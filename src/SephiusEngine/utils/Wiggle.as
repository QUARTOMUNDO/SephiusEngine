package SephiusEngine.utils 
{
 
  import flash.display.BitmapData;
  import flash.display.BitmapDataChannel;
  import flash.filters.ColorMatrixFilter;
  import flash.geom.Point;
  import flash.utils.ByteArray;
 
  /**
   * ... This class create a perlin noise in a process of get random values with transition over time. So is possible to create "wiggle" effects. 
   * It can be used for wiggle any number var.
   * @author Thonbo.com
   * 
   */
 
  public class Wiggle extends ByteArray{
 
    public var perlinData:BitmapData;
    public var pixelValue:uint = 0
    public var name:String;
    private var _multiplier:Number = 1
    private var _perlinVelocity:Number;
    private var _roughNess:Number;
    private var _looping:Boolean;
    private var _fractal:Boolean;
    private var _combined:Boolean;
	
    private var newrValue:uint;
    private var newgValue:uint;
    private var newbValue:uint;
    private var newaValue:uint;
	
    private var rValue:Number = 115;
    private var gValue:Number = 115;
    private var bValue:Number = 115;
    private var aValue:Number = 115;
	
    private var lastrValue:uint;
    private var lastgValue:uint;
    private var lastbValue:uint;
    private var lastaValue:uint;
	
    private var _seed:uint
 
    private var contrastFilter:ColorMatrixFilter;
 
	/**
	 * Wiigle make possible to animate values using a "gaussian" type of noise. Making possible some thing like a "wiggle" effect.
	 * When animating using justa a MathRandom code, value jump to one ammout to other so does not make a smooth ramdom animation.
	 * This class create this effects by creating a configurable linear perlin noise, and than "seeing" the color value in a particular position of the perlin strip.
	 * As the perlin noise is a ARGB image, there is possible to animate multiple values at same thime. By defaut is used to animate XYZ position and alpha of a object.
	 * But can be used to animate any type of int/number vars.
	 * @param	perlinVelocity The size of the perlin noise strip. Bigger the values more smooth the animation will be. 
	 * @param	roughNess The contras of the perlin. Bigger the value bigger is the amount of variation the var will have (in case of a motion, bigger motion).
	 * @param	fractal Create a more complex noise.
	 * @param	looping Make the end of the perlin strip to be equal to it´s begining. This make possible a seamless looping animation.
	 * @param	combined This make the perlin to be in grayscale beside colored. Make better when animation only 1 var. But when animation multiple vars (XYZA) all will have same values.
	 */
    public function Wiggle(perlinVelocity:Number = 100, roughNess:Number = 2, fractal:Boolean = true, looping:Boolean = true, combined:Boolean = false) {
      _perlinVelocity = perlinVelocity
      _roughNess = roughNess
      _seed = uint(Math.random() * 1000)
      _looping = looping
      _fractal = fractal
      _combined = combined
      perlinData = new BitmapData(2880, 1, false, 0x808080);
      contrastFilter = new ColorMatrixFilter()
 
      initPattern()
 
      position = 0;
    }
 
    private function initPattern():void {
      perlinData.perlinNoise(_perlinVelocity, .1, _roughNess, _seed, _looping, _fractal, BitmapDataChannel.RED | BitmapDataChannel.BLUE | BitmapDataChannel.GREEN | BitmapDataChannel.ALPHA, _combined, null);
      contrastFilter.matrix = [2.0348570346832275,-0.6124469041824341,-0.08241000026464462,0,-55.09000015258789,-0.31014299392700195,1.7325528860092163,-0.08241000026464462,0,-55.08999252319336,-0.31014299392700195,-0.6124469041824341,2.262589931488037,0,-55.089996337890625,0,0,0,1,0]
      perlinData.applyFilter(perlinData, perlinData.rect, new Point(0,0), contrastFilter)
      writeBytes(perlinData.getPixels(perlinData.rect))
    }
 
    public function newValues():void {
		if (this.position+4 >= this.length) {
		this.position = 0
		}
		
		//Interpolation code. RGBA values has only 255 values by channel(axis). So we need more precision. This code is like a ease, but serve as a interpolation so values can be lot of more precise.
		//This result in a smoother motion when multiplier is big.
		var diffaValue:Number = newaValue - lastaValue;
		var diffrValue:Number = newrValue - lastrValue;
		var diffgValue:Number = newgValue - lastgValue;
		var diffbValue:Number = newbValue - lastbValue;
		
		aValue += diffaValue * (0.02);
		rValue += diffrValue * (0.02);
		gValue += diffgValue * (0.02);
		bValue += diffbValue * (0.02);
		
		lastaValue = aValue;
		lastrValue = rValue;
		lastgValue = gValue;
		lastbValue = bValue;
	
		newaValue = pixelValue >> 32 & 0xFF;
		newrValue = pixelValue >> 16 & 0xFF;
		newgValue = pixelValue >> 8 & 0xFF;
		newbValue = pixelValue & 0xFF;
		
		pixelValue = this.readUnsignedInt();
    }
 
    public function get xValue():Number{
      return rValue * _multiplier;
    }
    public function get yValue():Number{
      return gValue * _multiplier;
    }
    public function get zValue():Number{
      return bValue * _multiplier;
    }
    public function get wValue():Number{
      return aValue * _multiplier;
    }
    public function get pointValue():Point{
      return new Point(rValue * _multiplier, gValue * _multiplier);
    }
 
    public function get perlinVelocity():Number { return _perlinVelocity; }
 
    public function set perlinVelocity(value:Number):void
    {
      _perlinVelocity = value;
      initPattern();
    }
 
    public function get roughNess():Number { return _roughNess; }
 
    public function set roughNess(value:Number):void
    {
      _roughNess = value;
      initPattern();
    }
 
    public function get looping():Boolean { return _looping; }
 
    public function set looping(value:Boolean):void
    {
      _looping = value;
      initPattern();
    }
 
    public function get fractal():Boolean { return _fractal; }
 
    public function set fractal(value:Boolean):void
    {
      _fractal = value;
      initPattern();
    }
 
    public function get combined():Boolean { return _combined; }
 
    public function set combined(value:Boolean):void
    {
      _combined = value;
      initPattern();
    }
 
    public function get multiplier():Number { return _multiplier; }
 
    public function set multiplier(value:Number):void
    {
      _multiplier = value;
    }  
  }
}