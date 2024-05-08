package SephiusEngine.input.controllers.gamepad.maps {
	import SephiusEngine.input.controllers.gamepad.Gamepad;
	import SephiusEngine.input.controllers.gamepad.controls.StickController;
	
	public class PlaystationGamepadMapB extends PlaystationGamepadMap{
		/**Control Mode 1 uses analogs for movement and Dpad for camera/item changing/interactions. */
		public function PlaystationGamepadMapB() {
			super();
			
			WEAPON_1 = BUTTON_L1;
			WEAPON_2 = BUTTON_R1;
			SPELL_1 = BUTTON_L2;
			SPELL_2 = BUTTON_R2;
			
			USE_ITEM = BUTTON_SQUARE;	
			
			SPELL_RING = BUTTON_R3;
			//ITEM_RING = BUTTON_R3;
			WEAPON_RING = BUTTON_L3;
			
			//RINGS = BUTTON_R3;
			//RINGS2 = BUTTON_L3;
			
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

			JUMP = BUTTON_CROSS;
			GLIDING = BUTTON_CROSS;
			ABSORPTION = BUTTON_CIRCLE;
			FLY = BUTTON_TRIANGLE;
			DODGE = BUTTON_TRIANGLE;
			FLAP_WINGS_A = BUTTON_CROSS;
			
			FLY_CONTROL = LEFT_STICK;
			
			INTERFACE_UP = DPAD_UP;
			INTERFACE_DOWN = DPAD_DOWN;
			INTERFACE_LEFT = DPAD_LEFT;
			INTERFACE_RIGHT = DPAD_RIGHT;
			
			INTERFACE_START = BUTTON_OPTIONS;

			INTERFACE_CONFIRM = BUTTON_CROSS;
			INTERFACE_CANCEL = BUTTON_CIRCLE;

			INTERFACE_EXIT = BUTTON_CIRCLE;

			INTERFACE_NEXT = BUTTON_R1;
			INTERFACE_PREVIOUS = BUTTON_L1;
			
			INTERFACE_MENU_INFO = BUTTON_SHARE;
			INTERFACE_PAUSE = BUTTON_OPTIONS;
		}
	}
}