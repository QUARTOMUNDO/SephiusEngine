package SephiusEngine.core {
	import SephiusEngine.core.GameCamera;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.displayObjects.GameArt;
	import SephiusEngine.displayObjects.ViewObjects.ViewLayer;
	import SephiusEngine.displayObjects.ViewObjects.ViewParallax;
	import SephiusEngine.levelObjects.interfaces.ISpriteView;
	import SephiusEngine.math.MathVector;

	import com.greensock.TweenMax;

	import flash.display.DisplayObject;
	import flash.geom.Matrix;

	import nape.geom.Mat23;

	import org.osflash.signals.Signal;

	import starling.core.RenderSupport;
	import starling.display.BlendMode;
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.extensions.brinkbit.fullscreenscreenextension.FullScreenExtension;
	
	
	/**
	 * Menage visual representation of all objects added to a GameState
	 * @author Fernando Rabello
	 */
	public class GameView extends Sprite {
		/** Store game camera. Its a "virtual" object and it is used determine the final position of all object visual representation.*/
		public var camera:GameCamera;
		
		/** Store view layers where object arts are added Each layer has relation to the object group property */
		public var layers:Vector.<ViewLayer> = new Vector.<ViewLayer>();
		
		///** Store objects visual representation added to state. Pass the object to accesse it */
		//public var viewObjectsByName:Dictionary = new Dictionary();
		/** Store objects visual representation on a vector. Faster to access */
		public var viewObjects:Vector.<GameArt> = new Vector.<GameArt>();
		
		/** Objects which will be updated by view */
		public var viewObjectsToUpdate:Vector.<GameArt> = new Vector.<GameArt>();
		
		/** Box2D are not rendered on Starling display List. So its view is a normal Flash display list */
		public var physicsDebugView:flash.display.DisplayObject;
		/** Temporary matrix used to correct physic debug view transformation to match Starling transform features */
		public var debugViewTransformMatrix:Matrix;
		
		private var _currentArtHelper:GameArt;
		//private var _dephFactors:Object = new Object();
		 
		/** Container where all view layers stays inside */
		public var viewRoot:Sprite = new Sprite();
		
		private var originNewPos:MathVector = new MathVector();
		private var originOldPos:MathVector = new MathVector();
		private var originNewRot:Number;
		private var originOldRot:Number;
		private var originNewScale:Number;
		private var originOldScale:Number;
		
		/** A object witch represents the origing in the camera coordinate space */
		public var originPos:MathVector = new MathVector();
		/** A object witch represents the origing in the camera coordinate space */
		public var originRot:Number;
		/** A object witch represents the origing in the camera coordinate space */
		public var originScale:Number;
		/** A object witch represents the origing in the camera coordinate space */
		public var originDysplayObject:Sprite = new Sprite();
		
		/** Container where all view layers of related with backgrounds */
		public var viewBackGround:Sprite = new Sprite();
		/** Container where all view layers of related with layer witch player is */
		public var viewZeroGround:Sprite = new Sprite();
		/** Container where all view layers of related with foreground */
		public var viewForeGround:Sprite = new Sprite();
		
		/** A parent of viewRoot used to apply filter effect without conflict with viewRoot filter */
		public var viewRootParent1:Sprite = new Sprite();
		/** A parent of viewRootParent1 used to apply filter effect without conflict with viewRoot filter */
		public var viewRootParent2:Sprite = new Sprite();
		
		/**  Container that contains sound bebug view*/
		public var soundDebugCanvas:Sprite = new Sprite();
		/** Container witch contains physic debug art (box2D at this time) */
		public var gameDebugCanvas:Sprite = new Sprite();
		/** Special canvas witch appear effects like lighting. */
		public var effectsCanvas:Sprite = new Sprite();
		/** Used for fade in and fade out effects to blackscreen */
		private var blackScreenCanvas:Sprite = new Sprite();
		private var blackScreen:Quad = new Quad(10, 10, 0xffffff);
		
		private var h_currentLayer:Sprite;
		
		private var oldViewRootTransform:Object = new Object();
		private var newViewRootTransform:Object = new Object();
		
		private var _resolution:Number = 1;
		/** Ration to determine render resolution */
		public function get resolution():Number {return _resolution;}
		public function set resolution(value:Number):void { 
			if (value > 1)
				value = 1;
			
			if (value <= 0)
				throw Error("Resolution can´t be equal or less than 0");
			
			_resolution = value;
			
			value *= defaultResolutionRatio;
			
			if (viewRootParent1.filter)
				viewRootParent1.filter.resolution = value;
			
			if (viewRootParent2.filter)
				viewRootParent2.filter.resolution = value;
			
			if (viewBackGround.filter)
				viewBackGround.filter.resolution = value;
			
			if (viewZeroGround.filter)
				viewZeroGround.filter.resolution = value;
			
			if (viewForeGround.filter)
				viewForeGround.filter.resolution = value;
				
		}
		
		/** Default resolution ratio to make game run at same resolution on diferent displays dpi */
		public var defaultResolutionRatio:Number = 1;
		
		/** GameView replaces SephiusEngine View classes and levels of abstractions
		 * It works directly with Starling framework
		 * Here is where all visual representation of game objects is menage
		 * GameView also menage camera and object views in order to create the deph and parallax effect the game uses
		 * GameView also contains special layers for interface elements witch keeps separately from ViewRoot
		 * */
		public function GameView() {
			super();
			viewRoot.name = "ViewRoot";
			viewBackGround.name = "viewBackGround";
			viewZeroGround.name = "viewZeroGround";
			viewForeGround.name = "viewForeGround";
			
			viewRoot.addChild(viewBackGround);
			viewRoot.addChild(viewZeroGround);
			viewRoot.addChild(viewForeGround);
			
			viewRootParent1.addChild(viewRoot);
			viewRootParent2.addChild(viewRootParent1);
			addChild(viewRootParent2);
			//addChild(viewRoot);
			addChild(effectsCanvas);
			
			blackScreen.x = FullScreenExtension.screenLeft;
			blackScreen.y = FullScreenExtension.screenTop;
			blackScreen.width = FullScreenExtension.screenWidth;
			blackScreen.height = FullScreenExtension.screenHeight;
			blackScreen.alpha = 0;
			blackScreen.blendMode = BlendMode.ADD;
			addChild(blackScreenCanvas);
			
			addChild(soundDebugCanvas);
			addChild(gameDebugCanvas);
			
			camera = new GameCamera(FullScreenExtension.stageWidth, FullScreenExtension.stageHeight, viewRoot);
			viewZeroGround.addChild(originDysplayObject);
			
			defaultResolutionRatio = FullScreenExtension.stageWidth / FullScreenExtension.screenRenderWidth;
		}
		
		public var onFadeInComplete:Signal = new Signal(); 
		public var onFadeOutComplete:Signal = new Signal(); 
		public var isFading:Boolean;
		
		/* fades game in and out */
		public function fade(fadeIntime:Number = 0.5, stayTime:Number = 2, fadeOutTime:Number = 1, inCallback:Function = null, outCallback:Function = null):void{
			if(inCallback)
				onFadeInComplete.addOnce(inCallback);
			if(outCallback)
				onFadeOutComplete.addOnce(outCallback);
			
			fadeIn(fadeIntime);
			
			TweenMax.delayedCall(fadeIntime + stayTime, fadeOut, [fadeOutTime]);
		}
		
		/**Fades games in them waits level to be ready (loads all assets) to fade out */
		public function fadeOutByLevelManager(fadeOutTime:Number = 1,outCallback:Function = null):void{
			if(outCallback)
				onFadeOutComplete.addOnce(outCallback);
			
			if(!GameEngine.instance.state.isReady)
				GameEngine.instance.state.onReady.addOnce(fadeOutOnLevelReady);
			else
				TweenMax.delayedCall(0.5, fadeOut, [fadeOutTime]);
		}
		
		/* called when level is ready and game is on black screen */
		private function fadeOutOnLevelReady(state:GameState):void{
			fadeOut();
		}
		
		/*Fade in black screen */
		public function fadeIn(fadeIntime:Number = 0.5, inCallback:Function = null):void{
			if(inCallback)
				onFadeInComplete.addOnce(inCallback);
				
			isFading = true;	
			
			addBlackScreen(true);
			
			TweenMax.to(blackScreen, fadeIntime, {alpha:1, onComplete:onFadeInComplete.dispatch});
			TweenMax.to(this, fadeIntime, {isFading:false});
		}
		
		/*Fade out black screen */
		public function fadeOut(fadeOutTime:Number = 1, outCallback:Function = null):void{
			if(outCallback)
				onFadeOutComplete.addOnce(outCallback);
				
			isFading = true;	
			
			TweenMax.to(blackScreen, fadeOutTime, {alpha:0, onComplete:onFadeOutComplete.dispatch});
			TweenMax.delayedCall(fadeOutTime, removeBlackScreen);
			TweenMax.to(this, fadeOutTime, {isFading:false});
		}
		
		private function addBlackScreen(add:Boolean):void{
			blackScreenCanvas.addChild(blackScreen);
		}
		private function removeBlackScreen():void{
			if (isFading)
				return;
				
			blackScreen.alpha = 0;
			blackScreenCanvas.removeChild(blackScreen);
		}
		
		private function updateNewOrigin():void {
			var dephFactor:Number;
			var finalParallax:Number;
			
			if (camera.allowZMotion) {
				dephFactor = Math.pow(5, (camera.realZ - 1));
				
				//originNewRot = viewRoot.rotation;
				originScale = dephFactor;
				
				originPos.x = (dephFactor) + (-camera.realPosition.x * dephFactor);
				originPos.y = (dephFactor) + (-camera.realPosition.y * dephFactor);
			}
			else {
				originPos.x = (camera.realPosition.x - camera.screenCenter.x) * (1) + camera.screenCenter.x;
				originPos.y = (camera.realPosition.y - camera.screenCenter.y) * (1) + camera.screenCenter.y;
				//originNewRot = viewRoot.rotation;
				originScale = 1;
			}
			
			originDysplayObject.x = originPos.x;
			originDysplayObject.y = originPos.y;
			originDysplayObject.scaleX = originScale;
			originDysplayObject.scaleY = originScale;
		}
		
		/**
		 * The update method's job is to iterate through all the SephiusEngineObjects,
		 * Here GameView updates the position of all Art Objects falowing a special parallax formula 
		 * For that its uses information from the Game Camera
		 * Super cool parallax algorithm!
		 */		
		public function updateViewNewStates(timeDelta:Number):void {
			//Refresh camera;
			camera.update(timeDelta);
			
			var n:int = layers.length;
			var i:int = 0;
			var n2:int;
			var i2:int = 0;
			var scale:Number;
			
			// Update layer states
			for (i = 0; i < n; i++ ) {
				n2 = layers[i].parallaxGroups.length;
				for (i2 = 0; i2 < n2; i2++ ) {
					if (layers[i].parallaxGroups[i2].numChildren > 0)
						updateGroupParallaxNewState(layers[i].parallaxGroups[i2]);
				}
			}
			
			n = viewObjectsToUpdate.length;
			i = 0;
			
			// Update gameArts states
			for (i = 0; i < n; i++ ) {
				if (viewObjectsToUpdate[i].content && (viewObjectsToUpdate[i].updateState || viewObjectsToUpdate[i].updateStateOnce)){
					updateArtNewState(viewObjectsToUpdate[i]);
				}
			}
			
			updateNewOrigin();
			
			//_dephFactors = new Dictionary();
			
			if (camera.allowZoom)
				newViewRootTransform.scaleX = newViewRootTransform.scaleY = camera.realZoom;
			
			if (camera.allowRotation)
				newViewRootTransform.rotation = camera.realRotation;
			
			//To make camera rotate in the screen center
			newViewRootTransform.x = camera.screenCenter.x;
			newViewRootTransform.y = camera.screenCenter.y;
			
			//2D shakeness and randomness
			if(!camera.disableShakeness){
				newViewRootTransform.x -= camera.shakeness.x;
				newViewRootTransform.y -= camera.shakeness.y;
			}
			if(!camera.disableRandomness){
				newViewRootTransform.x -= camera.randomness.x;
				newViewRootTransform.y -= camera.randomness.y;
			}
			
			//Refesh physics debug view
			if (GameEngine.instance.state.physics.visible) {
				physicsDebugView = GameEngine.instance.state.physics.view.display;
				
				if (camera.mainTarget || camera.manualPosition) {
					scale = Math.pow(5, camera.realZ - 1) * camera.realZoom;
					
					debugViewTransformMatrix = GameEngine.instance.state.physics.view.transform.toMatrix();
					debugViewTransformMatrix.identity();
					debugViewTransformMatrix.translate(-camera.realPosition.x, -camera.realPosition.y);
					debugViewTransformMatrix.rotate(camera.realRotation);
					debugViewTransformMatrix.scale(scale, scale);
					debugViewTransformMatrix.translate(viewRoot.x, viewRoot.y);
					debugViewTransformMatrix.translate(-FullScreenExtension.screenLeft, -FullScreenExtension.screenTop);
					debugViewTransformMatrix.scale(FullScreenExtension.sizeRatio, FullScreenExtension.sizeRatio);
					
					GameEngine.instance.state.physics.view.transform = Mat23.fromMatrix(debugViewTransformMatrix);
				}
			}
		}
		
		public function smoothViewStates(fixedTimestepAccumulatorRatio:Number):void {
			var n:int = layers.length;
			var i:int = 0;
			var scale:Number;
			var n2:int;
			var i2:int = 0;
			
			var oneMinusRatio:Number = 1.0 - fixedTimestepAccumulatorRatio;
			
			// Update layer states
			for (i = 0; i < n; i++ ) {
				n2 = layers[i].parallaxGroups.length;
				for (i2 = 0; i2 < n2; i2++ ) {
					if (layers[i].parallaxGroups[i2].numChildren > 0)
						smoothGroupParallaxState(layers[i].parallaxGroups[i2], fixedTimestepAccumulatorRatio, oneMinusRatio);
				}
			}
			
			n = viewObjectsToUpdate.length;
			i = 0;
			
			for (i = 0; i < n; i++ ) {
				if (viewObjectsToUpdate[i].contentVar && (viewObjectsToUpdate[i].updateState || viewObjectsToUpdate[i].updateStateOnce)){
					smoothArtState(viewObjectsToUpdate[i], fixedTimestepAccumulatorRatio, oneMinusRatio);
					if(viewObjectsToUpdate[i].updateStateOnce)
						viewObjectsToUpdate[i].updateState = false;
				}
			}
			
			if (camera.allowZoom)
				viewRoot.scaleX = viewRoot.scaleY = (newViewRootTransform.scaleX * fixedTimestepAccumulatorRatio) + (oldViewRootTransform.scaleX * oneMinusRatio);
			
			if (camera.allowRotation)
				viewRoot.rotation = (newViewRootTransform.rotation * fixedTimestepAccumulatorRatio) + (oldViewRootTransform.rotation * oneMinusRatio);
			
			viewRoot.x = (newViewRootTransform.x * fixedTimestepAccumulatorRatio) + (oldViewRootTransform.x * oneMinusRatio);
			viewRoot.y = (newViewRootTransform.y * fixedTimestepAccumulatorRatio) + (oldViewRootTransform.y * oneMinusRatio);
		}
		
		public function updateViewOldStates():void {
			var n:int = layers.length;
			var i:int = 0;
			var scale:Number;
			var n2:int;
			var i2:int = 0;
			
			// Update layer states
			for (i = 0; i < n; i++ ) {
				n2 = layers[i].parallaxGroups.length;
				for (i2 = 0; i2 < n2; i2++ ) {
					if (layers[i].parallaxGroups[i2].numChildren > 0)
						updateGroupParallaxOldState(layers[i].parallaxGroups[i2]);
				}
			}
			
			n = viewObjectsToUpdate.length;
			i = 0;
			
			for (i = 0; i < n; i++ ) {
				if (viewObjectsToUpdate[i].contentVar && (viewObjectsToUpdate[i].updateState || viewObjectsToUpdate[i].updateStateOnce)){
					updateArtOldState(viewObjectsToUpdate[i]);
				}
			}
			
			if (camera.allowZoom)
				oldViewRootTransform.scaleX = oldViewRootTransform.scaleY = newViewRootTransform.scaleX;
			
			if (camera.allowRotation)
				oldViewRootTransform.rotation = newViewRootTransform.rotation;
			
			oldViewRootTransform.x = newViewRootTransform.x;
   			oldViewRootTransform.y = newViewRootTransform.y;
		}
		
		public function updateGroupParallaxNewState(pArt:ViewParallax):void {
			if (camera.allowZMotion && complexCalculation) {
				pArt.dephFactor = Math.pow(5, (camera.realZ - 1) * pArt.parallax);
				pArt.nScaleX = (pArt.lockScales ? 1 : pArt.dephFactor);
				pArt.nScaleY = (pArt.lockScales ? 1 : pArt.dephFactor);
				
				pArt.finalParallax = pArt.parallax * pArt.dephFactor;
				
				pArt.nx = (pArt.lockX ? 0 : (-camera.realPosition.x * pArt.finalParallax));
				pArt.ny = (pArt.lockY ? 0 : (-camera.realPosition.y * pArt.finalParallax));
			}
			else {
				pArt.nx = (pArt.lockX ? 0 : (-camera.realPosition.x * pArt.parallax));
				pArt.ny = (pArt.lockY ? 0 : (-camera.realPosition.y * pArt.parallax));
				pArt.nScaleX = 1;
				pArt.nScaleY = 1;
			}
			
			//Make art desapear if it comes too close to the camera. Usefull to able to "see" objects behind others.
			if (pArt.scaleX > 10)
				pArt.visible = false;
			else 
				pArt.visible = true;
			
			//Update GameArt (Damage System need GameArt updated during state steps)
			pArt.x = pArt.nx;
			pArt.y = pArt.ny;
			//art.scaleX = art.nScaleX;
			pArt.scaleX =  Math.abs(pArt.nScaleX);
			pArt.scaleY = pArt.nScaleY;
		}
		
		public function updateGroupParallaxOldState(pArt:ViewParallax):void {
			pArt.px = pArt.nx;
			pArt.py = pArt.ny;
			
			pArt.pScaleX = pArt.nScaleX;
			pArt.pScaleY = pArt.nScaleY;
		}
		
		public function smoothGroupParallaxState(pArt:ViewParallax, fixedTimestepAccumulatorRatio:Number, oneMinusRatio:Number):void {
			pArt.x = (pArt.nx * fixedTimestepAccumulatorRatio) + (pArt.px * oneMinusRatio);
			pArt.y = (pArt.ny * fixedTimestepAccumulatorRatio) + (pArt.py * oneMinusRatio);
			
			pArt.scaleX = (pArt.nScaleX * fixedTimestepAccumulatorRatio) + (pArt.pScaleX * oneMinusRatio);
			pArt.scaleY = (pArt.nScaleY * fixedTimestepAccumulatorRatio) + (pArt.pScaleY * oneMinusRatio);
		}
		
		public  var complexCalculation:Boolean = true;
		private  var gOP:Object = {};
		private  var cameraP:Object = {};
		public function updateArtNewState(art:GameArt):void {
			var gameObject:ISpriteView = art.gameObject;
			
			art.nOriginalScaleX = gameObject.scaleX;
			art.nOriginalScaleY = gameObject.scaleY;
			art.parallax = gameObject.parallax;
			
			art.lockX = gameObject.lockX;
			art.lockY = gameObject.lockY;
			art.lockRotation = gameObject.lockRotation;
			art.lockScales = gameObject.lockScales;
			
			art.nx = gameObject.x * art.parallax;
			art.ny = gameObject.y * art.parallax;
			art.nScaleX = art.nOriginalScaleX;
			art.nScaleY = art.nOriginalScaleX;
			
			art.nAlpha = gameObject.alpha;
			art.nRotation = gameObject.rotationRad * (art.lockRotation ? -camera.realRotation : 1);
			
			art.color = gameObject.color;
			
			art.visible = gameObject.visible;
			art.registration = gameObject.registration;
			//art.content = gameObject.view.content;
			
			art.compAbove = gameObject.compAbove;
			if ((art.group!= gameObject.group) || gameObject.updateGroup){
				art.group = gameObject.group;
				updateGroupForSprite(art, art.compAbove);
			}
			
			art.blendMode = gameObject.blendMode;
			
			//Make art desapear if it comes too close to the camera. Usefull to able to "see" objects behind others.
			if (art.scaleX > 10 * art.originalScaleX)
				art.contentVar.visible = false;
			else 
				art.contentVar.visible = gameObject.visible;
			
			//Animation of Offsets
			if(art.contentVar as DisplayObjectContainer){
				art.contentVar.pivotX = -gameObject.offsetX;
				art.contentVar.pivotY = -gameObject.offsetY;
			}
			else {
				art.contentVar.pivotX = -(gameObject.offsetX - (art.contentWidth / 2));//Tying to fix offset for image objects
				art.contentVar.pivotY = -(gameObject.offsetY - (art.contentHeight / 2));
			}
			art.contentVar.scaleX = gameObject.scaleOffsetX;
			art.contentVar.scaleY = gameObject.scaleOffsetY;
			
			art.contentVar.rotation = gameObject.rotationOffset;
			
			//Update GameArt (Damage System need GameArt updated during state steps)
			art.x = art.nx;
			art.y = art.ny;
			//art.scaleX = art.nScaleX;
			art.scaleX = Math.abs(art.nScaleX) * (gameObject.inverted ? -1 : 1);
			art.scaleY = art.nScaleY;
			
			art.alpha = art.nAlpha;
			art.rotation = art.nRotation;
			
			art.originalScaleX = art.nOriginalScaleX;
			art.originalScaleY = art.nOriginalScaleY;
		}
		
		public function updateArtOldState(art:GameArt):void {
			art.px = art.nx;
			art.py = art.ny;
			art.pScaleX = art.nScaleX;
			art.pScaleY = art.nScaleY;
			
			art.pAlpha = art.nAlpha;
			art.pRotation = art.nRotation;
			
			art.pOriginalScaleX = art.nOriginalScaleX;
			art.pOriginalScaleY = art.nOriginalScaleY;
		}
		
		public function smoothArtState(art:GameArt, fixedTimestepAccumulatorRatio:Number, oneMinusRatio:Number):void {
			art.x = (art.nx * fixedTimestepAccumulatorRatio) + (art.px * oneMinusRatio);
			art.y = (art.ny * fixedTimestepAccumulatorRatio) + (art.py * oneMinusRatio);
			
			art.scaleX = (Math.abs((art.nScaleX * fixedTimestepAccumulatorRatio)) + Math.abs((art.pScaleX * oneMinusRatio))) * (art.gameObject.inverted ? -1 : 1);
			art.scaleY = (art.nScaleY * fixedTimestepAccumulatorRatio) + (art.pScaleY * oneMinusRatio);
			art.originalScaleX = (art.nOriginalScaleX * fixedTimestepAccumulatorRatio) + (art.pOriginalScaleX * oneMinusRatio);
			art.originalScaleY = (art.nOriginalScaleY * fixedTimestepAccumulatorRatio) + (art.pOriginalScaleY * oneMinusRatio);
			
			art.alpha = (art.nAlpha * fixedTimestepAccumulatorRatio) + (art.pAlpha * oneMinusRatio);
			
			art.rotation = (art.nRotation * fixedTimestepAccumulatorRatio) + (art.pRotation * oneMinusRatio);
			
			if(art.needSmoothContainerState && art.stage)
				art.gameArtContainer.smoothState(fixedTimestepAccumulatorRatio, oneMinusRatio);
		}
		
		/** Actually add a GameArt to the GameView root and updates the view display objects tree */
		public function updateGroupForSprite(sprite:GameArt, above:Boolean = true):void {
			var gameObject:ISpriteView = sprite.gameObject;
			
			if (sprite.gameObject.group > viewRoot.numChildren + 100)
				trace("the group property value of " + gameObject + ":" + gameObject.group + " is higher than +100 to the current max group value (" + viewRoot.numChildren + ") and may perform a crash");
			
			// Create the container sprite (group) if it has not been created yet.
			while (sprite.gameObject.group + 1 > layers.length) {
				h_currentLayer = new ViewLayer(layers.length);
				h_currentLayer.name = "ViewLayer" + layers.length;
				layers.push(h_currentLayer);
				
				if (layers.length - 1 >= 6 && layers.length - 1 <= 15)
					viewZeroGround.addChild(h_currentLayer);
				else if (layers.length - 1 < 6)
					viewBackGround.addChild(h_currentLayer);
				else if (layers.length - 1 > 15)
					viewForeGround.addChild(h_currentLayer);
			}
			
			// Add the sprite to the appropriate group
			layers[gameObject.group].add(sprite, above);
			
			// Update sprite position avoiding flicking when sprite change parallax
  			sprite.nx = gameObject.x * sprite.parallax;
			sprite.ny = gameObject.y * sprite.parallax;
			updateArtOldState(sprite);
			smoothArtState(sprite, .5, .5);
			
			// The sprite.group will be updated in the update method like all its other values. This function is called after the updateGroupForSprite method.
			sprite.gameObject.updateGroup = false;
		}
		
		override public function render(support:RenderSupport, parentAlpha:Number):void {
			super.render(support, parentAlpha);
		}
		
		public var destroyed:Boolean;
		
		public function destroy():void{
			destroyed = true;
			camera.dispose();
			camera = null;
			var gameArt:GameArt;
			for each(gameArt in viewObjects) {
				gameArt.removeFromParent(true);
				gameArt.dispose();
			}
			layers.length = 0;
			//viewObjectsByName = null;
			viewObjects.length = 0;
			viewObjects = null;
			viewObjectsToUpdate.length = 0;
			viewObjectsToUpdate = null;
			physicsDebugView = null;
			debugViewTransformMatrix = null;
			originDysplayObject = null;
		}
	}
}