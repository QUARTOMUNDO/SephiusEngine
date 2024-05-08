package SephiusEngine.displayObjects.textures 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.TextureBase;
	import flash.utils.ByteArray;
	import starling.core.Starling;
	import starling.errors.MissingContextError;
	import starling.textures.AtfData;
	import starling.textures.ConcreteTexture;
	import starling.textures.Texture;
	/**
	 * Alow change some properties after creation
	 * @author Fernando Rabello
	 */
	public class ExtendedConcreteTexture extends ConcreteTexture {
		public var loaded:Boolean = false;
		
		public function ExtendedConcreteTexture(base:TextureBase, format:String, width:int, height:int, mipMapping:Boolean, premultipliedAlpha:Boolean, optimizedForRenderTexture:Boolean=false, scale:Number=1, repeat:Boolean=false) {
			super(base, format, width, height, mipMapping, premultipliedAlpha, optimizedForRenderTexture, scale, repeat);
		}
		
		public function set width(value:Number):void { mWidth = value; }
		public function set height(value:Number):void { mHeight = value; }
		public function set format(value:String):void { mFormat = value; }
		public function set mipMapping(value:Boolean):void { mMipMapping = value; }
		public function set base(value:TextureBase):void { mBase = value; }
		
        public static function proxyTexture(width:Number = 1, height:Number = 1, format:String = Context3DTextureFormat.BGRA, scale:Number=1, useMipMaps:Boolean=false, repeat:Boolean=false):Texture{
            var context:Context3D = Starling.context;
            if (context == null) throw new MissingContextError();
            
            //var nativeTexture:flash.display3D.textures.Texture = context.createTexture(width, height, format, false);
            var concreteTexture:ExtendedConcreteTexture = new ExtendedConcreteTexture(null, Context3DTextureFormat.BGRA, width, height, useMipMaps, false, false, scale, repeat);
            
            return concreteTexture;
        }
		
        public function uploadData(data:ByteArray, async:Function = null):void {
            var context:Context3D = Starling.context;
            if (context == null) throw new MissingContextError();
            var atfData:AtfData = new AtfData(data);
			
			format = atfData.format;
			width = atfData.width;
			height = atfData.height;
			mipMapping = mMipMapping && atfData.numTextures > 1;
			
			base = context.createTexture(width, height, format, false);
			
            uploadAtfData(data, 0, async);
            onRestore = function():void
            {
                uploadAtfData(data, 0);
            };
		}
		
		public function clearData():void {
			dispose();
		}
	}
}