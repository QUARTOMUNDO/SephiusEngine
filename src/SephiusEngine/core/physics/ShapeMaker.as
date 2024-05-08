package SephiusEngine.core.physics 
{
	import flash.geom.Matrix;
	import nape.geom.Mat23;
	import nape.geom.Vec2;
	import nape.geom.Vec2List;
	import nape.shape.Polygon;
	/**
	 * Tools to create shapes
	 * @author Fernando Rabello
	 */
	public class ShapeMaker {
		
		public function ShapeMaker() { }
		
		public static function BEVELED_BOX_FROM_MATRIX(matrix:Matrix=null, bevel:Number=.2, hWitdh:Number=100, hHeith:Number=15, internalX:Number = 0, internalY:Number = 0, internalRotation:Number = 0):Polygon {
			
			var vertices:Vec2List = new Vec2List();
			var shape:Polygon;
			vertices.add(Vec2.weak( -hWitdh + bevel, -hHeith));
			vertices.add(Vec2.weak( hWitdh - bevel, -hHeith));
			vertices.add(Vec2.weak( hWitdh, -hHeith + bevel));
			vertices.add(Vec2.weak( hWitdh, hHeith - bevel));
			vertices.add(Vec2.weak( hWitdh - bevel, hHeith));
			vertices.add(Vec2.weak( -hWitdh + bevel, hHeith));
			vertices.add(Vec2.weak( -hWitdh, hHeith - bevel));
			vertices.add(Vec2.weak( -hWitdh, -hHeith + bevel));
			shape = new Polygon(vertices);
			
			if(matrix)
				shape.transform(Mat23.fromMatrix(matrix));
			
			else{
				shape.transform(Mat23.translation(internalX, internalY));
				shape.transform(Mat23.rotation(internalRotation));
			}
			
			return shape;
		}
		
		private static var currentAngle:Number;
		private static var stepAngle:Number;
		private static var faceHeight:Number;
		private static var currentVertex:Vec2;
		private static var step:uint;
		public static function CAPSULE(matrix:Matrix=null, hWitdh:Number=100, hHeith:Number=15, numSteps:uint=10, internalX:Number = 0, internalY:Number = 0, internalRotation:Number = 0):Polygon {
			var vertices:Vec2List = new Vec2List();
			var shape:Polygon;
			
			faceHeight = (hHeith * 2) - hWitdh;
			currentAngle = -Math.PI;
			stepAngle = (Math.PI) / numSteps;
			
			for (step = 0; step <= numSteps; step++) {
				currentVertex = Vec2.weak();
				currentVertex.x = Math.cos(currentAngle) * hWitdh;
				currentVertex.y = (Math.sin(currentAngle) * hWitdh) + hWitdh;
				currentVertex.y -= hHeith + (hWitdh *.5);
				
				currentAngle += stepAngle;
				
				vertices.add(currentVertex);
			}
			
			currentAngle -= stepAngle;
			
			for (step = 0; step <= numSteps; step++) {
				currentVertex = Vec2.weak();
				currentVertex.x = Math.cos(currentAngle) * hWitdh;
				currentVertex.y = (Math.sin(currentAngle) * hWitdh) + (hWitdh + faceHeight);
				currentVertex.y -= hHeith + (hWitdh *.5);
				
				currentAngle += stepAngle;
				
				vertices.add(currentVertex);
			}
			
			shape = new Polygon(vertices);
			
			if(matrix)
				shape.transform(Mat23.fromMatrix(matrix));
			
			else{
				shape.transform(Mat23.translation(internalX, internalY));
				shape.transform(Mat23.rotation(internalRotation));
			}
			
			return shape;
		}
	}
}