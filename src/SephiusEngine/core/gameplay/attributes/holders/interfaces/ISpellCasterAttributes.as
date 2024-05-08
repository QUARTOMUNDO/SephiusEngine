package SephiusEngine.core.gameplay.attributes.holders.interfaces {
	import SephiusEngine.core.gameplay.attributes.subAttributes.NatureGauge;
	
	/**
	 * Attributes for objects witch cast spells
	 * @author Fernando Rabello
	 */
	public interface ISpellCasterAttributes {
		/** Raise spell power for specifics natures */
		function get natureAmplifications():NatureGauge;
		
		function get enabled():Boolean;
		
		/** Scale spell power with efficiency. */
		function get mysticalEfficiency():Number;
		function set mysticalEfficiency(value:Number):void;
		
		/** Position where spell should spawn. Its relative to the origin property */
		function get castPositionX():Number;
		function set castPositionX(value:Number):void;
		
		/** Position where spell should spawn. Its relative to the origin property */
		function get castPositionY():Number;
		function set castPositionY(value:Number):void;
		
		/** Initial Rotation where spell spawn. Its relative to the origin property */
		function get castRotation():Number;
		function set castRotation(value:Number):void;
		
		/** Reference to where spell should spawn. ,
		 ** Could have theses values: caster (caster position), world ({x,y}), target (target position), displayObject(displayObject stage position)
		 * So spawn position will be related with one of these values */
		function get spellOrigin():Object;
		function set spellOrigin(value:Object):void;
		
		/** If true spell should fallow origin. */
		function get spellFollowOrigin():Boolean;
		function set spellFollowOrigin(value:Boolean):void;
		
		/** A spell target. Some spell logics take this into account */
		function get spellTarget():Object;
		function set spellTarget(value:Object):void;
		
		/** Create a new Nature Amplification NatureAtributes copy from a given one */
		function cloneNatureAmplifications(cloned:NatureGauge = null):NatureGauge;
	}
}