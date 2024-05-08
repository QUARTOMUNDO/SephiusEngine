package SephiusEngine.core.gameplay.attributes.holders {
	import SephiusEngine.core.gameplay.attributes.AttributeHolder;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.IDamagerAttributes;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.ISufferAttributes;
	import SephiusEngine.core.gameplay.attributes.subAttributes.DamagerAttibutes;
	import SephiusEngine.core.gameplay.attributes.subAttributes.NatureGauge;
	import SephiusEngine.core.gameplay.attributes.subAttributes.SufferAttributes;
	import SephiusEngine.levelObjects.GameObject;
	import SephiusEngine.levelObjects.interfaces.IDamagerObject;
	import SephiusEngine.levelObjects.interfaces.ISufferObject;
	
	/**
	 * Attributes for harmfull objects like pools, spikes and etc.
	 * @author FernandoRabello
	 */
	public class HarmfullObjectAttributes extends AttributeHolder implements IDamagerAttributes, ISufferAttributes {
		public var parent:GameObject;
		
		public function HarmfullObjectAttributes(parent:GameObject) {
			this.parent = parent;
			_name = parent.name + "_Atributes";
			super();
		}
		public function get name():String { return _name; }
		private var _name:String;
		
		public function get enabled():Boolean {return _enabled;}
		public function set enabled(value:Boolean):void{
			_enabled = value;
		}
		private var _enabled:Boolean;
		
		/** Group os damager attributes. Objects can have multiple damagers with differents attributes values
		 * Damage System will iterate on all damagers and verify contacts and damage results automatcly */
		public function get avertSuffers():Vector.<ISufferObject>  { return _avertSuffers; }
		public function set avertSuffers(value:Vector.<ISufferObject> ):void {
			_avertSuffers = value;
		}
		private var _avertSuffers:Vector.<ISufferObject> = new Vector.<ISufferObject>();
		
		/** Group os damager attributes. Objects can have multiple damagers with differents attributes values
		 * Damage System will iterate on all damagers and verify contacts and damage results automatcly */
		public function get nerfedSuffers():Vector.<ISufferObject>  { return _nerfedSuffers; }
		public function set nerfedSuffers(value:Vector.<ISufferObject> ):void {
			_nerfedSuffers = value;
		}
		private var _nerfedSuffers:Vector.<ISufferObject> = new Vector.<ISufferObject>();
		
		/* INTERFACE SephiusEngine.core.gameplay.attributes.holders.interfaces.ISufferAttributes */
		
		/** Parent of the attribute holder witch needs to be a IDamagerObject */
		public function get sufferParent():ISufferObject  { return parent as ISufferObject; }
		
		/** Group os damager attributes. Objects can have multiple damagers with differents attributes values
		 * Damage System will iterate on all damagers and verify contacts and damage results automatcly */
		public function get sufferAttributes():Vector.<SufferAttributes>{return _sufferAttributes;}
		public function set sufferAttributes(value:Vector.<SufferAttributes>):void{
			_sufferAttributes = value;
		}
		private var _sufferAttributes:Vector.<SufferAttributes> = new Vector.<SufferAttributes>();
		
		public function get mainSuffer():SufferAttributes { return _mainSuffer ? _mainSuffer : sufferAttributes.length > 0 ? sufferAttributes[0] : null; };
		private var _mainSuffer:SufferAttributes;
		
		public function get damageTakenConstrainedByTime():Boolean{return _damageTakenConstrainedByTime;}
		public function set damageTakenConstrainedByTime(value:Boolean):void{
			_damageTakenConstrainedByTime = value;
		}
		private var _damageTakenConstrainedByTime:Boolean;
		
		public function get collisionEnabled():Boolean { return _collisionEnabled; }
		public function set collisionEnabled(valuer:Boolean):void { _collisionEnabled = valuer};
		private var _collisionEnabled:Boolean = true;
		
		public function updateSuffers():void{
			
		}
		
		/* INTERFACE SephiusEngine.core.gameplay.attributes.holders.interfaces.IDamagerAttributes */
		
		/** Parent of the attribute holder witch needs to be a IDamagerObject */
		public function get damagerParent():IDamagerObject  { return parent as IDamagerObject; }
		
		/** Group os damager attributes. Objects can have multiple damagers with differents attributes values
		 * Damage System will iterate on all damagers and verify contacts and damage results automatcly */
		public function get damagerAttributes():Vector.<DamagerAttibutes> { return _damagerAttributes; }
		public function set damagerAttributes(value:Vector.<DamagerAttibutes>):void{
			_damagerAttributes = value;
		}
		private var _damagerAttributes:Vector.<DamagerAttibutes> = new Vector.<DamagerAttibutes>();
		
		/** Determine the sucess of damager perform a critical damage */
		public function get efficiency():Number{return _efficiency;}
		private var _efficiency:Number;
		
		/** Additional ammount of efficiency. This can change by game logic like a status being applied */
		public function get efficiencyBuff():Number{return _efficiencyBuff;}
		public function set efficiencyBuff(value:Number):void{
			_efficiencyBuff = value;
		}
		private var _efficiencyBuff:int = 0;
		
		/** Logic witch will determint if damager is on a conddition to corrupt a suffer */
		public function shouldCorrupt(suffer:Object):Boolean {
			return true;
		}
		
		/** Update damagers values and contacts. */
		public function updateDamagers():void{
			
		}
		
		
		/* INTERFACE SephiusEngine.core.gameplay.attributes.holders.interfaces.ISufferAttributes */
		private var _natureImmunity:NatureGauge;
		public function get natureImmunity():NatureGauge 
		{
			return _natureImmunity;
		}
		
		public function set natureImmunity(value:NatureGauge):void 
		{
			_natureImmunity = value;
			
		}
		private var _natureImmunityBuff:NatureGauge;
		public function get natureImmunityBuff():NatureGauge 
		{
			return _natureImmunityBuff;
		}
		
		public function set natureImmunityBuff(value:NatureGauge):void 
		{
			_natureImmunityBuff = value;
		}
	}
}