package SephiusEngine.input.controllers.gamepad.maps {

	import SephiusEngine.input.controllers.gamepad.controls.StickController;
	import SephiusEngine.input.controllers.gamepad.Gamepad;

	public class XboxGamepadMap extends GamePadMap{

		public function XboxGamepadMap():void{
			super();
		}

        /** Register buttons for playstation controllers. Since Dualshock 4 buttons ID don't changed so same maping can be used for all PS controllers. 
         * Except if you want to use new features like touch and etc.
          */
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