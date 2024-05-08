package SephiusEngine.utils 
{
	import flash.utils.getTimer;
	/**
	 * Store information about some processes times
	 * @author Fernando Rabello
	 */
	public class TimeMarks {
		private const UPDATE_INTERVAL:Number = 0.5;
		
		public var numOfEngineSteps:uint = 0;
		
		private var _count:uint = 0;
		public function get count():uint {return _count;}
		public function set count(value:uint):void { _count = value % countMax; }
		
		public const countMax:uint = 60;
		
		public function TimeMarks() {
		}
		
		public var logicTime:Number;
		public var logicTimeSingle:Number;
		private var _logicTimeSingleAcummo:Number = 0;
		private var _logicTimeAcummo:Number = 0;
		private var _logicTimeStepsAcummo:Number = 0;
		private var _logicLastTime:Number;
		private var _logicCurrentTime:Number;
		public function logicCountStepCheck():void {
			_logicCurrentTime = getTimer();
			_logicTimeStepsAcummo += _logicCurrentTime - _logicLastTime;
			_logicLastTime = _logicCurrentTime;
		}
		public function logicCountCheck(checkin:Boolean, stepCount:uint=1):void {
			if(checkin){
				_logicCurrentTime = getTimer();
				_logicLastTime = _logicCurrentTime;
			}
			else {
				_logicTimeAcummo += _logicTimeStepsAcummo;
				_logicTimeSingleAcummo += _logicTimeStepsAcummo / stepCount;
				_logicTimeStepsAcummo = 0;
				if (count == countMax -1){
					logicTime = _logicTimeAcummo / countMax;
					logicTimeSingle = _logicTimeSingleAcummo / countMax;
					_logicTimeAcummo = 0;
					_logicTimeSingleAcummo = 0;
				}
			}
		}
		
		public var starlingTime:Number;
		public var starlingTimeSingle:Number;
		private var _starlingTimeSingleAcummo:Number = 0;
		private var _starlingTimeAcummo:Number = 0;
		private var _starlingTimeStepsAcummo:Number = 0;
		private var _starlingLastTime:Number;
		private var _starlingCurrentTime:Number;
		public function starlingCountStepCheck():void {
			_starlingCurrentTime = getTimer();
			_starlingTimeStepsAcummo += _starlingCurrentTime - _starlingLastTime;
			_starlingLastTime = _starlingCurrentTime;
		}
		public function starlingCountCheck(checkin:Boolean, stepCount:uint=1):void {
			if(checkin){
				_starlingCurrentTime = getTimer();
				_starlingLastTime = _starlingCurrentTime;
			}
			else {
				_starlingTimeAcummo += _starlingTimeStepsAcummo;
				_starlingTimeSingleAcummo += _starlingTimeStepsAcummo / stepCount;
				_starlingTimeStepsAcummo = 0;
				if (count == countMax -1){
					starlingTime = _starlingTimeAcummo / countMax;
					starlingTimeSingle = _starlingTimeSingleAcummo / countMax;
					_starlingTimeAcummo = 0;
					_starlingTimeSingleAcummo = 0;
				}
			}
		}
		
		public var physicTime:Number;
		public var physicTimeSingle:Number;
		private var _physicTimeSingleAcummo:Number = 0;
		private var _physicTimeAcummo:Number = 0;
		private var _physicTimeStepsAcummo:Number = 0;
		private var _physicLastTime:Number;
		private var _physicCurrentTime:Number;
		public function physicCountStepCheck():void {
			_physicCurrentTime = getTimer();
			_physicTimeStepsAcummo += _physicCurrentTime - _physicLastTime;
			_physicLastTime = _physicCurrentTime;
		}
		public function physicCountCheck(checkin:Boolean, stepCount:uint=1):void {
			if(checkin){
				_physicCurrentTime = getTimer();
				_physicLastTime = _physicCurrentTime;
			}
			else {
				_physicTimeAcummo += _physicTimeStepsAcummo;
				_physicTimeSingleAcummo += _physicTimeStepsAcummo / stepCount;
				
				_physicTimeStepsAcummo = 0;
				if (count == countMax -1){
					physicTime = _physicTimeAcummo / countMax;
					physicTimeSingle = _physicTimeSingleAcummo / countMax;
					_physicTimeAcummo = 0;
					_physicTimeSingleAcummo = 0;
				}
			}
		}
		
		public var debugTime:Number;
		private var _debugTimeAcummo:Number = 0;
		private var _debugTimeStepsAcummo:Number = 0;
		private var _debugLastTime:Number;
		private var _debugCurrentTime:Number;
		public function debugCountStepCheck():void {
			_debugCurrentTime = getTimer();
			_debugTimeStepsAcummo += _debugCurrentTime - _debugLastTime;
			_debugLastTime = _debugCurrentTime;
		}
		public function debugCountCheck(checkin:Boolean, stepCount:uint=1):void {
			if(checkin){
				_debugCurrentTime = getTimer();
				_debugLastTime = _debugCurrentTime;
			}
			else {
				_debugTimeAcummo += _debugTimeStepsAcummo;
				
				_debugTimeStepsAcummo = 0;
				if (count == countMax -1){
					debugTime = _debugTimeAcummo / countMax;
					_debugTimeAcummo = 0;
				}
			}
		}
		
		public var viewTime:Number;
		public var viewTimeSingle:Number;
		private var _viewTimeAcummo:Number = 0;
		private var _viewTimeStepsAcummo:Number = 0;
		private var _viewLastTime:Number;
		private var _viewCurrentTime:Number;
		public function viewCountStepCheck():void {
			_viewCurrentTime = getTimer();
			_viewTimeStepsAcummo += _viewCurrentTime - _viewLastTime;
			_viewLastTime = _viewCurrentTime;
		}
		public function viewCountCheck(checkin:Boolean):void {
			if(checkin){
				_viewCurrentTime = getTimer();
				_viewLastTime = _viewCurrentTime;
			}
			else {
				_viewTimeAcummo += _viewTimeStepsAcummo;
				
				_viewTimeStepsAcummo = 0;
				if (count == countMax -1){
					viewTime = _viewTimeAcummo / countMax;
					if(numOfEngineSteps > 0)
						viewTimeSingle = viewTime / numOfEngineSteps;
					_viewTimeAcummo = 0;
				}
			}
		}
		
		public var uiTime:Number;
		private var _uiTimeAcummo:Number = 0;
		private var _uiTimeStepsAcummo:Number = 0;
		private var _uiLastTime:Number;
		private var _uiCurrentTime:Number;
		private var _uiTimeSingleAcummo:Number = 0;
		public var uiTimeSingle:Number;
		public function uiCountStepCheck():void {
			_uiCurrentTime = getTimer();
			_uiTimeStepsAcummo += _uiCurrentTime - _uiLastTime;
			_uiLastTime = _uiCurrentTime;
		}
		public function uiCountCheck(checkin:Boolean, stepCount:uint=1):void {
			if(checkin){
				_uiCurrentTime = getTimer();
				_uiLastTime = _uiCurrentTime;
			}
			else {
				_uiTimeAcummo += _uiTimeStepsAcummo;
				_uiTimeSingleAcummo += _uiTimeStepsAcummo / stepCount;
				
				_uiTimeStepsAcummo = 0;
				if (count == countMax -1){
					uiTime = _uiTimeAcummo / countMax;
					uiTimeSingle = _uiTimeSingleAcummo / countMax;
					_uiTimeAcummo = 0;
					_uiTimeSingleAcummo = 0;
				}
			}
		}
		
		public var inputTime:Number;
		private var _inputTimeAcummo:Number = 0;
		private var _inputTimeStepsAcummo:Number = 0;
		private var _inputLastTime:Number;
		private var _inputCurrentTime:Number;
		public function inputCountStepCheck():void {
			_inputCurrentTime = getTimer();
			_inputTimeStepsAcummo += _inputCurrentTime - _inputLastTime;
			_inputLastTime = _inputCurrentTime;
		}
		public function inputCountCheck(checkin:Boolean):void {
			if(checkin){
				_inputCurrentTime = getTimer();
				_inputLastTime = _inputCurrentTime;
			}
			else {
				_inputTimeAcummo += _inputTimeStepsAcummo;
				
				_inputTimeStepsAcummo = 0;
				if (count == countMax -1){
					inputTime = _inputTimeAcummo / countMax;
					_inputTimeAcummo = 0;
				}
			}
		}
		
		public var renderTime:Number;
		private var _renderTimeAcummo:Number = 0;
		private var _renderTimeStepsAcummo:Number = 0;
		private var _renderLastTime:Number;
		private var _renderCurrentTime:Number;
		public function renderCountStepCheck():void {
			_renderCurrentTime = getTimer();
			_renderTimeStepsAcummo += _renderCurrentTime - _renderLastTime;
			_renderLastTime = _renderCurrentTime;
		}
		public function renderCountCheck(checkin:Boolean):void {
			if(checkin){
				_renderCurrentTime = getTimer();
				_renderLastTime = _renderCurrentTime;
			}
			else {
				_renderTimeAcummo += _renderTimeStepsAcummo;
				
				_renderTimeStepsAcummo = 0;
				if (count == countMax -1){
					renderTime = _renderTimeAcummo / countMax;
					_renderTimeAcummo = 0;
				}
			}
		}
		
		public var lastTime:Number = 0;
		public var currentTime:Number = 0;
		public var pausedTime:Number = 0;
		public var gameTime:Number = 0;
	}
}