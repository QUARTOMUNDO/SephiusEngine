package SephiusEngine.userInterfaces.components.menus.menuItens {
	import SephiusEngine.Languages.LanguageManager;
	import SephiusEngine.core.GameEngine;

	import com.greensock.TweenMax;

	import flash.geom.Rectangle;

	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	
	/**
	 * Generic single Menu Item
	 * @author Fernando Rabello
	 */
	public class MenuItem extends Sprite {
		public var itemID:String;
		public var langCategory:String;
		public var text:MenuItemText;
		public var textMestizo:MenuItemText;
		protected var selectionHighlight:Image;
		protected var _skin:String = "Light";
		public var skinNames:Array;
		
		public var touchArea:Quad;
		
		protected var selectionHighlightTextures:Array = new Array();
		protected var selectionHighlightBlendModes:Array = new Array();
		
		protected var highlightAlpha:Number = 1;
		
		public var sizeX:Number;
		public var sizeY:Number;
		protected var _selected:Boolean;
		protected var textSize:int = 30;
		public var autoLangUpdate:Boolean = true;

		public function MenuItem(id:String, langCategory:String, skinNames:Array, hightLights:Array, blendModes:Array, highlightAlpha:Number = 1, setHighLight:Boolean = false, textSize:int = 30, alignMode:String="center") {
			super();
			this.textSize = textSize;
			if (skinNames.length != hightLights.length)
				throw Error ("The number of skin names should be equal to number of highlights textures");
			
			this.skinNames = skinNames;
			this.text = new MenuItemText(id, textSize);
			this.text.touchable = false;
			this.text.alignMode = alignMode;

			this.langCategory = langCategory;

			this.textMestizo = new MenuItemText(id, textSize);
			this.textMestizo.touchable = false;
			this.textMestizo.alignMode = alignMode;
			
			this.highlightAlpha = highlightAlpha;
			
			sizeX = this.text.textFiled.width;
			sizeY = this.text.textFiled.height;
			itemID = id;
			
			touchArea = new Quad(this.text.width * 1.3, this.text.height * 1.3);
			touchArea.alignPivot();
			touchArea.alpha = 0;
			
			addChild(touchArea);
			
			selectionHighlightBlendModes = blendModes;
			
			if (!blendModes)
				selectionHighlightBlendModes.length = skinNames.length;
			
			if (setHighLight)
				setHighlightArt(hightLights)
				
			addChild(this.text);
			
			LanguageManager.ON_LANG_CHANGED.add(updateLang);

			if(autoLangUpdate)
				updateLang();
		}

		public function updateLang(langID:String=""):void{
			if(langCategory == "")//Should not translate.
				text.text = itemID;
			else
				text.text = LanguageManager.getSimpleLang(langCategory, itemID).name;

			sizeX = text.textFiled.width;
			sizeY = text.textFiled.height;
		}

		public function setHighlightArt(textureNames:Array):void {
			var i:int = 0;
			for (i = 0; i < textureNames.length; i++){
				selectionHighlightTextures.push(GameEngine.assets.getTexture(textureNames[i]));
			}
			
			selectionHighlight = new Image(selectionHighlightTextures[0]);
			selectionHighlight.x = selectionHighlight.y = 0;
			selectionHighlight.alignPivot();
			selectionHighlight.width = this.text.width * 1.3 + 100;
			selectionHighlight.blendMode = selectionHighlightBlendModes[0];
			selectionHighlight.alpha = 0;
			selectionHighlight.touchable = false;
			addChildAt(selectionHighlight, 0);
		}
		
		public function get skin():String { return _skin; }
		public function set skin(value:String):void {
			var skinIndex:int = skinNames.indexOf(value);
			if (skinIndex == -1)
				throw Error ("There is no skin with this name in this bar menu item");
			
			if (value == "Mestizo" && _skin != "Mestizo"){
				this.text.clipRect = new Rectangle( -this.text.width * .5, -this.text.height * .5, this.text.width * .5, this.text.height);
				this.textMestizo.clipRect = new Rectangle(0, -this.textMestizo.height * .5, this.textMestizo.width * .5, this.textMestizo.height);
				
				addChild(this.textMestizo);
			}
			else if(_skin == "Mestizo"){
				this.text.clipRect = new Rectangle( -this.text.width * .5, -this.text.height * .5, this.text.width * .5, this.text.height);
				this.textMestizo.clipRect = new Rectangle(0, -this.textMestizo.height * .5, this.textMestizo.width * .5, this.textMestizo.height);
				
				removeChild(this.textMestizo);
			}
			
			_skin = value;
			
			if (value == "Dark")
				text.fontName = "ChristianaWhite";
			else if (value == "Light")
				text.fontName = "ChristianaBlack";
			else if ( value == "Mestizo"){
				text.fontName = "ChristianaWhite";
				textMestizo.fontName = "ChristianaBlack";
			}
			else
				text.fontName = "ChristianaBlack" 
			
			selectionHighlight.texture = selectionHighlightTextures[skinIndex];
			selectionHighlight.blendMode = !selectionHighlightBlendModes[skinIndex] ? BlendMode.NORMAL : selectionHighlightBlendModes[skinIndex];
		}
		
		public function get selected():Boolean{ return _selected; }
		public function set selected(value:Boolean):void {
			if (_selected == value)
				return;
				
			if(value)
				TweenMax.to(selectionHighlight, .3, { alpha:highlightAlpha } );
			else
				TweenMax.to(selectionHighlight, .3, { alpha:0 } );
				
			_selected = value;
		}
		
		public function get enabled():Boolean{ return _enabled; }
		public function set enabled(value:Boolean):void {
			if (_enabled == value)
				return;
				
			if(value)
				TweenMax.to(this, .3, { alpha:1 } );
			else
				TweenMax.to(this, .3, { alpha:.3 } );
			
			_enabled = value;
		}
		protected var _enabled:Boolean = true;
		
		override public function dispose():void {
			super.dispose();
			removeChildren(0, -1, true);
			text = null;
			selectionHighlight = null;
			LanguageManager.ON_LANG_CHANGED.remove(updateLang);
		}
		
		public function toString():String {
			return itemID;
		}
	}
}