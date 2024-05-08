package SephiusEngine.core.gameplay.inventory.objects {
	import SephiusEngine.core.gameplay.inventory.InventoryObject;
	import tLotDClassic.GameData.Properties.SpellProperties;
	/**
	 * This class is actually not being used.
	 * Store spells witch a character knows. Not used yet.
	 * @author Fernando Rabello
	 */
	public class SpellKnowledge extends InventoryObject {
		public var property:SpellProperties;

		public function SpellKnowledge(property:SpellProperties, amount:int, inventoryClass:Class) {
			super(property, amount, inventoryClass);
			this.property = property;
		}
		
		override public function dispose():void {
			super.dispose();
			property = null;
		}
	}
}