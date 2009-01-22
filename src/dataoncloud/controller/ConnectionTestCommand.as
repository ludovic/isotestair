package	 dataoncloud.controller
{
    import dataoncloud.model.SqlProxy;
    
    import org.puremvc.as3.interfaces.*;
    import org.puremvc.as3.patterns.command.*;
    import org.puremvc.as3.patterns.observer.*;
    
    public class ConnectionTestCommand extends SimpleCommand
    {
        override public function execute( note:INotification ) :void    
        {
			var connection:Object = note.getBody()

        	       
			var sqlProxy:SqlProxy = facade.retrieveProxy(SqlProxy.NAME) as SqlProxy;
			sqlProxy.testConnection(connection);
        }
    }

}