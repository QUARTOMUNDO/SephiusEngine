package SephiusEngine.utils.pools 
{
	import SephiusEngine.displayObjects.AnimationPack;
	/**
	 * Pool of sprites with animation
	 * @author Fernando Rabello
	 */
	public class SpritePool {
        private static var MAX_VALUE:uint = 100; 
        private static var GROWTH_VALUE:uint = 1; 
        private static var pool:Vector.<AnimationPack>; 
		
        public static function initialize( maxPoolSize:uint = 30, growthValue:uint = 1 ):void { 
            MAX_VALUE = maxPoolSize;
            GROWTH_VALUE = growthValue;
             
            var i:uint = MAX_VALUE; 
             
            pool = new Vector.<AnimationPack>(MAX_VALUE); 
			
            while( --i > -1 ) 
                pool[i] = new AnimationPack("Splash", null ); 
        } 
         
        public static function getObject():AnimationPack{ 
            if ( pool.length > 0 ) 
                return pool.pop(); 
                 
            var i:uint = GROWTH_VALUE; 
            while( --i > -1 ) 
                    pool.unshift ( new AnimationPack("Splash", null ); 
            return getObject(); 
             
        } 
  
        public static function returnObject(disposedObject:SplashAnimation):void { 
            pool.push(disposedObject); 
        } 
	}

}