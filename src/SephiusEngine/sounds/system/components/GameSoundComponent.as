package SephiusEngine.sounds.system.components 
{
	//import SephiusEngine.core.SephiusEngine_internal;
	import SephiusEngine.sounds.system.BitFlag;
	import SephiusEngine.math.MathVector;
	import SephiusEngine.sounds.GameSound;
	import SephiusEngine.sounds.GameSoundInstance;
	import SephiusEngine.sounds.system.GameSoundSystem;
	import SephiusEngine.core.GameEngine;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * Base sound component
	 */
	public class GameSoundComponent 
	{
		//use namespace SephiusEngine_internal;
		
		public static var verbose:Boolean = false;
		
		protected var _ce:GameEngine;
		protected var _soundSystem:GameSoundSystem;
		public var name:String = "base";
		
		protected var _type:int = -1;
		protected var _radius:Number = -1;
		protected var _rect:Rectangle = new Rectangle();
		protected var _position:Point = new Point();
		protected var _camVec:MathVector = new MathVector();
		
		protected var _radius_affects_volume:Boolean = true;
		protected var _position_affects_panning:Boolean = true;
		
		//volume multiplier
		public var volume:Number = 1;
		
		//fade multiplier
		public var fadeVolume:Number = 1;
		
		public var flags:BitFlag;
		
		public static var panAdjust:Function = easeInQuad;
		public static var volAdjust:Function = easeOutQuad;
		
		public function GameSoundComponent(name:String) 
		{
			flags = new BitFlag();
			name = name;
		}
		
		public function initialize():void
		{
			_ce = GameEngine.instance;
			_soundSystem = GameSoundSystem.getInstance();
		}
		
		/**
		 * called by SephiusEngineSoundSystem before camVec is calculated and the normal update
		 */
		public function updatePosition():void { }
		
		public function updateSoundInstance(SephiusEngineSoundInstance:GameSoundInstance):void
		{
			if (_type == SoundComponentType.POINT)
			{
				var distance:Number = _camVec.length;
				
				if (_radius_affects_volume)
				{
					var volume:Number = distance > _radius ? 0 : 1 - distance / _radius;
					SephiusEngineSoundInstance.volume = adjustVolume(volume);
				}
				
				if (_position_affects_panning && _soundSystem.camera)
				{
					var panning:Number = (Math.cos(_camVec.angle) * distance) / 
						( (_soundSystem.camera.cameraLensWidth / _soundSystem.camera.camProxy.scale) * 0.5 );
					SephiusEngineSoundInstance.panning = adjustPanning(panning);
				}
			}
		}
		
		public function adjustPanning(value:Number):Number
		{
			if (value <= -1)
				return -1;
			else if (value >= 1)
				return 1;
			
			if (value < 0)
				return -panAdjust(-value, 0, 1, 1);
			else if (value > 0)
				return panAdjust(value, 0, 1, 1);
			return value;
		}
		
		public function adjustVolume(value:Number):Number
		{
			if (value <= 0)
				return 0;
			else if (value >= 1)
				return 1 * volume * fadeVolume;
				
			return volAdjust(value, 0, 1, 1) * volume * fadeVolume;
		}
		
		public function update(timeDelta:Number):void
		{
			
		}
		
		protected function log(message:String=""):void
		{
			
		}
		
		public function destroy():void
		{
			flags.destroy();
			_soundSystem = null;
			_ce = null;
		}
		
		public function get type():int
		{
			return _type;
		}
		
		public function get position():Point
		{
			return _position;
		}
		
		public function set position(value:Point):void
		{
			_position = value;
		}
		
		public function get radius():Number
		{
			return _radius;
		}
		
		public function set radius(value:Number):void
		{
			_radius = value;
		}
		
		public function get camVec():MathVector
		{
			return _camVec;
		}
		
		public function set camVec(value:*):void
		{
			if (value is Point)
			{
				_camVec.x = value.x;
				_camVec.y = value.y;
			}else (value is MathVector)
			{
				_camVec = value as MathVector;
			}
		}
		
		public static function easeInQuad(t:Number, b:Number, c:Number, d:Number):Number {return c*(t/=d)*t + b;};
		public static function easeOutQuad(t:Number, b:Number, c:Number, d:Number):Number {return -c *(t/=d)*(t-2) + b;};
		public static function easeInCubic(t:Number, b:Number, c:Number, d:Number):Number {return c*(t/=d)*t*t + b;};
		public static function easeOutCubic(t:Number, b:Number, c:Number, d:Number):Number {return c*((t=t/d-1)*t*t + 1) + b;};
		public static function easeInQuart(t:Number, b:Number, c:Number, d:Number):Number {return c*(t/=d)*t*t*t + b;};
		public static function easeOutQuart(t:Number, b:Number, c:Number, d:Number):Number {return -c * ((t=t/d-1)*t*t*t - 1) + b;};
		
	}

}