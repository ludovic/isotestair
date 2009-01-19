package dataoncloud.view
{
	
	import dataoncloud.*;
	import dataoncloud.ApplicationFacade;
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
        
        /**
         * Constructor. 
         */
        public function ApplicationMediator( viewComponent:Object ) 
        {
            // pass the viewComponent to the superclass where 
            // it will be stored in the inherited viewComponent property
            super( NAME, viewComponent );
            
            facade.registerMediator( new ConnectionManagerMediator( app.connectionManager ));
        }
        
        
        override public function listNotificationInterests():Array 
        {
            
            return [ ApplicationFacade.VIEW_CONNECTION_MANAGER,
                     ApplicationFacade.VIEW_QUERY_EXPLORER
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
            }
        }
        
        
        protected function get app():BimeDesktop
        {
            return viewComponent as BimeDesktop
        }
	}
}