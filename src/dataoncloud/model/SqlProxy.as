package dataoncloud.model
{
	import __AS3__.vec.Vector;
	
	import com.probertson.utils.GZIPEncoder;
	
	import dataoncloud.ApplicationFacade;
	import dataoncloud.model.vo.MyExcelSheet;
	import dataoncloud.model.vo.SQLQuery;
	
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
        
        /**
         * Create the url for JDBC. 
         * @param connection Object packaging the connection parameters.
         * @return The url created.
         */       
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
        
        /**
         * Test the connection paramaters.
         * @param connection Object packaging the connection parameters.
         */        
        public function testConnection(connection:Object):void
    	{	
    		var ds:String;
			ds = this.rewriteURL(connection);
 		
 		
    		bridgeInst.sendMessage( new Message( 'dataSource', ds ) );
    	}
    	
	   	/**
	   	 * Retrieves the names of databases. 
	   	 * @param connection Object packaging the connection parameters.
	   	 */    	
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
    	
    	/**
    	 * Send the query to execute to JDBC.
    	 * @param mySQLQuery Object packaging the sql query and the connection parameters.
    	 */    	
    	public function executeQuery(mySQLQuery:SQLQuery):void
    	{
    		var ds:String;
    		ds = this.rewriteURL(mySQLQuery.connection);
    		switch (mySQLQuery.connection.type)
    		{
			// oracle
//			case 0:
//				 ds = connection.login + "##" + connection.mdp + "##" + connection.type + "##" + "jdbc:oracle:thin:@"+connection.host+":"+connection.port+":"+connection.sid;
//			break;
			//SQL server
//			case 2:
//				ds = connection.login + "##" + connection.mdp + "##" + connection.type + "##" +  "jdbc:sqlserver://" + connection.host + ":" + connection.port;
//			break;
			//MYsql
			case 3:
				ds = ds+"/"+mySQLQuery.connection.database;
			break;
			postgre
			case 4:				
				ds = ds+"/"+mySQLQuery.connection.database;
			break;
    		}
				
    		bridgeInst.sendMessage( new Message( 'sqlRequest_request', ds + "##" + mySQLQuery.query ) );
    	}
    	
    	/**
    	 * Cancel the query who is executing in the Java part.
    	 */
    	public function cancelQuery():void
    	{				
    		bridgeInst.sendMessage( new Message( 'sqlRequest_cancel',null) );
    	}
    	
    	/**
    	 * Ask to Java to send to flex the names of the Excel file sheets.
    	 * @param path The path of the Excel file.
    	 */
    	public function getNameExcelSheets(path:String):void
    	{
    		bridgeInst.sendMessage( new Message( 'getNameSheets',path) );
    	}
    	/**
    	 * Send an order to Java to load an Excel file.
    	 * @param myExcelSheet Object packaging the file path and the sheet to load.
    	 * 
    	 */    	
    	public function loadExcelSheet(myExcelSheet:MyExcelSheet):void
    	{
    		bridgeInst.sendMessage( new Message( 'getExcelData',myExcelSheet.path+'##'+myExcelSheet.sheetName));
    	}   	
    	
    	// Result methods
    	/**
    	 * Dispatch the Merapi events between different functions.
    	 * @param event The Merapi events.
    	 */    	
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
    			case 'sqlStart':
    				this.sqlResultHandler(event);
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
    			case 'excelStart':
    				this.excelResultHandler(event);
    			break;
    			case 'excelResult':
    				this.excelResultHandler(event);
    			break;
    			case 'excelStop':
    				this.excelResultHandler(event);
    			break;    			
    		}
    	}
    	/**
    	 * Get the result of the test connection and send it by notification : CONNECTION_TEST_RESULT. 
    	 * @param event The Merapi event.
    	 */    	
    	private function testConnectionResultHandler(event : ResultEvent): void
    	{
			var message:Object = event.result.data;
			sendNotification(ApplicationFacade.CONNECTION_TEST_RESULT,message);
     	}
     	/**
    	 * Get the result of the retrieve of the names of database and send it by notification : RETRIEVE_DATABASE_RESULT. 
    	 * @param event The Merapi event.
    	 */
     	private function retrieveDatabaseResultHandler(event:ResultEvent):void
     	{
     		var message:Object = event.result;
     		sendNotification(ApplicationFacade.RETRIEVE_DATABASE_RESULT,message);
     	}
     	/**
    	 * Get the info result of the SQL execution and send it by notification : INFO_SQL_QUERY. 
    	 * @param event The Merapi event.
    	 */
     	private function infoResultHandler(event:ResultEvent):void
     	{
     		var message:Object = event.result;
     		sendNotification(ApplicationFacade.INFO_SQL_QUERY,message);
     	}
     	
     	/**
     	 * Retrieve the result of the sql query
     	 */
     	private var partResult:Vector.<Object>=null;
     	 
     	/**
     	 * Retrieve the result of the sql query in var partResult and send two notifications : SQL_RESULT_XML, with the result, and INFO_SQL_QUERY, whith the info.
     	 * @param event The Merapi event. 
     	 */     	 
     	private function sqlResultHandler(event:ResultEvent):void
     	{     		
     		if(event.result.type=='sqlStart')
     		{
     			partResult=null;
			}     		
     		else if(event.result.type=='sqlResult')
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
            }
     	}
     	/**
     	 * Retrieve the names of the Excel sheets and send a notification NAME_SHEETS_EXCEL whith the names.
     	 * @param event The Merapi event. 
     	 */     	
     	private function namesSheeExcelHandler(event:ResultEvent):void
     	{
     		//event.result.getData -> String[]
     		sendNotification(ApplicationFacade.NAME_SHEETS_EXCEL,event.result.data);
     	}
     	/**
     	 * Retrieve the names of the Excel sheets and send a notification NAME_SHEETS_EXCEL with the names.
     	 * @param event The Merapi event. 
     	 */
     	private var excelResult:Array=null;
     	private function excelResultHandler(event:ResultEvent):void
     	{
     		
     		if(event.result.type=='excelStart')
     		{
     			excelResult=null;
     		}
     		if(event.result.type=='excelResult')
     		{
     			if (excelResult==null)
     				excelResult = event.result.data as Array;
     			else
     				excelResult = excelResult.concat(event.result.data as Array);
     		}
     		else if(event.result.type=='excelStop')
     		{
     			sendNotification(ApplicationFacade.EXCEL_DATA,excelResult);
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