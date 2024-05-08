package SephiusEngine.core.gameplay.attributes.holders.interfaces {
	import SephiusEngine.core.gameplay.attributes.subAttributes.NatureGauge;
	import SephiusEngine.core.gameplay.attributes.subAttributes.SufferAttributes;
	import SephiusEngine.levelObjects.interfaces.ISufferObject;
	
	/**
	 * Attributes for objects witch can take damage
	 * @author FernandoRabello
	 */
	public interface ISufferAttributes {
		function get name():String;
		
		function get sufferParent():ISufferObject;
		
		function get enabled():Boolean;
		function set enabled(valuer:Boolean):void;
		
		function get collisionEnabled():Boolean;
		function set collisionEnabled(valuer:Boolean):void;
		
		function get sufferAttributes():Vector.<SufferAttributes>;
		function set sufferAttributes(value:Vector.<SufferAttributes>):void;
		
		function get mainSuffer():SufferAttributes;
		
		function get natureImmunity():NatureGauge;
		function set natureImmunity(value:NatureGauge):void;
		
		function get efficiency():Number;
		
		function get efficiencyBuff():Number;
		function set efficiencyBuff(value:Number):void;
		
		function get damageTakenConstrainedByTime():Boolean;
		function set damageTakenConstrainedByTime(value:Boolean):void;
		
		function updateSuffers():void;
	}
}