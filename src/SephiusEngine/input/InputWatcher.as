package SephiusEngine.input 
{
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.input.InputAction;
	import SephiusEngine.input.InputPhase;
	import SephiusEngine.input.controllers.gamepad.Gamepad;
	import SephiusEngine.input.controllers.gamepad.controls.StickController;
	import SephiusEngine.input.controllers.gamepad.maps.GamePadMap;

	import flash.utils.Dictionary;

	import org.osflash.signals.Signal;
	import SephiusEngine.input.controllers.Mouse;
	/**
	 * Store information about input and phases in a easy and light way
	 * @author Fernando Rabello
	 */
	public class InputWatcher {
		public var inputChannel:int;
		/** Game devices witch controls objects related with inputChannel */
		public var gameDevices:Vector.<Gamepad> = new Vector.<Gamepad>();
		/** Store controllers from gameDevices related with inputChannel */
		public var controllers:Dictionary = new Dictionary();
		private var _ge:GameEngine;
		private var _cAction:InputAction;
		private var _actions:Dictionary = new Dictionary();
		
		public var onControllerAdded:Signal = new Signal(String);
		public var onControllerRemoved:Signal = new Signal(String);
		
		public function enableControls():void { controlsEnabled = true; }
		public function disableControls():void { controlsEnabled = false; }
		
		public function get controlsEnabled():Boolean {return _controlsEnabled;}
		public function set controlsEnabled(value:Boolean):void {
			_controlsEnabled = value;
		}
		protected var _controlsEnabled:Boolean = true;
		
		public var currentMap:GamePadMap;
		
		public var controlMode:int = 0;
		
		public var stickControllerLeft:StickController;
		public var stickControllerRight:StickController;
		
		public function InputWatcher(inputChannel:int = -1) {
			this.inputChannel = inputChannel;
			_ge = GameEngine.instance;
			
			_ge.gamePadManager.onControllerAdded.add(addController);
			_ge.gamePadManager.onControllerRemoved.add(removeController);
			
			addController(_ge.gamePadManager.getGamePadByChannel(inputChannel));
			
			controlMode = _ge.gamePadManager.channelModes[inputChannel == -1 ? 0 : inputChannel];
			
			if(gameDevices.length > 0)
				changeDevice(gameDevices[gameDevices.length - 1].device.name);
			else
				changeDevice("None");
		}
		
		public function update():void {
			if (justDid(InputActionsNames.ATTACK_MODIFIER)){
				Mouse.MODIFICATION_ACTIVE = !Mouse.MODIFICATION_ACTIVE;
			}
		}
		
		public var deviceName:String = "None";
		public var deviceButtomsName:String = "KeyboardBlack";
		public var mouseButtomsName:String = "KeyboardBlackMouse";
		private function changeDevice(controllerName:String):void {
			deviceName = controllerName;
			
			switch(deviceName) {
				case "Wireless Controller":
				case "DualSense Wireless Controller":
				case "PLAYSTATION(R)3 Controller":
				case "PLAYSTATION":
				case "USB Joystick         ":
					deviceButtomsName = "PS4";
					break;
				case "Microsoft X-Box 360":
				case "Xbox 360 Controller":
				case "XBOX One For Windows":
				case "Xbox 360 Controller (XInput STANDARD GAMEPAD)":
					deviceButtomsName = "XboxOne";
					break;
				default:
					deviceButtomsName = "KeyboardBlack";
					break;
			}
			
			if(deviceButtomsName != "KeyboardBlack"){
				stickControllerLeft = getStickController(GamePadMap.LEFT_STICK);
				stickControllerRight = getStickController(GamePadMap.RIGHT_STICK);
			}
			else{
				stickControllerLeft = null;
				stickControllerRight = null;
			}
		}
		
		public function addController(controller:Gamepad):void {
			if(!controller || controller.defaultChannel != inputChannel)
				return;

			if (gameDevices.lastIndexOf(controller) < 0) {
				gameDevices.push(controller);
				changeDevice(controller.device.name);
				currentMap = controller.map;
				onControllerAdded.dispatch(controller.device.name);
				//currentMap = controller.map;
			}
		}
		
		public function removeController(controller:Gamepad):void{
			var i:int = gameDevices.lastIndexOf(controller);
			gameDevices.splice(i, 1);
			changeDevice("None");
			onControllerRemoved.dispatch("None");
			//currentMap = null;
		}
		
		public function getStickController(controllerName:String):StickController {
			if (!controllers[controllerName])
				controllers[controllerName] = _ge.input.getControllerByName(controllerName);
			return controllers[controllerName] as StickController;
		}
		
		public function isDoingAnything():Boolean {
			if(!_controlsEnabled)
				return false;
			
			if (_ge.input.actions.length > 0)
				return true;
			else
				return false;
		}
		
		private var channelNumber:String;
		/** Return true if the current action is trigged on by more than one frame*/
		public function isDoing(actionName:String):Boolean {
			if(!_controlsEnabled)
				return false;
			
			if(inputChannel == -1){
				if (!_ge.input.actionsByNameByChannel[actionName])
					return false;
				
				for (channelNumber in _ge.input.actionsByNameByChannel[actionName]) {
					_actions = _ge.input.actionsByNameByChannel[actionName];
					
					if (_actions){
						_cAction = _actions[channelNumber];
						
						return _cAction ? _cAction.time > 1 && _cAction.phase < InputPhase.END : false;
					}
				}
				
				return false;
			}
			else{
				_ge.input.getActions
				_actions = _ge.input.actionsByChannelByName[inputChannel]; 
				
				if (!_actions)
					return false;
				
				_cAction = _actions[actionName];
				
				return _cAction ? _cAction.time > 1 && _cAction.phase < InputPhase.END : false;
			}
		}
		
		/** Return true if the current action was trigged on on last frame */
		public function justDid(actionName:String):Boolean {
			if(!_controlsEnabled)
				return false;
			
			if(inputChannel == -1){
				if (!_ge.input.actionsByNameByChannel[actionName])
					return false;
				
				for (channelNumber in _ge.input.actionsByNameByChannel[actionName]) {
					_actions = _ge.input.actionsByNameByChannel[actionName];
					
					if (_actions){
						_cAction = _actions[channelNumber];
						
						return _cAction ? _cAction.time == 1 : false;
					}
				}
				
				return false;
			}
			else{	
				_actions = _ge.input.actionsByChannelByName[inputChannel]; 
				
				if (!_actions)
					return false
				
				_cAction = _actions[actionName];
				
				return _cAction ? _cAction.time == 1 : false;
			}
		}
		
		/** Return true if the current action was trigged off on last frame */
		public function hasDone(actionName:String):Boolean {
			if (!_controlsEnabled) {
				return false;
			}
			
			if(inputChannel == -1){
				if (!_ge.input.actionsByNameByChannel[actionName])
					return false;
				
				for (channelNumber in _ge.input.actionsByNameByChannel[actionName]) {
					_actions = _ge.input.actionsByNameByChannel[actionName];
					
					if (_actions){
						_cAction = _actions[channelNumber];
						
						return _cAction ? _cAction.phase == InputPhase.END : false;
					}
				}
				
				return false;
			}
			else{
				_actions = _ge.input.actionsByChannelByName[inputChannel]; 
				
				if (!_actions)
					return false
				
				_cAction = _actions[actionName];
				//if(_cAction && _cAction.phase == InputPhase.END)
					//trace("INPUTMANAGER] " + _cAction ? _cAction.phase : "...")
				return _cAction ? _cAction.phase == InputPhase.END : false;
			}
		}
		
		public function dispose():void {
			_actions = null;
			controllers = null;
			_cAction = null;
		}
	}
}