package events
{
	import flash.events.Event;

	public class MenuEvent extends Event
	{
		public static var NEW:String = "MenuEvent.New";
		public static var OPEN:String = "MenuEvent.Open";
		public static var SAVE:String = "MenuEvent.Save";
		public static var EXPORT_TILED:String = "MenuEvent.ExportTiled";
		public static var EXPORT_IMAGE:String = "MenuEvent.ExportImage";
		public static var EXPORT_ELEVATION:String = "MenuEvent.ExportElevation";
		public static var EXPORT_MOISTURE:String = "MenuEvent.ExportMoisture";
		
		public function MenuEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
