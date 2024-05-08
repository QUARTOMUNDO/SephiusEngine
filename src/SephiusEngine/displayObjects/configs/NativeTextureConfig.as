package SephiusEngine.displayObjects.configs 
{
	import starling.textures.Texture;
	/**
	 * Store information about a texture
	 * @author Fernando Rabello
	 */
	public class NativeTextureConfig {
		/** Store hald width of the sub texture. Usefull for some calculations  */
		public var halfWidth:Number = 1.0;
		/** Store half height of the sub texture. Usefull for some calculations */
		public var halfHeight:Number = 1.0;
		/** The name of the texture config can be used to identify form what texture this config is related */
		public var name:String;
		/** The width of the texture in pixels */
        public var width:int;
		/** The height of the texture in pixels */
        public var height:int;
		/** If this texture has colors premultiplied alpha*/
        public var premultipliedAlpha:Boolean;
		/** The scale of the texture this chage de overal size of the texture and subtextures related */
        public var scale:Number;
		/** If this texture repeats itself */
        public var repeat:Boolean;
		/** A function to be called if Starling loss and restrores context*/
        public var mOnRestore:Function;
		
		// This vars we can´t know before load the actual texture
        public var mipMapping:Boolean;
		/** Format of the texture, compressed, rgba etc. */
        public var format:String;
		/** If the data from the real texture was loaded */
        public var dataUploaded:Boolean;
		/** The texture related with this config */
		public var texture:Texture;
		
		public function NativeTextureConfig(name:String, width:int, height:int, premultipliedAlpha:Boolean, mipMapping:Boolean, scale:Number, repeat:Boolean) {
			this.name = name;
			this.width = width;
			this.height = height;
			this.halfWidth = width * .5;
			this.halfHeight = height * .5;
			this.premultipliedAlpha = premultipliedAlpha;
			this.scale = scale;
			this.repeat = repeat;
			this.mOnRestore = mOnRestore;
			this.mipMapping = mipMapping;
			
			texture = Texture.fromConfig(this);
			texture.name = name;
		}
	}
}