package SephiusEngine.levelObjects.effects 
{
	import com.greensock.TweenMax;
	import SephiusEngine.core.GameEngine;
	
	/**
	 * Visual Representation of a equiped Weapon in the game
	 * @author Fernando Rabello
	 */
	public class ItemSprite extends SpecialSprite	{
		public static var qualquercoisa:Number = 0;
		
		public function ItemSprite(name:String, objectParams:Object = null) {
			super(name, objectParams);
		}
		
		override public function loadInitAndAdd():void {
			super.loadInitAndAdd();
			TweenMax.to(this, 0.1, { startAt: { scaleX:0.25, scaleY:0.25, alpha:0 }, scaleX:0.35, scaleY:0.35, alpha:1, yoyo:true, repeat:1 } );
			TweenMax.delayedCall(2, killITemSprite);
			GameEngine.instance.state.add(this);
		}
		
		public function killITemSprite():void {
			kill = true;
		}
	}
}