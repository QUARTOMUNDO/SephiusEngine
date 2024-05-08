package SephiusEngine.userInterfaces.components.menus {
	import SephiusEngine.Languages.LanguageManager;
	import SephiusEngine.userInterfaces.components.menus.menuItens.ScreenMenuItem;

	import starling.display.BlendMode;
	import starling.display.Sprite;
	import starling.utils.HAlign;
	
	/**
	 * Menu witch appear on top other interfaces (like options menu);
	 * @author Fernando Rabello
	 */
	public class ScreenMenuComponent extends Sprite {
		private var menuParent:Object;
			
		/** Element index witch are selected at the momenent */
		private var _index:int = -1;
		
		private var _skin:String = "Light";
		
		/** Name of the element that is selected */
		public var selectecItem:ScreenMenuItem;
		
		/** Itens this menu has. Pass the names witch should appear*/
		public var menuItens:Vector.<ScreenMenuItem> = new Vector.<ScreenMenuItem>();
		
		///** Art divisors witch separates the menu itens */
		//private var menuDivisors:Vector.<Image> = new Vector.<Image>();
		
		/** Space betwenn menu items */
		private static var vSpacing:int = 18;
		
		public function ScreenMenuComponent(menuItensConfig:Vector.<Array>, menuParent:Object, pack:String, skinsNames:Array, langCaterogy:String) {
			super();
			
			this.menuParent = menuParent;
			var middleIndex:int = Math.floor(menuItensConfig.length / 2);
			var isOdd:Boolean = (menuItensConfig.length % 2 > 0);
			var nextPosition:Number = 0;
			var totalSize:Number = 0;
			var itemLangName:String;
			var itemStateLangName:String;
			var screenMenuItemStates:Array;
			var clangCaterogy:String;

			for (var i:String in menuItensConfig){
				if(menuItensConfig[i][0] == "LANGUAGE"){
					screenMenuItemStates = LanguageManager.getAvaiableLanguages();
					clangCaterogy = "";
				}
				else{
					screenMenuItemStates = menuItensConfig[i][1];
					clangCaterogy = langCaterogy;
				}

				if (menuItensConfig[i].length == 1)
					menuItens.push(new ScreenMenuItem(menuItensConfig[i][0], clangCaterogy, ["Light", "Dark"], [pack + "_" + skinsNames[0] + "Highlight", pack + "_" + skinsNames[0] + "Highlight"], [pack + "_" + skinsNames[0] + "Highlight", pack + "_" + skinsNames[0] + "Highlight"], [BlendMode.NORMAL, BlendMode.SCREEN], []));
				else
					menuItens.push(new ScreenMenuItem(menuItensConfig[i][0], clangCaterogy, ["Light", "Dark"], [pack + "_" + skinsNames[1] + "Highlight", pack + "_" + skinsNames[1] + "Highlight"], [pack + "_" + skinsNames[1] + "Highlight", pack + "_" + skinsNames[1] + "Highlight"], [BlendMode.NORMAL, BlendMode.SCREEN], screenMenuItemStates, HAlign.RIGHT));
				
				if(int(i) > 0)
					nextPosition = menuItens[int(i) - 1].y + (menuItens[int(i) - 1].sizeY * .5 + menuItens[i].sizeY * .5) + vSpacing;
				
				menuItens[i].y = nextPosition;
				addChild(menuItens[i]);
				
				totalSize += menuItens[i].height;
				if(int(i) < menuItensConfig.length - 1 || menuItensConfig.length > 1)
					totalSize += vSpacing;
			}
			
			if (isOdd)
				y -= menuItens[middleIndex].y;
			else
				y -= menuItens[middleIndex - 1].y + vSpacing * .5;
		}
		
		public function get skin():String {return _skin;}
		public function set skin(value:String):void {
			_skin = value;
			
			for each (var item:ScreenMenuItem in menuItens) {
				item.skin = _skin;
			}
		}
		
		public function get maxIndex():int{ return menuItens.length - 1; }
		
		public function get index():int{ return _index; }
		public function set index(value:int):void {
			if (_index == value || value > maxIndex)
				return;
				
			if(index != -1 || value == -1)	
				menuItens[index].selected = false;
			
			if(value != -1){
				menuItens[value].selected = true;
				selectecItem = menuItens[value];
				menuParent.soundComponent.play("UI_interface_select", "UI");
			}
			
			_index = value;
		}
		
		override public function dispose():void {
			super.dispose();
			menuParent = null;
			selectecItem = null;
			for each (var menuItem:ScreenMenuItem in menuItens) {
				menuItem.dispose();
			}
			menuItens.length = 0;
		}
	}
}