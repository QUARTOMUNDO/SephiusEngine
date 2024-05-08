package SephiusEngine.core.gameplay.inventory.objects {
	import SephiusEngine.core.gameplay.attributes.subAttributes.DamagerAttibutes;
	import SephiusEngine.core.gameplay.attributes.subAttributes.NatureGauge;
	import SephiusEngine.core.gameplay.attributes.subAttributes.StatusGauge;
	import SephiusEngine.core.gameplay.inventory.InventoryObject;

	import tLotDClassic.GameData.Properties.WeaponProperties;
	import tLotDClassic.gameArts.WeaponArt;
	/**
	 * Store a Weapon
	 * @author Fernando Rabello
	 */
	public class Weapon extends InventoryObject{
		/** Types of damages this weapon does. It can have multiple same time. */
		public var natures:NatureGauge = new NatureGauge();
		
		/** Corruption applied to the weapon. */
		public function get corruption():StatusGauge { return _corruption; }
		public function set corruption(value:StatusGauge):void { _corruption = value; }
		private var _corruption:StatusGauge = new StatusGauge();
		
		/** Propery uses by this weapon, casted as weapon property */
		public var property:WeaponProperties;
		
		/** Art used by this weapon */
		public var art:WeaponArt;
		
		/** Damager attribute this weapons is using */
		public var damager:DamagerAttibutes;
		
		/** This determine the weapon final potency. It´s related with the level, powerAmp and natures */ 
		public function get power():Number { return _power; }
		public function set power(value:Number):void { _power = value; }
		private var _power:Number = 0;
		
		/** Scale the final level for the weapon. */
		public function get level():Number { return _level; }
		public function set level(value:Number):void {
			_level = value; 
			this.power = WeaponProperties.getLeveledPower(this);
		}
		private var _level:Number = 0;
		
		/** Detewrminme if this weapons is being used by other object (mostly Sephius). 
		 * If true, this mean wepons is one of 2 used by the player */ 
		public function get selected():Boolean { return _selected; }
		public function set selected(value:Boolean):void { 
			_selected = value; 
		}
		private var _selected:Boolean;
		
		public static const WEAPONS:Vector.<Weapon> = new Vector.<Weapon>();
		
		public function Weapon(property:WeaponProperties, amount:int, inventoryClass:Class) {
			super(property, amount, inventoryClass);
			this.property = property;
			
			this.natures = property.natures;
			this.corruption = property.corruption;
			this.power = WeaponProperties.getPower(property);
			
			WEAPONS.push(this);
		}
		
		public function updateAttributes():void {
			this.power = WeaponProperties.getLeveledPower(this);
		}
		
		override public function dispose():void {
			super.dispose();
			this.natures = null;
			this.corruption = null;
			selected = false;
			
			WEAPONS.splice(WEAPONS.indexOf(this), 1);
		}
		
		/** Add a additional nature damage for the weapon beyont the natures the weapon properties give */
		public function addNatureDamage(nature:String, power:Number):void {
			natures[nature] += power;
		}
		
		/** Remove a nature damage for the weapon */
		public function removeNatureDamage(nature:String, power:Number):void {
			natures[nature] -= power;
		}
	}
}