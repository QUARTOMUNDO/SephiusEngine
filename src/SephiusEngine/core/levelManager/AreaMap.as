package SephiusEngine.core.levelManager 
{
	import flash.utils.Dictionary;
	/**
	 * Store information about area coordinates using a color map associated with a LevelArea
	 * Used for Level Manager to determine on witch area player is.
	 * To use this AreaAreaMap is needed to store a bitmap data into a vector.
	 * Then you need to set mapWitdh, scalles and position that will be used to determine the corrected coordined
	 * @author Fernando Rabello
	 */
	public class AreaMap {
		public var colorIDs:Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>();
		public var areasIDs:Vector.<uint> = new Vector.<uint>();
		// Set true if the are map in use did not store actual area IDs but generic ID to be assign to areas latter. For SWF set this as true, set false if you are using XML for Level Region
		public var convertColorIDtoAreaID:Boolean = true;
		
		public var numberOfColors:uint = 0;
		
		/** The width original bitmapData has */
		public var mapWidth:uint;
		public var mapHeight:uint;
		
		/** The scaleX the original map container has. Normaly bitmap data has in smaller resolution then scalled up inside flash pro */
		public var scaleX:Number;
		
		/** The scaleY the original map container has. Normaly bitmap data has in smaller resolution then scalled up inside flash pro */
		public var scaleY:Number;
		
		/** The positionX the original map container was. 
		 * Bitmap container could be at any position inside flash pro 
		 * and this position need to be used to find the final coordinates of the pixels*/
		public var positionX:int;
		
		/** The positionX the original map container was. 
		 * Bitmap container could be at any position inside flash pro 
		 * and this position need to be used to find the final coordinates of the pixels*/
		public var positionY:int;
		
		public var unkownAreaGlonalID:uint;
		
		public function AreaMap(){}
		
		public static function fromArgs(colors:Vector.<uint>, mapWidth:uint, mapHeight:uint, scaleX:Number, scaleY:Number, positionX:int, positionY:int):AreaMap {
			var areaMap:AreaMap = new AreaMap();
			
			if (colors.length == 0)
				throw Error("[AREA Area COLOR]: a vector with colors information does not has any values");
			
			areaMap.colorIDs = new Vector.<Vector.<uint>>();
			areaMap.colorIDs.length = mapWidth;
			
			var index:int = 0;
			var ColorsUsed:Dictionary = new Dictionary();
			var color:uint
			var yIndex:uint;
			var xIndex:uint;
			var idCount:int = 0;
			
			for (index = 0; index < (mapWidth * mapHeight); index++) {
				color = (0xffffff & colors[index]);//converts ARGB to RGB
				
				xIndex = index % mapWidth;
				yIndex = Math.floor(index / mapWidth);
				
				if (!areaMap.colorIDs[xIndex]){
					areaMap.colorIDs[xIndex] = new Vector.<uint>();
					areaMap.colorIDs[xIndex].length = mapHeight;
				}
				
				if (!ColorsUsed[color]) {
					ColorsUsed[color] = idCount;
					idCount++;
				}
				
				areaMap.colorIDs[xIndex][yIndex] = ColorsUsed[color];
			}
			
			areaMap.numberOfColors = idCount;
			
			areaMap.unkownAreaGlonalID = 99;
			areaMap.mapWidth = mapWidth;
			areaMap.mapHeight = mapHeight;
			areaMap.positionX = positionX ;
			areaMap.positionY = positionY ;
			areaMap.scaleX = scaleX;
			areaMap.scaleY = scaleY;
			
			return areaMap;
		}
		
		public function assignColorIDtoAreaID(areaID:uint, colorID:uint):void {
			trace((areasIDs.length >= (colorID + 1)));
			if (areasIDs.length >= (colorID + 1))
				if(areasIDs[colorID] != 99)
					throw Error("Color ID " + colorID + " already assigned to AreaID " + areasIDs[colorID]);
			
			while (areasIDs.length - 1 < colorID){
				areasIDs.push(99)
			}
			
			areasIDs[colorID] = areaID;
		}
		
		/** Give a color ID based on a determined coordinate XY. If coordinate is out of bounds, it will return a unknownAreaGlobalID */
		public function getColorID(x:int, y:int):int {
			if (!colorIDs)
				throw Error("[AREA Area COLOR]: this objects is has not stored area ids")
			x -= positionX;
			y -= positionY;
			x /= scaleX;
			y /= scaleY;
			
			if (x < 0 || x > colorIDs.length - 1 || y < 0 || y > colorIDs[x].length - 1)
				return unkownAreaGlonalID;
			
			return colorIDs[x][y];
		}
		
		private var hColorID:uint;
		/** Give a area ID based on a determined coordinate XY. If coordinate is out of bounds, it will return a unknownAreaGlobalID */
		public function getAreaID(x:int, y:int):uint {
			if(!convertColorIDtoAreaID)
				return getColorID(x, y);
			else
				hColorID = getColorID(x, y);
				
			if (hColorID == 99 || hColorID >= areasIDs.length)
				return unkownAreaGlonalID;
			else 	
				return areasIDs[hColorID];
		}	
		
		public function destroy():void{
		}
	}
}