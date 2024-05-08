package SephiusEngine.input.controllers.gamepad.controls {
	import SephiusEngine.input.InputAction;
	import SephiusEngine.input.InputController;
	import SephiusEngine.input.controllers.gamepad.Gamepad;
	
	
	public class ButtonController extends InputController implements Icontrol{
		protected var _gamePad:Gamepad;
		protected var _controlID:String;
		protected var _prevValue:Number = 0;
		protected var _value:Number = 0;
		protected var _action:Array;
		
		public var threshold:Number = 0.1;
		public var inverted:Boolean = false;
		public var precision:Number = 100;
		public var digital:Boolean = false;
		
		/**
		 * ButtonController is an abstraction of the button controls of a gamepad. This InputController will see its value updated
		 * via its corresponding gamepad object and send his own actions to the Input system.
		 * 
		 * It should not be instantiated manually.
		 */
		public function ButtonController(name:String,parentGamePad:Gamepad,controlID:String,action:Array = null) {
			super(name);
			_gamePad = parentGamePad;
			_controlID = controlID;
			_action = action;
		}
		
		public function updateControl(control:String, value:Number):void{
			if (_action){
				value = value * (inverted ? -1 : 1);
				_prevValue = _value;
				value = ((value * precision) >> 0) / precision;
				_value = ( value <= threshold && value >= -threshold ) ? 0 : value ;
				_value = digital ? _value >> 0 : _value;
				
				if (_prevValue != _value){
					if (_value > 0)
						triggerCHANGE(null, _value,null,_gamePad.defaultChannel);
					else
						triggerOFF(null, 0, null, _gamePad.defaultChannel);
				}
			}
		}
		
		override protected function triggerCHANGE(name:String, value:Number = 0, message:String = null, channel:int = -1):InputAction{
			if (name){
				return super.triggerCHANGE(name, value, message, channel);
			}
			
			if(_action.length < 2)
				super.triggerCHANGE(_action[0], value, message, channel);
			else{
				var action:String;
				for each(action in _action)
					super.triggerCHANGE(action, value, message, channel);
			}	
			
			return null;
		}
		
		override protected function triggerOFF(name:String, value:Number = 0, message:String = null, channel:int = -1):InputAction{
			if (name){
			return super.triggerOFF(name, value, message, channel);
			}
			
			if(_action.length < 2)
				super.triggerOFF(_action[0], value, message, channel);
			else{
				var action:String;
				for each(action in _action)
					super.triggerOFF(action, value, message, channel);
			}	
			
			return null;
		}
		
		public function hasControl(id:String):Boolean{
			return _controlID == id;
		}
		
		override public function destroy():void{
			_input.stopActionsOf(this);
			super.destroy();
			_gamePad = null;
		}
		
		public function get value():Number{return _value;}
		
		public function get gamePad():Gamepad{return _gamePad;}
		
		public function get controlID():String{return _controlID;}
		
		public function get action():Array{return _action;}
		
		public function set action(value:Array):void{_action = value;}
	}
}