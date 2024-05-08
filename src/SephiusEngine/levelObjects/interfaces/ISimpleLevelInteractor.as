package SephiusEngine.levelObjects.interfaces 
{
	import SephiusEngine.levelObjects.specialObjects.LevelCollision;
	import nape.dynamics.CollisionArbiter;
	import nape.shape.Shape;
	
	/**
	 * Simple interactions with level collisions
	 * @author FernandoRabello
	 */
	public interface ISimpleLevelInteractor {
		function onSimpleGroundTouch(levelCollision:LevelCollision, platformGroup:int):void;
	}
}