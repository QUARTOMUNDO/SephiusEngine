package SephiusEngine.levelObjects.interfaces 
{
	import SephiusEngine.core.gameplay.attributes.AttributeHolder;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.IAbsorberAttributes;
	
	/**
	 * Objects witch absorbs essence
	 * @author FernandoRabello
	 */
	public interface IEssenceAbsorber {
		function get name():String;
		
		function get enabled():Boolean;
		
		function get attributes():AttributeHolder;
		function get absorberAttributes():IAbsorberAttributes;
		
		function get rotationRad():Number;
		function get x():Number;
		function get y():Number;
		function get inverted():Boolean;
	}
	
}