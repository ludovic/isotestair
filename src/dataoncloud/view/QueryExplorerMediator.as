package dataoncloud.view
{
	import __AS3__.vec.Vector;
	
	import dataoncloud.ApplicationFacade;
	import dataoncloud.model.vo.SQLQuery;
	import dataoncloud.view.components.QueryExplorer;
	
	import flash.events.Event;
	
	import mx.controls.dataGridClasses.DataGridColumn;
	
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
            this.queryExplorer.addEventListener(QueryExplorer.VIEW_CONNECTION_MANAGER,onBack);
            
        }

        override public function listNotificationInterests():Array 
        {
            return [ ApplicationFacade.VIEW_QUERY_EXPLORER,
            		ApplicationFacade.INFO_SQL_QUERY,
            		ApplicationFacade.SQL_RESULT_XML];
        }
         
        override public function handleNotification( note:INotification ):void 
        {
        	var j:int;
            switch ( note.getName() ) 
            {
                case ApplicationFacade.VIEW_QUERY_EXPLORER:
                	this.queryExplorer.clearText();
                    this.queryExplorer.connection=note.getBody();
                break;
				case ApplicationFacade.INFO_SQL_QUERY:
                    this.queryExplorer.responseSQL.text+=note.getBody().data+'\n';
                break;
                case ApplicationFacade.SQL_RESULT_XML:

                    //load the data grid in the component with headers (The header are the first line received)
                    var myVector:Vector.<Object> = (note.getBody() as Vector.<Object>);
                    var tab:Array = new Array();
                    var columnName:Array = myVector[0] as Array;
                    for(j=1;j<myVector.length;j++)                    
                    	tab[j-1]=myVector[j];
                    
                    this.queryExplorer.sqlresult.dataProvider={};
                    this.queryExplorer.sqlresult.dataProvider=tab;
 
                    if (tab.length>0)
                    	for(j=0;j<columnName.length;j++)
                    		(this.queryExplorer.sqlresult.columns[j] as DataGridColumn).headerText=columnName[j];                          	
				break;
            }
        }
        
        private function get queryExplorer():QueryExplorer
        {
        	return viewComponent as QueryExplorer;
        }
        
        private function onExecute(event:Event):void
        {
        	var mySQLQuery:SQLQuery = new SQLQuery(this.queryExplorer.connection,this.queryExplorer.requette.text);        	
        	sendNotification(ApplicationFacade.EXECUTE_QUERY,mySQLQuery);
        } 
        
        private function onCancel(event:Event):void
        {        	
        	sendNotification(ApplicationFacade.CANCEL_QUERY,null);
        }
        private function onBack(event:Event):void
        {
            sendNotification(ApplicationFacade.VIEW_CONNECTION_MANAGER,null);
        }
    }
}