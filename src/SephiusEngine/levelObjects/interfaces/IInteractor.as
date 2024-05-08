package SephiusEngine.levelObjects.interfaces {
	import SephiusEngine.core.gameplay.attributes.holders.InteractorAttributes;
	
	/**
	 * Describle objects witch interacts with IInteragents.
	 * @author Fernando Rabello
	 */
	public interface IInteractor {
		function get interactorAttributes():InteractorAttributes;
		function get x():Number;
		function get y():Number;
		function verifyInteractionRequirements(interagent:IInteragent):Boolean;
	}
}