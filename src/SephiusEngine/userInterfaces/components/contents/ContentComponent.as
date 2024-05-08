package SephiusEngine.userInterfaces.components.contents {
	import com.greensock.TweenMax;

	import starling.display.Sprite;
	
	/**
	 * Base class for info menu content
	 * @author Fernando Rabello
	 */
	public class ContentComponent extends Sprite {
		public var skin:String = "Light";
		protected var objectParent:Object;
		public var opened:Boolean;
		
		public function ContentComponent(objectParent:Object){
			super();
			this.objectParent = objectParent;
		}
		
		/** Change Top Menu Component Skin. Propagates trought menu itens changing then skin also */
		public function changeSkin(skin:String):void {
			
		}
		
		public function show():void {
			updateData();
			
			changeSkin(objectParent.skin);
			
			alpha = 0;
			
			TweenMax.to(this, .3, { alpha:1, opened:true } );
			//TweenMax.to(this, 0, { delay:0.4, opened:true } );
		}
		
		public function hide():void {
			TweenMax.to(this, .3, { alpha:0, onComplete:removeFromParent } );
			opened = false;
		}
		
		public function setContent(contentName:String):void {
			
		}
		
		public function updateData():void {
			
		}
		
		override public function dispose():void {
			super.dispose();
		}
		
		public function update():void {
			
		}
	}
}