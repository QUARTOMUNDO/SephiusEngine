package SephiusEngine.core
{
	import SephiusEngine.Languages.LanguageManager;
	import SephiusEngine.core.GameAssets;
	import SephiusEngine.core.GameData;
	import SephiusEngine.core.GameState;
	import SephiusEngine.core.gameStates.GameTitle;
	import SephiusEngine.core.gameStates.LevelManager;
	import SephiusEngine.core.levelManager.GameOptions;
	import SephiusEngine.core.levelManager.LevelRegion;
	import SephiusEngine.displayObjects.LoadingScreen;
	import SephiusEngine.displayObjects.StartScreen;
	import SephiusEngine.input.GameKeyboard;
	import SephiusEngine.input.GameMouse;
	import SephiusEngine.input.GamePadManager;
	import SephiusEngine.input.Input;
	import SephiusEngine.levelObjects.activators.ReagentCollider;
	import SephiusEngine.levelObjects.damagers.DamageCollisions;
	import SephiusEngine.sounds.SoundManager;
	import SephiusEngine.sounds.system.components.global.GlobalSoundComponent;
	import SephiusEngine.utils.TimeMarks;
	import SephiusEngine.utils.pools.RectanglePool;

	import com.greensock.TimelineLite;
	import com.greensock.TweenMax;
	import com.greensock.core.Animation;

	import flash.desktop.NativeApplication;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;

	import org.gestouch.core.Gestouch;
	import org.gestouch.extensions.starling.StarlingDisplayListAdapter;
	import org.gestouch.extensions.starling.StarlingTouchHitTester;
	import org.gestouch.input.NativeInputAdapter;
	import org.osflash.signals.Signal;

	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.extensions.brinkbit.fullscreenscreenextension.FullScreenExtension;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	import tLotDClassic.GameData.Properties.naturesInfos.Natures;
	import tLotDClassic.gameObjects.activators.MysticReceptacle;
	import tLotDClassic.gameObjects.activators.Pyra;
	import tLotDClassic.gameObjects.barriers.*;
	import tLotDClassic.gameObjects.breakableObjects.BreakableObject;
	import tLotDClassic.gameObjects.characters.Spawner;
	import tLotDClassic.gameObjects.pools.Pool;
	import tLotDClassic.gameObjects.rewards.Reward;
	
	/**
	 * Main class for The Light of the Darkness Game
	 * This class replace GameEngine level of abstractions
	 * working directly with Starling as view and Box2D as physics.
	 * Also make physics works independly from render
	 * enabling game run at same speed no matter frame rate is.
	 * @author Fernando Rabello
	 */
	public class GameEngine extends MovieClip
	{
		public static const VERSION:String = "1.0.0";
		
		/** ---------------------------------------------- */
		/** ------------------ Game Controlls ------------ */
		/** ---------------------------------------------- */
		
		/** Used to pause animations in SpriteArt and StarlingArt.*/
		public var onPlayingChange:Signal;
		
		/** @return true if the Game Engine is playing */
		public function get playing():Boolean  { return _playing; }
		protected var _playing:Boolean = true;

		public var desiredContext3DProfile:String;

		/** Stops some engine processes*/
		public function set playing(value:Boolean):void
		{
			if (!value && _playing)
			{
				allTweens = TimelineLite.exportRoot(null, false);
				allTweens.stop();
			}
			else if (value && !_playing)
			{
				if (allTweens)
					allTweens.play();
				
				GameEngine.instance.input.resetActions();
			}
			
			_playing = value;
			onPlayingChange.dispatch(_playing);
		}
		
		/** Used to pause tweens and delay calls when game pause */
		public var allTweens:TimelineLite;
		
		/** This should contains all assets used in the game. All textures, atlas, sounds and etc.*/
		static public var assets:GameAssets;
		
		public var inScreenRec:Rectangle = new Rectangle();
		public var outScreenRec:Rectangle = new Rectangle();
		
		/** ---------------------------------------------- */
		/** ------------------ Game variables ------------ */
		/** ---------------------------------------------- */
		
		/** Classes witch is only referenced on the Level Editor. Theses must be referenced here in order application could instantiate then */
		public static var classes:Vector.<Class> = new Vector.<Class>();
		GameEngine.classes.push(DamageCollisions);
		GameEngine.classes.push(ReagentCollider);
		GameEngine.classes.push(Spawner);
		GameEngine.classes.push(SocketBarrier);
		GameEngine.classes.push(EnchantedBarrier);
		GameEngine.classes.push(BlockedBarrier);
		GameEngine.classes.push(TriggeredBarrier);
		GameEngine.classes.push(Reward);
		GameEngine.classes.push(Pool);
		GameEngine.classes.push(BreakableObject);
		GameEngine.classes.push(Pyra);
		GameEngine.classes.push(MysticReceptacle);		
		
		/** ---------------------------------------------- */
		/** --------------- Game View Layers ------------- */
		/** ---------------------------------------------- */
		
		/**  Canvas witch apear above state and other canvas when a game state is loading */
		public var loadingCanvas:Sprite = new Sprite();
		private var startScreen:StartScreen;
		public var loadingScreen:LoadingScreen;
		//public var gameTitle:GameTitle;
		
		/** ---------------------------------------------- */
		/** ------------------ Game Systems--------------- */
		/** ---------------------------------------------- */
		public static var p1InputChannel:uint = 0;
		public static var p2InputChannel:uint = 1;
		
		/** You can get access to the Input manager object from this reference so that you can see which keys are pressed and stuff. */
		public function get input():Input  { return _input; }
		protected var _input:Input;
		
		/** You can get access to the Gamepas Manager manager */
		public function get gamePadManager():GamePadManager  { return _gamePadManager; }
		protected var _gamePadManager:GamePadManager;
		
		/**A reference to the SoundManager instance. Use it if you want.*/
		public function get sound():SoundManager  { return _sound; }
		private var _sound:SoundManager;
		
		/** If non null current state will be destroyed and replaced buy this new state */
		protected var _newState:GameState;
		
		/**
		 * We only ACTUALLY change states on enter frame so that we don't risk changing states in the middle of a state update.
		 * However, if you use the state getter, it will grab the new one for you, so everything should work out just fine.
		 */
		public function get state():GameState
		{
			//if (_newState)
			//return _newState;
			//else 
			return _state;
		}
		protected var _state:GameState;
		
		protected function setState(newState:GameState):void
		{
			if (_newState)
				_newState.onInitialized.removeAll();
			
			newState.onInitialized.addOnce(loadingScreen.hideLoadingScreen);
			
			_newState = newState;
		}
		
		public function replaceState(newState:GameState):void
		{
			if (newState == _state)
				return;
			
			loadingCanvas.addChild(loadingScreen);
			loadingScreen.show();
			
			if (newState)
			{
				if (state)
				{
					//TweenMax.to(state, 1, { alpha:0 } );
					TweenMax.delayedCall(1.5, setState, [newState]);
				}
				else
				{
					setState(newState);
				}
			}
		}
		
		/** Says on witch layer state should be */
		protected var _stateDisplayIndex:uint = 0;
		
		/** Starling is the render engine */
		public function get starlingObject():Starling  { return _starling; }
		protected var _starling:Starling;
		
		/** Store game data for a particular character from a particular game state */
		public static var gameData:GameData;
		
		public var soundComponent:GlobalSoundComponent;
		
		/** ---------------------------------------------- */
		/** ------------------ Time ---------------------- */
		/** ---------------------------------------------- */
		
		/** The time when game start */
		private var _startTime:Number;
		private var _lastTime:Number = 0;
		private var _currentTime:Number = 0;
		public var frameTime:Number = 0;
		public static var timeSinceEngineStart:Number = 0;
		
		public var timeMarks:TimeMarks = new TimeMarks();
		/** ---------------------------------------------- */
		/** ---------------------------------------------- */
		/** ---------------------------------------------- */
		
		public static var instance:GameEngine;
		
		public function GameEngine()
		{
			trace("[GameEngine!!!]Air Version", NativeApplication.nativeApplication.runtimeVersion);
			RectanglePool.initialize(25000, 1000);
			/*** --------------- */ /*
			   var ba:ByteArray = new ByteArray();
			   for(var i:uint = 0; i<100000000; i++)
			   {
			   ba.writeInt(int(Math.random()*10000000));
			   ba.writeInt(int(Math.random()*10000000));
			   ba.writeInt(int(Math.random()*10000000));
			   }
			
			   trace("--------------------End", ba.length, System.totalMemory / 1000000);*/
			/*** --------------- */
			
			instance = this;
			onPlayingChange = new Signal(Boolean);
			
			//Set up time
			_startTime = getTimer() / 1000;
			_currentTime = _startTime;
			
			LanguageManager.init();
			LanguageManager.changeLanguage("en");//Need to load from a options save file

			//Set up input
			_input = new Input();
			
			//Set up sound manager
			_sound = SoundManager.getInstance();
			
			//addEventListener(flash.events.Event.ENTER_FRAME, masterUpdate);
			Animation.ticker.addEventListener("tick", masterUpdate, false, 0, true);
			
			addEventListener(flash.events.Event.ADDED_TO_STAGE, init);
		}
		
		protected function start():void
		{
			Starling.handleLostContext = true;
			Starling.multitouchEnabled = true;
			setUpStarling(true);
			starlingObject.simulateMultitouch = false;
			
			Gestouch.inputAdapter = new NativeInputAdapter(stage);
			Gestouch.addDisplayListAdapter(DisplayObject, new StarlingDisplayListAdapter());
			Gestouch.addTouchHitTester(new StarlingTouchHitTester(starlingObject), -1);
			
			fullScreen(1);
			
			FullScreenExtension.stage.addChild(loadingCanvas);
			
			gameData = GameData.getInstance();
			
			_input.keyboard = new GameKeyboard("keyboard");
			_input.mouse = new GameMouse("Mouse");
			
			if (GameOptions.USE_GAMEPAD)
				_gamePadManager = new GamePadManager(2);
		}
		
		/**
		 * Set fullscreen.
		 * Soon, this class will control how game goes to fullscreen (resolution and etc).
		 * There is a need to controle PC fullscreen resolution, in cases of low spec and player whant to play in lower resolution.
		 */
		public function fullScreen(screenWidthRatio:Number = 1):void
		{
			//var screenWidth:int = Capabilities.screenResolutionX * screenWidthRatio;
			//var screenHeight:int = Capabilities.screenResolutionY * screenWidthRatio;
			var screenWidth:int = 400;
			var screenHeight:int = 200;

			stage.scaleMode = StageScaleMode.SHOW_ALL;
			stage.align = StageAlign.TOP_LEFT;
			
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			
			inScreenRec.setTo(0, 0, FullScreenExtension.screenWidth, FullScreenExtension.screenHeight);
			outScreenRec.setTo(-FullScreenExtension.screenWidth, -FullScreenExtension.screenHeight, FullScreenExtension.screenWidth * 2, FullScreenExtension.screenHeight * 2);
			//inScreenRec = new Rectangle(FullScreenExtension.screenWidth, FullScreenExtension.screenHeight, FullScreenExtension.screenWidth, FullScreenExtension.screenHeight);
			//outScreenRec = new Rectangle(-FullScreenExtension.screenWidth * .5, -FullScreenExtension.screenHeight * .5, FullScreenExtension.screenWidth * 2, FullScreenExtension.screenHeight * 2);
			
			FullScreenExtension.showStageBounds = false;
		}
		
		/** Set up things that need the stage access. */
		protected function init(e:flash.events.Event):void
		{
			removeEventListener(flash.events.Event.ADDED_TO_STAGE, init);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(flash.events.Event.DEACTIVATE, stageDeactivated);
			//stage.addEventListener(flash.events.Event.ACTIVATE, stageActivated);
			
			_input.initialize();
		}
		
		/**
		 * You should call this function to create your Starling view. The RootClass is internal, it is never used elsewhere.
		 * StarlingState is added on the starling stage : <code>_starling.stage.addChildAt(_state as StarlingState, _stateDisplayIndex);</code>
		 * @param debugMode If true, display a Stats class instance.
		 * @param antiAliasing The antialiasing value allows you to set the anti-aliasing (0 - 16), generally a value of 1 is totally acceptable.
		 * @param viewPort Starling's viewport, default is (0, 0, stage.stageWidth, stage.stageHeight, change to (0, 0, stage.fullScreenWidth, stage.fullScreenHeight) for mobile.
		 */
		public function setUpStarling(debugMode:Boolean = false, antiAliasing:uint = 1, viewPort:Rectangle = null):void
		{
			if (!viewPort)
				viewPort = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			
			//_starling = new Starling(RootClass, stage, viewPort, null, "auto", Context3DProfile.BASELINE_EXTENDED);
			
			_starling = FullScreenExtension.createStarling(RootClass, stage, 1920, 1080, HAlign.CENTER, VAlign.CENTER, false, desiredContext3DProfile);
			
			_starling.antiAliasing = antiAliasing;
			_starling.showStats = debugMode;
			
			_starling.addEventListener(starling.events.Event.CONTEXT3D_CREATE, _context3DCreated);
		}
		
		/**  Be sure that starling is initialized (especially on mobile).*/
		protected function _context3DCreated(evt:starling.events.Event):void
		{
			_starling.removeEventListener(starling.events.Event.CONTEXT3D_CREATE, _context3DCreated);
			
			if (!_starling.isStarted)
				_starling.start();
			
			_currentTime = getTimer() * 0.001;
			_lastTime = _currentTime;
			
			startScreen = new StartScreen(prepareAssets);
			loadingCanvas.addChild(startScreen);
			
			Starling.current.context.ignoreResourceLimits = true;

			trace("[GAMEENGINE]contentScaleFactor", Starling.contentScaleFactor);
			trace("[GAMEENGINE]driverInfo:", Starling.current.context.driverInfo);
		}
		
		/** Prepare assets managers parsng xmls. When done call loadTextures() */
		public function prepareAssets():void
		{
			assets = new GameAssets();
			assets.onTexturesReady.addOnce(loadTextures);
			assets.onSoundsReady.addOnce(onAllSoundsLoaded);
		}
		
		public function onAllSoundsLoaded():void
		{
			allSoundsLoaded = true;
			onAllLoaded("");
		}
		public var allSoundsLoaded:Boolean;
		
		/** Loads initial textures */
		private var texturePacks:Vector.<String> = new Vector.<String>();
		
		public function loadTextures():void
		{
			_currentTime = getTimer() * 0.001;
			
			trace("[MAIN]StartScreen loaded in: " + (_currentTime - _lastTime) + " seconds");
			trace("[MAIN]Loading Starting Textures");
			
			_lastTime = _currentTime;
			
			//Getter the packs that should be loaded
			texturePacks.push("Fonts", "OptionsMenu");
			
			//Pre Load some textures
			assets.checkInTexturePack("SephiusL", null, "GAME_ENGINE");
			assets.checkInTexturePack("SephiusR", null, "GAME_ENGINE");
			//assets.checkInTexturePack("Aekon", null, "GAME_ENGINE");

			//Load thoses packs
			var packName:String;
			for each (packName in texturePacks){
				assets.checkInTexturePack(packName, onAllLoaded, "GAME_ENGINE");
			}
		}
		
		protected function onAllLoaded(packName:String):void
		{
			//Remove from list, packs that was aready loaded. If all get removed continue
			trace("[GAMEENGINE] Texture pack " + packName + " ready. Missing:" + texturePacks.length);
			
			if (texturePacks.indexOf(packName) > -1)
				texturePacks.splice(texturePacks.indexOf(packName), 1)
			if (texturePacks.length > 0 || !allSoundsLoaded)
				return;
			
			TweenMax.to(startScreen, 1, {alpha: 0, onComplete: loadingCanvas.removeChild, onCompleteParams: [startScreen, true]});
			
			_currentTime = getTimer() * 0.001;
			trace("[MAIN]Starting Textures loaded in: " + (_currentTime - _lastTime) + " seconds");
			_lastTime = _currentTime;
			
			assets.createFonts();
			
			loadingScreen = new LoadingScreen();
			
			//gameTitle = new GameTitle();
			replaceState(new GameTitle());
			
			//TweenMax.delayedCall(1, GameData.getInstance().newGame);
			
			soundComponent = new GlobalSoundComponent("MainSound");
			sound.soundSystem.registerComponent(soundComponent);
			
			//Create Pools
			Natures.defineNaturesLists();
		
			//GameData.getInstance().overrideProperties();
		}
		
		public function startGame(levelRegion:LevelRegion):void
		{
			var levelName:String = "LevelManager_" + int(Math.random() * 100000);
			var newState:GameState = new LevelManager(levelRegion);
			newState.name = levelName;
			trace(String(newState.name));
			TweenMax.delayedCall(1.1, replaceState, [newState]);
		}
		
		public function updateScreenViews():void
		{
			inScreenRec.setTo(0, 0, FullScreenExtension.screenWidth, FullScreenExtension.screenHeight);
			outScreenRec.setTo(-FullScreenExtension.screenWidth, -FullScreenExtension.screenHeight, FullScreenExtension.screenWidth * 2, FullScreenExtension.screenHeight * 2);
			//trace("screen recs updated " + " in:" + inScreenRec + " out:" + outScreenRec);
		}
		
		private var randomFinal:Number = 1;
		private var sRandomSeed:Number = 1;
		private var randomVariance:Number = 1;
		public var frameTimeRatio:Number = 1;
		
		/** This is the game loop. It switches states if necessary, then calls update on the current state.
		 * Its also determine delta times during frame updates to be used on update logic in order to keep consistent speed in variable framerates */
		protected function masterUpdate(e:flash.events.Event):void
		{
			_currentTime = getTimer() / 1000;

			timeSinceEngineStart += _startTime - _currentTime;

			//randomFinal = randomVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			
			//trace(randomFinal.toFixed(4));
			
			//UpdateGameTime
			
			if ((_state as LevelManager && !_state.playing) || !_playing)
				timeMarks.pausedTime += _currentTime - _lastTime;
			
			if (!_playing)
			{
				state.currentTime = _currentTime;
				state.lastTime = _currentTime;
				_lastTime = _currentTime;
			}
			else
			{
				frameTime = (_currentTime - _lastTime);
				//frameTime = frameTime < GamePhysics.FIXED_TIMESTEP ? GamePhysics.FIXED_TIMESTEP : frameTime;
				
				//trace("GE GetTIMER: " + getTimer() + " CT: " + _currentTime + " LT: " + _lastTime + " FT: " + frameTime);
				_lastTime = _currentTime;
				
				//Change states if it has been requested
				if (_newState)
				{
					if (_starling.isStarted && _starling.context && _state)
					{
						_state.destroy();
						FullScreenExtension.stage.removeChild(_state);
							// Remove Box2D or Nape debug view
							//var debugView:DisplayObject = _starling.nativeStage.getChildByName("debug view");
							//if (debugView)
							//_starling.nativeStage.removeChild(debugView);
					}
					
					_state = _newState;
					_newState = null;
					
					FullScreenExtension.stage.addChildAt(_state, _stateDisplayIndex);
					
					if (loadingScreen.loaded)
						_state.initialize();
					else
						loadingScreen.onLoaded.add(_state.initialize);
				}
				
				//Update the state
				if (_state && _state.Initialized)
				{
					updateScreenViews();
					
					_state.update(frameTime);
					_sound.soundSystem.update(frameTime);
				}
				else
				{
					GameEngine.instance.timeMarks.inputCountCheck(true);
					_input.update();
					GameEngine.instance.timeMarks.inputCountStepCheck();
					GameEngine.instance.timeMarks.inputCountCheck(false);
					
					GameEngine.instance.timeMarks.starlingCountCheck(true);
					if (!GameEngine.instance.starlingObject.shareContext)
						GameEngine.instance.starlingObject.nextFrame(frameTime);
					GameEngine.instance.timeMarks.starlingCountStepCheck();
				}
				
				if (!starlingObject.shareContext)
					starlingObject.render();
				
				if (loadingScreen)
					loadingScreen.update();
				
				timeMarks.count++;
			}
		}
		
		protected function stageDeactivated(e:flash.events.Event):void
		{
			if (!_state)
				return;
			
			if (_playing)
			{
				//playing = false;
				stage.addEventListener(flash.events.Event.ACTIVATE, stageActivated);
				stage.removeEventListener(flash.events.Event.DEACTIVATE, stageDeactivated);
			}
		}
		
		protected function stageActivated(e:flash.events.Event):void
		{
			if (!_playing)
			{
				playing = true;
				stage.removeEventListener(flash.events.Event.ACTIVATE, stageActivated);
				stage.addEventListener(flash.events.Event.DEACTIVATE, stageDeactivated);
			}
		}
		
		/** The debug canvas on witch debug physics is rendered */
		public function get debugCanvas():Sprite  { return _debugCanvas; }
		protected var _debugCanvas:Sprite;
		
		/** If physic debug canvas is visible */
		public function get debugCanvasVisible():Boolean  { return _debugCanvasVisible; }
		protected var _debugCanvasVisible:Boolean = false;
		
		public function set debugCanvasVisible(value:Boolean):void
		{
			if (value)
			{
				_debugCanvas = new Sprite();
				FullScreenExtension.stage.addChild(_debugCanvas);
			}
			else
			{
				FullScreenExtension.stage.removeChild(_debugCanvas);
				_debugCanvas = null;
			}
			_debugCanvasVisible = value;
		}

	}
}
import starling.display.Sprite;

/**
 * RootClass is the root of Starling, it is never destroyed and only accessed through <code>_starling.stage</code>.
 */
internal class RootClass extends Sprite
{
	
	public function RootClass()
	{
	}
}
