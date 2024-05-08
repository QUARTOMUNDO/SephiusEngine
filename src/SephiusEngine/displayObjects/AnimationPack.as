package SephiusEngine.displayObjects 
{
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.displayObjects.GameArt;
	import SephiusEngine.displayObjects.SingleAnimation;
	import SephiusEngine.utils.ColorsUtils;
	import SephiusEngine.utils.pools.RectanglePool;

	import com.greensock.TweenMax;

	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	import org.osflash.signals.Signal;

	import starling.animation.IAnimatable;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	/**
	 * AtlasAnimation is the most important class for animation in the Light of the Darkness game
	 * Its works with AtlasManager and uses texture atlas for dealing with frames animation
	 * Its mimmics normal display object so there is no need to worry about witch SingleAnimation/texture is being on screen
	 * Its will return values for normal properties like frameRate, color, alpha, visible and etc as this object would be single display object
	 * @author Fernando Rabello, Aymeric
	 */
	public class AnimationPack extends Sprite implements IAnimatable {
		/** A prefix to identify the object in the Asset Manager when geting the animations*/
		public var objectBaseName:String;
		/** Some times to conserve memory sprites could be loaded half resolution or lower, but also it need to match character size some cases (weapons, coatings). Put resolution to low and AnimationEffect will scale sprite to make it apear same size if it has full resolution.*/
		public var resolution:String = "normal";
		/** set false if textures alrady loaded for this sprite sheet */
		public var loadTextures:Boolean = true;
		/** The signal is dispatched each time an animation is completed, sending the animation name as argument. */
		public var onAnimationComplete:Signal;
		/** The signal is dispatched each time animation change frame, sending the animation name as argument and the frame number. */
		public var onFrameChange:Signal;
		/** The signal is dispatched each time animation change, sending the new animation name and the previous animation name as argument*/
		public var onAnimationChange:Signal;
		
		public var dispatchOnFrameChange:Boolean;
		
		public var activated:Boolean = false;
		
		public var firstAnimation:String = "";
		public var mSmoothing:String;
		
		/** If you want this class tracing some info */
		public var verbose:Boolean = false;
		
		/** Dispach when this object are fully loaded and created */
		public var onReady:Signal;
		private var callback:Array;
		
		public var numOfAnimations:uint = 0;
		
		/**If true it will automacly play the animation when created */
		private var autoPlayFistAnimation:Boolean = false;
		public var forceLoopType:String = "none";
		/** If true, AnimationPack will checkin and checkout automatcly.*/
		private var checkInOut:Boolean;
		
		public var fadeIn:Boolean = true;
		public var fadeInTime:Number = 1;
		private var originalalpha:Number = 1;
		
		public var centerAlignment:Boolean = true;
		
		public function AnimationPack(objectBaseName:String, callbacks:Array, animFps:Number = 30, smoothing:String = "bilinear", autoPlayFistAnimation:Boolean = false, forceLoopType:String = "none", originalAlpha:Number = 1, fadeIn:Boolean = true, chekinAssets:Boolean = true, centerAlignment:Boolean  = true, asymmetric:Boolean=false) {
			super();
			
			this.name = objectBaseName + "_SpriteSheet" + int(Math.random() * 1000);
			this.objectBaseName = objectBaseName;
			this.frameRate = animFps;
			this.mSmoothing = smoothing;
			this.autoPlayFistAnimation = autoPlayFistAnimation;
			this.callback = callback;
			this.forceLoopType = forceLoopType;
			this.fadeIn = fadeIn;
			this.originalalpha = originalAlpha;
			this.centerAlignment = centerAlignment;
			
			//frameBoundRect = RectanglePool.getRectangle(); // moved to class
			
			onAnimationComplete = new Signal(String);
			onFrameChange = new Signal(String, Number);
			onReady = new Signal(AnimationPack);
			onAnimationChange = new Signal(String, String);
			
			var _function:Function;
			for each(_function in callbacks)
				if(_function)
					onReady.add(_function);
			
			checkInOut = chekinAssets;
			this.assymmetric = asymmetric;

			if(asymmetric){
				mRightSequences = new Dictionary();
				mRightSequencesVector = new Vector.<SingleAnimation>();

				mLeftSequences = new Dictionary();
				mLeftSequencesVector = new Vector.<SingleAnimation>();
				
				if(checkInOut){
					GameEngine.assets.checkInTexturePack(objectBaseName + "L", initLeft, "AnimationPack_" + this.name);
					GameEngine.assets.checkInTexturePack(objectBaseName + "R", initRight, "AnimationPack_" + this.name);
				}
				else{
					initLeft(objectBaseName + "L");
					initRight(objectBaseName + "R");
				}
			}
			else{
				mSequences = new Dictionary();
				mSequencesVector = new Vector.<SingleAnimation>();

				if(checkInOut){
					GameEngine.assets.checkInTexturePack(objectBaseName, initSymetrical, "AnimationPack_" + this.name);
				}
				else{
					initSymetrical(objectBaseName);
				}
			}
		}
		
		private var rightReady:Boolean = false;
		private var leftReady:Boolean = false;

		private function initSymetrical(objectName:String):void{
			init(objectName, mSequences, mSequencesVector);
			onReady.dispatch(this);
		}


		private function initRight(objectName:String):void{
			init(objectName, mRightSequences, mRightSequencesVector);
			rightReady = true;

			if(rightReady && leftReady)
				onReady.dispatch(this);
		}


		private function initLeft(objectName:String):void{
			init(objectName, mLeftSequences, mLeftSequencesVector);
			leftReady = true;

			if(rightReady && leftReady)
				onReady.dispatch(this);
		}


		private function init(objectName:String, sequences:Dictionary, mSequencesVector:Vector.<SingleAnimation>):void {
			//trace("[SPRITESHEETANIMATION2] " + this.name, objectName);
			//if (objectName != objectBaseName)
				//return;
			
			if (mDisposed) {
				//onReady.removeAll();
				//if(checkInOut);
					//GameEngine.assets.checkOutTexturePack(objectName, "AnimationPack_" + this.name);
				return;
			}
			
			numOfAnimations = 0;
			animationNames = GameEngine.assets.getSubTexturesNames(objectName);
			
			var animationName:String;
			var textureSize:Rectangle;
			var singleAnimation:SingleAnimation;
			
			for each (animationName in animationNames) {
				singleAnimation = new SingleAnimation(GameEngine.assets.getTextures(objectName, animationName), _frameRate, forceLoop ? true : forceLoopType == "first" ? animationName.slice(0, 7) == "default" ? true : false : GameEngine.assets.getTextureCache(objectName, animationName).loop);
				singleAnimation.name = animationName;
				singleAnimation.smoothing = mSmoothing;
				
				//textureSize = GameEngine.assets.getTextureSize(objectName);
				
				if(centerAlignment){
					singleAnimation.pivotX = singleAnimation.texWidth * .5;
					singleAnimation.pivotY = singleAnimation.texHeight * .5;
				}
				
				numOfAnimations++;
				
				if(animationName == "default" || firstAnimation == "")
					firstAnimation = animationName;
				
				sequences[animationName] = singleAnimation;
				mSequencesVector.push(singleAnimation);
			}
			
			if (forceLoopType == "all")
				_forceLoop = true;
			
			isReady = true;
			
			if (autoPlayFistAnimation)
				changeAnimation(firstAnimation);
			
			if(fadeIn) {
				alpha = 0;
				TweenMax.to(this, fadeInTime, { alpha:originalalpha } );
			}
			else {
				alpha = 1;
			}
			
			//trace("[SPRITESHEETANIMATION] " + "dispathing " + objectName + " signal with: " + onReady.numListeners + " listners");
		}
		
		override public function alignPivot(hAlign:String = "center", vAlign:String = "center"):void {
			//trace("alinign AnimationPAck");
			super.alignPivot(hAlign, vAlign);
		}
		
		private var _pivotX:Number = 0;
		override public function get pivotX():Number {return _pivotX;}
		override public function set pivotX(value:Number):void {
			_pivotX = value;
		}
		
		private var _pivotY:Number = 0;
		override public function get pivotY():Number {return _pivotY;}
		override public function set pivotY(value:Number):void {
			_pivotY = value;
		}

		/** Tell if this animation pack represen a assymetric art which variates depending if is inverted or not.
		 * If false, this art will only be fliped when object is inverted.
		 */
		public var assymmetric:Boolean = false;

		/** Change art depending on if is inverted or not. Used for objects that have left/right distinction */
		public function get rightSide():Boolean{return _rightSide;}
		public function set rightSide(value:Boolean):void{
			if(!assymmetric)
				return;

			if(_rightSide == value)
				return;

			_rightSide = value;

			if(currentSequence && currentSequence.parent == this){
				removeChild(currentSequence);
				GameEngine.instance.state.gameJuggler.remove(this);
			}
			var cCurrentFrame:uint = currentFrame;

			mCurrentSequence = sequences[currentAnimation];

			if (hasAnimationCompleted || !mCurrentSequence) {
				return;
			}

			updateAnimation();

			addChildAt(mCurrentSequence, 0);
			mCurrentSequence.currentFrame = cCurrentFrame;

			textureBoundDefined = false;
		}
		private var _rightSide:Boolean = true;

		/** Get sequences depending if is assymetrical or not and if it is the right or left sequences */
		public function get sequences():Dictionary {
			if(assymmetric){
				if(_rightSide)
					return mRightSequences;
				else
					return mLeftSequences;	
			}
			else 
				return mSequences;
		}

		public var mLeftSequences:Dictionary;
		public var mRightSequences:Dictionary;

		protected var mLeftSequencesVector:Vector.<SingleAnimation>;
		protected var mRightSequencesVector:Vector.<SingleAnimation>;	

		/** Dictionary containing all animations registered thanks to their string name.*/
		protected var mSequences:Dictionary;
		
		/** Dictionary containing all animations in a vector.*/
		protected var mSequencesVector:Vector.<SingleAnimation>;	
		
		public function get previousSequence():SingleAnimation { return  mPreviousAnimation == "" ? null : (mPreviousSequence); }
		private var mPreviousSequence:SingleAnimation;
		
		public function get currentSequence():SingleAnimation { return mCurrentAnimation == "" ? null : (mCurrentSequence); }
		private var mCurrentSequence:SingleAnimation;
		
		public function get frameChanged():Boolean { return currentSequence ? mPreviousFrame != currentSequence.currentFrame : false };
		
		public function advanceTime(time:Number):void {
			hasAnimationCompleted = false;
			hasAnimationChanged = false;
			
			if (!currentSequence)
				return;
			
			if(_isPlaying)	
				currentSequence.play();
			else
				currentSequence.stop();
			
			currentSequence.fps = _frameRate;
			currentSequence.color = _tranformedColor;
			mPreviousFrame = currentSequence.currentFrame;
			
			if (_forceLoop && !currentSequence.loop)
				currentSequence.loop = true;
			
			currentSequence.advanceTime(time);
			
			currentSequence.x = -_pivotX;
			currentSequence.y = -_pivotY;
			
			//trace(name, currentSequence.name, currentSequence.currentFrame)
			
			if (mPreviousFrame != currentSequence.currentFrame){
				if(dispatchOnFrameChange)
					onFrameChange.dispatch(mCurrentAnimation, currentSequence.currentFrame); 
				textureBoundDefined = false;
			}
			
			if(currentSequence.isComplete && !hasAnimationCompleted){
				onAnimationComplete.dispatch(currentSequence.name);
				hasAnimationCompleted = true;
			}
		}
		
		public var hasAnimationCompleted:Boolean = false;
		public var hasAnimationChanged:Boolean = false;
		
		public var animationNames:Vector.<String> = new Vector.<String>();

		private var gameArt:GameArt;
		private var cParent:DisplayObjectContainer;

		/**
		 * Called by StarlingArt, managed the MC's animations.
		 * @param animation the MC's animation
		 * @param animLoop true if the MC is a loop
		 */
		public function changeAnimation(animation:String):Boolean {
			if (!isReady)
				return false;
			
			if(currentSequence && currentSequence.parent == this){
				removeChild(currentSequence);
				GameEngine.instance.state.gameJuggler.remove(this);
			}
			
			mPreviousSequence = mCurrentSequence;
			mCurrentSequence = sequences[animation];

			mPreviousAnimation = mCurrentAnimation;
			mCurrentAnimation = animation;

			if (!mCurrentSequence) {
				log("ANIMATION SEQUENCE WARNING: " + this.name + " doesn't have the " + animation + " animation set up in its animations' array");
				return false;
			}
			
			hasAnimationCompleted = false;
			hasAnimationChanged = true;
			//mPreviousAnimation = mCurrentAnimation;
			//mCurrentAnimation = animation;
			onAnimationChange.dispatch(animation, mPreviousAnimation);
			
			updateAnimation();

			if(dispatchOnFrameChange)
				onFrameChange.dispatch(mCurrentAnimation, mCurrentSequence.currentFrame);

			//log("[SPRITESHEETANIMATION]: " + this.name + " animation: " + animation  + " " + currentSequence.parent + " ");
			addChildAt(mCurrentSequence, 0);
			mCurrentSequence.currentFrame = 0;
			
			return true;
		}
		
		public function updateAnimation():void{
			mCurrentSequence.x = -_pivotX;
			mCurrentSequence.y = -_pivotY;
			
			mCurrentSequence.color = mColor;
			mCurrentSequence.fps = _frameRate;
			
			textureBoundDefined = false;
			
			while (!gameArt && cParent){ 
				gameArt = cParent as GameArt;
				cParent = cParent.parent;
			}
			
			if ((gameArt && gameArt.activated && activated) || (!gameArt && activated)) {
				GameEngine.instance.state.gameJuggler.add(this);
			}
			
			//log("[SPRITESHEETANIMATION]: " + this.name + " animation: " + animation  + " " + currentSequence.parent + " ");
		}

		public function activate():void {
			if (!activated) {
				activated = true;
				
				//var gameArt:GameArt;
				//var parent:DisplayObjectContainer = this.parent;
				
				while (!gameArt && cParent){ 
					gameArt = cParent as GameArt;
					cParent = cParent.parent;
				}
				
				if ((gameArt && gameArt.activated && activated) || (!gameArt && activated)) {
					GameEngine.instance.state.gameJuggler.add(this);
				}
			}
		}
		
		public function deactivate():void {
			if (activated) {
				
				activated = false;
				
				GameEngine.instance.state.gameJuggler.remove(this);
			}
		}
		
		/** Pause the current sequence. Same thing as the pauseAnimation but more simple way. */
		public function pause():void { _isPlaying = false; }
		
		/** Plays the current sequence if it wasn´t already playing*/
		public function play():void { _isPlaying = true; }
		
		/** Return the current frame of the current senquence */
		public function get currentFrame():int { return (isReady && currentSequence) ? currentSequence.currentFrame : 0;}
		public function set currentFrame(value:int):void {
			if(isReady && currentSequence){
				currentSequence.currentFrame = value;
				if(dispatchOnFrameChange)
					onFrameChange.dispatch(mCurrentAnimation, currentSequence.currentFrame);
				hasAnimationCompleted = false;
			}
		}
		
		/** Return the frame before of the current frame of the senquence. 
		 * Note that for animations slower than the game frame rate some frames repeats. 
		 * So last frame could be equal to the current frame some times.*/
		public function get previousFrame():int {return mPreviousFrame;}
		public function set previousFrame(value:int):void {mPreviousFrame = value;}
		private var mPreviousFrame:uint;
		
		/** Verify if animation is in a particular frame but this frame but is not the second time this frame is happaning in a roll
		 * Used as "currentFrame" in cases animation run at a lower framerate than the game (30/60 for example) witch makes some frames to repeat some times
		 * Does not work if game run at a lower frame rate than the animation*/
		public function currentFrameOnce(frame:uint):Boolean {
			return (isReady && currentSequence) ? (mPreviousFrame < frame && frame <= currentSequence.currentFrame) : false;
		}
		
		/**Return the total number of frames of the current senquence*/
		public function get numFrames():int {
			return (isReady && currentSequence) ? currentSequence.numFrames : 0;
		}
		
		/**  Return true if the current sequence has it animation completed*/
		public function get isComplete():Boolean { return hasAnimationCompleted; }
		
		public function get currentAnimation():String { return mCurrentAnimation;}
		protected var mCurrentAnimation:String = "";
		
		public function get previousAnimation():String {return mPreviousAnimation;}
		protected var mPreviousAnimation:String = "";
		
		/** Indicates if the current sequence is looping. */
		public function get loop():Boolean { return (isReady && currentSequence) ? currentSequence.loop : false; }
		
		/** Indicates if the all sequences should loop. */
		public function get forceLoop():Boolean {return _forceLoop;	}
		public function set forceLoop(value:Boolean):void { _forceLoop = value; }
		private var _forceLoop:Boolean;
		
        /** Indicates if the clip is still playing. Returns <code>false</code> when the end 
         *  is reached. */
		public function get isPlaying():Boolean { return  _isPlaying ; }
		public function set isPlaying(value:Boolean):void { _isPlaying = value; }
		private var _isPlaying:Boolean = true;
		
		/** Return the total time of the current senquence*/
		public function get totalTime():Number { return (isReady && currentSequence) ? currentSequence.totalTime : 0; }
		
		/** Return the current time of the current senquence*/
		public function get currentTime():Number { return (isReady && currentSequence) ? currentSequence.currentTime : 0; }
		
		public function get frameRate():uint { return _frameRate; } 
		public function set frameRate(value:uint):void { _frameRate = value; }
		private var _frameRate:uint = 30;
		
		/**
		 * You can change the color of you animation with this propriety
		 * Since Animation Sequence has a lot of SingleAnimations inside, that changes when every animation changes
		 * It´s automatcly updates color of current sequence when animation changes.
		 * So you not neet to worry about update color every animation changes.
		 */
		public function get color():uint {return mColor;}
		public function set color(value:uint):void {
			mColor = value;
			_tranformedColor = ColorsUtils.subtract(mColor, _parentColor);
		}
		private var mColor:Number = 0xffffff;
		
		/** Color assigned to this parent. It need to be informed manually */
		public function setParentColor(value:uint):void {
			_parentColor = value;
			_tranformedColor = ColorsUtils.subtract(mColor, _parentColor);
		}
        private var _parentColor:uint = 0xffffff;
		
		/** Return the color taking into account quad parents colors */
		public function get tranformedColor():uint {return _tranformedColor;}
        private var _tranformedColor:uint = 0xffffff;
		
		public function get isReady():Boolean {return mIsReady;}
		public function set isReady(value:Boolean):void { mIsReady = value; }
		/** Tell when Sprite Sheet is ready to be used */
		private var mIsReady:Boolean = false;
		
		override public function get parent():DisplayObjectContainer { return super.parent; }
		
		override public function addChild(child:DisplayObject):DisplayObject { return super.addChild(child); }
		
		public var textureBoundDefined:Boolean;

		private var frameBoundRect:Rectangle = RectanglePool.getRectangle();

		private static var sHelperMatrix:Matrix = new Matrix();
		private static var sHelperPoint:Point = new Point();
		private var cropLeft:Number; private var cropTop:Number; private var cropRight:Number; private var cropButtom:Number; private var cropIdentical:Boolean;
		private var bx1:Number; private var by1:Number; private var bx2:Number; private var by2:Number; private var bx3:Number; private var by3:Number; private var bx4:Number; private var by4:Number;
		
		private var frameX:Number;
		private var frameY:Number;
		private var frameWidth:Number;
		private var frameHeight:Number;

		private var texWidth:Number;
		private var texHeight:Number;


		/** Return the bound of the object taking into account the texture frame/crop data.
		 * In pratical, this return the bound of the non 0 alpha pixels.
		 * Also support crop returning a smaller/grater bound by pass number for each side.*/
		public function getFrameBounds(targetSpace:DisplayObject, resultRect:Rectangle = null, cropLeft:Number = 0, cropRight:Number = 0, cropTop:Number = 0, cropButtom:Number = 0):Rectangle {
			var texture:Texture; var lastTexture:Texture; var hI:int;
			var minX:Number; var minY:Number; var maxX:Number; var maxY:Number;
				
			if (resultRect == null) resultRect = new Rectangle();
			
			if( this.cropLeft == cropLeft &&
				this.cropTop == cropTop &&
				this.cropRight == cropRight &&
				this.cropButtom == cropButtom) {
				cropIdentical = true;	
			}
			else {
				cropIdentical = false;
			}
			
			this.cropLeft = cropLeft;
			this.cropTop = cropTop;
			this.cropRight = cropRight;
			this.cropButtom = cropButtom;
			
			//texture = getCurrentFrameTexture();
			if(currentSequence)
				texture = currentSequence.getFrameTexture(currentFrame);
			else
				texture = null;
				
			if(texture == lastTexture)
				textureBoundDefined = false;
			
			if(!textureBoundDefined || !cropIdentical){
				if(!texture ){
					texWidth = 0;
					texHeight = 0;
				}
				else{
					texWidth = texture.width;
					texHeight = texture.height;
				}

				if (!texture || (texWidth <= 1 || texHeight <= 1)) {
					resultRect.setTo(frameBoundRect.x, frameBoundRect.y, frameBoundRect.width, frameBoundRect.height);
					return resultRect;
				}
				
				texWidth = texWidth;
				texHeight = texHeight;

				if(texture.frame){
					frameX = texture.frame.x;
					frameY = texture.frame.y;
					frameWidth = texture.frame.width;
					frameHeight = texture.frame.height;
				}
				else{
					frameX = 0;
					frameY = 0;
					frameWidth = texWidth;
					frameHeight = texHeight;
				}

				bx1 = -frameX -frameWidth * .5 + cropLeft;
				by1 = -frameY -frameHeight * .5 + cropTop;
				
				bx2 = -frameX + texWidth -frameWidth * .5 - cropRight;
				by2 = -frameY -frameHeight * .5 + cropTop;
				
				bx3 = -frameX -frameWidth * .5 + cropLeft;
				by3 = -frameY + texHeight -frameHeight * .5 - cropButtom;
				
				bx4 = -frameX + texWidth -frameWidth * .5 - cropRight;
				by4 = -frameY + texHeight -frameHeight * .5 - cropButtom;
				
				textureBoundDefined = true;
			}

			if (!getTransformationMatrix(targetSpace, sHelperMatrix)){
				resultRect.setTo(0, 0, 0, 0);
				return resultRect;
			}

			minX = Number.MAX_VALUE, maxX = -Number.MAX_VALUE;
			minY = Number.MAX_VALUE, maxY = -Number.MAX_VALUE;

			for (hI = 1; hI <= 4; ++hI) {
				//transformCoords(sHelperMatrix, this["bx"+hI], this["by"+hI], sHelperPoint);
				
				sHelperPoint.x = sHelperMatrix.a * this["bx"+hI] + sHelperMatrix.c * this["by"+hI] + sHelperMatrix.tx;
				sHelperPoint.y = sHelperMatrix.d * this["by"+hI] + sHelperMatrix.b * this["bx"+hI] + sHelperMatrix.ty;
				
				if (minX > sHelperPoint.x) minX = sHelperPoint.x;
				if (maxX < sHelperPoint.x) maxX = sHelperPoint.x;
				if (minY > sHelperPoint.y) minY = sHelperPoint.y;
				if (maxY < sHelperPoint.y) maxY = sHelperPoint.y;
			}
			
			frameBoundRect.setTo(minX, minY, maxX - minX, maxY - minY);
			resultRect.setTo(minX, minY, maxX - minX, maxY - minY);
			
			return resultRect;
		}

        /** Uses a matrix to transform 2D coordinates into a different space. If you pass a
         *  'resultPoint', the result will be stored in this point instead of creating a
         *  new object. */
        public function transformCoords(matrix:Matrix, x:Number, y:Number,
                                               resultPoint:Point=null):Point{
            if (resultPoint == null) resultPoint = new Point();

            resultPoint.x = matrix.a * x + matrix.c * y + matrix.tx;
            resultPoint.y = matrix.d * y + matrix.b * x + matrix.ty;

            return resultPoint;
        }

        /** Returns the texture of the current frame. */
        public function getCurrentFrameTexture():Texture {
			if(currentSequence)
				return currentSequence.getFrameTexture(currentFrame);
			else 
				return null;
		}
		
		private var mDisposed:Boolean = false;
		public function get disposed():Boolean { return mDisposed; }
		override public function dispose():void {
			if (mDisposed)
				return;
			
			if(parent)
				removeFromParent();
			
			deactivate();
			
			//Remove signals
			//trace ("disposing atlas animation", name, this.x);
			onAnimationComplete.removeAll();
			onAnimationComplete = null;

			onReady.removeAll();
			onReady = null;
			
			onFrameChange.removeAll();
			onFrameChange = null;
			
			onAnimationChange.removeAll();
			onAnimationChange = null;

			isReady = leftReady = rightReady = hasAnimationCompleted = false;
			
			if(callback){
				callback.length = 0;
				callback = null;
			}
			
			if(currentSequence && currentSequence.parent)
				removeChild(currentSequence);
			

			var index:int;

			if(!assymmetric){
				//Remove onComplete listners and dispose all MCs
				for (index in mSequencesVector) {
					mSequencesVector[index].dispose();
					mSequencesVector[index] = null;
				}
				
				mSequencesVector.length = 0;

				//Checkout texture source group. When there is no other object using this group of assets, it will be automatcly disposed.
				if(checkInOut){
					GameEngine.assets.checkOutTexturePack(objectBaseName, "AnimationPack_" + this.name);
					GameEngine.assets.textures.removeCallback(objectBaseName, initSymetrical);
				}
			}
			else{
				//Remove onComplete listners and dispose all MCs
				for (index in mLeftSequencesVector) {
					mLeftSequencesVector[index].dispose();
					if(mRightSequencesVector.length < index){
						mRightSequencesVector[index].dispose();
						mRightSequencesVector[index] = null;
					}
					mLeftSequencesVector[index] = null;
					
				}

				mLeftSequencesVector.length = 0;
				mRightSequencesVector.length = 0;
				
				//Checkout texture source group. When there is no other object using this group of assets, it will be automatcly disposed.
				if(checkInOut){
					GameEngine.assets.checkOutTexturePack(objectBaseName + "L", "AnimationPack_" + this.name);
					GameEngine.assets.checkOutTexturePack(objectBaseName + "R", "AnimationPack_" + this.name);
					GameEngine.assets.textures.removeCallback(objectBaseName + "L", initLeft);
					GameEngine.assets.textures.removeCallback(objectBaseName + "R", initRight);
				}
			}
			
			mSequences = null;
			RectanglePool.returnRectangle(frameBoundRect);
			//frameBoundRect = null;
			super.dispose();
			
			mDisposed = true;
		}
		
		private function log(message:String):void {
			if (verbose)
				trace(message);
		}
	}

}