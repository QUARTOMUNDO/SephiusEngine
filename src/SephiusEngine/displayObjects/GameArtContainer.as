package SephiusEngine.displayObjects {
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.displayObjects.AnimationPack;

	import starling.animation.IAnimatable;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	
	/**
	 * Special art container for GameObjects
	 * @author Fernando Rabello
	 */
	public class GameArtContainer extends Sprite {
		protected var _color:uint = 0xffffff;
		
		private var center:Image;
		public static var DEBUG:Boolean = false;
		
		/** Store IAnimatable objects added to this Game Art Container */
		public var animatables:Vector.<IAnimatable> = new Vector.<IAnimatable>();
		/** Store other GameArtContainer objects added to this Game Art Container */
		public var containers:Vector.<GameArtContainer> = new Vector.<GameArtContainer>();
		
		public function GameArtContainer() {
			super();
			
			if (DEBUG){
				center = new Image(GameEngine.assets.getTexture("Debug_box"));
				center.alignPivot();
				center.scaleX = center.scaleY = .2;
				center.color = 0xDD00FD;
				addChild(center);
			}
		}
		
		private var mIndex:uint;
		private var mChildAnima:AnimationPack;
		private var mChildCont:GameArtContainer;
		
		public function smoothState(fixedTimestepAccumulatorRatio:Number, oneMinusRatio:Number):void {
			
		}
		
		/** Anable this container also disabling its childs.*/
		public function activate():void {
			activated = true;
			for (mIndex = 0; mIndex < animatables.length; mIndex++){
				mChildAnima = animatables[mIndex] as AnimationPack;
				mChildAnima.activate();
				mChildAnima = null;
			}
			for (mIndex = 0; mIndex < containers.length; mIndex++){
				mChildCont = containers[mIndex] as GameArtContainer;
				mChildCont.activate();
				mChildCont = null;
			}
			//trace("GACONT: ", name, "activated");
		}
		
		/** Disable this container also disabling its childs. When disabled animations will not update */
		public function deactivate():void {
			activated = false;
			for (mIndex = 0; mIndex < animatables.length; mIndex++){
				mChildAnima = animatables[mIndex] as AnimationPack;
				mChildAnima.deactivate();
				mChildAnima = null;
			}
			for (mIndex = 0; mIndex < containers.length; mIndex++){
				mChildCont = containers[mIndex] as GameArtContainer;
				mChildCont.deactivate();
				mChildCont = null;
			}
			//trace("GACONT: ", name, "activated");
		}
		public var activated:Boolean;
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
			super.addChildAt(child, index);
			
			if (DEBUG)
				setChildIndex(center, numChildren);
			
			mChildAnima = child as AnimationPack;
			mChildCont = child as GameArtContainer;
			
			if (mChildAnima) {
				if (animatables.indexOf(mChildAnima) == -1){
					animatables.push(mChildAnima);
					if(activated)
						mChildAnima.activate();
				}
			}
			
			if (mChildCont) {
				if (containers.indexOf(mChildCont) == -1){
					containers.push(mChildCont);
					if(activated)
						mChildCont.activate();
				}
			}
			
			mChildAnima = null;
			mChildCont = null;
			return child;
		}
		
		override public function removeChildAt(index:int, dispose:Boolean = false):DisplayObject {
			mChildAnima = getChildAt(index) as AnimationPack;
			mChildCont = getChildAt(index) as GameArtContainer;
			
			if (mChildAnima) {
				if (animatables.indexOf(mChildAnima) > -1) {
					mChildAnima.deactivate();
					animatables.splice(animatables.indexOf(mChildAnima), 1);
				}
			}
			
			if (mChildCont) {
				if (containers.indexOf(mChildCont) > -1)
					mChildCont.deactivate();
					containers.splice(containers.indexOf(mChildCont), 1);
			}
			
			mChildAnima = null;
			mChildCont = null;
			return super.removeChildAt(index, dispose);
		}
		
		public function get color():uint {return _color;}
		public function set color(value:uint):void {
			_color = value;
		}
		
		public function get mainChild():Object {return _mainChild;}
		public function set mainChild(value:Object):void {
			_mainChild = value;
		}
		
		/** The child witch would receive effects and etc */
		private var _mainChild:Object;
		
		override public function dispose():void {
			mainChild = null;
			super.dispose();
		}
	}
}