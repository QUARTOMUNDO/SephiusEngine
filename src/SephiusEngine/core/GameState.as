package SephiusEngine.core 
{
	import SephiusEngine.core.GameData;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.GamePhysics;
	import SephiusEngine.core.GameView;
	import SephiusEngine.core.effects.GlobalEffects;
	import SephiusEngine.core.gameStates.LevelManager;
	import SephiusEngine.displayObjects.particles.ParticleSystemEX;
	import SephiusEngine.levelObjects.GameObject;
	import tLotDClassic.gameObjects.characters.Characters;
	import tLotDClassic.gameObjects.characters.Sephius;
	import SephiusEngine.levelObjects.interfaces.IPhysicSoundEmitter;
	import SephiusEngine.levelObjects.interfaces.IPhysicalObject;
	import SephiusEngine.levelObjects.interfaces.ISpriteSoundEmitter;
	import SephiusEngine.levelObjects.interfaces.ISpriteView;
	import SephiusEngine.userInterfaces.UserInterfaces;
	import SephiusEngine.utils.pools.ELootAPool;
	import SephiusEngine.utils.pools.ParticlePool;
	import SephiusEngine.utils.pools.PresencePool;
	import SephiusEngine.utils.pools.SplashPool;
	import SephiusEngine.utils.pools.SplashTextPool;

	import com.greensock.TimelineLite;
	import com.greensock.TweenMax;

	import flash.utils.getTimer;

	import org.osflash.signals.Signal;

	import starling.animation.Juggler;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.Sprite;

	import tLotDClassic.GameData.Properties.CutsceneProperties;
	import SephiusEngine.Languages.LanguageManager;
	import SephiusEngine.math.MathUtils;
	
	/**
	 * Game state usually contains the logic for a particular state the game is in.
	 * The main game play state is LevelManager witch manage all game areas and GameEngine objects.
	 * There can only ever be one state running at a time.
	 * The Game State is actually the game itself
	 * @author Fernando Rabello
	 */
	public class GameState extends Sprite {
		/** Store objects not added to state.*/
		public var storedObjects:Vector.<GameObject> = new Vector.<GameObject>();
		
		/** Store all objects witch was added to the state */
		public var addedObjects:Vector.<GameObject> = new Vector.<GameObject>();
		
		/** View menage the visual representation of the objects */
		public var view:GameView;
		
		/** State physic object */
		public var physics:GamePhysics;
		
		/** Effects related with enviroments, ui and etc */
		public var globalEffects:GlobalEffects;
		
		/**Container that contains HUD and other interface assets. 
		 * This container should be outside View cause it does not should inherit it´s proprieties.*/
		public var userInterfaces:UserInterfaces;
		
		/** Game Juggler manage all animation updates related with a game state
		 * Stoping this juggler all animations related with game will stop */
		public var gameJuggler:Juggler =  new Juggler();
		
		/** Used to pause tweens and delay calls when game pause */
		public var allTweens:TimelineLite;
		
		/** State is ready not straming content */
		public var onInitialized:Signal;
		
		/** Dispach a signal when state was fully created */
		public var Initialized:Boolean = false;
		
		/** State is ready not straming content */
		public var onReady:Signal;
		
		/** Dispach a signal when state was fully created */
		public var onNotReady:Signal;
		
		/** Tell is state is ready witch means initial state is fully setted
		 * GameState will only real updates when it is ready*/
		public var isReady:Boolean = false;
		
		/** Used to pause animations in SpriteArt and StarlingArt.*/
		public var onPlayingChange:Signal;
		
		public function get paused():Boolean { return _paused; }
		protected var _paused:Boolean = false;
		
		public function set paused(value:Boolean):void {
			playing = !value;
			_paused = value;
		}
		
		/** Initial textures witch state need to load to be ready to run. 
		 * onReady can dispach if this packs does not gets loaded */
		public var texturePacksUsed:Vector.<String> = new Vector.<String>();
		
		/** Tell if all textures was fully loaded. */
		public function get texturesLoaded():Boolean  {return _texturesLoaded;}
		public function set texturesLoaded(value:Boolean):void {
			_texturesLoaded = value;
			if (value)
				onTexturesLoaded.dispatch(this);
		}
		protected var _texturesLoaded:Boolean;
		
		/** Dispach a signal when all textures gets fully loaded. */
		public var onTexturesLoaded:Signal = new Signal(GameState);

		protected var texturePacksMissing:Vector.<String> = new Vector.<String>();
		/** Verify if all textures from this area was loaded */
		protected function onTextureLoaded(packName:String):void {
			//Remove from list, packs that was aready loaded. If all get removed continue
			if(texturePacksMissing.indexOf(packName) > -1)
				texturePacksMissing.splice(texturePacksMissing.indexOf(packName), 1)
			
			trace("[GameState] Texture pack " + packName + " ready. Missing:" + texturePacksMissing.length);
			
			if (texturePacksMissing.length > 0)
				return;
			
			texturesLoaded = true;
		}
		
		/** @return true if the Game State is playing */		
		public function get playing():Boolean { return _playing; }
		protected var _playing:Boolean = true;
		/*
		 * Runs and pauses the game state loop. Assign this to false to pause the game and stop the
		 * <code>update()</code> methods from being called.
		 * Dispatch the Signal onPlayingChange with the value
		 */
		public function set playing(value:Boolean):void {
			if (!value && _playing){
				Starling.juggler.remove(gameJuggler);
				
				allTweens = TimelineLite.exportRoot(null, false);
				allTweens.stop();
			}
			
			else if (value && !_playing){
				Starling.juggler.add(gameJuggler);
				
				if(allTweens)
					allTweens.play();	
			}
			
			_playing = value;
			onPlayingChange.dispatch(_playing);
		}
		
		/** Just a function to pause/unpause the game. You can just set pause propertie to do samething */
		private function playSwitch(value:Boolean):void {
			if (paused)
				return;
			
			playing = value;
		}
		
		private function fadeState(gameState:GameState):void {
			if(gameState.view)
				TweenMax.to(gameState.view, 1, { alpha:1 } );
			onReady.remove(fadeState);
		}
		
		/** Player witch is plaing game with input 1 */
		public function get player1():Sephius {return _player1;}
		public function set player1(value:Sephius):void {
			if (_player1 == value)
				return;
				this
			if(_player1 && view.camera.otherTargets.indexOf(_player1))
				view.camera.otherTargets.splice(view.camera.otherTargets.indexOf(_player1), 1);
			
			_player1 = value;
			
			if(_player1 && view.camera.otherTargets.indexOf(_player1))
				view.camera.otherTargets.push(_player1);
		}
		private var _player1:Sephius;
		
		/** Player witch is plaing game with input 1 */
		public function get player2():Sephius {return _player2;}
		public function set player2(value:Sephius):void {
			if (_player2 == value)
				return;
				
			if(_player2 && view.camera.otherTargets.indexOf(_player2))
				view.camera.otherTargets.splice(view.camera.otherTargets.indexOf(_player2), 1);
			
			_player2 = value;
			
			if(_player2 && view.camera.otherTargets.indexOf(_player2))
				view.camera.otherTargets.push(_player2);
		}
		private var _player2:Sephius;
		
		/** Return the player witch is treated as main, witch level systems will use as reference */
		public function get mainPlayer():Sephius {return _mainPlayer;}
		public function set mainPlayer(value:Sephius):void {
			if (_mainPlayer == value)
				return;
			
			if (_mainPlayer)
				_mainPlayer.deadSignal.remove(_onMainPlayerDeath);
			
			_mainPlayer = value;
			
			view.camera.mainTarget = _mainPlayer;
			userInterfaces.inputWatcher = _mainPlayer.inputWatcher;
			
			if(userInterfaces.hud)
				userInterfaces.hud.player = _mainPlayer;
			
			if(userInterfaces.storyUI)
				_mainPlayer.presence.onPlaceNatureChanged.add(userInterfaces.storyUI.changeSkin);
			
			_mainPlayer.deadSignal.add(_onMainPlayerDeath);
		}
		
		protected var _mainPlayer:Sephius;
		
		protected function _onMainPlayerDeath(mainPlayer:Characters):void {
			GameEngine.instance.state.view.camera.shake(null, 5);
			gameOverType = GAMEOVER_TYPE_PLAYER_DEATH;
			gameOverTimer = 3;
		}
		
		public function onMainBossDeath(mainPlayer:Characters):void {
			GameEngine.instance.state.view.camera.shake(null, 5);
			gameOverType = GAMEOVER_TYPE_BOSS_DEATH;
			gameOverTimer = 0;
		}
		
		public var gameOverType:String;
		public static const GAMEOVER_TYPE_PLAYER_DEATH:String = "playerDeath";
		public static const GAMEOVER_TYPE_BOSS_DEATH:String = "bossDeath";
		
		public function get gameOverTimer():Number {return _gameOverTimer;}
		public function set gameOverTimer(value:Number):void {
			_gameOverTimer = value;
			//trace("GAME STATE _gameOverTimer: ", _gameOverTimer);
			if (_gameOverTimer <= 0) {
				//trace("GAME STATE start game over:");
				_gameOverTimer = 0;
				
				GameEngine.instance.soundComponent.fadeOutAll(1);
				
				if (gameOverType == GAMEOVER_TYPE_PLAYER_DEATH) {
					GameData.getInstance().numberOfDeaths++;

					var randomInt:int = MathUtils.randomInt(0, 4);
					var message:String = LanguageManager.getDialogueSceneLang("DialogueLanguageElements", "Nomegah").scenes["GameOver"][randomInt];//Momegah's subtitle
					
					_mainPlayer.hud.gameOver(gameOverType, message);
					
					GameEngine.instance.state.globalEffects.screenBluring("death");

					GameEngine.instance.soundComponent.play("ST_NOMEGAH_NARRATION_GAMEOVER_" + randomInt, "Site", -1);//Momegah's audio
					GameEngine.instance.soundComponent.play("BGM_Game_Over", "Site", -1);
					
				}
				else if (gameOverType == GAMEOVER_TYPE_BOSS_DEATH) {
					GameEngine.instance.soundComponent.fadeOutAll(2, true);
					userInterfaces.cutscene.callback = cutsceneReset;
					userInterfaces.cutscene.show(CutsceneProperties.AEKON_DEFEATED.varName)
				}
				
				restartTimer = 8;
				reseted = false;
			}
			
		}
		
		public function cutsceneReset():void {}
		
		private var _gameOverTimer:Number = 0;
		public var reseted:Boolean;
		protected var _restartTimer:Number;
		public function get restartTimer():Number {return _restartTimer;}
		public function set restartTimer(value:Number):void {
			_restartTimer = value;
			//trace("GAME STATE _restartTimer: ", _restartTimer);
			if (_restartTimer <= 0) {
				//trace("GAME STATE start reset:");
				_restartTimer = 0;
				GameEngine.instance.state.globalEffects.removeScreenBlur();
			}
		}
		
		private function updateCountDown(timeDelta:Number):void {
			if(gameOverTimer > 0)
				gameOverTimer -= timeDelta;
			
			if(restartTimer > 0)
				restartTimer -= timeDelta;
		}
		
		public function get uiSkin():String {
			if (_mainPlayer)
				return _mainPlayer.presence.placeNature;
			else
				return "Light";
		}
		
		private var fixedFrameTimeAccumulator:Number = 0;
		private var fixedStepAccumulator:Number = 0;
		private var fixedFrameTimeAccumulatorRatio:Number = 0;
		
		/** Dispach when a next step will be processed */
		public var onNextStep:Signal;
		/** Dispach when a step as finsh to update */
		public var onEndStep:Signal;
		
		private var _lastTime:Number = 0;
		
		public function GameState() {
			super();
			//alpha = 0;
			
			onInitialized = new Signal(GameState);
			onReady = new Signal(GameState);
			onNotReady = new Signal(GameState);
			onInitialized.add(fadeState);
			
			onNextStep = new Signal(Number);
			onEndStep = new Signal(Number);
			
			onPlayingChange = new Signal(Boolean);
			GameEngine.instance.onPlayingChange.add(playSwitch);
			
			Starling.juggler.add(gameJuggler);
		}
		
		protected var texturePack:String;
		/**
		 * You'll most definitely want to override this method when you create your own State class. This is where you should
		 * add all your SephiusEngineObjects and pretty much make everything. Please note that you can't successfully call add() on a 
		 * state in the constructur. You should call it in this initialize() method. 
		 */
		public function initialize():void {
			SplashTextPool.initialize();
			SplashPool.initialize();
			PresencePool.initialize();
			ELootAPool.initialize();
			ParticlePool.initialize();
			ParticleSystemEX.init(1024, false, 512, 4);
			
			GameEngine.instance.loadingScreen.onLoaded.remove(initialize);
			
			//Load thoses packs
			for each (texturePack in texturePacksUsed) {
				GameEngine.assets.checkInTexturePack(texturePack, onTextureLoaded, ("GAME_STATE" + (this as LevelManager ? "LEVEL_MANAGER" : "GAME_TITE")));
				texturePacksMissing.push(texturePack);
			}
			
			view = new GameView();
			view.alpha = 0;
			addChildAt(view, 0);
			
			//Set up UI
			userInterfaces = new UserInterfaces(this);
			addChild(userInterfaces);
			
			//Create and add physics to the state
			if(this as LevelManager)
				physics = new GamePhysics();
			//add(physics);
			
			globalEffects = new GlobalEffects();
		}
		
		public var totalTime:Number = 0;
		public var currentTime:Number = 0;
		public var lastTime:Number = 0;
		public var frameTime:Number = 0;
		/**
		 * This method calls update on all the SephiusEngineObjects that are attached to this state.
		 * The update method also checks for SephiusEngineObjects that are ready to be destroyed and kills them.
		 * Finally, this method updates the View manager. 
		 */
		public function update(timeDelta:Number):void {
			if (!Initialized)
				return;
			
			timeDelta /= GameEngine.instance.frameTimeRatio;
			
			parent.alpha = .999;
			var n:uint = addedObjects.length;
			var nLogic:int;
			var nStep:int;
			var object:GameObject;
				
			// Search objects to destroy
			var garbage:Array = [];
			//Search objects to remove
			var removables:Array = [];
			
			//trace("A-GAMESTATE-RENDER", (mainPlayer ? mainPlayer.characterView.mainAnimation.currentFrame : ""));
			
			if(!_playing){
				currentTime = getTimer() / 1000.0;//Need to use delta time, since this time is related with
				lastTime = currentTime;
			}
			
			if (_playing) {
				var MAX_STEPS:int = 5;
				
				updateCountDown(timeDelta);
				
				fixedFrameTimeAccumulator += timeDelta;
				
				var nSteps:int = Math.floor(fixedFrameTimeAccumulator / (GamePhysics.FIXED_TIMESTEP));
			 
				//if (nSteps == 0)
					//nSteps = 1;
				
				fixedFrameTimeAccumulator -= nSteps * (GamePhysics.FIXED_TIMESTEP);
				fixedStepAccumulator = fixedFrameTimeAccumulator;
				
				totalTime += timeDelta - fixedFrameTimeAccumulator;
				
				//fixedFrameTimeAccumulatorRatio = fixedFrameTimeAccumulator / GamePhysics.FIXED_TIMESTEP;
				
				var nStepsClamped:int = Math.min(nSteps, MAX_STEPS);
				
							GameEngine.instance.timeMarks.numOfEngineSteps = nStepsClamped;
				//trace(nStepsClamped, timeDelta);
				for (nStep = 0; nStep < nStepsClamped; ++nStep) {
					fixedStepAccumulator + frameTime;
					
					currentTime = getTimer() / 1000.0;
					frameTime = currentTime - lastTime;
					lastTime = currentTime;
					
					onNextStep.dispatch(timeDelta);
					//trace("processing step " + nStep + 1);
					
									GameEngine.instance.timeMarks.starlingCountCheck(true);
					if (!GameEngine.instance.starlingObject.shareContext)
						GameEngine.instance.starlingObject.nextFrame(GamePhysics.FIXED_TIMESTEP);
					GameEngine.instance.starlingObject.updateNativeOverlay();
									GameEngine.instance.timeMarks.starlingCountStepCheck();
					
					n = addedObjects.length;
					
					//Start to verify the time to process game logic
								GameEngine.instance.timeMarks.logicCountCheck(true);

					if(physics && physics.visible)
						physics.view.clear();
					
					//Update Game Logic
					if (n > 0) {
						//See of object should be updated, removed or destroyed
						for (nLogic = n - 1; nLogic >= 0; --nLogic) {
							object = addedObjects[nLogic];
							if (object.kill) {
								//garbage.push(object);
								remove(object);
								object.destroy();
								n--;
							}
							else if (object.remove) {
								//removables.push(object);
								remove(object);
								//object.remove = false;
								n--;
							}
							else if (object.updateCallEnabled)
								object.update(GamePhysics.FIXED_TIMESTEP);
						}
					}
					
					fixedFrameTimeAccumulatorRatio = fixedStepAccumulator / GamePhysics.FIXED_TIMESTEP;
					
					//verify the time to process game logic
								GameEngine.instance.timeMarks.logicCountStepCheck();
					
					//Update inputs
								GameEngine.instance.timeMarks.inputCountCheck(true);
					GameEngine.instance.input.update();
								GameEngine.instance.timeMarks.inputCountStepCheck();
					
					// Reset view interpolation values
					if(view){
									GameEngine.instance.timeMarks.viewCountCheck(true);
						view.updateViewOldStates();
									GameEngine.instance.timeMarks.viewCountStepCheck();
					}
					//Updates Physics
					if(physics){
									GameEngine.instance.timeMarks.physicCountCheck(true);
						physics.singleStep(GamePhysics.FIXED_TIMESTEP);
									GameEngine.instance.timeMarks.physicCountStepCheck();
					}
					
					if(view){
						// Update the state's view
									GameEngine.instance.timeMarks.viewCountCheck(true);
						view.updateViewNewStates(GamePhysics.FIXED_TIMESTEP);
									GameEngine.instance.timeMarks.viewCountStepCheck();
					}
					
					onEndStep.dispatch(timeDelta);
					
					//Update Interfaces
								GameEngine.instance.timeMarks.uiCountCheck(true);
					userInterfaces.update();
								GameEngine.instance.timeMarks.uiCountStepCheck();
					
				}
				
				if(fixedFrameTimeAccumulatorRatio < 0)
					fixedFrameTimeAccumulatorRatio = 0;
				if(fixedFrameTimeAccumulatorRatio > 1)
					fixedFrameTimeAccumulatorRatio = 1;
						
				//Finish verify the time to process game logic
							if(nStepsClamped > 0){
								GameEngine.instance.timeMarks.starlingCountCheck(false, nStepsClamped);
								GameEngine.instance.timeMarks.logicCountCheck(false, nStepsClamped);
								GameEngine.instance.timeMarks.physicCountCheck(false, nStepsClamped);
								GameEngine.instance.timeMarks.uiCountCheck(false, nStepsClamped);
								GameEngine.instance.timeMarks.debugCountCheck(false);
							}
				if(view){
					// Interpolates the view´s state
								GameEngine.instance.timeMarks.viewCountCheck(true);
					view.smoothViewStates(fixedFrameTimeAccumulatorRatio);
								GameEngine.instance.timeMarks.viewCountStepCheck();
								GameEngine.instance.timeMarks.viewCountCheck(false);
				}
			}
			else {
							GameEngine.instance.timeMarks.inputCountCheck(true);
				GameEngine.instance.input.update();
							GameEngine.instance.timeMarks.inputCountStepCheck();
							GameEngine.instance.timeMarks.inputCountCheck(false);
				
							GameEngine.instance.timeMarks.uiCountCheck(true);
				userInterfaces.update();
							GameEngine.instance.timeMarks.uiCountStepCheck();
							GameEngine.instance.timeMarks.uiCountCheck(false, nStepsClamped);
				
							GameEngine.instance.timeMarks.starlingCountCheck(true);
				if (!GameEngine.instance.starlingObject.shareContext)
					GameEngine.instance.starlingObject.nextFrame(timeDelta);
				GameEngine.instance.starlingObject.updateNativeOverlay();
							GameEngine.instance.timeMarks.starlingCountStepCheck();
							GameEngine.instance.timeMarks.starlingCountCheck(false, nStepsClamped);
			}
		}
		
		/**
		 * Call this method to add a SephiusEngineObject to this state. All visible game objects and physics objects
		 * will need to be created and added via this method so that they can be properly created, managed, updated, and destroyed. 
		 * @return The SephiusEngineObject that you passed in. Useful for linking commands together.
		 */
		public function add(object:GameObject):GameObject {
			// avoid to add same object multiple times!!
			if (object.addedToState) 
 				return object;
			
			if (object is IPhysicalObject)
				(object as IPhysicalObject).addPhysics();
			
			addedObjects.push(object);
			
			if ((object is ISpriteView) && (object as ISpriteView).view)
				(object as ISpriteView).addView();
			
			if (object as IPhysicSoundEmitter)
				(object as IPhysicSoundEmitter).addSound();
			
			else if(object as ISpriteSoundEmitter)
				(object as ISpriteSoundEmitter).addSound();
			
			object.addedToState = true;
			object.remove = false;
			
			return object;
		}
		
		/** Remove a object from state. IT DOES NOT DESTROY THE OBJECT */
		public function remove(object:GameObject):void {
			//trace("GAMESTATE: REMOVING OBJECT", object.name);
			// avoid to add same object multiple times!!
			if (!object.addedToState)
				return;
			
			if (object is IPhysicalObject)
				if((object as IPhysicalObject).physicAdded)
					(object as IPhysicalObject).removePhysics();
			
			if ((object is ISpriteView) && (object as ISpriteView).view)
				if((object as ISpriteView).viewAdded)
					(object as ISpriteView).removeView();
			
			if (object as IPhysicSoundEmitter)
				if((object as IPhysicSoundEmitter).soundAdded)
					(object as IPhysicSoundEmitter).removeSound();
			
			else if (object as ISpriteSoundEmitter)
				if((object as ISpriteSoundEmitter).soundAdded)
					(object as ISpriteSoundEmitter).removeSound();
			
			addedObjects.splice(addedObjects.indexOf(object), 1);
			object.addedToState = false;
		}
		
		public var destroyed:Boolean;
		/** Called by the Game Engine. Destoy state completly and its objects, view and arts */
		public function destroy():void {
			if (destroyed)
				return;
			
			playing = false;
			
			// Call destroy on all objects, and remove all art from the stage.
			var n:uint = storedObjects.length;
			var i:int;
			var object:GameObject;
			
			for (i = n - 1; i >= 0; --i) {
				object = storedObjects[i];
				//remove(object);
				object.destroy();
			}
			
			storedObjects.length = 0;
			addedObjects.length = 0;
			
			if(view!=null){
				view.destroy();
				view = null;
			}
			
			if(physics!=null){
				physics.destroy();
				physics = null;
			}
			
			onReady.removeAll();
			onReady = null;
			
			onInitialized.removeAll();
			onInitialized = null;
			
			onNotReady.removeAll();
			onNotReady = null;
			
			for each (texturePack in texturePacksUsed) {
				GameEngine.assets.checkOutTexturePack(texturePack, ("GAME_STATE" + (this as LevelManager ? "LEVEL_MANAGER" : "GAME_TITE")));
			}
			
			globalEffects.dispose();
			
			userInterfaces.dispose();

			gameJuggler.purge();
			gameJuggler = null;
			
			destroyed = true;

			TweenMax.killAll();///DANGEROUS!!!!!!!!

			///_starling.nativeStage.removeChild(debugView);
		}
		
		/**
		 * Gets a reference to a SephiusEngineObject by passing that object's name in.
		 * Often the name property will be set via a level editor such as the Flash IDE. 
		 * @param name The name property of the object you want to get a reference to.
		 */
		public function getObjectByName(name:String):GameObject {
			var object:GameObject;
			for each (object in addedObjects) {
				if (object.name == name)
					return object;
			}
			return null;
		}
		
		/**
		 * This returns a vector of all objects of a particular name. This is useful for adding an event handler
		 * to objects that aren't similar but have the same name. For instance, you can track the collection of 
		 * coins plus enemies that you've named exactly the same. Then you'd loop through the returned vector to change properties or whatever you want.
		 * @param name The name property of the object you want to get a reference to.
		 */
		public function getObjectsByName(name:String):Vector.<GameObject> {
			var objects:Vector.<GameObject> = new Vector.<GameObject>();
			var object:GameObject;
			for each (object in objects) {
				if (object.name == name)
					objects.push(object);
			}
			return objects;
		}
		
		/**
		 * This returns a vector of all objects of a particular type. This is useful for adding an event handler
		 * to all similar objects. For instance, if you want to track the collection of coins, you can get all objects
		 * of type "Coin" via this method. Then you'd loop through the returned array to add your listener to the coins' event.
		 * @param type The class of the object you want to get a reference to.
		 */
		public function getObjectsByType(type:Class):Vector.<GameObject> {
			var objects:Vector.<GameObject> = new Vector.<GameObject>();
			var object:GameObject;
			for each (object in objects) {
				if (object is type) {
					objects.push(object);
				}
			}
			return objects;
		}
		
		override public function render(support:RenderSupport, parentAlpha:Number):void {
			GameEngine.instance.timeMarks.renderCountCheck(true);
			super.render(support, parentAlpha);
			GameEngine.instance.timeMarks.renderCountStepCheck();
			GameEngine.instance.timeMarks.renderCountCheck(false);
		}
		
		/**
		 * Destroy all the objects added to the State and not already killed.
		 * @param except you want to save.
		 */
		public function killAllObjects(except:Array):void {
			var objectToKill:GameObject;
			var objectToPreserve:GameObject;
			
			for each (objectToKill in addedObjects) {
				objectToKill.kill = true;
				for each (objectToPreserve in except) {
					if (objectToKill == objectToPreserve) {
						objectToPreserve.kill = false;
						except.splice(except.indexOf(objectToPreserve), 1);
						break;
					}
				}
			}
		}
	}
}