package dataoncloud.view
{
	import dataoncloud.ApplicationFacade;
	import dataoncloud.model.vo.MyExcelSheet;
	import dataoncloud.view.components.ExcelExplorer;
	
	import flash.events.Event;
	
	import mx.controls.dataGridClasses.DataGridColumn;
	
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
            this.excelExplorer.addEventListener(ExcelExplorer.LOAD_SHEET,onLoadSheet);
            this.excelExplorer.addEventListener(ExcelExplorer.BACK,onBack);
            
        }

        override public function listNotificationInterests():Array 
        {
            return [ ApplicationFacade.VIEW_EXCEL_EXPLORER,
            		 ApplicationFacade.NAME_SHEETS_EXCEL,
            		 ApplicationFacade.EXCEL_DATA];
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
                case ApplicationFacade.EXCEL_DATA:
                	var result:Array = (note.getBody() as Array);
                	if (this.excelExplorer.en_tetes.selected)
                	{
	                	if(result!=null)
	                	{
	                		this.excelExplorer.excelResult.dataProvider=result.splice(1,result.length-1);
	                    	var columnsTab:Array = this.excelExplorer.excelResult.columns;
	                    	for (var i:int=0;i<columnsTab.length;i++)
	                    		(columnsTab[i] as DataGridColumn).headerText=result[0][i];
	                 	}
	                 	else
	                 	{
	                 		this.excelExplorer.excelResult.dataProvider={};
	                 	}
	                }
	                else
	                {
	                	this.excelExplorer.excelResult.dataProvider={};
	                	this.excelExplorer.excelResult.dataProvider=result;
	                }                  
                break;	
            }
        }
        
        private function get excelExplorer():ExcelExplorer
        {
        	return viewComponent as ExcelExplorer;
        }
        
        private function onLoadSheet(event:Event):void
        {       
        	var myExcelSheet:MyExcelSheet = new MyExcelSheet(this.path,this.excelExplorer.sheetNames.selectedItem as String);
        	sendNotification(ApplicationFacade.LOAD_EXCEL_SHEET,myExcelSheet);
        }
        private function onBack(event:Event):void
        {       
        	this.excelExplorer.clear();
        	sendNotification(ApplicationFacade.VIEW_CONNECTION_MANAGER,null);
        }        
    }
}