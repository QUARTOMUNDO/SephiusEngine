package SephiusEngine.levelObjects.specialObjects {
	import SephiusEngine.core.GamePhysics;
	import flash.geom.Matrix;
	import nape.dynamics.InteractionFilter;
	import nape.geom.Mat23;
	import nape.geom.Vec2;
	import nape.geom.Vec2List;
	import nape.phys.Material;
	import nape.shape.Polygon;
	import nape.shape.Shape;
	
	/**
	 * Polygon shape witch stores center position, rotation and dimensions.
	 * Used for oneway collisions.
	 * @author Fernando Rabello.
	 */
	public class LevelCollisionPoly {
		static private var LEVEL_MATERIAL_ROCK:Material = new Material(0, 1, 1.2, 50);
		static private var LEVEL_MATERIAL_ICE:Material = new Material(0, .05, .06, 50);
		
		public var center:Vec2;
		public var angle:Number = 0;
		public var hx:Number;
		public var hy:Number;
		public var oneWay:Boolean;
		
		public function LevelCollisionPoly() {
			
		}
		
		public static function CUSTOM_POLYGON(localVerts:*):Polygon {
			var shape:Polygon = new Polygon(localVerts, LEVEL_MATERIAL_ROCK, GamePhysics.LEVEL_FILTER);
			
			shape.cbTypes.add(GamePhysics.SPELL_INTERACTOR_CBTYPE);
			shape.cbTypes.add(GamePhysics.LEVEL_CBTYPE);
			
			shape.userData.center = shape.worldCOM;
			shape.userData.angle = 0;
			shape.userData.hx = -1;
			shape.userData.hy = -1;
			shape.userData.oneWay = false;
			
			return shape;
		}
		
		public static function BEVELED_BOX_FROM_MATRIX(matrix:Matrix, bevel:Number=.2, internalHWitdh:Number=100, internalHHeith:Number=15, internalX:Number = 0, internalY:Number = 0, internalRotation:Number = 0, oneWay:Boolean = false, invertOrder:Boolean = false):Polygon {
			var vertices:Vec2List =  new Vec2List();
			var shape:Polygon;
			if(!invertOrder){
				vertices.add(Vec2.weak( -internalHWitdh + bevel, -internalHHeith));
				vertices.add(Vec2.weak( internalHWitdh - bevel, -internalHHeith));
				vertices.add(Vec2.weak( internalHWitdh, -internalHHeith + bevel));
				vertices.add(Vec2.weak( internalHWitdh, internalHHeith - bevel));
				vertices.add(Vec2.weak( internalHWitdh - bevel, internalHHeith));
				vertices.add(Vec2.weak( -internalHWitdh + bevel, internalHHeith));
				vertices.add(Vec2.weak( -internalHWitdh, internalHHeith - bevel));
				vertices.add(Vec2.weak( -internalHWitdh, -internalHHeith + bevel));
			}
			else{
				vertices.add(Vec2.weak( -internalHWitdh, -internalHHeith + bevel));
				vertices.add(Vec2.weak( -internalHWitdh, internalHHeith - bevel));
				vertices.add(Vec2.weak( -internalHWitdh + bevel, internalHHeith));
				vertices.add(Vec2.weak( internalHWitdh - bevel, internalHHeith));
				vertices.add(Vec2.weak( internalHWitdh, internalHHeith - bevel));
				vertices.add(Vec2.weak( internalHWitdh, -internalHHeith + bevel));
				vertices.add(Vec2.weak( internalHWitdh - bevel, -internalHHeith));
				vertices.add(Vec2.weak( -internalHWitdh + bevel, -internalHHeith));
			}
			
			shape = new Polygon(vertices, LEVEL_MATERIAL_ROCK, GamePhysics.LEVEL_FILTER);
			
			shape.cbTypes.add(GamePhysics.SPELL_INTERACTOR_CBTYPE);
			shape.cbTypes.add(GamePhysics.LEVEL_CBTYPE);
			
			//shape.rotate(internalRotation);
			//shape.translate(Vec2.get(internalX, internalY));
			//shape.scale(Vec2.get(internalHWitdh, internalHHeith));
			
			if(matrix)
				shape.transform(Mat23.fromMatrix(matrix));
			
			//shape = shape.worldCOM;
			shape.userData.center = new Vec2(internalX, internalY);
			shape.userData.angle = internalRotation;
			shape.userData.hx = internalHWitdh;
			shape.userData.hy = internalHHeith;
			shape.userData.oneWay = oneWay;
			
			return shape;
		}
		
		public static function BOX_FROM_MATRIX(matrix:Matrix, internalHWitdh:Number=100, internalHHeith:Number=15, internalX:Number = 0, internalY:Number = 0, internalRotation:Number = 0, oneWay:Boolean = false):Polygon {
			var vertices:Vec2List =  new Vec2List();
			var shape:Polygon;
			vertices.add(Vec2.weak( -internalHWitdh, -internalHHeith));
			vertices.add(Vec2.weak( internalHWitdh, -internalHHeith));
			vertices.add(Vec2.weak( internalHWitdh, internalHHeith));
			vertices.add(Vec2.weak( -internalHWitdh, internalHHeith));
			
			shape = new Polygon(vertices, LEVEL_MATERIAL_ROCK, GamePhysics.LEVEL_FILTER);
			
			shape.cbTypes.add(GamePhysics.SPELL_INTERACTOR_CBTYPE);
			shape.cbTypes.add(GamePhysics.LEVEL_CBTYPE);
			
			//shape.rotate(internalRotation);
			//shape.translate(Vec2.get(internalX, internalY));
			//shape.scale(Vec2.get(internalHWitdh, internalHHeith));
			
			if(matrix)
				shape.transform(Mat23.fromMatrix(matrix));
			
			//shape = shape.worldCOM;
			shape.userData.center = new Vec2(internalX, internalY);
			shape.userData.angle = internalRotation;
			shape.userData.hx = internalHWitdh;
			shape.userData.hy = internalHHeith;
			shape.userData.oneWay = oneWay;
			
			return shape;
		}
	}
}