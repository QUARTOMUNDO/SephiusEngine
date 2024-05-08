package starling.extensions.lighting.lights
{
	import starling.extensions.brinkbit.fullscreenscreenextension.FullScreenExtension;
	import starling.extensions.lighting.core.LightBase;
	
	/**
	 * @author Szenia
	 */
	public class PointLight extends LightBase
	{
		private var _x:int;
		private var _y:int;
		private var _radius:Number;
		private var _castShadow:Boolean;
		
		/**
		 * A light that illuminates the scene equally in all directions
		 *
		 * @param x x position of the light in world cooridinates
		 * @param y y position of the light in world cooridinates
		 * @param radius radius of the light in world space
		 * @param color RGB color of the light. No alpha channel.
		 * @param brightness brightness modifier. Values > 1 dim the light, values < 1 brighten it.
		 */
		public function PointLight(x:int, y:int, radius:int, color:uint, brightness:Number = 1)
		{
			super(color, brightness);
			
			_x = x;
			_y = y;
			_radius = radius;
			_castShadow = true;
		}
		
		public function get x():int
		{
			return _x - FullScreenExtension.screenLeft;
		}
		
		public function set x(x:int):void
		{
			_x = x;
		}
		
		public function get y():int
		{
			return _y - FullScreenExtension.screenTop;
		}
		
		public function set y(y:int):void
		{
			_y = y;
		}
		
		public function get radius():Number
		{
			return _radius;
		}
		
		public function set radius(radius:Number):void
		{
			if (radius < 0)
				radius = Number.MAX_VALUE;
			_radius = radius;
		}
		
		public function get castShadow():Boolean 
		{
			return _castShadow;
		}
		
		public function set castShadow(value:Boolean):void 
		{
			_castShadow = value;
		}
	}
}
