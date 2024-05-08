package SephiusEngine.sounds 
{
	import SephiusEngine.math.MathUtils;
	/**
	 * GameSoundGroup represents a volume group with its groupID and has mute control as well.
	 */
	public class GameSoundGroup 
	{
		
		public static const BGM:String = "BGM";
		public static const BGFX:String = "BGFX";
		public static const FX:String = "FX";
		public static const UI:String = "UI";
		public static const STORYTELLER:String = "STORYTELLER";
		
		protected var _groupID:String;
		
		internal var _volume:Number = 1;
		internal var _mute:Boolean = false;
		
		protected var _sounds:Vector.<GameSound>;
		
		public function GameSoundGroup() 
		{
			_sounds = new Vector.<GameSound>();
		}
		
		protected function applyChanges():void
		{
			var s:GameSound;
			for each(s in _sounds)
				s.refreshSoundTransform();
		}
		
		internal function addSound(s:GameSound):void
		{
			if (s.group && s.group.isadded(s))
				(s.group as GameSoundGroup).removeSound(s);
			s.setGroup(this);
			_sounds.push(s);
		}
		
		internal function isadded(sound:GameSound):Boolean
		{
			var s:GameSound;
			for each(s in _sounds)
				if (sound == s)
					return true;
			return false;
		}
		
		public function getAllSounds():Vector.<GameSound>
		{
			return _sounds.slice();
		}
		
		internal function removeSound(s:GameSound):void
		{
			var si:String;
			for (si in _sounds)
			{
				if (_sounds[si] == s)
				{
					GameSound(_sounds[si]).setGroup(null);
					GameSound(_sounds[si]).refreshSoundTransform();
					_sounds.splice(uint(si), 1);
					break;
				}
			}
		}
		
		public function getSound(name:String):GameSound
		{
			var s:GameSound;
			for each(s in _sounds)
				if (s.name == name)
					return s;
			return null;
		}
		
		public function getRandomSound():GameSound
		{
			var index:uint = MathUtils.randomInt(0, _sounds.length - 1);
			return _sounds[index];
		}
		
		public function set mute(val:Boolean):void
		{
			_mute = val;
			applyChanges();
		}
		
		public function get mute():Boolean
		{
			return _mute;
		}
		
		public function set volume(val:Number):void
		{
			_volume = val;
			applyChanges();
		}
		
		public function get volume():Number
		{
			return _volume;
		}
		
		public function get groupID():String
		{
			return _groupID;
		}
		
		internal function destroy():void
		{
			var s:GameSound;
			for each(s in _sounds)
				removeSound(s);
			_sounds.length = 0;
		}
		
	}

}