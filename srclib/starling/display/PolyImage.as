package starling.display 
{
	import flash.geom.Rectangle;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	import starling.utils.VertexData;
	
	/**
	 * Similar to Image but object can have custom vertex locations and a custom amount of them. Object can have any shape. 
	 * Also support custom UV coords. This able to create diffent type of effects. 
	 * @author Fernando Rabello
	 */
	public class PolyImage extends QuadBatch {
		private var vertexIndex:int = 0;
		private var polyIndex:int = 0;
		
		public function PolyImage(texture:Texture) {
			super();
		}
		
        /** Adds an quad polygon to the batch. This method internally calls 'addQuad' with the correct
         *  parameters for 'texture' and 'smoothing'. */ 
        public function addPolygon(image:Image, data:QuadPolyData):void{
			//trace(".");
			//trace("PolyImage Poses:", data.pointsPos);
			//trace("PolyImage Coords", data.pointsCoords);
			//trace(".");
			
			vertexIndex = 0;
			
			for (vertexIndex; vertexIndex < data.vertexCount; vertexIndex++) {
				
				//trace("PolyImage Pos:", data.pointsPos[vertexIndex]);
				//trace("PolyImage Coord", data.pointsCoords[vertexIndex]);
				
				image.setVetexPosition(vertexIndex, data.pointsPos[vertexIndex].x, data.pointsPos[vertexIndex].y);			
				image.setTexCoordsTo(vertexIndex, data.pointsCoords[vertexIndex].x, data.pointsCoords[vertexIndex].y);
				
				if(data.pointsAlphas)
					image.setVertexAlpha(vertexIndex, data.pointsAlphas[vertexIndex]);
				if(data.pointsColors)
					image.multiplyVertexColor(vertexIndex, data.pointsColors[vertexIndex]);
			}
			
			//trace("PolyImage V3 Coord", image.getTexCoords(3));
			
			addQuad(image, 1, image.texture, null, null, null);
			
		}
	}
}