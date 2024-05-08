package SephiusEngine.levelObjects.interfaces{
	import SephiusEngine.levelObjects.specialObjects.LevelCollision;
	import nape.callbacks.CbType;
	import nape.callbacks.CbTypeList;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.PreCallback;
	import nape.dynamics.Arbiter;
	import nape.dynamics.CollisionArbiter;
	import nape.dynamics.FluidArbiter;
	import nape.dynamics.InteractionFilter;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.Material;
	import nape.shape.EdgeList;
	import nape.shape.Shape;
	import nape.shape.ShapeList;
	import org.osflash.signals.Signal;

	/** An interface used by each Box2D object.*/
	public interface IPhysicalObject {
		function get body():Body;
		function get shapes():ShapeList;
		function get shapeType():String;
		function get mainShape():Shape;
		function get material():Material;
		
		function get destroyed():Boolean
		
		function get interactionFilter():InteractionFilter;
		function get cbTypes():CbTypeList;
		
		function get x():Number;
		function set x(value:Number):void;
		function get y():Number;
		function set y(value:Number):void;
		function get z():Number;
		function get rotation():Number;
		function set rotation(value:Number):void;
		function get rotationRad():Number;
		function set rotationRad(value:Number):void;
		function get width():Number;
		function set width(value:Number):void;
		function get height():Number;
		function set height(value:Number):void;
		function get depth():Number;
		function get radius():Number;
		function set radius(value:Number):void;
		function get velocity():Vec2;
		function set velocity(value:Vec2):void;
		function get velocityScaled():Vec2;
		function get angularVel():Number;
		function set angularVel(value:Number):void;
		function get mass():Number;
		function get gravityIntensity():Number;
		function set gravityIntensity(value:Number):void;
		function get allowRotation():Boolean;
		function set allowRotation(value:Boolean):void;
		function get allowMovement():Boolean;
		function set allowMovement(value:Boolean):void;
		
		function get physicAdded():Boolean;
		
		function createPhysics():void;
		function destroyPhysics():void; 
		function addPhysics():void;
		function removePhysics():void;
		
		function get onDestroyed():Signal;
		
		function applyImpulse(impulse:Vec2, pos:Vec2 = null):void;
		function applyConstrainedImpulse(impulse:Vec2, pos:Vec2 = null, contraintIntensity:Number =-1):void;
		function applyAngularImpulse(impulse:Number):void;
		function applyAngularVelocity(velocity:Number):void;
	}
}