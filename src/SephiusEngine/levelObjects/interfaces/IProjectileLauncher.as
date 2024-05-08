package SephiusEngine.levelObjects.interfaces {

	import tLotDClassic.GameData.Properties.objectsInfos.GameObjectGroups;
	import nape.geom.Vec2;

	/**
	 * Objects Witch has Physic Sound Component
	 * @author FernandoRabello
	 */
	public interface IProjectileLauncher {
        function get targetGroups():Vector.<GameObjectGroups>;
        function get targetGroupFlag():uint;

        function get avertGroups():Vector.<GameObjectGroups>;
        function get avertGroupFlag():uint;

        function get nerfGroups():Vector.<GameObjectGroups>;
        function get nerfGroupFlag():uint;

        function get launchDirection():Number;
        function set launchDirection(value:Number):void;

        function get inverted():Boolean;
        function get velocity():Vec2;
        function get name():String;
    }
}
