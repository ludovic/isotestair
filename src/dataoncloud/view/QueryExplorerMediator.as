package dataoncloud.view
{
	import dataoncloud.ApplicationFacade;
	import dataoncloud.model.vo.MySQLQuery;
	import dataoncloud.view.components.QueryExplorer;
	import dataoncloud.view.events.DocEvent;
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.mediator.Mediator;
    
    /**
     * A Mediator for interacting with the EmployeeLogin component.
     */
    public class QueryExplorerMediator extends Mediator implements IMediator
    {
        // Cannonical name of the Mediator
        public static const NAME:String = "QueryExplorerMediator";
        
        /**
         * Constructor. 
         */
        public function QueryExplorerMediator( viewComponent:Object ) 
        {
            // pass the viewComponent to the superclass where 
            // it will be stored in the inherited viewComponent property
            super( NAME, viewComponent );
            this.queryExplorer.addEventListener(QueryExplorer.EXECUTE_QUERY,onExecute);
            this.queryExplorer.addEventListener(QueryExplorer.CANCEL_QUERY,onCancel);
            this.queryExplorer.addEventListener(QueryExplorer.VIEW_CONNECTION_MANAGER,onView);
            
        }

        /**
         * List all notifications this Mediator is interested in.
         * <P>
         * Automatically called by the framework when the mediator
         * is registered with the view.</P>
         * 
         * @return Array the list of Nofitication names
         */
        override public function listNotificationInterests():Array 
        {
            return [ ApplicationFacade.VIEW_QUERY_EXPLORER,
            		ApplicationFacade.INFO_SQL_QUERY,
            		ApplicationFacade.SQL_RESULT_XML,
            		ApplicationFacade.VIEW_CONNECTION_MANAGER ];
        }

        /**
         * Handle all notifications this Mediator is interested in.
         * <P>
         * Called by the framework when a notification is sent that
         * this mediator expressed an interest in when registered
         * (see <code>listNotificationInterests</code>.</P>
         * 
         * @param INotification a notification 
         */
        override public function handleNotification( note:INotification ):void 
        {
            switch ( note.getName() ) 
            {
                case ApplicationFacade.VIEW_QUERY_EXPLORER:
                    this.queryExplorer.connection=note.getBody();
                break;
				case ApplicationFacade.INFO_SQL_QUERY:
                    this.queryExplorer.responseSQL.text+=note.getBody().data+'\n';
                break;
                case ApplicationFacade.SQL_RESULT_XML:
                var myXML:XML= new XML((note.getBody() as ByteArray).toString());
                    this.queryExplorer.sqlresult.dataProvider=myXML.session;
                break;
            }
        }
        
        private function get queryExplorer():QueryExplorer
        {
        	return viewComponent as QueryExplorer;
        }
        
        private function onExecute(event:Event):void
        {
        	var mySQLQuery:MySQLQuery = new MySQLQuery(this.queryExplorer.connection,this.queryExplorer.requette.text);        	
        	sendNotification(ApplicationFacade.EXECUTE_QUERY,mySQLQuery);
        }
        
        private function onCancel(event:Event):void
        {        	
        	sendNotification(ApplicationFacade.CANCEL_QUERY,null);
        }
        private function onView(event:Event):void
        {
            this.queryExplorer.clearText();
            sendNotification(ApplicationFacade.VIEW_CONNECTION_MANAGER,null);
        }
    }
}