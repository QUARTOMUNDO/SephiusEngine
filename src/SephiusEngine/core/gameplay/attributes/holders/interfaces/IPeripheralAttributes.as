package SephiusEngine.core.gameplay.attributes.holders.interfaces {
	
	/**
	 * Attributes for Objects witch looses peripheral essence.
	 * @author FernandoRabello
	 */
	public interface IPeripheralAttributes {
		function get name():String;
		
		function get peripheralEssence():Number;
		function set peripheralEssence(value:Number):void;
		
		function get maxPeripheralEssence():int;
		function set maxPeripheralEssence(value:int):void;
		
		function get weakDamagePercent():Number;
		function set weakDamagePercent(value:Number):void;
		
		function get harmfullImpact():Number;
		function set harmfullImpact(value:Number):void;
		
		function get harmfullImpactBuffer():Number;
		function set harmfullImpactBuffer(value:Number):void;
		
		function get regenerable():Boolean;
		function set regenerable(value:Boolean):void;
		
		function get degenerable():Boolean;
		function set degenerable(value:Boolean):void;
		
		function get peripheralGain():Number;

		function get restoreEfficiency():Number;
		
		function consumePeripheralEssence(amount:Number, showOnUI:Boolean = true):int;
		function restorePeripheralEssence(amount:Number):Boolean;
		
		function regenerate():void;
		function degenerate():void;
	}
}