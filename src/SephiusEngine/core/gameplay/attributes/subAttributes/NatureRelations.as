package SephiusEngine.core.gameplay.attributes.subAttributes {
	import SephiusEngine.core.gameplay.attributes.subAttributes.NatureSubRelations;

	import tLotDClassic.GameData.Properties.naturesInfos.Natures;
	/**
	 * @author FernandoRabello
	 */
	public class NatureRelations {
		public function get Fire():NatureSubRelations { return fire; }
		public function set Fire(value:NatureSubRelations):void { fire = value; }
		private var fire:NatureSubRelations = new NatureSubRelations();
		
		public function get Ice():NatureSubRelations { return ice; }
		public function set Ice(value:NatureSubRelations):void { ice = value; }
		private var ice:NatureSubRelations = new NatureSubRelations();
		
		public function get Water():NatureSubRelations { return water; }
		public function set Water(value:NatureSubRelations):void { water = value; }
		private var water:NatureSubRelations = new NatureSubRelations();
		
		public function get Earth():NatureSubRelations { return earth; }
		public function set Earth(value:NatureSubRelations):void { earth = value; }
		private var earth:NatureSubRelations = new NatureSubRelations();
		
		public function get Air():NatureSubRelations { return air; }
		public function set Air(value:NatureSubRelations):void { air = value; }
		private var air:NatureSubRelations = new NatureSubRelations();
		
		public function get Light():NatureSubRelations { return light; }
		public function set Light(value:NatureSubRelations):void { light = value; }
		private var light:NatureSubRelations = new NatureSubRelations();
		
		public function get Darkness():NatureSubRelations { return darkness; }
		public function set Darkness(value:NatureSubRelations):void { darkness = value; }
		private var darkness:NatureSubRelations = new NatureSubRelations();
		
		public function get Corruption():NatureSubRelations { return corruption; }
		public function set Corruption(value:NatureSubRelations):void { corruption = value; }
		private var corruption:NatureSubRelations = new NatureSubRelations();
		
		public function get Bio():NatureSubRelations { return bio; }
		public function set Bio(value:NatureSubRelations):void {  bio = value; }
		private var bio:NatureSubRelations = new NatureSubRelations();
		
		public function get Psionica():NatureSubRelations { return psionica; }
		public function set Psionica(value:NatureSubRelations):void { psionica = value; }
		private var psionica:NatureSubRelations = new NatureSubRelations();
		
		public function get Physical():NatureSubRelations { return physical; }
		public function set Physical(value:NatureSubRelations):void {  physical = value; }
		private var physical:NatureSubRelations = new NatureSubRelations();
		
		public var natures:Vector.<String> = new Vector.<String>();
		public var mysticalNatures:Vector.<String> = new Vector.<String>();
		
		public function NatureRelations() { 
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