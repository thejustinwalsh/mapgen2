package
{
	import com.bit101.components.ComboBox;
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.NumericStepper;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.net.FileFilter;
	import flash.net.URLRequest;
	import flash.system.ImageDecodingPolicy;
	import flash.system.LoaderContext;
	
	import aze.motion.eaze;
	import aze.motion.easing.Cubic;
	
	import components.TileWell;
	
	import data.Project;
	
	import events.EditorEvent;
	
	
	public class TilesetEditor extends Sprite
	{
		private var project:Project;
		private var tilesetIndex:int;
		private var tilesetSource:String;
		private var tilesetBitmap:Bitmap;
		
		private var SIZE:int;
		private var PADDING:int;
		
		private var tileMargin:int;
		private var tilePadding:int;
		private var tileSize:int;
		private var tileImageSize:Point;
		
		private var gridScale:int;
		private var gridOffset:Point;
		private var mouseDownPos:Point;
		private var mouseDelta:Point;
		private var isPanning:Boolean;
		
		private var parent:DisplayObjectContainer;
		private var viewport:Sprite;
		private var spriteSheet:Sprite;
		private var grid:Sprite;
		private var gridBitmap:Bitmap;
		private var panel:Panel;
		private var closeButton:PushButton;
		private var tilesetLabel:Label;
		private var tilesetInput:InputText;
		private var tilesetBrowseButton:PushButton;
		private var tilesetMarginLabel:Label;
		private var tilesetMarginStepper:NumericStepper;
		private var tilesetPaddingLabel:Label;
		private var tilesetPaddingStepper:NumericStepper;
		private var tilesetSizeLabel:Label;
		private var tilesetSizeStepper:NumericStepper;
		private var biomeLabel:Label;
		private var biomeComboBox:ComboBox;
		private var biomeTileLabel:Label;
		private var biomeTileNO:TileWell;
		private var biomeTileNE:TileWell;
		private var biomeTileN:TileWell;
		private var biomeTileNW:TileWell;
		private var biomeTileEO:TileWell;
		private var biomeTileE:TileWell;
		private var biomeTileC:TileWell;
		private var biomeTileW:TileWell;
		private var biomeTileWO:TileWell;
		private var biomeTileSE:TileWell;
		private var biomeTileS:TileWell;
		private var biomeTileSW:TileWell;
		private var biomeTileSO:TileWell;
		
		public function get tileset():int { return tilesetIndex; }
		
		public function TilesetEditor(parent:DisplayObjectContainer, viewportSize:int, padding:int, project:Project)
		{
			super();
			this.parent = parent;
			this.project = project;
			tilesetSource = "[empty]";
			
			SIZE = viewportSize;
			PADDING = padding;
			
			tileMargin = 2;
			tilePadding = 2;
			tileSize = 24;
			tileImageSize = new Point(1024, 1024);
			
			gridScale = 1;
			gridOffset = new Point(0, 0);
			mouseDelta = new Point(0, 0);
			isPanning = false;
			
			var viewportFill:Sprite = new Sprite();
			viewportFill.graphics.clear();
			viewportFill.graphics.beginFill(0xE8E8E8);
			viewportFill.graphics.drawRect(0, 0, 20, 20);
			viewportFill.graphics.endFill();
			viewportFill.graphics.beginFill(0xC8C8C8);
			viewportFill.graphics.drawRect(0, 0, 10, 10);
			viewportFill.graphics.endFill();
			viewportFill.graphics.beginFill(0xC8C8C8);
			viewportFill.graphics.drawRect(10, 10, 20, 20);
			viewportFill.graphics.endFill();
			var bitmapData:BitmapData = new BitmapData(20, 20);
			bitmapData.draw(viewportFill);
			
			viewport = new Sprite();
			viewport.graphics.clear();
			viewport.graphics.beginBitmapFill(bitmapData);
			viewport.graphics.drawRect(0, 0, SIZE, SIZE);
			viewport.graphics.endFill();
			viewport.alpha = 0.0;
			
			var mask:Shape = new Shape();
			mask.graphics.beginFill(0xFF00FF);
			mask.graphics.drawRect(0, 0, SIZE, SIZE);
			mask.graphics.endFill();
			viewport.mask = mask;
			
			spriteSheet = new Sprite();
			viewport.addChild(spriteSheet);
			grid = new Sprite();
			viewport.addChild(grid);
			addChild(viewport);
			
			panel = new Panel(this, parent.stage.stageWidth, 0);
			panel.width = parent.stage.stageWidth - SIZE;
			panel.height = parent.stage.stageHeight;
			
			tilesetLabel = new Label(panel.content, PADDING, PADDING, "Tileset Image");
			tilesetInput = new InputText(panel.content, PADDING, tilesetLabel.y + PADDING, "");
			tilesetInput.width = 168;
			tilesetBrowseButton = new PushButton(panel.content, tilesetInput.x + tilesetInput.width + 12, tilesetLabel.y + PADDING - 2, "Load", function(e:MouseEvent):void {
				var file:File = File.documentsDirectory;
				file.browseForOpen("Open Tileset Image", [new FileFilter("PNG", "*.png")]);
				file.addEventListener(Event.SELECT, function(e:Event):void {
					project.tilesets[tilesetIndex].src = file.url;
					project.tilesets[tilesetIndex].id = file.name.substring(0, file.name.indexOf(file.extension) - 1);
					tilesetInput.text = project.tilesets[tilesetIndex].id;
					loadTileset();
				});
			});
			
			var tilesetColumn:int = 100;
			tilesetMarginLabel = new Label(panel.content, tilesetColumn * 0 + PADDING, tilesetInput.y + PADDING, "Margin");
			tilesetMarginStepper = new NumericStepper(panel.content, tilesetColumn * 0 + PADDING, tilesetMarginLabel.y + PADDING, function(e:Event):void {
				tileMargin = project.tilesets[tilesetIndex].margin = tilesetMarginStepper.value;
				updateViewport();
			});
			tilesetMarginStepper.minimum = 0; tilesetMarginStepper.value = tileMargin;
			
			tilesetPaddingLabel = new Label(panel.content, tilesetColumn * 1 + PADDING, tilesetInput.y + PADDING, "Padding");
			tilesetPaddingStepper = new NumericStepper(panel.content, tilesetColumn * 1 + PADDING, tilesetMarginLabel.y + PADDING, function(e:Event):void {
				tilePadding = project.tilesets[tilesetIndex].padding = tilesetPaddingStepper.value;
				updateViewport();
			});
			tilesetPaddingStepper.minimum = 0; tilesetPaddingStepper.value = tilePadding;
			
			tilesetSizeLabel = new Label(panel.content, tilesetColumn * 2 + PADDING, tilesetInput.y + PADDING, "Tile Size");
			tilesetSizeStepper = new NumericStepper(panel.content, tilesetColumn * 2 + PADDING, tilesetMarginLabel.y + PADDING, function(e:Event):void {
				tileSize = project.tilesets[tilesetIndex].size = tilesetSizeStepper.value;
				updateViewport();
			});
			tilesetSizeStepper.minimum = 0; tilesetSizeStepper.value = tileSize;
			
			biomeLabel = new Label(panel.content, PADDING, tilesetMarginStepper.y + PADDING, "Biomes");
			biomeComboBox = new ComboBox(panel.content, PADDING, biomeLabel.y + PADDING, "OCEAN", [
				'OCEAN', 'MARSH', 'ICE', 'LAKE', 'BEACH', 'SNOW', 'TUNDRA', 'BARE', 'SCORCHED', 'TAIGA', 'SHRUBLAND', 
				'TEMPERATE_DESERT', 'TEMPERATE_RAIN_FOREST', 'TEMPERATE_DECIDUOUS_FOREST', 'GRASSLAND', 'TEMPERATE_DESERT', 
				'TROPICAL_RAIN_FOREST', 'TROPICAL_SEASONAL_FOREST', 'GRASSLAND', 'SUBTROPICAL_DESERT'
			]);
			biomeComboBox.width = panel.width - PADDING*2 + 4;
			
			biomeTileLabel = new Label(panel.content, PADDING, biomeComboBox.y + biomeComboBox.height + PADDING, "Biome Tiles");
			
			var wellPadding:int = 57;
			var wellOffsetY:int = biomeTileLabel.y + PADDING;
			biomeTileNO = new TileWell(panel.content, PADDING + wellPadding * 2, wellOffsetY + wellPadding * 0, false);
			biomeTileNE = new TileWell(panel.content, PADDING + wellPadding * 1, wellOffsetY + wellPadding * 1, false);
			biomeTileN  = new TileWell(panel.content, PADDING + wellPadding * 2, wellOffsetY + wellPadding * 1, false);
			biomeTileNW = new TileWell(panel.content, PADDING + wellPadding * 3, wellOffsetY + wellPadding * 1, false);
			biomeTileEO = new TileWell(panel.content, PADDING + wellPadding * 0, wellOffsetY + wellPadding * 2, false);
			biomeTileE  = new TileWell(panel.content, PADDING + wellPadding * 1, wellOffsetY + wellPadding * 2, false);
			biomeTileC  = new TileWell(panel.content, PADDING + wellPadding * 2, wellOffsetY + wellPadding * 2, true);
			biomeTileW  = new TileWell(panel.content, PADDING + wellPadding * 3, wellOffsetY + wellPadding * 2, false);
			biomeTileWO = new TileWell(panel.content, PADDING + wellPadding * 4, wellOffsetY + wellPadding * 2, false);
			biomeTileSE = new TileWell(panel.content, PADDING + wellPadding * 1, wellOffsetY + wellPadding * 3, false);
			biomeTileS  = new TileWell(panel.content, PADDING + wellPadding * 2, wellOffsetY + wellPadding * 3, false);
			biomeTileSW = new TileWell(panel.content, PADDING + wellPadding * 3, wellOffsetY + wellPadding * 3, false);
			biomeTileSO = new TileWell(panel.content, PADDING + wellPadding * 2, wellOffsetY + wellPadding * 4, false);
			
			
			closeButton = new PushButton(panel.content, panel.width - 100 - PADDING, panel.height - 20 - PADDING, "Close", function(e:MouseEvent):void {
				hide();
			});
		}
		
		public function show(tilesetId:String):void
		{
			// Find the tile set...
			var tilesets:Array = project.tilesets;
			tilesetIndex = -1;
			for (var i:int = 0; i < tilesets.length; ++i) {
				if (tilesets[i].id == tilesetId) {
					tilesetIndex = i;
					break;
				}
			}
			
			// Create a new tileset
			if (tilesetIndex == -1) {
				tilesetIndex = project.tilesets.push({ id: tilesetId, src: "", margin: 0, padding: 0, size: 24, tilemap: {} }) - 1;
			}
			
			// Populate our menu items
			tilesetInput.text = project.tilesets[tilesetIndex].id;
			tileMargin = tilesetMarginStepper.value = project.tilesets[tilesetIndex].margin;
			tilePadding = tilesetPaddingStepper.value = project.tilesets[tilesetIndex].padding;
			tileSize = tilesetSizeStepper.value = project.tilesets[tilesetIndex].size;
			
			// Hide the old tileset if it is no longer valid
			if (project.tilesets[tilesetIndex].src == "" || project.tilesets[tilesetIndex].src != tilesetSource) spriteSheet.removeChildren();
			
			// Animate the view
			var easeComplete:Function = function(t:DisplayObject):void {
				dispatchEvent(new EditorEvent(EditorEvent.OPENED));
				loadTileset();
				updateViewport();
			};
			
			parent.addChild(this);
			eaze(panel).to(0.6, { x: SIZE }).easing(Cubic.easeOut);
			eaze(viewport).to(0.6, { alpha: 1.0 }).easing(Cubic.easeOut).onComplete(easeComplete, this);
			dispatchEvent(new EditorEvent(EditorEvent.OPENING));
			
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onRightMouseUp, false, 0, true);
			viewport.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown, false, 0, true);
		}
		
		public function hide():void
		{
			var easeComplete:Function = function(t:DisplayObject):void {
				parent.removeChild(t);
				dispatchEvent(new EditorEvent(EditorEvent.CLOSED));
			};
			
			eaze(panel).to(0.6, { x: parent.stage.stageWidth }).easing(Cubic.easeIn);
			eaze(viewport).to(0.6, { alpha: 0.0 }).easing(Cubic.easeIn).onComplete(easeComplete, this);
			dispatchEvent(new EditorEvent(EditorEvent.CLOSING));
			
			stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, onRightMouseUp);
			viewport.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown);
		}

		public function updateViewport():void
		{
			// Clamp Offset
			gridOffset = gridOffset.add(mouseDelta);
			gridOffset.x = Math.floor(Math.min(gridOffset.x, SIZE/2));
			gridOffset.x = Math.floor(Math.max(gridOffset.x, -((gridScale * tileImageSize.x) - SIZE/2)));
			gridOffset.y = Math.floor(Math.min(gridOffset.y, SIZE/2));
			gridOffset.y = Math.floor(Math.max(gridOffset.y, -((gridScale * tileImageSize.y) - SIZE/2)));
			
			// Update spritesheet
			spriteSheet.x = gridOffset.x;
			spriteSheet.y = gridOffset.y;
			spriteSheet.scaleX = spriteSheet.scaleY = gridScale;
			
			// Update grid
			var scale:int = gridScale, margin:int = tileMargin, padding:int = tilePadding, tileSize:int = this.tileSize;
			var xmin:int = 0, ymin:int = 0, xmax:int = SIZE, ymax:int = SIZE; 
			var g:Graphics = grid.graphics;
			g.clear();
			g.lineStyle(1, 0x3c3c3c, 1.0, true);
			for (var y:int = 0; y < Math.floor(tileImageSize.y/(tileSize+padding)); ++y) {
				// Desired Line
				var x0:int = 0;
				var x1:int = tileImageSize.x * scale;
				var yA:int = ((margin * scale) + (y * tileSize * scale) + (y * padding * scale));
				var yB:int = yA + (tileSize * scale);
				
				// Translate Line
				x0 += gridOffset.x; x1 += gridOffset.x;
				yA += gridOffset.y; yB += gridOffset.y;
				
				// Clamp X
				x0 = Math.max(0, Math.min(xmax, x0));
				x1 = Math.max(0, Math.min(xmax, x1));
				
				// Draw yA if within view
				if (yA > 0 && yA < ymax) {
					// Draw Line
					yA = Math.max(0, Math.min(ymax, yA));
					g.moveTo(x0, yA); g.lineTo(x1, yA);
				}
				
				// Draw yB if within view
				if (yB > 0 && yB < ymax) {
					// Draw Line
					yB = Math.max(0, Math.min(ymax, yB));
					g.moveTo(x0, yB); g.lineTo(x1, yB);
				}
				
				for (var x:int = 0; x < Math.floor(tileImageSize.x/(tileSize+padding)); ++x) {
					// Desired Line
					var y0:int = 0;
					var y1:int = tileImageSize.y * scale;
					var xA:int = ((margin * scale) + (x * tileSize * scale) + (x * padding * scale));
					var xB:int = xA + (tileSize * scale);
					
					// Translate Line
					y0 += gridOffset.y; y1 += gridOffset.y;
					xA += gridOffset.x; xB += gridOffset.x;
					
					// Clamp Y
					y0 = Math.max(0, Math.min(ymax, y0));
					y1 = Math.max(0, Math.min(ymax, y1));
					
					// Draw xA if within view
					if (xA > 0 && xA < xmax) {
						// Draw Line
						xA = Math.max(0, Math.min(xmax, xA));
						g.moveTo(xA, y0); g.lineTo(xA, y1);
					}
					
					// Draw yB if within view
					if (xB > 0 && xB < xmax) {
						// Draw Line
						xB = Math.max(0, Math.min(xmax, xB));
						g.moveTo(xB, y0); g.lineTo(xB, y1);
					}
				}
			}
		}
		
		public function updateBiomeTiles():void
		{
			if (!tilesetBitmap) return;
			
			// TEST
			//biomeTileC.setTileSource(tilesetBitmap.bitmapData, 2, 2, 24, 24);
		}
		
		private function loadTileset():void
		{
			if (project.tilesets[tilesetIndex].src != "" && (spriteSheet.numChildren == 0 || project.tilesets[tilesetIndex].src != tilesetSource)) {
				var file:File = new File(project.tilesets[tilesetIndex].src);
				if (file.exists) {
					tilesetSource = project.tilesets[tilesetIndex].src;
					
					var loaderContext:LoaderContext = new LoaderContext(); 
					loaderContext.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
					var loader:Loader = new Loader();
					loader.contentLoaderInfo.addEventListener(Event.INIT, function(e:Event):void {
						tilesetBitmap = e.target.content as Bitmap;
						tileImageSize.x = tilesetBitmap.width;
						tileImageSize.y = tilesetBitmap.height;
						updateViewport();
						updateBiomeTiles();
					});
					
					loader.load( new URLRequest(file.url), loaderContext);
					spriteSheet.removeChildren();
					spriteSheet.addChild(loader);
				}
			}
		}
		
		private function onMouseWheel(e:MouseEvent):void
		{
			if (!viewport.hitTestPoint(stage.mouseX, stage.mouseY)) return;
			gridScale += Math.floor(e.delta >= 0 ? 1 : -1);
			gridScale = Math.max(1, gridScale);
			gridScale = Math.min(4, gridScale);
			updateViewport();
		}
		
		private function onMouseMove(e:MouseEvent):void
		{
			if (!isPanning) return;
			var mousePos:Point = new Point(stage.mouseX, stage.mouseY);
			mouseDelta = mouseDownPos.subtract(mousePos);
			updateViewport();
		}
		
		private function onRightMouseDown(e:MouseEvent):void
		{
			isPanning = true;
			mouseDownPos = new Point(stage.mouseX, stage.mouseY);
		}
		
		private function onRightMouseUp(e:MouseEvent):void
		{
			isPanning = false;
			var mousePos:Point = new Point(this.mouseX, this.mouseY);
			mouseDelta = mouseDownPos.subtract(mousePos);
			updateViewport();
		}
	}
}