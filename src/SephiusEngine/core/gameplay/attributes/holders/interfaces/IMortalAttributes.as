package SephiusEngine.core.gameplay.attributes.holders.interfaces {
	
	/**
	 * Attributes for Objects witch can die or be destroyed by ingame mechanics
	 * @author FernandoRabello
	 */
	public interface IMortalAttributes {
		function get name():String;
		
		function get dead():Boolean;
		
		function death():void;
	}
}