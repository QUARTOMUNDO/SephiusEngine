package SephiusEngine.core.gameplay.attributes.subAttributes {
	import SephiusEngine.core.gameplay.attributes.SubAttributes;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.ISufferAttributes;
	import SephiusEngine.core.gameplay.attributes.subAttributes.NatureGauge;

	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	import tLotDClassic.GameData.Properties.objectsInfos.GameObjectGroups;
	/**
	 * Contains methods and properties related with objects witch suffer damages
	 * @author Fernando [Sephius] Rabello
	 */
	public class SufferAttributes extends SubAttributes {
		/** Object witch has this attributes */ 
		public function get holder():ISufferAttributes {return _parent;}
		private var _parent:ISufferAttributes;
		
		/** The ID of this suffet. */
		public function get currentID():String { return _currentID; }
		private var _currentID:String;
		
		/** Determine if suffer is enabled and can actually receive a damage */
		public var enabled:Boolean = true;
		
		/** The object used to determine the contact/collision. Could be a range of objects: Quad, Image, AtlasAnimation
		 * Each object type has its own logic to determine the contact. */
		/** The object used to determine the contact/collision. Could be a range of objects: Quad, Image, Body, AtlasAnimation
		 * Each object type has its own logic to determine the contact. */
		public function get contact():* { return _contact; }
		public function set contact(value:*):void {
			_contact = value;
			if(_contact)
				this.contactClass = getDefinitionByName(getQualifiedClassName(_contact)) as Class;
		}
		private var _contact:*;
		
		/** Witch class contact belongs */
		public var contactClass:Class;
		
		/** Reduce contact bound by some amount of pixels from left */
		public var cropBoundLeft:Number = 0;
		/** Reduce contact bound by some amount of pixels from right */
		public var cropBoundRight:Number = 0;
		/** Reduce contact bound by some amount of pixels from top */
		public var cropBoundTop:Number = 0;
		/** Reduce contact bound by some amount of pixels from buttom */
		public var cropBoundButtom:Number = 0;
		
		/** Determine the strongness of the attack. If weight is greater than suffer weight the damage reaction will be stronger */
		public var weight:Number = 1;
		
		/** If suffer can receive critical damages */
		public var criticable:Boolean = false;
		
		/** Reduce damage by a particular nature */
		public var natureImmunity:NatureGauge = new NatureGauge();
		
		/** Damage this suffer taken in its history */
		public var damageTaken:Number = 0;
		
		/** ALTERNATIVEWitch groups os characters belongs. Crautaryus, Assincetrofokus ans etc. */
		/*public function get groups():Vector.<GameplayGroups> { return _groups; }
		public function set groups(value:Vector.<GameplayGroups>):void {
			_groups = value;
			
			var group:GameplayGroups;
			
			_groupFlag = 0;
			
			for each(group in value) {
				_groupFlag |= group.bitFlag;
			}
		}
		private var _groups:Vector.<GameplayGroups> = new Vector.<GameplayGroups>();*/
		
		/** Witch groups os characters belongs. Crautaryus, Assincetrofokus ans etc. */
		public var groups:Vector.<GameObjectGroups> = new Vector.<GameObjectGroups>();
		/** Bitflag related with this group. Used to verify damage collisions groups and enemy awareness */
		public var groupFlag:uint = 0;
		
		/**Tell the percent of the Peripheral Essence (Helth) the damage should be below to be considered a weak damage.*/
		public var weakDamagePercent:Number = 0.05;
		
		//public var dead:Boolean = false;
		
		/**Time witch character stay invunerable when take a damage. Only aplicable if damageTakenConstrainedByTime is true.*/
		public var damageTakenConstraintTime:Number = 1.5;
		/**When this is true, character will become invunerable for some time after a damage*/
		public var damageTakenConstrainedByTime:Boolean = false;
		
		/**Splash that is shown when creature from a normal/strong/powerfull physical attack*/
		public var normalSplash:String;
		/**Splash that is shown when creature from a weak physical attack*/
		public var weakSplash:String;
		/**Splash that is shown when creature is defending.*/
		public var defenceSplash:String;
		/**Splash that is shown when creature has abnormalState true*/
		public var abnormalSplash:String;
		/** If this suffer is defending against the damagers */
		public var defending:Boolean = false;
		
		/** If false damage from this damager will only create splash if final damage is greater than 0 */
		public var hideZeroDamage:Boolean = true;
		
		/** If true damage values to this suffer will not be showed by HUD  */
		public var hideDamageValue:Boolean = false;
		
		/** If true damage art to this suffer will not be showed by HUD  */
		public var hideDamageArt:Boolean = false;
		
		public function SufferAttributes(parent:ISufferAttributes, currentID:String=null) {
			this._parent = parent;
			if (!currentID)
				_currentID = _parent.name + "_S_" + (Math.random() * 1000).toFixed(0);
			else
				_currentID = currentID;
		}
		
		
		override public function dispose():void {
			_parent = null;
			contact = null;
			natureImmunity  = null;
			groups = null;
		}
	}
}