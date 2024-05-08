package SephiusEngine.core.gameplay.inventory.objects {
	import SephiusEngine.core.gameplay.inventory.InventoryObject;
	import tLotDClassic.GameData.Properties.MemoProperties;
	import SephiusEngine.userInterfaces.map.MapLocationIDTypes;
	import SephiusEngine.core.gameStates.LevelManager;
	import tLotDClassic.gameObjects.rewards.Reward;
	/**
	 * Store a Record
	 * @author Fernando Rabello
	 */
	public class Memo extends InventoryObject {
		public var property:MemoProperties;
		
		public var read:Boolean;

		/**If object will be equiped on wheels when first time collected */
		public var autoEquip:Boolean = false;

		public function Memo(property:MemoProperties, amount:int, inventoryClass:Class) {
			super(property, amount, inventoryClass);
			this.property = property;
		}
		
		override public function dispose():void {
			super.dispose();
			property = null;
		}

		/** Verify if this memo  should enable map location for other reward or if it should enable a site map */
		public function collectionActivation():void{
			var targetMapLocation:String = property.targetMapLocation;
			var mapLocationType:String = property.mapLocationType;

			if(targetMapLocation != ""){
				if(mapLocationType == MapLocationIDTypes.TYPE_MAP_DISCOVERY){
					LevelManager.getInstance().userInterfaces.gameMap.enableSiteMapByName(targetMapLocation);
				}
				else{
					if(Reward.rewardsByMapLocationID[targetMapLocation])
						Reward.rewardsByMapLocationID[targetMapLocation].addToMap();
				}
			}
		}
	}
}