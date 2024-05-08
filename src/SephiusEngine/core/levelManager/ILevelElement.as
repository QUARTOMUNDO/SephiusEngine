package SephiusEngine.core.levelManager 
{
	import SephiusEngine.displayObjects.gameArtContainers.AnimationContainer;
	import SephiusEngine.levelObjects.GameObject;
	import SephiusEngine.levelObjects.GameSprite;
	import nape.geom.Vec2;
	
	/**
	 * Describe a level element witch can be menage by Level Manager, like Areas and Backgrounds
	 * @author FernandoRabello
	 */
	public interface ILevelElement {
		function get region():LevelRegion;
		
		function get globalId():uint;
		
		function get objects():Vector.<GameObject>;
		
		function get sprites():Vector.<GameSprite>;
		
		function get effects():Vector.<AnimationContainer>;
		
		function get otherObjects():Vector.<GameObject>;
		
		function addObject(object:GameObject):void;
		
		function addObjects(objects:Vector.<GameObject>):void;
		
		function removeObject(object:GameObject):void;
		
		function addTexturePack(packName:String):void;
		
		//function get texturePacksUsed():Vector.<String>;
		
		function get statistics():Object;
		function set statistics(value:Object):void;
		
		function get spritesInfo():Vector.<Object>;
		function set spritesInfo(value:Vector.<Object>):void;
		
		function get offset():Vec2;
		function set offset(value:Vec2):void;
	}
}