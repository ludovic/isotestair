package	 dataoncloud.controller
{
    import dataoncloud.model.SqlProxy;
    import dataoncloud.model.vo.MySQLQuery;
    
    import org.puremvc.as3.interfaces.*;
    import org.puremvc.as3.patterns.command.*;
    import org.puremvc.as3.patterns.observer.*;
    
    public class ExecuteQueryCommand extends SimpleCommand
    {
        override public function execute( note:INotification ) :void    
        {
			var mySQLQuery:MySQLQuery = note.getBody() as MySQLQuery;

        	       
			var sqlProxy:SqlProxy = facade.retrieveProxy(SqlProxy.NAME) as SqlProxy;
			sqlProxy.executeQuery(mySQLQuery);
        }
    }

}