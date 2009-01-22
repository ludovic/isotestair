package	 dataoncloud.controller
{
    import dataoncloud.model.SqlProxy;
    import dataoncloud.model.vo.MyExcelSheet;
    
    import org.puremvc.as3.interfaces.*;
    import org.puremvc.as3.patterns.command.*;
    import org.puremvc.as3.patterns.observer.*;

    public class LoadExcelSheet extends SimpleCommand
    {
        override public function execute( note:INotification ) :void    
        {     
			var sqlProxy:SqlProxy = facade.retrieveProxy(SqlProxy.NAME) as SqlProxy;
			sqlProxy.loadExcelSheet(note.getBody() as MyExcelSheet);
        }
    }

}