package SephiusEngine.levelObjects.interfaces 
{
	import SephiusEngine.core.gameplay.attributes.AttributeHolder;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.IEssenceBleederAttributes;
	/**
	 * For objects witch bleeds essence
	 * @author Fernando Rabello
	 */
	public interface IEssenceBleeder {
		function get name():String;
		
		function get enabled():Boolean;
		
		function get dead():Boolean;
		
		function get attributes():AttributeHolder;
		function get bleederAttributes():IEssenceBleederAttributes;
		
		function get rotationRad():Number;
		function get x():Number;
		function get y():Number;
		function get bleedOffsetX():Number;
		function get bleedOffsetY():Number;
		function get inverted():Boolean;
	}
}