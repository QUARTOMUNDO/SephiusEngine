package SephiusEngine.displayObjects.textures {
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.utils.ByteArray;
	import starling.errors.MissingContextError;
	import starling.textures.AtfData;
	import starling.textures.ConcreteTexture;
	import starling.textures.Texture;
	
	/**
	 * Alow pre-creation of a texture and option do upload data after.
	 * @author Fernando Rabello
	 */
	public class ExtendedTexture extends Texture {
		
		public var loaded:Boolean = false;
		
		public function ExtendedTexture() {
			super();
		}
		
        public static function proxyTexture(width:Number = 1, height:Number = 1, format:String = Context3DTextureFormat.BGRA, scale:Number=1, useMipMaps:Boolean=false, repeat:Boolean=false):Texture{
            var context:Context3D = Starling.context;
            if (context == null) throw new MissingContextError();
            
            var nativeTexture:flash.display3D.textures.Texture = context.createTexture(width, height, format, false);
            var concreteTexture:ExtendedConcreteTexture = new ExtendedConcreteTexture(nativeTexture, Context3DTextureFormat.BGRA, width, height, useMipMaps, false, false, scale, repeat);
            
            return concreteTexture;
        }
		
        public static function uploadData(texture:ExtendedConcreteTexture, data:ByteArray, async:Function = null):void {
            var context:Context3D = Starling.context;
            if (context == null) throw new MissingContextError();
            var atfData:AtfData = new AtfData(data);
			
			texture.format = atfData.format;
			texture.width = atfData.width;
			texture.height = atfData.height;
			texture.mipMapping = texture.useMipMaps && atfData.numTextures > 1;
			
			texture.base = context.createTexture(texture.width, texture.height, texture.format, false);
			
            texture.uploadAtfData(data, 0, async);
            texture.onRestore = function():void
            {
                texture.uploadAtfData(data, 0);
            };
		}
		
		public static function clearData(texture:ConcreteTexture):void {
			texture.dispose();
		}
	}
}