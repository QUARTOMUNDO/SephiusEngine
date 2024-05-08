package SephiusEngine.levelObjects.interfaces {
	import SephiusEngine.core.gameplay.attributes.AttributeHolder;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.IMysticalAttributes;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.ISpellCasterAttributes;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.IStatusAttributes;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.ISufferAttributes;
	import nape.geom.Vec2;
	
	/**
	 * Objects Witch cast Spells
	 * @author Fernando Rabello
	 */
	public interface ISpellCaster {
		function get name():String;
		function get attributes():AttributeHolder;
		function set attributes(valuer:AttributeHolder):void;
		
		function get casterAttributes():ISpellCasterAttributes;
		
		function get rotationRad():Number;
		function get x():Number;
		function set x(value:Number):void;
		function get y():Number;
		function set y(value:Number):void;
		function get inverted():Boolean;
		function get group():uint;
		function get velocity():Vec2;
		function set velocity(value:Vec2):void;
		function get velocityScaled():Vec2;
	}
}