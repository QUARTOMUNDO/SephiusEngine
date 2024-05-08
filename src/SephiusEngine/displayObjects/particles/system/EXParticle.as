package SephiusEngine.displayObjects.particles.system {
	import com.greensock.TweenMax;
	import SephiusEngine.levelObjects.interfaces.IEssenceAbsorber;
	import starling.extensions.particles.ColorArgb;
	import starling.extensions.particles.Particle;
	import starling.extensions.particles.PDParticle;
	
	/**
	 * Particles witch compound a Essence Cloud and other particle Systems
	 * @author Fernando Rabello
	 */
	public class EXParticle {
		public var active:Boolean = false;
		public var justActivated:Boolean = false;
		
		public var wildness:Number = 1;
		
		public var fadeInFactor:Number = 0;
		public var fadeOutFactor:Number = 0;
		public var spawnFactor:Number = 0;
		
		public var animationIdx:int = 0;
		public var frameIdx:int = 0;
		public var frameAmount:int = 0;
		public var frame:Number = 0;
		public var loopCount:uint = 0;
		public var frameDelta:Number = 0;
		
        public var displacementX:Number = 0.0;
        public var displacementY:Number = 0.0;
        public var displacementRotation:Number = 0.0;
		
        public var x:Number = 0.0;
        public var y:Number = 0.0;
        public var oldX:Number = 0.0;
        public var oldY:Number = 0.0;
        public var mScale:Number = 0.0;
        public var motionScale:Number = 0.0;
        public var scaleX:Number = 1.0;
        public var scaleY:Number = 1.0;
        public var oldScaleX:Number = 1.0;
        public var oldScaleY:Number = 1.0;
        public var oScaleX:Number = 1.0;
        public var oScaleY:Number = 1.0;
        public var oscilationX:Number = 0.0;
        public var oscilationY:Number = 0.0;
        public var oscilationFrequencyX:Number = 0.0;
        public var oscilationFrequencyY:Number = 0.0;
        public var oscilationAngleX:Number = 0.0;
        public var oscilationAngleY:Number = 0.0;
		
        public var rotation:Number = 0.0;
        public var oldRotation:Number = 0.0;
        public var currentTime:Number = 0.0;
        public var totalTime:Number = 1.0;
		
		public var colorRed:Number = 1.0;
		public var colorGreen:Number = 1.0;
		public var colorBlue:Number = 1.0;
		public var colorAlpha:Number = 1.0;
		
		public var colorDeltaRed:Number = 0.0;
		public var colorDeltaGreen:Number = 0.0;
		public var colorDeltaBlue:Number = 0.0;
		public var colorDeltaAlpha:Number = 0.0;
		
		public var emitter:ParticleEmitter;
        public var startX:Number = 0.0, startY:Number = 0.0;
        public var originX:Number = 0.0, originY:Number = 0.0;
        public var velocityX:Number = 0, velocityY:Number = 0;
        public var abDistanceX:Number = 0, abDistanceY:Number = 0;
        public var radialAcceleration:Number = 0;
        public var tangentialAcceleration:Number = 0;
		public var dragForce:Number = 1;
        public var emitRadius:Number = 0, emitRadiusDelta:Number = 0;
        public var emitRotation:Number = 0, emitRotationDelta:Number = 0;
        public var rotationDelta:Number = 0;
        public var scaleDeltaX:Number = 0;
        public var scaleDeltaY:Number = 0;
		
		public var bounceCoefficient:Number = 1;
		
		public function EXParticle() {}
		
		public var collided:Boolean = false;
		public var numCollisions:uint = 0;
		public var sleeping:Boolean = false;
		public var absorbed:Boolean = false;
		public var absorber:IEssenceAbsorber;
		public var aborberDistanceScalar:Number;
		
		public function get color():uint {
			return new ColorArgb(colorRed, colorGreen, colorBlue, 1).toRgb();
		}
        private var _color:uint = 0xffffff;
	}
}