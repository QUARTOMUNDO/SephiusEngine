package SephiusEngine.core.effects 
{
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.IStatusAttributes;
	import SephiusEngine.core.gameplay.attributes.subAttributes.EssenceLootAttributes;
	import SephiusEngine.displayObjects.configs.AssetsConfigs;
	import SephiusEngine.displayObjects.gameArtContainers.ParticleArt;
	import SephiusEngine.displayObjects.particles.EssenceCloud;
	import SephiusEngine.displayObjects.particles.ParticleSystemEX;
	import SephiusEngine.displayObjects.particles.system.EXParticle;
	import SephiusEngine.displayObjects.particles.system.ParticleEmitter;
	import SephiusEngine.levelObjects.GameSprite;
	import SephiusEngine.levelObjects.interfaces.IEssenceAbsorber;
	import SephiusEngine.levelObjects.interfaces.IEssenceBleeder;

	import flash.utils.Dictionary;

	import tLotDClassic.GameData.Properties.EssenceProperties;
	import tLotDClassic.GameData.Properties.ParticleSystemProperties;
	/**
	 * Menage particles in the world
	 * @author Arthur Fernando Rabello
	 */
	public class ParticleManager extends GameSprite{
		private var particleContainer:ParticleArt = new ParticleArt();
		
		/** Store all particle systems sorted by property they use. 
		 * Normally Particle Manager only create 1 particle system for property.
		 * If you want multiple objects to cast same type of particles, just assign a emitter for the correspondent particle system and they will emit partcile normaly*/
		public var PARTICLES_SYSTEMS:Dictionary;
		/** Store all emitters assigned to some of the particle systems managed by this class */
		public var PARTICLES_EMITTERS:Vector.<ParticleEmitter>;
		/** Store all essence systems. At this time Essences use other Particle System class. In the future, essenses will also use ParticleSystemEX */
		public var ESSENCES:Dictionary;
		
		//public var ESSENCE_ABSORBERS:Vector.<IEssenceAbsorber> = new Vector.<IEssenceAbsorber>();
		
		public function ParticleManager(name:String,params:Object=null) {	
			group = AssetsConfigs.OBJECTS_ASSETS_GROUP;
			super(name, params);
			
			PARTICLES_SYSTEMS = new Dictionary();
			PARTICLES_EMITTERS = new Vector.<ParticleEmitter>();
			ESSENCES = new Dictionary();
			
			view.content = particleContainer;	
			view.needSmoothContainerState = true;
			view.compAbove = true;

			updateCallEnabled = false;
			ParticleSystemProperties.defineStrahtonConfig();
			ParticleSystemProperties.defineTestConfig();
			ParticleSystemProperties.defineSmokingConfig();
			ParticleSystemProperties.defineStrahtonFireConfig();
			ParticleSystemProperties.defineBubbleConfig();
			ParticleSystemProperties.defineMeztizoEssenceConfig();
		}
		
		private var ps:ParticleSystemEX;
		/** Return a particle system related with a particular property. Create one if there is no existing */
		public function getParticleSystem(properties:ParticleSystemProperties):ParticleSystemEX {
			if (!PARTICLES_SYSTEMS[properties]){
				ps = new ParticleSystemEX(properties);
				ps.name = properties.name;
				particleContainer.addChild(ps);
				PARTICLES_SYSTEMS[properties] = ps;
			}
			return PARTICLES_SYSTEMS[properties];
		}
		
		private var emiterIndex1:int;
		/** Assign a emitter to a particle system related with a particular property. */
		public function assignEmitter(emitter:ParticleEmitter, properties:ParticleSystemProperties):void {
			PARTICLES_SYSTEMS[properties].assignEmitter(emitter);
			
			emiterIndex1 = PARTICLES_EMITTERS.indexOf(emitter);
			if (emiterIndex1 == -1){
				PARTICLES_EMITTERS.push(emitter);
				emitter.onDestroyed.add(removeEmitter);
			}
		}
		
		/** Destroy the visual representation container (GameArt) */		
		override public function destroyView():void {
			if (_viewAdded)
				removeView();
			
			//view.dispose();
		}
		
		override public function removeView():void {
			super.removeView();
		}
		
		/** Unassign emitter to a particular particle system. If property pass as null, emitter will be completly removed from manager */
		public function unassignEmitter(emitter:ParticleEmitter, properties:ParticleSystemProperties):void {
			if (!properties){
				removeEmitter(emitter);
				return;
			}
			
			PARTICLES_SYSTEMS[properties].unassignEmitter(emitter);
			
			if(emitter.systemsAssigned.length == 0){
				removeEmitter(emitter);
			}
		}
		
		public function stopParticle(name:String):void {
			(PARTICLES_SYSTEMS[name] as ParticleSystemEX).pause();
		}
		
		public function startParticle(name:String):void {
			(PARTICLES_SYSTEMS[name] as ParticleSystemEX).start();
		}
		
		/** Completly remove emitter from manager, unassign it from any particle system on this manager it is assosiated with */
		public function removeEmitter(emitter:ParticleEmitter):void {
			emiterIndex1 = PARTICLES_EMITTERS.indexOf(emitter);
			if (emiterIndex1 != -1){
				PARTICLES_EMITTERS.splice(emiterIndex1, 1);
				emitter.onDestroyed.remove(removeEmitter);
			}
			
			var particleSystem:ParticleSystemEX;
			for each (particleSystem in PARTICLES_SYSTEMS) {
				particleSystem.unassignEmitter(emitter);
			}
		}
		
		private var cName:String;
		/** Avoid 2 essences clouds to have same name returning a unique name */
		private function defineName(list:Dictionary, name:String):String {
			cName = name + "_" + uint(Math.random() * 1000);
			
			while (list[cName]) {
				cName = name + "_" + uint(Math.random() * 1000);
			}
			return cName;
		}
		
		public function createEssence(bleeder:IEssenceBleeder, essenceLootAttribures:EssenceLootAttributes):EssenceCloud {
			cName = defineName(ESSENCES, bleeder.name)
			
			ESSENCES[cName] = new EssenceCloud(cName, bleeder, essenceLootAttribures);
			
			(ESSENCES[cName] as EssenceCloud).emitterX = bleeder.x;
			(ESSENCES[cName] as EssenceCloud).emitterY = bleeder.y;
			(ESSENCES[cName] as EssenceCloud).emitterXVariance = 30;
			(ESSENCES[cName] as EssenceCloud).emitterYVariance = 60;
			(ESSENCES[cName] as EssenceCloud).gravityY = -20;
			(ESSENCES[cName] as EssenceCloud).lifespan = 10;
			(ESSENCES[cName] as EssenceCloud).endRotation = 0;
			(ESSENCES[cName] as EssenceCloud).endRotationVariance = 5;
			(ESSENCES[cName] as EssenceCloud).startRotation = 3;
			(ESSENCES[cName] as EssenceCloud).startRotationVariance = 6;
			(ESSENCES[cName] as EssenceCloud).startSize = essenceLootAttribures.essenceProperties.aspect == EssenceProperties.ASPECT_ETHOS ? 13 : 300;
			(ESSENCES[cName] as EssenceCloud).endSize = essenceLootAttribures.essenceProperties.aspect == EssenceProperties.ASPECT_ETHOS ? 17 : 800;
			(ESSENCES[cName] as EssenceCloud).startSizeVariance = essenceLootAttribures.essenceProperties.aspect == EssenceProperties.ASPECT_ETHOS ? 3 : 127;
			(ESSENCES[cName] as EssenceCloud).endSizeVariance = essenceLootAttribures.essenceProperties.aspect == EssenceProperties.ASPECT_ETHOS ? 0 : 0;
			(ESSENCES[cName] as EssenceCloud).speed = 50;
			(ESSENCES[cName] as EssenceCloud).radialAcceleration = -40;
			
			particleContainer.addChild(ESSENCES[cName]);
			GameEngine.instance.state.gameJuggler.add(ESSENCES[cName]);
			ESSENCES[cName].start();	
			
			return ESSENCES[cName];
		}
		
		private var hasAbsorbed:Boolean;
		private var absorberStatusAtt:IStatusAttributes;
		private var abPosX:Number;
		private var abPosY:Number;
		public function processParticle(particle:EXParticle, system:ParticleSystemEX, absorber:IEssenceAbsorber):void {/*
			if (absorber.absorberAttributes.absorbing)
				hasAbsorbed = system.attractorDistanceScalar < 150;
			else
				hasAbsorbed = absorber.absorberAttributes.bounds.contains(particle.x, particle.y);
			
			if (hasAbsorbed) {
				if (!particle.absorbed) {
					abPosX = absorber.absorberAttributes.absorbing ? absorber.x + (absorber.absorberAttributes.aborptionOffsetX * (absorber.inverted ? -1 : 1)) : particle.x;
					abPosY = absorber.absorberAttributes.absorbing ? absorber.y + absorber.absorberAttributes.aborptionOffsetY : particle.y;
					
					particle.absorbed = true;
					particle.absorber = absorber;
					
					absorberStatusAtt = absorber.absorberAttributes as IStatusAttributes;
					if(absorberStatusAtt)
						absorberStatusAtt.status.applyStatus(StatusProperties[system.essenceLootAttributes.essenceProperties.origin + "Embedded"], true);
					
					absorberStatusAtt = null;
					
					if(system.essenceLootAttributes.type == EssenceProperties.ASPECT_DEEP){
						absorber.absorberAttributes.absorbDeepEssence(system.essenceLootUnity);
						GameEngine.instance.state.globalEffects.splashByEssenceAbsorbation(system.essenceLootAttributes.essenceProperties.origin, {x:abPosX, y:abPosY});
					}
					else if(system.essenceLootAttributes.type == EssenceProperties.ASPECT_ETHOS)
						absorber.absorberAttributes.absorbNatureAmplification(system.essenceLootAttributes.ethosNature, system.essenceLootUnity);
				}
			}*/
		}
		
		public function destroyEssence(essence:EssenceCloud):void  {
			essence.destoy()
		}
		
		/** Destroy a particle system previous created */
		private function destroyParticleSystem(particle:ParticleSystemEX):void {
			if (!PARTICLES_SYSTEMS[particle.particleSystemProperties])
				return
			ps = PARTICLES_SYSTEMS[particle.particleSystemProperties];
			if(ps.playing)
				ps.stop(true);
			particleContainer.removeChild(ps, true);
			ps = PARTICLES_SYSTEMS[particle.particleSystemProperties] = null;
			delete PARTICLES_SYSTEMS[particle.particleSystemProperties];
		}
		
		public function dispose():void { 
			var key:Object;
			
			for (key in ESSENCES) {
				destroyEssence(ESSENCES[key]);
			}
			
			for (key in PARTICLES_SYSTEMS) {
				destroyParticleSystem(PARTICLES_SYSTEMS[key]);
			}
			
			particleContainer.dispose(); 
			particleContainer = null;
		}
		
		override public function destroy():void {
			super.destroy();
			var key:Object;
			
			for (key in ESSENCES) {
				destroyEssence(ESSENCES[key]);
			}
			
			for (key in PARTICLES_SYSTEMS) {
				destroyParticleSystem(PARTICLES_SYSTEMS[key]);
			}
			
			particleContainer.dispose(); 
			particleContainer = null;
			
			PARTICLES_SYSTEMS = null;
			PARTICLES_EMITTERS = null;
			ESSENCES = null;
		}
	}
}