package SephiusEngine.utils.pools { 
	import SephiusEngine.displayObjects.AnimationPack;
	import SephiusEngine.levelObjects.effects.SplashAnimation;
     
    public final class SplashPool { 
        private static var MAX_VALUE:uint = 200; 
        private static var GROWTH_VALUE:uint = 1; 
        private static var pool:Vector.<SplashAnimation>; 
	
        public static function initialize( maxPoolSize:uint = 30, growthValue:uint = 1 ):void { 
            MAX_VALUE = maxPoolSize;
            GROWTH_VALUE = growthValue;
            
            var i:uint = MAX_VALUE; 
            
            pool = new Vector.<SplashAnimation>(MAX_VALUE); 
			
            while( --i > -1 ) 
                pool[i] = new SplashAnimation("Splash" + i, {parent:null} ); 
        } 
         
        public static function getObject():SplashAnimation{ 
            if ( pool.length > 0 ) 
                return pool.pop(); 
                 
            var i:uint = GROWTH_VALUE; 
            while( --i > -1 ) 
                    pool.unshift ( new SplashAnimation("Splash" + i, {parent:null} ) ); 
            return getObject(); 
             
        } 
		
        public static function returnObject(disposedObject:SplashAnimation):void { 
			disposedObject.x = disposedObject.y = 0;
			disposedObject.scaleX = disposedObject.scaleY = 1;
			disposedObject.parallax = 1;
			disposedObject.offsetX = disposedObject.offsetY = 0;
			disposedObject.linkPosition = false;
			disposedObject.linkGroup = false;
			disposedObject.group = 9;
			disposedObject.view.scaleX = disposedObject.view.scaleY = 1;
			disposedObject.displacementX = disposedObject.displacementY = 0;
			(disposedObject.spriteArt as AnimationPack).changeAnimation("");
			disposedObject.animation = "";
			disposedObject.parent = null;
			disposedObject.useSound = false;
			//disposedObject.remove = false;
			
            pool.push(disposedObject); 
        } 
    } 
}