package SephiusEngine.input.controllers.gamepad{
	import SephiusEngine.input.InputActionsNames;
	import SephiusEngine.input.InputController;
	import SephiusEngine.input.controllers.gamepad.controls.ButtonController;
	import SephiusEngine.input.controllers.gamepad.controls.Icontrol;
	import SephiusEngine.input.controllers.gamepad.controls.StickController;
	import SephiusEngine.input.controllers.gamepad.maps.PlaystationGamepadMapA;
	import SephiusEngine.input.controllers.gamepad.maps.PlaystationGamepadMapB;
	import SephiusEngine.input.controllers.gamepad.maps.GamePadMap;
	import SephiusEngine.input.controllers.gamepad.maps.XboxGamepadMapA;
	import SephiusEngine.input.controllers.gamepad.maps.XboxGamepadMapB;
	import flash.events.Event;
	import flash.ui.GameInputControl;
	import flash.ui.GameInputDevice;
	import flash.utils.Dictionary;
	
	public class Gamepad extends InputController{
		
		protected var _device:GameInputDevice;
		protected var _deviceID:String;
		
		/**
		 * GameInputControls for the GameInputDevice, indexed by their id.
		 */
		protected var _controls:Dictionary;
		
		/**
		 * button controller used, indexed by name.
		 */
		protected var _buttons:Dictionary;
		
		/**
		 * stick controller used, indexed by name.
		 */
		protected var _sticks:Dictionary;
		
		/**
		 * controls being used, indexed by GameInputControl.id
		 * (quick access for onChange)
		 */
		protected var _usedControls:Dictionary;
		
		/**
		 * will trace information on the gamepad at runtime.
		 */
		public var debug:Boolean = false;
		
		/**
		 * if set to true, all 'children controllers' will send an action with their controller name when active (value != 0) 
		 * helps figuring out which button someone touches for remapping in game for example.
		 */
		public var triggerActivity:Boolean = true;
		
		/**
		 * key = substring in devices id/name to recognize
		 * value = map class
		 */
		public static var devicesMapsA:Dictionary;
		public static var devicesMapsB:Dictionary;
		public var map:GamePadMap;
		
		/** FOR GAMEPADS: Mode 0 use DPad for movement, Analogs for camera/item changing/interactions. Control Mode 1 uses analogs for movement and Dpad for camera/item changing/interactions. 
		 * FOR MOUSE AND KEYBOARDS: Mode 0 use only keyboard and UP/DOWN/LEFT/RIGHT for movment. Mode 1 Uses AWSD for movement, mouse buttons for attacks. 
		 * Middle Buttom for change attack type (weapons/spells)  */
		public function get controlMode():int {return _controlMode;}
		public function set controlMode(value:int):void {
			_controlMode = value;
			setActions();
		}
		private var _controlMode:int = 0;
		
		public function Gamepad(name:String, device:GameInputDevice, controlMode:int=0, params:Object = null){
			super(name, params);
			
			if(!devicesMapsA)
				initDevicesMaps();
			
			_device = device;
			_deviceID = _device.id;
			_controls = new Dictionary();
			
			enabled = true;
			initControlsList();
			
			_buttons = new Dictionary();
			_sticks = new Dictionary();
			
			_usedControls = new Dictionary();
			
			_controlMode = controlMode;
			setActions();
		}
		
		public function setActions():void {
			resetAllActions();
			apllyMap();
			
			if (map == null)
				return;
			
			if (!device)
				throw Error("Gamepad has no device. why?");
			
			trace("GAMEPAD SETUP:", device.name, deviceID, enabled);	
			
			if(_controlMode == 0){
				//Dpad used to move character
				addButtonAction(map.LEFT, InputActionsNames.LEFT);
				addButtonAction(map.RIGHT, InputActionsNames.RIGHT);
				addButtonAction(map.UP, InputActionsNames.UP);
				addButtonAction(map.DOWN , InputActionsNames.DOWN);

				//Dpad used to fly up and down
				addButtonAction(map.UP, InputActionsNames.FLY_UP);
				addButtonAction(map.DOWN, InputActionsNames.FLY_DOWN);

				//Stick will be used to make those actions
				addStickActions(map.MOVEMENT, InputActionsNames.INTERACTION, InputActionsNames.TOGGLE_ITEM_RIGHT, InputActionsNames.FAST_MAP, InputActionsNames.TOGGLE_ITEM_LEFT);
			}
			else{
				//Stick will be used to move character
				addStickActions(map.MOVEMENT, InputActionsNames.UP, InputActionsNames.RIGHT, InputActionsNames.DOWN, InputActionsNames.LEFT);

				addButtonAction(map.INTERACTION, InputActionsNames.INTERACTION);
				addButtonAction(map.TOGGLE_ITEM_LEFT, InputActionsNames.TOGGLE_ITEM_LEFT);
				addButtonAction(map.TOGGLE_ITEM_RIGHT, InputActionsNames.TOGGLE_ITEM_RIGHT);
				addButtonAction(map.FAST_MAP, InputActionsNames.FAST_MAP);
			}

			//Actions
			addButtonAction(map.WEAPON_1, InputActionsNames.WEAPON_1 );
			addButtonAction(map.WEAPON_2, InputActionsNames.WEAPON_2);
			addButtonAction(map.SPELL_1, InputActionsNames.SPELL_1);
			addButtonAction(map.SPELL_2, InputActionsNames.SPELL_2);
			addButtonAction(map.USE_ITEM, InputActionsNames.USE_ITEM);

			addButtonAction(map.JUMP, InputActionsNames.JUMP);
			addButtonAction(map.GLIDING, InputActionsNames.GLIDING);
			addButtonAction(map.ABSORPTION, InputActionsNames.ABSORPTION);
			addButtonAction(map.FLY, InputActionsNames.FLY);
			addButtonAction(map.DODGE, InputActionsNames.DODGE);
			addButtonAction(map.FLAP_WINGS_A , InputActionsNames.FLAP_WINGS_A);

			// Camera
			addStickActions(map.CAMERA, InputActionsNames.CAMERA_INWARD, null, InputActionsNames.CAMERA_OUTWARD, null);

			//Rings
			addButtonAction(map.SPELL_RING, InputActionsNames.SPELL_RING);
			//addButtonAction(map.ITEM_RING, InputActionsNames.ITEM_RING); //Item ring was removed due incompatibility with other controlls
			addButtonAction(map.WEAPON_RING, InputActionsNames.WEAPON_RING);

			//addButtonAction(map.RINGS, InputActionsNames.RINGS); //Rings on 
			//addButtonAction(map.RINGS2, InputActionsNames.RINGS2);

			addStickActions(map.MOVEMENT, InputActionsNames.INTERFACE_UP, InputActionsNames.INTERFACE_RIGHT, InputActionsNames.INTERFACE_DOWN, InputActionsNames.INTERFACE_LEFT);
			addButtonAction(map.INTERFACE_UP, InputActionsNames.INTERFACE_UP);
			addButtonAction(map.INTERFACE_DOWN, InputActionsNames.INTERFACE_DOWN);
			addButtonAction(map.INTERFACE_LEFT, InputActionsNames.INTERFACE_LEFT);
			addButtonAction(map.INTERFACE_RIGHT, InputActionsNames.INTERFACE_RIGHT);

			addButtonAction(map.INTERFACE_START, InputActionsNames.INTERFACE_START );

			addButtonAction(map.INTERFACE_CONFIRM, InputActionsNames.INTERFACE_CONFIRM);
			addButtonAction(map.INTERFACE_CANCEL, InputActionsNames.INTERFACE_CANCEL);

			addButtonAction(map.INTERFACE_EXIT, InputActionsNames.INTERFACE_EXIT );

			addButtonAction(map.INTERFACE_NEXT, InputActionsNames.INTERFACE_NEXT );
			addButtonAction(map.INTERFACE_PREVIOUS, InputActionsNames.INTERFACE_PREVIOUS );

			addButtonAction(map.INTERFACE_MENU_INFO,InputActionsNames.INTERFACE_MENU_INFO);
			addButtonAction(map.INTERFACE_PAUSE,InputActionsNames.INTERFACE_PAUSE);
		}
		
		/**
		 * list all available controls by their control.id and start caching.
		 */
		protected function initControlsList():void{
			var controlNames:Vector.<String> = new Vector.<String>();
			var control:GameInputControl;
			var i:int = 0;
			var numcontrols:int = _device.numControls;
			for (i; i < numcontrols; i++)
			{
				control = _device.getControlAt(i);
				_controls[control.id] = control;
				controlNames.push(control.id);
			}
			
			if(controlNames.length > 0)
				_device.startCachingSamples(30, controlNames);
		}
		
		/**
		 * creates the dictionary for default game pad maps to apply.
		 * key = substring in GameInputDevice.name to look for,
		 * value = GamePadMap class to use for mapping the game pad correctly.
		 */
		protected function initDevicesMaps():void{
			devicesMapsA = new Dictionary();
			devicesMapsA["Microsoft X-Box 360"] = new XboxGamepadMapA();
			devicesMapsA["Xbox 360 Controller"] = new XboxGamepadMapA();
			
			devicesMapsA["PLAYSTATION"] = new PlaystationGamepadMapA();
			devicesMapsA["Wireless Controller"] = new PlaystationGamepadMapA()
			devicesMapsA["MotioninJoy Virtual Game Controller"] = new PlaystationGamepadMapA();
			devicesMapsA["DualSense Wireless Controller"] = new PlaystationGamepadMapA();
			
			devicesMapsB = new Dictionary();
			devicesMapsB["Microsoft X-Box 360"] = new XboxGamepadMapB();
			devicesMapsB["Xbox 360 Controller"] = new XboxGamepadMapB();
			
			devicesMapsB["PLAYSTATION"] = new PlaystationGamepadMapB();
			devicesMapsB["Wireless Controller"] = new PlaystationGamepadMapB()
			devicesMapsB["MotioninJoy Virtual Game Controller"] = new PlaystationGamepadMapB();
			devicesMapsB["DualSense Wireless Controller"] = new PlaystationGamepadMapB();
		}
		
		/**
		 * apply GamepadMap
		 * @param	map
		 */
		public function apllyMap():void{
			var substr:String;
			for (substr in devicesMapsA){
				if (device.name.indexOf(substr) > -1 || device.id.indexOf(substr) > -1){
					if(controlMode == 0)
						map = devicesMapsA[substr] as GamePadMap;
					else
						map = devicesMapsB[substr] as GamePadMap;
				}
			}
			
			if (map != null)
				map.setup(this);
			
			stopAllActions();
		}
		
		protected function onChange(e:Event):void{
			if (!(e.currentTarget.id in _usedControls)){
				if(debug)
					trace(e.target.id, "seems to not be bound to any controls for", this);
				return;
			}
			
			var id:String = (e.currentTarget as GameInputControl).id;
			var value:Number = (e.currentTarget as GameInputControl).value;
			
			var icontrols:Vector.<Icontrol> = _usedControls[id];
			var icontrol:Icontrol;
			
			for each (icontrol in icontrols)
					icontrol.updateControl(id, value);
		}
		
		protected function bindControl(controlid:String, controller:Icontrol):void{
			if (!(controlid in _controls)){
				if(debug)
					trace(this, "trying to bind", controlid, "but", controlid, "is not in listed controls for device", _device.name);
				return;
			}
			
			var control:GameInputControl = (_controls[controlid] as GameInputControl);
			
			if (!control.hasEventListener(Event.CHANGE))
				control.addEventListener(Event.CHANGE, onChange);
			
			if (!(controlid in _usedControls))
				_usedControls[controlid] = new Vector.<Icontrol>();
			
			if(debug)
				trace("Binding", control.id, "to", controller, controlid in _usedControls);
			
			(_usedControls[controlid] as Vector.<Icontrol>).push(controller);
		}
		
		protected function unbindControl(controlid:String, controller:Icontrol):void{
			if (!(controlid in _usedControls)){
				if (_usedControls[controlid] is Vector.<Icontrol>){
					var controls:Vector.<Icontrol> = _usedControls[controlid];
					var icontrol:Icontrol;
					var i:String;
					for (i in controls){
						icontrol = controls[int(i)];
						if (icontrol == controller){
							controls.splice(int(i), 1);
							break;
						}
					}
					
					if (controls.length == 0){
						delete _usedControls[controlid];
						
						if (_controls[controlid].hasEventListener(Event.CHANGE, onChange))
							_controls[controlid].removeEventListener(Event.CHANGE, onChange);
					}
				}
			}
		}
		
		public function unregisterStick(name:String):void{
			var stick:StickController;
			stick = _sticks[name];
			if (stick){
				unbindControl(stick.hAxis, stick);
				unbindControl(stick.vAxis, stick);
				delete _sticks[name];
				stick.destroy();
			}
		}
		
		public function unregisterButton(name:String):void{
			var button:ButtonController;
			button = _buttons[name];
			if (button)
			{
				unbindControl(button.controlID, button);
				delete _buttons[name];
				button.destroy();
			}
		}
		
		/**
		 * Register a new stick controller to the gamepad.
		 * leave all or any of up/right/down/left actions to null for these directions to trigger nothing.
		 * invertX and invertY inverts the axis values.
		 * @param	name
		 * @param	hAxis the GameInputControl id for the horizontal axis (left to right).
		 * @param	vAxis the GameInputControl id for the vertical axis (up to donw).
		 * @param	up
		 * @param	right
		 * @param	down
		 * @param	left
		 * @param	invertX
		 * @param	invertY
		 * @return
		 */
		public function registerStick(name:String, hAxis:String, vAxis:String, up:String = null, right:String = null, down:String = null, left:String = null, invertX:Boolean = false, invertY:Boolean = false):StickController{
			if (name in _sticks)
			{
				if(debug)
					trace(this + " joystick control " + name + " already exists");
				return _sticks[name];
			}
			
			var joy:StickController = new StickController(name,this, hAxis, vAxis, up, right, down, left, invertX, invertY);
			bindControl(hAxis, joy);
			bindControl(vAxis, joy);
			return _sticks[name] = joy;
		}
		
		/**
		 * Register a new button controller to the gamepad.
		 * if action is null, this button will trigger no action.
		 * @param	name
		 * @param	control_id the GameInputControl id.
		 * @param	action
		 * @return
		 */
		public function registerButton(name:String, control_id:String, action:String = null):ButtonController{
			if (name in _buttons){
				if(debug)
					trace(this + " button control " + name + " already exists");
				return _buttons[name];
			}
			var button:ButtonController = new ButtonController(name,this, control_id, [action]);
			bindControl(control_id, button);
			return _buttons[name] = button;
		}
		
		
		/**
		 * Set a registered stick's actions, leave null to keep unchanged.
		 * @param	name
		 * @param	up
		 * @param	right
		 * @param	down
		 * @param	left
		 */
		public function addStickActions(name:String, up:String, right:String, down:String, left:String):void{
			if (!(name in _sticks)){
				trace(this + "cannot set joystick control, " + name + " is not registered.");
				return;
			}
			
			var joy:StickController = _sticks[name] as StickController;
			
			if(up && joy.upAction.indexOf(up) == -1)
				joy.upAction.push(up);
			if(down && joy.downAction.indexOf(down) == -1)	
				joy.downAction.push(down);
			if(left && joy.leftAction.indexOf(left) == -1)
				joy.leftAction.push(left);
			if(right && joy.rightAction.indexOf(right) == -1)
				joy.rightAction.push(right);
		}
		
		/**
		 * Set a registered button controller action.
		 * @param	name 
		 * @param	action
		 */
		public function setButtonAction(name:String, action:String):void{
			if (!(name in _buttons)){
				throw new Error(this + " cannot set button control, " + name + " is not registered.");
				return;
			}
			
			(_buttons[name] as ButtonController).action = [action];
		}
		
		public function addButtonAction(name:String, action:String):void{
			if (!(name in _buttons)){
				throw new Error(this + " cannot set button control, " + name + " is not registered.");
				return;
			}
			
			var buttonControl:ButtonController = (_buttons[name] as ButtonController);
			
			if ( !(buttonControl.action is Array) || buttonControl.action == null)
				buttonControl.action = [action];
			else 
				buttonControl.action.push(action);
		}
		
		public function removeButtonAction(name:String, action:String):void{
			if (!(name in _buttons)){
				throw new Error(this + " cannot set button control, " + name + " is not registered.");
				return;
			}
			var buttonControl:ButtonController = (_buttons[name] as ButtonController);
			
			var i:int = buttonControl.action.indexOf(action);
			if(i > -1)
				buttonControl.action.splice(i, 1);
		}
		
		/**
		 * run through all defined controllers and just null actions.
		 */
		public function resetAllActions():void{
			var stickC:StickController;
			for each(stickC in _sticks){
				stickC.upAction = null;
				stickC.rightAction = null;
				stickC.leftAction = null;
				stickC.downAction = null;
			}
			
			var buttonC:ButtonController;
			for each(buttonC in _buttons){
				buttonC.action = null;
			}
		}
		
		
		/**
		 * get registered stick as a StickController to get access to the angle of the joystick for example.
		 * @param	name
		 * @return
		 */
		public function getStick(name:String):StickController{
			if (name in _sticks)
				return _sticks[name] as StickController;
			return null;
		}
		
		/**
		 * get added button as a ButtonController
		 * @param	name
		 * @return
		 */
		public function getButton(name:String):ButtonController{
			if (name in _buttons)
				return _buttons[name] as ButtonController;
			return null;
		}
		
		public function get device():GameInputDevice{ return _device;}
		
		public function get deviceID():String{return _deviceID;}
		
		public function stopAllActions():void{
			var icontrols:Vector.<Icontrol>;
			var icontrol:Icontrol;
			
			for each (icontrols in _usedControls)
				for each (icontrol in icontrols)
					_ge.input.stopActionsOf(icontrol as InputController);
		}
		
		override public function set enabled(val:Boolean):void{_device.enabled = _enabled = val;}
		
		override public function destroy():void{
			var control:Icontrol;
			for each (control in _buttons)
				unregisterButton((control as InputController).name);
			for each (control in _sticks)
				unregisterButton((control as InputController).name);
			
			_usedControls = null;
			_controls = null;
			
			enabled = false;
			
			_input.stopActionsOf(this);
			
			_buttons = null;
			_sticks = null;
			
			super.destroy();
		}
	}
}