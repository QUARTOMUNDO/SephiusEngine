package SephiusEngine.utils.pools 
{
	import SephiusEngine.core.levelManager.Presence;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Fernando Rabello
	 */
	public class PresencePool {
        private static var MAX_VALUE:uint = 50; 
        private static var GROWTH_VALUE:uint = 1; 
        private static var pool:Vector.<Presence>; 
        private static var currentObject:Presence; 
		private static var totalCreated:uint = 0;
		
		public function PresencePool() {
			
		}
		
        public static function initialize( maxPoolSize:uint = 50, growthValue:uint = 1 ):void { 
            MAX_VALUE = maxPoolSize;
            GROWTH_VALUE = growthValue;
            
            var i:uint = MAX_VALUE; 
            
            pool = new Vector.<Presence>(MAX_VALUE); 
			
            while( --i > -1 ) 
                pool[i] = new Presence(null); 
        } 
		
		private static var cObject:Presence;
        public static function getObject(parent:Object = null, useBounds:Boolean=false, controlLevel:Boolean=false, perceiveObjects:Boolean = false):Presence{ 
            if ( pool.length > 0 ) { 
				cObject = pool.pop(); 
				cObject.parent = parent;
				cObject.useBounds = useBounds;
				cObject.controlLevel = controlLevel;
				cObject.perceiveObjects = perceiveObjects;
                return cObject; 
			}
            
            var i:uint = GROWTH_VALUE; 
            while( --i > -1 ) 
				pool.unshift ( new Presence(null) ); 
			
            return getObject(parent, useBounds, controlLevel); 
        } 
		
        public static function returnObject(disposedObject:Presence):void { 
			disposedObject.ereaseValues();
            pool.push(disposedObject); 
        } 
	}
}