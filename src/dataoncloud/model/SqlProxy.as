package dataoncloud.model
{
	import dataoncloud.ApplicationFacade;
	
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
        }
        
        // collections
        
        
        // Business methods ---
        public function testConnection(login:String,mdp:String,type:String,host:String,port:String,sid:String):void
    	{	
    		var bridgeInstance:BridgeInstance = new BridgeInstance();
    		var ds:String;
    		switch (type)
    		{
    			// oracle
    			case "0":
    				 ds = login + "##" + mdp + "##" + type + "##" + "jdbc:oracle:thin:@"+host+":"+port+":"+sid;
    			break;
    			//SQL server
    			case "2":
    				ds = login + "##" + mdp + "##" + type + "##" +  "jdbc:sqlserver://" + host + ":" + port;
    			break;
    			//MYsql
    			case "3":
    				ds = login + "##" + mdp + "##" + type + "##" +  "jdbc:mysql://" + host + ":" + port;
    			break;
    			//postgre
    			case "4":
    				ds = login + "##" + mdp + "##" + type + "##" +  "jdbc:postgresql://" + host + ":" + port
    			break;
    		}
    		
    		bridgeInstance.sendMessage( new Message( 'dataSource', ds ) );
    		bridgeInstance.addEventListener(ResultEvent.RESULT,testConnectionResultHandler);
    		bridgeInstance.addEventListener(MerapiErrorEvent.CONNECT_FAILURE_ERROR, testConnectionFaultHandler,false,0,true);
    	}
    	
    	public function retrieveDatabase(login:String,password:String,type:String,host:String,port:String,sid:String):void
    	{
    		var bridgeInstance:BridgeInstance = new BridgeInstance();
    		var ds:String;
    		switch (type){
    			// Sql Server
    			case "2":
    				ds = login + "##" + password + "##" + type + "##" +  "jdbc:sqlserver://" + host + ":" + port + ";database=master";
    				bridgeInstance.sendMessage(new Message("dataSource_getDBSqlServer",ds));
    			break;
    			// Mysql
    			case "3":
    				ds = login + "##" + password + "##" + type + "##" +  "jdbc:mysql://" + host + ":" + port;
    				bridgeInstance.sendMessage(new Message("dataSource_getDBMySql",ds));
    			break;
    			//Postgre 
    			case "4":
    				ds = login + "##" + password + "##" + type + "##" +  "jdbc:postgresql://" + host + ":" + port + "/postgres";
    				bridgeInstance.sendMessage(new Message("dataSource_getDBPostgre",ds));
    			break;
    		}
    		bridgeInstance.addEventListener(ResultEvent.RESULT,retrieveDatabaseResultHandler,false,0,true);
    		bridgeInstance.addEventListener(MerapiErrorEvent.CONNECT_FAILURE_ERROR, retrieveDatabaseFaultHandler,false,0,true);
    	}
    	
    	
    	// Result methods
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
     	
     	
     	// Fault methods
     	private function testConnectionFaultHandler (event:FaultEvent):void
     	{
     		
     	}
     	private function retrieveDatabaseFaultHandler (event:FaultEvent):void
     	{
     		
     	}
    }

}