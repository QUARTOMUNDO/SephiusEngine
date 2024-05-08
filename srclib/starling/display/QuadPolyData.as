package starling.display {
	import nape.geom.Vec2;
	/**
	 * Store data to be used in PolyImages
	 * @author Fernando Rabello
	 */
	public class QuadPolyData {
		public function QuadPolyData() {
			
		}
		
		public var vertexCount:int = 0;
		private var pointsString:String;
		
		private var pointPosition:Vec2;
		private var pointCoord:Vec2;
		private var pointAlpha:Number;
		private var pointColor:uint;
		
		private var pointsPosArray:Vector.<String> = new Vector.<String>();
		private var pointsCoordsArray:Vector.<String> = new Vector.<String>();
		private var pointsAlphasArray:Vector.<String> = new Vector.<String>();
		private var pointsColorsArray:Vector.<String> = new Vector.<String>();
		
		public var pointsPos:Vector.<Vec2> = new Vector.<nape.geom.Vec2>();
		public var pointsCoords:Vector.<Vec2> = new Vector.<nape.geom.Vec2>();
		public var pointsAlphas:Vector.<Number>;
		public var pointsColors:Vector.<uint>;
		
		private var sIndex:int;
		/**
		 * Take a string with numbers separated by ',' and make a list of vec2 for each vertex sent
		 * @param	pointsString
		 */
		public function parseVertexDataString(pointsPosString:String, pointsCoordString:String, pointsAlphaString:String, pointsColorString:String, pointCount:int):void{
			pointsPosArray = Vector.<String>(pointsPosString.split(","));
			pointsCoordsArray = Vector.<String>(pointsCoordString.split(","));
			
			pointsPos = new Vector.<nape.geom.Vec2>();
			pointsCoords = new Vector.<nape.geom.Vec2>();
			
			for (sIndex = 0; sIndex < pointsPosArray.length - 1; sIndex += 2) {
				vertexCount++;
				pointPosition = Vec2.get(parseFloat(pointsPosArray[sIndex]), parseFloat(pointsPosArray[sIndex + 1]));
				pointCoord = Vec2.get(parseFloat(pointsCoordsArray[sIndex]), parseFloat(pointsCoordsArray[sIndex + 1]));
				
				pointsPos.push(pointPosition);
				pointsCoords.push(pointCoord);
			}
			
			if (pointsAlphaString){
				pointsAlphasArray = Vector.<String>(pointsAlphaString.split(","));
				pointsAlphas = new Vector.<Number>();
			}
			if (pointsColorString){
				pointsColorsArray = Vector.<String>(pointsColorString.split(","));
				pointsColors = new Vector.<uint>();
			}
			
			for (sIndex = 0; sIndex < pointsPosArray.length; sIndex++) {
				if(pointsAlphaString){
					pointAlpha = parseFloat(pointsAlphasArray[sIndex]);
					pointsAlphas.push(pointAlpha);
				}
				if(pointsColorString){
					pointColor = parseInt(pointsColorsArray[sIndex]);
					pointsColors.push(pointColor);
				}
			}
		}
	}
}