package SephiusEngine.displayObjects.ViewObjects {
	import com.greensock.loading.data.VideoLoaderVars;
	import SephiusEngine.displayObjects.GameArt;
	import SephiusEngine.displayObjects.configs.AssetsConfigs;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	
	/**
	 * Special sprite witch sort objects by their parallaxes. Serve as otimization specific for The Light of the Darkness game.
	 * @author Fernando Rabello
	 */
	public class ViewLayer extends Sprite {
		public const parallaxGroups:Vector.<ViewParallax> = new Vector.<ViewParallax>();
		public var group:int;
		
		public function ViewLayer(group:int) {
			super();
			
			this.group = group;
		}
		
		public function add(child:GameArt, above:Boolean = true):void{
			addAt(child, child.parallax, above);
		}
		
		public function addAt(child:GameArt, parallax:Number, above:Boolean = true):void{
			var n:int = parallaxGroups.length;
			var i:int;
			var cParallax:ViewParallax;
			
			for (i = 0; i < n; i++) {
				if (parallaxGroups[i].parallax == parallax && parallaxGroups[i].lockX == child.lockX && parallaxGroups[i].lockY == child.lockY && parallaxGroups[i].lockScales == child.lockScales)
 					cParallax = parallaxGroups[i];
			}
			
			if(!cParallax){
				cParallax = new ViewParallax(parallax);
				
				cParallax.lockScales = child.lockScales;
				cParallax.lockX = child.lockX;
				cParallax.lockY = child.lockY;
				
				parallaxGroups.push(cParallax);
				super.addChildAt(cParallax, numChildren); 
			}
			
			//trace("group:", group, " parallax:", cParallax.parallax, " children:", cParallax.numChildren, " x:", cParallax.x.toFixed(1), " y:", cParallax.y.toFixed(1), " width:", cParallax.width.toFixed(1), " height:", cParallax.height.toFixed(1), " pivotX:", cParallax.pivotX.toFixed(1), " pivotY:", cParallax.pivotY.toFixed(1), " scaleX:", cParallax.scaleX.toFixed(1), " scaleY:", cParallax.scaleY.toFixed(1));
 			
			if(above)
				cParallax.addChild(child);
			else
				cParallax.addChildAt(child, 0);
			
			//trace("group:", group, " parallax:", cParallax.parallax, " children:", cParallax.numChildren, " x:", cParallax.x.toFixed(1), " y:", cParallax.y.toFixed(1), " width:", cParallax.width.toFixed(1), " height:", cParallax.height.toFixed(1), " pivotX:", cParallax.pivotX.toFixed(1), " pivotY:", cParallax.pivotY.toFixed(1), " scaleX:", cParallax.scaleX.toFixed(1), " scaleY:", cParallax.scaleY.toFixed(1));
		}
		
		public function remove(child:GameArt):void{
			var cParallax:ViewParallax = child.parent as ViewParallax;
			
			if(cParallax)
				cParallax.removeChild(child);
			
			if (cParallax.numChildren == 0){
				parallaxGroups.splice(parallaxGroups.indexOf(cParallax), 1);
				
				var childIndex:int = getChildIndex(child);
				if (childIndex != -1) super.removeChildAt(childIndex, true);
			}
		}
		
		override public function removeChild(child:DisplayObject, dispose:Boolean = false):DisplayObject {
			throw new Error("Can´t remove child to this object this way. Use method 'remove' instead");
		}
		
		override public function removeChildAt(index:int, dispose:Boolean = false):DisplayObject {
			throw new Error("Can´t remove child to this object this way. Use method 'remove' instead");
		}
		
		override public function addChild(child:DisplayObject):DisplayObject {
			throw new Error("Can´t add child to this object this way. Use method 'Add' instead");
		}
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
			throw new Error("Can´t add child to this object this way. Use method 'Add' instead");
		}
	}
}