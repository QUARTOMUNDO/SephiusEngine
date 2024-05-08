package SephiusEngine.userInterfaces.components.menus {
	import SephiusEngine.Languages.LanguageManager;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.userInterfaces.components.menus.menuItens.MenuItem;

	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Sprite;
	/**
	 * Menu for the Game Title Screen
	 * @author Fernando Rabello Nilo Paiva
	 */
	public class TitleMenuComponent extends Sprite {
		private var menuParent:Object;
			
		/** Element index witch are selected at the momenent */
		private var _index:int = -2;
		private var _skin:String = "Light";
		
		private var _sectionIndex:int = -1;
		
		/** Name of the element that is selected */
		public var selectecItemID:String;
		
		/** Name of the element that is selected */
		public var currentSectionName:String;
		
		/** Itens this menu has. Pass the names witch should appear*/
		public var menuItens:Vector.<MenuItem> = new Vector.<MenuItem>();
		
		/** Art divisors witch separates the menu itens */
		private var menuDivisors:Vector.<Image> = new Vector.<Image>();
		
		/** Space betwenn menu items */
		private var hSpacing:int = 100;
		
		public function updateLang(landID:String):void{
			var i:int;
			var nextPosition:Number = 0;
			var size:Number;
			var sizePrevious:Number;

			//Need to update texts before update menu items spacing
			for (i = 0; i < numChildren; i++ ) {
				if(getChildAt(i) as MenuItem)
					(getChildAt(i) as MenuItem).updateLang(landID);
			}
			
			for (i = 0; i < numChildren; i++ ) {
				if(i > 0){
					if(getChildAt(i - 1) as MenuItem)
						size = (getChildAt(i - 1) as MenuItem).sizeX;
					else
						size = (getChildAt(i - 1) as Image).width;

					if(getChildAt(i) as MenuItem)
						sizePrevious = (getChildAt(i) as MenuItem).sizeX;
					else
						sizePrevious = (getChildAt(i) as Image).width;

					nextPosition = getChildAt(i - 1).x + (size * .5) + (sizePrevious * .5) + (hSpacing * .5);
				}
				getChildAt(i).x = nextPosition;
			}

			x = -getChildAt(Math.floor((numChildren) / 2)).x;
		}

		public function TitleMenuComponent(menuItensIDs:Vector.<String>, menuParent:Object, pack:String, inHSpacing:int = 100) {
			this.menuParent = menuParent;
			var ctext:String;
			var charCount:uint = 0;

			for each (ctext in menuItensIDs){
				charCount += ctext.length;
			}
			
			this.hSpacing = inHSpacing * (charCount / 70);//41 is the default number of characters for english language

			var middleIndex:int = Math.floor(menuItensIDs.length / 2);
			
			var numItemsOdd:Boolean = (menuItensIDs.length % 2 != 0);
			var numDivisorsOdd:Boolean = ((menuItensIDs.length - 1) % 2 != 0);
			
			var menuItensNamesLenght:int = menuItensIDs.length;
			
			var halfLengnt:Number = (menuItensIDs.length) * .5;
			var halfLengntMinus1:Number = (menuItensIDs.length - 1) * .5
			
			var nextPosition:Number = 0;
			var totalSize:Number = 0;
			var currentDivisor:Image;
			
			var i:int;
			var itemBias:int = -1;
			var divisorBias:int = -1;
			
			var divisorName:String = pack + "_DivisorDark";
			var highLightName:String = pack + "_HighLightDark";
			
			var itemLangName:String;
			for (i = 0; i < menuItensNamesLenght; i++ ) {
							
				//Items Verification
				itemBias = (numItemsOdd) ? (i == Math.ceil(halfLengnt) ? 0 : i + 1 < halfLengnt ? -1 : 1) : (i < halfLengnt ? -1 : 1);
				
				itemLangName = LanguageManager.getSimpleLang("TitleMenuElements", menuItensIDs[i]).name;
				menuItens.push(new MenuItem(menuItensIDs[i], "TitleMenuElements", ["Light", "Dark", "Mestizo"], [pack+"_HighLightLight", pack+"_HighLightMestizo", pack+"_HighLightDark"], [BlendMode.NORMAL, BlendMode.SCREEN, BlendMode.SCREEN ], 1, true));
				menuItens[i].autoLangUpdate = false;
				menuItens[i].skin = itemBias == -1 ? menuItens[i].skinNames[1] : itemBias == 1 ? menuItens[i].skinNames[0] : menuItens[i].skinNames[2];
				addChild(menuItens[i]);
				
				//Divisors Verification
				divisorBias = numDivisorsOdd ? (i == Math.ceil(halfLengntMinus1 - 1) ? 0 : i < halfLengntMinus1 ? -1 : 1) : (i < halfLengntMinus1 ? -1 : 1);
				
				if ((menuItensIDs.length > 1 && i < menuItensIDs.length - 1)){
					divisorName = itemBias < 0 ? pack + "_DivisorDark" : pack + "_DivisorLight";
					
					currentDivisor = new Image(GameEngine.assets.getTexture(divisorName));
					currentDivisor.alignPivot();
					currentDivisor.touchable = false;
					
					menuDivisors.push(currentDivisor);
					addChild(currentDivisor);
					
					if (divisorBias == 0)
						currentDivisor.visible = false;
				}
				//Size Verification
				totalSize += menuItens[i].width;
				
				if(int(i) < menuItensIDs.length - 1 || menuItensIDs.length > 1)
					totalSize += hSpacing;
			}
			
			LanguageManager.ON_LANG_CHANGED.add(updateLang);
			updateLang("");
		}
		
		public function get index():int{ return _index; }
		public function set index(value:int):void {
			if (_index == value)
				return;
			
			//If value come as -2 deselect all
			if (value == -2 || value == -3) {	
				if(index > -1)
					menuItens[index].selected = false;
				_index = value;
				return;
			}
			
			//Detect if selection is going up or down (left or right)
			var toUP:Boolean = value > _index;
			
			//If nothing is highlighted highlight menu itens next to the selected item
			if (_index == -2)
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
				selectecItemID = menuItens[value].itemID;
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
					menuItens[_sectionIndex].selected = false;
					
				if(value != -1){
					menuItens[value].selected = true;
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
			for each (var menuItem:MenuItem in menuItens) {
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