package SephiusEngine.userInterfaces.components.menus {
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.userInterfaces.components.contents.subContents.ItemSubContentComponent;
	import SephiusEngine.userInterfaces.components.contents.subContents.SpellSubContentComponent;
	import SephiusEngine.userInterfaces.components.menus.menuItens.SubMenuItem;

	import flash.geom.Rectangle;

	import starling.display.BlendMode;
	import starling.display.Sprite;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	import flash.utils.Dictionary;
	
	/**
	 * submenu witch is shown on info menu sections. It allow to choose witch item will be shown on HUD rings
	 * @author Fernando Rabello
	 */
	public class SubMenuComponent extends Sprite {
		public var menuName:String;
		private var menuParent:Object;
		public var langCategory:String;

		/** Element index witch are selected at the momenent */
		private var _index:int = -1;
		private var _skin:String = "Light";
		
		/** Name of the element that is selected */
		public var selectedItem:SubMenuItem;

		public function get selectecName():String{ return menuItens[index].itemID; }
		public function set selectecName(value:String):void{
			index = menuItens.indexOf(menuItensDict[value]);
		}
		
		/** Itens this menu has. Pass the names witch should appear*/
		public var menuItens:Vector.<SubMenuItem> = new Vector.<SubMenuItem>();
		public var menuItensDict:Dictionary = new Dictionary();
		
		/** Space betwenn menu items */
		private static var vSpacing:int = 30;
		
		private var _indexDownLimit:int = 13;
		private var _indexUpLimit:int = 0;
		private var currentYPosition:Number = 0;
		
		private var submenuContainer:Sprite = new Sprite();
		
		public var pack:String;
		
		public function SubMenuComponent(menuItensConfig:Vector.<String>, menuParent:Object, pack:String, langCategory:String) {
			super();
			this.langCategory = langCategory;
			this.pack = pack;
			this.menuParent = menuParent;
			var nextPosition:Number = 0;
			var totalSize:Number = 0;
			var itemLangName:String;

			if (menuParent.contentClass == ItemSubContentComponent)
				menuName = "Item Menu";
				
			else if (menuParent.contentClass == SpellSubContentComponent)
				menuName = "Spell Menu";
				
			for (var i:String in menuItensConfig) {
				menuItens.push(new SubMenuItem(menuItensConfig[i], langCategory, ["Light", "Dark"], [pack + "_LightSmallHigh", pack + "_LightSmallHigh"], [BlendMode.NORMAL, BlendMode.SCREEN]));
				menuItensDict[menuItensConfig[i]] = menuItens[menuItens.length -1];

				if(int(i) > 0)
					nextPosition = menuItens[int(i) - 1].y + vSpacing;
				
				menuItens[i].y = nextPosition;
				submenuContainer.addChild(menuItens[i]);
				
				totalSize += menuItens[i].height;
				if(int(i) < menuItensConfig.length - 1 || menuItensConfig.length > 1)
					totalSize += vSpacing;
			}
			
			submenuContainer.alignPivot(HAlign.CENTER, VAlign.TOP);
			addChild(submenuContainer);
			
			clipRect = new Rectangle( -200, -275, 400, 750);
		}
		
		public function update():void {
			var posDiff:Number = (currentYPosition - (submenuContainer.y + 120)) * 0.1;
			submenuContainer.y += posDiff;
		}
		
		public function get skin():String {return _skin;}
		public function set skin(value:String):void {
			_skin = value;
			
			for each (var item:SubMenuItem in menuItens) {
				item.skin = _skin;
			}
		}
		
		public function updateData(menuItensConfig:Vector.<String>):void {
			for each (var menuItem:SubMenuItem in menuItens) {
				menuItem.dispose();
			}
			
			menuItens.length = 0;
			menuItensDict = new Dictionary();

			var nextPosition:Number = 0;
			var totalSize:Number = 0;
			var itemLangName:String;

			for (var i:String in menuItensConfig) {
				menuItens.push(new SubMenuItem(menuItensConfig[i], langCategory, ["Light", "Dark"], [pack + "_LightSmallHigh", pack + "_LightSmallHigh"], [BlendMode.NORMAL, BlendMode.SCREEN]));
				menuItensDict[menuItensConfig[i]] = menuItens[menuItens.length -1];

				if(int(i) > 0)
					nextPosition = menuItens[int(i) - 1].y + vSpacing;
				
				menuItens[i].y = nextPosition;
				submenuContainer.addChild(menuItens[i]);
				
				totalSize += menuItens[i].height;
				if(int(i) < menuItensConfig.length - 1 || menuItensConfig.length > 1)
					totalSize += vSpacing;
			}
			
			submenuContainer.alignPivot(HAlign.CENTER, VAlign.TOP);
			
			if(menuItensConfig.length == 0)
				return;
			
			index = index == -1 ? 0 : index;
			//selectedItem = menuItens[index];
		}
		
		public function get index():int{ return _index; }
		public function set index(value:int):void {
			if(menuItens.length == 0)
				return;
			
			if (index != -1 || value == -1 || value == -2){
				if(index >= 0)
					menuItens[index].selected = false;
				
				if (value == -2){
					_index = -1;
					return;
				}
			}
			
			value = value < 0 ? menuItens.length - 1 : value % menuItens.length;
			
			if(value != -1){
				menuItens[value].selected = true;
				selectedItem = menuItens[value];
				GameEngine.instance.soundComponent.play("UI_interface_select", "UI");
			}
			
			_index = value;
			
			if (_index == 0) {
				currentYPosition = 0;
				_indexUpLimit = 0;
				_indexDownLimit = 13;
			}
			else if ((_index == menuItens.length - 1) && _index > _indexDownLimit) {
				currentYPosition =  - menuItens[(menuItens.length - 15)].y;
				_indexUpLimit = menuItens.length - 13;
				_indexDownLimit = menuItens.length - 1;
			}
			else if (_index > _indexDownLimit) {
				if(index != -1)
					currentYPosition = - menuItens[_indexUpLimit].y;
				else
					currentYPosition = 0;
				_indexUpLimit++
				_indexDownLimit++
				//trace(_indexUpLimit);
				//trace(_indexDownLimit);
			}
			else if (_index < _indexUpLimit)	{
				if(index != -1)
					currentYPosition = - menuItens[_indexUpLimit -2].y;
				else
					currentYPosition = 0;
				_indexUpLimit--
				_indexDownLimit--
				//trace(_indexUpLimit);
				//trace(_indexDownLimit);
			}
		}
		
		override public function dispose():void {
			super.dispose();
			menuParent = null;
			for each (var menuItem:SubMenuItem in menuItens) {
				menuItem.dispose();
			}
			selectedItem = null;
			submenuContainer = null;
			menuItens.length = 0;
		}
	}
}