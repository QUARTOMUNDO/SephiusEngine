package SephiusEngine.core.gameplay.attributes.holders.interfaces {
	import SephiusEngine.core.effects.ObjectEffects;
	import SephiusEngine.core.gameplay.status.interfaces.IStatus;
	
	/**
	 * Interface for objects witch can receive status conditions
	 * @author FernandoRabello
	 */
	public interface IStatusAttributes {
		function get name():String;
		
		function get status():IStatus;
		function get effects():ObjectEffects;
		
		function get corruptionImmunity():Vector.<String>;
		function set corruptionImmunity(valuer:Vector.<String>):void;
		
		function get corruptionImmunityBuff():Vector.<String>;
		function set corruptionImmunityBuff(valuer:Vector.<String>):void;
	}
}