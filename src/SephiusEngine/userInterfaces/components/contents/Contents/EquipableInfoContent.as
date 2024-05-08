package SephiusEngine.userInterfaces.components.contents.Contents {
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.input.InputActionsNames;
	import SephiusEngine.userInterfaces.components.contents.ContentComponent;
	import SephiusEngine.userInterfaces.components.contents.SubContentComponent;
	import SephiusEngine.userInterfaces.components.contents.subContents.HelpSubContentComponent;
	import SephiusEngine.userInterfaces.components.contents.subContents.ItemSubContentComponent;
	import SephiusEngine.userInterfaces.components.contents.subContents.MapSubContentComponent;
	import SephiusEngine.userInterfaces.components.contents.subContents.MemoSubContentComponent;
	import SephiusEngine.userInterfaces.components.contents.subContents.SpellSubContentComponent;
	import SephiusEngine.userInterfaces.components.contents.subContents.WeaponSubContentComponent;
	import SephiusEngine.userInterfaces.components.menus.SubMenuComponent;
	import SephiusEngine.userInterfaces.menus.screenMenus.EquipMenu;

	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	import starling.display.Image;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	import tLotDClassic.GameData.Properties.HelpProperties;
	import SephiusEngine.input.InputWatcher;
	
	/**
	 * Used for Items, Weapons and Spells content. Is composite with a submenu and and a subcontente. Allows to choose if item should be on HUD rings or not.
	 * Generlly used for all equipable group of items.
	 * @author Fernando Rabello
	 */
	public class EquipableInfoContent extends ContentComponent {
		public var contentName:String;
		public var menu:SubMenuComponent;
		public var equipMenu:EquipMenu;
		public var content:SubContentComponent;
		private var gradientTop:Image = new Image(GameEngine.assets.getTexture("Menu_DecalDouble"));
		private var gradientBottom:Image = new Image(GameEngine.assets.getTexture("Menu_DecalDouble"));
		public var contentClass:Class;
		private var _ge:GameEngine;
		
		private var menuDivisorTop:Image = new Image(GameEngine.assets.getTexture("Menu_LightBigOrnamentDivisor"));
		private var menuDivisorBottom:Image = new Image(GameEngine.assets.getTexture("Menu_LightBigOrnamentDivisor"));
		
		private var inputWatcher:InputWatcher;

		public function EquipableInfoContent(contentClass:Class, objectParent:Object) {
			super(objectParent);
			_ge = GameEngine.instance;
			inputWatcher = _ge.state.mainPlayer.inputWatcher;

			this.contentClass = contentClass;
			
			if (contentClass == ItemSubContentComponent) {
				contentName = "Item Menu";
				menu = new SubMenuComponent(Vector.<String>(GameEngine.instance.state.mainPlayer.inventory.itemsIDsSorted), this, "Menu", "ItemsData");
				equipMenu = new EquipMenu("OptionsMenu", this );
			}
				
			else if (contentClass == SpellSubContentComponent) {
				contentName = "Spell Menu";
				menu = new SubMenuComponent(Vector.<String>(GameEngine.instance.state.mainPlayer.inventory.spellsIDsSorted), this,  "Menu", "SpellsData");
				trace(menu.menuItens.toString());
			}
			
			else if (contentClass == WeaponSubContentComponent) {
				contentName = "Weapon Menu";
				menu = new SubMenuComponent(Vector.<String>(GameEngine.instance.state.mainPlayer.inventory.weaponsIDsSorted), this,  "Menu", "WeaponsData");
				trace(menu.menuItens.toString());
			}
			
			else if (contentClass == MemoSubContentComponent) {
				contentName = "Memo Menu";
				menu = new SubMenuComponent(Vector.<String>(GameEngine.instance.state.mainPlayer.inventory.memosIDsSorted), this,  "Menu", "MemosData");
				trace(menu.menuItens.toString());
			}
			
			else if (contentClass == HelpSubContentComponent) {
				contentName = "Help Menu";
				menu = new SubMenuComponent(HelpProperties.PROPERTIES_MENU_VAR_NAMES, this,  "Menu", "HelpMenuElements");
				trace(menu.menuItens.toString());
			}
			
			content = new contentClass();
			
			content.touchable = false;
			menuDivisorTop.touchable = false;
			menuDivisorBottom.touchable = false;
			
			menu.x -= 440;
			//content.rotation = 1;
			
			menuDivisorTop.alignPivot(HAlign.CENTER, VAlign.TOP);
			menuDivisorTop.x = menu.x + 220;
			menuDivisorTop.y = - 178;
			
			menuDivisorBottom.alignPivot(HAlign.CENTER, VAlign.TOP);
			menuDivisorBottom.rotation = Math.PI;
			menuDivisorBottom.x = menu.x + 220;
			menuDivisorBottom.y = 455;

			gradientBottom.alignPivot();
			gradientBottom.color = 0x000000;
			gradientBottom.width = 1500;
			gradientBottom.height = 350;
			gradientBottom.y = 450;

			gradientTop.alignPivot();
			gradientTop.color = 0x000000;
			gradientTop.width = 1500;
			gradientTop.height = 350;
			gradientTop.y = -200;

			clipRect = new Rectangle( -700, -275, 1400, 750);
			
			addChild(menu);
			addChild(content);

			addChild(gradientBottom);
			addChild(gradientTop);

			addChild(menuDivisorTop);
			addChild(menuDivisorBottom);
			
			//setContent(menu.menuItens[0].itemID);
		}
		
		override public function setContent(contentName:String):void {
			var idkList:Dictionary;
			if (content as ItemSubContentComponent){
				idkList = GameEngine.instance.state.mainPlayer.inventory.itemsByID;
				content.setContent(idkList[contentName]);
			}
			else if (content as SpellSubContentComponent){
				idkList = GameEngine.instance.state.mainPlayer.inventory.spellsByID;	
				content.setContent(idkList[contentName]);
			}
			else if (content as WeaponSubContentComponent){
				idkList = GameEngine.instance.state.mainPlayer.inventory.weaponsByID;	
				content.setContent(idkList[contentName]);
			}
			else if (content as MemoSubContentComponent){
				idkList = GameEngine.instance.state.mainPlayer.inventory.memosByID;
				content.setContent(idkList[contentName]);
			}
			else if (content as MapSubContentComponent){
				content.setContent(null);
			}
			else if (content as HelpSubContentComponent){
				idkList = HelpProperties.PROPERTIES_MENU_BY_VAR_NAME;
				content.setContent(idkList[contentName]);
			}
		}
		
		override public function updateData():void {
			trace("[EQUIPABLE INFO CONTENTE] classes:" + "ITEM = " + (contentClass == ItemSubContentComponent) + " / SPELL = " + (contentClass == SpellSubContentComponent));
			
			if (contentClass == ItemSubContentComponent){
				menu.updateData(Vector.<String>(GameEngine.instance.state.mainPlayer.inventory.itemsIDsSorted));
				trace("setting item menu");
			}
			
			else if (contentClass == SpellSubContentComponent){
				menu.updateData(Vector.<String>(GameEngine.instance.state.mainPlayer.inventory.spellsIDsSorted));
				trace("setting spell menu");
			}
			
			else if (contentClass == WeaponSubContentComponent){
				menu.updateData(Vector.<String>(GameEngine.instance.state.mainPlayer.inventory.weaponsIDsSorted));
				trace("setting weapon menu");
			}
			
			else if (contentClass == MemoSubContentComponent){
				menu.updateData(Vector.<String>(GameEngine.instance.state.mainPlayer.inventory.memosIDsSorted));
				trace("setting memo menu");
			}
			
			else if (contentClass == HelpSubContentComponent){
				menu.updateData(HelpProperties.PROPERTIES_MENU_VAR_NAMES);
				trace("setting help menu");
			}
			
			if(menu.menuItens.length > 0)
				setContent(menu.selectedItem.itemID);
		}
		
		override public function changeSkin(skin:String):void {
			super.changeSkin(skin);
			menu.skin = skin;
			this.skin = skin;
			content.changeSkin(skin);
			menuDivisorTop.texture = GameEngine.assets.getTexture("Menu_" + skin + "BigOrnamentDivisor");
			menuDivisorBottom.texture = GameEngine.assets.getTexture("Menu_" + skin + "BigOrnamentDivisor");

			gradientTop.color = skin == "Light" ? 0x2e323b : 0x000000;
			gradientBottom.color = skin == "Light" ? 0x2e323b : 0x000000;
			//gradient.width = 1500;
			//gradient.y = 1000;
		}
		
		override public function hide():void {
			super.hide();
			content.assets.purge();
		}

		private var indexChangeOnHoldTime:Number = 0;
		private var indexChangeOnHoldResetTime:Number = 50;

		private var indexChangeOnHoldMaxTime:Number = 30;
		private var indexChangeOnHoldMinTime:Number = 10;

		override public function update():void {
			if (equipMenu && equipMenu.visible)
				equipMenu.update();
			
			if(menu.menuItens.length == 0 || (equipMenu && equipMenu.visible) || !opened)
				return;
			
			if (inputWatcher.justDid(InputActionsNames.INTERFACE_UP) || inputWatcher.justDid(InputActionsNames.INTERFACE_DOWN)) {
				if(inputWatcher.justDid(InputActionsNames.INTERFACE_UP)){
					menu.index--;
					
					if (menu.index < 0)
						return;
				}
				else{
					menu.index++;
				}

				if (contentClass == ItemSubContentComponent)
					equipMenu.currentItem = _ge.state.mainPlayer.inventory.items[menu.menuItens[menu.index].itemID];
				
				setContent(menu.selectedItem.itemID);

				//Resets rate count down rate. So it will have initial rate when player start to press again
				indexChangeOnHoldResetTime = indexChangeOnHoldMaxTime;
				indexChangeOnHoldTime = indexChangeOnHoldResetTime;
			}

			//Holding buttom, trigger at some rate. This rate will increase over time gradually
			else if(indexChangeOnHoldTime <= 0){
				if (inputWatcher.isDoing(InputActionsNames.INTERFACE_UP) || inputWatcher.isDoing(InputActionsNames.INTERFACE_DOWN)) {
					if(inputWatcher.isDoing(InputActionsNames.INTERFACE_UP))
						menu.index--;
					else
						menu.index++;

					if (contentClass == ItemSubContentComponent)
						equipMenu.currentItem = _ge.state.mainPlayer.inventory.items[menu.menuItens[menu.index].itemID];
					
					setContent(menu.selectedItem.itemID);

					//Trigger time decreases over time so rate will be faster
					if(indexChangeOnHoldResetTime > indexChangeOnHoldMinTime)
						indexChangeOnHoldResetTime *= 0.6;
						
					indexChangeOnHoldTime = indexChangeOnHoldResetTime;
				}
			}

			if (inputWatcher.justDid(InputActionsNames.INTERFACE_CONFIRM) && equipMenu && menu.index >= 0){
				equipMenu.show(skin);
				GameEngine.instance.soundComponent.play("UI_interface_enterAccept", "UI");
			}

			//Trigger rate.
			if(indexChangeOnHoldTime > 0)
				indexChangeOnHoldTime--;
				
			menu.update();
		}
	}
}