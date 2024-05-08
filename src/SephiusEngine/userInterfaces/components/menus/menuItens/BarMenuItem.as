package SephiusEngine.userInterfaces.components.menus.menuItens {
	import SephiusEngine.core.GameEngine;

	import com.greensock.TweenMax;

	import starling.display.BlendMode;
	import starling.display.Image;
	
	/**
	 * Single Menu Item
	 * @author Fernando Rabello
	 */
	public class BarMenuItem extends MenuItem{
		private var sectionHighlight:Image;
		protected var _isCurrentSection:Boolean;
		
		public function BarMenuItem(id:String, langCategory:String, skinNames:Array, hightLights:Array, blendModes:Array){
			super(id, langCategory, skinNames, hightLights, blendModes);

			sectionHighlight = new Image(GameEngine.assets.getTexture(hightLights[0]));
			sectionHighlight.alignPivot();
			sectionHighlight.x = sectionHighlight.y = 0;
			sectionHighlight.width = this.text.width * 1.3 + 100;
			sectionHighlight.blendMode = BlendMode.NORMAL;
			sectionHighlight.alpha = 0;
			sectionHighlight.touchable = false;
			
			setHighlightArt(hightLights);
			
			addChildAt(sectionHighlight, 0);
		}
		
		override public function get skin():String {return _skin;}
		override public function set skin(value:String):void {
			var skinIndex:int = skinNames.indexOf(value);
			if (skinIndex == -1)
				throw Error ("There is no skin with this name in this bar menu item");
			
			_skin = value;
			super.skin = value;
			
			sectionHighlight.texture = selectionHighlight.texture = selectionHighlightTextures[skinIndex];
			sectionHighlight.blendMode = !selectionHighlightBlendModes[skinIndex] ? BlendMode.NORMAL : selectionHighlightBlendModes[skinIndex];
		}
		
		public function get isCurrentSection():Boolean{ return _isCurrentSection; }
		public function set isCurrentSection(value:Boolean):void {
			if (_isCurrentSection == value)
				return;
				
			if(value)
				TweenMax.to(sectionHighlight, .3, { alpha:1 } );
			else
				TweenMax.to(sectionHighlight, .3, { alpha:0 } );
				
			_isCurrentSection = value;
		}
		
		override public function dispose():void {
			super.dispose();
			sectionHighlight.dispose();
		}
	}
}