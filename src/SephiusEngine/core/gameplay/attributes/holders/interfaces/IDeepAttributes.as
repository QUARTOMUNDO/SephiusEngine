package SephiusEngine.core.gameplay.attributes.holders.interfaces {
	
	/**
	 * Attributes for Objects witch can upgrade its attributes bu leveling up.
	 * @author FernandoRabello
	 */
	public interface IDeepAttributes {
		function get name():String;
		
		function get level():int;
		function set level(value:int):void;
		
		function get essencika():Number;
		function set essencika(value:Number):void;
		
		function get deepEssence():Number;
		function set deepEssence(value:Number):void;
		
		function get maxDeepEssence():int;
		function set maxDeepEssence(value:int):void;
		
		function levelUp():void;
		
		function consumeDeepEssence(amount:Number):Boolean;
		function absorbDeepEssence(amount:Number, nature:String):void;
	}
}