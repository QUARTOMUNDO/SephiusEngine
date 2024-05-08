package SephiusEngine.core 
{
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.math.MathVector;
	import SephiusEngine.core.levelManager.CameraControl;
	import SephiusEngine.core.levelManager.Presence;
	import SephiusEngine.levelObjects.interfaces.ISpriteView;
	import SephiusEngine.displayObjects.configs.ViewData;
	import SephiusEngine.utils.pools.PresencePool;
	import SephiusEngine.utils.Wiggle;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import nape.geom.Vec2;
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.display.DisplayObject;
	import starling.extensions.brinkbit.fullscreenscreenextension.FullScreenExtension;
	import SephiusEngine.core.levelManager.GameOptions;
	
	/**
	 * Virtual Camera used to determine position of object visual representations
	 * It supports several advanced functions like rotation, deph, shakeness, randomness, zoom.
	 * All camera related properties gets they values changed with a easing behavior.
	 * @author Fernando Rabello
	 */
	public class GameCamera {
		/** the actual zoon, not the target zoon */
		public var realZoom:Number = 1;
		/** the actual z, not the target z */
		public var realZ:Number = 1;
		/** the actual Rotation, not the target Rotation, not */
		public var realRotation:Number = 0;
		/** the actual Offset, not the target Offset */
		public var realOffset:MathVector = new MathVector(0, 0);
		/** the actual Position, not the target Position */
		public var realPosition:MathVector = new MathVector(0, 0);
		/** the Position on last frame, not the target Position */
		public var lastRealPosition:MathVector = new MathVector(0, 0);
		
		/** A factor related with how deep objects are related with camera */
		public var deepFactor:Number = 1;
		
		/** should we restrict zoom to bounds?*/
		public var restrictZoom:Boolean = false;
		/** Is the camera allowed to Zoom?*/
		protected var _allowZoom:Boolean = false;
		/** Is the camera allowed to move in z axis?*/
		protected var _allowZMotion:Boolean = false;
		/** Is the camera allowed to Rotate?*/
		protected var _allowRotation:Boolean = false;
		/**The camera position to be set manually if target is not set.*/
		protected var _manualPosition:Point = new Point();
		
		/** targeted camera position */
		public var position:Point = new Point();
		/** the targeted rotation value.*/
		public var rotation:Number = 0;
		/** the targeted zoom value.*/
		public var zoom:Number = 1;
		/** the targeted z value.*/
		public var z:Number = 1;
		
		/**the ease factor for zoom*/
		public var zoomEasing:Number = 0.030;
		/**the ease factor for z*/
		public var zEasing:Number = 0.030;
		/**the ease factor for rotation*/
		public var rotationEasing:Number = 0.030;
		/**the ease factor for zoom*/
		public var offsetEasing:Number = 0.030;
		/**Ajust offset in order to make target in the center of the screen.*/
		public var centralizeTarget:Boolean = true;
		
		/**The distance from the top-left corner of the screen that the camera should offset the target. */
		public var offset:MathVector = new MathVector();
		/**A value between 0 and 1 that specifies the speed at which the camera catches up to the target.
		 * 0 makes the camera not follow the target at all and 1 makes the camera follow the target exactly. */
		public var easing:MathVector = new MathVector(0.30, 0.03);
		/**A rectangle specifying the minimum and maximum area that the camera is allowed to follow the target in. */
		public var bounds:Rectangle;
		/**The width of the visible game screen. This will usually be the same as your stage width unless your game has a border.*/
		public var cameraLensWidth:Number;
		/**The height of the visible game screen. This will usually be the same as your stage width unless your game has a border.*/
		public var cameraLensHeight:Number;
		
		/**the _camProxy object is used as a container to hold the data to be applied to the _viewroot. */
		public var camProxy:Object = { x: 0, y: 0, z:1, offsetX: 0, offsetY: 0, scale: 1, rotation: 0 };
		
		/** Reference to Camera Control Class with deal with some player control over the camera and motion adjustment.*/
		public var cameraControl:CameraControl;
		
		/** ----------------------------------------- */
		/** -----------   Helpers    ---------------- */
		/** ----------------------------------------- */
		private var h_diffRot:Number;
		private var h_velocityRot:Number;
		private var h_diffZoom:Number;
		private var h_velocityZoom:Number;
		private var h_diffZ:Number;
		private var h_velocityZ:Number;
		private var h_diffX:Number;
		private var h_diffY:Number;
		private var h_velocityX:Number;
		private var h_velocityY:Number;
		private var h_diffOffset:MathVector;
		private var h_velocityOffset:MathVector;
		
		/**
		 * Wiigle class can wiggle objects to make effects like shake or random movement.
		 * Here is used to create a random smooth movement for câmera when player are not moving.
		 */
		public var motionWiggler:Wiggle;
		public var shakeWiggler:Wiggle;
		
		protected var _viewRoot:DisplayObject;
		
		/**Store some informations about camera presence on LevelManager */
		public var presence:Presence;
		private var screenSize:Number = 1;
		public function GameCamera(cameraLensWidth:Number, cameraLensHeight:Number, viewRoot:DisplayObject) {
			this.cameraLensWidth = cameraLensWidth;
			this.cameraLensHeight = cameraLensHeight;	
			
			motionWiggler = new Wiggle(200, 2, true, true, false); 
			shakeWiggler = new Wiggle(5, 5, true, true, false); 
			
			_viewRoot = viewRoot;
			
			cameraControl = new CameraControl(this);
			
			presence = PresencePool.getObject(this, true, true, true);
			presence.bounds.width = FullScreenExtension.screenWidth * 2 * screenSize;
			presence.bounds.height = FullScreenExtension.screenHeight * 2 * screenSize;
			Presence.PRESENCES_IN_USE.push(presence);
		}
		
		public var disableUpdate:Boolean = false;
		/** Update the camera.  */
		public function update(timeDelta:Number):void {
			if(disableUpdate)
				return;

			if(cameraControl)
				cameraControl.update(timeDelta);
			
			if (motionWiggler && !disableRandomness && !(randomnessIntensity.x == 0 && randomnessIntensity.y == 0 && randomnessIntensity.z == 0 && randomnessIntensity.rotation == 0)) {
				motionWiggler.newValues();
			}
			
			if (shakeWiggler && !disableShakeness && !(shakeIntensity.x == 0 && shakeIntensity.y == 0 && shakeIntensity.z == 0 && shakeIntensity.rotation == 0)) {
				shakeWiggler.newValues();
			}
			
			if (_allowRotation) {
				h_diffRot = rotation - camProxy.rotation;
				h_velocityRot = h_diffRot * rotationEasing;
				realRotation += h_velocityRot;
				camProxy.rotation += h_velocityRot;
			}
			
			if (_allowZoom) {
				h_diffZoom = zoom - camProxy.scale;
				h_velocityZoom = h_diffZoom * zoomEasing;
				camProxy.scale += h_velocityZoom;
				realZoom += h_velocityZoom;
			}
			
			if (_allowZMotion) {
				h_diffZ = z - camProxy.z;
				h_velocityZ = h_diffZ * zEasing;
				camProxy.z += h_velocityZ;
				realZ += h_velocityZ;
			}
			
			h_diffX = 0;
			h_diffY = 0;
			var nOfTargets:uint = 0;
			
			if (_useManualPosition) {
				h_diffX += _manualPosition.x - camProxy.x;
				h_diffY += _manualPosition.y - camProxy.y;
				nOfTargets++;
			}
			
			else {
				if (_mainTarget) {
					h_diffX += _mainTarget.x - camProxy.x;
					h_diffY += _mainTarget.y - camProxy.y;
					nOfTargets++;
				}
				
				var cTarget:ISpriteView;
				for each(cTarget in _otherTargets) {
					if(cTarget != _mainTarget ){
						h_diffX += cTarget.x - camProxy.x;
						h_diffY += cTarget.y - camProxy.y;
						nOfTargets++;
					}
				}
			}
			
			h_velocityX = (h_diffX / nOfTargets) * easing.x;
			h_velocityY = (h_diffY / nOfTargets) * easing.y;
			camProxy.x += h_velocityX;
			camProxy.y += h_velocityY;
			
			// Ease camera offset
			h_diffOffset = new MathVector((offset.x - camProxy.offsetX), (offset.y - camProxy.offsetY));
			h_velocityOffset = new MathVector ((h_diffOffset.x * offsetEasing), (h_diffOffset.y * offsetEasing));
			camProxy.offsetX += h_velocityOffset.x;
			camProxy.offsetY += h_velocityOffset.y;
			realOffset.x = camProxy.offsetX;
			realOffset.y = camProxy.offsetY;
			
			lastRealPosition.x = realPosition.x;
			lastRealPosition.y = realPosition.y;
			
			realPosition.x = camProxy.x - realOffset.x;
			realPosition.y = camProxy.y - realOffset.y;
			
			//Wiggle : Original Value(xyzr) - Half Wiggle Max Value (Adjusted) + Wiggle Current Value;
			realPosition.x = realPosition.x + randomness.x + shakeness.x;
			realPosition.y = realPosition.y + randomness.y + shakeness.y;
			
			if(_allowZoom)
				realZoom = camProxy.scale + randomness.zoom + shakeness.zoom;
			
			if(_allowZMotion)
				realZ = camProxy.z + randomness.z + shakeness.z;
			
			if(_allowRotation)
				realRotation = camProxy.rotation + randomness.rotation + shakeness.rotation;
			
			_velocityX = (realPosition.x - lastRealPosition.x) / timeDelta;
			_velocityY = (realPosition.y - lastRealPosition.y) / timeDelta;
			
			deepFactor = Math.pow(5, (realZ - 1));
			
			presence.update(realPosition.x, realPosition.y);
		}
		
		/** Reset camera real values */
		public function reset():void {
			camProxy.offsetX = offset.x;
			camProxy.offsetY = offset.y;
			
			if (_useManualPosition) {
				camProxy.x = manualPosition.x;
				camProxy.y = manualPosition.y;
			}
			else {
				var nOfTargets:int = 0;
				var posX:Number = 0;
				var posY:Number = 0;
				var cTarget:ISpriteView;
				
				if (_mainTarget) {	
					posX = mainTarget.x;
					posY = mainTarget.y;
					nOfTargets++;
				}
				
				for each(cTarget in _otherTargets) {
					if(cTarget != _mainTarget ){
						posX += cTarget.x;
						posY += cTarget.y;
						nOfTargets++;
					}
				}
				
				camProxy.x = posX / nOfTargets;
				camProxy.y = posY / nOfTargets;
			}
			
			camProxy.rotation = rotation;
			camProxy.zoom = zoom;
			camProxy.z = z;
			
			realRotation = camProxy.rotation;
			realZ = camProxy.z;
			realZoom = camProxy.zoom;
			realOffset.x = camProxy.offsetX;
			realOffset.y = camProxy.offsetY;
			
			realPosition.x = camProxy.x + camProxy.offsetX;
			realPosition.y = camProxy.y + camProxy.offsetY;
		}
		
		/**
		 * This is a non-critical helper function that allows you to quickly set all the available camera properties in one place. 
		 * @param target The thing that the camera should follow.
		 * @param offset The distance from the upper-left corner that you want the camera to be offset from the target.
		 * @param bounds The rectangular bounds that the camera should not extend beyond.
		 * @param easing The x and y percentage of distance that the camera will travel toward the target per tick. Lower numbers are slower. The number should not go beyond 1.
		 * @param cameraLens The width and height of the visible game screen. Default is the same as your stage width and height.
		 * @return The Instance GameCamera .
		 */		
		public function setUp(target:ISpriteView = null, offset:MathVector = null, bounds:Rectangle = null, easing:MathVector = null, cameraLens:MathVector = null):GameCamera{
			if (bounds)
				this.bounds = bounds;
			if (easing)
				this.easing = easing;
			if (cameraLens){
				cameraLensWidth = cameraLens.x;
				cameraLensHeight = cameraLens.y;
			}
			if (offset)
				this.offset.x = offset.x;
				this.offset.y = offset.y;
			if (target)
				this.mainTarget = target;
			return this;
		}
		
		/** Multiply current zoom by a specified factor */
		public function zooming(factor:Number):void {
			if (_allowZoom)
				zoom *= factor;
			else
				trace((this+" is not allowed to zoom. please set allowZoom to true."));
		}
		
		/** Set zoom from original value to a new value */
		public function setZoom(factor:Number):void {
			if (_allowZoom)
				zoom = factor;
			else
				trace((this+" is not allowed to zoom. please set allowZoom to true."));
		}
		
		/** Multiply z position by a specified factor */
		public function zMotion(factor:Number):void {
			//trace("camera.z " + z + " camera.realZ " + realZ)
			if (_allowZMotion)
				z *= factor;
			else
				trace((this+" is not allowed to z motion. please set allowZMotion to true."));
		}
		
		/** Set z position from original value to a new value */
		public function setZ(factor:Number):void {
			//trace("camera.z " + z + " camera.realZ " + realZ)
			if (_allowZMotion)
				z = factor;
			else
				trace((this+" is not allowed to z motion. please set allowZMotion to true."));
		}
		
		/** Increases/Decreases rotation by a specified value */
		public function rotate(angle:Number):void {
			if (_allowRotation){
				rotation += angle;
			}
			else
				trace(this + " is not allowed to rotate. please set allowRotation to true.");
		}
		
		/** Set z rotation from original value to a new value */
		public function setRotation(angle:Number):void {
			if (_allowRotation)
				rotation = angle;
			else
				trace((this+" is not allowed to rotate. please set allowRotation to true."));
		}
		
		/** Determine if camera could zoom */
		public function get allowZoom():Boolean{return _allowZoom; }
		public function set allowZoom(value:Boolean):void{
			if (!value){
				zoom = 1;
				camProxy.scale = 1;
			}
			_allowZoom = value;
		}
		
		/** Determine if camera could move on z axis */
		public function get allowZMotion():Boolean{return _allowZMotion; }
		public function set allowZMotion(value:Boolean):void{
			if (!value){
				z = 1;
				camProxy.z = 1;
			}
			_allowZMotion = value;
		}
		
		/** Determine if camera could rotate */
		public function get allowRotation():Boolean{ return _allowRotation; }
		public function set allowRotation(value:Boolean):void{
			if (!value){
				rotation = 0;
				camProxy.rotation = 0;
			}
			_allowRotation = value;
		}
		
		/** Objects witch camera follow */
		public function get otherTargets():Vector.<ISpriteView> {return _otherTargets;}
		public function set otherTargets(value:Vector.<ISpriteView>):void {	
			_otherTargets = value;
		}
		protected var _otherTargets:Vector.<ISpriteView> = new Vector.<ISpriteView>();
		
		/**The thing that the camera will follow if a manual position is not set.*/
		public function get mainTarget():ISpriteView {return _mainTarget;}
		public function set mainTarget(value:ISpriteView):void {	
			_mainTarget = value;
		}
		protected var _mainTarget:ISpriteView;
		
		public function get useManualPosition():Boolean {	return _useManualPosition;}
		public function set useManualPosition(v:Boolean):void {
			_useManualPosition = v;
		}
		private var _useManualPosition:Boolean = false;
		
		/** A point in space where camera will be */
		public function get manualPosition():Point {	return _manualPosition;}
		public function set manualPosition(p:Point):void {
			_manualPosition = p;
		}
		
		/** A Velocity on X camera is moving */
		public function get velocityX():Number {	return _velocityX; }
		private var _velocityX:Number;
		
		/** A Velocity on X camera is moving */
		public function get velocityY():Number {	return _velocityY;}
		private var _velocityY:Number;
		
		/** If centralizeTarget si true, return the center of the screen so camera offset could use it to centrilize target on screen. */
		public function get screenCenter():MathVector {
			if(centralizeTarget)
				return new MathVector(cameraLensWidth * 0.5, cameraLensHeight * 0.5);
			else
				return new MathVector(0, 0);
		}
		
		public static var cameraMovementIntensity:Number = 1;
		/** Return the current value for randomness. In order to change motionWiggler need to get is properties updated every frame */
		public function get randomness():ViewData {
			if (!motionWiggler || disableRandomness) {
				_randomness.x = 0;
				_randomness.y = 0;
				_randomness.z = 0;
				_randomness.zoom = 0;
				_randomness.rotation = 0;
				//trace("Camera motion randomness disabled")
			}else {
				_randomness.x = (motionWiggler.xValue - 115) * randomnessIntensity.x * cameraMovementIntensity;
				_randomness.y = (motionWiggler.yValue - 115) * randomnessIntensity.y * cameraMovementIntensity;
				//Rotation and Zoom need a smaller values to mach X and Y movement speed.
				_randomness.z = (motionWiggler.zValue - 115) * randomnessIntensity.z * 0.0006 * cameraMovementIntensity;
				_randomness.zoom = (motionWiggler.zValue - 115) * randomnessIntensity.z * 0.0006 * cameraMovementIntensity;
				_randomness.rotation = (motionWiggler.wValue  - 115)* randomnessIntensity.rotation * 0.001 * cameraMovementIntensity;
			}
			return _randomness;
		}
		/**
		 * Adds to camera a randomized motion to camera! Support all kind of motions: x, y, depth(z/zoom) and rotation;
		 * Set values different than zero to enable this feature. 
		 */
		public var randomnessIntensity:ViewData = new ViewData("CameraRondomnessIntensity", .2, .2, .2, .0, .1);
		private var _randomness:ViewData = new ViewData("CameraRondomness", 0, 0, 0, 0);
		
		public var disableRandomness:Boolean;
		public var disableShakeness:Boolean;
		
		/** Return the current value for shakeness. In order to change shakeWiggler need to get is properties updated every frame */
		public function get shakeness():ViewData {
			if (!shakeWiggler || disableShakeness) {
				_shakeness.x = 0;
				_shakeness.y = 0;
				_shakeness.z = 0;
				_shakeness.rotation = 0;
				_shakeness.zoom = 0;
			}else {
				_shakeness.x = (shakeWiggler.xValue - 115) * shakeIntensity.x;
				_shakeness.y = (shakeWiggler.yValue - 115) * shakeIntensity.y;
				//Rotation and Zoom need a smaller values to mach X and Y movement speed.
				_shakeness.z = (shakeWiggler.zValue - 115) * shakeIntensity.z * 0.0006;
				_shakeness.zoom = (shakeWiggler.zValue - 115) * shakeIntensity.z * 0.0006;
				_shakeness.rotation = (shakeWiggler.wValue - 115) * shakeIntensity.rotation * 0.001;
			}
			return _shakeness;
		}
		/**
		 * Make camera shake! Support all kind of motions: x, y, depth(z/zoom) and rotation;
		 * Set values different than zero to enable this feature. 
		 * Only works with enhanced camera.
		 */
		public var shakeIntensity:ViewData = new ViewData("CameraShakeIntensity", 0, 0, 0, 0);
		private var _shakeness:ViewData = new ViewData("CameraShake", 0, 0, 0, 0);
		
		private var cVarName:String;
		private var tween:Tween = new Tween(shakeIntensity, 1, Transitions.EASE_OUT);
		/** Shake camera for a determined time. Shakness use normal starling Tween, not TweenMax */
		public function shake(intensity:Object = null, time:Number = 2):void {
			shakeIntensity.setVars(10, 10, 1, 3);
			
			if (intensity is Array || intensity is Vector.<Number>)
				shakeIntensity.setVars(intensity[0], intensity[1], intensity[2], intensity[3]);
			else if (intensity is Object) {
				for (cVarName in intensity){
					shakeIntensity[cVarName] = intensity[cVarName];
				}
			}
			else if(intensity is ViewData){
				shakeIntensity.x = intensity.x;
				shakeIntensity.y = intensity.y;
				shakeIntensity.z = intensity.z;
				shakeIntensity.rotation = intensity.rotation;
				shakeIntensity.zoom = intensity.zoom;
			}
			
			tween.reset(shakeIntensity, time, Transitions.EASE_OUT);
			tween.animate("x", 0);
			tween.animate("y", 0);
			tween.animate("z", 0);
			tween.animate("rotation", 0);
			GameEngine.instance.state.gameJuggler.add(tween);
		}
		
		/** Return the offset applied to the camera taking account the shaking and ramdomness.  */
		public function get cameraExternalOffset():MathVector {
			return new MathVector (_viewRoot.x - screenCenter.x, _viewRoot.y - screenCenter.y);
		}
		
		/**  Could be used for some effects that dacey depending with camera distance. */
		public function get inverseSquareOfZoom():Number {
			return 1 / (zoom * zoom);
		}
		
		public function dispose():void {
			PresencePool.returnObject(presence);
			Presence.PRESENCES_IN_USE.splice(Presence.PRESENCES_IN_USE.indexOf(presence), 1);
			realOffset = null;
			realPosition = null;
			_manualPosition = null;
			position = null;
			offset = null;
			easing = null;
			bounds = null;
			camProxy = null;
			_mainTarget = null;
			randomnessIntensity = null;
			_randomness = null;
			shakeIntensity = null;
			_shakeness = null;
			h_diffOffset = null;
			h_velocityOffset = null;
			motionWiggler.clear();
			shakeWiggler.clear();		
		}
	}
}