package components
{
	import com.bit101.components.Component;
	import com.bit101.components.Style;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class TileWell extends Component
	{
		protected static var SIZE:int = 48;
		protected var _groupName:String = "defaultTileWellGroup";
		public function get groupName():String { return _groupName; }
		
		private var _selected:Boolean;
		private var _well:Sprite;
		private var _tile:Bitmap;
		private var _background:Sprite;
		private var _wellBackgroundFill:BitmapData;
		private var _tileSource:BitmapData;
		private var _tileSourceRect:Rectangle;
		
		protected static var tileWells:Array;
		
		public function TileWell(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, selected:Boolean = false, defaultHandler:Function = null, groupName:String = "defaultTileWellGroup")
		{
			super(parent, xpos, ypos);
			_groupName = groupName;
			_selected = selected;
			if(defaultHandler != null) addEventListener(MouseEvent.CLICK, defaultHandler);
			
		}
		
		protected static function addTileWell(tileWell:TileWell):void
		{
			if (!tileWells) tileWells = [];
			tileWells.push(tileWell);
		}
		
		protected static function clear(activeWell:TileWell):void
		{
			for (var i:int = 0; i < tileWells.length; ++i) {
				var tileWell:TileWell = tileWells[i];
				if (activeWell != tileWell && tileWell.groupName == activeWell.groupName) {
					tileWell.selected = false;
				}
			}
		}
		
		override protected function init():void
		{
			super.init();
			
			buttonMode = true;
			useHandCursor = true;
			
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
			_wellBackgroundFill = new BitmapData(20, 20);
			_wellBackgroundFill.draw(viewportFill);
			
			_background = new Sprite();
			addChild(_background);
			
			_well = new Sprite();
			_well.filters = [getShadow(2, true)];
			_tile = new Bitmap();
			_well.addChild(_tile);
			addChild(_well);
			
			addTileWell(this);
			addEventListener(MouseEvent.CLICK, onClick, false, 1);
		}
				
		override public function draw():void
		{
			super.draw();
			
			_background.graphics.clear();
			_background.graphics.beginFill(Style.BACKGROUND);
			_background.graphics.drawRect(0, 0, SIZE+2, SIZE+2);
			_background.graphics.endFill();
			
			_well.graphics.clear();
			_well.graphics.beginBitmapFill(_wellBackgroundFill);
			_well.graphics.drawRect(1, 1, SIZE, SIZE);
			_well.graphics.endFill();
			
			if (_tileSource) {
				// Copy the data into the tile
				_tile.bitmapData = _tileSource;
				_tile.bitmapData = new BitmapData(_tileSourceRect.width, _tileSourceRect.height, true, 0);
				_tile.bitmapData.copyPixels(_tileSource, _tileSourceRect, new Point(0,0));
				
				// Scale and center the tile
				_tile.width = SIZE;
				_tile.scaleY = _tile.scaleX;
				if(_tile.height > SIZE) {
					_tile.height = SIZE;
					_tile.scaleX = _tile.scaleY;
				}
				_tile.x = (SIZE - _tile.width) / 2;
				_tile.y = (SIZE - _tile.height) / 2;
			}
			else {
				_tile.bitmapData = null;
			}
			
			// Update selection
			_well.filters = _selected ? [getSelection(), getShadow(2, true)] : [getShadow(2, true)];
		}
		
		public function get selected():Boolean
		{
			return _selected;
		}
		
		public function set selected(value:Boolean):void
		{
			_selected = value;
			if(_selected) TileWell.clear(this);
			invalidate();
		}
		
		public function setTileSource(bitmapData:BitmapData, x:int, y:int, width:int, height:int):void
		{
			_tileSource = bitmapData;
			_tileSourceRect = new Rectangle(x, y, width, height);
			invalidate();
		}
		
		protected function onClick(event:MouseEvent):void
		{
			selected = true;
		}
		
		protected function getSelection():GlowFilter
		{
			return new GlowFilter(0xcc3333, 0.8, 6, 6, 2, 2, true, false);
		}
	}
}