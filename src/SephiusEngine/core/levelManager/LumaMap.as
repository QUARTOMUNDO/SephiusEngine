package SephiusEngine.core.levelManager 
{
	import tLotDClassic.GameData.Properties.naturesInfos.Natures;
	/**
	 * Store information about a luminosity map associated with a LevelArea
	 * Used for UI to change skin from dark to bright places, bright to light.
	 * To use this AreaLumaMap is needed to store a bitmap data into a vector.
	 * Then you need to set mapWitdh, scalles and position that will be used to determine the corrected coordined
	 * @author Fernando Rabello
	 */
	public class LumaMap {
		/** All colors the original bitmap pixels has in a 1D index */
		public var colors:Vector.<uint>;
		
		/** If store colors is not exacly needed (ex: want just check if color is black or white)
		 * you can store booleans instead. Pass useBoolean as true to make use of this */
		public var booleans:Vector.<Vector.<Boolean>> = new Vector.<Vector.<Boolean>>();
		
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
		
		public function LumaMap(){}
		
		public static function fromArgs(colors:Vector.<uint>, mapWidth:uint, mapHeight:uint, scaleX:Number, scaleY:Number, positionX:int, positionY:int, useBooleans:Boolean = false):LumaMap {
			var lumaMap:LumaMap = new LumaMap();
			
			if (colors.length == 0)
				throw Error("[AREA LUMA COLOR]: a vector with colors information does not has any values");
			if (!useBooleans)
				lumaMap.colors = colors;
			else {
				lumaMap.booleans.length = mapWidth;
				var index:int = 0;
				var color:uint
				var yIndex:uint;
				var xIndex:uint;
				for (index = 0; index < (mapWidth * mapHeight); index++) {
					color = (((colors[index] >> 16) & 0xFF) / 255);//converts ARGB to Brighness
					
					xIndex = index % mapWidth;
					yIndex = Math.floor(index / mapWidth);
					
					if (!lumaMap.booleans[xIndex]){
						lumaMap.booleans[xIndex] = new Vector.<Boolean>();
						lumaMap.booleans[xIndex].length = mapHeight;
					}
					
					if (color >= 0.5)
						lumaMap.booleans[xIndex][yIndex] = true;
					else
						lumaMap.booleans[xIndex][yIndex] = false;
				}
			}
			
			lumaMap.mapWidth = mapWidth;
			lumaMap.mapHeight = mapHeight;
			lumaMap.positionX = positionX ;
			lumaMap.positionY = positionY ;
			lumaMap.scaleX = scaleX;
			lumaMap.scaleY = scaleY;
			
			return lumaMap;
		}
		
		/** Give a pixel color in the speficied position.
		 * Its already use AreaLumaMap informations to find corrected coordinate.
		 * So just pass the absolute position of the object 
		 * and this method will know where this pixel is inside it´s own vector of colors */
		public function getPixelColor(x:int, y:int):uint {
			if (!colors)
				throw Error("[AREA LUMA COLOR]: this objects is has not stored colors, try to use getPixelBoolean instead");
			x -= positionX;
			y -= positionY;
			x /= scaleX;
			y /= scaleY;
			
			if (colors[Math.floor(Math.ceil(x) + Math.ceil(y) * mapWidth)] > colors.length - 1)
				return 0;
				
			return colors[Math.floor(Math.ceil(x) + Math.ceil(y) * mapWidth)];
		}
		
		/** Give a pixel value as boolean in the speficied position.
		 * Its already use AreaLumaMap informations to find corrected coordinate.
		 * So just pass the absolute position of the object 
		 * and this method will know where this pixel is inside it´s own vector of colors */
		public function getPixelBoolean(x:int, y:int):Boolean {
			if (!booleans)
				throw Error("[AREA LUMA COLOR]: this objects is has not stored boleans, try to use getPixelColor instead")
			x -= positionX;
			y -= positionY;
			x = Math.floor(x / scaleX);
			y = Math.floor(y / scaleY);
			//x /= scaleX;
			//y /= scaleY;
			
			if (x < 0 || x > booleans.length - 1 || y < 0 || y > booleans[x].length - 1)
				return true;
			
			return booleans[x][y];
		}
		
		public function getPlaceNature(x:int, y:int):String {
			if (getPixelBoolean(x, y))
				return "Light";
			else
				return "Dark";
		}
		
		/** Give a pixel color in the speficied position.
		 * Its already use AreaLumaMap informations to find corrected coordinate.
		 * So just pass the absolute position of the object 
		 * and this method will know where this pixel is inside it´s own vector of colors */
		public function getPixelLuminosity(x:int, y:int):uint {
			if (!colors)
				throw Error("[AREA LUMA COLOR]: this objects is has not stored colors, try to use getPixelBoolean instead");
			x -= positionX;
			y -= positionY;
			x /= scaleX;
			y /= scaleY;
			
			if (Math.ceil(x) > mapWidth || Math.ceil(y) > mapHeight)
				return 0;
				
			return ((colors[Math.floor(Math.ceil(x) + Math.ceil(y) * mapWidth)] >> 16) & 0xFF) / 255;
		}
		
		public function destroy():void{
		}
	}
}