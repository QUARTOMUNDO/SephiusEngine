package SephiusEngine.levelObjects.interfaces{
	import SephiusEngine.core.gameplay.attributes.AttributeHolder;
	import SephiusEngine.core.gameplay.attributes.holders.HarmfullObjectAttributes;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.IDamagerAttributes;
	import SephiusEngine.core.gameplay.attributes.subAttributes.DamagerAttibutes;
	import SephiusEngine.core.gameplay.damageSystem.DamageConstraint;
	import SephiusEngine.core.gameplay.damageSystem.DamageManager;
	import SephiusEngine.levelObjects.GameObject;
	import flash.utils.Dictionary;
	import nape.geom.Vec2;
	import nape.shape.Shape;
	
	/**
	 * Interface for objects witch cause damage to ISuffer Objects
	 * @author Fernando Rabello
	 */
	public interface IDamagerObject{
		function get name():String;
		
		function get enabled():Boolean;
		function set enabled(valuer:Boolean):void;
		
		function get attributes():AttributeHolder;
		function set attributes(valuer:AttributeHolder):void;
		function get damagerAttributes():IDamagerAttributes;
		
		function damagerReaction(damage:DamageManager):void;
		function damagerSecundaryReaction(damage:DamageManager):void;
		function applyImpulse(impulse:Vec2, pos:Vec2 = null):void;
		function applyConstrainedImpulse(impulse:Vec2, pos:Vec2 = null, contraintIntensity:Number =-1):void;
		
		function shouldCorrupt(suffer:ILevelInteractor):Boolean;
		
		function get rotationRad():Number;
		function get x():Number;
		function get y():Number;
		function get inverted():Boolean;
		function get mass():Number;
		function get velocityScaled():Vec2;
	}
}