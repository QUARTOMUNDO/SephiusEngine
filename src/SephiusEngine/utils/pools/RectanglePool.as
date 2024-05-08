package SephiusEngine.utils.pools { 
	import flash.geom.Rectangle;
     
    public final class RectanglePool { 
        private static var MAX_VALUE:uint = 25000; 
        private static var GROWTH_VALUE:uint = 1; 
        private static var pool:Vector.<Rectangle>; 
        private static var currentObject:Rectangle; 
		private static var totalCreated:uint = 0;
		
        public static function initialize( maxPoolSize:uint = 5000, growthValue:uint = 1 ):void { 
            MAX_VALUE = maxPoolSize; 
            GROWTH_VALUE = growthValue; 
             
            var i:uint = MAX_VALUE; 
             
            pool = new Vector.<Rectangle>(MAX_VALUE); 
			
            while( --i > -1 ){ 
                pool[i] = new Rectangle(0, 0, 0, 0 ); 
				totalCreated++;
			}
        } 
         
        public static function getRectangle():Rectangle{ 
            if ( pool.length > 0 ) {
                return pool.pop(); 
            }
                 
            var i:uint = GROWTH_VALUE; 
            while( --i > -1 ){ 
				pool.unshift ( new Rectangle(0, 0, 0, 0 ));
				totalCreated++;
			}
            return getRectangle(); 
             
        } 
        
        public static function getRectangleFromOther(source:Rectangle):Rectangle{ 
            if (pool.length > 0 ) { 
				currentObject = pool.pop();
				currentObject.x = source.x;
				currentObject.y = source.y;
				currentObject.width = source.width;
				currentObject.height = source.height;
                return currentObject; 
			}
            
            var i:uint = GROWTH_VALUE; 
            while( --i > -1 ){ 
				pool.unshift ( new Rectangle(0, 0, 0, 0 ));
				totalCreated++;
			}
            return getRectangleSetted(source.x, source.y, source.width, source.height); 
        }

        public static function getRectangleSetted(x:Number, y:Number, width:Number, height:Number):Rectangle{ 
            if (pool.length > 0 ) { 
				currentObject = pool.pop();
				currentObject.x = x;
				currentObject.y = y;
				currentObject.width = width;
				currentObject.height = height;
                return currentObject; 
			}
            
            var i:uint = GROWTH_VALUE; 
            while( --i > -1 ){ 
				pool.unshift ( new Rectangle(0, 0, 0, 0 ));
				totalCreated++;
			}
            return getRectangleSetted(x, y, width, height); 
        } 
  
        public static function returnRectangle(disposedRectangle:Rectangle):void { 
            if(disposedRectangle)
                pool.push(disposedRectangle); 
        } 
    } 
}