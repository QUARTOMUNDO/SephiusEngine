package SephiusEngine.input {

	import SephiusEngine.core.GameEngine;
	import SephiusEngine.input.Input;
	import SephiusEngine.input.InputAction;
	import org.osflash.signals.Signal;
	
	/**
	 * InputController is the parent of all the controllers classes. It provides the same helper that SephiusEngineObject class : 
	 * it can be initialized with a params object, which can be created via an object parser/factory. 
	 */
	public class InputController{
		public static var hideParamWarnings:Boolean = false;
		
		public var name:String;
		public var defaultChannel:uint = 0;
		public var onUpdated:Signal = new Signal();
		
		protected var _ge:GameEngine;
		protected var _input:Input;
		protected var _initialized:Boolean;
		protected var _enabled:Boolean = true;
		protected var _updateEnabled:Boolean = false;
		
		private var action:InputAction;
		
		public function InputController(name:String, params:Object = null){
			this.name = name;
			
			setParams(params);
			
			_ge = GameEngine.instance;
			_input = GameEngine.instance.input;
			
			_input.addController(this);
		}
		
		/**
		 * Override this function if you need your controller to update when SephiusEngineEngine updates the Input instance.
		 */
		public function update():void{
			onUpdated.dispatch();
		}
		
		/**
		 * Will register the action to the Input system as an action with an InputPhase.BEGIN phase.
		 * @param	name string that defines the action such as "jump" or "fly"
		 * @param	value optional value for your action.
		 * @param	message optional message for your action.
		 * @param	channel optional channel for your action. (will be set to the defaultChannel if not set.
		 */
		protected function triggerON(name:String, value:Number = 0,message:String = null, channel:int = -1):InputAction{
			if (_enabled){
				action = InputAction.create(name, this, (channel < 0)? defaultChannel : channel , value, message);
				_input.actionON.dispatch(action);
				//trace("[InputController] Trigging Action ON", name, " value: ",  value, " Channel: ", channel);
				return action;
			}
			return null;
		}
		
		/**
		 * Will register the action to the Input system as an action with an InputPhase.END phase.
		 * @param	name string that defines the action such as "jump" or "fly"
		 * @param	value optional value for your action.
		 * @param	message optional message for your action.
		 * @param	channel optional channel for your action. (will be set to the defaultChannel if not set.
		 */
		protected function triggerOFF(name:String, value:Number = 0,message:String = null, channel:int = -1):InputAction{
			if (_enabled){
				action = InputAction.create(name, this, (channel < 0)? defaultChannel : channel , value, message);
				_input.actionOFF.dispatch(action);
				//trace("[InputController] Trigging Action OFF", name, " value: ",  value, " Channel: ", channel);
				return action;
			}
			return null;
		}
		
		/**
		 * Will register the action to the Input system as an action with an InputPhase.BEGIN phase if its not yet in the 
		 * actions list, otherwise it will update the existing action's value and set its phase back to InputPhase.ON.
		 * @param	name string that defines the action such as "jump" or "fly"
		 * @param	value optional value for your action.
		 * @param	message optional message for your action.
		 * @param	channel optional channel for your action. (will be set to the defaultChannel if not set.
		 */
		protected function triggerCHANGE(name:String, value:Number = 0,message:String = null, channel:int = -1):InputAction{
			if (_enabled){
				action = InputAction.create(name, this, (channel < 0)? defaultChannel : channel , value, message);
				_input.actionCHANGE.dispatch(action);
				return action;
			}
			return null;
		}
		
		/**
		 * Will register the action to the Input system as an action with an InputPhase.END phase if its not yet in the 
		 * actions list as well as a time to 1 (so that it will be considered as already triggered.
		 * @param	name string that defines the action such as "jump" or "fly"
		 * @param	value optional value for your action.
		 * @param	message optional message for your action.
		 * @param	channel optional channel for your action. (will be set to the defaultChannel if not set.
		 */
		protected function triggerONCE(name:String, value:Number = 0, message:String = null, channel:int = -1):InputAction{
			if (_enabled){
				action = InputAction.create(name, this, (channel < 0)? defaultChannel : channel , value, message, InputPhase.END);
				_input.actionON.dispatch(action);
				action = InputAction.create(name, this, (channel < 0)? defaultChannel : channel , value, message, InputPhase.END);
				_input.actionOFF.dispatch(action);
				return action;
			}
			return null;
		}
		
		public function get enabled():Boolean{
			return _enabled;
		}
		
		public function set enabled(val:Boolean):void{
			_enabled = val;
		}
		
		public function get updateEnabled():Boolean{
			return _updateEnabled;
		}
		
		/**
		 * Removes this controller from Input.
		 */
		public function destroy():void{
			_input.removeController(this);
		}
		
		public function toString():String{
			return name;
		}
		
		protected function setParams(object:Object):void{
			for (var param:String in object){
				try{
					if (object[param] == "true")
						this[param] = true;
					else if (object[param] == "false")
						this[param] = false;
					else
						this[param] = object[param];
				}
				catch (e:Error){
					if (!hideParamWarnings)
						trace("Warning: The parameter " + param + " does not exist on " + this);
				}
			}
			
			_initialized = true;
			
		}
	}
}