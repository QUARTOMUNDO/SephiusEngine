package SephiusEngine.assetManagers.loaders 
{
	import flash.filesystem.FileStream;
	
	/**
	 * Store some information on URLloader to be used after objetcts loads
	 * @author Fernando Rabello.
	 */
	public class TextureLoadRequest {
		public var objectName:String;
		public var atlasName:String;
		public var url:String;
		public var extention:String;
		public var fileStream:FileStream;

		public function TextureLoadRequest(objectName:String, atlasName:String, url:String, extention:String, fileStream:FileStream) {
			this.objectName = objectName;
			this.atlasName = atlasName;
			this.url = url;
			this.extention = extention;

			this.fileStream = fileStream;
		}
	}
}