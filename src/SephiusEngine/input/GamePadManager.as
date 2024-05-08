package SephiusEngine.input {
	import SephiusEngine.input.controllers.gamepad.Gamepad;

	import flash.events.GameInputEvent;
	import flash.ui.GameInput;
	import flash.ui.GameInputDevice;
	import flash.utils.Dictionary;

	import org.osflash.signals.Signal;
	
	public class GamePadManager{
		protected var _gameInput:GameInput;
		
		protected var _gamePads:Dictionary;

		//maximum number of game input devices we can add (as gamepads)
		public var maxPlayers:uint = 1;
		//channel that will be used by the next device plugged in
		protected var _currentChannel:uint = 0;
		
		public var channelIDs:Vector.<Boolean>;
		/** Witch controll mode each controller uses */
		public var channelModes:Vector.<int> = new Vector.<int>();
		
		protected static var _instance:GamePadManager;
		
		/**
		 * dispatches a newly created Gamepad object when a new GameInputDevice is added.
		 */
		public var onControllerAdded:Signal;
		/**
		 * dispatches the Gamepad object corresponding to the GameInputDevice that got removed.
		 */
		public var onControllerRemoved:Signal;
		
		public function GamePadManager(maxPlayers:uint = 1) {
			_instance = this;
			
			channelModes.push(1);
			channelModes.push(1);
			
			if (!GameInput.isSupported){
				trace(this, "GameInput is not supported.");
				return;
			}
			
			channelIDs = new Vector.<Boolean>()
			channelIDs.length = maxPlayers;
			channelIDs.fixed = true;
			
			_gamePads = new Dictionary();
			
			onControllerAdded = new Signal(Gamepad);
			onControllerRemoved = new Signal(Gamepad);
			
			_gameInput = new GameInput();
			_gameInput.addEventListener(GameInputEvent.DEVICE_ADDED, handleDeviceAdded);
			_gameInput.addEventListener(GameInputEvent.DEVICE_UNUSABLE, handleDeviceAdded);
			_gameInput.addEventListener(GameInputEvent.DEVICE_REMOVED, handleDeviceRemoved);
		}
		
		public static function getInstance():GamePadManager{return _instance;}
		
		/**
		 * return the first gamePad using the defined channel.
		 * @param	channel
		 * @return
		 */
		public function getGamePadByChannel(channel:uint = 0):Gamepad{
			var pad:Gamepad;
			for each(pad in _gamePads)
				if (pad.defaultChannel == channel)
					return pad;
			return pad;
		}
		
		protected var numDevicesAdded:int = 0;
		
		protected function handleDeviceUnusable(e:GameInputEvent):void {
			trace("GAMEPAD: " + e.device.name +" unsusable");
		}
		
		private var i:uint;
		protected function handleDeviceAdded(e:GameInputEvent):void {
			
			var device:GameInputDevice = e.device;
			var deviceID:String = device.id;
			var pad:Gamepad;
			trace(e.device.name + " detected");
			
			if (deviceID in _gamePads){
				trace(deviceID, "already added");
				return;
			}
			
			//Assign a channel not used by other controllers
			_currentChannel = maxPlayers -1;
			for (i = 0; i < channelIDs.length; i++ ) {
				if (!channelIDs[i]){
					_currentChannel = i;
					channelIDs[i] = true;
					break;
				}
			}
			
			pad = new Gamepad(device.name + "_" + numDevicesAdded, device, channelModes[_currentChannel] );
			pad.defaultChannel = _currentChannel;

			numDevicesAdded++;
			
			_gamePads[pad.deviceID] = pad;
			onControllerAdded.dispatch(pad);
		}
		
		protected function handleDeviceRemoved(e:GameInputEvent):void{
			numDevicesAdded--;
			var id:String;
			var pad:Gamepad;
			for (id in _gamePads){
				pad = _gamePads[id];
				if (pad.device == e.device)
					break;
			}
			
			if (!pad)
				return;
			
			channelIDs[pad.defaultChannel] = false;
			
			delete _gamePads[id];
			pad.destroy();
			onControllerRemoved.dispatch(pad);
		}
		
		public function destroy():void{
			_gameInput.removeEventListener(GameInputEvent.DEVICE_ADDED, handleDeviceAdded);
			_gameInput.removeEventListener(GameInputEvent.DEVICE_REMOVED, handleDeviceRemoved);
			
			var gp:Gamepad;
			for each(gp in _gamePads)
				gp.destroy();
			_gamePads.length = 0;
			channelIDs.length = 0;
			onControllerAdded.removeAll();
			onControllerRemoved.removeAll();
		}
		
		public function get numGamePads():int{
			return _gamePads.length;
		}
		
		public static const GAMEPAD_ADDED_ACTION:String = "GAMEPAD_ADDED_ACTION";
		public static const GAMEPAD_REMOVED_ACTION:String = "GAMEPAD_REMOVED_ACTION";
	}
}