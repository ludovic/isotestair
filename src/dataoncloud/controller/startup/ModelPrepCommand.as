package	 dataoncloud.controller.startup
{
    import dataoncloud.model.SqlProxy;
    
    import org.puremvc.as3.interfaces.*;
    import org.puremvc.as3.patterns.command.*;
    import org.puremvc.as3.patterns.observer.*;

    public class ModelPrepCommand extends SimpleCommand
    {
        override public function execute( note:INotification ) :void    
        {
            facade.registerProxy(new SqlProxy());
        }
    }

}