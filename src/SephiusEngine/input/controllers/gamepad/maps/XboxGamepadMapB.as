package SephiusEngine.input.controllers.gamepad.maps {
	import SephiusEngine.input.controllers.gamepad.controls.ButtonController;
	import SephiusEngine.input.controllers.gamepad.controls.StickController;
	import SephiusEngine.input.controllers.gamepad.Gamepad;

	public class XboxGamepadMapB extends GamePadMap{
		public function XboxGamepadMapB():void{
			super();
			
			WEAPON_1 = BUTTON_LB;
			WEAPON_2 = BUTTON_RB;
			SPELL_1 = BUTTON_LT;
			SPELL_2 = BUTTON_RT;
			
			USE_ITEM = BUTTON_X;
			
			SPELL_RING = RIGHT_STICK_CLICK;
			//ITEM_RING = RIGHT_STICK_CLICK;
			WEAPON_RING = LEFT_STICK_CLICK;
			
			//RINGS = RIGHT_STICK_CLICK;
			//RINGS2 = LEFT_STICK_CLICK;
			
			RING_SELECTION_1 = RIGHT_STICK;
			RING_SELECTION_2 = LEFT_STICK;
			
			CAMERA = RIGHT_STICK;
			CAMERA_INWARD = RIGHT_STICK_UP;
			CAMERA_OUTWARD = RIGHT_STICK_DOWN;

			FAST_MAP = DPAD_DOWN;

			MOVEMENT = LEFT_STICK;
			
			LEFT = LEFT_STICK_LEFT;
			RIGHT = LEFT_STICK_RIGHT;
			UP = LEFT_STICK_UP;
			DOWN = LEFT_STICK_DOWN;

			TOGGLE_ITEM_LEFT = DPAD_LEFT;
			TOGGLE_ITEM_RIGHT = DPAD_RIGHT;
			INTERACTION = DPAD_UP;
			FAST_MAP = DPAD_DOWN;
			
			JUMP = BUTTON_A;
			GLIDING = BUTTON_A;
			ABSORPTION = BUTTON_B;
			FLY = BUTTON_Y;
			DODGE = BUTTON_Y;
			FLAP_WINGS_A = BUTTON_A;
			INTERACTION = DPAD_UP;
			TALK = DPAD_UP;
			
			FLY_CONTROL = LEFT_STICK;
			
			INTERFACE_UP = DPAD_UP;
			INTERFACE_DOWN = DPAD_DOWN;
			INTERFACE_LEFT = DPAD_LEFT;
			INTERFACE_RIGHT = DPAD_RIGHT;

			INTERFACE_START = BUTTON_START;

			INTERFACE_CONFIRM = BUTTON_A;
			INTERFACE_CANCEL = BUTTON_B;
			
			INTERFACE_EXIT = BUTTON_B;
			
			INTERFACE_NEXT = BUTTON_RB;
			INTERFACE_PREVIOUS = BUTTON_LB;
			
			INTERFACE_MENU_INFO = BUTTON_BACK;
			INTERFACE_PAUSE = BUTTON_START;
		}
		
		override public function setupWIN(gamepad:Gamepad):void{
			var stick:StickController;
			stick = gamepad.registerStick(LEFT_STICK, "AXIS_0", "AXIS_1");
			stick.invertY = true; // AXIS_1 is inverted
			stick.threshold = 0.2;
			
			stick = gamepad.registerStick(RIGHT_STICK,"AXIS_2", "AXIS_3");
			stick.invertY = true; // AXIS_3 is inverted
			stick.threshold = 0.2;
			
			gamepad.registerButton(BUTTON_LB,"BUTTON_8");
			gamepad.registerButton(BUTTON_RB, "BUTTON_9");
			
			gamepad.registerButton(BUTTON_LT, "BUTTON_10");
			gamepad.registerButton(BUTTON_RT, "BUTTON_11");
			
			gamepad.registerButton(LEFT_STICK_CLICK, "BUTTON_14");
			gamepad.registerButton(RIGHT_STICK_CLICK, "BUTTON_15");
			
			gamepad.registerButton(BUTTON_BACK, "BUTTON_12");
			gamepad.registerButton(BUTTON_START, "BUTTON_13");
			
			gamepad.registerButton(DPAD_UP,"BUTTON_16","up");
			gamepad.registerButton(DPAD_DOWN,"BUTTON_17","down");
			gamepad.registerButton(DPAD_RIGHT,"BUTTON_19","right");
			gamepad.registerButton(DPAD_LEFT,"BUTTON_18","left");
			
			gamepad.registerButton(BUTTON_Y, "BUTTON_7");
			gamepad.registerButton(BUTTON_B, "BUTTON_5");
			gamepad.registerButton(BUTTON_A, "BUTTON_4");
			gamepad.registerButton(BUTTON_X, "BUTTON_6");
		}
		
		override public function setupMAC(gamepad:Gamepad):void{
			var stick:StickController;
			stick = gamepad.registerStick(LEFT_STICK, "AXIS_0", "AXIS_1");
			stick.invertY = true; // AXIS_1 is inverted
			stick.threshold = 0.2;
			
			stick = gamepad.registerStick(RIGHT_STICK,"AXIS_2", "AXIS_3");
			stick.invertY = true; // AXIS_3 is inverted
			stick.threshold = 0.2;
			
			gamepad.registerButton(BUTTON_LB,"BUTTON_8");
			gamepad.registerButton(BUTTON_RB, "BUTTON_9");
			
			gamepad.registerButton(BUTTON_LT, "BUTTON_10");
			gamepad.registerButton(BUTTON_RT, "BUTTON_11");
			
			gamepad.registerButton(LEFT_STICK_CLICK, "BUTTON_14");
			gamepad.registerButton(RIGHT_STICK_CLICK, "BUTTON_15");
			
			gamepad.registerButton(BUTTON_BACK, "BUTTON_12");
			gamepad.registerButton(BUTTON_START, "BUTTON_13");
			
			gamepad.registerButton(DPAD_UP,"BUTTON_16","up");
			gamepad.registerButton(DPAD_DOWN,"BUTTON_17","down");
			gamepad.registerButton(DPAD_RIGHT,"BUTTON_19","right");
			gamepad.registerButton(DPAD_LEFT,"BUTTON_18","left");
			
			gamepad.registerButton(BUTTON_Y, "BUTTON_7");
			gamepad.registerButton(BUTTON_B, "BUTTON_5");
			gamepad.registerButton(BUTTON_A, "BUTTON_4");
			gamepad.registerButton(BUTTON_X, "BUTTON_6");
		}
	}
}