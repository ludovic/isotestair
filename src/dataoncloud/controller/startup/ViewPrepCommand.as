package dataoncloud.controller.startup
{
	import dataoncloud.view.ApplicationMediator;
	import dataoncloud.ApplicationFacade;
	import dataoncloud.*;
	import dataoncloud.model.*;	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.command.*;
	import org.puremvc.as3.patterns.observer.*;
    
    public class ViewPrepCommand extends SimpleCommand
    {
        override public function execute( note:INotification ) :void    
        {
        	var app:BimeDesktop = note.getBody() as BimeDesktop;
            // Register the ApplicationMediator
             facade.registerMediator( new ApplicationMediator( app ));            

        }

    }
}