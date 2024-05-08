package SephiusEngine.input.controllers.gamepad.maps {

	import SephiusEngine.input.controllers.gamepad.controls.StickController;
	import SephiusEngine.input.controllers.gamepad.Gamepad;

	public class PlaystationGamepadMap extends GamePadMap{

		public function PlaystationGamepadMap():void{
			super();
		}

        /** Register buttons for playstation controllers. Since Dualshock 4 buttons ID don't changed so same maping can be used for all PS controllers. 
         * Except if you want to use new features like touch and etc.
          */
		override public function setupWIN(gamepad:Gamepad):void { 
			var joy:StickController;
			joy = gamepad.registerStick(LEFT_STICK, "AXIS_0", "AXIS_1");
			joy.invertY = false;
			joy.threshold = 0.2;
			joy = gamepad.registerStick(RIGHT_STICK, "AXIS_2", "AXIS_5");
			joy.invertY = false;
			joy.threshold = 0.2;
			
			gamepad.registerButton(BUTTON_L1,		"BUTTON_14");
			gamepad.registerButton(BUTTON_R1, 		"BUTTON_15");
			
			gamepad.registerButton(BUTTON_L2, 		"BUTTON_16");
			gamepad.registerButton(BUTTON_R2, 		"BUTTON_17");
			
			gamepad.registerButton(BUTTON_L3, 		"BUTTON_20");
			gamepad.registerButton(BUTTON_R3, 		"BUTTON_21");
			
			gamepad.registerButton(BUTTON_SHARE, 	"BUTTON_18");
			gamepad.registerButton(BUTTON_OPTIONS, 	"BUTTON_19");
			
			gamepad.registerButton(DPAD_UP,			"BUTTON_6",		"up");
			gamepad.registerButton(DPAD_DOWN,		"BUTTON_7",		"down");
			gamepad.registerButton(DPAD_RIGHT,		"BUTTON_9",		"right");
			gamepad.registerButton(DPAD_LEFT,		"BUTTON_8",		"left");
			
			gamepad.registerButton(BUTTON_CROSS, 	"BUTTON_11");
			gamepad.registerButton(BUTTON_SQUARE, 	"BUTTON_10");
			gamepad.registerButton(BUTTON_TRIANGLE, "BUTTON_13");
			gamepad.registerButton(BUTTON_CIRCLE, 	"BUTTON_12");
		}

        /** Register buttons for playstation controllers. Since Dualshock 4 buttons ID don't changed so same maping can be used for all PS controllers. 
         * Except if you want to use new features like touch and etc.
          */
		override public function setupMAC(gamepad:Gamepad):void{
			var joy:StickController;
			
			joy = gamepad.registerStick(LEFT_STICK, "AXIS_0", "AXIS_1");
			joy.invertY = true;
			joy.threshold = 0.2;
			
			joy = gamepad.registerStick(RIGHT_STICK, "AXIS_2", "AXIS_3");
			joy.invertY = true;
			joy.threshold = 0.2;
			
			gamepad.registerButton(BUTTON_L1,		"BUTTON_14");
			gamepad.registerButton(BUTTON_R1, 		"BUTTON_15");
			
			gamepad.registerButton(BUTTON_L2, 		"BUTTON_12");
			gamepad.registerButton(BUTTON_R2, 		"BUTTON_13");
			
			gamepad.registerButton(BUTTON_L3, 		"BUTTON_4");
			gamepad.registerButton(BUTTON_R3, 		"BUTTON_7");
			
			gamepad.registerButton(BUTTON_SHARE, 	"BUTTON_5");
			gamepad.registerButton(BUTTON_OPTIONS, 	"BUTTON_6");
			
			gamepad.registerButton(DPAD_UP,			"BUTTON_8","up");
			gamepad.registerButton(DPAD_DOWN,		"BUTTON_10","down");
			gamepad.registerButton(DPAD_RIGHT,		"BUTTON_9","right");
			gamepad.registerButton(DPAD_LEFT,		"BUTTON_11","left");
			
			gamepad.registerButton(BUTTON_CROSS, 	"BUTTON_18"); // X
			gamepad.registerButton(BUTTON_SQUARE, 	"BUTTON_19"); //   square
			gamepad.registerButton(BUTTON_TRIANGLE, "BUTTON_16"); //   triangle
			gamepad.registerButton(BUTTON_CIRCLE, 	"BUTTON_17"); //  circle
		}
    }
}