package SephiusEngine.assetManagers.loaders 
{
	import flash.display.Loader;
	
	/**
	 * Store some information on URLloader to be used after objetcts loads
	 * @author Fernando Rabello.
	 */
	public class PNGTextureLoader extends Loader {
		public var objectName:String;
		public var atlasName:String;
		public var url:String;
		public var textureLoadRequest:TextureLoadRequest;

		public function PNGTextureLoader() {
			super();
		}
	}
}