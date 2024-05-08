package SephiusEngine.displayObjects.configs 
{
	/**
	 * Store information to create a Light
	 * @author Fernando Rabello
	 */
	public class LightConfig {
		public var textureName:String;
		public var radius:uint = 100;
		public var color:uint = 0xfffffff;
		public var brightness:Number = 1;
		public var params:Object = null;
		
		public function LightConfig(textureName:String, radius:uint=100, color:uint=0xfffffff, brightness:Number=1, params:Object=null) {
			textureName = textureName;
			radius = radius;
			color = color;
			brightness = brightness;
			params = params;
		}
	}
}