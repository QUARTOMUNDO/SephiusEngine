package SephiusEngine.utils.pools 
{
	import SephiusEngine.displayObjects.particles.system.EssenceParticle;
	/**
	 * Store particles
	 * @author Fernando Rabello
	 */
	public class ParticlePool {
        private static var MAX_VALUE:uint = 1000; 
        private static var GROWTH_VALUE:uint = 1; 
        private static var pool:Vector.<EssenceParticle>; 
		
		public static var initialized:Boolean = false;
		
        public static function initialize( maxPoolSize:uint = 1000, growthValue:uint = 100 ):void { 
            MAX_VALUE = maxPoolSize;
            GROWTH_VALUE = growthValue;
            
            var i:uint = MAX_VALUE; 
            
            pool = new Vector.<EssenceParticle>(MAX_VALUE); 
			
            while( --i > -1 ) 
                pool[i] = new EssenceParticle(); 
			
			initialized = true;
        } 
         
        public static function getObject():EssenceParticle{ 
            if ( pool.length > 0 ){ 
                return pool.pop(); 
			}
               
            var i:uint = GROWTH_VALUE; 
            while( --i > -1 ) 
                    pool.unshift ( new EssenceParticle()); 
            return getObject(); 
             
        } 
		
        public static function returnObject(disposedObject:EssenceParticle):void { 
			disposedObject.x = 0;
			disposedObject.y = 0;
			disposedObject.scaleX = 1;
			disposedObject.scaleY = 1;
			disposedObject.rotation = 0;
			disposedObject.color = 0xffffff;
			disposedObject.alpha = 1;

			disposedObject.currentTime = 0;
			disposedObject.totalTime = 1;
		
			disposedObject.colorArgb.alpha = 0;
			disposedObject.colorArgb.blue = 0;
			disposedObject.colorArgb.green = 0;
			disposedObject.colorArgb.red = 0;
			
			disposedObject.colorArgbDelta.alpha = 0;
			disposedObject.colorArgbDelta.blue = 0;
			disposedObject.colorArgbDelta.green = 0;
			disposedObject.colorArgbDelta.red = 0;
			
			disposedObject.startX = disposedObject.startY = 0;
			disposedObject.velocityX = disposedObject.velocityY = 0;
			disposedObject.radialAcceleration = 0;
			disposedObject.tangentialAcceleration = 0;
			disposedObject.emitRadius = disposedObject.emitRadiusDelta = 0;
			disposedObject.emitRotation = disposedObject.emitRotationDelta = 0;
			disposedObject.rotationDelta = 0;
			disposedObject.scaleDelta = 0;
			
			disposedObject.hAlpha = 1;
			disposedObject.alphaFade = 0;
			disposedObject.alphaFadeDelta = 0;
			
			disposedObject.absorbed = false;
			disposedObject.absorber = null;
			disposedObject.aborberDistanceScalar = 0;
			
            pool.push(disposedObject); 
		}
	}
}