package SephiusEngine.input.controllers.gamepad.maps {
	import SephiusEngine.input.controllers.gamepad.Gamepad;
	import flash.system.Capabilities;
	
	public class GamePadMap {
		
		/** ------------------------------------------------------------------------- */
		/** ------------------------- -GAMEPAD BUTTOMS ------------------------------ */
		/** ------------------------------------------------------------------------- */
		public static const BUTTON_L1:String = "L1";
		public static const BUTTON_R1:String = "R1";
		
		public static const BUTTON_L2:String = "L2";
		public static const BUTTON_R2:String = "R2";
		
		public static const BUTTON_LT:String = "LT";
		public static const BUTTON_RT:String = "RT";
		
		public static const BUTTON_LB:String = "LB";
		public static const BUTTON_RB:String = "RB";
		
		public static const BUTTON_ZL:String = "ZL";
		public static const BUTTON_ZR:String = "ZR";
		
		public static const BUTTON_Z:String = "Z";
		public static const BUTTON_R:String = "R";
		public static const BUTTON_M:String = "M";
		public static const BUTTON_C:String = "C";
		
		public static const BUTTON_HOME:String = "Home";
		
		public static const BUTTON_WINDOWS:String = "Windows";
		public static const BUTTON_MENU:String = "Menu";
		
		public static const BUTTON_SELECT:String = "Select";
		public static const BUTTON_START:String = "Start";
		
		public static const BUTTON_BACK:String = "Back";
		
		public static const BUTTON_OPTIONS:String = "Options";
		public static const BUTTON_SHARE:String = "Share";
		
		public static const BUTTON_PLUS:String = "plus";
		public static const BUTTON_MINUS:String = "Minus";
		
		/** directional button on the left of the game pad.*/
		public static const DPAD:String = "Dpad";
		public static const DPAD_UP:String = "DpadUp";
		public static const DPAD_RIGHT:String = "DpadRight";
		public static const DPAD_DOWN:String = "DpadDown";
		public static const DPAD_LEFT:String = "DpadLeft";
		
		/** Generic buttons on the right, conventionally 4 arranged as a rhombus ,*/
		public static const BUTTON_TOP:String = "Top";
		public static const BUTTON_ONRIGHT:String = "OnRight";
		public static const BUTTON_BOTTOM:String = "Bottom";
		public static const BUTTON_ONLEFT:String = "OnLeft";
		
		/**buttons on the right, conventionally 4 arranged for Playstation controllers ,*/
		public static const BUTTON_TRIANGLE:String = "Triangle";
		public static const BUTTON_SQUARE:String = "Square";
		public static const BUTTON_CIRCLE:String = "Circle";
		public static const BUTTON_CROSS:String = "Cross";
		
		/**buttons on the right, conventionally 4 arranged for Xbox and Nintendo controllers ,*/
		public static const BUTTON_A:String = "A";
		public static const BUTTON_B:String = "B";
		public static const BUTTON_Y:String = "Y";
		public static const BUTTON_X:String = "X";
		
		public static const BUTTON_1:String = "1";
		public static const BUTTON_2:String = "2";
		
		/** Sticks */
		public static const BUTTON_L3:String = "L3";
		public static const BUTTON_R3:String = "R3";
		public static const LEFT_STICK_CLICK:String = "LeftStickClick";
		public static const RIGHT_STICK_CLICK:String = "RightStickClick";
		
		public static const LEFT_STICK:String = "LeftStick";
		public static const RIGHT_STICK:String = "RightStick";
		
		public static const LEFT_STICK_UP:String = "LeftStickUp";
		public static const LEFT_STICK_DOWN:String = "LeftStickDown";
		public static const LEFT_STICK_LEFT:String = "LeftStickLeft";
		public static const LEFT_STICK_RIGHT:String = "LeftStickRight";
		
		public static const RIGHT_STICK_UP:String = "RightStickUp";
		public static const RIGHT_STICK_DOWN:String = "RightStickDown";
		public static const RIGHT_STICK_LEFT:String = "RightStickLeft";
		public static const RIGHT_STICK_RIGHT:String = "RightStickRight";
		
		
		/** ------------------------------------------------------------------------- */
		/** ------------------------- -GAMEPAD ACTIONS ------------------------------ */
		/** ------------------------------------------------------------------------- */
		
		public var WEAPON_1:String = "";
		public var WEAPON_2:String = "";
		public var SPELL_1:String = "";
		public var SPELL_2:String = "";
		public var USE_ITEM:String = "";
		
		public var SPELL_RING:String = "";
		public var ITEM_RING:String = "";
		public var WEAPON_RING:String = "";
		
		public var RINGS:String = "";
		public var RINGS2:String = "";
		
		public var RING_SELECTION_1:String = "";
		public var RING_SELECTION_2:String = "";
		
		public var TOGGLE_ITEM_LEFT:String = "";
		public var TOGGLE_ITEM_RIGHT:String = "";
		
		public var CAMERA:String = "";
		public var CAMERA_INWARD:String = "";
		public var CAMERA_OUTWARD:String = "";
		public var MOVEMENT:String = "";
		
		public var FAST_MAP:String = "";
		
		//Movment
		public var LEFT:String = "";
		public var RIGHT:String = "";
		public var UP:String = "";
		public var DOWN:String = "";
		
		//Habilities
		public var JUMP:String = "";
		public var GLIDING:String = "";
		public var ABSORPTION:String = "";
		public var FLY:String = "";
		public var DODGE:String = "";
		public var FLAP_WINGS_A:String = "";
		
		public var INTERACTION:String = "";
		public var TALK:String = "";
		
		public var FLY_CONTROL:String = "";
		
		//Interfaces
		public var INTERFACE_UP:String = "";
		public var INTERFACE_DOWN:String = "";
		public var INTERFACE_LEFT:String = "";
		public var INTERFACE_RIGHT:String = "";
		public var INTERFACE_START:String = "";
		public var INTERFACE_CONFIRM:String = "";
		public var INTERFACE_CANCEL:String = "";
		public var INTERFACE_EXIT:String = "";
		public var INTERFACE_NEXT:String = "";
		public var INTERFACE_PREVIOUS:String = "";
		public var INTERFACE_MENU_INFO:String = "";
		public var INTERFACE_PAUSE:String = "";
		
		protected static var _platform:String;
		
		
		public function GamePadMap():void{
			if(!_platform)
				_platform = Capabilities.version.slice(0, 3);
		}
		
		public function setup(gamepad:Gamepad):void{
			gamepad = gamepad;
			gamepad.stopAllActions();
			gamepad.resetAllActions();
			
			switch(_platform){
				case "WIN" :
					setupWIN(gamepad);
					break;
				case "MAC" :
					setupMAC(gamepad);
					break;
			}
		}
		
		/**
		 * override those functions to set up a gamepad for different OS's by default,
		 * or override setup() to define your own way.
		 */
		public function setupWIN(gamepad:Gamepad):void {}
		public function setupMAC(gamepad:Gamepad):void {}
	}
}