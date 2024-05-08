package SephiusEngine.displayObjects.ViewObjects 
{
	import starling.display.Sprite;
	
	/**
	 * Special object used by GameView system
	 * ViewParallax is the one witch gets transformation constantly changed in order to create the illusion of deph and parallax
	 * @author Fernando Rabello.
	 */
	public class ViewParallax extends Sprite {
		/** ------------------------------------------ */
		/** ----- Old state for interpolation ----- */
		/** ------------------------------------------ */
		/** Position object was at last physic step */
		public var px:Number = 0;
		/** Position object was at last physic step */
		public var py:Number = 0;
		/** scaleX object was at last physic step */
		public var pScaleX:Number = 1;
		/** scaleY object was at last physic step */
		public var pScaleY:Number = 1;
		
		/** ------------------------------------------ */
		/** ----- New state for interpolation ----- */
		/** ------------------------------------------ */
		/** Position object was at last physic step */
		public var nx:Number = 0;
		/** Position object was at last physic step */
		public var ny:Number = 0;
		/** scaleX object was at last physic step */
		public var nScaleX:Number = 1;
		/** scaleY object was at last physic step */
		public var nScaleY:Number = 1;
		
		/** Locks */
		/** Lock art on the X axis. This mean it will not move related with camera on this axis */
		public var lockX:Boolean = false;
		/** Lock art on the Y axis. This mean it will not move related with camera on this axis */
		public var lockY:Boolean = false;
		/** Lock art scales. This mean it will not scale related with camera distance */
		public var lockScales:Boolean = false;
		
		public var finalParallax:Number = 1;
		public var parallax:Number = 1;
		public var dephFactor:Number = 1;
		
		public function ViewParallax(parallax:Number) {
			super();
			
			this.parallax = parallax;
		}
	}
}