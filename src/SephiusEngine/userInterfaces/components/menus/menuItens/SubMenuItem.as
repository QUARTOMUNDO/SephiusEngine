package SephiusEngine.userInterfaces.components.menus.menuItens {
	import SephiusEngine.core.GameEngine;

	import com.greensock.TweenMax;

	import starling.display.Image;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	/**
	 * Single submenu´s item witch is shown on info menu sections. It allow to choose witch item will be shown on HUD rings
	 * @author Fernando Rabello
	 */
	public class SubMenuItem extends MenuItem {
		public function SubMenuItem(id:String, langCategory:String, skinNames:Array, hightLights:Array, blendModes:Array) {
			//textSize = 10;
			super(id, langCategory, skinNames, hightLights, blendModes, 1, false, 24);
			
			//setHighlightArt(["Hud_LightSmallHigh", "Hud_LightSmallHigh"], [BlendMode.NORMAL, BlendMode.SCREEN]);
			
			var i:int = 0;
			for (i = 0; i < hightLights.length; i++){
				selectionHighlightTextures.push(GameEngine.assets.getTexture(hightLights[i]));
			}
			
			setHighlightArt(hightLights);
		}

		override public function setHighlightArt(textureNames:Array):void {
			selectionHighlight = new Image(selectionHighlightTextures[0]);
			selectionHighlight.alignPivot(HAlign.CENTER, VAlign.CENTER);
			
			selectionHighlight.x = selectionHighlight.y = 0;
			selectionHighlight.alignPivot();
			selectionHighlight.width = this.text.width * 2.5 + 100;
			selectionHighlight.blendMode = selectionHighlightBlendModes[0];
			selectionHighlight.alpha = 0;
			selectionHighlight.touchable = false;
			addChildAt(selectionHighlight, 0);
		}
		
		override public function set skin(value:String):void {
			super.skin = value;
			
			if (_skin == "Dark")
				selectionHighlight.color = 0xff3322;
			else if (_skin == "Light")
				selectionHighlight.color = 0x59afdd;
		}
		
		override public function set selected(value:Boolean):void{
			if (_selected == value)
				return;
			
			if(value)
				TweenMax.to(selectionHighlight, .3, { alpha:.5 } );
			else
				TweenMax.to(selectionHighlight, .3, { alpha:0 } );
			
			_selected = value;
		}
	}
}