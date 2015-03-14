package data
{
	import com.sociodox.utils.Base64;
	
	import flash.display.Bitmap;
	import flash.utils.ByteArray;

	/* Example data format
	json = {
		version: 1,
		height: 100,
		width: 100,
		tilewidth: 24,
		tileheight: 24,
		renderorder: "right-down",
		nextobjectid: 1,
		orientation: "orthogonal",
		properties: {},
		layers: [
			{ name: "Tile Layer 1", type:"tilelayer", x: 0, y: 0, width: 100, height: 100, visible: true, opacity: 1, data:[tile_idx, tile_idx] }
		],
		tilesets: [
			{ name: "OryxFantasy16World", firstgid: 1, tilewidth: 24, tileheight: 24, image: "OryxFantasy16World.png", imagewidth: 1024, imageheight: 2048, margin: 2, spacing: 2, properties: {} }
		]
	};
	*/
	
	public class Tiled extends JSONData
	{
		override public function get VERSION():int { return 1; }
		override public function get EXTENSION():String { return ".tiled.json"; }
		
		public function Tiled(width:int, height:int, tileWidth:int, tileHeight:int, properties:Object = null)
		{
			super();
			json.width = width;
			json.height = height;
			json.tilewidth = tileWidth;
			json.tileheight = tileHeight;
			
			json.renderorder = "right-down";
			json.nextobjectid = 1;
			json.orientation = "orthoganol";
			json.properties = properties ? properties : {};
			json.layers = [];
			json.tilesets = [];
		}
		
		override public function upgrade(version:int):void
		{
			
		}
		
		public function addLayer(name:String, width:int, height:int, data:Array):void
		{
			json.layers.push({ name: name, type: "tilelayer", x: 0, y: 0, width: width, height: height, visible: true, opacity: 1, data: data });
		}
		
		public function addTileset(name:String, image:Bitmap, margin:int, spacing:int, properties:Object = null):void
		{
			properties = properties ? properties : {};
			//properties.imagesrc = Base64.encode(image.bitmapData.getPixels(image.bitmapData.rect));
			json.tilesets.push({ name: name, firstgid: 1, tilewidth: json.tilewidth, tileheight: json.tileheight, image: image.name, imagewidth: image.width, imageheight: image.height, margin: margin, spacing: spacing, properties: properties});
		}
	}
}