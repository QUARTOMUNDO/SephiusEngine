package SephiusEngine.levelObjects.interfaces 
{
	import SephiusEngine.sounds.system.components.physics.SpriteSoundComponent;
	
	/**
	 * Objects Witch has Sprite Sound Component
	 * @author FernandoRabello
	 */
	public interface ISpriteSoundEmitter {
		function get soundComponent():SpriteSoundComponent;
		
		function createSound():void;
		function destroySound():void;
		
		function addSound():void;
		function removeSound():void;
		
		function get soundAdded():Boolean;
	}
}