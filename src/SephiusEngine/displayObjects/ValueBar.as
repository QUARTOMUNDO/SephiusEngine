package SephiusEngine.displayObjects 
{
	import flash.geom.Point;

	import starling.display.Image;
	import starling.textures.Texture;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * Used to show bars like peripheral essence, enemy/boss essence and etc.
	 * @author Fernando Rabello
	 */
	public class ValueBar extends Image {

		public var alighMode:String = "topLeft";
		
		public function ValueBar(texture:Texture, max:Number, min:Number, alighMode:String="topLeft") {
			super(texture);

			this.alighMode = alighMode;
			if(alighMode == "topLeft"){
				pivotX -= texture.frame ? texture.frame.x : 0;
				x -= texture.frame ? texture.frame.x : 0;
			}
			else{
				alignPivot(HAlign.LEFT, VAlign.CENTER);
				x = -width * 0.5 * size;
			}

			//this.max = max;
			//this.min = min;
		}
		
		public var barVelocity:Number = .03;
		
		public function get texRatio():Number { return _ratio; }
		private var _texRatio:Number = 1;
		
		public var max:Number = 1;
		public var min:Number = 0;
		
		/** This state the bar will react. Ex. 50% means half of the bar */
		public function get targetRatio():Number { return (_targetRatio * max) + min; }
		public function set targetRatio(value:Number):void {
			_targetRatio = value;
		}
		private var _targetRatio:Number = 1;
		
		/** use this obtion to chance the actual scale of the bar. As the ratio change that automacly this property retain the ability to scale this. */
		public function get size():Number { return _size; }
		public function set size(value:Number):void {
			_size = value;

			if(alighMode == "topLeft")
				x -= texture.frame ? texture.frame.x : 0;
			else
				x = -width * 0.5 * size;
		}
		private var _size:Number = 1;
		
		/** The current state of the bar. 50% means half of the bar */
		public function get ratio():Number { return _ratio; }
		private function setRatio(value:Number):void {
			_ratio = value;
		}
		private var _ratio:Number = 1;
		
		private var ratioPoint1:Point = new Point(0, 0);
		private var ratioPoint3:Point = new Point(0, 1.0);
		
		private var valueDiff:Number;
		
		public function update():void {
			valueDiff = targetRatio - _ratio;
			setRatio(_ratio + (valueDiff * barVelocity));
			
			scaleX = _ratio * _texRatio * _size;
			scaleY = _size;
			
			ratioPoint1.x = _ratio;
			ratioPoint3.x = _ratio;
			
			setTexCoords(1, ratioPoint1);
			setTexCoords(3, ratioPoint3);
		}
		
		public function reset():void {
			valueDiff = targetRatio - _ratio;
			setRatio(_ratio + (valueDiff));
			
			scaleX = _ratio * _texRatio * _size;
			scaleY = _size;
			
			ratioPoint1.x = _ratio;
			ratioPoint3.x = _ratio;
			
			setTexCoords(1, ratioPoint1);
			setTexCoords(3, ratioPoint3);
		}
	}
}