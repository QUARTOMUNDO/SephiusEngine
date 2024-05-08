package SephiusEngine.userInterfaces.components {
	import starling.display.Sprite;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.text.TextField;
	import starling.display.DisplayObject;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * Base class for Help Sprite
	 * @author Fernando Rabello
	 */
	public class HelpSprite extends Sprite {
        public var skinImage:Image;

        public var forceSkin:String="";

        public var helpContainer:Sprite;
        
        public var helpTexts:Vector.<TextField> = new Vector.<TextField>();
        public var helpImages:Vector.<Image> = new Vector.<Image>();
        public var helpContents:Vector.<DisplayObject> = new Vector.<DisplayObject>();

        public var onScreen:Boolean;

        public function HelpSprite(skinTexture:Texture, forceSkin:String="") {
            this.forceSkin = forceSkin;
            
            skinImage = new Image(skinTexture);
            skinImage.alignPivot(HAlign.CENTER, VAlign.CENTER);
            
            if(forceSkin != "")
                skinImage.color = this.forceSkin == "Light" ? 0xffffff : 0x000000;

            addChild(skinImage);
            helpContainer = new Sprite();
            addChild(helpContainer);
        }
    }
}