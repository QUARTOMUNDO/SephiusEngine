package SephiusEngine.userInterfaces.menus {
	import SephiusEngine.GameVersion;
	import SephiusEngine.Languages.LanguageManager;
	import SephiusEngine.core.GameData;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.input.InputActionsNames;
	import SephiusEngine.sounds.system.components.global.GlobalSoundComponent;
	import SephiusEngine.userInterfaces.Cutscene;
	import SephiusEngine.userInterfaces.ScreenSkinsNames;
	import SephiusEngine.userInterfaces.UserInterfaces;
	import SephiusEngine.userInterfaces.components.menus.TitleMenuComponent;
	import SephiusEngine.userInterfaces.components.menus.menuItens.MenuItem;
	import SephiusEngine.utils.AppInfo;

	import com.greensock.TweenMax;

	import flash.system.Capabilities;

	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.extensions.brinkbit.fullscreenscreenextension.FullScreenExtension;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	import tLotDClassic.GameData.Properties.CutsceneProperties;
	import SephiusEngine.displayObjects.AnimationPack;
	import flash.display.BlendMode;

	/**
	 * Menu player see when game is paused
	 * @author Fernando Rabello and Nilo Paiva
	 */
	
	public class TitleMenu extends Sprite {
		private var _main:GameEngine;
		private var _skin:String = "Light";
		
		public var soundComponent:GlobalSoundComponent;
		
		public var rootMenu:TitleMenuComponent = new TitleMenuComponent(Vector.<String>(["EXIT", "OPTIONS", "CONTINUE", "NEW GAME", "SHOWCASE", "CREDITS"]), this,  "GameTitle");
		
		private var	menuHighLight:Image = new Image(GameEngine.assets.getTexture("GameTitle_HighLightLight")); 
		
		private var logo:Image = new Image(GameEngine.assets.getTexture("GameTitle_Logo"));
		private var gameTite_FrameBG:Image = new Image(GameEngine.assets.getTexture("GameTitle_FrameBG"));
		private var gameTite_frame:Image = new Image(GameEngine.assets.getTexture("GameTitle_Frame"));
		private var gameTite_externalLight2:Image = new Image(GameEngine.assets.getTexture("GameTitle_ExternalLight2"));
		private var gameTite_externalLight1:Image = new Image(GameEngine.assets.getTexture("GameTitle_ExternalLight1")); 
		private var gameTite_externalDark1:Image = new Image(GameEngine.assets.getTexture("GameTitle_ExternalDark1"));
		private var gameTite_externalDark2:Image = new Image(GameEngine.assets.getTexture("GameTitle_ExternalDark2"));
		
		private var gameTite_MiddleDark:Image = new Image(GameEngine.assets.getTexture("GameTitle_ExternalDark2"));
		private var gameTite_MiddleLight:Image = new Image(GameEngine.assets.getTexture("GameTitle_ExternalLight1")); 
		
		private var gameTitle_BG:Image = new Image(GameEngine.assets.getTexture("GameTitle_BG")); 
		private var GameTitle_ShadowSmoothButom:Image = new Image(GameEngine.assets.getTexture("GameTitle_ShadowSmoothButom")); 
		
		private var gameTitle_QUARTOMUNDOLogo:Image = new Image(GameEngine.assets.getTexture("GameTitle_QUARTOMUNDOLogo")); 
		private var gameTitle_EpiphanicaLogo:Image = new Image(GameEngine.assets.getTexture("GameTitle_EpifanicaLogo")); 
		private var gameTitle_EpiphanicaLogoLBright:Image = new Image(GameEngine.assets.getTexture("GameTitle_EpifanicaLogoLBright")); 
		
		private var epiphanicaLogoBrightAnimated:AnimationPack;
		private var essenceBG:AnimationPack;

		private var gameTite_externalLight2_bottom:Image = new Image(GameEngine.assets.getTexture("GameTitle_ExternalLight2"));
		private var gameTite_externalLight1_bottom:Image = new Image(GameEngine.assets.getTexture("GameTitle_ExternalLight1")); 
		
		private var gameTite_externalDark1_bottom:Image = new Image(GameEngine.assets.getTexture("GameTitle_ExternalDark1"));
		private var gameTite_externalDark2_bottom:Image = new Image(GameEngine.assets.getTexture("GameTitle_ExternalDark2"));
		
		private var gameTitle_ShadowSmoothButom:Image = new Image(GameEngine.assets.getTexture("GameTitle_ShadowSmoothButom"));
		
		private var gameTitle_version:TextField = new TextField(1000, 100, "E", "ChristianaWhite", 13, 0xffffff, true);
		
		private var externalTopRight:Sprite = new Sprite();
		private var externalTopLeft:Sprite = new Sprite();
		private var externalBottomRight:Sprite = new Sprite();
		private var externalBottomLeft:Sprite = new Sprite();
		
		private var epiphanicaLogo:Sprite = new Sprite();
		
		public var holdTitle:Boolean;
		
		private var blackScreen:Quad = new Quad(10, 10, 0x000000);
		
		public function updateLang(langID:String=""):void{
			var airVersion:String =  AppInfo.runtimeVersion;
			//var DefinitionNames:Vector.<String> = ApplicationDomain.currentDomain.getQualifiedDefinitionNames();
			var bits:String = Capabilities.supports64BitProcesses ? "64Bit" : "32Bit";
			var debbuger:String = AppInfo.isDebugBuild ? "Debug" : "Release";

			var swfVersion:uint = GameEngine.instance.loaderInfo.swfVersion;
			var driverInfo:String = Starling.current.context.driverInfo;

			gameTitle_version.text = "| SEPHIUS ENGINE |" + "\n ";
			gameTitle_version.text += GameVersion.versionType + " Build: " + GameVersion.versionName + "_" + GameVersion.Major + "." + GameVersion.Minor  + "." + GameVersion.Patch + "_" + GameVersion.Timestamp.split(" ")[0].split("/")[2] + " / SWF: " + swfVersion + " / Profile: " + driverInfo + " / Runtime:" + airVersion + "-" + bits + "-" + debbuger;
			gameTitle_version.text += "\n " + LanguageManager.getSimpleLang("TitleMenuElements", "Copyright").name;
			
			gameTitle_version.alignPivot();
			gameTitle_version.touchable = false;
		}

		public function TitleMenu(){
			super();
			_main = GameEngine.instance;
						
			rootMenu.menuItens[2].enabled = GameData.getInstance().saveDataExist();
			rootMenu.menuItens[5].enabled = false;

			soundComponent = _main.soundComponent;
			
			createTitleMenu();
			
			LanguageManager.ON_LANG_CHANGED.add(updateLang);
			
			this.addEventListener(TouchEvent.TOUCH, onTouch);
			Starling.current.stage.addEventListener(Event.RESIZE, resizeMenu);
			
			rootMenu.index = GameData.getInstance().saveDataExist() ? 2 : 3;
		}
		
		
		private var logosX:Number = 220;
		private var logosY:Number = 65;
		private var logoScale:Number = 0.8;
		public var cutscene:Cutscene;
		
		private var mainLogosX:Number = 30;
		private var mainLogosY:Number = 30;
		
		private var ShadowSmoothButomY:Number = 1.2;
		private var shadowSmoothButomHeight:Number = .7;
		
		private function resizeMenu():void{
			var menuYOffset:Number = FullScreenExtension.screenBottom * 0.25;
			var footYPos:Number = (FullScreenExtension.screenBottom * 0.5) -50;
			var screenWidth:Number = (FullScreenExtension.screenRight - FullScreenExtension.screenLeft) * 0.5;
			var screenHeight:Number = (FullScreenExtension.screenBottom -  FullScreenExtension.screenTop) * 0.5;
			
			gameTitle_BG.width = screenWidth * 2;
			gameTitle_BG.height = screenHeight * 2;
			
			blackScreen.width = screenWidth * 2;
			blackScreen.height = screenHeight * 2;
			
			gameTitle_QUARTOMUNDOLogo.x = logosX;
			gameTitle_QUARTOMUNDOLogo.y = footYPos - logosY;

			gameTitle_EpiphanicaLogo.x = -logosX;
			gameTitle_EpiphanicaLogo.y = footYPos - logosY;

			epiphanicaLogoBrightAnimated.x = gameTitle_EpiphanicaLogo.x + 0;
			epiphanicaLogoBrightAnimated.y = gameTitle_EpiphanicaLogo.y - 20;

			gameTitle_ShadowSmoothButom.width = screenWidth * 2.5;
			gameTitle_ShadowSmoothButom.height = screenHeight * shadowSmoothButomHeight;
			gameTitle_ShadowSmoothButom.y = footYPos - 70;

			//bottom left dark
			gameTitle_version.x = 0;
			gameTitle_version.y = footYPos;

			rootMenu.y = menuYOffset; //menuYOffset is correct
			
			gameTite_FrameBG.x = 0;
			gameTite_FrameBG.y = menuYOffset; //menuYOffset is correct
			
			gameTite_frame.x = 0;
			gameTite_frame.y = menuYOffset; //menuYOffset is correct
			
			logo.x = -mainLogosX;
			logo.y = -menuYOffset + mainLogosY; //gameTite_frame.y - 800; //500 is correct
			logo.scaleX = logo.scaleY = 1;

			essenceBG.y = -200;
			essenceBG.scaleX = -7;
			essenceBG.scaleY = 7;

			//top right light
			externalTopRight.x = screenWidth;
			externalTopRight.y = -screenHeight;
			
			//bottom right light
			externalBottomRight.x = screenWidth;
			externalBottomRight.y = screenHeight;
			
			//top left dark
			externalTopLeft.x = -screenWidth;
			externalTopLeft.y = -screenHeight;
			
			//bottom left dark
			externalBottomLeft.x = -screenWidth;
			externalBottomLeft.y = screenHeight;
		}
		
		public function update():void {				
			if (holdTitle || UserInterfaces.instance.holdMenus && UserInterfaces.instance.cutscene.onScreen)
				return;
			
			if(UserInterfaces.instance.optionsMenu || UserInterfaces.instance.exitMenu || UserInterfaces.instance.overrideMenu){
				if (UserInterfaces.instance.optionsMenu.visible || UserInterfaces.instance.exitMenu.visible || UserInterfaces.instance.overrideMenu.visible)
					return;
			}
			if (UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_LEFT)) {
				if(rootMenu.index >= 0)
					rootMenu.index--;
				else 
					rootMenu.index = 0;
			}
				
			if (UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_RIGHT)) {
				if(rootMenu.index >= 0)
					rootMenu.index++;
				else
					rootMenu.index = 0;
			}
			
			if (UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_CONFIRM)) {
				
				if(rootMenu.index != -1)
					soundComponent.play("UI_interface_enterAccept", "UI");
				
				switch (rootMenu.selectecItemID){
					case "EXIT":
						UserInterfaces.instance.exitMenu.show(ScreenSkinsNames.DARK);
						GameEngine.instance.state.globalEffects.animateUIBlurIn();
						holdTitle = true;
						break;
					case "OPTIONS":
						UserInterfaces.instance.optionsMenu.show(ScreenSkinsNames.DARK);
						GameEngine.instance.state.globalEffects.animateUIBlurIn();
						holdTitle = true;
						break						
					case "CONTINUE":
						TweenMax.delayedCall(1, GameData.getInstance().continueGame);
						this.hide();
						holdTitle = true;
						break
					case "NEW GAME":
						UserInterfaces.instance.cutscene.callback = GameData.getInstance().newGame;
						if(GameData.getInstance().saveDataExist()){
							UserInterfaces.instance.overrideMenu.show(ScreenSkinsNames.DARK);
							GameEngine.instance.state.globalEffects.animateUIBlurIn();
							holdTitle = true;
						}
						else {
							hide();
							holdTitle = true;
							UserInterfaces.instance.cutscene.show(CutsceneProperties.PROLOGUE.varName);
							soundComponent.fadeOutAll(2);
						}
						break
					case "SHOWCASE":
						UserInterfaces.instance.cutscene.callback = GameData.getInstance().showcaseGame;
						if(GameData.getInstance().saveDataExist()){
							UserInterfaces.instance.overrideMenu.show(ScreenSkinsNames.DARK);
							GameEngine.instance.state.globalEffects.animateUIBlurIn();
							holdTitle = true;
						}
						else {
							hide();
							holdTitle = true;
							UserInterfaces.instance.cutscene.callback = GameData.getInstance().showcaseGame;
							UserInterfaces.instance.cutscene.show(CutsceneProperties.PROLOGUE.varName);
							soundComponent.fadeOutAll(2);
						}
						break
					case "CREDITS":
						trace("CREDITS");
						UserInterfaces.instance.cutscene.show(CutsceneProperties.CREDITS.varName);
						//holdTitle = true;
						break
				}
			}
		}
		
		/**
		 * 
		 * @param	event the event related with current touch 
		 */
		private function onTouch(event:TouchEvent):void {
			if (holdTitle && UserInterfaces.instance.holdMenus)
				return;
			
			var touch:Touch = event.getTouch((event.target as DisplayObject));
			var menuIndex:int;
			
			if (touch) {
				menuIndex = rootMenu.menuItens.indexOf((event.target as DisplayObject).parent as MenuItem);
				if (rootMenu.menuItens[menuIndex].enabled) {
					if (touch.phase == TouchPhase.HOVER) {
						rootMenu.index = menuIndex;
					}
					else if(touch.phase == TouchPhase.BEGAN){
						if(rootMenu.index != -1)
							soundComponent.play("UI_interface_enterAccept", "UI");
						
						switch (rootMenu.menuItens[menuIndex].itemID) {
							case "EXIT":
								UserInterfaces.instance.exitMenu.show(ScreenSkinsNames.DARK);
								GameEngine.instance.state.globalEffects.animateUIBlurIn();
								trace("Exit");
								holdTitle = true;
								break						
							case "OPTIONS":
								UserInterfaces.instance.optionsMenu.show(ScreenSkinsNames.DARK);
								GameEngine.instance.state.globalEffects.animateUIBlurIn();
								trace("Options!");
								holdTitle = true;
								break						
							case "CONTINUE":
								trace("CONTINUE");
								TweenMax.delayedCall(1, GameData.getInstance().continueGame);
								this.hide();
								holdTitle = true;
								soundComponent.fadeOutAll(2);
								break
							case "SHOWCASE":
								UserInterfaces.instance.cutscene.callback = GameData.getInstance().showcaseGame;
								if(GameData.getInstance().saveDataExist()){
									UserInterfaces.instance.overrideMenu.show(ScreenSkinsNames.DARK);
									GameEngine.instance.state.globalEffects.animateUIBlurIn();
									holdTitle = true;
								}
								else{
									//TweenMax.delayedCall(1, GameData.getInstance().newGame);
									//this.hide();
									holdTitle = true;
									soundComponent.fadeOutAll(2);
									UserInterfaces.instance.cutscene.callback = GameData.getInstance().showcaseGame;
									UserInterfaces.instance.cutscene.show(CutsceneProperties.PROLOGUE.varName);
								}
								break
							case "NEW GAME":
								UserInterfaces.instance.cutscene.callback = GameData.getInstance().newGame;
								if(GameData.getInstance().saveDataExist()){
									UserInterfaces.instance.overrideMenu.show(ScreenSkinsNames.DARK);
									GameEngine.instance.state.globalEffects.animateUIBlurIn();
									holdTitle = true;
								}
								else{
									//TweenMax.delayedCall(1, GameData.getInstance().newGame);
									//this.hide();
									holdTitle = true;
									soundComponent.fadeOutAll(2);
									UserInterfaces.instance.cutscene.callback = GameData.getInstance().newGame;
									UserInterfaces.instance.cutscene.show(CutsceneProperties.PROLOGUE.varName);
								}
								break
							case "CREDITS":
								UserInterfaces.instance.cutscene.show(CutsceneProperties.CREDITS.varName);
								trace("CREDITS");
								//holdTitle = true;
								break
								
						}
					}
				}
			}
			else {
				rootMenu.index = -3;
			}
		}		
		
		public function show():void {
			soundComponent.play("UI_interface_start", "UI");
			
			blackScreen.alpha = 1;
			TweenMax.to(blackScreen, 1.5, { alpha:0 } );
			TweenMax.to(blackScreen, 1, { delay:.3, visible:false } );
			
			rootMenu.index = -3;
		}
		
		public function hide():void {
			TweenMax.to(blackScreen, 1.5, { alpha:1 } );
			TweenMax.to(blackScreen, 1.5, { delay:.3, visible:false } );
			TweenMax.to(this, 1.5, { delay:.3, visible:false } );
			
			//rootMenu.index = -2;
			rootMenu.selectecItemID = "";
		}
		
		/**
		 * Configure menu items and aligh all pivots
		 */
		public function createTitleMenu():void {
			this.alpha = 0.999;
			
			logo.alignPivot(HAlign.CENTER, VAlign.CENTER);
			logo.touchable = false;
			
			gameTite_FrameBG.alignPivot(HAlign.CENTER, VAlign.CENTER);
			gameTite_FrameBG.touchable = false;
			
			gameTite_frame.alignPivot(HAlign.CENTER, VAlign.CENTER);
			gameTite_frame.touchable = false;
			
			//Canto superior light
			gameTite_externalLight2.alignPivot(HAlign.RIGHT, VAlign.TOP);
			gameTite_externalLight2.touchable = false;
			
			gameTite_externalLight1.alignPivot(HAlign.RIGHT, VAlign.TOP);
			gameTite_externalLight1.touchable = false;
			
			externalTopRight.touchable = false;
			
			//Canto inferior light
			gameTite_externalLight2_bottom.alignPivot(HAlign.RIGHT, VAlign.TOP);
			gameTite_externalLight2_bottom.touchable = false;
			
			gameTite_externalLight1_bottom.alignPivot(HAlign.RIGHT, VAlign.TOP);
			gameTite_externalLight1_bottom.touchable = false;	
			
			externalBottomLeft.touchable = false;
			externalBottomRight.touchable = false;
			
			//Canto superior dark
			gameTite_externalDark1.alignPivot(HAlign.LEFT, VAlign.TOP);
			gameTite_externalDark1.touchable = false;		
			
			gameTite_externalDark2.alignPivot(HAlign.LEFT, VAlign.TOP);
			gameTite_externalDark2.touchable = false;
			
			externalTopLeft.touchable = false;
			
			//canto inferior direito
			gameTite_externalDark1_bottom.alignPivot(HAlign.LEFT, VAlign.TOP);
			gameTite_externalDark1_bottom.touchable = false;		
			
			gameTite_externalDark2_bottom.alignPivot(HAlign.LEFT, VAlign.TOP);
			gameTite_externalDark2_bottom.touchable = false;
			
			//criando sym
			externalTopRight.addChild(gameTite_externalLight2);
			externalTopRight.addChild(gameTite_externalLight1);
			
			externalTopLeft.addChild(gameTite_externalDark2);
			externalTopLeft.addChild(gameTite_externalDark1);
			
			externalBottomRight.addChild(gameTite_externalLight2_bottom);
			externalBottomRight.addChild(gameTite_externalLight1_bottom);
			externalBottomRight.scaleY = -1;
			
			externalBottomLeft.addChild(gameTite_externalDark2_bottom);
			externalBottomLeft.addChild(gameTite_externalDark1_bottom);
			externalBottomLeft.scaleY = -1;
			
			gameTitle_BG.alignPivot();
			gameTitle_BG.touchable = false;
			blackScreen.alpha = 0;
			
			blackScreen.alignPivot(HAlign.CENTER, VAlign.CENTER);
			blackScreen.touchable = false;
			
			gameTitle_ShadowSmoothButom.alignPivot();
			gameTitle_ShadowSmoothButom.touchable = false;

			gameTitle_QUARTOMUNDOLogo.alignPivot();
			gameTitle_QUARTOMUNDOLogo.touchable = false;
			
			gameTitle_EpiphanicaLogo.alignPivot();
			gameTitle_EpiphanicaLogo.touchable = false;

			gameTitle_EpiphanicaLogoLBright.alignPivot();
			gameTitle_EpiphanicaLogoLBright.touchable = false;
			
			updateLang("");
			
			addChild(gameTitle_BG);

			essenceBG  = new AnimationPack("EssenceBG", [], 60, "bilinear", true, "all");
			essenceBG.touchable = false;
			essenceBG.activate();
			essenceBG.blendMode = BlendMode.SCREEN;
			
			addChild(essenceBG);

			addChild(logo);
			addChild(gameTite_FrameBG);	
			addChild(gameTite_frame);
			addChild(externalTopRight);
			addChild(externalTopLeft);   
			addChild(externalBottomRight);
			addChild(externalBottomLeft);
			addChild(rootMenu);
			
			addChild(gameTitle_ShadowSmoothButom);

			addChild(gameTitle_EpiphanicaLogo);
			addChild(gameTitle_QUARTOMUNDOLogo);

			epiphanicaLogoBrightAnimated = new AnimationPack("EpifânicaLogo", [], 30, "bilinear", true, "all");
			epiphanicaLogoBrightAnimated.touchable = false;
			epiphanicaLogoBrightAnimated.activate();
			//epiphanicaLogoBrightAnimated.blendMode = BlendMode.SCREEN;
			addChild(epiphanicaLogoBrightAnimated);

			addChild(gameTitle_version);
			
			addChild(blackScreen);

			resizeMenu();

			x = FullScreenExtension.stageWidth * .5;
			y = FullScreenExtension.stageHeight * .5;
			
			//gameTitle_BG.filter = new BlurFilter(20, 20);
			rootMenu.index = -3;
		}
		
		override public function dispose():void {
			super.dispose();
			/*
			while (numChildren > 0){
				if (getChildAt(0) as Sprite){
					while ((getChildAt(0) as Sprite).numChildren > 0){
						(getChildAt(0) as Sprite).getChildAt(0).removeFromParent(true);
					}
				}
				getChildAt(0).removeFromParent(true);
			}
			
			//_main.sound.soundSystem.unregisterComponent(soundComponent);*/
			soundComponent = null;

			LanguageManager.ON_LANG_CHANGED.remove(updateLang);
			//TODO dispose all resources!!
		}
	}
}