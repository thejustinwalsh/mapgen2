package
{
	import com.bit101.components.ComboBox;
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.List;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import com.bit101.components.RadioButton;
	import com.bit101.components.Style;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	import data.Project;
	
	import events.EditorEvent;
	import events.MenuEvent;
	
	[SWF(width="924", height="600", frameRate=60)]
	public class MapGen2Tiled extends Sprite
	{
		private var mapgen:mapgen2;
		private var menu:Menu;
		private var project:Project;
		private var mapIndex:int;
		
		private var controls:Sprite;
		private var panel:Panel;
		private var tilesetEditor:TilesetEditor;
		private var histogramLabel:Label;
		private var mapListLabel:Label;
		private var mapList:List;
		private var mapListAddButton:PushButton;
		private var mapListRemoveButton:PushButton;
		private var tilesetLabel:Label;
		private var tilesetComboBox:ComboBox;
		private var tilesetEditorButton:PushButton;
		private var mapSeedLabel:Label;
		private var mapSeedInput:InputText;
		private var mapSeedRandomizeButton:PushButton;
		private var mapTypeLabel:Label;
		private var mapTypeRadioGroup:Array = [];
		private var pointCountLabel:Label;
		private var pointCountRadioGroup:Array = [];
		private var renderModeLabel:Label;
		private var renderModeRadioGroup:Array = [];
		private var PADDING:int = 24;
		
		private function newIslandSeed():String { return ((Math.random()*100000).toFixed(0) + "-" + (1 + Math.floor(9*Math.random())).toFixed(0)); }
		
		public function MapGen2Tiled()
		{
			super();
			stage.nativeWindow.width = 924 + (stage.nativeWindow.width - stage.nativeWindow.stage.stageWidth);
			stage.nativeWindow.height = 600 + (stage.nativeWindow.height - stage.nativeWindow.stage.stageHeight);
			
			menu = new Menu(stage);
			menu.addEventListener(MenuEvent.NEW, onNewProject, false, 0, true);
			menu.addEventListener(MenuEvent.OPEN, onOpenProject, false, 0, true);
			menu.addEventListener(MenuEvent.SAVE, onSaveProject, false, 0, true);
			menu.addEventListener(MenuEvent.EXPORT_TILED, onExportTileMap, false, 0, true);
			
			project = new Project();
			onNewProject(null);
			
			// Histogram Locations
			var histogramRect:Object = {
				x: PADDING,
				y: 456,
				width: stage.stageWidth - mapgen2.SIZE - PADDING * 2
			};
			
			// Create the controls place holder
			controls = new Sprite();
			addChild(controls);
			
			// Create the map generator (easier to merge if we don't hack it up)
			mapgen = new mapgen2(false, false);
			addChild(mapgen);
			mapgen.islandType = project.maps[mapIndex].mapType;
			mapgen.numPoints = project.maps[mapIndex].pointSize;
			mapgen.pointType = "Square";
			mapgen.mapMode = "biome"
			mapgen.renderHistograms = false;
			mapgen.commandCallback = function():void { mapgen.drawHistograms(histogramRect.x, histogramRect.y, histogramRect.width); }
			mapgen.islandSeedInput.text = project.maps[mapIndex].id;
			mapgen.go(mapgen.islandType, mapgen.pointType, mapgen.numPoints);
			
			// Main Panel
			Style.setStyle("dark");
			panel = new Panel(controls, mapgen2.SIZE, 0);
			panel.width = stage.stageWidth - mapgen2.SIZE;
			panel.height = stage.stageHeight;
			
			// Tileset Editor
			tilesetEditor = new TilesetEditor(this, mapgen2.SIZE, PADDING, project);
			
			// Project
			mapListLabel = new Label(panel.content, PADDING, PADDING, "Maps");
			mapList = new List(panel.content, PADDING, mapListLabel.y + PADDING, [project.maps[mapIndex].id]);
			mapList.addEventListener(Event.SELECT, onMapSelected, false, 0, true); 
			mapList.width = histogramRect.width;
			mapList.height = 20 * 4;
			mapList.selectedIndex = 0;
			mapListAddButton = new PushButton(panel.content, histogramRect.width - 18, mapList.y + mapList.height + 2, "+", function(e:MouseEvent):void {
				var map:Object = { id: newIslandSeed(), mapType: mapgen.islandType, pointSize: mapgen.numPoints, tileset: -1 };
				project.maps.push(map);
				mapList.addItem(map.id);
			});
			mapListAddButton.width = mapListAddButton.height;
			mapListRemoveButton = new PushButton(panel.content, histogramRect.width + 4, mapList.y + mapList.height + 2, "-", function(e:MouseEvent):void {
				if (mapList.items.length == 1) return;
				var index:int = mapList.selectedIndex;
				project.maps.splice(index, 1);
				mapList.removeItemAt(index);
				mapIndex = mapList.selectedIndex;
				onMapSelected(null);
			});
			mapListRemoveButton.width = mapListRemoveButton.height;
			
			// Tileset
			var tilesets:Array = project.tilesets;
			var tilesetLabels:Array = [];
			for each(var tileset:Object in tilesets) { tilesetLabels.push(tileset.id); }
			tilesetLabels.push("New Tileset");
			
			tilesetLabel = new Label(panel.content, PADDING, mapList.y + mapList.height + 18, "Tileset"); 
			tilesetComboBox = new ComboBox(panel.content, PADDING, tilesetLabel.y + PADDING, tilesetLabels[0], tilesetLabels);
			tilesetComboBox.width = 168;
			tilesetEditorButton = new PushButton(panel.content, tilesetComboBox.x + tilesetComboBox.width + 12, tilesetLabel.y + PADDING, "Edit Tileset", function(e:MouseEvent):void {
				tilesetEditor.addEventListener(EditorEvent.OPENED, onEditorOpened, false, 0, true);
				tilesetEditor.addEventListener(EditorEvent.CLOSING, onEditorClosing, false, 0, true);
				tilesetEditor.show(tilesetComboBox.selectedItem as String);
			});
			
			// Map Seed
			mapSeedLabel = new Label(panel.content, PADDING, tilesetEditorButton.y + PADDING, "Map Seed");
			mapSeedInput = new InputText(panel.content, PADDING, mapSeedLabel.y + PADDING, project.maps[mapIndex].id);
			mapSeedInput.width = 168;
			mapSeedInput.textField.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void {
				if (e.charCode == 13) {
					project.maps[mapIndex].id = mapSeedInput.text;
					mapList.items[mapIndex] = mapSeedInput.text;					
					mapList.draw();
					
					mapgen.islandSeedInput.text = mapSeedInput.text;
					mapgen.go(mapgen.islandType, mapgen.pointType, mapgen.numPoints);
				}
			});
			mapSeedRandomizeButton = new PushButton(panel.content, mapSeedInput.x + mapSeedInput.width + 12, mapSeedLabel.y + PADDING - 2, "Randomize", function(e:MouseEvent):void {
				project.maps[mapIndex].id = mapSeedInput.text = mapgen.islandSeedInput.text = newIslandSeed();
				mapList.items[mapIndex] = mapSeedInput.text;					
				mapList.draw();
				mapgen.go(mapgen.islandType, mapgen.pointType, mapgen.numPoints);
			});
			
			// Map Type
			var mapTypeColumnWidth:int = 72;
			mapTypeLabel = new Label(panel.content, PADDING, mapSeedRandomizeButton.y + 32, "Map Type");
			mapTypeRadioGroup[0] = new RadioButton(panel.content, PADDING + mapTypeColumnWidth * 0, mapTypeLabel.y + PADDING, "Radial", false, function(e:MouseEvent):void {
				project.maps[mapIndex].mapType = "Radial";
				mapgen.go("Radial", mapgen.pointType, mapgen.numPoints);
			}, "mapTypeGroup");
			mapTypeRadioGroup[1] = new RadioButton(panel.content, PADDING + mapTypeColumnWidth * 1, mapTypeLabel.y + PADDING, "Perlin", true, function(e:MouseEvent):void {
				project.maps[mapIndex].mapType = "Perlin";
				mapgen.go("Perlin", mapgen.pointType, mapgen.numPoints);
			}, "mapTypeGroup");
			mapTypeRadioGroup[2] = new RadioButton(panel.content, PADDING + mapTypeColumnWidth * 2, mapTypeLabel.y + PADDING, "Square", false, function(e:MouseEvent):void {
				project.maps[mapIndex].mapType = "Square";
				mapgen.go("Square", mapgen.pointType, mapgen.numPoints);
			}, "mapTypeGroup");
			mapTypeRadioGroup[3] = new RadioButton(panel.content, PADDING + mapTypeColumnWidth * 3, mapTypeLabel.y + PADDING, "Blob", false, function(e:MouseEvent):void {
				project.maps[mapIndex].mapType = "Blob";
				mapgen.go("Blob", mapgen.pointType, mapgen.numPoints);
			}, "mapTypeGroup");
			
			// Point Size
			var pointCountOffset:int = mapTypeRadioGroup[3].y + 32;
			var pointCountColumnWidth:int = 55;
			pointCountLabel = new Label(panel.content, PADDING, pointCountOffset, "Grid Size");
			pointCountRadioGroup[0] = new RadioButton(panel.content, PADDING + pointCountColumnWidth * 0, pointCountLabel.y + PADDING, "25X25", true, function(e:MouseEvent):void {
				project.maps[mapIndex].pointSize = 25*25;
				mapgen.go(mapgen.islandType, mapgen.pointType, project.maps[mapIndex].pointSize);
			}, "pointSizeGroup");
			pointCountRadioGroup[1] = new RadioButton(panel.content, PADDING + pointCountColumnWidth * 1, pointCountLabel.y + PADDING, "50X50", false, function(e:MouseEvent):void {
				project.maps[mapIndex].pointSize = 50*50;
				mapgen.go(mapgen.islandType, mapgen.pointType, project.maps[mapIndex].pointSize);
			}, "pointSizeGroup");
			pointCountRadioGroup[2] = new RadioButton(panel.content, PADDING + pointCountColumnWidth * 2, pointCountLabel.y + PADDING, "75X75", false, function(e:MouseEvent):void {
				project.maps[mapIndex].pointSize = 75*75;
				mapgen.go(mapgen.islandType, mapgen.pointType, project.maps[mapIndex].pointSize);
			}, "pointSizeGroup");
			pointCountRadioGroup[3] = new RadioButton(panel.content, PADDING + pointCountColumnWidth * 3, pointCountLabel.y + PADDING, "100X100", false, function(e:MouseEvent):void {
				project.maps[mapIndex].pointSize = 100*100;
				mapgen.go(mapgen.islandType, mapgen.pointType, project.maps[mapIndex].pointSize);
			}, "pointSizeGroup");
			pointCountRadioGroup[4] = new RadioButton(panel.content, PADDING + pointCountColumnWidth * 4, pointCountLabel.y + PADDING, "200X200", false, function(e:MouseEvent):void {
				project.maps[mapIndex].pointSize = 200*200;
				mapgen.go(mapgen.islandType, mapgen.pointType, project.maps[mapIndex].pointSize);
			}, "pointSizeGroup");
			
			// Render Mode
			var renderModeOffset:int = pointCountRadioGroup[4].y + 32;
			var renderModeColumnWidth:int = 72;
			renderModeLabel = new Label(panel.content, PADDING, renderModeOffset, "View");
			renderModeRadioGroup[0] = new RadioButton(panel.content, PADDING + renderModeColumnWidth * 0, renderModeLabel.y + PADDING, "Biome", true, function(e:MouseEvent):void {
				mapgen.drawMap(mapgen.mapMode = "biome");
				mapgen.drawHistograms(histogramRect.x, histogramRect.y, histogramRect.width);
			}, "viewModeGroup");
			renderModeRadioGroup[1] = new RadioButton(panel.content, PADDING + renderModeColumnWidth * 1, renderModeLabel.y + PADDING, "Smooth", false, function(e:MouseEvent):void {
				mapgen.drawMap(mapgen.mapMode = "smooth");
				mapgen.drawHistograms(histogramRect.x, histogramRect.y, histogramRect.width);
			}, "viewModeGroup");
			renderModeRadioGroup[2] = new RadioButton(panel.content, PADDING + renderModeColumnWidth * 2, renderModeLabel.y + PADDING, "Slopes", false, function(e:MouseEvent):void {
				mapgen.drawMap(mapgen.mapMode = "slopes");
				mapgen.drawHistograms(histogramRect.x, histogramRect.y, histogramRect.width);
			}, "viewModeGroup");
			renderModeRadioGroup[3] = new RadioButton(panel.content, PADDING + renderModeColumnWidth * 3, renderModeLabel.y + PADDING, "3D", false, function(e:MouseEvent):void {
				mapgen.drawMap(mapgen.mapMode = "3d");
				mapgen.drawHistograms(histogramRect.x, histogramRect.y, histogramRect.width);
			}, "viewModeGroup");
			renderModeRadioGroup[4] = new RadioButton(panel.content, PADDING + renderModeColumnWidth * 0, renderModeRadioGroup[0].y + PADDING, "Elevation", false, function(e:MouseEvent):void {
				mapgen.drawMap(mapgen.mapMode = "elevation");
				mapgen.drawHistograms(histogramRect.x, histogramRect.y, histogramRect.width);
			}, "viewModeGroup");
			renderModeRadioGroup[5] = new RadioButton(panel.content, PADDING + renderModeColumnWidth * 1, renderModeRadioGroup[0].y + PADDING, "Moisture", false, function(e:MouseEvent):void {
				mapgen.drawMap(mapgen.mapMode = "moisture");
				mapgen.drawHistograms(histogramRect.x, histogramRect.y, histogramRect.width);
			}, "viewModeGroup");
			renderModeRadioGroup[6] = new RadioButton(panel.content, PADDING + renderModeColumnWidth * 2, renderModeRadioGroup[0].y + PADDING, "Polygons", false, function(e:MouseEvent):void {
				mapgen.drawMap(mapgen.mapMode = "polygons");
				mapgen.drawHistograms(histogramRect.x, histogramRect.y, histogramRect.width);
			}, "viewModeGroup");
			renderModeRadioGroup[7] = new RadioButton(panel.content, PADDING + renderModeColumnWidth * 3, renderModeRadioGroup[0].y + PADDING, "Watersheds", false, function(e:MouseEvent):void {
				mapgen.drawMap(mapgen.mapMode = "watersheds");
				mapgen.drawHistograms(histogramRect.x, histogramRect.y, histogramRect.width);
			}, "viewModeGroup");
			
			// Histogram Label
			histogramLabel = new Label(panel.content, PADDING, histogramRect.y - PADDING, "Distribution");
		}
		
		private function onMapSelected(e:Event):void
		{
			var i:int;
			var index:int = e ? (e.target as List).selectedIndex : 0;
			if (e && mapIndex == index) return;
			mapIndex = index;
			
			var map:Object = project.maps[mapIndex];
			if (map.tileset >= 0) tilesetComboBox.selectedIndex = map.tileset;
			
			// Seed
			mapgen.islandSeedInput.text = mapSeedInput.text = map.id;
			
			// Type
			for (i = 0; i < mapTypeRadioGroup.length; ++i) {
				var mapTypeRadioButton:RadioButton = mapTypeRadioGroup[i] as RadioButton;
				if (mapTypeRadioButton.label == map.mapType) {
					mapTypeRadioButton.selected = true;
					break;
				}
			}
			
			// Size
			for (i = 0; i < pointCountRadioGroup.length; ++i) {
				var pointCountRadioButton:RadioButton = pointCountRadioGroup[i] as RadioButton;
				if (pointCountRadioButton.label == map.pointSize.toString()) {
					pointCountRadioButton.selected = true;
					break;
				}
			}
			
			// Regenerate
			mapgen.go(map.mapType, mapgen.pointType, map.pointSize);
		}
		
		private function onNewProject(e:MenuEvent):void
		{
			var map:Object = { id: newIslandSeed(), mapType: "Perlin", pointSize: 500, tileset: -1};
			project.maps.splice(0, project.maps.length);
			project.maps.push(map);
			mapIndex = 0;
			
			if (mapList) { mapList.items = []; mapList.addItem(map.id); onMapSelected(null); }
			if (mapgen) mapgen.go(map.mapType, mapgen.pointType, map.pointSize);
		}
		
		private function onOpenProject(e:MenuEvent):void
		{
			var file:File = File.documentsDirectory;
			file.browseForOpen("Open Project", [new FileFilter("Project Files", "*"+project.EXTENSION)]);
			file.addEventListener(Event.SELECT, function(e:Event):void {
				project.load(file);
				
				mapList.removeAll();
				for (var i:int = 0; i < project.maps.length; ++i) { mapList.addItem(project.maps[i].id); }
				
				tilesetComboBox.removeAll();
				for (var j:int = 0; j < project.tilesets.length; ++j) { tilesetComboBox.addItem(project.tilesets[j].id); }
				tilesetComboBox.addItem("New Tileset");
				
				onMapSelected(null);
			});
		}
		
		private function onSaveProject(e:MenuEvent):void
		{
			var file:File = File.documentsDirectory.resolvePath("project"+project.EXTENSION);
			file.browseForSave("Save Project");
			file.addEventListener(Event.SELECT, function(e:Event):void {
				project.save(file);
			});
		}
		
		private function onExportTileMap(e:MenuEvent):void
		{
			
		}
		
		private function onEditorOpened(e:EditorEvent):void
		{
			if (mapgen.mapMode == "3d") mapgen.render3dTimer.stop();
			mapgen.viewport.visible = false;
			
			tilesetEditor.removeEventListener(EditorEvent.OPENED, onEditorOpened);
		}
		
		private function onEditorClosing(e:EditorEvent):void
		{
			var tilesets:Array = project.tilesets;
			tilesetComboBox.removeAll();
			for each(var tileset:Object in tilesets) { tilesetComboBox.addItem(tileset.id); }
			tilesetComboBox.addItem("New Tileset");
			tilesetComboBox.selectedIndex = tilesetEditor.tileset;
			if (project.maps[mapIndex].tileset == -1) project.maps[mapIndex].tileset = tilesetComboBox.selectedIndex;
			
			mapgen.viewport.visible = true;
			if (mapgen.mapMode == "3d") mapgen.render3dTimer.start();
			
			tilesetEditor.removeEventListener(EditorEvent.CLOSING, onEditorClosing);
		}
	}
}