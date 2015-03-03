package
{
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import com.bit101.components.RadioButton;
	import com.bit101.components.Style;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	[SWF(width="924", height="600", frameRate=60)]
	public class MapGen2Tiled extends Sprite
	{
		private var mapgen:mapgen2;
		
		private var controls:Sprite;
		private var panel:Panel;
		private var histogramLabel:Label;
		private var mapSeedLabel:Label;
		private var mapSeedInput:InputText;
		private var mapSeedRandomizeButton:PushButton;
		private var pointCountLabel:Label;
		private var pointCountRadioGroup:Array = [];
		private var renderModeLabel:Label;
		private var renderModeRadioGroup:Array = [];
		private var PADDING:int = 24;
		
		public function MapGen2Tiled()
		{
			super();
			
			// Histogram Locations
			var histogramRect:Object = {
				x: PADDING,
				y: 456,
				width: stage.stageWidth - mapgen2.SIZE - PADDING * 2
			};
			
			// Island Seed
			var islandSeed:String = ((Math.random()*100000).toFixed(0) + "-" + (1 + Math.floor(9*Math.random())).toFixed(0));
			
			// Create the controls place holder
			controls = new Sprite();
			addChild(controls);
			
			// Create the map generator (easier to merge if we don't hack it up)
			mapgen = new mapgen2(false, false);
			addChild(mapgen);
			mapgen.pointType = "Square";
			mapgen.numPoints = 500;
			mapgen.mapMode = "biome"
			mapgen.renderHistograms = false;
			mapgen.commandCallback = function():void { mapgen.drawHistograms(histogramRect.x, histogramRect.y, histogramRect.width); }
			mapgen.islandSeedInput.text = islandSeed;
			mapgen.go(mapgen.islandType, mapgen.pointType, mapgen.numPoints);
			
			// Main Panel
			Style.setStyle("dark");
			panel = new Panel(controls, mapgen2.SIZE, 0);
			panel.width = stage.stageWidth - mapgen2.SIZE;
			panel.height = stage.stageHeight;
			
			// Map Seed
			mapSeedLabel = new Label(panel.content, PADDING, PADDING, "Map Seed");
			mapSeedInput = new InputText(panel.content, PADDING, mapSeedLabel.y + PADDING, islandSeed);
			mapSeedInput.width = 168;
			mapSeedInput.textField.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void {
				if (e.charCode == 13) {
					mapgen.islandSeedInput.text = mapSeedInput.text;
					mapgen.go(mapgen.islandType, mapgen.pointType, mapgen.numPoints);
				}
			});
			mapSeedRandomizeButton = new PushButton(panel.content, mapSeedInput.x + mapSeedInput.width + 12, mapSeedLabel.y + PADDING - 2, "Randomize", function(e:MouseEvent):void {
				mapSeedInput.text = mapgen.islandSeedInput.text = ((Math.random()*100000).toFixed(0) + "-" + (1 + Math.floor(9*Math.random())).toFixed(0));
				mapgen.go(mapgen.islandType, mapgen.pointType, mapgen.numPoints);
			});
						
			// Point Size
			var pointCountColumnWidth:int = 48;
			pointCountLabel = new Label(panel.content, PADDING, mapSeedRandomizeButton.y + 32, "Point Size");
			pointCountRadioGroup[0] = new RadioButton(panel.content, PADDING + pointCountColumnWidth * 0, pointCountLabel.y + PADDING, "500", true, function(e:MouseEvent):void {
				mapgen.go(mapgen.islandType, mapgen.pointType, 500);
			}, "pointSizeGroup");
			pointCountRadioGroup[1] = new RadioButton(panel.content, PADDING + pointCountColumnWidth * 1, pointCountLabel.y + PADDING, "1000", false, function(e:MouseEvent):void {
				mapgen.go(mapgen.islandType, mapgen.pointType, 1000);
			}, "pointSizeGroup");
			pointCountRadioGroup[2] = new RadioButton(panel.content, PADDING + pointCountColumnWidth * 2, pointCountLabel.y + PADDING, "2000", false, function(e:MouseEvent):void {
				mapgen.go(mapgen.islandType, mapgen.pointType, 2000);
			}, "pointSizeGroup");
			pointCountRadioGroup[3] = new RadioButton(panel.content, PADDING + pointCountColumnWidth * 3, pointCountLabel.y + PADDING, "4000", false, function(e:MouseEvent):void {
				mapgen.go(mapgen.islandType, mapgen.pointType, 4000);
			}, "pointSizeGroup");
			pointCountRadioGroup[4] = new RadioButton(panel.content, PADDING + pointCountColumnWidth * 4, pointCountLabel.y + PADDING, "8000", false, function(e:MouseEvent):void {
				mapgen.go(mapgen.islandType, mapgen.pointType, 8000);
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
	}
}