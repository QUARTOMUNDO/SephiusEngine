package SephiusEngine.core.levelManager{
	import SephiusEngine.core.GameCamera;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.gameStates.LevelManager;
	import SephiusEngine.displayObjects.configs.ViewData;
	import SephiusEngine.input.InputActionsNames;
	import SephiusEngine.math.MathUtils;
	import SephiusEngine.math.MathVector;
	import SephiusEngine.userInterfaces.UserInterfaces;

	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.TapGesture;
	import org.gestouch.gestures.ZoomGesture;

	import starling.extensions.brinkbit.fullscreenscreenextension.FullScreenExtension;

	import tLotDClassic.GameData.Properties.creatureInfos.Actions;
	import tLotDClassic.gameObjects.characters.Sephius;
	import tLotDClassic.ui.debug.DebugControls;
	import tLotDClassic.attributes.AttributesConstants;
	import SephiusEngine.utils.AppInfo;

	/**
	 * This class deal with all camera moviments adjustment in the game and also with player control over the câmera.
	 * Here there is some custom effects like shake (wiggle) and enhanced target positioning in several gameplay situations.
	 * For example, whem player runs, camera target moves ahead the player to show where he going. When player falls, target moves to below the player showing where he goes land.
	 * Functions presented here should be called by other classes like Sephius class and Debbug class inside the gameplay logic presented in this external classes.
	 * This class is a "singleton" so there can be only 1 instance of this class in the system.
	 * @author Fernando Rabello
	 */
	public class CameraControl{
		protected var _ge:GameEngine;
		private static var _instance:CameraControl;
		private var enviromentObjectsSetted:Boolean = false;
		
		/**Timeout to stop camera from shaking*/
		public var _TimeOutcameraShaking:uint
		
		public var camera:GameCamera;
		
		/**Make graphics have same size no matter the resolution game run. Camera scales the state to the right size. */
		public var relativeZoom:Number;
		
		/**Can ryse or reduce max zoom in the game */
		public var zoomConstraint:Number = 0.01;
		
		//Gestures
		protected var screenDoubleTap:TapGesture = new TapGesture(GameEngine.instance.state as LevelManager);
		protected var screenZoomTouch:ZoomGesture = new ZoomGesture(GameEngine.instance.state as LevelManager);
		
		protected var zoomAndZFactor:Number;
		protected var targetAdjust:MathVector;
		protected var tapGesture:TapGesture;
		protected var zoomGesture:ZoomGesture;
		
		public function CameraControl(camera:GameCamera) {
			_ge = GameEngine.instance;
			this.camera = camera;
			camera.allowZoom = true;
			camera.allowRotation = true;
			camera.allowZMotion = true;
			
			camera.cameraLensWidth = FullScreenExtension.stageWidth;
			camera.cameraLensHeight = FullScreenExtension.stageHeight;
			
			relativeZoom = 1;
			camera.setZoom(relativeZoom);
			
			screenDoubleTap.numTapsRequired = 2;
			screenDoubleTap.addEventListener(GestureEvent.GESTURE_RECOGNIZED, cameraTouchControl);
			
			screenZoomTouch.lockAspectRatio = true;
			screenZoomTouch.addEventListener(GestureEvent.GESTURE_BEGAN, cameraTouchControl);
			screenZoomTouch.addEventListener(GestureEvent.GESTURE_CHANGED, cameraTouchControl);	
		}
		
		public static var disableCameraControl:Boolean;
		/** Update function, this is called by Level class when game is not paused.*/
		public function update(timeDelta:Number):void {
			camera.cameraLensWidth = FullScreenExtension.stageWidth;
			camera.cameraLensHeight = FullScreenExtension.stageHeight;
			if (GameEngine.instance.state.mainPlayer && GameEngine.instance.state.mainPlayer.updateCallEnabled ){
				targetControl(timeDelta);
				if (!UserInterfaces.instance.hud.isAnyRingOnScreen)
					cameraControls(timeDelta);
			}
			//camera.presence.bounds.width = FullScreenExtension.screenWidth * 1.5 / camera.deepFactor;
			//camera.presence.bounds.height = FullScreenExtension.screenHeight * 1.5 / camera.deepFactor;
		}
		
		private var cTAdjust:MathVector = new MathVector();
		private var cTarget:Sephius;

		private var controlByFacingTarget:Number = 0;
		private var controlByFacing:Number = 0;

		private var controlByOnGroundTarget:Number = 0;
		private var controlByOnGround:Number = 0;

		private var controlByVelocityXTarget:Number = 0;
		private var controlByVelocityX:Number = 0;

		private var controlByVelocityYTarget:Number = 0;
		private var controlByVelocityY:Number = 0;

		public static var cameraAssitIntensity:Number = 1;
		/** This function control the behavior of the camera offset in several gameplay conditions*/
		private function targetControl(timeDelta:Number):void {
			targetAdjust = new MathVector(0, 0);
			cTAdjust.setTo(0, 0);
			
			//--------------------------------------------------------------------------------//
			//                      Player movement control over target                      //
			//--------------------------------------------------------------------------------//
			if(!disableCameraControl){
				for each (cTarget in camera.otherTargets){
					//Adjustment based on sephius size in relation to screen
					//zoomAndZFactor = 1 / Math.abs(cTarget.characterView.parent.scaleX);
					//zoomAndZFactor = Math.min(1, zoomAndZFactor);

					zoomAndZFactor = 1 / Math.pow(5, (camera.realZ - 1));
					zoomAndZFactor = Math.min(2, zoomAndZFactor);

					//Default x reposition (camera does not stay with player on center, but slight on left or right acordding where he is facing)
					controlByFacingTarget = cTarget.inverted ? (FullScreenExtension.stageWidth * 0.1 * zoomAndZFactor) : -(FullScreenExtension.stageWidth * 0.1 * zoomAndZFactor);
					controlByFacing = MathUtils.lerp(controlByFacing, controlByFacingTarget, AttributesConstants.controlByFacingLerpSped * timeDelta);
					cTAdjust.x = controlByFacing ;
					//cTAdjust.x = cTarget.inverted ? (FullScreenExtension.stageWidth * 0.1 * zoomAndZFactor) : -(FullScreenExtension.stageWidth * 0.1 * zoomAndZFactor);
					
					//To show ahead when hero is moving right or left. Bigger the velocity, further ahead camera will show.
					controlByVelocityXTarget = cTarget.velocityScaled.x * 40 * zoomAndZFactor;
					controlByVelocityX = MathUtils.lerp(controlByVelocityX, controlByVelocityXTarget, AttributesConstants.controlByVelocityXLerpSpeed * timeDelta);
					cTAdjust.x -= controlByVelocityX;
					//cTAdjust.x -= cTarget.velocityScaled.x * 40 * zoomAndZFactor;
					
					//Default y reposition (camera does not stay with player on center, but slight on above player to show more of the backgroung)
					controlByOnGroundTarget = (cTarget.onGround && cTarget.action.actionType != "duck") ? (FullScreenExtension.stageHeight * 0.25) * zoomAndZFactor : FullScreenExtension.stageHeight * 0.07 * zoomAndZFactor;
					controlByOnGround = MathUtils.lerp(controlByOnGround, controlByOnGroundTarget, AttributesConstants.controlByOnGroundLerpSped * timeDelta);
					cTAdjust.y = controlByOnGround;
					//cTAdjust.y = cTarget.onGround ? (FullScreenExtension.stageHeight * 0.25) * zoomAndZFactor : FullScreenExtension.stageHeight * 0.07 * zoomAndZFactor;
					
					//When Gliding show bellow effect should be more stronger then when falling.
					//if (cTarget.velocityScaled.y > 0) {
						controlByVelocityYTarget = cTarget.velocityScaled.y  * zoomAndZFactor * ((cTarget.action == Actions.SEPHIUS_GLIDING_LOOP || cTarget.action == Actions.SEPHIUS_GLIDING_START) ? 40 : 25);
						controlByVelocityY = MathUtils.lerp(controlByVelocityY, controlByVelocityYTarget, AttributesConstants.controlByVelocityYLerpSpeed * timeDelta);
						cTAdjust.y -= controlByVelocityY;
						//cTAdjust.y -= cTarget.velocityScaled.y  * zoomAndZFactor * ((cTarget.action == Actions.SEPHIUS_GLIDING_LOOP || cTarget.action == Actions.SEPHIUS_GLIDING_START) ? 40 : 25);
					//}

					//--------------------------------------------------------------------------------//
					//                              Offset adjustment application                     //
					//--------------------------------------------------------------------------------//
					//This prevent Sephius to go out screen when moving too fast
					cTAdjust.x -= (cTarget.characterView.mainAnimation.parent.x * cTarget.characterView.mainAnimation.parent.x * cTarget.characterView.mainAnimation.parent.x * 0.00001);
					cTAdjust.y -= (cTarget.characterView.mainAnimation.parent.y * cTarget.characterView.mainAnimation.parent.y * cTarget.characterView.mainAnimation.parent.y * 0.00001);
					
					if (isNaN(cTAdjust.x) || isNaN(cTAdjust.y))
						if(AppInfo.isDebugBuild)
							throw Error("something becomes NaN on Camera Control");
					
					targetAdjust.x += cTAdjust.x / camera.otherTargets.length;
					targetAdjust.y += cTAdjust.y / camera.otherTargets.length;
				}
			}
			
			camera.offset.x = targetAdjust.x * cameraAssitIntensity;
			camera.offset.y = targetAdjust.y * cameraAssitIntensity;
		}
		
		/** Resets Camera zoom with double tap touch*/
		public function cameraTouchControl(event:GestureEvent):void {
			tapGesture = event.target as TapGesture;
			if (tapGesture){
				//camera.setZoom(relativeZoom);
				//camera.setZ(1);
			}
			
			zoomGesture = event.target as ZoomGesture;
			if (zoomGesture){
				if ((camera.z < 2 && zoomGesture.scaleX > 1) || (camera.z > 0.5 && zoomGesture.scaleX < 1)){
					camera.setZ(camera.z * (zoomGesture.scaleX));
				}
				if (((camera.zoom < 1.3 * relativeZoom) && zoomGesture.scaleX > 1) || ((camera.zoom > 0.7 * relativeZoom) && zoomGesture.scaleX < 1)){
					camera.setZoom(camera.zoom * (((zoomGesture.scaleX-1) * 0.33)+1));
				}
			}
		}
		
		public var showMap:Boolean;
		
		/**
		 * Player control over the camera.
		 * This call zoom features and other actions
		 */
		public function cameraControls(timeDelta:Number):void {
			if (!GameEngine.instance.state.mainPlayer.inputWatcher.isDoing(InputActionsNames.CAMERA_DEFAULT)) {
				if(DebugControls.debugEnabled){
					if (GameEngine.instance.state.mainPlayer.inputWatcher.isDoing(InputActionsNames.CAMERA_UNLIMITED_ZOOM_IN) && GameEngine.instance.state.mainPlayer.inputWatcher.isDoing(InputActionsNames.DEBUG_MAIN))
						camera.zooming(1.01);
					
					else if (GameEngine.instance.state.mainPlayer.inputWatcher.isDoing(InputActionsNames.CAMERA_UNLIMITED_ZOON_OUT) && GameEngine.instance.state.mainPlayer.inputWatcher.isDoing(InputActionsNames.DEBUG_MAIN))
						camera.zooming(0.99);
					
					if (GameEngine.instance.state.mainPlayer.inputWatcher.isDoing(InputActionsNames.CAMERA_UNLIMITED_Z_IN) && GameEngine.instance.state.mainPlayer.inputWatcher.isDoing(InputActionsNames.DEBUG_MAIN))
						camera.setZ(camera.z + .05);
					
					else if (GameEngine.instance.state.mainPlayer.inputWatcher.isDoing(InputActionsNames.CAMERA_UNLIMITED_Z_OUT) && GameEngine.instance.state.mainPlayer.inputWatcher.isDoing(InputActionsNames.DEBUG_MAIN))
						camera.setZ(camera.z - .05);
					
					if (GameEngine.instance.state.mainPlayer.inputWatcher.isDoing(InputActionsNames.CAMERA_ROTATION_LEFT) && GameEngine.instance.state.mainPlayer.inputWatcher.isDoing(InputActionsNames.DEBUG_MAIN)) {
						camera.rotate(.1);
					}
					
					else if (GameEngine.instance.state.mainPlayer.inputWatcher.isDoing(InputActionsNames.CAMERA_ROTATION_RIGHT) && GameEngine.instance.state.mainPlayer.inputWatcher.isDoing(InputActionsNames.DEBUG_MAIN)) {
						camera.rotate(-.1);
					}
				}
				
				//Reset Camera
				if (GameEngine.instance.state.mainPlayer.inputWatcher.justDid(InputActionsNames.CAMERA_DEFAULT)) {
					camera.setZoom(relativeZoom);
					camera.setZ(1);
					camera.setRotation(0);
				}
				
				if (GameEngine.instance.state.mainPlayer.inputWatcher.justDid(InputActionsNames.FAST_MAP) && GameEngine.instance.state.mainPlayer.action.actionType != "winging") {
					if(!showMap){
						camera.setZoom(relativeZoom);
						camera.setZ(-1);
						//camera.setRotation(0);
						showMap = true;
					}
					else {
						camera.setZoom(relativeZoom);
						camera.setZ(1);
						//camera.setRotation(0);
						showMap = false;
					}
				}	
				
				
				else if (GameEngine.instance.state.mainPlayer.inputWatcher.isDoing(InputActionsNames.CAMERA_OUTWARD)) {
					if (camera.z > camZMax2) {
						if (camera.z > camZMax)
							camera.setZ(camera.z - camZVelocity);
						else
							camera.setZ(camera.z - camZVelocity2);
					}
					if (camera.zoom > (camZoomMax * relativeZoom)){
						camera.zooming(0.998);
					}
				}
				else if (GameEngine.instance.state.mainPlayer.inputWatcher.isDoing(InputActionsNames.CAMERA_INWARD)){
					if (camera.z < camZMin) {
						if (camera.z > camZMax)
							camera.setZ(camera.z + camZVelocity);
						else
							camera.setZ(camera.z + camZVelocity2);
					}
					if (camera.zoom < (camZoomMin * relativeZoom)){
						camera.zooming(1.002);
					}
				}
			}
			
			else {
				//Reset camera to max distance
				if (GameEngine.instance.state.mainPlayer.inputWatcher.isDoing(InputActionsNames.CAMERA_OUTWARD)) {
					camera.setZoom(camZoomMax * relativeZoom);
					camera.setZ(camZMax);
					camera.setRotation(0);
				}
				
				//Reset camera to closer distance
				else if (GameEngine.instance.state.mainPlayer.inputWatcher.isDoing(InputActionsNames.CAMERA_INWARD)) {
					camera.setZoom(camZoomMin * relativeZoom);
					camera.setZ(camZMin);
					camera.setRotation(0);
				}
			}
			
			//trace(camera.zoom + " / " + camera.z)
		}
		
		private var camZMax:Number = 0.99;
		private var camZoomMax:Number = 0.93;
		
		private var camZMax2:Number = -1.8;
		private var camZoomMax2:Number = 0.93;
		
		private var camZMin:Number = 1.5;
		private var camZoomMin:Number = 1.01;
		
		private var camZVelocity:Number = 0.005;
		private var camZVelocity2:Number = 0.02;
		
		/**
		 *	Shake camera for a determined time
		 *	 @return Nothing
		 *	 @param time
		 */
		public function ShakeCamera(shakeIntensity:ViewData=null, time:Number=2):void{
			camera.shake(shakeIntensity, time);
		}
		
		public function dispose():void {
			_ge = null;
			_instance = null;
			camera = null;
			screenDoubleTap.dispose();
			screenZoomTouch.dispose();
			tapGesture.dispose();
			zoomGesture.dispose();
			targetAdjust = null;
		}
	}
}
