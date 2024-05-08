package SephiusEngine.core.levelManager 
{
	import SephiusEngine.core.GameState;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.gameStates.LevelManager;
	import SephiusEngine.utils.GraphicQualities;
	import SephiusEngine.utils.GraphicResolutions;
	import starling.core.Starling;
	import tLotDClassic.GameData.Properties.CharacterProperties;
	import flash.display.StageDisplayState;
	import SephiusEngine.Languages.LanguageManager;
	import SephiusEngine.core.GameCamera;
	/**
	 * Game Configurations
	 * @author Fernando Rabello
	 */
	public class GameOptions {
		/** Store the name of all variables in order to use those names on game data saving */
		public static var VAR_NAMES:Vector.<String> = new Vector.<String>();
		VAR_NAMES.push("LEGACY_SEPHIUS", "DISABLE_COMBAT_INFORMATION", "DISABLE_HUD_NAMES", "DISABLE_ALL_EFFECTS", "DISABLE_UI_EFFECTS", "GRAPHIC_QUALITY", 
		"GRAPHIC_RESOLUTION", "SCREEN_RESOLUTION", "LANGUAGE", "WINDOW_MODE", "ANTI_ALAISING", "DISABLE_BLUR_EFFECTS", "DISABLE_DOF_EFFECT", 
		"DISABLE_NOISE_EFFECT", "DISABLE_STATUS_EFFECTS", "DISABLE_COLOR_EFFECTS_AND_FILTERS", "DISABLE_SPLASHES", "DISABLE_ENVIROMENTAL_EFFECTS", "DISABLE_SUN", 
		"DISABLE_FOG", "DISABLE_AURORA", "DISABLE_RAIN", "DISABLE_FLYING_OBJECTS", "SHOW_STATS", "SOUNDS_FX_VOLUME", "MUSIC_VOLUME", "NARRATOR_VOLUME", "USE_TOUCH",
		"CAMERA_MOVEMENT_INTENSITY", "GAME_DIFFICULTY");
        

/** ----------------------------------------------*/
/** ----------------- GAME PLAY --------------------*/
/** ----------------------------------------------*/
		/** Disable splash Texts */
		public static var DISABLE_COMBAT_INFORMATION:Boolean = false;
		
		/** Disable hud names on rings */
		public static var DISABLE_HUD_NAMES:Boolean = false;

		public static function get SHOW_STATS():Boolean { return _SHOW_STATS }
		public static function set SHOW_STATS(value:Boolean):void { 
			_SHOW_STATS = value;
			if(Starling.current)
				Starling.current.showStats = value; 
		}
		private static var _SHOW_STATS:Boolean = false;

		public static function get CAMERA_MOVEMENT_INTENSITY():Number { return _CAMERA_MOVEMENT_INTENSITY }
		public static function set CAMERA_MOVEMENT_INTENSITY(value:Number):void { 
			_CAMERA_MOVEMENT_INTENSITY = value;
			GameCamera.cameraMovementIntensity = _CAMERA_MOVEMENT_INTENSITY / 100;
		}
		private static var _CAMERA_MOVEMENT_INTENSITY:Number = 100;
		
		public static function get CAMERA_ASSIST_INTENSITY():Number { return _CAMERA_ASSIST_INTENSITY }
		public static function set CAMERA_ASSIST_INTENSITY(value:Number):void { 
			_CAMERA_ASSIST_INTENSITY = value;
			CameraControl.cameraAssitIntensity = _CAMERA_ASSIST_INTENSITY / 100;
		}
		private static var _CAMERA_ASSIST_INTENSITY:Number = 100;
		
		public static function get GAME_DIFFICULTY():int { return _GAME_DIFFICULTY }
		public static function set GAME_DIFFICULTY(value:int):void { 
			_GAME_DIFFICULTY = Math.min(5, Math.max(0, value));
		}
		private static var _GAME_DIFFICULTY:int = 2;
		
		public static var USE_TOUCH:Boolean = false;
		

/** ----------------------------------------------*/
/** ------------ AUDIO AND LANGUAGE ---------------*/
/** ----------------------------------------------*/
		/** Change Game Language*/
		static public function get LANGUAGE():String {return _LANGUAGE;}
		static public function set LANGUAGE(value:String):void {
			LanguageManager.changeLanguage(value);

			_LANGUAGE = value;
		}
		private static var _LANGUAGE:String = LanguageManager.getCurrentLangName();

		public static function get KEYBOARD_LAYOUT():String { return _KEYBOARD_LAYOUT; }
		public static function set KEYBOARD_LAYOUT(value:String):void {
			_KEYBOARD_LAYOUT = value;
			GameEngine.instance.input.keyboard.update();
		}
		private static var _KEYBOARD_LAYOUT:String = "QWERTY";

		public static function get SOUNDS_FX_VOLUME():Number { return _SOUNDS_FX_VOLUME }
		public static function set SOUNDS_FX_VOLUME(value:Number):void { 
			_SOUNDS_FX_VOLUME = value;
			//GameEngine.instance.sound.masterVolume = value / 100;
			GameEngine.instance.sound.getGroup("BGFX").volume = value / 100;
			GameEngine.instance.sound.getGroup("FX").volume = value / 100;
			GameEngine.instance.sound.getGroup("UI").volume = value / 100;
		}
		private static var _SOUNDS_FX_VOLUME:Number = 100;
		
		public static function get MUSIC_VOLUME():Number { return _MUSIC_VOLUME }
		public static function set MUSIC_VOLUME(value:Number):void { 
			_MUSIC_VOLUME = value;
			GameEngine.instance.sound.getGroup("BGM").volume = value / 100;
		}
		private static var _MUSIC_VOLUME:Number = 100;

		public static function get NARRATOR_VOLUME():Number { return _NARRATOR_VOLUME }
		public static function set NARRATOR_VOLUME(value:Number):void { 
			_NARRATOR_VOLUME = value;
			GameEngine.instance.sound.getGroup("STORYTELLER").volume = value / 100;
		}
		private static var _NARRATOR_VOLUME:Number = 100;

/** ----------------------------------------------*/
/** ----------------- GRAPHICS --------------------*/
/** ----------------------------------------------*/
		/** Change preset of several graphic options */
		static public function get GRAPHIC_RESOLUTION():String {return _GRAPHIC_RESOLUTION;}
		static public function set GRAPHIC_RESOLUTION(value:String):void {
			_GRAPHIC_RESOLUTION = value;
			
			if (GameEngine.instance.state as LevelManager) {
				switch(value) {
					case GraphicResolutions.RENDER_DOUBLE:
						GameEngine.instance.state.view.resolution = 2;
						break
					case GraphicResolutions.RENDER_UNCHANGED:
						GameEngine.instance.state.view.resolution = 1;
						break
					case GraphicResolutions.RENDER_HALF:
						GameEngine.instance.state.view.resolution = .5;
						break
					case GraphicResolutions.RENDER_FOURTH:
						GameEngine.instance.state.view.resolution = .25;
						break
				}
			}
		}
		private static var _GRAPHIC_RESOLUTION:String = GraphicResolutions.SCREEN_UNCHANGED;

		/** Change preset of several graphic options */
		static public function get SCREEN_RESOLUTION():String {return _SCREEN_RESOLUTION;}
		static public function set SCREEN_RESOLUTION(value:String):void {
			_SCREEN_RESOLUTION = value;
			/*
			if (GameEngine.instance.state as LevelManager) {
				switch(value) {
					case GraphicResolutions.SCREEN_DOUBLE:
						GameEngine.instance.fullScreen(2);
						break
					case GraphicResolutions.SCREEN_UNCHANGED:
						GameEngine.instance.fullScreen(1);
						break
					case GraphicResolutions.SCREEN_HALF:
						GameEngine.instance.fullScreen(0.5);
						break
					case GraphicResolutions.SCREEN_FOURTH:
						GameEngine.instance.fullScreen(0.25);
						break
				}
			}*/
		}
		private static var _SCREEN_RESOLUTION:String = GraphicResolutions.SCREEN_UNCHANGED;
		
		/** Put game in full screen or in windowed mode */
		static public function get WINDOW_MODE():String {return _WINDOW_MODE;}
		static public function set WINDOW_MODE(value:String):void {
			if(value != WINDOW_MODE_FULLSCREEN && value != WINDOW_MODE_WINDOWED)
				return;
			
			if(value == WINDOW_MODE_FULLSCREEN)
				GameEngine.instance.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			else if(value == WINDOW_MODE_WINDOWED)	
				GameEngine.instance.stage.displayState = StageDisplayState.NORMAL;

			_WINDOW_MODE = value;
		}
		private static var _WINDOW_MODE:String = WINDOW_MODE_FULLSCREEN;
		
		public static var WINDOW_MODE_FULLSCREEN:String = "WINDOW_MODE_FULLSCREEN";
		public static var WINDOW_MODE_WINDOWED:String = "WINDOW_MODE_WINDOWED";

		
		/** Game Anti Alaising */
		static public function get ANTI_ALAISING():int {return _ANTI_ALAISING;}
		static public function set ANTI_ALAISING(value:int):void {
			_ANTI_ALAISING = value;
			
			if (GameEngine.instance.state as GameState) {
				switch(value) {
					case GraphicQualities.ANTI_ALAISING_0:
						GameEngine.instance.starlingObject.antiAliasing = 0;
						break
					case GraphicQualities.ANTI_ALAISING_2:
						GameEngine.instance.starlingObject.antiAliasing = 2;
						break
					case GraphicQualities.ANTI_ALAISING_4:
						GameEngine.instance.starlingObject.antiAliasing = 4;
						break
					case GraphicQualities.ANTI_ALAISING_8:
						GameEngine.instance.starlingObject.antiAliasing = 8;
						break
					case GraphicQualities.ANTI_ALAISING_16:
						GameEngine.instance.starlingObject.antiAliasing = 16;
						break
				}
			}
		}
		private static var _ANTI_ALAISING:int = GraphicQualities.ANTI_ALAISING_0;

		/** Change preset of several graphic options */
		static public function get GRAPHIC_QUALITY():String {return _GRAPHIC_QUALITY;}
		static public function set GRAPHIC_QUALITY(value:String):void {
			_GRAPHIC_QUALITY = value;
			
			if (GameEngine.instance.state as GameState) {
				switch(value) {
					case GraphicQualities.HIGH:
						break
					case GraphicQualities.NORMAL:
						break
					case GraphicQualities.LOW:
					case GraphicQualities.LOWERST:
						break
				}
			}
		}
		private static var _GRAPHIC_QUALITY:String = GraphicQualities.HIGH;
		
/** ----------------------------------------------*/
/** ----------------- EFFECTS --------------------*/
/** ----------------------------------------------*/
		/** Use old Sephius' animations ingame instead the new ones */
		public static function get LEGACY_SEPHIUS():Boolean { return _LEGACY_SEPHIUS }
		public static function set LEGACY_SEPHIUS(value:Boolean):void { 
			_LEGACY_SEPHIUS = value;
			CharacterProperties.SEPHIUS.assymetric = !value;
		}
		private static var _LEGACY_SEPHIUS:Boolean = false;

		
		public static function get DISABLE_BLUR_EFFECTS():Boolean { return DISABLE_ALL_EFFECTS ? false : _DISABLE_BLUR_EFFECTS }
		public static function set DISABLE_BLUR_EFFECTS(value:Boolean):void { _DISABLE_BLUR_EFFECTS = value }
		private static var _DISABLE_BLUR_EFFECTS:Boolean = false;
		
		public static function get DISABLE_DOF_EFFECT():Boolean { return DISABLE_ALL_EFFECTS ? false : _DISABLE_DOF_EFFECT }
		public static function set DISABLE_DOF_EFFECT(value:Boolean):void { 
			_DISABLE_DOF_EFFECT = value 
			if(GameEngine.instance.state as LevelManager && GameEngine.instance.state.isReady){
				GameEngine.instance.state.globalEffects.screenDephofField(!value);
			}
		}
		private static var _DISABLE_DOF_EFFECT:Boolean = false;
		
		public static function get DISABLE_NOISE_EFFECT():Boolean { return DISABLE_ALL_EFFECTS ? false : _DISABLE_NOISE_EFFECT }
		public static function set DISABLE_NOISE_EFFECT(value:Boolean):void { 
			_DISABLE_NOISE_EFFECT = value 
			if(GameEngine.instance.state as LevelManager && GameEngine.instance.state.isReady){
				GameEngine.instance.state.globalEffects.screenNoise(!value);
			}
		}
		private static var _DISABLE_NOISE_EFFECT:Boolean = false;
		
		/** Disable status animation effect */
		public static function get DISABLE_STATUS_EFFECTS():Boolean { return DISABLE_ALL_EFFECTS ? false : _DISABLE_STATUS_EFFECTS }
		public static function set DISABLE_STATUS_EFFECTS(value:Boolean):void { _DISABLE_STATUS_EFFECTS = value }
		private static var _DISABLE_STATUS_EFFECTS:Boolean = false;
		
		/** Disable color effects and filters */
		public static function get DISABLE_COLOR_EFFECTS_AND_FILTERS():Boolean { return DISABLE_ALL_EFFECTS ? false : _DISABLE_COLOR_EFFECTS_AND_FILTERS }
		public static function set DISABLE_COLOR_EFFECTS_AND_FILTERS(value:Boolean):void { _DISABLE_COLOR_EFFECTS_AND_FILTERS = value }
		private static var _DISABLE_COLOR_EFFECTS_AND_FILTERS:Boolean = false;
		
		/** Disable splashes animations */
		public static function get DISABLE_SPLASHES():Boolean { return DISABLE_ALL_EFFECTS ? false : _DISABLE_SPLASHES }
		public static function set DISABLE_SPLASHES(value:Boolean):void { _DISABLE_SPLASHES = value }
		private static var _DISABLE_SPLASHES:Boolean = false;
		
		/** All environmental effect like sun fog and etc */
		public static function get DISABLE_ENVIROMENTAL_EFFECTS():Boolean { return DISABLE_ALL_EFFECTS ? false : _DISABLE_ENVIROMENTAL_EFFECTS }
		public static function set DISABLE_ENVIROMENTAL_EFFECTS(value:Boolean):void { 
			DISABLE_SUN = value;
			DISABLE_FOG = value; 
			DISABLE_AURORA = value; 
			DISABLE_RAIN = value; 
			DISABLE_FLYING_OBJECTS = value; 
			_DISABLE_ENVIROMENTAL_EFFECTS = value 
		}
		private static var _DISABLE_ENVIROMENTAL_EFFECTS:Boolean = false;
		
		/** Sun effect */
		public static function get DISABLE_SUN():Boolean { return DISABLE_ENVIROMENTAL_EFFECTS ? true : _DISABLE_SUN }
		public static function set DISABLE_SUN(value:Boolean):void { 
			if(GameEngine.instance.state as LevelManager && GameEngine.instance.state.isReady)
				GameEngine.instance.state.globalEffects.SUN_EFFECT = !value;
			_DISABLE_SUN = value 
		}
		private static var _DISABLE_SUN:Boolean = false;
		
		/** Fog effect */
		public static function get DISABLE_FOG():Boolean { return DISABLE_ENVIROMENTAL_EFFECTS ? true : _DISABLE_FOG }
		public static function set DISABLE_FOG(value:Boolean):void { 
			if(GameEngine.instance.state as LevelManager && GameEngine.instance.state.isReady)
				GameEngine.instance.state.globalEffects.FOG_EFFECT = !value;
			_DISABLE_FOG = value 
		}
		private static var _DISABLE_FOG:Boolean = false;
		
		/** Aurora effect */
		public static function get DISABLE_AURORA():Boolean { return DISABLE_ENVIROMENTAL_EFFECTS ? true : _DISABLE_AURORA }
		public static function set DISABLE_AURORA(value:Boolean):void { 
			if(GameEngine.instance.state as LevelManager && GameEngine.instance.state.isReady)
				GameEngine.instance.state.globalEffects.AURORA_EFFECT = !value;
			_DISABLE_AURORA = value 
		}
		private static var _DISABLE_AURORA:Boolean = false;
		
		/** Rain effect */
		public static function get DISABLE_RAIN():Boolean { return DISABLE_ENVIROMENTAL_EFFECTS ? true : _DISABLE_RAIN }
		public static function set DISABLE_RAIN(value:Boolean):void { 
			if(GameEngine.instance.state as LevelManager && GameEngine.instance.state.isReady)
				GameEngine.instance.state.globalEffects.RAIN_EFFECT = !value;
			_DISABLE_RAIN = value 
		}
		private static var _DISABLE_RAIN:Boolean = true;
		
		/** Rain effect */
		public static function get DISABLE_FLYING_OBJECTS():Boolean { return DISABLE_ENVIROMENTAL_EFFECTS ? true : _DISABLE_FLYING_OBJECTS }
		public static function set DISABLE_FLYING_OBJECTS(value:Boolean):void { 
			if(GameEngine.instance.state as LevelManager && GameEngine.instance.state.isReady)
				GameEngine.instance.state.globalEffects.FLYING_OBJECTS = !value;
			_DISABLE_FLYING_OBJECTS = value 
		}
		private static var _DISABLE_FLYING_OBJECTS:Boolean = false;
		
		public static var USE_GAMEPAD:Boolean = true;
		
		/** Disable all effects local or global. Ignore UI effects */
		public static var DISABLE_ALL_EFFECTS:Boolean = false;
		
		/** Disable effect witch is rendered on UI */
		public static var DISABLE_UI_EFFECTS:Boolean = false;
		
		
		public function GameOptions(){
		}
	}
}