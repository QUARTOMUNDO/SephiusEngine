package SephiusEngine.levelObjects.interfaces 
{
	import flash.geom.Rectangle;
	
	/**
	 * Objects witch can be perceived by presences
	 * @author FernandoRabello
	 */
	public interface IPerceptible {
		/** If this object was perceived by a presence object. */
		function get perceived():Boolean;
		function set perceived(value:Boolean):void;
		
		/** Area related with this percepible object */
		function get perceptibleBounds():Rectangle;
		
		/** How many presences perceived this object. */
		function get perceivedCount():uint;
		function set perceivedCount(value:uint):void;
	}
}