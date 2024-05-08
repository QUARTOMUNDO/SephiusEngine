package SephiusEngine.levelObjects.specialObjects {
	import SephiusEngine.core.GamePhysics;
	import SephiusEngine.levelObjects.GamePhysicalObject;
	import SephiusEngine.levelObjects.interfaces.ILevelInteractor;
	import SephiusEngine.levelObjects.interfaces.IPhysicalObject;

	import nape.callbacks.PreCallback;
	import nape.callbacks.PreFlag;
	import nape.dynamics.CollisionArbiter;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Shape;
	import nape.shape.ShapeList;
	
	/**
	 * A physic object composed by several fixtures. 
	 * Its far lighter have 1 object with fixtures than have several individual platforms.
	 * @author Fernando Rabello.
	 */
	public class LevelCollision extends GamePhysicalObject {
		private var _shapes:ShapeList;
		
		public function LevelCollision(name:String, shapes:ShapeList, params:Object = null) {
			_shapes = shapes;
			super(name, params);
		}
		
		override public function createPhysics():void {
			_body = new Body(BodyType.STATIC);
			_body.shapes.merge(_shapes);
			
			_cbTypes.add(GamePhysics.LEVEL_CBTYPE);
			_cbTypes.add(GamePhysics.SPELL_INTERACTOR_CBTYPE);
			
			_interactionFilter = GamePhysics.LEVEL_FILTER;
			
			super.createPhysics();
		}
		
		/** return the contact angle in deggrees by a given angle in radians */
		protected function getCollisionAngleDeg(radAngle:Number):Number { return ((radAngle * (180 / Math.PI)) + 180) % 360; }
		
		private var colArb:CollisionArbiter;
		private var collidingShape:Shape;
		private var otherShape:Shape;
		private var colliderBottom:Number;
		private var slope:Number;
		private var rotationSin:Number;
		private var rotationCos:Number;
		private var finalAndgle:Number;
		private var upNormal:Boolean;
		
		public function handleOneWayContact(collider:IPhysicalObject, cb:PreCallback):PreFlag {
            colArb = cb.arbiter.collisionArbiter;
			collidingShape = !cb.swapped ? colArb.shape1 as Shape : colArb.shape2 as Shape;
			otherShape = cb.swapped ? colArb.shape1 as Shape : colArb.shape2 as Shape;
			upNormal = !cb.swapped ? colArb.normal.y >= -0.2 : colArb.normal.y < 0.2;//0.1 to give some margin to avoid colision with oneway platforms at 90 degrees
			var levelInteractor:ILevelInteractor = collider as ILevelInteractor;

			if (collidingShape.userData.oneWay){				
				colliderBottom = otherShape.bounds.max.y;
				
				colArb.normal.angle
				
				//Hipotetic line scope related with the plataform 
				//finalAndgle = collidingShape.userData.angle;
				finalAndgle = cb.swapped ? colArb.normal.angle + Math.PI * 2 : colArb.normal.angle;
				
				slope = Math.sin(finalAndgle) / Math.cos(finalAndgle);
				
				//trace("LevelCollision " + String(colliderBottom) + " / " + String(((slope * (collider.x - collidingShape.userData.center.x)) + (collidingShape.userData.center.y + y)) - collidingShape.userData.hy) + " / " + String(colliderBottom - ((slope * (collider.x - collidingShape.userData.center.x)) + (collidingShape.userData.center.y + y)) - collidingShape.userData.hy) + " / " + String(slope));
				//Collider bottom should be greater than slope function - half of the plataform heigh
				//if (otherShape.userData.penetrator || ((colliderBottom - ((slope * (collider.y - (collidingShape.userData.center.x + x))) + (collider.x - (collidingShape.userData.center.y + y))) - collidingShape.userData.hy) > 0))
				if(levelInteractor){
					if(levelInteractor.ignoreOneWayCollisions){
						return PreFlag.IGNORE;
					}
					else{
						if (upNormal)
							return PreFlag.IGNORE;
						else {
							if (levelInteractor.ignoredShapes.has(collidingShape))
								return PreFlag.IGNORE;
							else {
								levelInteractor.handleGroundPreTouch(collidingShape, cb);
								return PreFlag.ACCEPT_ONCE;
							}
						}
					}
				}
				else{
					if (upNormal)
						return PreFlag.IGNORE;
					else
						return PreFlag.ACCEPT_ONCE;
				}
			}
			else{
				(collider as ILevelInteractor).handleGroundPreTouch(collidingShape, cb);
				return PreFlag.ACCEPT;
			}
		}
	}
}