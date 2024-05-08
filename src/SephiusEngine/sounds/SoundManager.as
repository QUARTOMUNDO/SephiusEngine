package SephiusEngine.sounds {

	import aze.motion.eaze;
	import SephiusEngine.sounds.events.GameEvent;
	import SephiusEngine.sounds.events.GameEventDispatcher;
	import SephiusEngine.sounds.groups.BGFXGroup;
	import SephiusEngine.sounds.groups.STORYTELLERGroup;
	import SephiusEngine.sounds.system.GameSoundSystem;

	import SephiusEngine.sounds.groups.BGMGroup;
	import SephiusEngine.sounds.groups.SFXGroup;
	import SephiusEngine.sounds.groups.UIGroup;

	import flash.events.EventDispatcher;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.utils.Dictionary;

	public class SoundManager extends GameEventDispatcher {
		
		internal static var _instance:SoundManager;

		protected var soundsDic:Dictionary;
		protected var soundGroups:Vector.<GameSoundGroup>;
		
		public var soundSystem:GameSoundSystem;
		
		protected var _masterVolume:Number = 1;
		protected var _masterMute:Boolean = false;
		
		protected var verbose:Boolean = false;
		
		public function SoundManager() {
			
			soundsDic = new Dictionary();
			soundGroups = new Vector.<GameSoundGroup>();
			
			//default groups
			soundGroups.push(new BGMGroup());
			soundGroups.push(new SFXGroup());
			soundGroups.push(new UIGroup());
			soundGroups.push(new BGFXGroup());
			soundGroups.push(new STORYTELLERGroup());
			
			soundSystem = new GameSoundSystem(this);
			GameSoundInstance.eventVerbose = false;
		}
		
		public static function getInstance():SoundManager {
			if (!_instance)
				_instance = new SoundManager();
			
			return _instance;
		}
		
		public function destroy():void {
			var csg:GameSoundGroup;
			for each(csg in soundGroups)
				csg.destroy();
				
			var s:GameSound;
			for each(s in soundsDic)
				s.destroy();
			
			soundSystem.destroy();
			soundSystem = null;
			
			soundsDic = null;
			_instance = null;
			
			removeAllEventListeners();
		}
		
		/**
		 * Register a new sound an initialize its values with the params objects. Accepted parameters are:
		 * <ul><li>sound : a url, a class or a Sound object.</li>
		 * <li>volume : the initial volume. the real final volume is calculated like so : volume x group volume x master volume.</li>
		 * <li>panning : value between -1 and 1 - unaffected by group or master.</li>
		 * <li>mute : default false, whether to start of muted or not.</li>
		 * <li>timesToPlay : default 1 (plays once) . 0 or a negative number will make the sound loop infinitely.</li>
		 * <li>group : the groupID of a group, no groups are set by default. default groups ID's are SephiusEngineSoundGroup.SFX (sound effects) and SephiusEngineSoundGroup.BGM (background music)</li>
		 * <li>triggerSoundComplete : whether to dispatch a SephiusEngineSoundEvent on each loop of type SephiusEngineSoundEvent.SOUND_COMPLETE .</li>
		 * <li>triggerRepeatComplete : whether to dispatch a SephiusEngineSoundEvent of type SephiusEngineSoundEvent.REPEAT_COMPLETE when a sounds has played 'timesToPlay' times.</li></ul>
		 */
		public function addSound(id:String, params:Object = null):void {
			if (!params.hasOwnProperty("sound"))
				throw new Error("SoundManager addSound() sound:"+id+"can't be added with no sound definition in the params.");
			if (id in soundsDic)
				log(this + id + " already exists.");
			else
				soundsDic[id] = new GameSound(id, params);
		}
		
		/**
		 * add your own custom SephiusEngineSoundGroup here.
		 */
		public function addGroup(group:GameSoundGroup):void
		{
			soundGroups.push(group);
		}
		
		/**
		 * removes a group and detaches all its sounds - they will now have their default volume modulated only by masterVolume
		 */
		public function removeGroup(groupID:String):void
		{
			var g:GameSoundGroup = getGroup(groupID);
			var i:int = soundGroups.lastIndexOf(g);
			if ( i > -1)
			{
				soundGroups.splice(i, 1);
				g.destroy();
			}
			else
				log("Sound Manager : group " + groupID + " not found for removal.");
		}
		
		/**
		 * moves a sound to a group - if groupID is null, sound is simply removed from any groups
		 * @param	soundName 
		 * @param	groupID ("BGM", "SFX" or custom group id's)
		 */
		public function moveSoundToGroup(soundName:String, groupID:String = null):void
		{
			var s:GameSound;
			var g:GameSoundGroup;
			if (soundName in soundsDic)
			{
				s = soundsDic[soundName];
				if (s.group != null)
					s.group.removeSound(s);
				if(groupID != null)
				g = getGroup(groupID)
				if (g)
					g.addSound(s);
			}
			else
				log(this + " moveSoundToGroup() : sound " + soundName + " doesn't exist.");
		}
		
		/**
		 * return group of id 'name' , defaults would be SFX or BGM
		 * @param	name
		 * @return SephiusEngineSoundGroup
		 */
		public function getGroup(name:String):GameSoundGroup
		{
			var sg:GameSoundGroup;
			for each(sg in soundGroups)
			{
				if (sg.groupID == name)
					return sg;
			}
			log(this + " getGroup() : group " + name + " doesn't exist.");
			return null;
		}
		
		/**
		 * returns a SephiusEngineSound object. you can use this reference to change volume/panning/mute or play/pause/resume/stop sounds without going through SoundManager's methods.
		 */
		public function getSound(name:String):GameSound
		{
			if (name in soundsDic)
				return soundsDic[name];
			else
				log(this + " getSound() : sound " + name + " doesn't exist.");
			return null;
		}
		
		public function preloadAllSounds():void
		{
			var cs:GameSound;
			for each (cs in soundsDic)
				cs.load();
		}
		
		/**
		 * pauses all playing sounds
		 */
		public function pauseAll():void
		{
			var s:GameSound;
			for each(s in soundsDic)
					s.pause();
		}
		
		/**
		 * resumes all paused sounds
		 */
		public function resumeAll():void
		{
			var s:GameSound;
			for each(s in soundsDic)
					s.resume();
		}
		
		public function playSound(id:String):GameSoundInstance {
			if (id in soundsDic)
				return GameSound(soundsDic[id]).play();
			else
				trace(this, "playSound() : sound", id, "doesn't exist.");
			return null;
		}
		
		public function stopSound(id:String):void {
			if (id in soundsDic)
				GameSound(soundsDic[id]).stop();
			else
				log(this + " stopSound() : sound " + id + " doesn't exist.");
		}
		
		public function removeSound(id:String):void {
			stopSound(id);
			if (id in soundsDic)
			{
				GameSound(soundsDic[id]).destroy();
				soundsDic[id] = null;
				delete soundsDic[id];
			}
			else
				log(this + " removeSound() : sound " + id + " doesn't exist.");
		}
		
		public function soundIsPlaying(sound:String):Boolean
		{
			if (sound in soundsDic)
			{
				var s:GameSound;
					for each(s in soundsDic)
						if (s.isPlaying)
							return true;
			}
			return false;
		}
		
		public function removeAllSounds(...except):void {
			
			var killSound:Boolean;
			
			for each(var cs:GameSound in soundsDic) {
				
				killSound = true;
				
				for each (var soundToPreserve:String in except) {
				
					if (soundToPreserve == cs.name) {
						killSound = false;
						break;
					}
				}
				if (killSound)
					removeSound(cs.name);
			}
		}
		
		public function get masterVolume():Number
		{
			return _masterVolume;
		}
		
		public function get masterMute():Boolean
		{
			return _masterMute;
		}
		
		/**
		 * sets the master volume : resets all sound transforms to masterVolume*groupVolume*soundVolume
		 */
		public function set masterVolume(val:Number):void
		{
			var tm:Number = _masterVolume;
			if (val >= 0 && val <= 1)
				_masterVolume = val;
			else
				_masterVolume = 1;
			
			if (tm != _masterVolume)
			{
				var s:String;
				for (s in soundsDic)
					soundsDic[s].refreshSoundTransform();
			}
		}
		
		/**
		 * sets the master mute : resets all sound transforms to volume 0 if true, or 
		 * returns to normal volue if false : normal volume is masterVolume*groupVolume*soundVolume
		 */
		public function set masterMute(val:Boolean):void
		{
			if (val != _masterMute)
			{
				_masterMute = val;
				var s:String;
				for (s in soundsDic)
					soundsDic[s].refreshSoundTransform();
			}
		}

		/**
		 * tells if the sound is added in the list.
		 * @param	id
		 * @return
		 */
		public function soundIsAdded(id:String):Boolean {
			return (id in soundsDic);
		}
		
		/**
		 * Cut the SoundMixer. No sound will be heard.
		 */
		public function muteFlashSound(mute:Boolean = true):void {
			
			var s:SoundTransform = SoundMixer.soundTransform;
			s.volume = mute ? 0 : 1;
			SoundMixer.soundTransform = s;
		}

		/**
		 * set volume of an individual sound (its group volume and the master volume will be multiplied to it to get the final volume)
		 */
		public function setVolume(id:String, volume:Number):void {
			if (id in soundsDic)
				soundsDic[id].volume = volume;
			else
				log(this + " setVolume() : sound " + id + " doesn't exist.");
		}
		
		/**
		 * set pan of an individual sound (not affected by group or master
		 */
		public function setPanning(id:String, panning:Number):void {
			if (id in soundsDic)
				soundsDic[id].panning = panning;
			else
				log(this + " setPanning() : sound " + id + " doesn't exist.");
		}
		
		/**
		 * set mute of a sound : if set to mute, neither the group nor the master volume will affect this sound of course.
		 */
		public function setMute(id:String, mute:Boolean):void {
			if (id in soundsDic)
				soundsDic[id].mute = mute;
			else
				log(this + " setMute() : sound " + id +  " doesn't exist.");
		}
		
		/**
		 * Stop playing all the current sounds.
		 * @param except an array of soundIDs you want to preserve.
		 */		
		public function stopAllPlayingSounds(...except):void {
			
			var killSound:Boolean;
			var cs:GameSound;
			loop1:for each(cs in soundsDic) {
					
				for each (var soundToPreserve:String in except)
					if (soundToPreserve == cs.name)
						break loop1;
				
					stopSound(cs.name);
			}
		}

		public function tweenVolume(id:String, volume:Number = 0, tweenDuration:Number = 2, callback:Function = null):void {
			if (soundIsPlaying(id)) {
				var tweenvolObject:Object = {volume:GameSound(soundsDic[id]).volume};
				
				eaze(tweenvolObject).to(tweenDuration, {volume:volume})
					.onUpdate(function():void {
					GameSound(soundsDic[id]).volume = tweenvolObject.volume;
				}).onComplete(callback);
			} else 
				log("the sound " + id + " is not playing");
		}

		public function crossFade(fadeOutId:String, fadeInId:String, tweenDuration:Number = 2):void {

			tweenVolume(fadeOutId, 0, tweenDuration);
			tweenVolume(fadeInId, 1, tweenDuration);
		}
		
		internal function soundLoaded(s:GameSound):void
		{
			dispatchEvent(new GameSoundEvent(GameSoundEvent.SOUND_LOADED,s,null));
			var cs:GameSound;
			for each(cs in soundsDic)
				if (!cs.loaded)
					return;
			dispatchEvent(new GameSoundEvent(GameSoundEvent.ALL_SOUNDS_LOADED, s,null));
		}
		
		public function log(message:String):void {
			if (verbose)
				trace("SOUND MANAGER]:" + message);
		}
	}
}
