package dataoncloud
{
	import dataoncloud.controller.ConnectionTestCommand;
	import dataoncloud.controller.RetrieveDatabseCommand;
	import dataoncloud.controller.startup.ApplicationStartupCommand;
	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.facade.*;
	import org.puremvc.as3.patterns.proxy.*;
    public class ApplicationFacade extends Facade
    {
        
        // Notification name constants
        public static const STARTUP:String                     	= 	"startup";
        public static const CONNECTION_TEST:String				=	"connectionTest";
		public static const CONNECTION_TEST_RESULT:String		=	"connectionTestResult";
		public static const RETRIEVE_DATABASE:String			=	"retrieveDatabse";
		public static const RETRIEVE_DATABASE_RESULT:String		=	"retrieveDatabaseResult";
		
        /**
         * Singleton ApplicationFacade Factory Method
         */
        public static function getInstance() : ApplicationFacade 
        {
            if ( instance == null ) instance = new ApplicationFacade( );
            return instance as ApplicationFacade;
        }

        /**
         * Register Commands with the Controller 
         */
        override protected function initializeController( ) : void 
        {
            super.initializeController(); 
            registerCommand( STARTUP, ApplicationStartupCommand );
            registerCommand( CONNECTION_TEST, dataoncloud.controller.ConnectionTestCommand );
            registerCommand( RETRIEVE_DATABASE, dataoncloud.controller.RetrieveDatabseCommand);
        }
        
        public function startup( app:BimeDesktop ):void
        {
            sendNotification( STARTUP, app );
        }
    }

}