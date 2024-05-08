package SephiusEngine.core.gameplay.damageSystem {
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.IDamagerAttributes;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.IDefenderAttributes;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.IMortalAttributes;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.IMysticalAttributes;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.IPeripheralAttributes;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.IStatusAttributes;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.ISufferAttributes;
	import SephiusEngine.core.gameplay.attributes.subAttributes.DamagerAttibutes;
	import SephiusEngine.core.gameplay.attributes.subAttributes.SufferAttributes;
	import SephiusEngine.levelObjects.interfaces.IDamagerObject;
	import SephiusEngine.levelObjects.interfaces.ISufferObject;
	import SephiusEngine.math.MathVector;
	import SephiusEngine.utils.AppInfo;

	import nape.geom.Vec2;

	import starling.utils.deg2rad;
	import starling.utils.rad2deg;

	import tLotDClassic.GameData.Properties.StatusProperties;
	import tLotDClassic.GameData.Properties.naturesInfos.Natures;
	import tLotDClassic.GameData.Properties.objectsInfos.GameObjectGroups;
	import tLotDClassic.attributes.AttributesConstants;
	import tLotDClassic.gameObjects.damagers.Projectile;
	import tLotDClassic.gameObjects.spells.Spell;
	/**
	 * A Damage object with information and calculations about a damage event.
	 * @author Fernando Rabello
	 */
	public class DamageManager {
		/** Return DamageManager object. There can be only 1 damage manager running */
		public static function getDamageManager():DamageManager {
			if (!instance){
				instance = new DamageManager(new PrivateClass());
				instance.sufferForce = Vec2.get(0, 0);
				instance.damagerForce = Vec2.get(0, 0);
			}
			
			return instance;
		}
		
		/** Who is giving the damage */
		public var damagerAttribute:DamagerAttibutes;
		public var damagerObject:IDamagerObject;

		/** The objects contextually responsable by the damage. In cases for spells and projecticles who normally is casted/shooted by other object, use this property to identify them */
		public var damagerResponsible:*;
		
		/** Who is receiving the damage */
		public var sufferAttribute:SufferAttributes;
		public var sufferObject:ISufferObject;

		/** critical, normal, weak, absorb or strong.*/
		public var outcome:String = "normal";
		
		/** Tells if character has defended the damage */
		public var defended:Boolean; 
		
		/** Attack, Body, DamageObject, Corruption Status, Fall, Spell */
		public var origin:String;
		
		/** The position in level coordinate where the damage happens */
		public var originLocation:MathVector;
		
		/**
		 * Damage must have at leat 1 naturePower. Multiple natures powers are accumulated in the final damage.
		 * Each natures and naturesPowers need to have same amount of entries.
		 */
		public var naturesPowers:Vector.<Number> = new Vector.<Number>();
		
		/**  Damage must have at least 1 nature Physical, Fire, Ice, Water, Earth, Air, Light, Dark, Corruption, Bio, Psionica.*/
		public var natures:Vector.<String> = new Vector.<String>();
		
		/** Witch nature was stronger and then dominant in the damage. Used to determine splash effect.*/
		public var natureDominance:String = "";
		
		/** Combination of all naturesPowers.*/
		public var totalPower:int = 0;
		
		/** Final corruption power, related with status damage.*/
		public var totalCorruptionPower:int = 0;
		
		/** If the damage amount was greater than the suffer peripheral essence.*/
		public var overDamage:Boolean = false;
		
		/** If the damage amount was greater than the defence resistance.*/
		public var overDefence:Boolean = false;
		
		/** If the damage was from front or back of the suffer.*/
		public var bias:int = 1;
		
		/** If damage from the front of suffer or back */
		public var frontSide:Boolean;
		
		/** The final direction of the damage */
		public var direction:Number = 0;
		public function get directionDeg():Number { return rad2deg(direction); }
		/** The opisite direction of the damage */
		public var oppositeDirection:Number = 0;
		public function get oppositeDirectionDeg():Number { return rad2deg(oppositeDirection); }
		
		/** Determine the time suffer will stay on hurt state */
		public var hurtTime:Number = 1;
		
		private static var instance:DamageManager;
		public var verbose:Boolean = false;
		
		public function DamageManager(pvt:PrivateClass) {}
		
		/**Determine how much suffer will be repelled */
		public var sufferForceIntensity:Number;
		
		/**Determine how much damager will be repelled */
		public var damagerForceIntensity:int;
		
		/**Adjust how much damager will be repelled */
		/**Force aplied when suffer damage. It´s intensity and direction chages depending of the damager factors.*/
		public var sufferForce:Vec2;
		
		/**Force aplied when damager damage. It´s intensity and direction chages depending of the damager factors.*/
		public var damagerForce:Vec2;
		
		public var sufferWillReact:Boolean = true;
		public var damagerWillReact:Boolean = true;
		
		/** Determine critical hits */
		public var efficiencyRatio:Number = 1;
		/** Used to randomize critical hits */
		public var randomizedEfficiencyRatio:Number = 1;
		public var efficiencyRatioVariance:Number = .3;
		
		/** Determine some damage results like impulse force, suffer reaction */
		public var weightRatio:Number = 1;
		/** Used to randomize suffer reaction */
		public var randomizedWeightRatio:Number = 1;

		/** Attributes that can hold multiple Damagers Attribues and be have other information not related with damage
		 * Here is casted as IDamagerAttribures can store information to be shared between all DamagerAttribues
		 */
		public var damagerHolderAttributes:IDamagerAttributes;
		/** Attributes that can hold multiple Suffer Attribues and be have other information not related with damage
		 * Here is casted as ISufferAttribures can store information to be shared between all SufferAttribues
		 */
		public var sufferHolderAttributes:ISufferAttributes;

		/** Return suffer attribute if implements IPeripheralAttributes. Otherwise it will be null */
		public var sPeripheralA:IPeripheralAttributes;
		/** Return suffer attribute if implements IMortalAttributes. Otherwise it will be null */
		public var sMortalA:IMortalAttributes;
		/** Return suffer attribute if implements IMysticalAttributes. Otherwise it will be null */
		public var sMysticalpA:IMysticalAttributes;
		/** Return suffer attribute if implements IStatusAttributes. Otherwise it will be null */
		public var sStatusA:IStatusAttributes;
		/** Return suffer attribute if implements IDefenderAttributes. Otherwise it will be null */
		public var sDefenderA:IDefenderAttributes;
		
		// -------------------------------------------------------//
		//------------------ Damage Calculators   ----------------//
		//--------------------------------------------------------//
		private var remainingDamage:int;
		private var consumeResult:int;
		private var cStatusNameSting:StatusProperties;
		
		private var randomFinal:Number = 1;
		private var sRandomSeed:Number = 1;
		private var randomVariance:Number = 1;
		
		public var randomRatio:Number = Math.random();
		public var randomRatio2:Number = Math.random();
		
		private var powerOngoing:Number;
		
		public var staminaToConsume:Number;
		private var showDamageOnHUD:Boolean;

		private var directionImpulseBias:Boolean;
		private var baseDirection:Number;
		private var baseOppositeDirection:Number;

		/** Generalistic damage processor. Process a damage event from a damager attributes to a suffer attributes */
		public function processDamage(damager:DamagerAttibutes, suffer:SufferAttributes, origin:String, originLocation:MathVector):void {
			//resets Damamge values for new calculation
      		resetDamage(damager, suffer, origin, originLocation);
			
			damagerResponsible = damager.holder.damagerParent as Spell ? (damager.holder.damagerParent as Spell).caster : null;
			if (!damagerResponsible)
				damagerResponsible = damager.holder.damagerParent as Projectile ? (damager.holder.damagerParent as Projectile).launcher : null;
			if (!damagerResponsible)
				damagerResponsible = damager.holder.damagerParent;
			
			if(sDefenderA)
				defended = sDefenderA.defending && frontSide && damager.denfensable;
			
			randomRatio = (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);//-0.5 to 0.5
			randomRatio2 = (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x80000000));//0 to 1
			
			weightRatio = (damager.weight / suffer.weight);
			randomizedWeightRatio = weightRatio + (weightRatio * AttributesConstants.weightRatioVariance * randomRatio);
			
			if(damager.criticable && suffer.criticable)
				efficiencyRatio = damager.holder.efficiency / suffer.holder.efficiency;
			else 
				efficiencyRatio = 0.0001;
			
			randomizedEfficiencyRatio = efficiencyRatio / (efficiencyRatio + AttributesConstants.criticalAdjust);
			outcome = randomRatio2 > (1 - randomizedEfficiencyRatio) ? "critical" : randomizedWeightRatio > AttributesConstants.strongDamageRatio ? "strong" : "normal";
			
			//trace("Critical Ratio: " + weightRatio, " / Critical Final: " + randomizedEfficiencyRatio + " / RamdomN:" + randomRatio2);
			
			if(damager.natures.aboveZero.length == 0){
				trace("Damager has no damage Natures!!!");
				return;
			}
				
			natures = damager.natures.aboveZero.concat();
			
			natureDominance = natures[0];
			
			var i:int;
			//For each damager nature (physical, fire, ice and etc) make damage calculations.
			for (i = 0; i < natures.length; i++) {
				if (Natures.ALL_NATURES.indexOf(natures[i]) == -1)
					throw Error ("Nature " + natures[i] + " does not exist" + " - Use one of follow natures:" + Natures.ALL_NATURES);
				
				powerOngoing = damager.intensity * damager.amplification * damager.natures[natures[i]] * (outcome == "critical" ? AttributesConstants.criticalDamageBonus : 1);
				damager.damageDealtPotential += powerOngoing;
				
				naturesPowers.push(0);
				
				// Shield absorbing nature damage
				if (sDefenderA) {
					if (defended && sDefenderA.defenceResistanceNatures[natures[i]]) {
						staminaToConsume = AttributesConstants.staminaBase * AttributesConstants.staminaDamageConsunption * weightRatio;
						remainingDamage	= sDefenderA.consumeStamina(staminaToConsume, 1);
						
						if(remainingDamage < 1)
							naturesPowers[i] = powerOngoing * ((1 - (sDefenderA.defenceResistanceNatures[natures[i]] * .01)) * (1 - remainingDamage));
						else
							naturesPowers[i] = powerOngoing;
						
						overDefence = remainingDamage > 0 ? true : false;
					}
					else {
						naturesPowers[i] = powerOngoing;
					}
				}
				else {
					naturesPowers[i] = powerOngoing;
				}
				
				naturesPowers[i] *= (1 - (suffer.natureImmunity[natures[i]] * .01));
				
				//Tell witch nature was stronger. Strongest nature is one factor to determine damage splash
				if (i > 0 && Math.abs(naturesPowers[i]) > Math.abs(naturesPowers[i - 1]))
					natureDominance = natures[i];
				
				//Nature powers are combining to determine the final damage power
				totalPower += naturesPowers[i];
				
				if(verbose && damager.showZeroDamage)
					log("Roll"+ i + " Nature: " + natures[i] + " Power:" + naturesPowers[i] + " Accumulative Power:" + totalPower);
			}
			
			if (GameObjectGroups.hasGroup(damager.nerfGroupFlag, suffer.groupFlag) || damagerHolderAttributes.nerfedSuffers.indexOf(sufferObject) != -1) {
				totalPower *= damager.nerfRatio;
			}
			
			damager.damageDealt += totalPower;
			suffer.damageTaken += totalPower;
			
			//Verify if was a weak or powerfull damage. Used in the suffer hurt logic. Weak is a damage that consume to liitle essence. Powefull is the one witch consume a lot of essence
			if(sPeripheralA){
				//outcome = totalPower < (sPeripheralA.peripheralEssence * sPeripheralA.weakDamagePercent) ? "weak" : totalPower > (sPeripheralA.maxPeripheralEssence * AttributesConstants.powerfullDamageRatio) ? "powerfull" : outcome;
				
				showDamageOnHUD = (damagerResponsible == GameEngine.instance.state.player1 || damagerResponsible == GameEngine.instance.state.player2) || (suffer.holder.sufferParent == GameEngine.instance.state.player1 || suffer.holder.sufferParent == GameEngine.instance.state.player2);
				
				consumeResult = sPeripheralA.consumePeripheralEssence(totalPower, showDamageOnHUD);
				// consume peripheral essence will return 0 if there was no change on the damage. Meaning damage was meaningless in term of changind perpheeral essence
				if (consumeResult == -1)	
					overDamage = true;
				else if  (consumeResult == 0){
					//outcome = "null";
					if (!damager.showZeroDamage)
						return;
				}
			}
			else if ((totalPower == 0) && !damager.showZeroDamage){
				return;
			}
			//If damage was critical call for a critical effect
			if (outcome == "critical")
				GameEngine.instance.state.globalEffects.criticalEffect();
							
			if(verbose)
				log("Result:" + " / origin:" + origin + " / outcome:" + outcome + " / natureDominance:" + natureDominance + " / totalPower:" + totalPower + " / natures:" + natures.length + " / overDamage:" + overDamage + " / overDefence:" + overDefence + " / bias:" + bias + " / frontSide:" + frontSide);
			
			hurtTime = (outcome == "critical" || outcome == "powerfull") ? AttributesConstants.powerfullHurtTime : outcome == "strong" ? AttributesConstants.strongHurtTime : outcome == "weak" ? AttributesConstants.weakHurtTime : outcome == "null" ? 0 : AttributesConstants.normalHurtTime;
			
			damagerWillReact = defended && !overDefence && randomizedWeightRatio < AttributesConstants.strongDamageRatio;			
			
			// ----------- Damage Ractions -------------- /
			//Complex decision if creature will entrer on damage animation or not
			sufferWillReact = true;
			//Damage is powerfull or strong ? If so, its true, damage is normal or weak ? then is false, if is none of that then is default
			if(!defended)
				sufferWillReact = ((outcome == "powerfull" || outcome == "strong")) ? true : ((outcome == "weak" || outcome == "normal" || outcome == "null")) ? false : sufferWillReact;
			else
				sufferWillReact = randomizedWeightRatio > AttributesConstants.strongDamageRatio;
				
				//Creature is weak ? If is then is will react, if not maintain value.
				//sufferWillReact = (suffer.characterProperties.behavior.weak && outcome != "weak") ? true : sufferWillReact;
				//Damage outcome is critical ? If is then it will react if not maintain value.
				//sufferWillReact = outcome == "critical" ? true : sufferWillReact;
			//It was a overdamage (damage amount greater than remaning essence) ? If was then is true, if not maintain value.
			sufferWillReact = (overDamage || overDefence) ? true : sufferWillReact;
				//If was a corruption damage (periodical damage from status condition) ? If is then is false, if not maintain value.
				//sufferWillReact = outcome == "corruption" ? false : sufferWillReact;
			// If damage was equal to 0
			//sufferWillReact = (totalPower == 0) ? false : sufferWillReact;
			//It has defended the damage
			//sufferWillReact = defended ? true : sufferWillReact;
			
			//Why Allow Invunerable here?
			if (sStatusA && damager.allowInvunerable) {
				//Creature is frozen ? If is then it will not react, if not maintain value.
				sufferWillReact = (sStatusA.status.statusConditions.frozen == true) ? false : sufferWillReact;
				
				if(totalPower >= 0) {
					if (suffer.damageTakenConstrainedByTime && outcome != "weak" && (totalPower > 0 || defended))
						sStatusA.status.applyStatus(StatusProperties.damageInvunerable, true);
					else
						if (defended)
							sStatusA.status.applyStatus(StatusProperties.defenceDamaged, true);
						else
							sStatusA.status.applyStatus(StatusProperties.damaged, true);
				}
				else if (totalPower < 0) { 
					if (defended)
						sStatusA.status.applyStatus(StatusProperties.defenceHealed, true);
					else
						sStatusA.status.applyStatus(StatusProperties.healed, true);
				}
				
				
				if (damager.corruptionStatus.aboveZero.length > 0) {
					for (i = 0; i < damager.corruptionStatus.aboveZero.length; i++) {
						cStatusNameSting = damager.corruptionStatus.aboveZero[i];
						processStatus(damager.corruptionStatus.aboveZero[i], sStatusA, damager.corruptionStatus[cStatusNameSting.varName]);
					}
				}
			}
			
			// Define damage direction:
			// -1: Absolute direction
			//  0: Relative to damager's facing direction
			//  1: Relative to damage bias
			//  2: Relative to damager's rotation
			//  3: Relative to damager's rotation but considering damage bias
			//  4: Array to damager object location
			//  5: Array to damage point location

			// Common calculation for base directions
			baseDirection = deg2rad(damager.pullDirection);
			baseOppositeDirection = deg2rad(180 - (damager.pullDirection + (damager.pullDirection < 0 ? 360 : 0)));

			//Fix for Level Damage Collision rotations. Because LDC has their shapes combined into 1 object so we need to get rotation from value stored earlier.
			var rotation:Number = damagerAttribute.contactShape ? damagerAttribute.contactShape.userData.rotation : 0;

			switch(damager.pullTypeID) {
				case -1:
					direction = baseDirection;
					oppositeDirection = baseOppositeDirection;
					break;

				case 0:
  					direction = !damagerObject.inverted ? baseDirection : baseOppositeDirection;
					oppositeDirection = damagerObject.inverted ? baseDirection : baseOppositeDirection;
					break;

				case 1:
					direction = bias > 0 ? baseDirection : baseOppositeDirection;
					oppositeDirection = bias < 0 ? baseDirection : baseOppositeDirection;
					break;

				case 2:
					direction = baseDirection + damager.holder.damagerParent.rotationRad + rotation;
 					oppositeDirection = baseOppositeDirection - damager.holder.damagerParent.rotationRad - rotation;
					break;

				case 3:
					direction = !damagerObject.inverted ? baseDirection : baseOppositeDirection;
					oppositeDirection = damagerObject.inverted ? baseDirection : baseOppositeDirection;

					direction += damager.holder.damagerParent.rotationRad + rotation;
					oppositeDirection -= damager.holder.damagerParent.rotationRad + rotation;
					break;

				case 4:
					baseDirection = pointDirection(suffer.holder.sufferParent.x, suffer.holder.sufferParent.y, damager.holder.damagerParent.x, damager.holder.damagerParent.y) - deg2rad(180);
					baseOppositeDirection = pointDirection(damager.holder.damagerParent.x, damager.holder.damagerParent.y, suffer.holder.sufferParent.x, suffer.holder.sufferParent.y) - deg2rad(180);
					break;

				case 5:
					baseDirection = pointDirection(suffer.holder.sufferParent.x, suffer.holder.sufferParent.y, originLocation.x, originLocation.y) - deg2rad(180);
					baseOppositeDirection = pointDirection(damager.holder.damagerParent.x, damager.holder.damagerParent.y, suffer.holder.sufferParent.x, suffer.holder.sufferParent.y) - deg2rad(180);
					break;
			}
			
			if(sufferWillReact) {
				sufferForceIntensity = AttributesConstants.globalSufferDamageImpulse;
				//trace("DAMAGEMANAGER sufferForceIntensity:", AttributesConstants.globalSufferDamageImpulse);
				sufferForceIntensity *= (outcome == "critical") ? AttributesConstants.globalCriticalImpulseRatio : outcome == "weak" ? AttributesConstants.globalWeakImpulseRatio : 1;
				//trace("DAMAGEMANAGER outcome Invigo:", (outcome == "critical") ? AttributesConstants.globalCriticalImpulseRatio : outcome == "weak" ? AttributesConstants.globalWeakImpulseRatio : 1);
				sufferForceIntensity *= 1 + (randomizedWeightRatio * AttributesConstants.globalWeightRatioImpulseRatio * sufferForceIntensity);
				//trace("DAMAGEMANAGER wight Invigo:", 1 + (randomizedWeightRatio * AttributesConstants.globalWeightRatioImpulseRatio * sufferForceIntensity));
				sufferForceIntensity *= damager.attackImpulseIntensity;
				sufferForce.setxy(1, 0);
				sufferForce.length = sufferForceIntensity * suffer.holder.sufferParent.mass;
				//trace("DAMAGEMANAGER mass Invigo:", suffer.holder.sufferParent.mass);
				sufferForce.angle = direction;
				
				if(isNaN(sufferForce.x) || isNaN(sufferForce.x))
					if(AppInfo.isDebugBuild)
						throw Error("sufferForce has NaN");

				suffer.holder.sufferParent.applyConstrainedImpulse(sufferForce);
				suffer.holder.sufferParent.sufferReaction(this);
				
				//if (rad2deg(sufferForce.angle) < 10)
					//trace("qhat is this?");
				//trace("DAMAGEMANAGER damage impulse applied", suffer.holder.name, " sufferForceI:", sufferForceIntensity, " sufferForceLength:", sufferForce.length, " angle:", rad2deg(sufferForce.angle), " mass:" + suffer.holder.sufferParent.mass);
				
				//if (sufferForce.length == 0 || sufferForce.length > 3000)
					//trace("DAMAGEMANAGER damage impulse applied", suffer.holder.name, " sufferForceI:", sufferForceIntensity, " sufferForceLength:", sufferForce.length, " angle:", rad2deg(sufferForce.angle), " mass:" + suffer.holder.sufferParent.mass);
				
				//sufferWillReact = false;
			}
			
			if (damagerWillReact) {
				damagerForceIntensity =  AttributesConstants.globalDamagerDamagerImpulse; //350 -> valor antigo.
				damagerForce.setxy(1, 0);
				damagerForce.length = damagerForceIntensity * damager.holder.damagerParent.mass;
				damagerForce.angle = oppositeDirection;
				damager.holder.damagerParent.applyConstrainedImpulse(damagerForce);
				damager.holder.damagerParent.damagerReaction(this);
			}
			
			suffer.holder.sufferParent.sufferSecundaryReaction(this);
			//call suffer hit logic method passing this damage informations
			damager.holder.damagerParent.damagerSecundaryReaction(this);
			
			//Determine and call splash effect for this damage
			if (natureDominance == Natures.Physical)
				GameEngine.instance.state.globalEffects.defineSplashByDefaultDamage(this, (!damager.hideDamageArt && !suffer.hideDamageArt), (!damager.hideDamageValue && !suffer.hideDamageValue));
			else
				GameEngine.instance.state.globalEffects.defineSplashByDamageNatureDominance(this, (!damager.hideDamageArt && !suffer.hideDamageArt), (!damager.hideDamageValue && !suffer.hideDamageValue));
			
			/** null refs */
			nullDamage();
		}
		
		public function processStatus(status:StatusProperties, suffer:IStatusAttributes, corruptionPower:Number):void {
			corruptionPower *= 1 - (suffer.status.statusResistances[status.varName] * .1);
			
			if (corruptionPower > 0) {
				suffer.status.riseStatus(status, corruptionPower);
				
				if(suffer.status && status.type == StatusProperties.TYPE_CORRUPTION)
					suffer.status.riseCorruption(status, corruptionPower * status.getStatusPower());
			}
		}
		
		/**
		 *	Determine and subtract Peripheral Essence when character take damage from Damage Objetct like spikes and lava.
		 * 	Used both for Player and Enemies
		 */
		public function defineAmountOfFallDamage(suffer:SufferAttributes, impact:Number, normalAnlge:Number, impactLocation:Vec2):void {
			resetDamage(null, suffer, "Fall", new MathVector(impactLocation.x, impactLocation.y));
			
			sPeripheralA = suffer.holder as IPeripheralAttributes;

			//Verify if was a weak or powerfull damage. Used in the suffer hurt logic. Weak is a damage that consume to liitle essence. Powefull is the one witch consume a lot of essence
			if (sPeripheralA) {
				impact = impact / (sPeripheralA.harmfullImpact + sPeripheralA.harmfullImpactBuffer);
				impact = (impact - 1) * sPeripheralA.maxPeripheralEssence;
				totalPower = impact;
				
				outcome = totalPower < (sPeripheralA.peripheralEssence * sPeripheralA.weakDamagePercent) ? "weak" : totalPower > (sPeripheralA.maxPeripheralEssence * AttributesConstants.powerfullDamageRatio) ? "powerfull" : outcome;
				consumeResult = sPeripheralA.consumePeripheralEssence(totalPower, false);
				// consume peripheral essence will return 0 if there was no change on the damage. Meaning damage was meaningless in term of changind perpheeral essence
				if (consumeResult == -1)	
					overDamage = true;
				else if  (consumeResult == 0){
					outcome = "null";
				}
			}
			
			GameEngine.instance.state.globalEffects.defineSplashByDefaultDamage(this);
			
			hurtTime = (outcome == "critical" || outcome == "powerfull") ? 1.5 : outcome == "strong" ? 1 : outcome == "weak" ? .25 : .5;
			
			direction = normalAnlge;
			
			sufferForceIntensity = 0.13;
			sufferForceIntensity *= impact;
			sufferForce.setxy(1, 0);
			sufferForce.length = sufferForceIntensity;
			sufferForce.angle = direction;

			sufferObject.applyConstrainedImpulse(sufferForce);
			
			sufferObject.sufferReaction(this);
			sufferObject.sufferSecundaryReaction(this);
			
			//trace("DAMAGEMANAGER Fall impulse applied", suffer.holder.name, impact, sufferForce.length);

			nullDamage();
		}
		
		/** Deal a damage by a corruption not from a contact with a damage */
		public function corruptionConditionDamage(suffer:ISufferAttributes, damagePower:int, nature:String):void {
			if (!(suffer as IStatusAttributes))
				throw Error ("DM, object attribute does not implement IStatusAttributes, so it can´t receive corruption damage");
			
			resetDamage(null, suffer.mainSuffer, "Corruption", new MathVector(0, 0));
			
			totalPower = damagePower;
			
			natureDominance = nature;
			
			if(sPeripheralA)
				outcome = totalPower < (sPeripheralA.peripheralEssence * sPeripheralA.weakDamagePercent) ? "weak" : totalPower > (sPeripheralA.peripheralEssence * 0.1) ? "powerfull" : "normal";
			
			originLocation.x = suffer.sufferParent.x;
			originLocation.y = suffer.sufferParent.y;
			
			sufferWillReact = false;
			damagerWillReact = false;
			
			if (sPeripheralA) {
				totalPower *= 1 - (suffer.natureImmunity[nature] * .01);
				
				if (sPeripheralA.consumePeripheralEssence(totalPower, showDamageOnHUD) == -1)
					overDamage = true;
			}
			
			hurtTime = -1;
			
			suffer.sufferParent.sufferReaction(this);
			suffer.sufferParent.sufferSecundaryReaction(this)
			
			GameEngine.instance.state.globalEffects.defineSplashByDamageNatureDominance(this, false);

			nullDamage();
		}
		
		public function resetDamage(damager:DamagerAttibutes, suffer:SufferAttributes, origin:String, originLocation:MathVector):void {
			this.damagerAttribute = damager;
			this.sufferAttribute = suffer;
			this.origin = origin;
			this.originLocation = originLocation;
			this.defended = false; 
			
			if(damager)
				this.damagerHolderAttributes = damager.holder as IDamagerAttributes;
			if(suffer)
				this.sufferHolderAttributes = suffer.holder as ISufferAttributes;
		
			if(this.damagerHolderAttributes)
				damagerObject = this.damagerHolderAttributes.damagerParent;
			if(this.sufferHolderAttributes)
				sufferObject = this.sufferHolderAttributes.sufferParent;



			//Define attributes properties 
			//if attribute holder does not implement some of this interfaces this vars will be null 
			//so code will know witch type of attributes its deal with.
			if(suffer){
				sPeripheralA = suffer.holder as IPeripheralAttributes;
				sMortalA = suffer.holder as IMortalAttributes;
				sMysticalpA = suffer.holder as IMysticalAttributes;
				sStatusA = suffer.holder as IStatusAttributes;
				sDefenderA = suffer.holder as IDefenderAttributes;
			}
			
			if(damager)
				this.bias = suffer.holder.sufferParent.x - damager.holder.damagerParent.x;
			else
				this.bias = 0;
			
			if(suffer)
				frontSide = ((bias < 0 && !suffer.holder.sufferParent.inverted) || (bias >= 0 && suffer.holder.sufferParent.inverted)) ? true : false;
			else
				frontSide = true;
				
			//randomRatio = Math.random();
			staminaToConsume = 0;
			weightRatio = 1;
			randomizedWeightRatio = 1;
			
			efficiencyRatio = 1;
			randomizedEfficiencyRatio = 1;
			
			naturesPowers.length = 0;
			totalPower = 0;
			overDamage = false;
			overDefence = false;
			outcome = "normal";
			
			sufferForceIntensity = 0;
			damagerForceIntensity = 0;
			
			damagerWillReact = false;
			sufferWillReact = false;
			
			sufferForce.x = 0;
			sufferForce.y = 0;
			damagerForce.x = 0;
			damagerForce.y = 0;
		}
		
		/** Null references to external objects */
		private function nullDamage():void{
			damagerAttribute = null;
			sufferAttribute = null;
			damagerHolderAttributes = null;
			sufferHolderAttributes = null;
			damagerObject = null;
			sufferObject = null;
			sPeripheralA = null;
			sMortalA = null;
			sMysticalpA = null;
			sStatusA = null;
			sDefenderA = null;
		}

        private function log(message:String):void {
            if (verbose) trace("[DamageManager]:", message);
        }
		
		/** Return angle between 2 points with values between 0 and 360(degrees) of 0 and 2Pi(radians). Can return both clockwise or an clockwise */
		public static function pointDirection(x1:Number, y1:Number, x2:Number, y2:Number, clockWise:Boolean=false, degrees:Boolean=false):Number {
			if (clockWise)
				y2 *= -1;
				
            var angle:Number = Math.atan2(y2 - y1, x2 - x1) * (degrees ? (180 / Math.PI) : 1);
			
			angle = angle < 0 ? angle + (2 * Math.PI) : angle;
			
			if (!degrees)
				return angle;
			else
        		return angle * (180 / Math.PI);
		}
		
		/**
		 * This function is needed to calculate logarithm of arbitrary basis (other than E / call log as natual)
		 */
		private static function mathLogWithCustomBase(val:Number, base:Number = 1.02):Number{
			return Math.log(val)/Math.log(base)
		}
		
		public function dispose():void {
			sufferForce.dispose();
			damagerForce.dispose();
			sufferForce = null;
			damagerForce = null;
			
		}

	}
}
class PrivateClass{}