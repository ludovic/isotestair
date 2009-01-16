package dataoncloud.view
{
	import mx.controls.Alert;
    import flash.events.Event;
    import org.puremvc.as3.interfaces.*;
    import org.puremvc.as3.patterns.mediator.Mediator;
    
    /**
     * A Mediator for interacting with the EmployeeLogin component.
     */
    public class SqlQueryMediator extends Mediator implements IMediator
    {
        // Cannonical name of the Mediator
        public static const NAME:String = "SqlQueryMediator";
        
        /**
         * Constructor. 
         */
        public function SqlQueryMediator( viewComponent:Object ) 
        {
            // pass the viewComponent to the superclass where 
            // it will be stored in the inherited viewComponent property
            super( NAME, viewComponent );
            
        }

        /**
         * List all notifications this Mediator is interested in.
         * <P>
         * Automatically called by the framework when the mediator
         * is registered with the view.</P>
         * 
         * @return Array the list of Nofitication names
         */
        override public function listNotificationInterests():Array 
        {
            return [ ApplicationFacade.APP_LOGOUT ];
        }

        /**
         * Handle all notifications this Mediator is interested in.
         * <P>
         * Called by the framework when a notification is sent that
         * this mediator expressed an interest in when registered
         * (see <code>listNotificationInterests</code>.</P>
         * 
         * @param INotification a notification 
         */
        override public function handleNotification( note:INotification ):void 
        {
            switch ( note.getName() ) 
            {
                case ApplicationFacade.APP_LOGOUT:
                    employeeLogin.resetLogin();
                    break;
            }
        }
                    
        /**
         * Cast the viewComponent to its actual type.
         * 
         * <P>
         * This is a useful idiom for mediators. The
         * PureMVC Mediator class defines a viewComponent
         * property of type Object. </P>
         * 
         * <P>
         * Here, we cast the generic viewComponent to 
         * its actual type in a protected mode. This 
         * retains encapsulation, while allowing the instance
         * (and subclassed instance) access to a 
         * strongly typed reference with a meaningful
         * name.</P>
         * 
         * @return EmployeeLogin the viewComponent cast to EmployeeLogin
         */
        protected function get employeeLogin():EmployeeLogin
        {
            return viewComponent as EmployeeLogin;
        }
        
        private function login( event:Event = null ) : void
        {
            var isValid:Boolean = userProxy.validate(employeeLogin.username.text,employeeLogin.password.text);
            if( isValid )
            {
                sendNotification( ApplicationFacade.VIEW_EMPLOYEE_LIST );
            }
            else
            {
                // if the auth info was incorrect, prompt with an alert box and remain on the login screen
                Alert.show( "Invaild username and/or password. Please try again.","Login Failed" );
            }
        }
        private var userProxy:UserProxy;
        
    }
}