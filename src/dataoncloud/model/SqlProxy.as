package dataoncloud.model
{
	import com.probertson.utils.GZIPEncoder;
	
	import dataoncloud.ApplicationFacade;
	import dataoncloud.model.vo.MySQLQuery;
	
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	import merapi.*;
	import merapi.events.MerapiErrorEvent;
	import merapi.messages.Message;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.proxy.Proxy;
    
    /**
     * A proxy for the User data
     */
    public class SqlProxy extends Proxy implements IProxy
    {
        public static const NAME:String = "SqlProxy";
        
        public function SqlProxy ( data:Object = null ) 
        {
            super ( NAME, data );
           	Bridge.instance.addEventListener(ResultEvent.RESULT,onResultHandler,false,0,true);
    		Bridge.instance.addEventListener(MerapiErrorEvent.CONNECT_FAILURE_ERROR, onFaultHandler,false,0,true);
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
 		
 		
    		Bridge.instance.sendMessage( new Message( 'dataSource', ds ) );
    	}
    	
	   	public function retrieveDatabase(connection:Object):void
    	{
    		var ds:String;
    		ds = this.rewriteURL(connection);
				switch (connection.type){
    			// Sql Server
    			case 2:
    				ds = ds + ";database=master";
    				Bridge.instance.sendMessage(new Message("dataSource_getDBSqlServer",ds));
    			break;
    			// Mysql
    			case 3:
    				//ds = login + "##" + password + "##" + type + "##" +  "jdbc:mysql://" + host + ":" + port;
    				Bridge.instance.sendMessage(new Message("dataSource_getDBMySql",ds));
    			break;
    			//Postgre 
    			case 4:
    				ds = ds + "/postgres";
    				Bridge.instance.sendMessage(new Message("dataSource_getDBPostgre",ds));
    			break;
    		}
    	}
    	
    	public function executeQuery(mySQLQuery:MySQLQuery):void
    	{
    		var ds:String;
    		ds = this.rewriteURL(mySQLQuery.connection);
				
    		Bridge.instance.sendMessage( new Message( 'sqlRequest_request', ds + "##" + mySQLQuery.query ) );
    	}
    	
    	public function cancelQuery():void
    	{				
    		Bridge.instance.sendMessage( new Message( 'sqlRequest_cancel',null) );
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
    			
    		}
    	}
    	
    	private function testConnectionResultHandler(event : ResultEvent): void
    	{
                if ((event.result as Message).type=='testBase')
                {
                	var message:Object = event.result.data;
                    sendNotification(ApplicationFacade.CONNECTION_TEST_RESULT,message);
                }
     	}
     	private function retrieveDatabaseResultHandler(event:ResultEvent):void
     	{
     		var message:Object = event.result;
     		sendNotification(ApplicationFacade.RETRIEVE_DATABASE_RESULT,message);
     	}
     	private function executeQueryResultHandler(event:ResultEvent):void
     	{
     		//var message:Object = event.result;
     		//sendNotification(ApplicationFacade.RETRIEVE_DATABASE_RESULT,message);
     	}
     	private function infoResultHandler(event:ResultEvent):void
     	{
     		var message:Object = event.result;
     		sendNotification(ApplicationFacade.INFO_SQL_QUERY,message);
     	}
     	private function sqlResultHandler(event:ResultEvent):void
     	{
     		var path:String = event.result.data as String;
     		
     		var myFile:File = new File();            
            var encoder:GZIPEncoder = new GZIPEncoder();
               
            myFile.nativePath=path;                       
            var tabByte:ByteArray=encoder.uncompressToByteArray(myFile);            
            //var myXML:XML= new XML(tabByte.toString());
            
            sendNotification(ApplicationFacade.SQL_RESULT_XML,tabByte);            
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