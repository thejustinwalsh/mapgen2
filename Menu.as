package
{
	import flash.desktop.NativeApplication;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import events.MenuEvent;

	public class Menu extends EventDispatcher
	{
		private var nativeMenu:NativeMenu;
		
		public function Menu(stage:Stage)
		{
			if (NativeApplication.supportsMenu) {
				nativeMenu = NativeApplication.nativeApplication.menu;
			}
			else if (NativeWindow.supportsMenu) {
				nativeMenu = new NativeMenu();
				stage.nativeWindow.menu = nativeMenu;
			}
			
			buildFileMenu();
		}
		
		private function buildFileMenu():void
		{
			var fileMenu:NativeMenuItem;
			var fileMenuItems:NativeMenu;
			if (NativeApplication.supportsMenu) {
				fileMenu = Menu.getMenuItemByLabel(nativeMenu, "File");
				fileMenuItems = fileMenu.submenu;
			}
			else {
				fileMenu = nativeMenu.addItem(new NativeMenuItem("File"));
				fileMenuItems = new NativeMenu();
				fileMenu.submenu = fileMenuItems;
			}
			
			var newItem:NativeMenuItem = fileMenuItems.addItemAt(new NativeMenuItem("New"), 0);
			newItem.keyEquivalent = "n";
			newItem.addEventListener(Event.SELECT, onMenuItemSelected, false, 0, true);
			
			var openItem:NativeMenuItem = fileMenuItems.addItemAt(new NativeMenuItem("Open"), 1);
			openItem.keyEquivalent = "o";
			openItem.addEventListener(Event.SELECT, onMenuItemSelected, false, 0, true);
			
			var saveItem:NativeMenuItem = fileMenuItems.addItemAt(new NativeMenuItem("Save"), 2);
			saveItem.keyEquivalent = "s";
			saveItem.addEventListener(Event.SELECT, onMenuItemSelected, false, 0, true);
			
			var exportMenu:NativeMenuItem = fileMenuItems.addItemAt(new NativeMenuItem("Export"), 3);
			var exportMenuItems:NativeMenu = new NativeMenu();
			exportMenu.submenu = exportMenuItems;
			
			var tiledExportItem:NativeMenuItem = exportMenuItems.addItem(new NativeMenuItem("Tiled"));
			tiledExportItem.keyEquivalent = "e";
			tiledExportItem.addEventListener(Event.SELECT, onMenuItemSelected, false, 0, true);
			
			var imageExportItem:NativeMenuItem = exportMenuItems.addItem(new NativeMenuItem("Image"));
			imageExportItem.addEventListener(Event.SELECT, onMenuItemSelected, false, 0, true);
			
			var elevationExportItem:NativeMenuItem = exportMenuItems.addItem(new NativeMenuItem("Elevation Map"));
			elevationExportItem.addEventListener(Event.SELECT, onMenuItemSelected, false, 0, true);
			
			var moistureExportItem:NativeMenuItem = exportMenuItems.addItem(new NativeMenuItem("Moisture Map"));
			moistureExportItem.addEventListener(Event.SELECT, onMenuItemSelected, false, 0, true);
		}
		
		private function onMenuItemSelected(e:Event):void
		{
			var menuItem:NativeMenuItem = e.target as NativeMenuItem;
			switch (menuItem.label) {
				case "New":  			dispatchEvent(new MenuEvent(MenuEvent.NEW)); break;
				case "Open": 			dispatchEvent(new MenuEvent(MenuEvent.OPEN)); break;
				case "Save": 			dispatchEvent(new MenuEvent(MenuEvent.SAVE)); break;
				case "Tiled":			dispatchEvent(new MenuEvent(MenuEvent.EXPORT_TILED)); break;
				case "Image":			dispatchEvent(new MenuEvent(MenuEvent.EXPORT_IMAGE)); break;
				case "Elevation Map":	dispatchEvent(new MenuEvent(MenuEvent.EXPORT_ELEVATION)); break;
				case "Moisture Map":	dispatchEvent(new MenuEvent(MenuEvent.EXPORT_MOISTURE)); break;
			}
		}
		
		private static function getMenuItemByLabel(menu:NativeMenu, labelName:String):NativeMenuItem
		{
			var count:int = menu.items.length;
			for (var i:int = 0; i < count; ++i) {
				var item:NativeMenuItem = menu.getItemAt(i);
				if(item.label === labelName) return item;
			}
			return null;
		}
	}
}