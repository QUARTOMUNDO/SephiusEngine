package SephiusEngine.levelObjects.interfaces 
{
	import SephiusEngine.core.gameplay.attributes.AttributeHolder;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.IAttractorAttributes;
	
	/**
	 * Objects witch attract particles
	 * @author FernandoRabello
	 */
	public interface IAttractor {
		function get name():String;
		
		function get enabled():Boolean;
		
		function get attributes():AttributeHolder;
		function get attractorAttributes():IAttractorAttributes;
		
		function get rotationRad():Number;
		function get x():Number;
		function get y():Number;
		function get inverted():Boolean;
	}
	
}