package SephiusEngine.core.gameplay.attributes.subAttributes{
	import SephiusEngine.core.gameplay.attributes.SubAttributes;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.IDamagerAttributes;
	import SephiusEngine.core.gameplay.attributes.subAttributes.NatureGauge;
	import SephiusEngine.core.gameplay.attributes.subAttributes.StatusGauge;
	import SephiusEngine.core.gameplay.damageSystem.DamageConstraint;
	import SephiusEngine.levelObjects.interfaces.ISufferObject;

	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	import nape.shape.Shape;

	import tLotDClassic.GameData.Properties.objectsInfos.GameObjectGroups;
	/**
	 * Store Attributes for harmfull objects
	 * @author Fernando Rabello
	 */
	public class DamagerAttibutes extends SubAttributes {
		/** Object witch has this attributes */ 
		public function get holder():IDamagerAttributes {return _holder;}
		private var _holder:IDamagerAttributes;
		
		/** Determine if damager is enabled and can actually produce a damage */
		public var enabled:Boolean = true;
		
		/** Tell witch attack is being performed. */
		public var currentID:String;
		
		/** Limit the damage collision to happen */
		public var damageConstraint:DamageConstraint;
		
		/** The object used to determine the contact/collision. Could be a range of objects: Quad, Image, Body, AtlasAnimation
		 * Each object type has its own logic to determine the contact. */
		public function get contact():* { return _contact; }
		public function set contact(value:*):void {
			if (value == undefined)
				trace ("weapon contact is undefined");
			
			_contact = value;
			
			if(_contact)
				this.contactClass = getDefinitionByName(getQualifiedClassName(_contact)) as Class;
		}
		private var _contact:*;
		/** Witch class contact belongs */
		public var contactClass:Class;
		
		/** If contact is a Body, it should identify what is the shape related with the damage, in case damager has multiple contact shapes */
		public var contactShape:Shape;
		
		/** Reduce contact bound by some amount of pixels from left */
		public var cropBoundLeft:Number = 0;
		/** Reduce contact bound by some amount of pixels from right */
		public var cropBoundRight:Number = 0;
		/** Reduce contact bound by some amount of pixels from top */
		public var cropBoundTop:Number = 0;
		/** Reduce contact bound by some amount of pixels from buttom */
		public var cropBoundButtom:Number = 0;
		
		/** A suffer witch this damager should damage no matter the it matchs the group or not. */
		public var target:ISufferObject;
		
		/** Determine witch suffer this damager should contact. 
		 * So witch group this damager should cause damage. */
		public var targetGroups:Vector.<GameObjectGroups> = new Vector.<GameObjectGroups>();
		
		/** Bitflag related with this group. Used to verify damage collisions groups and enemy awareness */
		public var targetGroupFlag:uint = 0;
		
		/** Determine damager will only actually damage the target */
		public var targetExclusive:Boolean = false;
		
		/** A suffer witch this damager should NOT damage no matter the it matchs the group or not. */
		public var avert:ISufferObject;
		
		/** Determine witch suffer this damager should NOT contact. 
		 * So witch group this damager should NOT cause damage. */
		public var avertGroups:Vector.<GameObjectGroups> = new Vector.<GameObjectGroups>();
		
		/** Bitflag related with this group. Used to verify damage collisions groups and enemy awareness */
		public var avertGroupFlag:uint = 0;
		
		/** Witch group this damager should cause less damage. */
		public var nerfGroups:Vector.<GameObjectGroups> = new Vector.<GameObjectGroups>();
		
		/** Bitflag related with this group. Used to verify damage collisions groups and enemy awareness */
		public var nerfGroupFlag:uint = 0;
		
		/** the reduction ratio of the damage dealed if suffer group is on of the nerfGroups of this damager attributes. */
		public var nerfRatio:Number = .2;
		
		/** Determine the strongness of the attack. If weight is greater than suffer weight the damage reaction will be stronger */
		public var weight:Number = 1;
		/** If damager can perform critical damages */
		public var criticable:Boolean = false;
		/** Angle witch suffer should be pulled in degress. -1 means suffer should be pulled same angle damager is facing. -2 means suffer will be pulled aways from the suffer related with damager center. */
		public var pullDirection:Number = -35;
		/** Define how relativity of pull direction should pull a suffer. 0 means absolute angle. 1 means relative to damager body angle. 2 means perpendicular related with damager body angle. 3 means away from damager center position. */
		public var pullTypeID:int = 0;
		
		/** Scales the damage impulse */
		public var attackImpulseIntensity:Number = 1;
		
		/** Tell how frequently this object will case damage in a roll */
		public var repeateTime:Number = 1;
		
		/**Add a status to the suffer when a damage occour*/
		public var corruptionStatus:StatusGauge = new StatusGauge();
		
		/** Tell the amount of damages for each nature damage can deal. */
		public var natures:NatureGauge = new NatureGauge();
		
		/** Total of damage this damager dealed in its history. This not take into the account the nature immunities and defences from suffers. */
		public var damageDealtPotential:Number = 0;
		
		/** Total of damage this damager dealed in its history. Taking into the account what was absorbed by suffers nature immunities and defences. */
		public var damageDealt:Number = 0;
		
		/** Determine the damage ration this object will cause to the suffer. Related with the type of action/attack */
		public var intensity:Number = 1;
		/** Determine the addicional power for the damage. Related with the weapons mostly */
		public var amplification:Number = 1;
		
		public var hurtTime:Number = 1;
		
		/** If false damage from this damager will only create splash if final damage is greater than 0 */
		public var showZeroDamage:Boolean = true;
		
		/** If true damage values from this damager will not be showed by HUD  */
		public var hideDamageValue:Boolean = false;
		
		/** If true damage art from this damager will not be showed by HUD  */
		public var hideDamageArt:Boolean = false;
		
		/** Allow suffer to enter on damage invunerable state after take damage from this damage  */
		public var allowInvunerable:Boolean = true;
		
		/** Allow suffer to defend the damage */
		public var denfensable:Boolean = true;
		
		public function DamagerAttibutes(holder:IDamagerAttributes) {
			this._holder = holder;
			this.name = _holder.name + "_D_" + (Math.random() * 1000).toFixed(0);
			//currentID = this.name;
			
			damageConstraint = new DamageConstraint(holder.name + (!holder.damagerAttributes ? 0 : holder.damagerAttributes.length + 1));
			//damageConstraint.addDefinitiveSufferName(this.name);
		}
		
		override public function dispose():void {
			_holder = null;
			natures = null;
			corruptionStatus = null;
			targetGroups = null;
			_contact = null;
			target = null;
			damageConstraint.dispose();
			damageConstraint = null;			
		}
	}
}