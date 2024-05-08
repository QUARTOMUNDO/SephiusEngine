package SephiusEngine.core.gameplay.attributes.subAttributes 
{
	import SephiusEngine.core.gameplay.attributes.SubAttributes;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.IEssenceBleederAttributes;

	import tLotDClassic.GameData.Properties.EssenceProperties;
	import tLotDClassic.attributes.AttributesConstants;
	/**
	 * Store Essence Loots
	 * @author FernandoRabello
	 */
	public class EssenceLootAttributes extends SubAttributes {
		/** Normal Essence aspect. Normaly related with deep essence absorbation */
		public static var TYPE_DEEP:String = EssenceProperties.ASPECT_DEEP;
		/** Aspect related with nature ethos absorbation */
		public static var TYPE_ETHOS:String = EssenceProperties.ASPECT_ETHOS;
		/** Aspect related with essence witch causa damage and can´t be absorbed */
		public static var TYPE_CORRUPTED:String = EssenceProperties.ASPECT_CORRUPTED;
		
		/** Information about essence aspects */
		public function get essenceProperties():EssenceProperties { return _essenceProperties; }
		private var _essenceProperties:EssenceProperties;
		
		/** What kind of loot this essence loot grants. Deep, Nature Ethos or Corruption Status.
		 * This is bound to essence property ASPECT*/
		public function get type():String { return essenceProperties.aspect; }
		
		/** If this Essence Loot is type ETHOS, this say witch nature is related. Return null if Essence Loot is not type ETHOS */
		public function get ethosNature():String { return type != TYPE_ETHOS ? null : _ethosNature; }
		private var _ethosNature:String;
		
		/** The amount of loot the cloud could grant. It will decrease as bleeder bleeeds the essence */
		public function get amount():Number { return _amount; }
		public function set amount(value:Number):void { _amount = value } 
		private var _amount:Number = 0;
		
		public function EssenceLootAttributes() {
			
		}
		
		public function setValues(essenceProperties:EssenceProperties, ethosNature:String, lootAmount:Number):void {
			this.name = "_D_" + (Math.random() * 1000).toFixed(0);
			
			_essenceProperties = essenceProperties;
			_ethosNature = ethosNature;
			
			if(type == TYPE_ETHOS)
				_amount = lootAmount * AttributesConstants.ethosLootBalance * AttributesConstants.invigoration;
			else{
				//LootAmount is essencika * invigoration * bleeder's lootAmount * deepLootBalance(balancing)

				//Essencika: Number that defines all attributes values making all proportinal
				//Invigoration: Related with level proression. Also detemine amount of deep essence needed to level up.
				//Bleeder's LootAmount: Should be a percentual of deep essence needed to level up. So 1 means it will give 1 level
				//DeepLootBalance: Used to balancing the game make characters drop more or less essence globally.

				_amount = lootAmount * AttributesConstants.deepLootBalance * AttributesConstants.invigoration;
			}
		}
		
		public function ereaseValues():void {
			this.name = null;
			
			_essenceProperties = null;
			_ethosNature = null;
			_amount = 0;
		}
	}
}