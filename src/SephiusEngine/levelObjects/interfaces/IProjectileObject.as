package SephiusEngine.levelObjects.interfaces {
	import SephiusEngine.math.MathVector;
	import SephiusEngine.levelObjects.interfaces.IPhysicalObject;
	import SephiusEngine.utils.Wiggle;
	import nape.dynamics.CollisionArbiter;
	
	/**
	 * Describe attributes for objects witch are projectile (move trough enviroment with physics)
	 * @author Fernando Rabello
	 */
	public interface IProjectileObject {
		/** Speed this spell will start not counting with character velocity */
		function get speed():Number;
		function set speed(value:Number):void;
		
		/** Determine the type of rotation. Motion mean rotation related to velocity direction. Fixes means do not rotate. Constant means constant rotation */
		function get rotationType():String;
		function set rotationType(value:String):void;
		
		/** Rotation speed this spell will start */
		function get rotatonSpeed():String;
		function set rotatonSpeed(value:String):void;
		
		/** Blend mode before explodion and after explodion */
		function get blendModesOrder():Array;
		function set blendModesOrder(value:Array):void;
		
		/** Time until spell exploades by itself. In seconds */
		function get timeToExplode():Number;
		function set timeToExplode(value:Number):void;
		
		/** If spell can´t collide with physic objects */
		function get ethereal():Boolean;
		function set ethereal(value:Boolean):void;
		
		/** In how many pices a spell will create after explodes. Caution, each piece will consume additional essence. 0 for spells witch does not create fragments. */ 
		function get burstfragments():uint;
		function set burstfragments(value:uint):void;
		
		/** Determine the spell will burst upon impact */
		function get burstByImpact():Boolean;
		function set burstByImpact(value:Boolean):void;
		
		/** If is a spell can burst and how many times it should explode in smaller fragments. 0 for spells witch don´t explode */
		function get bursts():uint;
		function set bursts(value:uint):void;
		
		/** Explodes the Spell */
		function explode():void;
		
		/** Defines the wiggle options */
		function updateWiggle():void;
		
		function verifyLifeTime(lifeTime:Number):void;
		
		/** Explodes the spell with contact */
		function objectTouch(collider:IPhysicalObject, collisionArbiter:CollisionArbiter):void;
		
		/** Se a variavel tem wiggle ou não */
		function get wiggleable():Boolean;
		function set wiggleable(value:Boolean):void;
		
		/** Make spell go thought a ramdom path */
		function get wiggle():Wiggle;
		function set wiggle(value:Wiggle):void;
		
		/** Size sprite should be when spell explodes */
		function get explodedSize():Number;
		function set explodedSize(value:Number):void;
		
		/** How strong screen will shake when spell exploded */
		function get explosionShakness():Number;
		function set explosionShakness(value:Number):void;
		
		/** How much spell will bounce */
		function get restitution():Number;
		function set restitution(value:Number):void;
		
		/**  Current position of the wiggle */
		function get wigglePosition():MathVector;
		function set wigglePosition(value:MathVector):void;
		
		/** Spell has explode */ 
		function get bursted():Boolean;
		function set bursted(value:Boolean):void;
		
		/** If this spell was created by a parent spell this will tell witch piece count it is */
		function get count():int;
		function set count(value:int):void;
		
		/** Determine the spece between the parent spell to the spell pieces it creates */
		function get spacing():Number;
		function set spacing(value:Number):void;
	}
}