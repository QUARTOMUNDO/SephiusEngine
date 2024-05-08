package SephiusEngine.userInterfaces.menus.screenMenus {
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.gameplay.inventory.Inventory;
	import SephiusEngine.core.gameplay.inventory.objects.Item;
	import SephiusEngine.input.InputActionsNames;
	import SephiusEngine.userInterfaces.ScreenSkinsNames;
	import SephiusEngine.userInterfaces.UserInterfaces;
	import SephiusEngine.userInterfaces.components.contents.Contents.EquipableInfoContent;
	import SephiusEngine.userInterfaces.components.contents.subContents.ItemSubContentComponent;
	import SephiusEngine.userInterfaces.components.menus.ScreenMenuComponent;
	import SephiusEngine.userInterfaces.components.menus.menuItens.ScreenMenuItem;
	import SephiusEngine.userInterfaces.menus.ScreenMenu;

	import com.greensock.TweenMax;

	import starling.display.DisplayObject;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import SephiusEngine.Languages.LanguageManager;
	
	/**
	 * Menu sking if player really want to exit the game
	 * If on title, application will close. If on gameplay application will go to title screen.
	 * @author Fernando Rabello && Nilo Paiva
	 */
	public class EquipMenu extends ScreenMenu {
		private var _main:GameEngine;
		public var currentItem:Item;
		public var parentMenu:EquipableInfoContent;
		
		public function EquipMenu(pack:String, parentMenu:EquipableInfoContent) {			
			_main = GameEngine.instance;
			this.parentMenu = parentMenu;
			
			titleText = new TextField(1000, 500, "", "ChristianaWhite", 30, 0xffffff, true); 
			titleText.hAlign = "center"; 
			titleText.vAlign = "center"; 
			
			var equipQuestionLang:String = LanguageManager.getSimpleLang("EquipMenuElements", "EQUIP_QUESTION").name;
			titleText.text = equipQuestionLang; 
			
			titleText.hAlign = "center"; 
			titleText.vAlign = "center"; 
			
			titleText.touchable = false;
			
			rootMenu = new ScreenMenuComponent(Vector.<Array>([["EQUIP"], ["UNEQUIP"]]), this, pack, ["Mestizo", "Mestizo"], "EquipMenuElements");
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
			if (currentItem && UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_CONFIRM)) {
				if(rootMenu.index != -1){
					//rootMenu.selectecItem.currentState = (rootMenu.selectecItem.currentState + 1) % rootMenu.selectecItem.states.length;
					switch(rootMenu.selectecItem.itemID) {
						case "EQUIP" : 
							GameEngine.instance.state.mainPlayer.inventory.equipObject(currentItem.name, Inventory.TYPE_ITEM);
							
							if(parentMenu.content as ItemSubContentComponent){
								(parentMenu.content as ItemSubContentComponent).itemEquipedText.text = LanguageManager.getSimpleLang("GameMenuElements", "Equiped").name;
							}
							
							soundComponent.play("UI_interface_enterAccept", "UI");
							hide();
							break;
						case "UNEQUIP" : 
							GameEngine.instance.state.mainPlayer.inventory.unequipObject(currentItem.name, Inventory.TYPE_ITEM);
							
							if(parentMenu.content as ItemSubContentComponent){
								(parentMenu.content as ItemSubContentComponent).itemEquipedText.text = LanguageManager.getSimpleLang("GameMenuElements", "Not Equiped").name;
							}
							
							soundComponent.play("UI_interface_enterAccept", "UI");
							hide();
							break;
					}
				}
			}
		}
		
		override public function show(skin:String = "Light"):void {
			super.show(skin);
			TweenMax.to(backgroundColor, 0.4, { startAt: { alpha:0 }, alpha:1 } );
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
							soundComponent.play("UI_interface_enterAccept", "UI");
							this.hide();
							break
						case "NO" : 
							soundComponent.play("UI_interface_backCancel", "UI");
							hide();
							break
					}
				}
			}
		}
		
		override public function dispose():void {
			super.dispose();
			_main = null;
			currentItem = null;
			parentMenu = null;
		}
	}
}