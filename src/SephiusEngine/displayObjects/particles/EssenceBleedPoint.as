package SephiusEngine.displayObjects.particles {
	import SephiusEngine.core.gameplay.attributes.AttributeHolder;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.IEssenceBleederAttributes;
	import SephiusEngine.levelObjects.interfaces.IEssenceBleeder;
    
	
	/**
     * A Point in space that can bleed essence
	 */
	public class EssenceBleedPoint implements IEssenceBleeder {
        public function get bleederAttributes():IEssenceBleederAttributes{ return null; }

        public function get rotationRad():Number{return 0;}

        public function get name():String{return "EssenceBleedPoint";}

        public function get x():Number { return _x; }
        public function set x(value:Number):void{ _x = value; }
    	private var _x:Number = 0;

        public function get y():Number{ return _y; }
        public function set y(value:Number):void{ _y = value; }
    	private var _y:Number = 0;

        public function get dead():Boolean{return false;}
        public function get attributes():AttributeHolder{ return null; }
        public function get inverted():Boolean { return false; }
        public function get enabled():Boolean{ return true; }

        public function get bleedOffsetX():Number { return _bleedOffsetX; }
        public function set bleedOffsetX(value:Number):void{ _bleedOffsetX = value; }
    	private var _bleedOffsetX:Number = 0;

        public function get bleedOffsetY():Number { return _bleedOffsetY; }
        public function set bleedOffsetY(value:Number):void{ _bleedOffsetY = value; }
    	private var _bleedOffsetY:Number = 0;
    }
}