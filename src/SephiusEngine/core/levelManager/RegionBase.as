package SephiusEngine.core.levelManager 
{
	import flash.geom.Point;
	
	/**
	 * Place where player could start or resume the game after exit.
	 * @author Fernando Rabello
	 */
	public class RegionBase extends Point{
		
		public var globalID:uint = 0;
		public var locallID:uint = 0;
		public var areaGlobalID:uint = 0;
		
		private static var currentMaxID:int = 0;
		private static var currentMaxLocalIDs:Vector.<int> = new Vector.<int>();
		
		public var teleportable:Boolean = true;
		
		public function RegionBase(area:LevelArea, x:Number=0, y:Number=0, teleportable:Boolean = true){
			super(x, y);
			
			this.teleportable = teleportable;
			
			var areaGlobalID:uint = area.globalId;
			
			//trace("REGIONBASE=" + "New RegionBase / Area:" + areaGlobalID);
			
			if (currentMaxLocalIDs.length < areaGlobalID + 1){
				currentMaxLocalIDs.length = areaGlobalID + 1;
				currentMaxLocalIDs[areaGlobalID] = 0;
			}
			
			this.globalID = currentMaxID++;
			this.locallID = currentMaxLocalIDs[areaGlobalID]++;
			this.areaGlobalID = areaGlobalID;
		}
		
		public static function resetIDS():void{
			currentMaxID = 0;
			currentMaxLocalIDs.length = 0;
		}
	}
}