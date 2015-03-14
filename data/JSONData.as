package data
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class JSONData
	{
		public function get VERSION():int { throw new Error("Abstract method"); }
		public function get EXTENSION():String { throw new Error("Abstract method"); }
		protected var json:Object;
		
		public function JSONData()
		{
			json = { version: VERSION };
		}
		
		public function clone():Object
		{
			return JSON.parse(JSON.stringify(json));
		}
		
		public function load(input:File):Boolean
		{
			var result:Boolean = false;
			var fs:FileStream = new FileStream();
			
			try {
				fs.open(input, FileMode.READ);
				json = JSON.parse(fs.readUTFBytes(fs.bytesAvailable));
				result = true;
			}
			catch(e:Error) {
				trace(e.message);
			}
			finally {
				fs.close();
			}
			
			if (json.version < VERSION) upgrade(json.version);
			return result;
		}
		
		public function save(output:File):Boolean
		{
			var result:Boolean = false;
			var fs:FileStream = new FileStream();
			
			try {
				fs.open(output, FileMode.WRITE);
				fs.writeUTFBytes(JSON.stringify(json));
				result = true;
			}
			catch(e:Error) {
				trace(e.message);
			}
			finally {
				fs.close();
			}
			
			return result;
		}
		
		public function upgrade(version:int):void
		{
			throw new Error("Abstract method");
		}
	}
}
