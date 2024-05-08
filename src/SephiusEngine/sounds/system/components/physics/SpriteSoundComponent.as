package SephiusEngine.sounds.system.components.physics 
{
	import aze.motion.EazeTween;
	import SephiusEngine.levelObjects.GameObject;
	import SephiusEngine.levelObjects.GameSprite;
	import SephiusEngine.sounds.GameSound;
	import SephiusEngine.sounds.GameSoundEvent;
	import SephiusEngine.sounds.GameSoundInstance;
	import SephiusEngine.sounds.system.components.GameSoundComponent;
	import SephiusEngine.sounds.system.components.SoundComponentType;
	import SephiusEngine.levelObjects.interfaces.ISpriteView;

	public class SpriteSoundComponent extends GameSoundComponent
	{
		
		private var sprite:ISpriteView;
		private var soundInstances:Vector.<GameSoundInstance>;
		
		public function SpriteSoundComponent(name:String,co:ISpriteView) 
		{
			super(name);
			
			sprite = co as ISpriteView;
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
			}
			soundInstance.play();
			
			log("SoundComponent " + sprite.spriteName + " currently playing " + soundName);
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
				var ease:EazeTween = new EazeTween(this).to(duration, { fadeVolume:0 } ).onComplete(function():void
				{
					soundInstance.destroy();
					fadeVolume = 1;
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
			e.soundInstance.removeSelfFromVector(soundInstances);
			log();
		}
		
		override protected function log(message:String=""):void
		{
			if (verbose) {
				if(message == "")
					trace("SoundComponent", sprite.spriteName, "currently playing", soundInstances.length, "sound(s)");
				else 
					trace(message);
			}
		}
		
		override public function updatePosition():void
		{
			_position.setTo(sprite.x, sprite.y);
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
		}
		
	}
	
}