package SephiusEngine.userInterfaces.menus.screenMenus {
	import SephiusEngine.Languages.LanguageManager;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.input.InputActionsNames;
	import SephiusEngine.userInterfaces.ScreenSkinsNames;
	import SephiusEngine.userInterfaces.UserInterfaces;
	import SephiusEngine.userInterfaces.components.menus.ScreenMenuComponent;
	import SephiusEngine.userInterfaces.components.menus.menuItens.ScreenMenuItem;
	import SephiusEngine.userInterfaces.menus.ScreenMenu;

	import starling.display.DisplayObject;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;

	import tLotDClassic.GameData.Properties.CutsceneProperties;
	
	/**
	 * Menu sking if player really want to exit the game
	 * If on title, application will close. If on gameplay application will go to title screen.
	 * @author Fernando Rabello && Nilo Paiva
	 */
	public class OverrideMenu extends ScreenMenu {
		private var _main:GameEngine;
		public function OverrideMenu(pack:String) {			
			_main = GameEngine.instance;
			
			titleText = new TextField(1000, 500, "", "ChristianaWhite", 30, 0xffffff, true); 
			titleText.hAlign = "center"; 
			titleText.vAlign = "center"; 
			
			var OVERRIDE_QUESTION:String = LanguageManager.getSimpleLang("OverrideMenuElements", "OVERRIDE_QUESTION").name;
			titleText.text = OVERRIDE_QUESTION; 
			
			titleText.hAlign = "center"; 
			titleText.vAlign = "center"; 
			
			titleText.touchable = false;
			
			rootMenu = new ScreenMenuComponent(Vector.<Array>([["YES"], ["NO"]]), this, pack, ["Mestizo", "Mestizo"], "OverrideMenuElements");
			super(pack);
			
			skin = ScreenSkinsNames.DARK;
			
			this.addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		override public function update():void {
			
			if (UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_UP) && rootMenu.index != 0)
				rootMenu.index = 0;
			if (UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_DOWN) && rootMenu.index != 1)
				rootMenu.index = 1;
				
			if (UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_CANCEL) || UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_CANCEL_B)){
				hide();
				soundComponent.play("UI_interface_backCancel", "UI");
			}
			if (UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_CONFIRM)) {
				if(rootMenu.index != -1){
					//rootMenu.selectecItem.currentState = (rootMenu.selectecItem.currentState + 1) % rootMenu.selectecItem.states.length;
					switch(rootMenu.selectecItem.itemID) {
						case "YES" : 
							this.hide();
							UserInterfaces.instance.titleMenu.hide();
							UserInterfaces.instance.titleMenu.holdTitle = true;
							UserInterfaces.instance.cutscene.show(CutsceneProperties.PROLOGUE.varName);
							GameEngine.instance.soundComponent.fadeOutAll(2);
							break
						case "NO" : 
							soundComponent.play("UI_interface_backCancel", "UI");
							hide();
							break
					}
				}
			}
		}
		
		private function onTouch(event:TouchEvent):void {
			if (UserInterfaces.instance.holdMenus)
				return;
			
			var touch:Touch = event.getTouch((event.target as DisplayObject).parent.parent);
			if (touch) {
				if(touch.phase == TouchPhase.HOVER){
					rootMenu.index = rootMenu.menuItens.indexOf((event.target as DisplayObject).parent as ScreenMenuItem);
				}
				else if (touch.phase == TouchPhase.BEGAN) {
					if(rootMenu.index != -1)
						soundComponent.play("UI_interface_enterAccept", "UI");
					switch (((event.target as DisplayObject).parent as ScreenMenuItem).itemID){
						case "YES" : 
							this.hide();
							UserInterfaces.instance.cutscene.show(CutsceneProperties.PROLOGUE.varName);
							GameEngine.instance.soundComponent.fadeOutAll(2);
							break
						case "NO" : 
							soundComponent.play("UI_interface_backCancel", "UI");
							hide();
							break
					}
				}
			}
		}
	}
}