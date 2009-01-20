package dataoncloud.view
{
	import dataoncloud.ApplicationFacade;
	import dataoncloud.view.components.ExcelExplorer;
	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.mediator.Mediator;
    
    /**
     * A Mediator for interacting with the EmployeeLogin component.
     */
    public class ExcelExplorerMediator extends Mediator implements IMediator
    {
        // Cannonical name of the Mediator
        public static const NAME:String = "ExcelExplorerMediator";
        
        private var path:String = null;
        
        /**
         * Constructor. 
         */
        public function ExcelExplorerMediator( viewComponent:Object ) 
        {
            // pass the viewComponent to the superclass where 
            // it will be stored in the inherited viewComponent property
            super( NAME, viewComponent );
            
        }

        override public function listNotificationInterests():Array 
        {
            return [ ApplicationFacade.VIEW_EXCEL_EXPLORER,
            		 ApplicationFacade.NAME_SHEETS_EXCEL];
        }


        override public function handleNotification( note:INotification ):void 
        {
            switch ( note.getName() ) 
            {
                case ApplicationFacade.VIEW_EXCEL_EXPLORER:
                    this.path=note.getBody() as String;
                    //Ask the different names of the Excel sheet
                    sendNotification(ApplicationFacade.GET_NAME_SHEETS_EXCEL,this.path);
                break;
                case ApplicationFacade.NAME_SHEETS_EXCEL:
                    this.excelExplorer.sheetNames.dataProvider=note.getBody() as Array;
                break;		
            }
        }
        
        private function get excelExplorer():ExcelExplorer
        {
        	return viewComponent as ExcelExplorer;
        }    
    }
}