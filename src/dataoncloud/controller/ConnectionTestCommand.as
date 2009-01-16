package	 dataoncloud.controller
{
    import dataoncloud.model.SqlProxy;
    
    import org.puremvc.as3.interfaces.*;
    import org.puremvc.as3.patterns.command.*;
    import org.puremvc.as3.patterns.observer.*;
    
    /**
     * Create and register <code>Proxy</code>s with the <code>Model</code>.
     */
    public class ConnectionTestCommand extends SimpleCommand
    {
        override public function execute( note:INotification ) :void    
        {
        	var param:Object = note.getBody()
        	
        	var login:String = param.login
        	var mdp:String	= param.mdp
        	var type:String = param.type
        	var host:String = param.host
        	var port:String = param.port
        	var sid:String = param.sid
        	       
           var sqlProxy:SqlProxy = facade.retrieveProxy(SqlProxy.NAME) as SqlProxy;
           sqlProxy.testConnection( login,
									mdp,
									type,
									host,
									port,
									sid
								   )
        }
    }

}