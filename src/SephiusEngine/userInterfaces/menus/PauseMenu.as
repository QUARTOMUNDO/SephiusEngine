package SephiusEngine.userInterfaces.menus {
	import SephiusEngine.sounds.system.components.global.GlobalSoundComponent;
	import com.greensock.TweenMax;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.gameStates.LevelManager;
	import SephiusEngine.input.InputActionsNames;
	import SephiusEngine.userInterfaces.components.menus.menuItens.BarMenuItem;
	import SephiusEngine.userInterfaces.components.menus.TopMenuComponent;
	import SephiusEngine.userInterfaces.UserInterfaces;
	import SephiusEngine.core.levelManager.GameOptions;
	import flash.system.System;
	import starling.display.BlendMode;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.extensions.brinkbit.fullscreenscreenextension.FullScreenExtension;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * Menu player see when game is paused
	 * @author Fernando Rabello
	 */
	
	public class PauseMenu extends Sprite {
		private var _main:GameEngine;
		private var _skin:String = "Light";
		
		public var soundComponent:GlobalSoundComponent;
		
		public var rootMenu:TopMenuComponent = new TopMenuComponent(Vector.<String>(["RESUME", "MENU", "OPTIONS", "QUIT"]), this, "Menu", "PauseMenuElements");
		
		private var menuBackgroundLeft:Image = new Image(GameEngine.assets.getTexture("Menu_LightBackgroundLeft"));
		private var	menuBackgroundRight:Image = new Image(GameEngine.assets.getTexture("Menu_LightBackgroundRight"));
		private var	menuDivisor:Image = new Image(GameEngine.assets.getTexture("Menu_LightDivisor"));
		private var	menuExternoLeft:Image = new Image(GameEngine.assets.getTexture("Menu_LightExternoLeft"));
		private var	menuExternoRight:Image = new Image(GameEngine.assets.getTexture("Menu_LightExternoRight"));
		private var	menuFrameLeft:Image = new Image(GameEngine.assets.getTexture("Menu_LightFrameLeft"));
		private var	menuFrameMiddle:Image = new Image(GameEngine.assets.getTexture("Menu_LightFrameMiddle"));
		private var	menuFrameRight:Image = new Image(GameEngine.assets.getTexture("Menu_LightFrameRight"));
		private var	menuHighLight:Image = new Image(GameEngine.assets.getTexture("Menu_LightHighLight")); 
		private var	menuOrnamentButtom:Image = new Image(GameEngine.assets.getTexture("Menu_LightOrnamentButtom"));
		private var	menuOrnamentTop:Image = new Image(GameEngine.assets.getTexture("Menu_LightOrnamentTop"));
		private var	menuSrtipsButtomLeft:Image = new Image(GameEngine.assets.getTexture("Menu_LightSrtipsButtomLeft"));
		private var	menuSrtipsButtomRight:Image = new Image(GameEngine.assets.getTexture("Menu_LightSrtipsButtomRight"));
		private var	menuStripsOrnamentTop:Image = new Image(GameEngine.assets.getTexture("Menu_LightStripsOrnamentTop")); 
		private var	menuStripsTopLeft:Image = new Image(GameEngine.assets.getTexture("Menu_LightStripsTopLeft"));
		private var	menuStripsTopRight:Image = new Image(GameEngine.assets.getTexture("Menu_LightStripsTopRight"));
		private var backgroundColor:Image = new Image(GameEngine.assets.getTexture("Menu_DecalDouble"));
		
		public function PauseMenu(){
			super();
			_main = GameEngine.instance;
			
			//soundComponent = new GlobalSoundComponent("PauseMenu");
			//_main.sound.soundSystem.registerComponent(soundComponent);
			
			soundComponent = _main.soundComponent;
			
			createPauseMenu();
			
			this.addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		public function update():void {
			if (UserInterfaces.instance.optionsMenu.visible || UserInterfaces.instance.exitMenu.visible)
				return;
				
			if (_main.state.mainPlayer.inputWatcher.justDid(InputActionsNames.INTERFACE_LEFT))
				rootMenu.index--
			if (_main.state.mainPlayer.inputWatcher.justDid(InputActionsNames.INTERFACE_RIGHT))
				rootMenu.index++
				
			if (_main.state.mainPlayer.inputWatcher.justDid(InputActionsNames.INTERFACE_CANCEL) || _main.state.mainPlayer.inputWatcher.justDid(InputActionsNames.INTERFACE_PAUSE)){
				hide();
				soundComponent.play("UI_interface_backCancel", "UI");
			}
			
			if (_main.state.mainPlayer.inputWatcher.justDid(InputActionsNames.INTERFACE_CONFIRM)) {
				
				if(rootMenu.index != -1)
					soundComponent.play("UI_interface_enterAccept", "UI");
					
				switch (rootMenu.indexID){
					case "RESUME":
						hide();
						break
					case "OPTIONS":
						UserInterfaces.instance.optionsMenu.show(_main.state.uiSkin);
						break
					case "QUIT":
						UserInterfaces.instance.exitMenu.show(_main.state.uiSkin);
						break
					case "MENU":
						UserInterfaces.instance.gameMenu.show(_main.state.uiSkin);
						hide();
						break
				}
			}
		}
		
		public function show(skin:String):void {
			this.skin = skin;
			
			soundComponent.play("UI_interface_start", "UI");
			setGamePlaying(false);
			
			UserInterfaces.instance.hud.visible = false;
			UserInterfaces.instance.belowMenuContainers.visible = false;
			UserInterfaces.instance.storyUI.visible = false;

			visible = false;
			if (!GameOptions.DISABLE_BLUR_EFFECTS) {
				addChildAt(GameEngine.instance.state.globalEffects.uiBackgroundBlur, 0);
				GameEngine.instance.state.globalEffects.renderBackgroundBlur();
				GameEngine.instance.state.globalEffects.animateBackgroundBlurIn();
				GameEngine.instance.state.globalEffects.uiBackgroundBlur.removeUIFilter2();
			}
			visible = true;
			
			alpha = 0;
			TweenMax.to(this, 0.5, { startAt: { alpha:0}, alpha:1} );
			
			System.gc();
			System.pauseForGCIfCollectionImminent();
			
			rootMenu.index = 1;
		}
		
		public function hide():void {
			TweenMax.to(this, .3, { alpha:0 } );
			TweenMax.to(this, 0, { delay:.3, visible:false } );
			
			if (!UserInterfaces.instance.gameMenu.visible) {
				if (!GameOptions.DISABLE_BLUR_EFFECTS)
					GameEngine.instance.state.globalEffects.uiBackgroundBlur.animateBackgroundBlurOut();

				UserInterfaces.instance.hud.visible = true;
				UserInterfaces.instance.belowMenuContainers.visible = true;
				UserInterfaces.instance.storyUI.visible = true;

				TweenMax.delayedCall(.3, setGamePlaying, [true]);
				System.gc();
				System.pauseForGCIfCollectionImminent();
			}
			
			//rootMenu.index = -2;
			rootMenu.selectedItemID = "";
		}
		
		private function onTouch(event:TouchEvent):void {
			if (UserInterfaces.instance.holdMenus)
				return;
			
			var touch:Touch = event.getTouch((event.target as DisplayObject).parent.parent);
			if (touch) {
				if(touch.phase == TouchPhase.HOVER){
					rootMenu.index = rootMenu.menuItens.indexOf((event.target as DisplayObject).parent as BarMenuItem);
				}
				else if(touch.phase == TouchPhase.BEGAN){
					if(rootMenu.index != -1)
						soundComponent.play("UI_interface_enterAccept", "UI");
					switch (((event.target as DisplayObject).parent as BarMenuItem).itemID){
						case "RESUME":
							hide();
							break
						case "OPTIONS":
							UserInterfaces.instance.optionsMenu.show(_main.state.uiSkin);
							break
						case "QUIT":
							UserInterfaces.instance.exitMenu.show(_main.state.uiSkin);
							break
						case "MENU":
							UserInterfaces.instance.gameMenu.show(_main.state.uiSkin);
							hide();
							break
					}
				}
			}
		}
		
		public function setGamePlaying(play:Boolean):void {
			_main.state.paused = !play;
			_main.stage.focus = _main.stage;
		}
		
		public function get skin():String {return _skin;}
		public function set skin(value:String):void {
			_skin = value;
			
			menuBackgroundLeft.texture = GameEngine.assets.getTexture("Menu_" + _skin + "BackgroundLeft");
			menuBackgroundRight.texture = GameEngine.assets.getTexture("Menu_" + _skin + "BackgroundRight");
			menuDivisor.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "Divisor");
			menuExternoLeft.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "ExternoLeft");
			menuExternoRight.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "ExternoRight");
			menuFrameLeft.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "FrameLeft");
			menuFrameRight.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "FrameRight");
			menuHighLight.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "HighLight"); 
			menuOrnamentButtom.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "OrnamentButtom");
			menuOrnamentTop.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "OrnamentTop");
			menuSrtipsButtomLeft.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "SrtipsButtomLeft");
			menuSrtipsButtomRight.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "SrtipsButtomRight");
			menuStripsOrnamentTop.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "StripsOrnamentTop"); 
			menuStripsTopLeft.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "StripsTopLeft");
			menuStripsTopRight.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "StripsTopRight");
			
			backgroundColor.texture  = GameEngine.assets.getTexture("Menu_" + (_skin == "Dark" ? "Shadow" : "Decal") + "Double");
			backgroundColor.blendMode = (_skin == "Dark" ? BlendMode.NORMAL : BlendMode.SCREEN);
			backgroundColor.alpha = (_skin == "Dark" ? .7 : .3);
			
			rootMenu.skin = _skin;
		}
		
		public function createPauseMenu():void {
			this.alpha = 0.999;
			menuBackgroundLeft.touchable = false;
			menuBackgroundRight.touchable = false;
			menuDivisor.touchable = false;
			menuExternoLeft.touchable = false;
			menuExternoRight.touchable = false;
			menuFrameLeft.touchable = false;
			menuFrameMiddle.touchable = false;
			menuFrameRight.touchable = false;
			menuHighLight.touchable = false;
			menuOrnamentButtom.touchable = false;
			menuOrnamentTop.touchable = false;
			menuSrtipsButtomLeft.touchable = false;
			menuSrtipsButtomRight.touchable = false;
			menuStripsOrnamentTop.touchable = false;
			menuStripsTopLeft.touchable = false;
			menuStripsTopRight.touchable = false;
			backgroundColor.touchable = false;
			
			menuBackgroundLeft.alignPivot(HAlign.RIGHT, VAlign.CENTER);
			menuBackgroundLeft.x = 0;
			menuBackgroundLeft.y = 0;
			
			menuBackgroundRight.alignPivot(HAlign.LEFT, VAlign.CENTER);
			menuBackgroundRight.x = 0;
			menuBackgroundRight.y = 0;
			
			menuFrameLeft.alignPivot(HAlign.RIGHT, VAlign.CENTER);
			menuFrameLeft.x = 0;
			menuFrameLeft.y = 0;
			
			menuFrameRight.alignPivot(HAlign.LEFT, VAlign.CENTER);
			menuFrameRight.x = 0;
			menuFrameRight.y = 0;
			
			menuSrtipsButtomLeft.alignPivot(HAlign.RIGHT, VAlign.TOP);
			menuSrtipsButtomLeft.x = 0;
			menuSrtipsButtomLeft.y = 68;
			
			menuSrtipsButtomRight.alignPivot(HAlign.LEFT, VAlign.TOP);
			menuSrtipsButtomRight.y = 68;
			
			menuStripsTopLeft.alignPivot(HAlign.RIGHT, VAlign.BOTTOM);
			menuStripsTopLeft.pivotY = menuStripsTopLeft.height;
			menuStripsTopLeft.x = 0;
			menuStripsTopLeft.y = -68;
			
			menuStripsTopRight.alignPivot(HAlign.LEFT, VAlign.BOTTOM);
			menuStripsTopRight.x = 0;
			menuStripsTopRight.y = -68;
			
			menuOrnamentButtom.alignPivot(HAlign.CENTER, VAlign.TOP);
			menuOrnamentButtom.x = 0;
			menuOrnamentButtom.y = 68;
			
			menuOrnamentTop.alignPivot();
			menuOrnamentTop.x = 0;
			menuOrnamentTop.y = -83;
			
			menuStripsOrnamentTop.alignPivot();
			menuStripsOrnamentTop.y = -147;
			
			menuExternoLeft.alignPivot();
			menuExternoRight.alignPivot();
			menuExternoLeft.x = -menuFrameLeft.width * .9;
			menuExternoRight.x = menuFrameRight.width * .9;
			
			backgroundColor.alignPivot();
			backgroundColor.width = FullScreenExtension.stageWidth;
			backgroundColor.height = FullScreenExtension.stageHeight;
			backgroundColor.alpha = .5;
			addChild(backgroundColor);
			addChild(menuStripsOrnamentTop);
			addChild(menuExternoLeft);
			addChild(menuExternoRight);
			addChild(menuBackgroundLeft);
			addChild(menuBackgroundRight);
			addChild(rootMenu);
			addChild(menuSrtipsButtomLeft);
			addChild(menuSrtipsButtomRight);
			addChild(menuStripsTopLeft);
			addChild(menuStripsTopRight);
			addChild(menuOrnamentButtom);
			addChild(menuFrameLeft);
			addChild(menuFrameRight);
			addChild(menuOrnamentTop);
			
			x = FullScreenExtension.stageWidth * .5;
			y = FullScreenExtension.stageHeight * .45;
			
			//scaleX = scaleY = GameEngine.screenRatio * .7 + 0.3;
			
			this.visible = false;
			UserInterfaces.instance.menusContainers.addChild(this);
		}
	}
}