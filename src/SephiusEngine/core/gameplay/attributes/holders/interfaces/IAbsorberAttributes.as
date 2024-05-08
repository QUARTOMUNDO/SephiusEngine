package SephiusEngine.core.gameplay.attributes.holders.interfaces 
{
	import flash.geom.Rectangle;
	
	/**
	 * Atributes for objects witch absorbs essence
	 * @author FernandoRabello
	 */
	public interface IAbsorberAttributes {
		function get absorbing():Boolean;
		function set absorbing(value:Boolean):void;
		
		function get canAbsorb():Boolean;
		function set canAbsorb(value:Boolean):void;

		function get absorptionPower():Number;
		function set absorptionPower(value:Number):void;
		
		function get aborptionOffsetX():Number;
		function set aborptionOffsetX(value:Number):void;
		function get aborptionOffsetY():Number;
		function set aborptionOffsetY(value:Number):void;
		
		function absorbDeepEssence(amount:Number, nature:String):void;

		function absorbNatureAmplification(nature:String, amount:Number):void;

		function get bounds():Rectangle;
		
		function get name():String;
		
		function get enabled():Boolean;
	}
}