package SephiusEngine.sounds.system.components.global {
	import aze.motion.EazeTween;
	import SephiusEngine.sounds.GameSound;
	import SephiusEngine.sounds.GameSoundEvent;
	import SephiusEngine.sounds.GameSoundInstance;
	import SephiusEngine.sounds.system.components.GameSoundComponent;
	import SephiusEngine.sounds.system.components.SoundComponentType;
	import org.osflash.signals.Signal;
	
	/**
	 * Sound witch does not haz any to do with physics or positions
	 * @author Fernando Rabello
	 */
	public class GlobalSoundComponent extends GameSoundComponent {
		
		private var soundInstances:Vector.<GameSoundInstance>;
		
		public var onSoundEnding:Signal = new Signal(String);
		
		public function GlobalSoundComponent(name:String){
			super(name);
			_type = SoundComponentType.GLOBAL;
		}
		
		public function fadeOutAll(duration:Number = 1, destroy:Boolean = false ):void{
			var soundInstance:GameSoundInstance;
			for each (soundInstance in soundInstances) {
				var ease:EazeTween;
				if(!destroy)
					ease = new EazeTween(soundInstance).to(duration, { volumeMultiplier:0 } ).onComplete(soundInstance.stop);	
				else
					ease = new EazeTween(soundInstance).to(duration, { volumeMultiplier:0 } ).onComplete(soundInstance.destroy);	
			}
		}
		
		public function fadeOut(soundName:String, duration:Number = 1, destroy:Boolean = false ):void{
			var soundInstance:GameSoundInstance;
			for each (soundInstance in soundInstances)
				if (soundInstance.parentsound.name == soundName)
					break;
			
			if (soundInstance) {
				var ease:EazeTween;
				if(!destroy)
					ease = new EazeTween(soundInstance).to(duration, { volumeMultiplier:0 } ).onComplete(soundInstance.stop);	
				else
					ease = new EazeTween(soundInstance).to(duration, { volumeMultiplier:0 } ).onComplete(soundInstance.destroy);	
			}
		}
		
		public function stop(soundName:String):void{
			var soundInstance:GameSoundInstance;
			for each (soundInstance in soundInstances)
				if (soundName == "" || soundInstance.parentsound.name == soundName)
					soundInstance.stop();
		}
		
		public function play(soundName:String,category:String = null,volume:Number = -1, loop:Boolean = false):void{
			var soundInstance:GameSoundInstance;
			var SephiusEngineSound:GameSound;
			
			SephiusEngineSound = _ce.sound.getSound(soundName);
			if (SephiusEngineSound){
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
			else{
				log("TestSoundComponent, sound " + soundName + " doesn't exist...");
				return;
			}
			
			if (soundInstance){
				soundInstance.addEventListener(GameSoundEvent.SOUND_START, onSoundStart);
				soundInstance.addEventListener(GameSoundEvent.SOUND_END, onSoundEnd);
				EazeTween.killTweensOf(soundInstance);
			}
			soundInstance.play();
			
			log("SoundComponent " + " currently playing " + soundName);
		}
		
		override protected function log(message:String=""):void{
			if (verbose) {
				if(message == "")
					trace("SoundComponent", "currently playing", soundInstances.length, "sound(s)");
				else 
					trace(message);
			}
		}
		
		protected function onSoundStart(e:GameSoundEvent):void{
			soundInstances.push(e.soundInstance);
			log();
		}
		
		protected function onSoundEnd(e:GameSoundEvent):void{
			e.soundInstance.removeEventListener(GameSoundEvent.SOUND_START, onSoundStart);
			e.soundInstance.removeEventListener(GameSoundEvent.SOUND_END, onSoundEnd);
			e.soundInstance.removeSelfFromVector(soundInstances);
			
			onSoundEnding.dispatch(e.soundInstance.parentsound.name);
			
			log();
		}
		
		override public function initialize():void{
			super.initialize();
			soundInstances = new Vector.<GameSoundInstance>();
		}
		
		override public function destroy():void {
			super.destroy();
			onSoundEnding.removeAll();
			var soundInstance:GameSoundInstance;
			for each (soundInstance in soundInstances) {
					soundInstance.destroy();
			}
			soundInstances.length = 0;
		}
	}
}