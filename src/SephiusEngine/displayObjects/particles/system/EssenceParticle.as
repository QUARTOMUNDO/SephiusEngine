package SephiusEngine.displayObjects.particles.system {
	import SephiusEngine.levelObjects.interfaces.IEssenceAbsorber;

	import starling.extensions.particles.ColorArgb;
	
	/**
	 * Particles witch compound a Essence Cloud and other particle Systems
	 * @author Fernando Rabello
	 */
	public class EssenceParticle {
        public var x:Number;
        public var y:Number;
        //public var scale:Number;
        public var scaleX:Number;
        public var scaleY:Number;
        public var rotation:Number;
        public var color:uint;
        public var alpha:Number;
        
        public var currentTime:Number;
        public var totalTime:Number;
		
        public var colorArgb:ColorArgb;
        public var colorArgbDelta:ColorArgb;
        public var startX:Number, startY:Number;
        public var velocityX:Number = 0, velocityY:Number = 0;
        public var abDistanceX:Number = 0, abDistanceY:Number = 0;
        public var radialAcceleration:Number = 0;
        public var tangentialAcceleration:Number = 0;
        public var emitRadius:Number = 0, emitRadiusDelta:Number = 0;
        public var emitRotation:Number = 0, emitRotationDelta:Number = 0;
        public var rotationDelta:Number = 0;
        public var scaleDelta:Number = 0;
		
		public var frameIdx:int = 0;
		public var frame:Number = 0;
		public var frameDelta:Number = 0;
		
		public var hAlpha:Number = 1;
		public var alphaFade:Number = 0;
		public var alphaFadeDelta:Number = 0;
		
		public function EssenceParticle() {
            colorArgb = new ColorArgb();
            colorArgbDelta = new ColorArgb();
			
            x = y = rotation = currentTime = 0.0;
            totalTime = alpha = scaleX = scaleY = 1.0;
            color = 0xffffff;
		}
		
		public var absorbed:Boolean = false;
		public var absorber:IEssenceAbsorber;
		public var aborberDistanceScalar:Number;
	}
}