package SephiusEngine.userInterfaces.menus.screenMenus {
	import SephiusEngine.core.GameData;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.gameStates.GameTitle;
	import SephiusEngine.core.gameStates.LevelManager;
	import SephiusEngine.input.InputActionsNames;
	import SephiusEngine.userInterfaces.UserInterfaces;
	import SephiusEngine.userInterfaces.components.menus.ScreenMenuComponent;
	import SephiusEngine.userInterfaces.components.menus.menuItens.ScreenMenuItem;
	import SephiusEngine.userInterfaces.menus.ScreenMenu;

	import flash.desktop.NativeApplication;

	import starling.display.DisplayObject;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import SephiusEngine.Languages.LanguageManager;

	/**
	 * Menu sking if player really want to exit the game
	 * If on title, application will close. If on gameplay application will go to title screen.
	 * @author Fernando Rabello
	 */
	public class ExitMenu extends ScreenMenu {
		private var _main:GameEngine;
		public function ExitMenu(pack:String) {			
			_main = GameEngine.instance;
			var questionText:String;

			if (GameEngine.instance.state as GameTitle)
				questionText = "ARE YOU SURE YOU WANT TO QUIT?";
			else if (GameEngine.instance.state as LevelManager)	{
				questionText = "ARE YOU SURE YOU WANT TO EXIT?";
			}

			var question:String = LanguageManager.getSimpleLang("ExitMenuElements", "ARE YOU SURE YOU WANT TO EXIT?").name;
			titleText = new TextField(1000, 65, question, "ChristianaWhite", 30, 0xffffff, true); 
			titleText.touchable = false;
			
			rootMenu = new ScreenMenuComponent(Vector.<Array>([["YES"], ["NO"]]), this, pack, ["Mestizo", "Mestizo"], "ExitMenuElements");
			super(pack);
			
			this.addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		public function yesActivated():void{
			if (GameEngine.instance.state as GameTitle)
				NativeApplication.nativeApplication.exit();
			else if (GameEngine.instance.state as LevelManager)	{
				GameData.getInstance().saveGame(GameEngine.instance.state.mainPlayer);
				GameEngine.instance.replaceState(new GameTitle());
				GameEngine.instance.soundComponent.fadeOutAll(2, true);
			}
		}
		
		public function noActivated():void{
			soundComponent.play("UI_interface_backCancel", "UI");
			hide();
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
							yesActivated();
							break
						case "NO" : 
							noActivated();
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
							yesActivated();
							break
						case "NO" : 
							noActivated();
							break
					}
				}
			}
		}
	}
}
