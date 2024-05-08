package SephiusEngine.core.gameplay.status 
{
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.ISufferAttributes;
	import SephiusEngine.core.gameplay.attributes.subAttributes.NatureGauge;
	import SephiusEngine.core.gameplay.attributes.subAttributes.StatusGauge;
	import SephiusEngine.core.gameplay.damageSystem.DamageManager;
	import SephiusEngine.core.gameplay.status.interfaces.IStatus;

	import com.greensock.TweenMax;

	import tLotDClassic.GameData.Properties.StatusProperties;
	import tLotDClassic.GameData.Properties.naturesInfos.Natures;
	import tLotDClassic.gameObjects.characters.Characters;
	import tLotDClassic.gameObjects.characters.Sephius;
	
	/**
	 * This class deals with several types of status conditions, has methods to apply and remove this status
	 * Also has methods to retrive witch status are active or desactive
	 * Also call for effects for each status in case it become active.
	 * Each object that could receive status conditions should instantiatle this class
	 * @author Fernando Rabello
	 */
	public class CharacterStatus implements IStatus {
		public function get parent():Object { return _parent; }
		public function set parent(value:Object):void { _parent = value; }
		protected var _parent:Object;
		
		public function get characterParent():Characters{ return _parent as Characters; };
		
		/** Save amount of time each status has remaming to be desactivated */
		public function get times():StatusGauge {return _times; }
		public function set times(value:StatusGauge):void {_times = value;}	
		private var _times:StatusGauge = new StatusGauge();
		/** Tell how much times a corruption dealled damage in a row */
		private var damagesCounts:StatusGauge = new StatusGauge();
		/** The time to the next damage occour */
		private var damagesDelays:StatusGauge = new StatusGauge();
		
		/**Used to increase damager weight */
		public var damagerWeight:Number = 1;
		/**Used to increase suffer weight */
		public var sufferWeight:Number = 1;

		/** Status Damage is periodical. Each time new damage occour this amount will decrease. */
		public function get damageAmountRemaining():StatusGauge {return _damageAmountRemaining;}
		public function set damageAmountRemaining(value:StatusGauge):void {_damageAmountRemaining = value;}
		private var _damageAmountRemaining:StatusGauge = new StatusGauge();
		
		/** Array with all status that are activated */
		public function get activatedStatus():Vector.<StatusProperties> { return _statusConditions.aboveZero; }
		
		/** Status conditions. Determine status activeness. A status is considerated active if it value is above 0 */
		public function get statusConditions():StatusGauge {return _statusConditions;}
		public function set statusConditions(value:StatusGauge):void {_statusConditions = value;}
		private var _statusConditions:StatusGauge = new StatusGauge();
		
		/** Resitance for each status conditions. Bigger the resistance, more dificult is for get that particular status */
		public function get statusResistances():StatusGauge {return _statusResistances;}
		public function set statusResistances(value:StatusGauge):void {_statusResistances = value;}
		private var _statusResistances:StatusGauge = new StatusGauge();
		
		/** Can rise Status Resistances. This generally change during the course of the events. */
		public function get statusResistancesBuff():StatusGauge {return _statusResistancesBuff;}
		public function set statusResistancesBuff(value:StatusGauge):void { _statusResistancesBuff = value;}
		
		private var _statusResistancesBuff:StatusGauge = new StatusGauge();
		
		public static var verbose:Boolean = true;
		
		public function CharacterStatus(parent:Characters) {
			_parent = parent;
			var status:StatusProperties;
			for each (status in StatusProperties.CORRUPTIONS_CONDITIONS) {
				damagesDelays[status.varName] = status.damageFrequency;
			}
		}
		
		/**
		 * Used for dispelled status and dispell spell
		 * Remove no neutral status wicth is that ones who change character condition
		 */
		public function clearNoNeutralStatus():void {
			var condition:StatusProperties;
			for each (condition in StatusProperties.NON_NEUTRAL_CONDITIONS) {
				if (_statusConditions[condition.varName] > 0) {
					if(condition != StatusProperties.dispelled){
						if (condition.type == StatusProperties.TYPE_CORRUPTION)
							damageAmountRemaining[condition.varName] = 0;
						
						applyStatus(condition, false);
					}
				}
			}
		}
		
		/** Remove all status all together */
		public function cleanAllStatus():void {
			var condition:StatusProperties;
			for each (condition in activatedStatus) {
				if (condition.type == StatusProperties.TYPE_CORRUPTION)
					damageAmountRemaining[condition.varName] = 0;
				
				applyStatus(condition, false);
			}
		}
		
		/**
		 * Apply a status effect for some time
		 * @param	statusName witch status should be changed
		 * @param	on should activate or desactivate?
		 * @param	time time witch the status remain active. put time to -1 to activate indefinely.
		 * @param	effectsOn if effect should activate a effect
		 */
		public function applyStatus(statusProperty:StatusProperties, on:Boolean, effectsOn:Boolean = true):void {
			//If character is immune or if status is false and order is to disable the status
			if (_statusConditions[statusProperty.varName] == -1)
				return;
			
			log("[CHARACER STATUS] applystatus:" + statusProperty.varName + "-" + Boolean(_statusConditions[statusProperty.varName]) + " time:" + statusProperty.time + " to activate:" + on + " type " + statusProperty.type);
			
			if (effectsOn && characterParent.characterAttributes.effects && statusProperty.filterParams)
				characterParent.characterAttributes.effects.applyStatusEffects(on, statusProperty);
				
			if(this[statusProperty.varName + "Aftermath"])
				this[statusProperty.varName + "Aftermath"](on);
			else
				throw Error("There is no Aftermath function for Status with object base name: " + statusProperty.varName + "Aftermath");
			
			times[statusProperty.varName] = !on ? 0 : statusProperty.time;
			
			_statusConditions[statusProperty.varName] = on;
			
			if (on && statusProperty.type == StatusProperties.TYPE_CORRUPTION) {
				damagesCounts[statusProperty.varName] = 0;
			}
			
			if (characterParent as Sephius) {
				(characterParent as Sephius).hud.setStatus(_statusConditions.aboveZero); 
			}
		}
		
		private var statusRaiseRatio:Number = 1;
		/** Rise a Satus Gauge by some ammount */
		public function riseStatus(statusProperty:StatusProperties, curruptionPower:Number):void {
			times[statusProperty.varName] += curruptionPower * statusRaiseRatio * statusProperty.time;
			
			if (times[statusProperty.varName] >= statusProperty.time){
				applyStatus(statusProperty, true);
				times[statusProperty.varName] = statusProperty.time;
			}
		}
		
		/** Rise a Corruption Damage by some ammount */
		public function riseCorruption(statusProperty:StatusProperties, corruptionPower:Number):void {
			//var statusPowerRatio:Number = AttributesConstants.statusPowerRatio;
			damageAmountRemaining[statusProperty.varName] += corruptionPower;
		}
		
		private var index:int;
		private var currentCurrentDamage:Number;
		private var cStatus:StatusProperties;
		/** Deal with periodical damage from corruption conditions */
		public function update(timeDelta:Number):void {
			for each (cStatus in times.aboveZero) {
				times[cStatus.varName] -= timeDelta;
				
				/** If status is active, update damages or verify if time has reach zero */
				if (cStatus.type == StatusProperties.TYPE_CORRUPTION) {
					damagesDelays[cStatus.varName] -= timeDelta;
					
					if (damagesDelays[cStatus.varName] <= 0) {
						damagesCounts[cStatus.varName]++;
						damagesDelays[cStatus.varName] = cStatus.damageFrequency;
						
						//var timeComponent:Number = 1 + Math.sin((Math.PI * times[cStatus.varName]) / cStatus.time);
						var timeComponent:Number = 1 - (times[cStatus.varName] / cStatus.time);
						
						//var countComponent:Number = damageAmountRemaining[cStatus.varName] * damagesCounts[cStatus.varName];//Increase damage on each count. Reduce as remaining gets lower.

						currentCurrentDamage = Math.ceil(damageAmountRemaining[cStatus.varName] * timeComponent);

						damageAmountRemaining[cStatus.varName] -= currentCurrentDamage;
						
						log(" remaining: " + damageAmountRemaining[cStatus.varName] + " count: " + damagesCounts[cStatus.varName] + " power:" + currentCurrentDamage + " time: " + times[cStatus.varName]); 
						
						if(_statusConditions[cStatus.varName] > 0)
							DamageManager.getDamageManager().corruptionConditionDamage(characterParent.attributes as ISufferAttributes, currentCurrentDamage, cStatus.nature);
					}
				}
				
				if ((times[cStatus.varName] <= 0 || (cStatus.type == StatusProperties.TYPE_CORRUPTION && damageAmountRemaining[cStatus.varName] <= 0)) && _statusConditions[cStatus.varName] == true){
					applyStatus(cStatus, false);
					if (cStatus.type == StatusProperties.TYPE_CORRUPTION) {
						damagesCounts[cStatus.varName] = 0;
						damageAmountRemaining[cStatus.varName] = 0;
					}
				}
			}
			cStatus = null;
		}
		
		public function damagedAftermath(value:Boolean):void {}
		public function healedAftermath(value:Boolean):void {}
		public function LightEmbeddedAftermath(value:Boolean):void {}
		public function DarkEmbeddedAftermath(value:Boolean):void {}
		public function MestizoEmbeddedAftermath(value:Boolean):void {}
		public function noneEmbeddedAftermath(value:Boolean):void {}
		public function defenceDamagedAftermath(value:Boolean):void {}
		public function defenceHealedAftermath(value:Boolean):void {}
		public function damageInvunerableAftermath(value:Boolean):void {}
		public function unbeatableAftermath(value:Boolean):void {}
		public function defenceDisabledAftermath(value:Boolean):void { }
		
		public function burningAftermath(value:Boolean):void {}
		public function intoxicatedAftermath(value:Boolean):void {}
		public function illuminatedAftermath(value:Boolean):void {}
		public function nigricanedAftermath(value:Boolean):void {}
		
		public function wakefulAftermath(value:Boolean):void {}

		public function hypnotizedAftermath(value:Boolean):void {
			if (_statusConditions.hypnotized == -1)
				return;
			if (value == true && _statusConditions.hypnotized == false)
				characterParent.characterAttributes.hypnotic = true;
			else if (value == false && _statusConditions.hypnotized == true)
				characterParent.characterAttributes.hypnotic = false;
		}
		
		public function amplifiedAftermath(value:Boolean):void{
			if (_statusConditions.amplified == -1)
				return;
			if (value == true && _statusConditions.amplified == false) {
				characterParent.characterAttributes.strengthBuff += characterParent.characterAttributes.strength;
				characterParent.characterAttributes.efficiencyBuff += characterParent.characterAttributes.baseEfficiency;
				damagerWeight = 1.5;
			}else if (value == false && _statusConditions.amplified == true){
				characterParent.characterAttributes.strengthBuff -= characterParent.characterAttributes.strength;
				characterParent.characterAttributes.efficiencyBuff -= characterParent.characterAttributes.baseEfficiency;
				damagerWeight = 1.0;
			}
		}

		private var piImunGaugeOn:NatureGauge = new NatureGauge({Physical:-50});
		private var piImunGaugeOff:NatureGauge = new NatureGauge({Physical:50});
		/** Reduce Peripheral Essence to half of normal value */
		public function physicalImpairedAftermath(value:Boolean):void{
			if (_statusConditions.physicalImpaired == -1)
				return;
			if (value == true && _statusConditions.physicalImpaired == false){
				characterParent.characterAttributes.maxPeripheralEssence = characterParent.characterAttributes.maxPeripheralEssence * 0.5;
				//characterParent.characterAttributes.AddImmunities(piImunGaugeOn);
			}
			else if (value == false && _statusConditions.physicalImpaired == true){
				characterParent.characterAttributes.maxPeripheralEssence = -1;
				//characterParent.characterAttributes.AddImmunities(piImunGaugeOff);
			}
		}

		private var petrifiedImunGaugeOn:NatureGauge = new NatureGauge({Physical:50});
		private var petrifiedImunGaugeOff:NatureGauge = new NatureGauge({Physical:-50});
		public function petrifiedAftermath(value:Boolean):void{
			if (_statusConditions.petrified == -1)
				return;
			if (value == true && _statusConditions.petrified == false){
				characterParent.characterAttributes.AddImmunities(petrifiedImunGaugeOn);
				sufferWeight = 5;
				characterParent.mainShape.material.density = characterParent.characterProperties.physics.density * 3;
			}
			else if (value == false && _statusConditions.petrified == true){
				characterParent.characterAttributes.AddImmunities(petrifiedImunGaugeOff);
				sufferWeight = 1;
				characterParent.mainShape.material.density = characterParent.characterProperties.physics.density;
			}
		}
		
		private var frozenImunGaugeOn:NatureGauge = new NatureGauge({Fire:97, Air:90, Physical:-50});
		private var frozenImunGaugeOff:NatureGauge = new NatureGauge({Fire:-97, Air:-90, Physical:50});
		public function frozenAftermath(value:Boolean):void{
			if (_statusConditions.frozen == -1)
				return;
			if (value == true && _statusConditions.frozen == false){
				characterParent.canMove = false;
				characterParent.characterAttributes.AddImmunities(frozenImunGaugeOn);
				_statusResistances.burning += 100;
				_statusResistancesBuff.burning += 100;
			}
			else if (value == false && _statusConditions.frozen == true){
				characterParent.canMove = true;
				characterParent.characterAttributes.AddImmunities(frozenImunGaugeOff);
				_statusResistances.burning -= 100;
				_statusResistancesBuff.burning -= 100;
			}
		}
		
		public function demystifiedAftermath(value:Boolean):void {
			if (_statusConditions.demystified == -1)
				return;
			if (value == true && _statusConditions.demystified == false) {
				characterParent.characterAttributes.mysticalEssence = 1;
				characterParent.characterAttributes.maxMysticalEssence = 1;
				if (characterParent as Sephius) {
					(characterParent as Sephius).hud.mE = characterParent.characterAttributes.mysticalEssence;
				}
			}
			else if (value == false && _statusConditions.demystified == true){
				characterParent.characterAttributes.maxMysticalEssence = -1;
			}
		}
		
		public function mystifiedAftermath(value:Boolean):void {
			if (_statusConditions.mystified == -1)
				return;
			if (value == true && _statusConditions.mystified == false) {
				characterParent.characterAttributes.mysticalConsumeFactor *= 0.5;
			}
			else if (value == false && _statusConditions.mystified == true) {
				characterParent.characterAttributes.mysticalConsumeFactor *= 2;
			}
		}

		private var miImunGaugeOn:NatureGauge = new NatureGauge({Fire:-80, Ice:-80, Light:-80, Darkness:-80, Water:-80, Earth:-80, Bio:-80, Corruption:-80, Air:-80});
		private var miImunGaugeOff:NatureGauge = new NatureGauge({Fire:80, Ice:80, Light:80, Darkness:80, Water:80, Earth:80, Bio:80, Corruption:80, Air:80});
		public function mysticallyImpairmentAftermath(value:Boolean):void {
			if (_statusConditions.mysticallyImpairment == -1)
				return;

			if (value == true && _statusConditions.mysticallyImpairment == false) {
				characterParent.characterAttributes.AddImmunities(miImunGaugeOn);	
			}
			else if (value == false && _statusConditions.mysticallyImpairment == true) {
				characterParent.characterAttributes.AddImmunities(miImunGaugeOff);	
			}
		}

		private var ppImunGaugeOn:NatureGauge = new NatureGauge({Physical:50});
		private var ppImunGaugeOff:NatureGauge = new NatureGauge({Physical:-50});
		public function physicallyProtectedAftermath(value:Boolean):void {
			if (_statusConditions.physicallyProtected == -1)
				return;
			if (value == true && _statusConditions.physicallyProtected == false) {
				characterParent.characterAttributes.AddImmunities(ppImunGaugeOn);
			}
			else if (value == false && _statusConditions.physicallyProtected == true) {
				characterParent.characterAttributes.AddImmunities(ppImunGaugeOff);
			}
		}
		
		private var wpImunGaugeOn:NatureGauge = new NatureGauge({Ice:100, Air:100});
		private var wpImunGaugeOff:NatureGauge = new NatureGauge({Ice:-100, Air:-100});
		public function warmlyProtectedAftermath(value:Boolean):void {
			if (_statusConditions.warmlyProtected == -1)
				return;
			if (value == true && _statusConditions.warmlyProtected == false) {
				characterParent.characterAttributes.AddImmunities(wpImunGaugeOn);
				_statusResistances.frozen += 70;
				_statusResistancesBuff.frozen += 70;
			}
			else if (value == false && _statusConditions.warmlyProtected == true) {
				characterParent.characterAttributes.AddImmunities(wpImunGaugeOff);
				_statusResistances.frozen -= 70;
				_statusResistancesBuff.frozen -= 70;
			}
		}

		private var cpImunGaugeOn:NatureGauge = new NatureGauge({Fire:95, Air:100});
		private var cpImunGaugeOff:NatureGauge = new NatureGauge({Fire:-95, Air:-100});
		public function coldlyProtectedAftermath(value:Boolean):void {
			if (_statusConditions.coldlyProtected == -1)
				return;
			if (value == true && _statusConditions.coldlyProtected == false) {
				characterParent.characterAttributes.AddImmunities(cpImunGaugeOn);
				_statusResistances.burning += 70;
				_statusResistancesBuff.burning += 70;
			}
			else if (value == false && _statusConditions.coldlyProtected == true) {
				characterParent.characterAttributes.AddImmunities(cpImunGaugeOff);
				_statusResistances.burning -= 70;
				_statusResistancesBuff.burning -= 70;
			}
		}
		
		public function dispelledAftermath(value:Boolean):void {
			if (_statusConditions.dispelled == -1)
				return;
			if (value == true) {
				clearNoNeutralStatus();
			}
		}
		
		public function specializedAftermath(value:Boolean):void {
			if (_statusConditions.specialized == -1)
				return;
			if (value == true && _statusConditions.specialized == false) {

			}
			else if (value == false && _statusConditions.specialized == true) {

			}
		}

		private var mpImunGaugeOn:NatureGauge = new NatureGauge({Fire:80, Ice:80, Light:80, Darkness:80, Water:80, Earth:80, Bio:80, Corruption:80, Air:80});
		private var mpImunGaugeOff:NatureGauge = new NatureGauge({Fire:-80, Ice:-80, Light:-80, Darkness:-80, Water:-80, Earth:-80, Bio:-80, Corruption:-80, Air:-80});
		public function mysticallyProtectedAftermath(value:Boolean):void {
			if (_statusConditions.mysticallyProtected == -1)
				return;
			
			if (value == true && _statusConditions.mysticallyProtected == false) {
				characterParent.characterAttributes.AddImmunities(mpImunGaugeOn);	
			}
			else if (value == false && _statusConditions.mysticallyProtected == true) {
				characterParent.characterAttributes.AddImmunities(mpImunGaugeOff);	
			}
		}
		
		public function healingAftermath(value:Boolean):void {
			if (_statusConditions.healing == -1)
				return;
			if (value == true) {
				characterParent.characterAttributes.restorePeripheralEssence((characterParent.characterAttributes.maxPeripheralEssence * .5) * (1 - characterParent.characterProperties.staticAttributes.natureResistances[Natures.Bio]));
			}
		}
		
        private static function log(message:String):void {
            if (verbose) trace("[CHARACER STATUS]:", message);
        }
		
		public function dispose():void {
			_parent = null;
			times = null;
			damagesCounts = null;
			damagesDelays = null;
			damageAmountRemaining = null;
			TweenMax.killTweensOf(applyStatus);
		}
	}
}