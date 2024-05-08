package SephiusEngine.userInterfaces.components.menus {
	import SephiusEngine.Languages.LanguageManager;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.userInterfaces.components.menus.menuItens.BarMenuItem;

	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Sprite;
	import flash.utils.Dictionary;

	/**
	 * Itens witch appear as root selection in a menu
	 * @author Fernando Rabello
	 */
	public class TopMenuComponent extends Sprite {
		private var menuParent:Object;
			
		/** Element index witch are selected at the momenent */
		private var _index:int = -2;
		private var _skin:String = "Light";
		
		private var _sectionIndex:int = -1;
		
		/** Name of the element that is selected */
		public function get indexID():String{
			if(index >= 0 && index < menuItens.length)
				return menuItens[index].itemID;
			else
				return "";
		}
		public function set indexID(value:String):void{
			if(menuItens.indexOf(menuItensDict[value]) != -1)
				index = menuItens.indexOf(menuItensDict[value]);
			else
				trace("[TOP MENU COMPONENT] Menu ItemID Don't Found: " + value);
		}
		/** Name of the element that is selected */
		public function get selectedItemID():String{
			if(sectionIndex >= 0 && sectionIndex < menuItens.length)
				return menuItens[sectionIndex].itemID;
			else
				return "";
		}
		public function set selectedItemID(value:String):void{
			if(menuItens.indexOf(menuItensDict[value]) != -1)
				sectionIndex = menuItens.indexOf(menuItensDict[value]);
			else
				trace("[TOP MENU COMPONENT] Menu ItemID Don't Found: " + value);
		}
		
		/** Name of the element that is selected */
		public var currentSectionName:String;
		
		/** Itens this menu has. Pass the names witch should appear*/
		public var menuItens:Vector.<BarMenuItem> = new Vector.<BarMenuItem>();
		/** Itens this menu has. Pass the names witch should appear*/
		public var menuItensDict:Dictionary = new Dictionary();
		
		/** Art divisors witch separates the menu itens */
		private var menuDivisors:Vector.<Image> = new Vector.<Image>();
		
		/** Space betwenn menu items */
		private var hSpacing:int = 50;
		
		public var pack:String;
		
		public function updateLang(landID:String):void{
			var i:int;
			var nextPosition:Number = 0;
			var size:Number;
			var sizePrevious:Number;

			//Need to update texts before update menu items spacing
			for (i = 0; i < numChildren; i++ ) {
				if(getChildAt(i) as BarMenuItem)
					(getChildAt(i) as BarMenuItem).updateLang(landID);
			}

			for (i = 0; i < numChildren; i++ ) {
				if(i > 0){
					if(getChildAt(i - 1) as BarMenuItem)
						size = (getChildAt(i - 1) as BarMenuItem).text.textFiled.width;
					else
						size = (getChildAt(i - 1) as Image).width;

					if(getChildAt(i) as BarMenuItem)
						sizePrevious = (getChildAt(i) as BarMenuItem).text.textFiled.width;
					else
						sizePrevious = (getChildAt(i) as Image).width;

					nextPosition = getChildAt(i - 1).x + (size * .5) + (sizePrevious * .5) + (hSpacing * .5);
				}
				getChildAt(i).x = nextPosition;
			}

			x = -getChildAt(Math.floor((numChildren) / 2)).x;
		}

		public function TopMenuComponent(menuItensIDs:Vector.<String>, menuParent:Object, pack:String, langCategory:String, hSpacing:int = 50) {
			this.menuParent = menuParent;
			this.hSpacing = hSpacing;
			var middleIndex:int = Math.floor(menuItensIDs.length / 2);
			var isOdd:Boolean = (menuItensIDs.length % 2 > 0);
			var nextPosition:Number = 0;
			var totalSize:Number = 0;
			var currentDivisor:Image;
			this.pack = pack;
			var itemLangName:String;

			for (var i:String in menuItensIDs) {
				menuItens.push(new BarMenuItem(menuItensIDs[i], langCategory, ["Light", "Dark"], [pack + "_LightHighLight", pack + "_DarkHighLight"], [BlendMode.NORMAL, BlendMode.SCREEN]));
				menuItensDict[menuItensIDs[i]] = menuItens[menuItens.length - 1];

				menuItens[i].autoLangUpdate = false;	

				addChild(menuItens[i]);
				
				if(menuItensIDs.length > 1 && int(i) < menuItensIDs.length -1){
					menuDivisors.push(new Image(GameEngine.assets.getTexture(pack + "_LightDivisor")));
					menuDivisors[int(i)].alignPivot();
					menuDivisors[int(i)].touchable = false;
					addChild(menuDivisors[int(i)]);
				}
				
				totalSize += menuItens[i].width;
				if(int(i) < menuItensIDs.length - 1 || menuItensIDs.length > 1)
					totalSize += hSpacing;
			}
							
			LanguageManager.ON_LANG_CHANGED.add(updateLang);
			updateLang("");	
		}
		
		public function get skin():String {return _skin;}
		public function set skin(value:String):void {
			_skin = value;
			
			for each (var item:BarMenuItem in menuItens) {
				item.skin = _skin;
			}
			for each (var divisor:Image in menuDivisors) {
				divisor.texture = GameEngine.assets.getTexture(pack + "_" +_skin + "Divisor");
			}
		}
		
		public function get index():int{ return _index; }
		public function set index(value:int):void {
			if (_index == value)
				return;
			
			//If value come as -2 deselect all
			if (value == -2) {	
				if(index > -1)
					menuItens[index].selected = false;
				_index = value;
				return;
			}
			
			//Detect if selection is going up or down (left or right)
			var toUP:Boolean = value > _index;
			
			//If nothing is highlighted highlight menu itens next to the selected item
			if (_index <= -2)
				value = toUP ? sectionIndex + 1 : sectionIndex - 1;
			
			//Deal with out of rage values (-1 or menuItens.length)
			value = value < 0 ? menuItens.length - 1 : value % (menuItens.length);
			//Jump the index witch is already selected
			value = value == _sectionIndex ? (toUP ? value + 1 : value - 1) : value;
			//Deal With out of range again if rule above make value go out of rage
			value = value < 0 ? menuItens.length - 1 : value % menuItens.length;
			
			//un-highligh old menu item
			if(index > -1)
				menuItens[index].selected = false;
			
			_index = value;
			//highligh new menu item if it is enabled
			if(menuItens[value].enabled){
				menuItens[value].selected = true;
				//selectecItemID = menuItens[value].itemID;
				GameEngine.instance.soundComponent.play("UI_interface_select", "UI");
			}
			else if(!menuItens[value].enabled){
				if(toUP)
					index = value + 1;
				else
					index = value - 1;
			}
		}
		
		public function get sectionIndex():int {return _sectionIndex;}
		public function set sectionIndex(value:int):void {
			if (_sectionIndex == value)
				return;
			
			var toUP:Boolean = value > _sectionIndex;
			
			value = value < 0 ? menuItens.length - 1 : value % menuItens.length;	
			
			if(menuItens[value].enabled){
				if(_sectionIndex != -1 || value == -1)	
					menuItens[_sectionIndex].isCurrentSection = false;
					
				if(value != -1){
					menuItens[value].isCurrentSection = true;
					currentSectionName = menuItens[value].itemID;
				}
				
				_sectionIndex = value;
				index = -2;
			}
			else if(!menuItens[value].enabled){
				if(toUP)
					sectionIndex = value + 1;
				else
					sectionIndex = value - 1;
			}
		}
		
		override public function dispose():void {
			super.dispose();
			for each (var menuItem:BarMenuItem in menuItens) {
				menuItem.dispose();
			}
			for each (var divisor:Image in menuDivisors) {
				divisor.dispose();
			}
			menuParent = null;
			menuItens.length = 0;
			LanguageManager.ON_LANG_CHANGED.remove(updateLang);
		}
	}

}