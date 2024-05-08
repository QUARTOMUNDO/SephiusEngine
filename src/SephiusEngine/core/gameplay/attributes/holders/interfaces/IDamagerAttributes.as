package SephiusEngine.core.gameplay.attributes.holders.interfaces 
{
	import SephiusEngine.core.gameplay.attributes.subAttributes.DamagerAttibutes;
	import SephiusEngine.levelObjects.interfaces.IDamagerObject;
	import SephiusEngine.levelObjects.interfaces.ISufferObject;
	
	/**
	 * Attributes for objects witch can cause damage
	 * @author FernandoRabello
	 */
	public interface IDamagerAttributes {
		function get name():String;
		
		function get damagerParent():IDamagerObject;
		
		function get enabled():Boolean;
		function set enabled(valuer:Boolean):void;
		
		function get collisionEnabled():Boolean;
		function set collisionEnabled(valuer:Boolean):void;
		
		function get damagerAttributes():Vector.<DamagerAttibutes>;
		function set damagerAttributes(value:Vector.<DamagerAttibutes>):void;
		
		function get efficiency():Number;
		
		function get avertSuffers():Vector.<ISufferObject>;
		function set avertSuffers(value:Vector.<ISufferObject>):void;

		function get nerfedSuffers():Vector.<ISufferObject>;
		function set nerfedSuffers(value:Vector.<ISufferObject>):void;

		function get efficiencyBuff():Number;
		function set efficiencyBuff(value:Number):void;
		
		function shouldCorrupt(suffer:Object):Boolean;
		
		function updateDamagers():void;
	}
}