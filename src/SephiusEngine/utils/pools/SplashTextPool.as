package SephiusEngine.utils.pools { 
	import SephiusEngine.userInterfaces.SplashText;
     
    public final class SplashTextPool { 
        private static var MAX_VALUE:uint = 50; 
        private static var GROWTH_VALUE:uint = 1; 
        private static var pool:Vector.<SplashText>; 
		
        public static function initialize( maxPoolSize:uint = 50, growthValue:uint = 1 ):void { 
            MAX_VALUE = maxPoolSize; 
            GROWTH_VALUE = growthValue; 
             
            var i:uint = MAX_VALUE; 
             
            pool = new Vector.<SplashText>(MAX_VALUE); 
			
            while( --i > -1 ) 
                pool[i] = new SplashText("Splash" + i); 
        } 
         
        public static function getObject():SplashText{ 
            if ( pool.length > 0 ) 
                return pool.pop(); 
                 
            var i:uint = GROWTH_VALUE; 
            while( --i > -1 ) 
                    pool.unshift ( new SplashText("Splash" + i) ); 
            return getObject(); 
             
        } 
		
        public static function returnObject(disposedObject:SplashText):void { 
            pool.push(disposedObject); 
        } 
    } 
}