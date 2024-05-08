package SephiusEngine.core.gameplay.inventory {
	import SephiusEngine.core.gameplay.properties.ObjectProperties;
	import SephiusEngine.displayObjects.AnimationPack;
	/**
	 * Generic class for a inventory object
	 * @author Fernando Rabello
	 */
	public class InventoryObject {
		public var name:String;
		public var baseProperty:ObjectProperties;
		public var inventoryClass:Class;
		public var amount:uint;
		public var maxAmount:uint;
		public var equiped:Boolean = false;
		/**Used to sort objects */
		public var id:uint;
		public var disabled: Boolean = false;
		/** If false this object will not be shown on HUD rings */
		public var showInHUDRing:Boolean = true;
		 
		public function InventoryObject(baseProperty:ObjectProperties, amount:uint, inventoryClass:Class) {
			this.name = baseProperty.varName;
			this.baseProperty = baseProperty; 
			this.id = baseProperty.id;
			this.inventoryClass = inventoryClass;
			this.amount = amount;
			this.maxAmount = (baseProperty as Object).maxAmount;
		}
		
		public function dispose():void {
			baseProperty = null;
			inventoryClass = null;
		}
	}
}