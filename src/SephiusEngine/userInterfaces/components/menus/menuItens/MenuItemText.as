package SephiusEngine.userInterfaces.components.menus.menuItens 
{
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	
	/**
	 * 
	 * @author Fernando Rabello
	 */
	public class MenuItemText extends Sprite {
		public var textFiled:TextField;
		public var alignMode:String;
		private var _text:String;
		private var _fontName:String;
		private var _color:uint;
		
		public function MenuItemText(text:String, textSize:int = 30) {
			super();
			this._text = text;
			this.textFiled = new TextField(50, 10, text.split("_").join(" "), "ChristianaBlack", textSize, 0xffffff, true);
			this._fontName = textFiled.fontName;
			this.textFiled.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			this.textFiled.text = text;
			this.textFiled.x = this.textFiled.y = 0;
			addChild(textFiled);
		}
		
		public function get fontName():String {return _fontName;}
		public function set fontName(value:String):void {
			_fontName = value;
			this.textFiled.fontName = value;
			alignPivot(alignMode);
		}
		
		public function get text():String {return _text;}
		public function set text(value:String):void {
			_text = value;
			this.textFiled.text = value;
			alignPivot(alignMode);
		}
		
		public function get color():uint {return _color;}
		public function set color(value:uint):void {
			_color = value;
			this.textFiled.color = value;
		}
		
		override public function dispose():void {
			super.dispose();
			textFiled = null;//verify if sprite auto dispose this textfiled
		}
	}
}