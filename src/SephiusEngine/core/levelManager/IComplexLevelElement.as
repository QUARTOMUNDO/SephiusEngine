package SephiusEngine.core.levelManager {
	import SephiusEngine.displayObjects.LightSprite;
	import tLotDClassic.gameObjects.barriers.Barriers;
	import tLotDClassic.gameObjects.characters.Spawner;
	import SephiusEngine.levelObjects.interfaces.IDamagerObject;
	import tLotDClassic.gameObjects.pools.Pool;
	import tLotDClassic.gameObjects.rewards.Reward;
	import SephiusEngine.levelObjects.specialObjects.LevelCollision;
	
	/**
	 * Describe a level element witch can have multiple types of objects like collisions and effects
	 * @author Fernando Rabello
	 */
	public interface IComplexLevelElement {
		function get collisions():Vector.<LevelCollision>
		
		function get lights():Vector.<LightSprite>
		
		function get rewards():Vector.<Reward>
		
		function get damagers():Vector.<IDamagerObject>
		
		function get pools():Vector.<Pool>
		
		function get spawners():Vector.<Spawner>
		
		function get barriers():Vector.<Barriers>
	}
}