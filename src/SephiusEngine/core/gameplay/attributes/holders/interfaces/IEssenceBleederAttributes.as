package SephiusEngine.core.gameplay.attributes.holders.interfaces 
{
	import SephiusEngine.core.gameplay.attributes.SubAttributes;
	import SephiusEngine.core.gameplay.attributes.subAttributes.EssenceLootAttributes;
	import tLotDClassic.GameData.Properties.creatureInfos.NatureDrop;
	
	/**
	 * For Attributes witch store bleeding information
	 * @author FernandoRabello
	 */
	public interface IEssenceBleederAttributes {
		function get essenceLoots():Vector.<EssenceLootAttributes>;
		function set essenceLoots(value:Vector.<EssenceLootAttributes>):void;
		
		function get bleedSpeed():Number;
		function set bleedSpeed(value:Number):void;
		
		function get bleeding():Boolean;
		function set bleeding(value:Boolean):void;
		
		function get beingAbsorbed():Boolean;
		function set beingAbsorbed(value:Boolean):void;
		
		function get name():String;
		
		function get enabled():Boolean;
	}
}