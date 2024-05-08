package SephiusEngine.core.gameplay.status.interfaces {
	import SephiusEngine.core.gameplay.attributes.subAttributes.StatusGauge;
	import tLotDClassic.GameData.Properties.StatusProperties;
	
	/**
	 * Define Base method for status applied on a object
	 * @author Fernando [Sephius] Rabello
	 */
	public interface IStatus {
		function clearNoNeutralStatus():void;
		function cleanAllStatus():void;
		
		function get statusResistances():StatusGauge;
		function set statusResistances(value:StatusGauge):void;
				
		function riseStatus(statusProperty:StatusProperties, corruptionPower:Number):void
		function riseCorruption(statusProperty:StatusProperties, curruptionPower:Number):void;
		
		function applyStatus(statusProperty:StatusProperties, on:Boolean, effectsOn:Boolean = true):void;
		
		function update(timeDelta:Number):void;
		
		function get activatedStatus():Vector.<StatusProperties>;
		
		function get times():StatusGauge;
		function get damageAmountRemaining():StatusGauge;
		
		function get statusConditions():StatusGauge;
		
		function dispose():void;
	}
}