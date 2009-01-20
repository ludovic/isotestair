package dataoncloud
{
	import dataoncloud.controller.CancelQueryCommand;
	import dataoncloud.controller.ConnectionTestCommand;
	import dataoncloud.controller.ExecuteQueryCommand;
	import dataoncloud.controller.GetExcelSheetNames;
	import dataoncloud.controller.RetrieveDatabseCommand;
	import dataoncloud.controller.LoadExcelSheet;
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
		public static const VIEW_CONNECTION_MANAGER:String      =   "viewConnectionManager";
        public static const VIEW_QUERY_EXPLORER:String     		=   "viewQueryExplorer";
        public static const VIEW_EXCEL_EXPLORER:String			=	"viewExcelExplorer";
        public static const EXECUTE_QUERY:String				=	"executeQuery";
        public static const CANCEL_QUERY:String					=	"cancelQuery";
        public static const INFO_SQL_QUERY:String				=	"infoSQLQuery";
        public static const SQL_RESULT_XML:String				=	"SQLResultXML";
        public static const NAME_SHEETS_EXCEL:String			=	"nameSheetsExcel";
        public static const GET_NAME_SHEETS_EXCEL:String		=	"getNameSheetsExcel";
        public static const LOAD_EXCEL_SHEET:String				=	"loadExcelSheet";
        public static const EXCEL_DATA:String					=	"excelData";
        
		
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
            registerCommand( EXECUTE_QUERY, dataoncloud.controller.ExecuteQueryCommand);
            registerCommand( CANCEL_QUERY, dataoncloud.controller.CancelQueryCommand);
            registerCommand( GET_NAME_SHEETS_EXCEL, dataoncloud.controller.GetExcelSheetNames);
            registerCommand( LOAD_EXCEL_SHEET, dataoncloud.controller.LoadExcelSheet);
        }
        
        public function startup( app:BimeDesktop ):void
        {
            sendNotification( STARTUP, app );
        }
    }

}