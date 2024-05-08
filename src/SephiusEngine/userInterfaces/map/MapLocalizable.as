package SephiusEngine.userInterfaces.map 
{
	
	/**
	 * Used for objects that can be localizabed in the map
	 * @author Fernando Rabello
	 */
	public interface MapLocalizable {
		function get addedToMap():Boolean;
		function set addedToMap(value:Boolean):void;
		
		function addToMap(updateGameData:Boolean = true):void;
		function removeFromMap():void
	}
}