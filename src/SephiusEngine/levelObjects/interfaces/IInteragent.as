package SephiusEngine.levelObjects.interfaces {
	
	/**
	 * Describe a object ther objects can have game play interaction with
	 * @author Fernando Rabello
	 */
	public interface IInteragent {
		function get interactionType():int;
		function get interactionDistance():int;
		function get interactionValidator():String;
		function get canInteract():Boolean;
		
		function get x():Number;
		function get y():Number;
	}
}