package SephiusEngine.core.gameplay.attributes.holders.interfaces {
	import SephiusEngine.core.gameplay.attributes.subAttributes.NatureGauge;
	
	/**
	 * Attributes for Objects witch can defend a damage.
	 * @author FernandoRabello
	 */
	public interface IDefenderAttributes {
		function get name():String;
		
		function get defenceResistanceNatures():NatureGauge
		function set defenceResistanceNatures(value:NatureGauge):void;
		
		function get stamina():Number
		function set stamina(value:Number):void;
		
		function get maxStamina():int
		function set maxStamina(value:int):void;
		
		function get staminaBuff():Number
		function set staminaBuff(value:Number):void;
		
		function get staminaGainSpeed():Number
		
		function get staminaGain():Number
		
		function get defending():Boolean;
		function set defending(value:Boolean):void;
		
		function get canDefend():Boolean
		function set canDefend(value:Boolean):void;
		
		function consumeStamina(amount:Number, holdTime:Number = .3):int;
		function restoreStamina(amount:Number):Boolean;
		
		function holdStamina(time:Number = .6):void;
		
		function regenerate():void;
	}
}