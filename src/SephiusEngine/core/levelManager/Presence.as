package SephiusEngine.core.levelManager 
{
	import SephiusEngine.core.levelManager.LevelArea;
	import SephiusEngine.core.levelManager.LevelSite;
	import SephiusEngine.core.levelManager.RegionBase;
	import adobe.utils.ProductManager;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.gameStates.LevelManager;
	import tLotDClassic.attributes.AttributesConstants;
	import SephiusEngine.levelObjects.levelManager.ScreenViewSensor;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import nape.geom.Vec2;
	import org.osflash.signals.Signal;
	import starling.extensions.brinkbit.fullscreenscreenextension.FullScreenExtension;
	/**
	 * Deals with some player presence on the world. If player is on a dark ou light place, witch area he is and with is the areas he should see and etc.
	 * @author Fernando Rabello
	 */
	public class Presence {
		public var onPlaceNatureChanged:Signal = new Signal(String);
		public var onPlaceAreaChanged:Signal = new Signal(LevelArea);
		public var onPlaceSiteChanged:Signal = new Signal(LevelSite);
		public var onLastPlaceAreaChanged:Signal = new Signal(LevelArea);
		public var onRegionBaseChanged:Signal = new Signal(RegionBase);
		
		public function get parent():Object {return _parent;}
		public function set parent(value:Object):void {
			_parent = value;
		}
		
		private var _parent:Object;
		
		public var positionX:Number;
		public var positionY:Number;
		
		public var bounds:Rectangle = new Rectangle();
		public var useBounds:Boolean = false;
		
		public var controlLevel:Boolean = false;
		public var perceiveObjects:Boolean = false;
		
		public static const PRESENCES_IN_USE:Vector.<Presence> = new Vector.<Presence>();
		
		private var _placeNature:String;
		private var _placeArea:LevelArea;
		private var _placeSite:LevelSite;
		private var _lastPlaceArea:LevelArea;
		private var _lastRegionBase:RegionBase;
		
		private var _distanceTraveled:Number = 0;
		private var _timePlayed:String = "0:0:00";
		private var _totalTimePlayedNumber:Number = 0;
		private var _currentTimePlayedNumber:Number = 0;
		private var _previousPlayedNumber:Number = 0;
		private var _startTime:Number = 0;
		
		private var _timePlayedSeconds:int = 0;
		private var _timePlayedMinutes:int = 0;
		private var _timePlayedHours:int = 0;
		
		public var lastPosition:Vec2 = new Vec2();
		private var _currentPoition:Vec2 = new Vec2();
		private var _positionDifferance:Vec2 = new Vec2();
		
		public function ereaseValues():void {
			parent = null;
			_placeNature = null;
			_placeArea = null;
			_placeSite = null;
			_lastPlaceArea = null;
			_lastRegionBase = null;
		}
		
		private var _lm:LevelManager;
		public function Presence(parent:Object = null, useBounds:Boolean=false, controlLevel:Boolean=false, perceiveObjects:Boolean = false) {
			if(parent)
				this.parent = parent;
			
			_lm = LevelManager.getInstance();
			
			this.useBounds = useBounds;
			this.controlLevel = controlLevel;
			this.perceiveObjects = perceiveObjects;
			
			_startTime = GameEngine.instance.state.totalTime;
		}
		
		/** Area where this parent actually is */
		public function get placeArea():LevelArea { return _placeArea; }
		public function set placeArea(value:LevelArea):void {
			if (!value || _placeArea == value)
				return;
			
			lastPlaceArea = _placeArea;
			_placeArea = value;
			
			if(controlLevel && _placeArea)
				LevelManager.getInstance().addOrRemoveAreaByGlobalID(_placeArea.globalId, true);
			
			placeSite = value.site;
			onPlaceAreaChanged.dispatch(value);
		}
		
		/** Site where this parent actually is */
		public function get placeSite():LevelSite { return _placeSite; }
		public function set placeSite(value:LevelSite):void {
			if (!value || _placeSite == value)
				return;
			
			_placeSite = value;
			onPlaceSiteChanged.dispatch(_placeArea.site);
		}
		
		/** Last area where this parent was */
		public function get lastPlaceArea():LevelArea { return _lastPlaceArea; }
		public function set lastPlaceArea(value:LevelArea):void {
			if (!value || _lastPlaceArea == value)
				return;
			
			_lastPlaceArea = value;
			onLastPlaceAreaChanged.dispatch(value);
		}
		
		/** Place nature (light or dark) where this parent actually is */
		public function get placeNature():String { return _placeNature; }
		public function set placeNature(value:String):void {
			if (!value || _placeNature == value)
				return;
			_placeNature = value;	
			onPlaceNatureChanged.dispatch(value);
		}
		
		/** Last base player touch. Level bases are coordinates where player saves the game and starts on */
		public function get lastRegionBase():RegionBase { return _lastRegionBase; }
		public function set lastRegionBase(value:RegionBase):void {
			_lastRegionBase = value;
			onRegionBaseChanged.dispatch(value);
		}
		
		/** Return the distance traveled in game units (pixels) */
		public function get distanceTraveled():Number { return _distanceTraveled; }
		public function set distanceTraveled(value:Number):void {
			_distanceTraveled = value;
		}
		
		/** Return the distance traveled in meters of kilometers */
		public function get distanceTraveledMeters():String { return (_distanceTraveled * 1.3) > 100000 ? Number((_distanceTraveled * 1.3) / 100 / 1000).toFixed(2) + "km" : int((_distanceTraveled * 1.3) / 100) + "m"; }
		
		/** Amount of time playerd since game starts */
		public function get timePlayed():String { return _timePlayed; }
		
		/** Amount of time playerd since game from all game sessions */
		public function get totalTimePlayedNumber():Number { return _totalTimePlayedNumber; }
		public function set totalTimePlayedNumber(value:Number):void {
			_totalTimePlayedNumber = value;
		}
		
		/** Amount of time playerd since game starts on this session */
		public function get currentTimePlayedNumber():Number { return _currentTimePlayedNumber; }
		public function set currentTimePlayedNumber(value:Number):void {
			_currentTimePlayedNumber = value;
		}
		
		/** Amount of time playerd since game starts from previous */
		public function get previousPlayedNumber():Number { return _previousPlayedNumber; }
		public function set previousPlayedNumber(value:Number):void {
			_previousPlayedNumber = value;
		}
		
		/** Amount of time playerd since game starts */
		public function get timePlayedSeconds():int { return _timePlayedSeconds; }
		public function get timePlayedMinute():int { return _timePlayedMinutes; }
		public function get timePlayedHours():int { return _timePlayedHours; }
		
		private var h_areaID:uint;
		
		public function reset(startTime:Number = -1, previousPlayedNumber:Number = 0, distanceTraveled:Number = 0):void {
			if(startTime == -1)
				_startTime = GameEngine.instance.state.totalTime;
			else
				_startTime = startTime;
			
			_distanceTraveled = distanceTraveled;
			
			_previousPlayedNumber = previousPlayedNumber;
			
			_timePlayedSeconds = 0;
			_timePlayedMinutes = 0;
			_timePlayedHours = 0;
		}
		
		/** Distance traveled since game starts */
		public function update(positionX:Number, positionY:Number, init:Boolean=false):void { 
			//Determine on witch area player is
			h_areaID = _lm.levelRegion.areaMap.getAreaID(positionX, positionY);
			
			if (h_areaID > _lm.levelRegion.areas.length - 1)
				placeArea = _lm.levelRegion.unknownArea;
			else
				placeArea = _lm.levelRegion.areas[h_areaID];
			
			placeNature = _lm.levelRegion.lumaMap.getPlaceNature(positionX, positionY);
			
			this.positionX = positionX;
			this.positionY = positionY;
			bounds.x = positionX - (bounds.width * .5);
			bounds.y = positionY - (bounds.height * .5);
			
			_currentPoition.x = positionX;
			_currentPoition.y = positionY;
			
			if(!init){
				_positionDifferance.x = _currentPoition.x - lastPosition.x;
				_positionDifferance.y = _currentPoition.y - lastPosition.y;
				
				//Hack: ignore long teleportation travelers
				if (Math.abs(_positionDifferance.length) < 1000)
					_distanceTraveled += Math.abs(_positionDifferance.length);
			}
			
			lastPosition.x = _currentPoition.x;
			lastPosition.y = _currentPoition.y;
			
			//times
			_currentTimePlayedNumber = GameEngine.instance.state.totalTime - _startTime;
			_totalTimePlayedNumber = _currentTimePlayedNumber + _previousPlayedNumber;
			
			_timePlayedSeconds = _totalTimePlayedNumber % 60;
			_timePlayedMinutes = (_totalTimePlayedNumber / 60) % 60;
			_timePlayedHours = (_totalTimePlayedNumber / 60 / 60) % 60;	
			
			_timePlayed = (_timePlayedHours < 10 ? "0" + _timePlayedHours : _timePlayedHours) + ":" + (_timePlayedMinutes < 10 ? "0" + _timePlayedMinutes : _timePlayedMinutes) + ":" + (_timePlayedSeconds < 10 ? "0" + _timePlayedSeconds : _timePlayedSeconds);
		}
	}
}

