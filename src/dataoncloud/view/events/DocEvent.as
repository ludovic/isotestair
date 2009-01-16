package dataoncloud.view.events
{
	import flash.events.Event;
	
	public class DocEvent extends Event
	{	
		public var body : Object;
		public function DocEvent(type:String,body:Object)
		{
			super(type);
			this.body = body;
		}
		public override function clone():Event{
			return new DocEvent(type,body);
		}
	}
}