package SephiusEngine.userInterfaces.menus {
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.levelManager.GameOptions;
	import SephiusEngine.input.InputActionsNames;
	import SephiusEngine.userInterfaces.UserInterfaces;
	import SephiusEngine.userInterfaces.components.contents.ContentComponent;
	import SephiusEngine.userInterfaces.components.contents.Contents.EquipableInfoContent;
	import SephiusEngine.userInterfaces.components.contents.Contents.StatusContentComponent;
	import SephiusEngine.userInterfaces.components.contents.subContents.HelpSubContentComponent;
	import SephiusEngine.userInterfaces.components.contents.subContents.ItemSubContentComponent;
	import SephiusEngine.userInterfaces.components.contents.subContents.MemoSubContentComponent;
	import SephiusEngine.userInterfaces.components.contents.subContents.SpellSubContentComponent;
	import SephiusEngine.userInterfaces.components.contents.subContents.WeaponSubContentComponent;
	import SephiusEngine.userInterfaces.components.menus.TopMenuComponent;
	import SephiusEngine.userInterfaces.components.menus.menuItens.BarMenuItem;

	import com.greensock.TweenMax;

	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.extensions.brinkbit.fullscreenscreenextension.FullScreenExtension;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	import tLotDClassic.GameData.Properties.HelpProperties;
	import SephiusEngine.userInterfaces.components.HelpSprite;
	
	/**
	 * Menu with game informations (itens, spells, status, weapons, log etc)
	 * @author Fernando Rabello
	 */
	public class GameMenu extends Sprite {
		private var _main:GameEngine;
		private var _skin:String = "Light";
		
		public var infoMenuContainer:Sprite = new Sprite();
		
		public var rootMenu:TopMenuComponent = new TopMenuComponent(Vector.<String>(["STATUS", "ITEMS", "WEAPONS", "SPELLS", "MEMOS", "LOG", "HELP"]),this, "Menu", "GameMenuElements", 30);
		private var statusContent:StatusContentComponent;
		private var itemSubContent:EquipableInfoContent;
		private var spellSubContent:EquipableInfoContent;
		private var weaponSubContent:EquipableInfoContent;
		private var logSubContent:EquipableInfoContent;
		private var memoSubContent:EquipableInfoContent;
		private var helpSubContent:EquipableInfoContent;
		
		private var gameMenuHelp:HelpSprite;
		private var gameMenuBG:Quad = new Quad(10, 10, 0x000000);
		private var gameMenuBG2:Quad = new Quad(10, 10, 0x000000);
		
		private var _currentContent:ContentComponent; 
		
		private var menuBackgroundLeft:Image = new Image(GameEngine.assets.getTexture("Menu_LightBackgroundLeft"));
		private var	menuBackgroundMiddle:Image = new Image(GameEngine.assets.getTexture("Menu_LightBackgroundMiddle"));
		private var	menuBackgroundRight:Image = new Image(GameEngine.assets.getTexture("Menu_LightBackgroundRight"));
		private var	menuBigOrnamentDivisor:Image = new Image(GameEngine.assets.getTexture("Menu_LightBigOrnamentDivisor"));
		private var	menuBodyBackground:Image = new Image(GameEngine.assets.getTexture("Menu_LightBodyBackground"));
		private var	menuBodyFrameLeft:Image = new Image(GameEngine.assets.getTexture("Menu_LightBodyFrameLeft"));
		private var	menuBodyFrameRight:Image = new Image(GameEngine.assets.getTexture("Menu_LightBodyFrameRight"));
		private var	menuFrameOrnametTopLeft:Image = new Image(GameEngine.assets.getTexture("Menu_LightFrameOrnametTopLeft"));
		private var	menuFrameOrnametTopRight:Image = new Image(GameEngine.assets.getTexture("Menu_LightFrameOrnametTopRight"));
		private var	menuBodyTopOrnametRight:Image = new Image(GameEngine.assets.getTexture("Menu_LightBodyTopOrnametRight"));
		private var	menuBodyTopOrnametLeft:Image = new Image(GameEngine.assets.getTexture("Menu_LightBodyTopOrnametLeft"));
		private var	menuDivisor:Image = new Image(GameEngine.assets.getTexture("Menu_LightDivisor"));
		private var	menuDivisorH:Image = new Image(GameEngine.assets.getTexture("Menu_LightDivisorH"));
		private var	menuExternoLeft:Image = new Image(GameEngine.assets.getTexture("Menu_LightExternoLeft"));
		private var	menuExternoRight:Image = new Image(GameEngine.assets.getTexture("Menu_LightExternoRight"));
		private var	menuFrameFoot:Image = new Image(GameEngine.assets.getTexture("Menu_LightFrameFoot"));
		private var	menuFrameLeft:Image = new Image(GameEngine.assets.getTexture("Menu_LightFrameLeft"));
		private var	menuFrameMiddle:Image = new Image(GameEngine.assets.getTexture("Menu_LightFrameMiddle"));
		private var	menuFrameRight:Image = new Image(GameEngine.assets.getTexture("Menu_LightFrameRight"));
		private var	menuHighLight:Image = new Image(GameEngine.assets.getTexture("Menu_LightHighLight")); 
		private var	menuStatue:Image = new Image(GameEngine.assets.getTexture("Menu_LightStatue"));
		private var	menuOrnamentButtom:Image = new Image(GameEngine.assets.getTexture("Menu_LightOrnamentButtom"));
		private var	menuOrnamentTop:Image = new Image(GameEngine.assets.getTexture("Menu_LightOrnamentTop"));
		private var	menuOrnamentFooRight:Image = new Image(GameEngine.assets.getTexture("Menu_LightOrnamentFooRight"));
		private var	menuOrnamentFootLeft:Image = new Image(GameEngine.assets.getTexture("Menu_LightOrnamentFootLeft"));
		private var	menuSrtipsButtomLeft:Image = new Image(GameEngine.assets.getTexture("Menu_LightSrtipsButtomLeft"));
		private var	menuSrtipsButtomRight:Image = new Image(GameEngine.assets.getTexture("Menu_LightSrtipsButtomRight"));
		private var	menuStripsButtomMiddle:Image = new Image(GameEngine.assets.getTexture("Menu_LightStripsButtomMiddle")); 
		private var	menuStripsOrnamentTop:Image = new Image(GameEngine.assets.getTexture("Menu_LightStripsOrnamentTop")); 
		private var	menuStripsTopLeft:Image = new Image(GameEngine.assets.getTexture("Menu_LightStripsTopLeft"));
		private var	menuStripsTopMiddle:Image = new Image(GameEngine.assets.getTexture("Menu_LightStripsTopMiddle"));
		private var	menuStripsTopRight:Image = new Image(GameEngine.assets.getTexture("Menu_LightStripsTopRight"));
		private var backgroundColor:Image = new Image(GameEngine.assets.getTexture("Menu_DecalDouble"));
		
		public function GameMenu(){
			super();
			_main = GameEngine.instance;
			createInfoMenu();
			
			this.addEventListener(TouchEvent.TOUCH, onTouch);
			Starling.current.stage.addEventListener(Event.RESIZE, resize);

			createContents();
		}
		
		public function update():void {
			if (_currentContent && _currentContent as EquipableInfoContent && !_main.state.userInterfaces.cutscene.onScreen)
				_currentContent.update();
			
			if ((currentContent && currentContent == itemSubContent && (itemSubContent.equipMenu && itemSubContent.equipMenu.visible)) || _main.state.userInterfaces.cutscene.onScreen)
				return;
			
			if (UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_LEFT)) {
				rootMenu.index--;
				if(_currentContent as EquipableInfoContent)
					(_currentContent as EquipableInfoContent).menu.index = -2;
			}
				
			if (UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_RIGHT)) {
				rootMenu.index++;
				if(_currentContent as EquipableInfoContent)
					(_currentContent as EquipableInfoContent).menu.index = -2;
			}
			
			if (_main.state.mainPlayer.inputWatcher.justDid(InputActionsNames.INTERFACE_PREVIOUS)) {
				rootMenu.index--;
				if(_currentContent as EquipableInfoContent)
					(_currentContent as EquipableInfoContent).menu.index = -2;
				verifyContent(rootMenu.index);
				rootMenu.sectionIndex--;
				GameEngine.instance.soundComponent.play("UI_interface_enterAccept", "UI");
			}
			if (_main.state.mainPlayer.inputWatcher.justDid(InputActionsNames.INTERFACE_NEXT)) {
				rootMenu.index++;
				if(_currentContent as EquipableInfoContent)
					(_currentContent as EquipableInfoContent).menu.index = -2;
				verifyContent(rootMenu.index);
				rootMenu.sectionIndex++ ;
				GameEngine.instance.soundComponent.play("UI_interface_enterAccept", "UI");
			}
			
			if (_main.state.mainPlayer.inputWatcher.justDid(InputActionsNames.INTERFACE_CONFIRM) || _main.state.mainPlayer.inputWatcher.justDid(InputActionsNames.INTERFACE_MENU_INFO) || _main.state.mainPlayer.inputWatcher.justDid(InputActionsNames.INTERFACE_CANCEL) || _main.state.mainPlayer.inputWatcher.justDid(InputActionsNames.INTERFACE_PAUSE)){
				verifyContent(rootMenu.index);
				if (rootMenu.index >= 0){
					rootMenu.sectionIndex = rootMenu.index;
					GameEngine.instance.soundComponent.play("UI_interface_enterAccept", "UI");
				}
			}
			
			if (_main.state.mainPlayer.inputWatcher.justDid(InputActionsNames.INTERFACE_PAUSE) || _main.state.mainPlayer.inputWatcher.justDid(InputActionsNames.INTERFACE_MENU_INFO) || _main.state.mainPlayer.inputWatcher.justDid(InputActionsNames.INTERFACE_CANCEL) || _main.state.mainPlayer.inputWatcher.justDid(InputActionsNames.INTERFACE_PAUSE)){
				hide();
				GameEngine.instance.soundComponent.play("UI_interface_backCancel", "UI");
			}
		}
		
		private function onTouch(event:TouchEvent):void {
			if (UserInterfaces.instance.holdMenus)
				return;
			
			var touch:Touch = event.getTouch((event.target as DisplayObject));
			var menuIndex:int;
			if (touch) {
				
				menuIndex = rootMenu.menuItens.indexOf((event.target as DisplayObject).parent as BarMenuItem);	
				
				if(menuIndex != -1 && rootMenu.menuItens[menuIndex].enabled){
					if (touch.phase == TouchPhase.HOVER) {
						if(menuIndex != rootMenu.sectionIndex)
							rootMenu.index = menuIndex;
					}
					else if (touch.phase == TouchPhase.BEGAN) {
						verifyContent(rootMenu.index);
						if (rootMenu.index != -1)
							GameEngine.instance.soundComponent.play("UI_interface_enterAccept", "UI");
							rootMenu.sectionIndex = menuIndex;
					}
				}
			}
			else {
				rootMenu.index = -2;
			}
		}
		
		private function createContents():void{
			if (!statusContent)
				statusContent = new StatusContentComponent(this);
			if (!itemSubContent)
				itemSubContent = new EquipableInfoContent(ItemSubContentComponent, this);
			if (!spellSubContent)
				spellSubContent = new EquipableInfoContent(SpellSubContentComponent, this);
			if (!weaponSubContent)
				weaponSubContent = new EquipableInfoContent(WeaponSubContentComponent, this);
			if (!memoSubContent)
				memoSubContent = new EquipableInfoContent(MemoSubContentComponent, this);
			if (!helpSubContent)
				helpSubContent = new EquipableInfoContent(HelpSubContentComponent, this);
		}

		private function verifyContent(index:int):void {
			if (index < 0)
				return;

			var idemID:String = rootMenu.menuItens[index].itemID;
			switch (idemID){
				case "STATUS":
					currentContent = statusContent;
					break
				case "ITEMS":
					currentContent = itemSubContent;
					break
				case "SPELLS":
					currentContent = spellSubContent;
					break
				case "WEAPONS":
					currentContent = weaponSubContent;
					break
				case "LOG":
					currentContent = null;
					break
				case "MEMOS":
					currentContent = memoSubContent;
					break
				case "HELP":
					currentContent = helpSubContent;
					break
			}
		}
		
		private function updateAllContents():void {
			var barItem:BarMenuItem;
			var index:int;
			var maxIndex:int = rootMenu.menuItens.length;
			
			for (index = 0; index < maxIndex; index++ ) {
				barItem = rootMenu.menuItens[index];
				
				switch (barItem.itemID){
					case "STATUS":
						statusContent.updateData();
						statusContent.changeSkin(skin);
						break
					case "ITEMS":
						itemSubContent.updateData();
						itemSubContent.changeSkin(skin);
						
						if (itemSubContent.menu.menuItens.length == 0)
							barItem.enabled = false;
						else
							barItem.enabled = true;
						
						break
					case "SPELLS":
						spellSubContent.updateData();
						spellSubContent.changeSkin(skin);
						
						if (spellSubContent.menu.menuItens.length == 0)
							barItem.enabled = false;
						else
							barItem.enabled = true;
						
						break
					case "WEAPONS":
						weaponSubContent.updateData();
						weaponSubContent.changeSkin(skin);
						
						if (weaponSubContent.menu.menuItens.length == 0)
							barItem.enabled = false;
						else
							barItem.enabled = true;
						
						break
					case "LOG":
						barItem.enabled = false;
						break
					case "MEMOS":
						memoSubContent.updateData();
						memoSubContent.changeSkin(skin);
						
						if (memoSubContent.menu.menuItens.length == 0)
							barItem.enabled = false;
						else
							barItem.enabled = true;
						
						break
					case "HELP":
						helpSubContent.updateData();
						helpSubContent.changeSkin(skin);
						
						if (helpSubContent.menu.menuItens.length == 0)
							barItem.enabled = false;
						else
							barItem.enabled = true;
						
						break
				}
			}
		}
		
		public function show(skin:String = "Light", section:String="", subElmentID:String=""):void {
			GameEngine.instance.soundComponent.play("UI_interface_start", "UI");
			_main.state.paused = true;
			_main.stage.focus = _main.stage;

			if(section != ""){
				rootMenu.selectedItemID = section;
				verifyContent(rootMenu.sectionIndex);
			}

			if(subElmentID != ""){
				switch(section){
					case "ITEMS":
						itemSubContent.menu.selectecName = subElmentID;
						break;
					case "WEAPONS":
						weaponSubContent.menu.selectecName = subElmentID;
						break;
					case "MEMOS":
						memoSubContent.menu.selectecName = subElmentID;
						break;
					default:
						break;
				}
			}

			if (!statusContent)
				statusContent = new StatusContentComponent(this);
			
			if(!currentContent){
				currentContent = statusContent;
				
				rootMenu.sectionIndex = 0;
				rootMenu.index = -2;
			}
			
			this.skin = skin;
			
			statusContent.updateData();
			
			if (currentContent.skin != skin)
				currentContent.changeSkin(skin);
			
			UserInterfaces.instance.hud.visible = false;
			UserInterfaces.instance.belowMenuContainers.visible = false;
			UserInterfaces.instance.storyUI.visible = false;

			visible = false;
			
			if (!GameOptions.DISABLE_BLUR_EFFECTS){
				addChildAt(GameEngine.instance.state.globalEffects.uiBackgroundBlur, 0);
				GameEngine.instance.state.globalEffects.renderBackgroundBlur();
			}
			
			if (UserInterfaces.instance.pauseMenu.visible) {
				alpha = 1;
				infoMenuContainer.alpha = 0;
				GameEngine.instance.state.globalEffects.rendeUIBlur();
				GameEngine.instance.state.globalEffects.animateUIBlurIn();
				TweenMax.to(infoMenuContainer, 1, { startAt: { alpha:0 }, alpha:1 } );
			}
			else {
				alpha = 0;
				GameEngine.instance.state.globalEffects.rendeUIBlur();
				GameEngine.instance.state.globalEffects.animateBackgroundBlurIn();
				TweenMax.to(this, 1, { startAt: { alpha:0 }, alpha:1 } );
			}
			
			visible = true;
			
			updateAllContents();
		}
		
		public function hide():void {
			TweenMax.to(this, .3, { alpha:0 } );
			TweenMax.to(this, 0, { delay:.3, visible:false } );
			if (!GameOptions.DISABLE_BLUR_EFFECTS){
				GameEngine.instance.state.globalEffects.uiBackgroundBlur.animateBackgroundBlurOut();
				GameEngine.instance.state.globalEffects.uiBackgroundBlur.animateUIBlurOut();
			}
			UserInterfaces.instance.hud.visible = true;
			UserInterfaces.instance.belowMenuContainers.visible = true;
			UserInterfaces.instance.storyUI.visible = true;
			
			rootMenu.index = -2;
			
			rootMenu.selectedItemID = "";
			
			TweenMax.delayedCall(.3, setGamePlaying, [true]);
		}
		
		public function setGamePlaying(play:Boolean):void {
			_main.state.paused = !play;
			_main.stage.focus = _main.stage;
		}
		
		public function get skin():String {return _skin;}
		public function set skin(value:String):void {
			_skin = value;
			menuBackgroundLeft.texture = GameEngine.assets.getTexture("Menu_" + _skin + "BackgroundLeft");
			menuBackgroundMiddle.texture = GameEngine.assets.getTexture("Menu_" + _skin + "BackgroundMiddle");
			menuBackgroundRight.texture = GameEngine.assets.getTexture("Menu_" + _skin + "BackgroundRight");
			menuBigOrnamentDivisor.texture = GameEngine.assets.getTexture("Menu_" + _skin + "BigOrnamentDivisor");
			menuBodyBackground.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "BodyBackground");
			menuBodyFrameLeft.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "BodyFrameLeft");
			menuBodyFrameRight.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "BodyFrameRight");
			menuFrameOrnametTopLeft.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "FrameOrnametTopLeft");
			menuFrameOrnametTopRight.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "FrameOrnametTopRight");
			menuBodyTopOrnametLeft.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "BodyTopOrnametLeft");
			menuBodyTopOrnametRight.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "BodyTopOrnametRight");
			menuDivisor.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "Divisor");
			menuDivisorH.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "DivisorH");
			menuExternoLeft.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "ExternoLeft");
			menuExternoRight.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "ExternoRight");
			menuFrameFoot.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "FrameFoot");
			menuFrameLeft.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "FrameLeft");
			menuFrameMiddle.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "FrameMiddle");
			menuFrameRight.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "FrameRight");
			menuHighLight.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "HighLight"); 
			
			menuStatue.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "Statue");
			menuOrnamentButtom.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "OrnamentButtom");
			menuOrnamentTop.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "OrnamentTop");
			menuOrnamentFooRight.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "OrnamentFooRight");
			menuOrnamentFootLeft.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "OrnamentFootLeft");
			
			menuSrtipsButtomLeft.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "SrtipsButtomLeft");
			menuSrtipsButtomRight.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "SrtipsButtomRight");
			menuStripsButtomMiddle.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "StripsButtomMiddle"); 
			
			menuStripsOrnamentTop.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "StripsOrnamentTop"); 
			
			menuStripsTopLeft.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "StripsTopLeft");
			menuStripsTopMiddle.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "StripsTopMiddle");
			menuStripsTopRight.texture  = GameEngine.assets.getTexture("Menu_" + _skin + "StripsTopRight");
			
			backgroundColor.texture  = GameEngine.assets.getTexture("Menu_" + (_skin == "Dark" ? "Shadow" : "Decal") + "Double");
			backgroundColor.blendMode = (_skin == "Dark" ? BlendMode.NORMAL : BlendMode.SCREEN);
			backgroundColor.alpha = (_skin == "Dark" ? .7 : .3);
			
			rootMenu.skin = _skin;
			currentContent.changeSkin(_skin);
		}
		
		public function resize():void {
			gameMenuBG.width = gameMenuBG2.width = FullScreenExtension.screenWidth;
			gameMenuBG.height = 100;
			gameMenuBG2.height = 150;
			gameMenuBG.x = gameMenuBG2.x = FullScreenExtension.screenLeft;
			gameMenuBG2.y = FullScreenExtension.screenBottom - y;
			gameMenuBG.y = gameMenuBG2.y;
			
			//gameMenuHelp.x = gameMenuBG.x;
			gameMenuHelp.y = gameMenuBG.y - 50;
		}
		
		public function createInfoMenu():void {
			this.alpha = 0.999;
			
			var yPositionAdjust:int = -250;
			
			menuBackgroundMiddle.alignPivot();
			menuBackgroundMiddle.x = 0;
			menuBackgroundMiddle.y = 0 + yPositionAdjust;
			
			menuBackgroundLeft.alignPivot(HAlign.RIGHT, VAlign.CENTER);
			menuBackgroundLeft.x = - menuBackgroundMiddle.width * .5;
			menuBackgroundLeft.y = 0 + yPositionAdjust;
			
			menuBackgroundRight.alignPivot(HAlign.LEFT, VAlign.CENTER);
			menuBackgroundRight.x = menuBackgroundMiddle.width * .5;
			menuBackgroundRight.y = 0 + yPositionAdjust;
			
			menuFrameMiddle.alignPivot();
			menuFrameMiddle.x = 0;
			menuFrameMiddle.y = 0 + yPositionAdjust;
			
			menuFrameLeft.alignPivot(HAlign.RIGHT, VAlign.CENTER);
			menuFrameLeft.x = - menuFrameMiddle.width * .5;
			menuFrameLeft.y = 0 + yPositionAdjust;
			
			menuFrameRight.alignPivot(HAlign.LEFT, VAlign.CENTER);
			menuFrameRight.x = menuFrameMiddle.width * .5;
			menuFrameRight.y = 0 + yPositionAdjust;
			
			menuStripsTopMiddle.alignPivot(HAlign.CENTER, VAlign.BOTTOM);
			menuStripsTopMiddle.x = 0;
			menuStripsTopMiddle.y = -68 + yPositionAdjust;
			
			menuStripsTopLeft.alignPivot(HAlign.RIGHT, VAlign.BOTTOM);
			menuStripsTopLeft.x = - menuStripsTopMiddle.width * .5 + 2;
			menuStripsTopLeft.y = -68 + yPositionAdjust;
			
			menuStripsTopRight.alignPivot(HAlign.LEFT, VAlign.BOTTOM);
			menuStripsTopRight.x = menuStripsTopMiddle.width * .5 - 2;
			menuStripsTopRight.y = -68 + yPositionAdjust;
			
			menuOrnamentTop.alignPivot();
			menuOrnamentTop.x = 0;
			menuOrnamentTop.y = -83 + yPositionAdjust;
			
			menuStripsOrnamentTop.alignPivot();
			menuStripsOrnamentTop.y = -120 + yPositionAdjust;
			
			menuBodyBackground.alignPivot();
			menuBodyBackground.scaleX = menuBodyBackground.scaleY /= .7;
			menuBodyBackground.y = 22 + menuBodyBackground.height * .5 + yPositionAdjust;
			
			menuBodyFrameLeft.alignPivot(HAlign.LEFT, VAlign.TOP);
			menuBodyFrameLeft.x = -menuBodyBackground.width * .5;
			menuBodyFrameLeft.y = menuBodyBackground.y - menuBodyBackground.height * .5;
			
			menuBodyFrameRight.alignPivot(HAlign.RIGHT, VAlign.TOP);
			menuBodyFrameRight.x = menuBodyBackground.width * .5;
			menuBodyFrameRight.y = menuBodyBackground.y - menuBodyBackground.height * .5;
			
			menuFrameFoot.alignPivot(HAlign.CENTER, VAlign.BOTTOM);
			menuFrameFoot.x = menuBodyBackground.x;
			menuFrameFoot.y = menuBodyBackground.y + menuBodyBackground.height * .5;
			
			menuBodyTopOrnametLeft.alignPivot(HAlign.LEFT, VAlign.TOP);
			menuBodyTopOrnametLeft.x = -menuBodyBackground.width * .5;
			menuBodyTopOrnametLeft.y = menuBodyBackground.y - menuBodyBackground.height * .5;
			
			menuBodyTopOrnametRight.alignPivot(HAlign.RIGHT, VAlign.TOP);
			menuBodyTopOrnametRight.x = menuBodyBackground.width * .5;
			menuBodyTopOrnametRight.y = menuBodyBackground.y - menuBodyBackground.height * .5;
			
			menuOrnamentFootLeft.alignPivot(HAlign.LEFT, VAlign.BOTTOM);
			menuOrnamentFootLeft.x = -menuBodyBackground.width * .5;
			menuOrnamentFootLeft.y = menuBodyBackground.y + menuBodyBackground.height * .5;
			
			menuOrnamentFooRight.alignPivot(HAlign.RIGHT, VAlign.BOTTOM);
			menuOrnamentFooRight.x = menuBodyBackground.width * .5;
			menuOrnamentFooRight.y = menuBodyBackground.y + menuBodyBackground.height * .5;
			
			menuFrameOrnametTopLeft.alignPivot(HAlign.LEFT, VAlign.TOP);
			menuFrameOrnametTopLeft.x = -menuBodyBackground.width * .5;
			menuFrameOrnametTopLeft.y = menuBodyBackground.y - menuBodyBackground.height * .5;
			
			menuFrameOrnametTopRight.alignPivot(HAlign.RIGHT, VAlign.TOP);
			menuFrameOrnametTopRight.x = menuBodyBackground.width * .5;
			menuFrameOrnametTopRight.y = menuBodyBackground.y - menuBodyBackground.height * .5;
			
			backgroundColor.alignPivot();
			backgroundColor.width = FullScreenExtension.stageWidth;
			backgroundColor.height = FullScreenExtension.stageHeight;
			backgroundColor.alpha = .5;
			
			rootMenu.y = 0 + yPositionAdjust;
			
			backgroundColor.touchable = false;
			menuBodyBackground.touchable = false;
			menuBodyTopOrnametLeft.touchable = false;
			menuBodyTopOrnametRight.touchable = false;
			menuOrnamentFootLeft.touchable = false;
			menuOrnamentFooRight.touchable = false;
			menuBodyFrameLeft.touchable = false;
			menuBodyFrameRight.touchable = false;
			menuFrameFoot.touchable = false;
			menuStripsOrnamentTop.touchable = false;
			menuFrameOrnametTopLeft.touchable = false;
			menuFrameOrnametTopRight.touchable = false;
			menuBackgroundLeft.touchable = false;
			menuBackgroundMiddle.touchable = false;
			menuBackgroundRight.touchable = false;
			//rootMenu
			menuStripsTopLeft.touchable = false;
			menuStripsTopMiddle.touchable = false;
			menuStripsTopRight.touchable = false;
			menuFrameLeft.touchable = false;
			menuFrameMiddle.touchable = false;
			menuFrameRight.touchable = false;
			menuOrnamentTop.touchable = false;

			gameMenuHelp = UserInterfaces.instance.helpUI.showMenuHelpMessage(HelpProperties.HELP_HELP_MENU);
			gameMenuHelp.x = 0;

			infoMenuContainer.addChild(backgroundColor);
			infoMenuContainer.addChild(menuBodyBackground);
			infoMenuContainer.addChild(gameMenuBG);
			infoMenuContainer.addChild(gameMenuBG2);
			infoMenuContainer.addChild(gameMenuHelp);
			infoMenuContainer.addChild(menuBodyTopOrnametLeft);
			infoMenuContainer.addChild(menuBodyTopOrnametRight);
			infoMenuContainer.addChild(menuOrnamentFootLeft);
			infoMenuContainer.addChild(menuOrnamentFooRight);
			infoMenuContainer.addChild(menuBodyFrameLeft);
			infoMenuContainer.addChild(menuBodyFrameRight);
			infoMenuContainer.addChild(menuFrameFoot);
			infoMenuContainer.addChild(menuStripsOrnamentTop);
			infoMenuContainer.addChild(menuFrameOrnametTopLeft);
			infoMenuContainer.addChild(menuFrameOrnametTopRight);
			infoMenuContainer.addChild(menuBackgroundLeft);
			infoMenuContainer.addChild(menuBackgroundMiddle);
			infoMenuContainer.addChild(menuBackgroundRight);
			infoMenuContainer.addChild(rootMenu);
			infoMenuContainer.addChild(menuStripsTopLeft);
			infoMenuContainer.addChild(menuStripsTopMiddle);
			infoMenuContainer.addChild(menuStripsTopRight);
			infoMenuContainer.addChild(menuFrameLeft);
			infoMenuContainer.addChild(menuFrameMiddle);
			infoMenuContainer.addChild(menuFrameRight);
			infoMenuContainer.addChild(menuOrnamentTop);
			
			addChild(infoMenuContainer);
			
			x = FullScreenExtension.stageWidth * .5;
			y = FullScreenExtension.stageHeight * .45;
			
			gameMenuBG.setVertexAlpha(0, 0);
			gameMenuBG.setVertexAlpha(1, 0);
			
			gameMenuBG2.setVertexAlpha(0, 0);
			gameMenuBG2.setVertexAlpha(1, 0);
			
			gameMenuBG.alignPivot(HAlign.CENTER, VAlign.BOTTOM);
			gameMenuBG2.alignPivot(HAlign.CENTER, VAlign.BOTTOM);
			resize();
			
			
			//infoMenuContainer.scaleX = infoMenuContainer.scaleY = GameEngine.screenRatio * .7 + 0.3;
			
			this.visible = false;
			
			UserInterfaces.instance.menusContainers.addChild(this);
		}
		
		public function get currentContent():ContentComponent{ return _currentContent; }
		public function set currentContent(value:ContentComponent):void {
			if (value == _currentContent)
				return;
			
			if(_currentContent){
				_currentContent.hide();
				_currentContent = null;
			}
			
			if (!value)
				return;
				
			_currentContent = value;
			infoMenuContainer.addChildAt(_currentContent, infoMenuContainer.getChildIndex(menuBodyBackground) + 1);
			_currentContent.show();
		}
				
		override public function dispose():void {
			var id:String;
			for(id in this) {
				if (this[id] as DisplayObject){
					(this[id] as DisplayObject).removeFromParent(true);
					this[id] = null;
				}
			}	
			_main = null;
			if (statusContent)
				statusContent.removeFromParent(true);
			if (itemSubContent)
				itemSubContent.removeFromParent(true);
			if (spellSubContent)
				spellSubContent.removeFromParent(true);
			if (weaponSubContent)
				weaponSubContent.removeFromParent(true);
			if (memoSubContent)
				memoSubContent.removeFromParent(true);
			
			super.dispose();
		}
	}
}