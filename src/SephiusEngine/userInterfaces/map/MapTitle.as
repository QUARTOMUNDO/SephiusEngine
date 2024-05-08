package SephiusEngine.userInterfaces.map {
	import SephiusEngine.core.GameData;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.userInterfaces.GameMap;

	import com.greensock.TweenMax;

	import starling.textures.SubTexture;
	import starling.display.Image;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.HAlign;
	import starling.display.Sprite;
	import SephiusEngine.Languages.LanguageManager;
	/**
	 * Title used to tell the name of a site in game maps.
	 * @author Fernando Rabello
	 */
	public class MapTitle extends Sprite {
		public var text:TextField = new TextField(300, 90, "Oblivion Lands", "ChristianaWhite", 90, 0x000000, true);
        public var titleString:String;
        public var titleID:String;
        public var borderMiddle:Image;
        public var borderRight:Image;
        public var borderLeft:Image;

		public function MapTitle(titleID:String, titleText:String, x:Number, y:Number, scaleX:Number, scaleY:Number) {
			super();
			this.titleID = titleID;
            titleString = titleText;

            text.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
            text.alpha = 0.7;

            borderMiddle = new Image(GameEngine.assets.getTexture("GameMap_" + titleID.replace(" ", "") + "Middle") as SubTexture);
            borderMiddle.alignPivot();
            addChild(borderMiddle);

            borderRight = new Image(GameEngine.assets.getTexture("GameMap_" + titleID.replace(" ", "") + "Right") as SubTexture);
            borderRight.alignPivot(HAlign.LEFT);
            addChild(borderRight);

            borderLeft = new Image(GameEngine.assets.getTexture("GameMap_" + titleID.replace(" ", "") + "Left") as SubTexture);
            borderLeft.alignPivot(HAlign.RIGHT);
            addChild(borderLeft);

            this.x = x;
            this.y = y;
            this.scaleX = scaleX;
            this.scaleY = scaleY;

            addChild(text);

            updateLang();
		}
		
		public function updateLang():void {
			text.text = LanguageManager.getSimpleLang("SiteNames", titleString).name.toUpperCase();
            text.alignPivot();
            updateLayout();
		}

        private function updateLayout():void{
            text.alignPivot();

            borderMiddle.width = text.width + 20;
            borderMiddle.height = (text.height * 2) + (titleID ==  "RegionBox" ? 100 : 130); // Non RegionBoxes need more height
            borderMiddle.y = LanguageManager.CURRENT_LANGUAGE == "pt" ? 0 : 5;//Deal with pt characters like ç and à which changes the pivot of the text

            borderRight.height = borderMiddle.height;
            borderRight.x = (borderMiddle.width / 2);//Put on the right side of the middle part
            borderRight.y = borderMiddle.y;

            borderLeft.height = borderMiddle.height;
            borderLeft.x = -(borderMiddle.width / 2);//Put on the left side of the middle part
            borderLeft.y = borderMiddle.y;
        }
	}
}