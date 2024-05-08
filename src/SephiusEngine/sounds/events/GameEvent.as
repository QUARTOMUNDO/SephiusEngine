package SephiusEngine.sounds.events 
{
	public class GameEvent 
	{
		internal var _type:String;
		internal var _phase:int = CAPTURE_PHASE;
		internal var _bubbles:Boolean = true;
		internal var _cancelable:Boolean = false;
		internal var _target:GameEventDispatcher;
		internal var _currentTarget:GameEventDispatcher;
		internal var _currentListener:Function;
		
		public function GameEvent(type:String, bubbles:Boolean = true, cancelable:Boolean = false) 
		{
			_type = type;
			_bubbles = bubbles;
			_cancelable = cancelable;
		}
		
		protected function setTarget(object:*):void
		{
			_target = object;
		}
		
		public function clone():GameEvent
		{
			var e:GameEvent = new GameEvent(_type,_bubbles,_cancelable);
			e._target = e._currentTarget = _currentTarget;
			return e;
		}
		
		public function get type():String {	return _type;}
		public function get phase():int {	return _phase;}
		public function get bubbles():Boolean {	return _bubbles;}
		public function get cancelable():Boolean {	return _cancelable;}
		public function get target():GameEventDispatcher {	return _target;}
		public function get currentTarget():GameEventDispatcher {	return _currentTarget;}
		public function get currentListener():Function {	return _currentListener;}
		
		public function toString():String
		{
			return "[SephiusEngineEvent type:" + _type + " target:" + Object(_target).constructor +" currentTarget:"+ Object(_currentTarget).constructor +" phase:" + _phase + " bubbles:" + _bubbles +" cancelable:" + _cancelable + " ]";
		}
		
		public static var CAPTURE_PHASE:int = 0;
		public static var AT_TARGET:int = 1;
		public static var BUBBLE_PHASE:int = 2;

		
	}

}