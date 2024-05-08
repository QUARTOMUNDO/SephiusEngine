package SephiusEngine.userInterfaces {
	import SephiusEngine.assetManagers.ExtendedAssetManager;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.GameState;
	import SephiusEngine.core.gameStates.GameTitle;
	import SephiusEngine.core.gameStates.LevelManager;
	import SephiusEngine.input.InputActionsNames;
	import SephiusEngine.input.InputWatcher;
	import SephiusEngine.userInterfaces.menus.*;
	import SephiusEngine.userInterfaces.menus.screenMenus.*;

	import com.greensock.TweenMax;

	import org.osflash.signals.Signal;

	import starling.display.BlendMode;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.extensions.brinkbit.fullscreenscreenextension.FullScreenExtension;

	import tLotDClassic.ui.BossHUD;
	import tLotDClassic.ui.HUD;
	import tLotDClassic.ui.debug.DebugControls;
	import SephiusEngine.core.GameData;
	import SephiusEngine.core.gameplay.inventory.Inventory;

	
	/**
	 * Control all interfaces in the game. 
	 * @author Fernando Rabello
	 */
	public class UserInterfaces extends Sprite {
		private var _showGameMap:Boolean;
		
		public var aboveMenuContainers:Sprite = new Sprite();
		public var menusContainers:Sprite = new Sprite();
		public var belowMenuContainers:Sprite = new Sprite();
		
		public function get anySubMenuOnScreen():Boolean{
			if(_gameState as LevelManager)
				return (optionsMenu.visible || exitMenu.visible || overrideMenu.visible || gameMenu.visible);
			else if (_gameState as GameTitle)
				return (optionsMenu.visible || exitMenu.visible || overrideMenu.visible);
			else
				return false;
		}
		
		public var optionsMenu:OptionsMenu; 
		public var exitMenu:ExitMenu; 
		public var overrideMenu:OverrideMenu;
		
		public var gameMenu:GameMenu;
		
		public var hud:HUD;
		public var hud2:HUD;
		public var newRewardUI:NewRewardUI = new NewRewardUI();
		public var bossHud:BossHUD;
		public var gameMap:GameMap;
		public var fadeEffectBrigth:Quad = new Quad(10, 10, 0xffffff);
		
		public var pauseMenu:PauseMenu;
		public var titleMenu:TitleMenu;
		
		public var debug:DebugControls;
		
		public var cutscene:Cutscene;
		public var storyUI:StoryUI;
		public var helpUI:HelpUI;
		
		/** Reference to Main class */
		protected var _gameState:GameState;
		
		private var _assets:ExtendedAssetManager;
		
		public var inputWatcher:InputWatcher;
		
		public static var instance:UserInterfaces;
		
		public var holdMenus:Boolean;
		
		public function UserInterfaces(state:GameState) {
			_gameState = state;
			instance = this;
			addChild(belowMenuContainers);
			addChild(menusContainers);
			addChild(aboveMenuContainers);
			
			if (_gameState as LevelManager){
				gameMap = new GameMap();
				belowMenuContainers.addChild(gameMap);
			}
		}
		
		private function showNewReward(rewardID:String, rewardType:String):void{
			newRewardUI.show(rewardID, rewardType, menusContainers);
		}

		public var gameOptionsLoaded:Boolean = false;
		public function init():void {
			if(!gameOptionsLoaded){
				GameData.getInstance().loadGameOptions();
				gameOptionsLoaded = true;
			}

			optionsMenu = new OptionsMenu("OptionsMenu");
			exitMenu = new ExitMenu("OptionsMenu");
			overrideMenu = new OverrideMenu("OptionsMenu");

			if (_gameState as LevelManager){
				_gameState.mainPlayer.inventory.onObjectAdded.add(showNewReward);
				_gameState.mainPlayer.inventory.onSingleNatureAdded.add(showNewReward);

				inputWatcher = _gameState.mainPlayer.inputWatcher;
				
				newRewardUI.inputWatcher = inputWatcher;

				hud = new HUD(_gameState.mainPlayer);
				hud.showSite(_gameState.mainPlayer.presence.placeArea.site);
				menusContainers.addChildAt(hud, 0);

				helpUI = new HelpUI(_gameState.mainPlayer);
				belowMenuContainers.addChild(helpUI);

				pauseMenu = new PauseMenu();
				gameMenu = new GameMenu();
				
				if(_gameState.player2){
					hud2 = new HUD(_gameState.player2);
					menusContainers.addChildAt(this, 0);
					hud2.x += 800;
					hud2.scaleX = hud2.scaleY = .5;
					hud2.showHUD();
				}
				
				storyUI = new StoryUI();
				aboveMenuContainers.addChild(storyUI);
				
				cutscene = new Cutscene();
				aboveMenuContainers.addChild(cutscene);
				
				if(DebugControls.debugEnabled){
					debug = DebugControls.getInstance();
					GameEngine.instance.state.onNextStep.add(debug.updateDebugControls);
				}
				
				fadeEffectBrigth.x = FullScreenExtension.screenLeft;
				fadeEffectBrigth.y = FullScreenExtension.screenTop;
				fadeEffectBrigth.width = FullScreenExtension.screenWidth;
				fadeEffectBrigth.height = FullScreenExtension.screenHeight;
				fadeEffectBrigth.alpha = 0;
				fadeEffectBrigth.blendMode = BlendMode.ADD;
				fadeEffectBrigth.touchable = false;
				//belowMenuContainers.addChild(fadeEffectBrigth);
			}
			else if (_gameState as GameTitle){
				inputWatcher = new InputWatcher();
				
				cutscene = new Cutscene();
				aboveMenuContainers.addChild(cutscene);
				
				titleMenu = new TitleMenu();
				titleMenu.update();
				menusContainers.addChild(titleMenu);
				
				GameEngine.instance.state.globalEffects.backgroundBlurFilter;
			}
		}
		
		/**  Update function */
		public function update():void {
			if (cutscene)
				cutscene.update();

			if(helpUI)
				helpUI.skin = _gameState.uiSkin;

			if(inputWatcher)
				inputWatcher.update();
				
			if (_gameState as LevelManager){
				if(!holdMenus){
					if(!_gameState.mainPlayer.dead && gameMenu && gameMenu.visible && !cutscene.onScreen)
						gameMenu.update();	
					
					if(newRewardUI.enabled){
						newRewardUI.update();
						newRewardUI.skin = _gameState.uiSkin;
					}
					if (hud && !gameMenu.visible && !pauseMenu.visible)
						hud.update();
					
					if (hud2 && !gameMenu.visible && !pauseMenu.visible)
						hud2.update();
					
					if (!_gameState.mainPlayer.dead && pauseMenu && pauseMenu.visible && !cutscene.onScreen)
						pauseMenu.update();	
						
					if (optionsMenu && optionsMenu.visible && !cutscene.onScreen)
						optionsMenu.update();
						
					if (!_gameState.mainPlayer.dead && exitMenu && exitMenu.visible && !cutscene.onScreen)
						exitMenu.update();
						
					if (!_gameState.mainPlayer.dead && overrideMenu && overrideMenu.visible && !cutscene.onScreen)
						overrideMenu.update();	
					
					if(!_gameState.mainPlayer.dead && !cutscene.onScreen){
						if ((inputWatcher.justDid(InputActionsNames.INTERFACE_PAUSE)) && pauseMenu && _gameState.isReady){	
							if (!pauseMenu.visible && !gameMenu.visible && !newRewardUI.enabled){
								pauseMenu.show(_gameState.uiSkin);
							}
						}
						
						if ((inputWatcher.justDid(InputActionsNames.INTERFACE_MENU_INFO)) && gameMenu && _gameState.isReady && !cutscene.onScreen){	
							if (!gameMenu.visible && !pauseMenu.visible && !newRewardUI.enabled)	{
								gameMenu.show(_gameState.uiSkin);
							}
						}
					}
					
					if (gameMap && gameMap.visible){
						gameMap.update();
					}
				}
				
				if (storyUI){
					storyUI.update();
				}
			}
			else if (_gameState as GameTitle){
				if(!holdMenus && !cutscene.onScreen){
					if (titleMenu)
						titleMenu.update();
					if (optionsMenu && optionsMenu.visible)
						optionsMenu.update();
					if (exitMenu && exitMenu.visible)
						exitMenu.update();
					if (overrideMenu && overrideMenu.visible)
						overrideMenu.update();
				}
			}
		}
		
		public var onFadeInComplete:Signal = new Signal(); 
		public var onFadeOutComplete:Signal = new Signal(); 
		public var isFading:Boolean;
		
		/* fades game in and out */
		public function fade(fadeIntime:Number = 0.5, stayTime:Number = 2, fadeOutTime:Number = 1, inCallback:Function = null, outCallback:Function = null):void{
			if(inCallback)
				onFadeInComplete.addOnce(inCallback);
			if(outCallback)
				onFadeOutComplete.addOnce(outCallback);
			
			fadeIn(fadeIntime);
			
			TweenMax.delayedCall(fadeIntime + stayTime, fadeOut, [fadeOutTime]);
		}
		
		/**Fades games in them waits level to be ready (loads all assets) to fade out */
		public function fadeOutByLevelManager(fadeOutTime:Number = 1,outCallback:Function = null):void{
			if(outCallback)
				onFadeOutComplete.addOnce(outCallback);
			
			if(!GameEngine.instance.state.isReady)
				GameEngine.instance.state.onReady.addOnce(fadeOutOnLevelReady);
			else
				TweenMax.delayedCall(0.5, fadeOut, [fadeOutTime]);
		}
		
		/* called when level is ready and game is on black screen */
		private function fadeOutOnLevelReady(state:GameState):void{
			fadeOut();
		}
		
		/*Fade in black screen */
		public function fadeIn(fadeIntime:Number = 0.5, inCallback:Function = null):void{
			if(inCallback)
				onFadeInComplete.addOnce(inCallback);
				
			isFading = true;	
			
			addfadeEffectBrigth(true);
			
			TweenMax.to(fadeEffectBrigth, fadeIntime, {alpha:1, onComplete:onFadeInComplete.dispatch});
			TweenMax.to(this, fadeIntime, {isFading:false});
		}
		
		/*Fade out black screen */
		public function fadeOut(fadeOutTime:Number = 1, outCallback:Function = null):void{
			if(outCallback)
				onFadeOutComplete.addOnce(outCallback);
				
			isFading = true;	
			
			TweenMax.to(fadeEffectBrigth, fadeOutTime, {alpha:0, onComplete:onFadeOutComplete.dispatch});
			TweenMax.delayedCall(fadeOutTime, removefadeEffectBrigth);
			TweenMax.to(this, fadeOutTime, {isFading:false});
		}
		
		private function addfadeEffectBrigth(add:Boolean):void{
			aboveMenuContainers.addChild(fadeEffectBrigth);
		}
		private function removefadeEffectBrigth():void{
			if (isFading)
				return;
				
			fadeEffectBrigth.alpha = 0;
			aboveMenuContainers.removeChild(fadeEffectBrigth);
		}
		
		override public function dispose():void {
			super.dispose();

			if(_gameState.mainPlayer){
				_gameState.mainPlayer.inventory.onObjectAdded.remove(showNewReward);
				_gameState.mainPlayer.inventory.onSingleNatureAdded.remove(showNewReward);
			}
			newRewardUI.dispose();
			_gameState = null;
			instance = null;
			inputWatcher = null;
		}
	}
}