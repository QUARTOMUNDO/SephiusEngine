package SephiusEngine.core.gameplay.attributes.subAttributes {
	import tLotDClassic.GameData.Properties.SpellProperties;
	import tLotDClassic.GameData.Properties.naturesInfos.Natures;
	/**
	 * @author FernandoRabello
	 */
	public class NatureSubRelations {
		public function get Fire():SpellProperties { return fire; }
		public function set Fire(value:SpellProperties):void { fire = value; }
		private var fire:SpellProperties;
		
		public function get Ice():SpellProperties { return ice; }
		public function set Ice(value:SpellProperties):void { ice = value; }
		private var ice:SpellProperties;
		
		public function get Water():SpellProperties { return water; }
		public function set Water(value:SpellProperties):void { water = value; }
		private var water:SpellProperties;
		
		public function get Earth():SpellProperties { return earth; }
		public function set Earth(value:SpellProperties):void { earth = value; }
		private var earth:SpellProperties;
		
		public function get Air():SpellProperties { return air; }
		public function set Air(value:SpellProperties):void { air = value; }
		private var air:SpellProperties;
		
		public function get Light():SpellProperties { return light; }
		public function set Light(value:SpellProperties):void { light = value; }
		private var light:SpellProperties;
		
		public function get Darkness():SpellProperties { return darkness; }
		public function set Darkness(value:SpellProperties):void { darkness = value; }
		private var darkness:SpellProperties;
		
		public function get Corruption():SpellProperties { return corruption; }
		public function set Corruption(value:SpellProperties):void { corruption = value; }
		private var corruption:SpellProperties;
		
		public function get Bio():SpellProperties { return bio; }
		public function set Bio(value:SpellProperties):void {  bio = value; }
		private var bio:SpellProperties;
		
		public function get Psionica():SpellProperties { return psionica; }
		public function set Psionica(value:SpellProperties):void { psionica = value; }
		private var psionica:SpellProperties;
		
		public function get Physical():SpellProperties { return physical; }
		public function set Physical(value:SpellProperties):void {  physical = value; }
		private var physical:SpellProperties;
		
		public var natures:Vector.<String> = new Vector.<String>();
		public var mysticalNatures:Vector.<String> = new Vector.<String>();
		
		public function NatureSubRelations() { 
			mysticalNatures.push(Natures.Fire);
			mysticalNatures.push(Natures.Ice);
			mysticalNatures.push(Natures.Water);
			mysticalNatures.push(Natures.Earth);
			mysticalNatures.push(Natures.Air);
			mysticalNatures.push(Natures.Light);
			mysticalNatures.push(Natures.Darkness);
			mysticalNatures.push(Natures.Corruption);
			mysticalNatures.push(Natures.Bio);
			mysticalNatures.push(Natures.Psionica);
			
			natures = mysticalNatures.concat();
			natures.push(Natures.Physical);
		}
	}
}