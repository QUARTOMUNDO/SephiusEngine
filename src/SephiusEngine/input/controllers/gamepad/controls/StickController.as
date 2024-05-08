package SephiusEngine.input.controllers.gamepad.controls{
	import SephiusEngine.math.MathVector;
	import SephiusEngine.input.InputController;
	import SephiusEngine.input.controllers.gamepad.Gamepad;
	
	public class StickController extends InputController implements Icontrol{
		protected var _gamePad:Gamepad;
		
		protected var _hAxis:String;
		protected var _vAxis:String;
		
		protected var _prevRight:Number = 0;
		protected var _prevLeft:Number = 0;
		protected var _prevUp:Number = 0;
		protected var _prevDown:Number = 0;
		
		protected var _vec:MathVector;
		
		public var upAction:Array = [];
		public var downAction:Array = [];
		public var leftAction:Array = [];
		public var rightAction:Array = [];
		
		protected var _downActive:Boolean = false;
		protected var _upActive:Boolean = false;
		protected var _leftActive:Boolean = false;
		protected var _rightActive:Boolean = false;
		protected var _stickActive:Boolean = false;
		
		public var invertX:Boolean;
		public var invertY:Boolean;
		public var threshold:Number = 0.1;
		public var precision:int = 100;
		public var digital:Boolean = false;
		
		/**
		 * StickController is an abstraction of the stick controls of a gamepad. This InputController will see its axis values updated
		 * via its corresponding gamepad object and send his own actions to the Input system.
		 * 
		 * It should not be instantiated manually.
		 * 
		 * @param	name
		 * @param	hAxis left to right
		 * @param	vAxis up to down
		 * @param	up action name
		 * @param	right action name
		 * @param	down action name
		 * @param	left action name
		 * @param	invertX
		 * @param	invertY
		 */
		public function StickController(name:String, parentGamePad:Gamepad,hAxis:String,vAxis:String, up:String = null, right:String = null, down:String = null, left:String = null, invertX:Boolean = false, invertY:Boolean = false){
			super(name);
			_gamePad = parentGamePad;
			
			if(upAction.indexOf(up) == -1)
				upAction.push(up);
			if(downAction.indexOf(down) == -1)	
				downAction.push(down);
			if(leftAction.indexOf(left) == -1)
				leftAction.push(left);
			if(rightAction.indexOf(right) == -1)
				rightAction.push(right);
			
			_hAxis = hAxis;
			_vAxis = vAxis;
			this.invertX = invertX;
			this.invertY = invertY;
			_vec = new MathVector();
		}
		
		public function hasControl(id:String):Boolean{
			return (id == _hAxis || id == _vAxis);
		}
		
		public function updateControl(control:String, value:Number):void{
			value = ((value * precision) >> 0) / precision;
			
			value = (value <= threshold && value >= -threshold) ? 0 : value;
			
			var action:String;
			
			if (control == _vAxis){
				_prevUp = up;
				_prevDown = down;
				
				_vec.y = (digital ?  value >> 0 : value) * (invertY ? -1 : 1);
				
				if (downAction && _prevDown != down){
						if (_downActive && (down <= 0)){
							for each(action in downAction)
								triggerOFF(action, 0, null, _gamePad.defaultChannel);
							_downActive = false;
						}
						if (down > .5){
							for each(action in downAction)
								triggerCHANGE(action, down, null, _gamePad.defaultChannel);
							_downActive = true;
						}
				}
				
				if (upAction && _prevUp != up){
						if (_upActive && (up <= 0)){
							for each(action in upAction)
								triggerOFF(action, 0, null, _gamePad.defaultChannel);
							_upActive = false;
						}
						if (up > .5){
							for each(action in upAction)
								triggerCHANGE(action, up, null, _gamePad.defaultChannel);
							_upActive = true;
							
						}
				}
			}
			else if (control == _hAxis){
				_prevLeft = left;
				_prevRight = right;
				
				_vec.x = (digital ?  value >> 0 : value) * (invertX ? -1 : 1);
				
				if (leftAction && _prevLeft != left){
						if (_leftActive && left <= 0){
							for each(action in leftAction)
								triggerOFF(action, 0, null, _gamePad.defaultChannel);
							_leftActive = false;
						}
						if (left > .1){
							for each(action in leftAction)
								triggerCHANGE(action, left, null, _gamePad.defaultChannel);
							_leftActive = true;
						}
				}
				
				if (rightAction && _prevRight != right){
						if (_rightActive && right <= 0){
							for each(action in rightAction)
								triggerOFF(action, 0, null, _gamePad.defaultChannel);
							_rightActive = false;
						}
						if (right > .1){
							for each(action in rightAction)
								triggerCHANGE(action, right, null, _gamePad.defaultChannel);
							_rightActive = true;
						}
				}
			}
			
			stickActive = _vec.length == 0 ? false : true;
		}
		
		public function set stickActive(val:Boolean):void{
			if (val == _stickActive)
				return;
			else{
				if (val)
					triggerCHANGE(name, 1, null, defaultChannel);
				else
					triggerOFF(name, 1, null, defaultChannel);
				
				_stickActive = val;
			}
		}
		
		public function get y():Number{	return _vec.y;}
		public function get x():Number{return _vec.x;}
		
		public function get up():Number{return -_vec.y;}
		
		public function get down():Number{return _vec.y;}
		
		public function get left():Number{return -_vec.x;}
		
		public function get right():Number{return _vec.x;}
		
		public function get length():Number{return _vec.length;}
		
		public function get angle():Number{return _vec.angle;}
		
		public function get hAxis():String{return _hAxis;}
		
		public function get vAxis():String{return _vAxis;}
		
		public function get gamePad():Gamepad{return _gamePad;}
		
		override public function destroy():void{
			_input.stopActionsOf(this);
			super.destroy();
			_vec = null;
		}
	}
}