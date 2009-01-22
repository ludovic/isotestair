package dataoncloud.model
{
	import __AS3__.vec.Vector;
	
	import com.probertson.utils.GZIPEncoder;
	
	import dataoncloud.ApplicationFacade;
	import dataoncloud.model.vo.MyExcelSheet;
	import dataoncloud.model.vo.MySQLQuery;
	
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import merapi.*;
	import merapi.events.MerapiErrorEvent;
	import merapi.messages.Message;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.proxy.Proxy;
    

    public class SqlProxy extends Proxy implements IProxy
    {
    	private var bridgeInst:BridgeInstance = new BridgeInstance();
        public static const NAME:String = "SqlProxy";
        
        public function SqlProxy ( data:Object = null ) 
        {
            super ( NAME, data );
           	bridgeInst.addEventListener(ResultEvent.RESULT,onResultHandler,false,0,true);
    		bridgeInst.addEventListener(MerapiErrorEvent.CONNECT_FAILURE_ERROR, onFaultHandler,false,0,true);
        }
        
        // collections
        
        
        // Business methods ---
        private function rewriteURL(connection:Object):String
        {
        	var ds:String;
    		switch (connection.type)
    		{
    			// oracle
    			case 0:
    				 ds = connection.login + "##" + connection.mdp + "##" + connection.type + "##" + "jdbc:oracle:thin:@"+connection.host+":"+connection.port+":"+connection.sid;
    			break;
    			//SQL server
    			case 2:
    				ds = connection.login + "##" + connection.mdp + "##" + connection.type + "##" +  "jdbc:sqlserver://" + connection.host + ":" + connection.port;
    			break;
    			//MYsql
    			case 3:
    				ds = connection.login + "##" + connection.mdp + "##" + connection.type + "##" +  "jdbc:mysql://" + connection.host + ":" + connection.port;
    			break;
    			//postgre
    			case 4:
    				ds = connection.login + "##" + connection.mdp + "##" + connection.type + "##" +  "jdbc:postgresql://" + connection.host + ":" + connection.port
    			break;
    		}
    		return ds;
        }
        
        public function testConnection(connection:Object):void
    	{	
    		var ds:String;
			ds = this.rewriteURL(connection);
 		
 		
    		bridgeInst.sendMessage( new Message( 'dataSource', ds ) );
    	}
    	
	   	public function retrieveDatabase(connection:Object):void
    	{
    		var ds:String;
    		ds = this.rewriteURL(connection);
				switch (connection.type){
    			// Sql Server
    			case 2:
    				ds = ds + ";database=master";
    				bridgeInst.sendMessage(new Message("dataSource_getDBSqlServer",ds));
    			break;
    			// Mysql
    			case 3:    				
    				bridgeInst.sendMessage(new Message("dataSource_getDBMySql",ds));
    			break;
    			//Postgre 
    			case 4:
    				ds = ds + "/postgres";
    				bridgeInst.sendMessage(new Message("dataSource_getDBPostgre",ds));
    			break;
    		}
    	}
    	
    	public function executeQuery(mySQLQuery:MySQLQuery):void
    	{
    		var ds:String;
    		ds = this.rewriteURL(mySQLQuery.connection);
				
    		bridgeInst.sendMessage( new Message( 'sqlRequest_request', ds + "##" + mySQLQuery.query ) );
    	}
    	
    	public function cancelQuery():void
    	{				
    		bridgeInst.sendMessage( new Message( 'sqlRequest_cancel',null) );
    	}
    	
    	public function getNameExcelSheets(path:String):void
    	{
    		bridgeInst.sendMessage( new Message( 'getNameSheets',path) );
    	}
    	public function loadExcelSheet(myExcelSheet:MyExcelSheet):void
    	{
    		bridgeInst.sendMessage( new Message( 'getExcelData',myExcelSheet.path+'##'+myExcelSheet.sheetName));
    	}   	
    	
    	// Result methods
    	private function onResultHandler(event : ResultEvent): void
    	{
    		switch(event.result.type)
    		{
    			case 'testBase':
    				this.testConnectionResultHandler(event);
    			break;
    			case 'DBSqlServer':
    				this.retrieveDatabaseResultHandler(event);
    			break;
    			case 'DBMySql':
    				this.retrieveDatabaseResultHandler(event);
    			break;
    			case 'DBPostgreSql':
    				this.retrieveDatabaseResultHandler(event);
    			break;
    			case 'sqlInfo':
    				this.infoResultHandler(event);
    			break;
    			case 'sqlResult':
    				this.sqlResultHandler(event);
    			break;
    			case 'sqlStop':
                    this.sqlResultHandler(event);
                break;
    			case 'nameSheetsExcel':
    				this.namesSheeExcelHandler(event);
    			break;
    			case 'excelResult':
    				this.excelResultHandler(event);
    			break;
    			case 'excelStop':
    				this.excelResultHandler(event);
    			break;
    			
    		}
    	}
    	
    	private function testConnectionResultHandler(event : ResultEvent): void
    	{
			var message:Object = event.result.data;
			sendNotification(ApplicationFacade.CONNECTION_TEST_RESULT,message);
     	}
     	private function retrieveDatabaseResultHandler(event:ResultEvent):void
     	{
     		var message:Object = event.result;
     		sendNotification(ApplicationFacade.RETRIEVE_DATABASE_RESULT,message);
     	}
     	private function infoResultHandler(event:ResultEvent):void
     	{
     		var message:Object = event.result;
     		sendNotification(ApplicationFacade.INFO_SQL_QUERY,message);
     	}
     	
     	private var partResult:Vector.<Object>=null;
     	private function sqlResultHandler(event:ResultEvent):void
     	{     		
     		if(event.result.type=='sqlResult')
            {        	

				var begin : int = getTimer();
				var path:String= bridgeInst.lastMessage.data as String;

				var myFile:File = new File();
                myFile.nativePath=path; 
				var encoder:GZIPEncoder = new GZIPEncoder();
				var byteArray:ByteArray= new ByteArray();
				byteArray=encoder.uncompressToByteArray(myFile);
    
                var array:Vector.<Object> = Vector.<Object>(byteArray.readObject())
             
                if (partResult==null)
                {
                	var all:int=getTimer();                	
                    partResult = array;
                }
                else
                {
                	begin = getTimer();
					for(var i:int=0; i<array.length;i++)
						partResult.push(array[i]);
                }
               	myFile.deleteFile();
            }
            else if(event.result.type=='sqlStop')
            {
                sendNotification(ApplicationFacade.SQL_RESULT_XML,partResult);
                sendNotification(ApplicationFacade.INFO_SQL_QUERY,event.result);
                partResult=null;        
            }
     	}
     	private function namesSheeExcelHandler(event:ResultEvent):void
     	{
     		//event.result.getData -> String[]
     		sendNotification(ApplicationFacade.NAME_SHEETS_EXCEL,event.result.data);
     	}
     	private var result:Array=null;
     	private function excelResultHandler(event:ResultEvent):void
     	{
     		
     		if(event.result.type=='excelResult')
     		{
     			if (result==null)
     				result = event.result.data as Array;
     			else
     				result = result.concat(event.result.data as Array);
     		}
     		else if(event.result.type=='excelStop')
     		{
     			sendNotification(ApplicationFacade.EXCEL_DATA,result);
     			result=null;
     		}
     		
     	}     	
     	
     	// Fault methods
     	private function onFaultHandler (event:FaultEvent):void
     	{
     		
     	}
     	private function testConnectionFaultHandler (event:FaultEvent):void
     	{
     		
     	}
     	private function retrieveDatabaseFaultHandler (event:FaultEvent):void
     	{
     		
     	}
     	private function executeQueryFaultHandler (event:FaultEvent):void
     	{
     		
     	}
    }

}