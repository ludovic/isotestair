package dataoncloud.view
{
	
	import dataoncloud.*;
	import dataoncloud.model.*;
	import dataoncloud.view.components.*;
	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.mediator.Mediator;
    
	public class ApplicationMediator extends Mediator implements IMediator
	{
		 // Cannonical name of the Mediator
        public static const NAME:String = "ApplicationMediator";
        
        public static const CONNECTION_MANAGER : Number =   0;
        public static const QUERY_EXPLORER: Number =    1;
        public static const EXCEL_EXPLORER: Number =    2;
        
        /**
         * Constructor. 
         */
        public function ApplicationMediator( viewComponent:Object ) 
        {
            // pass the viewComponent to the superclass where 
            // it will be stored in the inherited viewComponent property
            super( NAME, viewComponent );
            
            facade.registerMediator( new ConnectionManagerMediator( app.connectionManager ));
            facade.registerMediator( new QueryExplorerMediator(app.queryExplorer));
            facade.registerMediator( new ExcelExplorerMediator(app.excelExplorer));
        }
        
        
        override public function listNotificationInterests():Array 
        {
            
            return [ ApplicationFacade.VIEW_CONNECTION_MANAGER,
                     ApplicationFacade.VIEW_QUERY_EXPLORER,
                     ApplicationFacade.VIEW_EXCEL_EXPLORER
                    ];
        }
        
        override public function handleNotification( note:INotification ):void 
        {
            switch ( note.getName() ) 
            { 
                
                case ApplicationFacade.VIEW_CONNECTION_MANAGER:
                	app.vwStack.selectedIndex = CONNECTION_MANAGER;
				break;
                case ApplicationFacade.VIEW_QUERY_EXPLORER:
                	app.vwStack.selectedIndex = QUERY_EXPLORER;
				break;
				case ApplicationFacade.VIEW_EXCEL_EXPLORER:
                	app.vwStack.selectedIndex = EXCEL_EXPLORER;
				break;
            }
        }
        
        
        protected function get app():BimeDesktop
        {
            return viewComponent as BimeDesktop
        }
	}
}