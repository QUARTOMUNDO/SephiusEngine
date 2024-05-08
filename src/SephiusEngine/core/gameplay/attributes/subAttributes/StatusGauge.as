package SephiusEngine.core.gameplay.attributes.subAttributes {
	import tLotDClassic.GameData.Properties.StatusProperties;
	/**
	 * Define arbitary values for each Game Staus @see StatusProperties
	 * This class is used in several ways by several classes.
	 * For example for StatusImmnity each value determine about of resistance for that particular status
	 * For Attack corruption each value determine a status do be risen to suffer on damge
	 * Generally a value iqual to 0 means null status.
	 * Call defineAboveZero() to update a list of values greater than 0. This list is used to reduce number of verification. (only above zero will be verified)
	 * @author FernandoRabello
	 */
	public class StatusGauge {
		public function get damaged():Number { return _damaged; }
		public function set damaged(value:Number):void { updateGauge("damaged", value); _damaged = value; }
		private var _damaged:Number = 0;
		
		public function get healed():Number { return _healed; }
		public function set healed(value:Number):void { updateGauge("healed", value); _healed = value; }
		private var _healed:Number = 0;
		
		public function get LightEmbedded():Number { return _LightEmbedded; }
		public function set LightEmbedded(value:Number):void { updateGauge("LightEmbedded", value); _LightEmbedded = value; }
		private var _LightEmbedded:Number = 0;
		
		public function get DarkEmbedded():Number { return _DarkEmbedded; }
		public function set DarkEmbedded(value:Number):void { updateGauge("DarkEmbedded", value); _DarkEmbedded = value; }
		private var _DarkEmbedded:Number = 0;
		
		public function get MestizoEmbedded():Number { return _MestizoEmbedded; }
		public function set MestizoEmbedded(value:Number):void { updateGauge("MestizoEmbedded", value); _MestizoEmbedded = value; }
		private var _MestizoEmbedded:Number = 0;
		
		public function get NoneEmbedded():Number { return _NoneEmbedded; }
		public function set NoneEmbedded(value:Number):void { updateGauge("NoneEmbedded", value); _NoneEmbedded = value; }
		private var _NoneEmbedded:Number = 0;
		
		public function get defenceDamaged():Number { return _defenceDamaged; }
		public function set defenceDamaged(value:Number):void { updateGauge("defenceDamaged", value); _defenceDamaged = value; }
		private var _defenceDamaged:Number = 0;
		
		public function get defenceHealed():Number { return _defenceHealed; }
		public function set defenceHealed(value:Number):void { updateGauge("defenceHealed", value); _defenceHealed = value; }
		private var _defenceHealed:Number = 0;
		
		public function get damageInvunerable():Number { return _damageInvunerable; }
		public function set damageInvunerable(value:Number):void { updateGauge("damageInvunerable", value); _damageInvunerable = value; }
		private var _damageInvunerable:Number = 0;
		
		// God Conditions
		public function get amplified():Number { return _amplified; }
		public function set amplified(value:Number):void { updateGauge("amplified", value); _amplified = value; }
		private var _amplified:Number = 0;
		
		public function get physicallyProtected():Number { return _physicallyProtected; }
		public function set physicallyProtected(value:Number):void { updateGauge("physicallyProtected", value); _physicallyProtected = value; }
		private var _physicallyProtected:Number = 0;
		
		public function get mysticallyProtected():Number { return _mysticallyProtected; }
		public function set mysticallyProtected(value:Number):void { updateGauge("mysticallyProtected", value); _mysticallyProtected = value; }
		private var _mysticallyProtected:Number = 0;
		
		public function get warmlyProtected():Number { return _warmlyProtected; }
		public function set warmlyProtected(value:Number):void { updateGauge("warmlyProtected", value); _warmlyProtected = value; }
		private var _warmlyProtected:Number = 0;
		
		public function get coldlyProtected():Number { return _coldlyProtected; }
		public function set coldlyProtected(value:Number):void { updateGauge("coldlyProtected", value); _coldlyProtected = value; }
		private var _coldlyProtected:Number = 0;
		
		public function get mystified():Number { return _mystified; }
		public function set mystified(value:Number):void { updateGauge("mystified", value); _mystified = value; }
		private var _mystified:Number = 0;
		
		public function get dispelled():Number { return _dispelled; }
		public function set dispelled(value:Number):void { updateGauge("dispelled", value); _dispelled = value; }
		private var _dispelled:Number = 0;
		
		public function get specialized():Number { return _specialized; }
		public function set specialized(value:Number):void { updateGauge("specialized", value); _specialized = value; }
		private var _specialized:Number = 0;
		
		public function get healing():Number { return _healing; }
		public function set healing(value:Number):void { updateGauge("healing", value); _healing = value; }
		private var _healing:Number = 0;
		
		public function get wakeful():Number { return _wakeful; }
		public function set wakeful(value:Number):void { updateGauge("wakeful", value); _wakeful = value; }
		private var _wakeful:Number = 0;
		
		//Bad Conditions	
		public function get hypnotized():Number { return _hypnotized; }
		public function set hypnotized(value:Number):void { updateGauge("hypnotized", value); _hypnotized = value; }
		private var _hypnotized:Number = 0;
		
		public function get physicalImpaired():Number { return _physicalImpaired; }
		public function set physicalImpaired(value:Number):void { updateGauge("physicalImpaired", value); _physicalImpaired = value; }
		private var _physicalImpaired:Number = 0;
		
		public function get mysticallyImpairment():Number { return _mysticallyImpairment; }
		public function set mysticallyImpairment(value:Number):void { updateGauge("mysticallyImpairment", value); _mysticallyImpairment = value; }
		private var _mysticallyImpairment:Number = 0;
		
		public function get demystified():Number { return _demystified; }
		public function set demystified(value:Number):void { updateGauge("demystified", value); _demystified = value; }
		private var _demystified:Number = 0;
		
		
		//Corruptions	
		public function get burning():Number { return _burning; }
		public function set burning(value:Number):void { updateGauge("burning", value); _burning = value; }
		private var _burning:Number = 0;
		
		public function get intoxicated():Number { return _intoxicated; }
		public function set intoxicated(value:Number):void { updateGauge("intoxicated", value); _intoxicated = value; }
		private var _intoxicated:Number = 0;
		
		public function get illuminated():Number { return _illuminated; }
		public function set illuminated(value:Number):void { updateGauge("illuminated", value); _illuminated = value; }
		private var _illuminated:Number = 0;
		
		public function get nigricaned():Number { return _nigricaned; }
		public function set nigricaned(value:Number):void { updateGauge("nigricaned", value); _nigricaned = value; }
		private var _nigricaned:Number = 0;
		
		public function get frozen():Number { return _frozen; }
		public function set frozen(value:Number):void { updateGauge("frozen", value); _frozen = value; }
		private var _frozen:Number = 0;
		
		public function get petrified():Number { return _petrified; }
		public function set petrified(value:Number):void { updateGauge("petrified", value); _petrified = value; }
		private var _petrified:Number = 0;
		
		//Neutral	
		public function get unbeatable():Number { return _unbeatable; }
		public function set unbeatable(value:Number):void { updateGauge("unbeatable", value); _unbeatable = value; }
		private var _unbeatable:Number = 0;
		
		public function get staminaDisabled():Number { return _staminaDisabled; }
		public function set staminaDisabled(value:Number):void { updateGauge("staminaDisabled", value); _staminaDisabled = value; }
		private var _staminaDisabled:Number = 0;
		
		
		/** Define the list with all natures properties in this class to be used by other methods.*/
		private function updateGauge(name:String, value:Number):void {
			if (this[name] <= 0 && value > 0) {
				aboveZero.push(StatusProperties[name]);
			}
			else if (this[name] > 0 && value <= 0) {
				i = aboveZero.indexOf(StatusProperties[name]);
				aboveZero.splice(i, 1);
			}
		}
		
		public var aboveZero:Vector.<StatusProperties> = new Vector.<StatusProperties>();
		
		public function StatusGauge() {}
		
		private var i:int;
		private var hkey:String;
		private var nGauge:StatusGauge;
		
		/** Copy values from this gauge do new one */
		public function copy():StatusGauge {
			nGauge = new StatusGauge();
			for each (hkey in StatusProperties.ALL_STATUS) {
				nGauge[hkey] = this[hkey];
			}
			return nGauge;
		}
		
		/** Add another gauge into this gauge */
		public function add(gauge2:StatusGauge = null):void {
			for each (hkey in StatusProperties.ALL_STATUS) {
				this[hkey] += gauge2[hkey]
			}
		}
		
		/** Combine another gauge with this gauge returning a new gauge */
		public function combine(gauge2:StatusGauge):StatusGauge {
			nGauge = copy();
			
			for each (hkey in StatusProperties.ALL_STATUS) {
				nGauge[hkey] += gauge2[hkey]
			}
			
			return nGauge;
		}
		
		public function toString():String {
			var message:String = "";
			var i:int = 0;
			
			for (i = 0; i < aboveZero.length; i++) {
				message += aboveZero[i].varName + ":" + this[aboveZero[i].varName].toFixed(2) + ", ";
			}
			
			return message;
			//return String("Fire:" + Fire, "Ice:" + Ice, "Water:" + Water, "Earth:" + Earth, "Air:" + Air, "Light:" + Light, "Darkness:" + Darkness, "Corruption:" + Corruption, "Bio:" + Bio, "Psionica:" + Psionica, "Physical:" + Physical);
		}
	}
}