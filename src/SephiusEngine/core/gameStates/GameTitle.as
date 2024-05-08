package SephiusEngine.core.gameStates 
{
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.GameState;
	import SephiusEngine.core.effects.GlobalEffects;
	import SephiusEngine.core.gameStates.LevelManager;
	import SephiusEngine.core.levelManager.GameOptions;
	import SephiusEngine.userInterfaces.UserInterfaces;

	import starling.core.Starling;

	import tLotDClassic.GameData.Properties.CutsceneProperties;
	
	/**
	 * ...
	 * @author Fernando Rabello & Nilo Paiva
	 */
	
	public class GameTitle extends GameState {
		public function GameTitle() {
			super();
			texturePacksUsed.push("GameTitle");	
		} 
		
		/**
		 * You'll most definitely want to override this method when you create your own State class. This is where you should
		 * add all your SephiusEngineObjects and pretty much make everything. Please note that you can't successfully call add() on a 
		 * state in the constructur. You should call it in this initialize() method. 
		 */
		override public function initialize():void {
			//super.initialize();
			//GameEngine.assets.checkInTexturePack("Aekon", null, "LevelManager");
			
			globalEffects = new GlobalEffects();
			
			GameEngine.instance.loadingScreen.onLoaded.remove(initialize);
			
			Starling.current.showStats = GameOptions.SHOW_STATS;
			
			//Load thoses packs
			for each (texturePack in texturePacksUsed) {
				GameEngine.assets.checkInTexturePack(texturePack, onTextureLoaded, "GAME_STATE" + (this as LevelManager ? "LEVEL_MANAGER" : "GAME_TITE"));
				texturePacksMissing.push(texturePack);
			}
			
			//Set up UI
			userInterfaces = new UserInterfaces(this);
			userInterfaces.init();
			addChild(userInterfaces);
			
			//this.visible = false;
			userInterfaces.cutscene.callback = showTitle;
			userInterfaces.cutscene.show(CutsceneProperties.INTRO.varName);
			
			//GameOptions.DISABLE_MUSIC = true;
			//GameEngine.instance.soundComponent.play("BGM_Title", "BGFX", 0.6, true);
		}
		
		public function showTitle():void{
			//this.visible = true;
		}
		
		/** Says if state textures get loaded */
		override public function set texturesLoaded(value:Boolean):void {
			super.texturesLoaded = value;
			trace("[GAMETITLE] States Texture " + (value ? "LOADED" : "NOT LOADED"));
			onReady.dispatch(this);
			isReady = true;
			onInitialized.dispatch(this);
			Initialized = true;
			trace ("[GAMETITLE] State is Ready");
		}
		
		public var videoMaxCounter:int = 60 * 20;
		public var videoCounter:int = 0;
		public var playVideos:Boolean = true;
		public var currentCutscene:CutsceneProperties = CutsceneProperties.GAMPLAY_SHOWREEL1;
		public var cutscene1:CutsceneProperties = CutsceneProperties.INTRO;
		public var cutscene2:CutsceneProperties = CutsceneProperties.GAMPLAY_SHOWREEL1;
		public var cutscene3:CutsceneProperties = CutsceneProperties.APARTUS_SHOWROOM;
		public var cutscene4:CutsceneProperties = CutsceneProperties.AEKON_SHOWROOM;
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			if (_playing && !userInterfaces.anySubMenuOnScreen && playVideos && !userInterfaces.titleMenu.holdTitle){
				if (videoCounter >= videoMaxCounter){
					videoCounter = 0;
					userInterfaces.cutscene.callback = showTitle;
					userInterfaces.cutscene.show(currentCutscene.varName);
					currentCutscene = currentCutscene == cutscene1 ? cutscene2 : currentCutscene == cutscene2 ? cutscene3 : currentCutscene == cutscene3 ? cutscene4 : cutscene1;
				}
				else if (userInterfaces.anySubMenuOnScreen || userInterfaces.inputWatcher.isDoingAnything())
					videoCounter = 0;
				else
					videoCounter++;
			}
			else
				videoCounter = 0;
		}
		
		override public function destroy():void {
			super.destroy();
		}
	}
}