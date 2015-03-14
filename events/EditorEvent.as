package events
{
	import flash.events.Event;
	
	public class EditorEvent extends Event
	{
		public static var CLOSED:String = "EditorEvent.Closed";
		public static var CLOSING:String = "EditorEvent.Closing";
		public static var OPENED:String = "EditorEvent.Opened";
		public static var OPENING:String = "EditorEvent.Opening";
		
		public function EditorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}