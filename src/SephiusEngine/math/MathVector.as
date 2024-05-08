package SephiusEngine.math
{
	public class MathVector
	{
		private var _x:Number;
		private var _y:Number;
		private var _l:* = null;
		private var _a:* = null;
		
		public function MathVector(x:Number=0, y:Number=0)
		{
			this.x = x;
			this.y = y;
		}
		
		public function copy():MathVector
		{
			return new MathVector(x, y);
		}
		
		public function copyFrom(vector:MathVector):void
		{
			this.x = vector.x;
			this.y = vector.y;
			_l = null;
			_a = null;
		}
		
		public function setTo(x:Number = 0, y:Number = 0):void
		{
			this.x = x;
			this.y = y;
		}
		
		public function rotate(angle:Number):void
		{
			var a:Number = angle;
			var ca:Number = Math.cos(a);
			var sa:Number = Math.sin(a);
			var tx:Number = x;
			var ty:Number = y;
			
			x = tx * ca - ty * sa;
			y = tx * sa + ty * ca;
		}
		
		public function scaleEquals(value:Number):void
		{
			x *= value; y *= value;
		}
		
		public function scale(value:Number, result:MathVector = null):MathVector
		{
			if (result) {
				result.x = _x * value;
				result.y = _y * value;
				
				return result;
			}
			
			return new MathVector(_x * value, _y * value);
		}
		
		public function normalize():void 
		{			
			var l:Number = length;
			x /= l;
			y /= l;
		}
		
		public function plusEquals(vector:MathVector):void
		{
			x += vector.x;
			y += vector.y;
		}
		
		public function plus(vector:MathVector, result:MathVector = null):MathVector
		{
			if (result) {
				result.x = _x + vector.x;
				result.y = _y + vector.y;
				
				return result;
			}
			
			return new MathVector(_x + vector.x, _y + vector.y);
		}
		
		public function minusEquals(vector:MathVector):void
		{
			x -= vector.x;
			y -= vector.y;
		}
		
		public function minus(vector:MathVector, result:MathVector = null):MathVector
		{
			if (result) {
				result.x = _x - vector.x;
				result.y = _y - vector.y;
				
				return result;
			}
			
			return new MathVector(_x - vector.x, _y - vector.y);
		}
		
		public function dot(vector:MathVector):Number
		{
			return (_x * vector.x) + (_y * vector.y);
		}
		
		public function get x():Number
		{
			return _x;
		}
		
		public function get y():Number
		{
			return _y;
		}
		
		public function set y(value:Number):void
		{
			if (value != _y)
			{
				_l = null;
				_a = null;
				_y = value;
			}
		}
		
		public function set x(value:Number):void
		{
			if (value != _x)
			{
				_l = null;
				_a = null;
				_x = value;
			}
		}
		
		public function get angle():Number
		{
			if (!_a)
				return _a = Math.atan2(y, x);
			else
				return _a;
		}
		
		public function set angle(value:Number):void
		{
			if (_a && value == _a)
				return;
				
			var l:Number = length;
			var tx:Number = l * Math.cos(value);
			var ty:Number = l * Math.sin(value);
			_x = tx;
			_y = ty;
			
			_l = null;
			_a = value;
		}
		
		public function get length():Number
		{
			if (!_l)
				return _l = Math.sqrt((x * x) + (y * y));
			else
				return _l;
		}
		
		public function set length(value:Number):void
		{
			if (_l && value == _l)
				return;
			this.scaleEquals(value / length);
		}
		
		public function get normal():MathVector
		{
			return new MathVector(-_y, _x);
		}
		
		public function toString():String
		{
			return "[" + _x + ", " + _y + "]";
		}
	}
}