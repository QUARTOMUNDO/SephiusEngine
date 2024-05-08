package SephiusEngine.displayObjects.configs {
	/**
	 * Simple class to store: x, y, z,  rotation, and zoom and other atributes related with view
	 * @author Fernando Rabello
	 */
	public class ViewData {
		public var name:String;
		public var frame:uint;
		public var x:Number;
		public var y:Number;
		public var z:Number;
		public var rotation:Number;
		public var zoom:Number;
		
		public var scaleX:Number;
		public var scaleY:Number;
		public var scaleZ:Number;
		
		public var alpha:Number;
		
		public var color:uint;
		
		public function ViewData(name:String, x:Number = 0, y:Number = 0, z:Number = 0, rotation:Number = 0, zoom:Number = 0, scaleX:Number = 0, scaleY:Number = 0, scaleZ:Number = 0, frame:uint=0, alpha:Number=1, color:uint = 0) {
			this.name = name;
			
			this.x = x;
			this.y = y;
			this.z = z;
			
			this.scaleX = scaleX;
			this.scaleY = scaleY;
			this.scaleZ = scaleZ;
			
			this.rotation = rotation;
			
			this.zoom = zoom;
			
			this.frame = frame;
			
			this.alpha = alpha;
			
			this.color = color;
 		}
		
		public function setVars(x:Number = 0, y:Number = 0, z:Number = 0, rotation:Number = 0, zoom:Number = 0, scaleX:Number=0, scaleX:Number=0, scaleX:Number=0, alpha:Number=1, color:uint = 0):void {
			this.x = x;
			this.y = y;
			this.z = z;
			
			this.scaleX = scaleX;
			this.scaleY = scaleY;
			this.scaleZ = scaleZ;
			
			this.rotation = rotation;
			
			this.zoom = zoom;
			
			this.alpha = alpha;
			this.color = color;
		}
	}
}