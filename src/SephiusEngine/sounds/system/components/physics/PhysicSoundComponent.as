package SephiusEngine.sounds.system.components.physics 
{
	import aze.motion.EazeTween;
	import SephiusEngine.levelObjects.GameObject;
	import SephiusEngine.levelObjects.GamePhysicalSprite;
	import SephiusEngine.sounds.GameSound;
	import SephiusEngine.sounds.GameSoundEvent;
	import SephiusEngine.sounds.GameSoundInstance;
	import SephiusEngine.sounds.system.components.GameSoundComponent;
	import SephiusEngine.sounds.system.components.SoundComponentType;
	import org.osflash.signals.Signal;

	public class PhysicSoundComponent extends GameSoundComponent
	{
		public var onAllSoundsEnd:Signal = new Signal(PhysicSoundComponent);
		
		private var physicsObject:GamePhysicalSprite;
		private var soundInstances:Vector.<GameSoundInstance>;
		public var waintingForEnd:Boolean;
		
		public function waitForUnregist():void {
			waintingForEnd = true;
			onAllSoundsEnd.add(_soundSystem.unregisterComponent);
		}
		
		public function PhysicSoundComponent(name:String,co:GameObject) 
		{
			super(name);
			
			physicsObject = co as GamePhysicalSprite;
			_type = SoundComponentType.POINT;
			radius = 300;
		}
		
		override public function initialize():void
		{
			super.initialize();
			soundInstances = new Vector.<GameSoundInstance>();
		}
		
		public function setSoundVolume(soundName:String, volume:Number):void {
			var soundInstance:GameSoundInstance;
			for each (soundInstance in soundInstances)
				if (soundInstance.parentsound.name == soundName)
					break;
			
			if (soundInstance) {
				soundInstance.volume = volume;
			}
		}
		
		public function setSoundVolumeMultiplier(soundName:String, multiplier:Number):void
		{
			var soundInstance:GameSoundInstance;
			for each (soundInstance in soundInstances)
				if (soundInstance.parentsound.name == soundName)
					break;
			
			if (soundInstance) {
				soundInstance.volumeMultiplier = multiplier;
			}
		}
		
		public function play(soundName:String,category:String = null,volume:Number = -1, loop:Boolean = false):void
		{
			if (soundName == "FX_splash_WaterPoolContactSplash1" ||
			    soundName == "FX_splash_WaterPoolContactSplash2" ||
				soundName == "FX_splash_WaterPoolContactSplash3" ||
				soundName == "FX_splash_WaterImpactMedium" ||
				soundName == "FX_splash_WaterImpactStrong" ||
				soundName == "FX_splash_WaterImpactWeak"){
				trace("Sound Component Physic OPS!");
			}
				
			var soundInstance:GameSoundInstance;
			var SephiusEngineSound:GameSound;
			
			/* Removed fo a wile, we can´t use this cause the priority is the sound come exacly in the right frame.
			for each (soundInstance in soundInstances)
				if (soundInstance.data["category"] && soundInstance.data["category"] == category)
					return;
			*/	
					
			SephiusEngineSound = _ce.sound.getSound(soundName);
			if (SephiusEngineSound)
			{
				soundInstance = SephiusEngineSound.createInstance(false, true);
				if(category)
					soundInstance.data["category"] = category;
				if (volume > -1)
					SephiusEngineSound.volume = volume;
				if(loop)
					soundInstance.loops = -1;
				else
					soundInstance.loops = SephiusEngineSound.loops;
			}
			else
			{
				log("TestSoundComponent, sound " + soundName + " doesn't exist...");
				return;
			}
			
			if (soundInstance)
			{
				soundInstance.addEventListener(GameSoundEvent.SOUND_START, onSoundStart);
				soundInstance.addEventListener(GameSoundEvent.SOUND_END, onSoundEnd);
				soundInstance.addEventListener(GameSoundEvent.SOUND_LOOP, onSoundLoop);
			}
			soundInstance.play();
			
			log("SoundComponent " + physicsObject.name + " currently playing " + soundName);
		}
		
		public function stop(soundName:String):void
		{
			var soundInstance:GameSoundInstance;
			for each (soundInstance in soundInstances)
				if (soundInstance.parentsound.name == soundName)
					soundInstance.stop();
		}
		
		public function fadeOut(soundName:String, duration:Number = 1 ):void
		{
			var soundInstance:GameSoundInstance;
			for each (soundInstance in soundInstances)
				if (soundInstance.parentsound.name == soundName)
					break;
			
			if (soundInstance)
			{
				var ease:EazeTween = new EazeTween(soundInstance).to(duration, { volumeMultiplier:0 } ).onComplete(function():void
				{
					soundInstance.destroy();
				});
			}
		}
		
		public function isSoundPlaying(soundName:String):Boolean
		{
			var soundInstance:GameSoundInstance;
			for each (soundInstance in soundInstances)
				if (soundInstance.parentsound.name == soundName)
					return soundInstance.isPlaying;
			return false;
		}
		
		protected function onSoundStart(e:GameSoundEvent):void
		{
			soundInstances.push(e.soundInstance);
			log();
		}
		
		protected function onSoundEnd(e:GameSoundEvent):void
		{
			e.soundInstance.removeEventListener(GameSoundEvent.SOUND_START, onSoundStart);
			e.soundInstance.removeEventListener(GameSoundEvent.SOUND_END, onSoundEnd);
			e.soundInstance.removeEventListener(GameSoundEvent.SOUND_LOOP, onSoundLoop);
			e.soundInstance.removeSelfFromVector(soundInstances);
			
			log();
			
			if (soundInstances.length == 0){
				onAllSoundsEnd.dispatch(this);
				onAllSoundsEnd.removeAll();
				waintingForEnd = false;
			}
		}
		
		protected function onSoundLoop(e:GameSoundEvent):void {
			if (!waintingForEnd)
				return;
			e.soundInstance.stop();
		}
		
		override protected function log(message:String=""):void
		{
			if (verbose) {
				if(message == "")
					trace("SoundComponent", physicsObject.name, "currently playing", soundInstances.length, "sound(s)");
				else 
					trace(message);
			}
		}
		
		override public function updatePosition():void
		{
			_position.setTo(physicsObject.x, physicsObject.y);
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			updateSounds();
		}
		
		/**
		 * update sound of all SephiusEngine sound instances attached to this sound component
		 */
		protected function updateSounds():void
		{
			var soundInstance:GameSoundInstance;
			for each (soundInstance in soundInstances)
				updateSoundInstance(soundInstance);
		}
		
		public function get instances():Vector.<GameSoundInstance>
		{
			return soundInstances.slice();
		}
		
		override public function destroy():void
		{
			var soundInstance:GameSoundInstance;
			for each (soundInstance in soundInstances)
			{
				soundInstance.stop(true);
				soundInstance.removeSelfFromVector(soundInstances);
			}
			super.destroy();
			onAllSoundsEnd.removeAll();
		}
		
	}
	
}