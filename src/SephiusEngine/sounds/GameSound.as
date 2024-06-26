package SephiusEngine.sounds 
{

	import SephiusEngine.sounds.events.GameEvent;
	import SephiusEngine.sounds.events.GameEventDispatcher;
	import SephiusEngine.core.GameEngine;
	import flash.events.ErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;

	public class GameSound extends GameEventDispatcher
	{
		public var hideParamWarnings:Boolean = false;
		
		protected var _name:String;
		protected var _soundTransform:SoundTransform;
		protected var _sound:Sound;
		protected var _ioerror:Boolean = false;
		protected var _loadedRatio:Number = 0;
		protected var _loaded:Boolean = false;
		protected var _group:GameSoundGroup;
		protected var _isPlaying:Boolean = false;
		protected var _urlReq:URLRequest;
		protected var _volume:Number = 1;
		protected var _panning:Number = 0;
		protected var _mute:Boolean = false;
		protected var _paused:Boolean = false;		
		
		protected var _ce:GameEngine;
		
		/**
		 * times to loop :
		 * if negative, infinite looping will be done and loops won't be tracked in GameSoundInstances.
		 * if you want to loop infinitely and still keep track of loops, set loops to int.MAX_VALUE instead, each time a loop completes
		 * the SOUND_LOOP event would be fired and loops will be counted.
		 */
		public var loops:int = 0;
		
		/**
		 * a list of all GameSoundInstances that are active (playing or paused)
		 */
		internal var soundInstances:Vector.<GameSoundInstance>;
		
		/**
		 * if permanent is set to true, no new GameSoundInstance
		 * will stop a sound instance from this GameSound to free up a channel.
		 * it is a good idea to set background music as 'permanent'
		 */
		public var permanent:Boolean = false;
		
		/**
		 * When the GameSound is constructed, it will load itself.
		 */
		public var autoload:Boolean = false;
		
		public function GameSound(name:String,params:Object = null) 
		{
			_ce = GameEngine.instance;
			_ce.sound.addDispatchChild(this);
			
			_name = name;
			if (params["sound"] == null)
				throw new Error(String(String(this) + " sound "+ name+ " has no sound param defined."));
				
			soundInstances = new Vector.<GameSoundInstance>();
			
			setParams(params);
			
			if (autoload)
				load();
		}
		
		public function load():void
		{
			unload();
			if (_urlReq && _loadedRatio == 0 && !_sound.isBuffering)
			{
					_ioerror = false;
					_loaded = false;
					_sound.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
					_sound.addEventListener(ProgressEvent.PROGRESS, onProgress);
					_sound.load(_urlReq);
			}
		}
		
		public function unload():void
		{
			if(_sound.isBuffering)
				_sound.close();
			_sound.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_sound.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			sound = _urlReq;
		}
		
		public function play():GameSoundInstance
		{
			return new GameSoundInstance(this, true, true);
		}
		
		/**
		 * creates a sound instance from this GameSound.
		 * you can use this GameSoundInstance to play at a specific position and control its volume/panning.
		 * @param	autoplay
		 * @param	autodestroy
		 * @return GameSoundInstance
		 */
		public function createInstance(autoplay:Boolean = false,autodestroy:Boolean = true):GameSoundInstance
		{
			return new GameSoundInstance(this, autoplay, autodestroy);
		}
		
		public function resume():void
		{
			var soundInstance:GameSoundInstance;
			for each (soundInstance in soundInstances)
				if(soundInstance.isPaused)
					soundInstance.resume();
		}
		
		public function pause():void
		{
			var soundInstance:GameSoundInstance;
			for each (soundInstance in soundInstances)
				if(soundInstance.isPlaying)
					soundInstance.pause();
		}
		
		public function stop():void
		{
			var soundInstance:GameSoundInstance;
			for each (soundInstance in soundInstances)
				if(soundInstance.isPlaying || soundInstance.isPaused)
					soundInstance.stop();
		}
		
		protected function onIOError(event:ErrorEvent):void
		{
			unload();
			trace("GameSound Error Loading: ", this.name);
			_ioerror = true;
			dispatchEvent(new GameSoundEvent(GameSoundEvent.SOUND_ERROR, this, null) as GameEvent);
		}
		
		protected function onProgress(event:ProgressEvent):void
		{
			_loadedRatio = _sound.bytesLoaded / _sound.bytesTotal;
			if (_loadedRatio == 1)
			{
				_loaded = true;
				_ce.sound.soundLoaded(this);
			}
		}
		
		internal function refreshSoundTransform():SoundTransform
		{
			if (_soundTransform == null)
				_soundTransform = new SoundTransform();
				
			if (_group != null)
			{
				_soundTransform.volume = (_mute || _group._mute || _ce.sound.masterMute) ? 0 : _volume * _group._volume * _ce.sound.masterVolume;
				_soundTransform.pan =  _panning;
			
			}
			else
			{
				_soundTransform.volume = (_mute || _ce.sound.masterMute) ? 0 : _volume * _ce.sound.masterVolume;
				_soundTransform.pan =  _panning;
			}
			
			var soundInstance:GameSoundInstance;
			for each (soundInstance in soundInstances)
				soundInstance.resetSoundTransform();
			
			return _soundTransform;
		}
		
		public function set sound(val:Object):void
		{
			if (_sound)
			{
				_sound.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				_sound.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			}
			
			if (val is String)
			{
				_urlReq = new URLRequest(val as String);
				_sound = new Sound();
			}
			else if (val is Class)
			{
				_sound = new (val as Class)();
				_ioerror = false;
				_loadedRatio = 1;
				_loaded = true;
			}
			else if (val is Sound)
			{
				_sound = val as Sound;
				_loadedRatio = 1;
				_loaded = true;
			}
			else if (val is URLRequest)
			{
				_urlReq = val as URLRequest;
				_sound = new Sound();
			}
			else
				throw new Error("GameSound, " + val + "is not a valid sound paramater");
		}
		
		public function get sound():Object
		{
			return _sound;
		}
		
		public function get isPlaying():Boolean
		{
			var soundInstance:GameSoundInstance;
			for each (soundInstance in soundInstances)
				if (soundInstance.isPlaying)
					return true;
			return false;
		}
		
		public function get isPaused():Boolean
		{
			var soundInstance:GameSoundInstance;
			for each (soundInstance in soundInstances)
				if (soundInstance.isPaused)
					return true;
			return false;
		}
		
		public function get group():*
		{
			return _group;
		}
		
		public function set volume(val:Number):void
		{
			if (_volume != val)
			{
				_volume = val;
				refreshSoundTransform();
			}
		}
		
		public function set panning(val:Number):void
		{
			if (_panning != val)
			{
				_panning = val;
				refreshSoundTransform();
				
				var soundInstance:GameSoundInstance;
				for each (soundInstance in soundInstances)
					soundInstance.resetSoundTransform();
			}
		}
		
		public function set mute(val:Boolean):void
		{
			if (_mute != val)
			{
				_mute = val;
				refreshSoundTransform();
				
				var soundInstance:GameSoundInstance;
				for each (soundInstance in soundInstances)
					soundInstance.resetSoundTransform();
			}
		}
		
		public function set group(val:*):void
		{
			_group = GameEngine.instance.sound.getGroup(val);
			if (_group)
				_group.addSound(this);
		}
		
		public function setGroup(val:GameSoundGroup):void
		{
			_group = val;
		}
		
		internal function destroy():void
		{
			if (_sound)
			{
				_sound.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				_sound.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			}
			if (_group)
				_group.removeSound(this);
			_soundTransform = null;
			_sound = null;
			
			var soundInstance:GameSoundInstance;
			for each (soundInstance in soundInstances)
				soundInstance.stop();
				
			removeAllEventListeners();
			
			_ce.sound.removeDispatchChild(this);
		}
		
		public function get loadedRatio():Number
		{
			return _loadedRatio;
		}
		
		public function get loaded():Boolean
		{
			return _loaded;
		}
		
		public function get ioerror():Boolean
		{
			return _ioerror;
		}
		
		public function get volume():Number
		{
			return _volume;
		}
		
		public function get panning():Number
		{
			return _panning;
		}
		
		public function get mute():Boolean
		{
			return _mute;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function get soundTransform():SoundTransform
		{
			return _soundTransform;
		}
		
		public function get ready():Boolean
		{
			if (_sound)
			{
				if (_sound.isURLInaccessible)
					return false;
				if (_sound.isBuffering || _loadedRatio > 0)
					return true;
			}
			return false;
		}
		
		public function get instances():Vector.<GameSoundInstance>
		{
			return soundInstances.slice();
		}
		
		public function getInstance(index:int):GameSoundInstance
		{
			if (soundInstances.length > index + 1)
				return soundInstances[index];
			return null;
		}
		
		protected function setParams(params:Object):void
		{
			for (var param:String in params)
			{
				try
				{
					if (params[param] == "true")
						this[param] = true;
					else if (params[param] == "false")
						this[param] = false;
					else
						this[param] = params[param];
				}
				catch (e:Error)
				{
					trace(e.message);
					if (!hideParamWarnings)
						trace("Warning: The parameter " + param + " does not exist on " + this);
				}
			}
		}
		
	}

}