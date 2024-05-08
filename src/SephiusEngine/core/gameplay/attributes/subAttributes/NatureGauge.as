package SephiusEngine.core.gameplay.attributes.subAttributes {

	/**
	 * Define arbitary values for each Game Natures @see NatureProperties
	 * This class is used in several ways by several classes.
	 * For example for NatureImmnity each value determine about of resistance for that particular Nature
	 * For AttackNatures each value determine a Nature damage to suffer receive
	 * Generally a value iqual to 0 means null nature.
	 * Call defineAboveZero() to update a list of values greater than 0. This list is used to reduce number of verification. (only above zero will be verified)
	 * @author FernandoRabello
	 */
	public class NatureGauge {
		
		public function get Fire():Number { return fire; }
		public function set Fire(value:Number):void { updateGauge("Fire", value); fire = value; }
		private var fire:Number = 0;
		
		public function get Ice():Number { return ice; }
		public function set Ice(value:Number):void { updateGauge("Ice", value); ice = value; }
		private var ice:Number = 0;
		
		public function get Water():Number { return water; }
		public function set Water(value:Number):void { updateGauge("Water", value); water = value; }
		private var water:Number = 0;
		
		public function get Earth():Number { return earth; }
		public function set Earth(value:Number):void { updateGauge("Earth", value); earth = value; }
		private var earth:Number = 0;
		
		public function get Air():Number { return air; }
		public function set Air(value:Number):void { updateGauge("Air", value); air = value; }
		private var air:Number = 0;
		
		public function get Light():Number { return light; }
		public function set Light(value:Number):void { updateGauge("Light", value); light = value; }
		private var light:Number = 0;
		
		public function get Darkness():Number { return darkness; }
		public function set Darkness(value:Number):void { updateGauge("Darkness", value); darkness = value; }
		private var darkness:Number = 0;
		
		public function get Corruption():Number { return corruption; }
		public function set Corruption(value:Number):void { updateGauge("Corruption", value); corruption = value; }
		private var corruption:Number = 0;
		
		public function get Bio():Number { return bio; }
		public function set Bio(value:Number):void { updateGauge("Bio", value); bio = value; }
		private var bio:Number = 0;
		
		public function get Psionica():Number { return psionica; }
		public function set Psionica(value:Number):void { updateGauge("Psionica", value); psionica = value; }
		private var psionica:Number = 0;
		
		public function get Physical():Number { return physical; }
		public function set Physical(value:Number):void { updateGauge("Physical", value); physical = value; }
		private var physical:Number = 0;
		
		/** Define the list with all natures properties in this class to be used by other methods.*/
		private function updateGauge(name:String, value:Number):void {
			if (this[name] == 0 && value != 0) {
				aboveZero.push(name);
			}
			else if (this[name] != 0 && value == 0) {
				i = aboveZero.indexOf(name);
				aboveZero.splice(i, 1);
			}
		}
		
		public var aboveZero:Vector.<String> = new Vector.<String>();
		
		private var i:int;
		private var paramName:String;
		public function NatureGauge(params:Object = null) { 
			if (params){
				for (paramName in params){
					this[paramName] = params[paramName];
				}
			}
		}
		
		private var hkey:String;
		private var nGauge:NatureGauge;
		
		/** Copy values from this gauge do new one */
		public function copy():NatureGauge {
			nGauge = new NatureGauge();
			for each (hkey in aboveZero) {
				nGauge[hkey] = this[hkey];
			}
			return nGauge;
		}
		
		/** Add another gauge into this gauge */
		public function add(gauge2:NatureGauge = null):void {
			for each (hkey in gauge2.aboveZero) {
				this[hkey] += gauge2[hkey]
			}
		}
		
		/** Combine another gauge with this gauge returning a new gauge */
		public function combine(gauge2:NatureGauge):NatureGauge {
			nGauge = copy();
			
			for each (hkey in gauge2.aboveZero) {
				nGauge[hkey] += gauge2[hkey]
			}
			
			return nGauge;
		}
		
		public function toString():String {
			var message:String = "";
			var i:int = 0;
			
			for (i = 0; i < aboveZero.length; i++) {
				message += aboveZero[i] + ":" + this[aboveZero[i]].toFixed(2) + ", ";
			}
			
			return message;
			//return String("Fire:" + Fire, "Ice:" + Ice, "Water:" + Water, "Earth:" + Earth, "Air:" + Air, "Light:" + Light, "Darkness:" + Darkness, "Corruption:" + Corruption, "Bio:" + Bio, "Psionica:" + Psionica, "Physical:" + Physical);
		}
		
		
	}
}