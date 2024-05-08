package SephiusEngine.displayObjects.configs 
{
	import SephiusEngine.displayObjects.configs.NativeTextureConfig;
	import SephiusEngine.displayObjects.configs.SubTextureConfig;
	import adobe.utils.CustomActions;
	import SephiusEngine.displayObjects.textures.ExtendedConcreteTexture;
	import SephiusEngine.utils.SortedDict;
	import flash.geom.Rectangle;
	import starling.textures.ConcreteTexture;
	import starling.textures.SubTexture;
	import starling.textures.Texture;
	/**
	 * Cache textures and information about them
	 * @author Fernando Rabello	
	 */
	public class TexturesCache {
		/** Name of this texture cache */
		public var name:String;
		/** amount of textures stored */
		public var amount:uint = 0;
		/** Subtextures configs stored. It also contains the native texture configs with info about the native texture */
		public var configs:Vector.<SubTextureConfig>;
		/** Sub textures stores. Contains similar (but less) information contained on configs. 
		 * It contains the parent "native" texture that could have or not data loaded */
		public var textures:Vector.<Texture>;
		/** A prefix related with native texture name and info presented on AtlasManager*/
		public var parentPrefix:String;
		/** If this cache should loop if is related with a animation */
		public var loop:Boolean = false;
		/** If this cache is related with a animation. 
		 * Other wise it should just store random textures not related with thenselves but have same native textures */
		public var isAnimation:Boolean;
		/** Determine the frame rate in case of this config be a animation. */
		public var frameRate:uint = 30;
		
		public function TexturesCache(name:String, parentPrefix:String, isAnimation:Boolean, frameRate:int = -1){
			this.name = name;
			this.parentPrefix = parentPrefix;
			this.isAnimation = isAnimation;
			this.frameRate = frameRate == -1 ? this.frameRate : frameRate;
			if (isAnimation && name.indexOf("Loop") >= 0)
				loop = true;
		}
		
		public function setTextureAndConfig(baseTexture:Texture, region:Rectangle, frame:Rectangle, frameNumber:uint, baseTextureConfig:NativeTextureConfig, rotated:Boolean):void {
			if (!configs)
				configs = new Vector.<SubTextureConfig>();
			
			if (!textures)
				textures = new Vector.<Texture>();
			
			var finalIndex:String;
			
			if (configs.length < frameNumber + 1){
				configs.length = frameNumber + 1;
			}
			
			if (textures.length < frameNumber + 1){
				textures.length = frameNumber + 1;
			}
			
			configs[Number(frameNumber)] = new SubTextureConfig(region, frame, baseTextureConfig, rotated);
			textures[Number(frameNumber)] = new SubTexture(baseTexture, region, false, frame, rotated);
			amount = amount < uint(frameNumber) + 1 ? uint(frameNumber) + 1 : amount;
		}
	}
}