package  dataoncloud.controller.startup
{
	import org.puremvc.as3.patterns.command.*;
    import org.puremvc.as3.interfaces.*;

    public class ApplicationStartupCommand extends MacroCommand
    {
        
        /**
         * Initialize the MacroCommand by adding its SubCommands.
         * 
         * <P>
         * Since we built the UI using an MXML <code>Application</code> tag, those
         * components are created first. The top level <code>Application</code>
         * then initialized the <code>ApplicationFacade</code>, which in turn initialized 
         * the <code>Controller</code>, registering Commands. Then the 
         * <code>Application</code> sent the <code>APP_STARTUP
         * Notification</code>, leading to this <code>MacroCommand</code>&apos;s execution.</P>
         * 
         * <P>
         * It is important for us to create and register Proxys with the Model 
         * prior to creating and registering Mediators with the View, since 
         * availability of Model data is often essential to the proper 
         * initialization of the View.</P>
         * 
         * <P>
         * So, <code>ApplicationStartupCommand</code> first executes 
         * <code>ModelPrepCommand</code> followed by <code>ViewPrepCommand</code></P>
         * 
         */
        override protected function initializeMacroCommand() :void
        {
            addSubCommand( ModelPrepCommand );
            addSubCommand( ViewPrepCommand );
        }
        
    }

}