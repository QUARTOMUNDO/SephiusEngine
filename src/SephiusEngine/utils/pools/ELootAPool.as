package SephiusEngine.utils.pools 
{
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.IEssenceBleederAttributes;
	import SephiusEngine.core.gameplay.attributes.subAttributes.EssenceLootAttributes;
	import tLotDClassic.GameData.Properties.EssenceProperties;
	/**
	 * ...
	 * @author Fernando Rabello
	 */
	public class ELootAPool {
        private static var MAX_VALUE:uint = 20; 
        private static var GROWTH_VALUE:uint = 1; 
        private static var pool:Vector.<EssenceLootAttributes>; 
        private static var currentObject:EssenceLootAttributes; 
		private static var totalCreated:uint = 0;
		
		public function ELootAPool() {
			
		}
		
        public static function initialize( maxPoolSize:uint = 20, growthValue:uint = 1 ):void { 
            MAX_VALUE = maxPoolSize;
            GROWTH_VALUE = growthValue;
            
            var i:uint = MAX_VALUE; 
            
            pool = new Vector.<EssenceLootAttributes>(MAX_VALUE); 
			
            while( --i > -1 ) 
                pool[i] = new EssenceLootAttributes(); 
        } 
		
		private static var cObject:EssenceLootAttributes;
        public static function getObject(essenceProperties:EssenceProperties, ethosNature:String, lootAmount:Number):EssenceLootAttributes{ 
            if ( pool.length > 0 ) { 
				cObject = pool.pop(); 
				cObject.setValues(essenceProperties, ethosNature, lootAmount);
                return cObject; 
			}
            
            var i:uint = GROWTH_VALUE; 
            while( --i > -1 ) 
				pool.unshift ( new EssenceLootAttributes() ); 
			
            return getObject(essenceProperties, ethosNature, lootAmount); 
        } 
		
        public static function returnObject(disposedObject:EssenceLootAttributes):void { 
			disposedObject.ereaseValues();
            pool.push(disposedObject); 
        } 
	}
}