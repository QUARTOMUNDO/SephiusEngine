package SephiusEngine.core.levelManager {
	import SephiusEngine.core.levelManager.LevelArea;
	import SephiusEngine.core.levelManager.LevelRegion;
	import flash.geom.Rectangle;
	
	/**
	 * Each Level/Region is divided by areas. This define a particular area.
	 * @author Fernando Rabello
	 */
	public class AreaBounds extends Rectangle {
		/** Name of this area bounds. It´s the same as the parentArea */
		public var name:String;
		/** LevelArea object this bounds belongs */
		public var parentArea:LevelArea;
		
		public function AreaBounds(x:Number=0, y:Number=0, width:Number=0, height:Number=0) {
			super(x, y, width, height);
		}
		
		public function destroy():void{
			parentArea = null;
		}
	}

}