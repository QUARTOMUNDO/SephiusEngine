package SephiusEngine.displayObjects.particles {
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.IStatusAttributes;
	import SephiusEngine.core.gameplay.attributes.subAttributes.EssenceLootAttributes;
	import SephiusEngine.displayObjects.particles.system.EssenceParticle;
	import SephiusEngine.levelObjects.interfaces.IEssenceAbsorber;
	import SephiusEngine.levelObjects.interfaces.IEssenceBleeder;

	import starling.display.BlendMode;

	import tLotDClassic.GameData.Properties.EssenceProperties;
	import tLotDClassic.GameData.Properties.NatureProperties;
	import tLotDClassic.GameData.Properties.StatusProperties;
    
	
	/**
	 * Particle system that simulate a essence cloud.
	 * Can give essence to a character that obsorb particles from it.
	 * Modified class from PDParticleSystem from starling.
	 * @author Fernando Rabello - Arthur Graná - Gamua OG
	 */
	public class EssenceCloud extends ParticleCloud {
		/** If Essence is from Dark, Light or Mestizo(Sephius)*/
		public var essenceLootAttributes:EssenceLootAttributes;
		
		/** How much essence bleeds from the bleeder */
		public var essenceCapacity:Number = 60;
		/** How much deep essence is granted when a particle is absorbed */ 
		public var essenceLootUnity:Number = 0.1;
		/** How much deep essence is granted when a particle is absorbed */ 
		public var wildness:Number = 1;
		/** Allow the bleeder itself to absorb the essence he is bleeding. 
		 * Used in some cases like when character use a item that gives essence, at this time essence is emitter by the character not by the item 
		 * Due that he need to be able to absorb the essence dropped*/
		public var selfAbsorption:Boolean = false;

		/** Time which this essence cloud should be exhausted. In game mechanics is the time the bleeder will bleed this essence in seconds. */
		private static var exhaustionTime:Number = 6;
		
		public function get bleeder():IEssenceBleeder { return emitter as IEssenceBleeder; }
		
		public var depleted:Boolean;
		
		public static var ESSENCE_ABSORBERS:Vector.<IEssenceAbsorber> = new Vector.<IEssenceAbsorber>();
		
		public function EssenceCloud(name:String, bleeder:Object, essenceLootAttributes:EssenceLootAttributes){
			this.essenceLootAttributes = essenceLootAttributes;
			var textureNamePrefix:String = essenceLootAttributes.type != EssenceLootAttributes.TYPE_DEEP ? "None" : essenceLootAttributes.essenceProperties.origin;
			
            super(name, "Essence_" + essenceLootAttributes.essenceProperties.aspect + textureNamePrefix, bleeder, essenceLootAttributes.essenceProperties.size, 10, BlendMode.SCREEN);
           
			essenceLootUnity = Number(Math.ceil((essenceLootAttributes.amount / essenceLootAttributes.essenceProperties.size) * 100) * .01);
			
			wildness = essenceLootAttributes.essenceProperties.wildness;
			
			autoSetEmissionRate = false;
			
			autoDestroy = true;
			
			if (essenceLootAttributes.type == EssenceProperties.ASPECT_ETHOS) {
				startColor.fromRgb(NatureProperties.PROPERTY_BY_NAME[essenceLootAttributes.ethosNature].color);
				endColor.fromRgb(NatureProperties.PROPERTY_BY_NAME[essenceLootAttributes.ethosNature].color);
			}
			
			//trace("[ESSENCE CLOUD]:", " amount: ", essenceLootAttributes.amount, " type: ", essenceLootAttributes.type, " origin: ", essenceLootAttributes.essenceProperties.origin, " aspect: ", essenceLootAttributes.essenceProperties.aspect, " size: ", essenceLootAttributes.essenceProperties.size, " ethosNature: ", essenceLootAttributes.ethosNature );
		}
        
		override public function advanceTime(passedTime:Number):void {
			super.advanceTime(passedTime);
			if(bleeder && bleeder.enabled){
				//trace("[ESSENCE CLOUD]: ADVANCE TIME" + " bleedSpeed: " + bleeder.bleederAttributes.bleedSpeed + " amount: " + amount + " finalCount: " + finalCount + " rate: " + emissionRate + " numParticles: " + numParticles  + " type: " + essenceLootAttributes.type);
				if(finalCount < amount)
					emissionRate = bleeder ? bleeder.bleederAttributes.bleedSpeed : emissionRate;
			}
			else{
				emissionRate = 0;
				depleted = true;
				//trace("[ESSENCE CLOUD]:" + " finalCount: " + finalCount + " numParticles: " + numParticles + " amount: " + amount + " emissionRate: " + emissionRate);
				//trace("[ESSENCE CLOUD]:" + " essenceLootUnity: " + essenceLootUnity + " type: " + essenceLootAttributes.type);
			}
		}

        override public function advanceEmitter():void{
			if(bleeder && bleeder.enabled){
				mEmitterX = emitter.x + emitterOffsetX + bleeder.bleedOffsetX;
				mEmitterY = emitter.y + emitterOffsetY + bleeder.bleedOffsetY;
			}
        } 

		override public function removeParticle(aParticle:EssenceParticle):void{
			//trace("[ESSENCE CLOUD]: REMOVE PARTICLE" + " currentTime: " + " absorbed: " + aParticle.absorbed + " currentTime: " + aParticle.currentTime + " totalTime: " + aParticle.totalTime + " numParticles: " + numParticles  + " type: " + essenceLootAttributes.type);
			super.removeParticle(aParticle);
		}

		override protected function initParticle(aParticle:EssenceParticle):void {
			super.initParticle(aParticle);

			if(bleeder){
				//particle.x += bleeder.bleedOffsetX;
				//particle.y += bleeder.bleedOffsetY;
			}
            particle.velocityX *= wildness;
            particle.velocityY *= wildness;
            //particle.radialAcceleration *= wildness;
			// particle.tangentialAcceleration *= wildness;
			//trace("[ESSENCE CLOUD]: INIT PARTICLE" + " alpha: " + particle.alpha + " totalTime: " + particle.totalTime + " amount: " + amount + " Hlifespan: " + Hlifespan + " currentTime: " + particle.currentTime);
			//trace("[ESSENCE CLOUD Particle]: " + " alpha: " + aParticle.alpha + " alphaFade: " + aParticle.alphaFade + " scale: " + aParticle.scale + " emissionRate: " + emissionRate);
			
			if (finalCount >= amount) {
				emissionRate = 0;
				depleted = true;
				//trace("[ESSENCE CLOUD]: STOPED Final Count: " + finalCount + " essenceLootUnity: " + essenceLootUnity + " type: " + essenceLootAttributes.type)
			}
		}
		
		private var attractorRadialX:Number;
		private var attractorRadialY:Number;
		private var attractorDistanceX:Number;
		private var attractorDistanceY:Number;
		private var attractorDistanceScalar:Number;
		private var velocityScalar:Number;
		private static var aI:Number;
		private var hasAbsorbed:Boolean;
		private var absorberStatusAtt:IStatusAttributes;
		private var abPosX:Number;
		private var abPosY:Number;
		private var aPosX:Number;
		private var aPosY:Number;
		
        override protected function advanceParticle(aParticle:EssenceParticle, passedTime:Number):void {
            particle = aParticle;
			
            restTime = particle.totalTime - particle.currentTime;
            passedTime = restTime > passedTime ? passedTime : restTime;
            particle.currentTime += passedTime;
            
			distanceX = particle.x - particle.startX;
			distanceY = particle.y - particle.startY;
			distanceScalar = Math.sqrt(distanceX * distanceX + distanceY * distanceY);
			
			if (distanceScalar < 0.01) distanceScalar = 0.01;
			
			radialX = distanceX / distanceScalar;
			radialY = distanceY / distanceScalar;
			tangentialX = radialX;
			tangentialY = radialY;
			
			radialX *= particle.radialAcceleration;
			radialY *= particle.radialAcceleration;
			
			newY = tangentialX;
			tangentialX = -tangentialY * particle.tangentialAcceleration;
			tangentialY = newY * particle.tangentialAcceleration;
			
			repelentDistanceX = particle.x - emitterX;
			repelentDistanceY = particle.y - emitterY;
			repelentDistanceScalar = Math.sqrt(repelentDistanceX * repelentDistanceX + repelentDistanceY * repelentDistanceY);
			
			if (repelentDistanceScalar < 0.01) repelentDistanceScalar = 0.01;
			
			repelentRadialX = repelentDistanceX / repelentDistanceScalar;
			repelentRadialY = repelentDistanceY / repelentDistanceScalar;
			
			repelentRadialX *= repelentForce;
			repelentRadialY *= repelentForce;
			
			attractorRadialX = 0;
			attractorRadialY = 0;
			hasAbsorbed = false;
			
			for (aI = 0; aI < ESSENCE_ABSORBERS.length; aI++ ) {
				//make particle only be absorbed by absorber after is absorbed (what?)
				if (!bleeder || (bleeder != ESSENCE_ABSORBERS[aI] || selfAbsorption)){
					if (ESSENCE_ABSORBERS[aI].absorberAttributes.enabled && ESSENCE_ABSORBERS[aI].absorberAttributes.canAbsorb) {
						if (!particle.absorber || particle.absorber == ESSENCE_ABSORBERS[aI]) {
							aPosX = ESSENCE_ABSORBERS[aI].x + (ESSENCE_ABSORBERS[aI].absorberAttributes.absorbing ? (ESSENCE_ABSORBERS[aI].absorberAttributes.aborptionOffsetX * (ESSENCE_ABSORBERS[aI].inverted ? -1 : 1)) : 0);
							aPosY = ESSENCE_ABSORBERS[aI].y + (ESSENCE_ABSORBERS[aI].absorberAttributes.absorbing ? ESSENCE_ABSORBERS[aI].absorberAttributes.aborptionOffsetY : 0);
							
							attractorDistanceX = particle.x - aPosX;
							attractorDistanceY = particle.y - aPosY;
							attractorDistanceScalar = particle.aborberDistanceScalar = Math.sqrt((attractorDistanceX * attractorDistanceX) + (attractorDistanceY * attractorDistanceY));
							
							if(particle.absorber){
								particle.abDistanceX = attractorDistanceX;
								particle.abDistanceY = attractorDistanceY;
							}
							
							if (attractorDistanceScalar < 0.01) attractorDistanceScalar = 0.01;
							
							// Distance ration * attractorForce / inverse square field * force
							attractorRadialX += (attractorDistanceX / attractorDistanceScalar) * 
												(ESSENCE_ABSORBERS[aI].absorberAttributes.absorptionPower / 
												(attractorDistanceScalar * attractorDistanceScalar)) * 
												(attractorForce);
							attractorRadialY += (attractorDistanceY / attractorDistanceScalar) *
												(ESSENCE_ABSORBERS[aI].absorberAttributes.absorptionPower / 
												(attractorDistanceScalar * attractorDistanceScalar)) * 
												(attractorForce);
							
							if (ESSENCE_ABSORBERS[aI].absorberAttributes.absorbing)
								hasAbsorbed = attractorDistanceScalar < 150;
							else
								hasAbsorbed = ESSENCE_ABSORBERS[aI].absorberAttributes.bounds.contains(particle.x, particle.y);
							
							if (hasAbsorbed) {
								if (!particle.absorbed) {
									abPosX = ESSENCE_ABSORBERS[aI].absorberAttributes.absorbing ? ESSENCE_ABSORBERS[aI].x + (ESSENCE_ABSORBERS[aI].absorberAttributes.aborptionOffsetX * (ESSENCE_ABSORBERS[aI].inverted ? -1 : 1)) : particle.x;
									abPosY = ESSENCE_ABSORBERS[aI].absorberAttributes.absorbing ? ESSENCE_ABSORBERS[aI].y + ESSENCE_ABSORBERS[aI].absorberAttributes.aborptionOffsetY : particle.y;
									
									particle.absorbed = true;
									particle.absorber = ESSENCE_ABSORBERS[aI];
									particle.alpha = 1;
									particle.alphaFade = 1;

									absorberStatusAtt = ESSENCE_ABSORBERS[aI].absorberAttributes as IStatusAttributes;
									if(absorberStatusAtt)
										absorberStatusAtt.status.applyStatus(StatusProperties[essenceLootAttributes.essenceProperties.origin + "Embedded"], true);
									
									absorberStatusAtt = null;
									
									if(essenceLootAttributes.type == EssenceProperties.ASPECT_DEEP){
										ESSENCE_ABSORBERS[aI].absorberAttributes.absorbDeepEssence(essenceLootUnity, essenceLootAttributes.essenceProperties.origin);
										GameEngine.instance.state.globalEffects.splashByEssenceAbsorbation(essenceLootAttributes.essenceProperties.origin, {x:abPosX, y:abPosY});
									}
									else if(essenceLootAttributes.type == EssenceProperties.ASPECT_ETHOS){
										ESSENCE_ABSORBERS[aI].absorberAttributes.absorbNatureAmplification(essenceLootAttributes.ethosNature, essenceLootUnity);
										GameEngine.instance.state.globalEffects.splashByEssenceAbsorbation(essenceLootAttributes.type, {x:abPosX, y:abPosY});
									}
								}
							}
						}
					}
				}
			}
			
			/** -------------------------------- */
			/** -------Particle Update---------- */
			/** -------------------------------- */
			
			if (!particle.absorbed) {
				particle.velocityX += passedTime * (mGravityX + radialX + tangentialX + attractorRadialX + repelentRadialX) * wildness;
				particle.velocityY += passedTime * (mGravityY + radialY + tangentialY + attractorRadialY + repelentRadialY) * wildness;
			}
			else if (particle.absorbed && particle.aborberDistanceScalar > 50){
				particle.velocityX += attractorRadialX * passedTime;
				particle.velocityY += attractorRadialY * passedTime;
				particle.scaleX *= particle.scaleX > .5 ? .95 : 1;
				particle.scaleY *= particle.scaleY > .5 ? .95 : 1;
			}
			else {
				particle.velocityX *= .6;
				particle.velocityY *= .6;
				particle.scaleX *= particle.scaleX > .3 ? .95 : 1;
				particle.scaleY *= particle.scaleY > .3 ? .95 : 1;
				particle.alpha *= .95;
			}
			
			particle.x += particle.velocityX * passedTime;
			particle.y += particle.velocityY * passedTime;
			particle.color = particle.colorArgb.toRgb();
			
			if (essenceLootAttributes.type == EssenceProperties.ASPECT_ETHOS){
				particle.rotation = Math.atan2(particle.velocityY, particle.velocityX);
				velocityScalar = Math.sqrt(particle.velocityX * particle.velocityX + particle.velocityY * particle.velocityY);
				particle.scaleX = (HstartSize / texture.width) + (velocityScalar * 0.001);
				particle.scaleY = (HstartSize / texture.width);
			}
			else{
				particle.rotation += particle.rotationDelta * passedTime * wildness;
			}
			
			if (!particle.absorbed) {
				particle.colorArgb.red   += particle.colorArgbDelta.red   * passedTime;
				particle.colorArgb.green += particle.colorArgbDelta.green * passedTime;
				particle.colorArgb.blue  += particle.colorArgbDelta.blue  * passedTime;
				particle.alphaFade = particle.alphaFade >= 1 ? 1 : particle.alphaFade + (particle.alphaFadeDelta * passedTime);
				particle.hAlpha += particle.colorArgbDelta.alpha * passedTime;
				particle.colorArgb.alpha = particle.hAlpha * particle.alphaFade;
				
				particle.scaleX += particle.scaleDelta * passedTime * wildness;
				particle.scaleY += particle.scaleDelta * passedTime * wildness;
				particle.alpha = particle.colorArgb.alpha;
			}
        }
		
		override public function destoy():void {
			essenceLootAttributes = null;
			emitter = null;
			super.destoy();
		}
	}
}