package dataoncloud.controller.startup
{
	import dataoncloud.view.ConnectionManagerMediator;
	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.command.*;
	import org.puremvc.as3.patterns.observer.*;
    
    
    /**
     * Prepare the View for use.
     * 
     * <P>
     * The <code>Notification</code> was sent by the <code>Application</code>,
     * and a reference to that view component was passed on the note body.
     * The <code>ApplicationMediator</code> will be created and registered using this
     * reference. The <code>ApplicationMediator</code> will then register 
     * all the <code>Mediator</code>s for the components it created.</P>
     * 
     */
    public class ViewPrepCommand extends SimpleCommand
    {
        override public function execute( note:INotification ) :void    
        {
        	var app:BimeDesktop = note.getBody() as BimeDesktop;
            // Register the ApplicationMediator
             facade.registerMediator( new ConnectionManagerMediator( app.connectionManager ));            

        }

    }
}