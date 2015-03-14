package data
{
	/* Example data format
	json = {
		version: Project.VERSION, 
		maps: [
			{ id: "84843-2", mapType: "Perlin", pointSize: 500, tileSet: 0 }
		],
		tilesets: [																			   
			{ id: "some name", src: "../relative/path/to/tiles.png", tilemap: { "ocean": [n, ne, e, se, s, sw, w, nw] } } 
		]
	};
	*/
	
	public class Project extends JSONData
	{
		override public function get VERSION():int { return 1; }
		override public function get EXTENSION():String { return ".mg2.json"; }
		
		public function get version():int { return json.version; }
		public function get maps():Array { return json.maps; }
		public function get tilesets():Array { return json.tilesets; }
		
		public function Project()
		{
			super();
			json.maps = [];
			json.tilesets = [];
		}
		
		override public function upgrade(version:int):void
		{
			
		}
	}
}