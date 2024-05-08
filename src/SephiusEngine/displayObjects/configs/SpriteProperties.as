package SephiusEngine.displayObjects.configs 
{
	import starling.display.BlendMode;
	/**
	 * Default values for filter used by Effects class
	 * @author Fernando Rabello
	 */
	public class SpriteProperties {
		public static const GENERIC_BRIGHT:SpriteProperties = new SpriteProperties(0xffffff, BlendMode.SCREEN, 0, 0, 1, 1, true);
		public static const GENERIC_OPAQUE:SpriteProperties = new SpriteProperties(0xffffff, BlendMode.NORMAL, 0, 0, 1, 1, true);
		
		public var color:uint = 0xffffff;
		public var blendMode:String = BlendMode.NORMAL;
		public var displacementX:Number = 0;
		public var displacementY:Number = 0;
		public var scaleOffsetX:Number = 1;
		public var scaleOffsetY:Number = 1;
		public var linkPosition:Boolean = true;
		
		public function SpriteProperties(color:uint, blendMode:String, displacementX:Number, displacementY:Number, scalleOffsetX:Number, scalleOffsetY:Number, linkPosition:Boolean) {
			this.color = color;
			this.blendMode = blendMode;
			this.displacementX = displacementX;
			this.displacementY = displacementY;
			this.scaleOffsetX = scalleOffsetX;
			this.scaleOffsetY = scalleOffsetY;
			this.linkPosition = linkPosition;
		}
		
		public function toString():String {
			return String("color:" + color + " blendMode:" + blendMode + " displacementX:" + displacementX +  " displacementY:" + displacementY + " linkPosition:" + linkPosition + " scalleOffsetX:" + scaleOffsetX + " scalleOffsetY:" + scaleOffsetY);
		}
	}

}