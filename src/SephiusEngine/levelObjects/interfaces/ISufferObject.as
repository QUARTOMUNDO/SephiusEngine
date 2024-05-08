package SephiusEngine.levelObjects.interfaces 
{
	import SephiusEngine.core.effects.ObjectEffects;
	import SephiusEngine.core.gameplay.attributes.AttributeHolder;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.ISufferAttributes;
	import SephiusEngine.core.gameplay.status.interfaces.IStatus;
	import SephiusEngine.core.gameplay.attributes.subAttributes.SufferAttributes;
	import SephiusEngine.core.gameplay.status.CharacterStatus;
	import SephiusEngine.core.gameplay.damageSystem.DamageManager;
	import SephiusEngine.core.gameplay.properties.ObjectProperties;
	import nape.geom.Vec2;
	
	/**
	 * Objects witch can be damaged by IDamagerObjects
	 * @author Fernando [Sephius] Rabello
	 */
	public interface ISufferObject {
		function get name():String;
		
		function get enabled():Boolean;
		function set enabled(valuer:Boolean):void;
		
		function get attributes():AttributeHolder;
		function set attributes(valuer:AttributeHolder):void;
		function get sufferAttributes():ISufferAttributes;
		
		function sufferReaction(damage:DamageManager):void;
		function sufferSecundaryReaction(damage:DamageManager):void;
		function applyImpulse(impulse:Vec2, pos:Vec2 = null):void;
		function applyConstrainedImpulse(impulse:Vec2, pos:Vec2 = null, contraintIntensity:Number =-1):void;
		
		function get rotationRad():Number;
		function get dead():Boolean;
		function get x():Number;
		function get y():Number;
		function get inverted():Boolean;
		function get mass():Number;
		function get velocityScaled():Vec2;
	}
}