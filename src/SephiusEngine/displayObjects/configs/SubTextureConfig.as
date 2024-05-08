package SephiusEngine.displayObjects.configs 
{
	import SephiusEngine.displayObjects.configs.NativeTextureConfig;
	import flash.geom.Rectangle;
	import starling.textures.SubTexture;
	/**
	 * Information about a particular frame inside a sprite sheet/texture atlas
	 * @author Fernando Rabello
	 */
	public class SubTextureConfig {
		/** Store hald width of the sub texture. Usefull for some calculations  */
		public var halfWidth:Number = 1.0;
		/** Store half height of the sub texture. Usefull for some calculations */
		public var halfHeight:Number = 1.0;
		
		/** Store que coordinate left position of the texture on its parent texture from 0 to 1 */
		public var mappingLeft:Number = 0.0;
		/** Store que coordinate top position of the texture on its parent texture from 0 to 1 */
		public var mappingTop:Number = 0.0;
		/** Store que coordinate right position of the texture on its parent texture from 0 to 1 */
		public var mappingRight:Number = 1.0;
		/** Store que coordinate buttom position of the texture on its parent texture from 0 to 1 */
		public var mappingBottom:Number = 1.0;
		
		/** If texture is trimmed this store the right position of the trimmed rectangle */ 
		public var frameRight:Number = 0.0;
		/** If texture is trimmed this store the bottom position of the trimmed rectangle */ 
		public var frameBottom:Number = 0.0;
		/** If texture is trimmed this store the left position of the trimmed rectangle */ 
		public var frameLeft:Number = 0.0;
		/** If texture is trimmed this store the top position of the trimmed rectangle */ 
		public var frameTop:Number = 0.0;
		
		/** Its true if this subtexture uses a frame (is trimmed) */ 
		public var useFrame:Boolean = false;
		
		/** Store the texture dimensions information in a rectangle object. In pixels. */
		//public var region:Rectangle = new Rectangle();
		/** Store the frame dimensions information in a rectangle object. In pixels. */
		//public var frame:Rectangle = new Rectangle();
		
		/** The texture config related to the base texture this sub texture is related */
		public var baseTextureConfig:NativeTextureConfig;
		
		/** If this texture is rotated */
		public var rotated:Boolean = false;
		
		public function SubTextureConfig(region:Rectangle, frame:Rectangle, baseTextureConfig:NativeTextureConfig, rotated:Boolean = false) {
			this.baseTextureConfig = baseTextureConfig;
			
			this.mappingLeft = region.x / baseTextureConfig.width;
			this.mappingTop = region.y / baseTextureConfig.height;
			this.mappingRight = (region.x + region.width) / baseTextureConfig.width;
			this.mappingBottom = (region.y + region.height) / baseTextureConfig.height;
			
			if(!frame){
				this.halfWidth = region.width * .5;
				this.halfHeight = region.height * .5;
			}
			else {
				this.halfWidth = frame.width * .5;
				this.halfHeight = frame.height * .5;
			}
			
			//this.region = region;
			//this.frame = frame;
			this.useFrame = frame;
			this.rotated = rotated;

			if(useFrame){
				this.frameRight  = frame.width  + frame.x - region.width;
				this.frameBottom = frame.height + frame.y - region.height;
				this.frameLeft = frame.x;
				this.frameTop = frame.y;
			}
		}
	}
}