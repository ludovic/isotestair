package dataoncloud.controller
{
	import dataoncloud.model.SqlProxy;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class RetrieveDatabseCommand extends SimpleCommand
	{
		override public function execute(notification:INotification):void
		{
			var connection:Object = notification.getBody();
        	var sqlProxy:SqlProxy = facade.retrieveProxy(SqlProxy.NAME) as SqlProxy;
        	sqlProxy.retrieveDatabase(connection);
		}
	}
}