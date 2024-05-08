package SephiusEngine.levelObjects.interfaces {
	import SephiusEngine.sounds.system.components.physics.PhysicSoundComponent;
	/**
	 * Objects Witch has Physic Sound Component
	 * @author FernandoRabello
	 */
	public interface IPhysicSoundEmitter {
		function get soundComponent():PhysicSoundComponent;
		
		function createSound():void;
		function destroySound():void;
		
		function addSound():void;
		function removeSound():void;
		
		function get soundAdded():Boolean;
	}
}