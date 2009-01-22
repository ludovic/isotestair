package dataoncloud.view
{
	import dataoncloud.ApplicationFacade;
	import dataoncloud.view.components.ConnectionManager;
	import dataoncloud.view.events.DocEvent;
	
	import flash.events.Event;
	
	import mx.controls.Alert;
	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.mediator.Mediator; 
    
    /**
     * A Mediator for interacting with the EmployeeLogin component.
     */
    public class ConnectionManagerMediator extends Mediator implements IMediator
    {
        // Cannonical name of the Mediator
        public static const NAME:String = "ConnectionManagerMediator";
        
        /**
         * Constructor. 
         */
        public function ConnectionManagerMediator( viewComponent:Object ) 
        {
            // pass the viewComponent to the superclass where 
            // it will be stored in the inherited viewComponent property
            super( NAME, viewComponent );
            this.connectionManager.addEventListener(ConnectionManager.CONNECTION_TEST,onConnectionTest);
            this.connectionManager.addEventListener(ConnectionManager.RETRIEVE_DATABASE,onRetrieveDatabase);
            this.connectionManager.addEventListener(ConnectionManager.VIEW_QUERY_EXPLORER,onView);
            this.connectionManager.addEventListener(ConnectionManager.LOAD_FILE,onLoadFile);
        }
        

		private function get connectionManager():ConnectionManager
		{
			return viewComponent as ConnectionManager;
		}

        override public function listNotificationInterests():Array 
        {
            return [ ApplicationFacade.CONNECTION_TEST_RESULT,
            ApplicationFacade.RETRIEVE_DATABASE_RESULT,
            ApplicationFacade.VIEW_QUERY_EXPLORER  ];
        }


        override public function handleNotification( note:INotification ):void 
        {
        	switch(note.getName())
        	{
        		case ApplicationFacade.CONNECTION_TEST_RESULT:
					this.connectionManager.responseText.text +=(note.getBody() as String)+'\n';        			
        		break;
        		case ApplicationFacade.RETRIEVE_DATABASE_RESULT:
        			var message:Object = note.getBody();
        			if (message.type == "DBMySql")
        			{
        				this.connectionManager.cmbDBMysql.dataProvider = message.data;
        			}
        			else if (message.type == "DBPostgreSql")
        			{
        				this.connectionManager.cmbDBPostgresql.dataProvider = message.data;
        			}
        			else if (message.type == "DBSqlServer")
        			{
        				this.connectionManager.cmbDBSqlserver.dataProvider = message.data;
        			}
        		break;	
        		case ApplicationFacade.VIEW_QUERY_EXPLORER:
        		                
                break;
        	}
        }
        
        private function onRetrieveDatabase(event:DocEvent):void
        {
        	sendNotification(ApplicationFacade.RETRIEVE_DATABASE,event.body);
        }
        private function onConnectionTest(event:DocEvent):void
        {
        	sendNotification(ApplicationFacade.CONNECTION_TEST,event.body);
        }
        private function onView(event:DocEvent):void
        {
            sendNotification(ApplicationFacade.VIEW_QUERY_EXPLORER,event.body);
        }
        private function onLoadFile(event:Event):void
        {
        	switch(this.connectionManager.source.extension)
        	{
	        	case 'xls':
	        		sendNotification(ApplicationFacade.VIEW_EXCEL_EXPLORER,this.connectionManager.sourceTxt.text);
	        	break;
	        }
        }
    }
}