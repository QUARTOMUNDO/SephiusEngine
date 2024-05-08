package SephiusEngine.levelObjects.interfaces 
{
	import SephiusEngine.levelObjects.GamePhysicalObject;

	import nape.callbacks.PreCallback;
	import nape.dynamics.CollisionArbiter;
	import nape.dynamics.FluidArbiter;
	import nape.geom.Vec2;
	import nape.shape.EdgeList;
	import nape.shape.Shape;
	import nape.shape.ShapeList;

	import tLotDClassic.gameObjects.pools.Pool;
	
	/**
	 * Interface class for objects witch has logic interaction with the level itself *
	 * @author Fernando Rabello
	 */
	public interface ILevelInteractor {
		function handleGroundPreTouch(shape:Shape, cb:PreCallback):void;
		function handleGroundTouch(begin:Boolean, ground:IPhysicalObject, collisionArbiter:CollisionArbiter, shape:Shape, swapped:Boolean):void;
		function handleGroundContact(ground:IPhysicalObject, collisionArbiter:CollisionArbiter, shape:Shape, swapped:Boolean):void;
		function handleFluidContact(state:String, fluid:Pool, fluidArbiter:FluidArbiter):void;
		
		function get impactVelocity():Vec2;
		function get impactVelocityScaled():Vec2;
		function get velocityScaled():Vec2;
		
		function get ignoredShapes():ShapeList;
		function get groundContacts():EdgeList;
		function get groundContactsAngles():Vector.<Number>;
		
		function get onGround():Boolean;
		function set onGround(value:Boolean):void;
		
		function get touchingAPoll():Boolean;
		function get submergedArea():Number
		function get submerged():Boolean;
		
		function get ignoreOneWayCollisions():Boolean;
		
		function get groundHeight():int;
		function set groundHeight(value:int):void;

		//function get invertedNormalCollision():Boolean;
	}
}