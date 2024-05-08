package SephiusEngine.input.maping {
	import flash.ui.Keyboard;
	import flash.utils.describeType;

	import starling.utils.cleanMasterString;
	import SephiusEngine.core.levelManager.GameOptions;
	
	/**
	 * Maping for actions using keyboard
	 * @author Fernando Rabello
	 */
	public class KeyboardActionMap{
		private static var _CURRENT:Object = getDefaultMapping();
		public static function get CURRENT():Object { return _CURRENT; }
		public static function update():void {
			_CURRENT = getDefaultMapping();
		}

		private static function getDefaultMapping():Object {
			trace("Keyboard layout: " + GameOptions.KEYBOARD_LAYOUT);

			// These are the relevant keys which are located in different locations on intl keyboards.
			var QWERTY_Q:uint = Keyboard.Q;
			var QWERTY_W:uint = Keyboard.W;
			var QWERTY_A:uint = Keyboard.A;
			var QWERTY_Z:uint = Keyboard.Z;

			switch(GameOptions.KEYBOARD_LAYOUT) {
				case "QWERTZ":
					break;
				case "AZERTY":
					QWERTY_Q = Keyboard.A;
					QWERTY_W = Keyboard.Z;
					QWERTY_A = Keyboard.Q;
					QWERTY_Z = Keyboard.W;
					break;
			}

			return {
				//Movment
				LEFT: QWERTY_A,
				RIGHT: Keyboard.D,
				UP: QWERTY_W,
				DOWN: Keyboard.S,
				
				FLY_UP: QWERTY_W,
				FLY_DOWN: Keyboard.S,
				
				//Habilities
				JUMP: Keyboard.SPACE,
				GLIDING: Keyboard.SPACE,
				ABSORPTION: Keyboard.F,
				FLY: Keyboard.SHIFT,
				DODGE: Keyboard.SHIFT,
				FLAP_WINGS_A: Keyboard.SPACE,
				//FLAP_WINGS_B: Keyboard.X,
				
				//Actions
				WEAPON_1: Keyboard.LEFT,
				WEAPON_2: Keyboard.RIGHT,
				SPELL_1: Keyboard.LEFT,
				SPELL_2: Keyboard.RIGHT,

				ATTACK_MODIFIER: Keyboard.C,

				USE_ITEM: Keyboard.UP,
				INTERACTION: Keyboard.R,
				
				TOGGLE_ITEM_LEFT: QWERTY_Q,
				TOGGLE_ITEM_RIGHT: Keyboard.E,
				
				SPELL_RING: Keyboard.NUMBER_1,
				WEAPON_RING: Keyboard.NUMBER_2,
				//RINGS: Keyboard.TAB,
				
				RING_SELECTION_PLUS: Keyboard.UP,
				RING_SELECTION_MINUS: Keyboard.DOWN,

				CAMERA_OUTWARD: Keyboard.MINUS,
				CAMERA_INWARD: Keyboard.EQUAL,
				CAMERA_DEFAULT: Keyboard.NUMBER_8,
				FAST_MAP: Keyboard.M,
				FAST_MAP: Keyboard.TAB,

				//Interfaces
				INTERFACE_UP: QWERTY_W,
				INTERFACE_DOWN: Keyboard.S,
				INTERFACE_LEFT: QWERTY_A,
				INTERFACE_RIGHT: Keyboard.D,
				
				INTERFACE_NEXT: Keyboard.D,
				INTERFACE_PREVIOUS: QWERTY_A,
				
				INTERFACE_UP: Keyboard.UP,
				INTERFACE_DOWN: Keyboard.DOWN,
				INTERFACE_LEFT: Keyboard.LEFT,
				INTERFACE_RIGHT: Keyboard.RIGHT,

				INTERFACE_START: Keyboard.ENTER,
				INTERFACE_CONFIRM: Keyboard.ENTER,

				INTERFACE_CANCEL: Keyboard.ESCAPE,
				INTERFACE_EXIT: Keyboard.ESCAPE,
				INTERFACE_CANCEL_B: Keyboard.BACKSPACE,
				INTERFACE_EXIT_B: Keyboard.ESCAPE,

				INTERFACE_MENU_INFO: Keyboard.I,
				INTERFACE_PAUSE: Keyboard.ESCAPE,
			
				//Spells and Items
				SPELL_SYMBOL_1: Keyboard.NUMBER_1,
				SPELL_SYMBOL_2: Keyboard.NUMBER_2,
				SPELL_SYMBOL_3: Keyboard.NUMBER_3,
				SPELL_SYMBOL_4: Keyboard.NUMBER_4,
				SPELL_SYMBOL_5: Keyboard.NUMBER_5,
				SPELL_SYMBOL_6: Keyboard.NUMBER_6,
				SPELL_SYMBOL_7: Keyboard.NUMBER_7,
				SPELL_SYMBOL_8: Keyboard.NUMBER_8,
				SPELL_SYMBOL_9: Keyboard.NUMBER_9,
				SPELL_SYMBOL_10: Keyboard.NUMBER_0,
				
				//Debug
				DEBUG_MAIN: Keyboard.G,
				
				//SHOW STUFF
				DEBUG_SHOW_FRAME_RATE: Keyboard.F1,
				DEBUG_SHOW_PHYSICS: Keyboard.F2,
				DEBUG_SHOW_SOUND: Keyboard.F3,
				DEBUG_SHOW_COLLISION: Keyboard.F4,
				DEBUG_SHOW_RANGES: Keyboard.F5,
				DEBUG_SHOW_PRESENCES_DEBUG: Keyboard.F6,
				DEBUG_SHOW_TIMEMARKS_DEBUG: Keyboard.F7,
				DEBUG_SHOW_AREA_MAP_DEBUG: Keyboard.F8,//Noy Implemented
				DEBUG_SHOW_LUMA_MAP_DEBUG: Keyboard.F9,//Noy Implemented

				//GAMEPLAY	
				DEBUG_SHOW_SEPHIUS_DEBUG: Keyboard.NUMPAD_1,
				DEBUG_SEPHIUS_TO_LEVEL_SITE: Keyboard.NUMPAD_5,
				DEBUG_SEPHIUS_ADD_LEVEL: Keyboard.NUMPAD_8,
				DEBUG_SEPHIUS_REMOVE_LEVEL: Keyboard.NUMPAD_2,
				DEBUG_GIVE_ESSENCES: Keyboard.NUMPAD_7,
				DEBUG_SEPHIUS_IMORTAL: Keyboard.NUMPAD_4,
				DEBUG_SPAWN_REWARDS: Keyboard.NUMPAD_9,
				DEBUG_SPAWN_PLATFORMS: Keyboard.NUMPAD_DIVIDE,
				DEBUG_DISABLE_GRAVITY: Keyboard.NUMPAD_MULTIPLY,
				DEBUG_DISABLE_DAMAGES: Keyboard.NUMPAD_3,
				DEBUG_TELEPORT_FORWARD: Keyboard.NUMPAD_DECIMAL,
				DEBUG_TELEPORT_BACK: Keyboard.NUMPAD_0,
				DEBUG_SLOW_TIME: Keyboard.NUMPAD_6,

				CAMERA_UNLIMITED_ZOON_OUT: Keyboard.NUMBER_3,
				CAMERA_UNLIMITED_ZOOM_IN: Keyboard.NUMBER_4,
				CAMERA_UNLIMITED_Z_OUT: Keyboard.MINUS,
				CAMERA_UNLIMITED_Z_IN: Keyboard.EQUAL,

				CAMERA_ROTATION_LEFT: Keyboard.NUMBER_9,
				CAMERA_ROTATION_RIGHT: Keyboard.NUMBER_6,
				
				//AI	
				DEBUG_SPAWN_ENEMY: Keyboard.ENTER,
					DEBUG_DESTROY_ENEMY: Keyboard.BACKSPACE,
					DEBUG_PREVIOUS_ENEMY: Keyboard.RIGHTBRACKET,
					DEBUG_NEXT_ENEMY: Keyboard.LEFTBRACKET,
				DEBUG_SHOW_CREATURE_DEBUG: Keyboard.NUMBER_1,
					DEBUG_NEXT_INFO_ENEMY: Keyboard.E,
					DEBUG_BACK_INFO_ENEMY: QWERTY_Q,
				DEBUG_DISABLE_IA: Keyboard.NUMBER_2,
				DEBUG_DISABLE_SPAWNERS: Keyboard.NUMBER_3,

				//RENDER	
				DEBUG_HIDE_SHOW_SEPHIUS: Keyboard.RIGHT,
				DEBUG_HIDE_SHOW_BACKGROUND: Keyboard.UP,
				DEBUG_HIDE_SHOW_FOREGROUND: Keyboard.DOWN,
				DEBUG_HIDE_SHOW_UI: Keyboard.LEFT,
				DEBUG_HIDE_SHOW_RULER: Keyboard.K,

				DEBUG_DISABLE_CAMERA_DEPTH: Keyboard.U,
				DEBUG_DISABLE_CAMERA_CONTROL: Keyboard.U,
				DEBUG_DISABLE_CAMERA_MOVEMENT: Keyboard.I,

				DEBUG_CAM_ZOOM_IN: Keyboard.EQUAL,
				DEBUG_CAM_ZOOM_OUT: Keyboard.MINUS,

				DEBUG_SEPHIUS_PARTICLES: Keyboard.P,
				DEBUG_LIGHT: Keyboard.L,
				DEBUG_CHANGE_WORLD: QWERTY_W,
				
				//GAME DATA	
				DEBUG_UPDATE_GAMEDATA: Keyboard.HOME,
				DEBUG_SAVE_GAME: Keyboard.END,
				DEBUG_CREATE_NARRATION: Keyboard.PAGE_UP,

				//PHYSICS
				DEBUG_TEST_FORCES: Keyboard.T,

				MODIFICATION_KEY_1: Keyboard.CONTROL,
				MODIFICATION_KEY_2: Keyboard.SHIFT,
				MODIFICATION_KEY_3: Keyboard.ALTERNATE
			};
		}
		
		private static function getKeyboardNames():Vector.<String> {
			var keyDescription:XML = describeType(Keyboard);
			var keyNames:XMLList = keyDescription..constant.@name;
			
			var keyboardKeys:Vector.<String> = new Vector.<String>();
			//keyboardDict.length = keyNames.length();
			
			var len:int = keyNames.length();
			var i:int = 0;
			var keycode:int = 0;
			var key:String;
			for (i; i < len; i++) {
				key = cleanMasterString(keyNames[i]);
				keycode = Keyboard[key];
				key = key.split("_").join("");
				
				//trace(key);
				//trace(keycode);
				
				if(keycode < 300){
					if (keyboardKeys.length < keycode)
						keyboardKeys.length = keycode;
					
					keyboardKeys[keycode] = key;
				}
			}
			
			return keyboardKeys;
		}
		
		public static var keyNamesFromCode:Vector.<String> = getKeyboardNames();	
	}
}