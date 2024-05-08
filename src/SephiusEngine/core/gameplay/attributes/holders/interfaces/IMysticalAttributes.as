package SephiusEngine.core.gameplay.attributes.holders.interfaces {
	import SephiusEngine.core.gameplay.attributes.subAttributes.NatureGauge;
	
	/**
	 * Attributes for Objects witch can cast spells.
	 * @author FernandoRabello
	 */
	public interface IMysticalAttributes {
		function get name():String;
		
		function get mysticalEssence():Number
		function set mysticalEssence(value:Number):void;
		
		function get maxMysticalEssence():int
		function set maxMysticalEssence(value:int):void;
		
		function get natureAmplifications():NatureGauge;
		function set natureAmplifications(value:NatureGauge):void;
		
		function get regenerable():Boolean;
		function set regenerable(value:Boolean):void;
		
		function get mysticGain():Number;

		function get restoreEfficiency():Number;
		
		function consumeMysticalEssence(amount:Number):Boolean;
		function restoreMysticalEssence(amount:Number):Boolean;
		
		function absorbNatureAmplification(nature:String, amount:Number):void;
		/** Create a new Nature Amplification NatureAtributes copy from a given one */
		function cloneNatureAmplifications(cloned:NatureGauge = null):NatureGauge;
		
		function regenerate():void;
	}
}