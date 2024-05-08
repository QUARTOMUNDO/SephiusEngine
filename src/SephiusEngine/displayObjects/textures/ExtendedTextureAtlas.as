package SephiusEngine.displayObjects.textures {
	import SephiusEngine.utils.pools.RectanglePool;

	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.utils.cleanMasterString;
	/**
	 * Texture Atlas optimized for faster creation
	 * @author Fernando Rabello
	 */
	public class ExtendedTextureAtlas extends TextureAtlas {
		public var name:String;
		public var textureNames:Vector.<String> = new <String>[];
		public var animations:Dictionary = new Dictionary();
		
		private static var sSplited:Array = new Array();
		
		public function ExtendedTextureAtlas(name:String, texture:Texture, atlasXml:XML = null) {
			this.name = name;
			super(texture, atlasXml);
		}
		
        override protected function parseAtlasXml(atlasXml:XML):void  {
            var scale:Number = mAtlasTexture.scale;
			var name:String;
			
			var region:Rectangle;
			var frame:Rectangle;
			var rotated:Boolean;

			var frameX:Number;
			var frameY:Number;
			var frameWidth:Number;
			var frameHeight:Number;

            for each (var subTexture:XML in atlasXml.SubTexture) {
				name = cleanMasterString(subTexture.@name);
			   
				//Store texture name in a vector with other texture names
				textureNames.push(name);
			   
				region = RectanglePool.getRectangle();
			   
				region.x 		= parseFloat(subTexture.@x) / scale;
				region.y		= parseFloat(subTexture.@y) / scale
				region.width 	= parseFloat(subTexture.@width) / scale;
				region.height 	= parseFloat(subTexture.@height) / scale;

				rotated    		= parseBool( subTexture.@rotated);

                frameX      	= parseFloat(subTexture.@frameX) / scale;
                frameY      	= parseFloat(subTexture.@frameY) / scale;
                frameWidth  	= parseFloat(subTexture.@frameWidth)  / scale;
                frameHeight 	= parseFloat(subTexture.@frameHeight) / scale;

                if (frameWidth > 0 && frameHeight > 0){
					frame = RectanglePool.getRectangle();
				   
					frame.x = frameX;
					frame.y = frameY;
					frame.width = frameWidth;
					frame.height = frameHeight;
			   }
			   else{
					trace("Texture has no frame");
					frame = null;
				}
			   
                addRegion(name, region, frame, parseBool(subTexture.@rotated));
            }
		}
        /** Adds a named region for a subtexture (described by rectangle with coordinates in 
         *  pixels) with an optional frame. */
        override public function addRegion(name:String, region:Rectangle, frame:Rectangle = null, rotated:Boolean = false):void {
			super.addRegion(name, region, frame, rotated);
			
			sSplited = name.split("_");
			
			if (sSplited.length > 1) {
				if (!animations[sSplited.length - 1])
					animations[sSplited.length - 1] = new Vector.<Texture>
				animations[sSplited.length - 1].push(getTexture(name));
			}
			
			sSplited = null;
        }
		
        /** Returns all textures that start with a certain string, sorted alphabetically
         *  (especially useful for "MovieClip"). */
        public function getTexturesE(prefix:String="", result:Vector.<Texture>=null, sorted:Boolean=true):Vector.<Texture>{
            if (result == null) result = new <Texture>[];
            
            for each (var name:String in getNamesE(prefix, sNames, sorted)) 
                result.push(getTexture(name)); 
			
            sNames.length = 0;
            return result;
        }
		
        /** Returns all texture names that start with a certain string, sorted alphabetically. */
		public function getNamesE(prefix:String = "", result:Vector.<String> = null, sorted:Boolean = true):Vector.<String> {
			var name:String;
            if (result == null) result = new <String>[];
			
            if (sorted && mSubTextureNames == null)
            {
                // optimization: store sorted list of texture names
                mSubTextureNames = new <String>[];
                for (name in mSubTextures) mSubTextureNames[mSubTextureNames.length] = name;
                mSubTextureNames.sort(Array.CASEINSENSITIVE);
            }
			
            for each (name in mSubTextureNames)
                if (name.indexOf(prefix) == 0)
                    result[result.length] = name;
            
            return result;
        }
		
		/** If Atlas is uses for a animation, this methcod is lighter to get only the animation names inside the Atlas. This also come sorted alrady */
		public function getAnimationNames(animationName:String = "", result:Vector.<String> = null):Vector.<String> {
			if (result == null) result = new <String>[];
			
			for (var name:String in animations)
				result.push(name);
			return result;
		}
		
		/** If Atlas is uses for a animation, this methcod is lighter to get animation frames inside the Atlas. This also come sorted alrady */
		public function getAnimationTextures(animationName:String = ""):Vector.<Texture> {
			return animations[animationName];
		}
		
        // utility methods
        
        private static function parseBool(value:String):Boolean
        {
            return value.toLowerCase() == "true";
        }
	}
}