package SephiusEngine.core.gameplay.attributes.holders.interfaces 
{
	import flash.geom.Rectangle;
	
	/**
	 * Atributes for objects witch absorbs essence
	 * @author FernandoRabello
	 */
	public interface IAttractorAttributes {
		function get attracting():Boolean;
		function set attracting(value:Boolean):void;
		
		function get canAttract():Boolean;
		function set canAttract(value:Boolean):void;
		
		function get attractionPower():Number;
		function set attractionPower(value:Number):void;
		
		function get attractionOffsetX():Number;
		function set attractionOffsetX(value:Number):void;
		function get attractionOffsetY():Number;
		function set attractionOffsetY(value:Number):void;
		
		function get name():String;
		
		function get enabled():Boolean;
	}
}