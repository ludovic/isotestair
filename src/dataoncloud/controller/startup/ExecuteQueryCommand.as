package	 dataoncloud.controller
{
    import dataoncloud.model.SqlProxy;
    
    import org.puremvc.as3.interfaces.*;
    import org.puremvc.as3.patterns.command.*;
    import org.puremvc.as3.patterns.observer.*;
    
    /**
     * Create and register <code>Proxy</code>s with the <code>Model</code>.
     */
    public class ExecuteQuery extends SimpleCommand
    {
        override public function execute( note:INotification ) :void    
        {
        	
        }
    }

}