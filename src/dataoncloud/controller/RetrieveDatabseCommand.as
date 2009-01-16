package dataoncloud.controller
{
	import dataoncloud.model.SqlProxy;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class RetrieveDatabseCommand extends SimpleCommand
	{
		override public function execute(notification:INotification):void
		{
			var param:Object = notification.getBody();
			
			var login:String = param.login
        	var mdp:String	= param.mdp
        	var type:String = param.type
        	var host:String = param.host
        	var port:String = param.port
        	var sid:String = param.sid
        	
        	var sqlProxy:SqlProxy = facade.retrieveProxy(SqlProxy.NAME) as SqlProxy;
        	sqlProxy.retrieveDatabase(login,
        								mdp,
        								type,
        								host,
        								port,
        								sid);
		}
	}
}