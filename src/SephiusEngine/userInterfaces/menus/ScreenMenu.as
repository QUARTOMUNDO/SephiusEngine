package SephiusEngine.userInterfaces.menus {
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.levelManager.GameOptions;
	import SephiusEngine.input.InputActionsNames;
	import SephiusEngine.sounds.system.components.global.GlobalSoundComponent;
	import SephiusEngine.userInterfaces.ScreenSkinsNames;
	import SephiusEngine.userInterfaces.UserInterfaces;
	import SephiusEngine.userInterfaces.components.menus.ScreenMenuComponent;

	import com.greensock.TweenMax;

	import starling.display.Image;
	import starling.display.Sprite;
	import starling.extensions.brinkbit.fullscreenscreenextension.FullScreenExtension;
	import starling.text.TextField;
	
	/**
	 * Generic Screen Menu
	 * @author Fernando Rabello
	 */
	public class ScreenMenu extends Sprite{
		private var _main:GameEngine;
		protected var _ge:GameEngine;
		private var _skin:String = "Light";
		
		public var soundComponent:GlobalSoundComponent;
		
		protected var backgroundColor:Image;
		
		public var rootMenu:ScreenMenuComponent;
		
		protected var titleText:TextField;
		
		protected var divisor:Image;
		
		public function ScreenMenu(pack:String) {
			super();
			_ge = GameEngine.instance;
			_main = GameEngine.instance;
			//soundComponent = new GlobalSoundComponent("ScreenMenu");
			//_ge.sound.soundSystem.registerComponent(soundComponent);
			soundComponent = _main.soundComponent;
			backgroundColor = new Image(GameEngine.assets.getTexture(pack + "_BG"));
			divisor = new Image(GameEngine.assets.getTexture(pack+"_DivisorH"));
			backgroundColor.touchable = false;
			divisor.touchable = false;
			createScreenMenu();
		}
		
		public function show(skin:String = "Light"):void {
			//Menu need to update to current values, for example if game was setted by a save game data or custom config
			
			_skin = skin;
			this.skin = skin;
			alpha = 1;
			backgroundColor.alpha = 0;
			
			if(skin == ScreenSkinsNames.DARK)
				backgroundColor.color = 0x000000;
			else if(skin == ScreenSkinsNames.LIGHT)
				backgroundColor.color = 0x000000;
			
			divisor.alpha = 0;
			rootMenu.alpha = 0;
			
			TweenMax.to(rootMenu, 0.5, { startAt: { alpha:0 }, alpha:1 } );
			TweenMax.to(backgroundColor, 0.5, { startAt: { alpha:0 }, alpha:1 } );
			TweenMax.to(divisor, 0.5, { startAt: { alpha:0 }, alpha:1 } );
			
			visible = false;
			
			if (!GameOptions.DISABLE_BLUR_EFFECTS) {
				GameEngine.instance.state.globalEffects.uiBackgroundBlur.rendeUIBlur();
				GameEngine.instance.state.globalEffects.uiBackgroundBlur.animateUIBlurIn();
				GameEngine.instance.state.userInterfaces.menusContainers.addChild(GameEngine.instance.state.globalEffects.uiBackgroundBlur);
			}
			
			visible = true;
			
			GameEngine.instance.state.userInterfaces.menusContainers.addChild(this);
		}
		
		public function hide():void {
			TweenMax.to(this, .3, { alpha:0 } );
			TweenMax.to(this, 0, { delay:.3, visible:false } );
			
			if (!GameOptions.DISABLE_BLUR_EFFECTS)
				GameEngine.instance.state.globalEffects.uiBackgroundBlur.animateUIBlurOut();
			
			rootMenu.index = -1;
			
			rootMenu.selectecItem = null;
			
			if (UserInterfaces.instance.titleMenu)
				UserInterfaces.instance.titleMenu.holdTitle = false;
		}
		

		private var indexChangeOnHoldTime:Number = 0;
		private var indexChangeOnHoldResetTime:Number = 50;

		private var indexChangeOnHoldMaxTime:Number = 30;
		private var indexChangeOnHoldMinTime:Number = 10;

		public function update():void {
			if (UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_UP) || UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_DOWN)){
				//Resets rate count down rate. So it will have initial rate when player start to press again
				indexChangeOnHoldResetTime = indexChangeOnHoldMaxTime;
				indexChangeOnHoldTime = indexChangeOnHoldResetTime;
			}

			if (UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_UP) && rootMenu.index > 0)
				rootMenu.index--;
			if (UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_DOWN) && rootMenu.index < rootMenu.menuItens.length -1)
				rootMenu.index++;

			//Holding buttom, trigger at some rate. This rate will increase over time gradually
			else if(indexChangeOnHoldTime <= 0){
				if (UserInterfaces.instance.inputWatcher.isDoing(InputActionsNames.INTERFACE_UP) || UserInterfaces.instance.inputWatcher.isDoing(InputActionsNames.INTERFACE_DOWN)) {
					if(UserInterfaces.instance.inputWatcher.isDoing(InputActionsNames.INTERFACE_UP)){
						if(rootMenu.index > 0)
							rootMenu.index--;
					}
					else
						rootMenu.index++;

					//Trigger time decreases over time so rate will be faster
					if(indexChangeOnHoldResetTime > indexChangeOnHoldMinTime)
						indexChangeOnHoldResetTime *= 0.6;
						
					indexChangeOnHoldTime = indexChangeOnHoldResetTime;
				}
			}

			if (UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_CANCEL) || UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_CANCEL_B)){
				hide();
				soundComponent.play("UI_interface_backCancel", "UI");
			}

			//Trigger rate.
			if(indexChangeOnHoldTime > 0)
				indexChangeOnHoldTime--;
		}
		


		public function get skin():String {return _skin;}
		public function set skin(value:String):void {
			//_skin = value;
			_skin = ScreenSkinsNames.DARK;//Force Dark Theme
			
			if (_skin == ScreenSkinsNames.DARK){
				backgroundColor.color = 0xffffff;
				titleText.fontName = "ChristianaWhite";
			}
			else if (_skin == ScreenSkinsNames.LIGHT){
				backgroundColor.color = 0x000000;
				titleText.fontName = "ChristianaBlack";
			}
			
			rootMenu.skin = _skin;
		}
		
		public function createScreenMenu():void {
			this.alpha = 0.999;
			
			backgroundColor.alignPivot();
			backgroundColor.width = FullScreenExtension.stageWidth + 500;
			backgroundColor.height = FullScreenExtension.stageHeight;
			backgroundColor.color = 0x000000;
			//backgroundColor.rotation = Math.PI;
			
			//titleText.autoSize =  TextFieldAutoSize.HORIZONTAL;
			titleText.alignPivot();
			titleText.y = rootMenu.y -100;
			
			divisor.alignPivot();
			divisor.y = titleText.y + 50;
			
			addChild(backgroundColor);
			addChild(titleText);
			addChild(divisor);
			addChild(rootMenu);
			
			x = FullScreenExtension.stageWidth * .5;
			y = FullScreenExtension.stageHeight * .52;
			
			//scaleX = scaleY = GameEngine.screenRatio * .7 + 0.3;
			
			this.visible = false;
		}
		
		override public function dispose():void {
			super.dispose();
			
		}
	}
}