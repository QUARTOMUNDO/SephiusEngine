package SephiusEngine.displayObjects{
	import org.osflash.signals.Signal;

	import starling.animation.IAnimatable;
	import starling.display.Image;
	import starling.textures.Texture;
	
	/**
	 * Describe a single frame sequence. It´s the simplest animation class.
	 * @author Fernando Rabello, Aymeric
	 */
    public class SingleAnimation extends Image implements IAnimatable {
		public function get textures():Vector.<Texture> { return mTextures; }
        private var mTextures:Vector.<Texture>;
		
		private var mNumOfFrames:Number;
		private var mLastFrame:Number;
        private var mCurrentFrame:int;
        private var mPreviousFrame:int;
        private var mFrameDuration:Number;
		
        private var mCurrentTime:Number = 0;
        private var mTotalTime:Number;
		
        private var mLoop:Boolean;
        private var mPlaying:Boolean;
		public var onComplete:Signal = new Signal();
		
		public var texWidth:Number;
		public var texHeight:Number;
		
        /** Creates a movie clip from the provided textures and with the specified default framerate.
         *  The movie will have the size of the first frame. */  
        public function SingleAnimation(textures:Vector.<Texture>, fps:Number = 60, loop:Boolean = true){
            if (textures.length > 0){
                super(textures[0]);
				
                if(textures[0].frame){
                    texWidth = textures[0].frame.width;
                    texHeight = textures[0].frame.height;
				}
                else{
                    texWidth = textures[0].width;
                    texHeight = textures[0].height;
                }
                
				mNumOfFrames = textures.length;
				mLoop = loop;
				mCurrentTime = 0.0;
				mCurrentFrame = 0;
				mTextures = textures;
				mLastFrame = mNumOfFrames - 1;
				
				this.fps = fps;
				mPlaying = true;
            }
            else
                throw new ArgumentError("Empty texture array");
        }
        
        /** Returns the texture of a certain frame. */
        public function getFrameTexture(frameID:int):Texture{
            if (frameID < 0 || frameID >= numFrames) throw new ArgumentError("Invalid frame id");
            return mTextures[frameID];
        }
        
        /** Starts playback. Beware that the clip has to be added to a juggler, too! */
        public function play():void{
            mPlaying = true;
        }
        
        /** Pauses playback. */
        public function pause():void{
            mPlaying = false;
        }
        
        /** Stops playback, resetting "currentFrame" to zero. */
        public function stop():void{
            mPlaying = false;
            currentFrame = 0;
        }
        
        public function advanceTime(passedTime:Number):void{
            if(isNaN(currentTime))
                mCurrentTime = 0;

            if (!mPlaying || (!mLoop && isComplete)) return;
			
            var dispatchCompleteSignal:Boolean = false;
			
            mPreviousFrame = mCurrentFrame;
			mCurrentTime += passedTime;
			
			if (mLoop) {
				if (mCurrentTime >= totalTime)
					mCurrentTime -= totalTime;
				
				else if (mCurrentTime <= 0)
					mCurrentTime += totalTime;
			}
			else {
				if (mCurrentTime >= totalTime){
					mCurrentTime = totalTime;
					dispatchCompleteSignal = true;
				}
				
				else if (mCurrentTime <= 0){
					mCurrentTime = 0;
					dispatchCompleteSignal = true;
				}
			}
			
			mCurrentFrame = Math.floor(mCurrentTime / mFrameDuration);
			
			if(mCurrentFrame > mLastFrame)
				mCurrentFrame = mLastFrame;
			
			if(mCurrentFrame < 0)
				mCurrentFrame = 0;
			
            if (mCurrentFrame != mPreviousFrame)
                texture = mTextures[mCurrentFrame];
            
            if (dispatchCompleteSignal){
                if (onComplete.numListeners > 0)
					onComplete.dispatch();
			}

            if(isNaN(currentTime))
                throw Error("Time is NaN. Why??")
        }
        
        // properties  
        
        /** The total duration of the clip in seconds. */
        public function get totalTime():Number { return mTotalTime; }
        
        /** The time that has passed since the clip was started (each loop starts at zero). */
        public function get currentTime():Number { return mCurrentTime; }
        
        /** The total number of frames. */
        public function get numFrames():int { return mNumOfFrames; }
        
        /** Indicates if the clip should loop. */
        public function get loop():Boolean { return mLoop; }
        public function set loop(value:Boolean):void { mLoop = value; }
        
        /** The index of the frame that is currently displayed. */
        public function get currentFrame():int { return mCurrentFrame; }
        public function set currentFrame(value:int):void {
			if (value >= mTextures.length)
				value = mTextures.length - 1;
			
            mCurrentFrame = value;
            mCurrentTime = mCurrentFrame * mFrameDuration;
            texture = mTextures[mCurrentFrame];

            if(isNaN(currentTime))
                throw Error("Time is NaN. Why??")
        }
        
        public function get fps():Number { return mfps; }
        public function set fps(value:Number):void{
			if (mfps == value)
				return;
			
            if (value <= 0) throw new ArgumentError("Invalid fps: " + value);
			
			mfps = value;
			
            var newFrameDuration:Number = 1.0 / mfps;
            var acceleration:Number = newFrameDuration / mFrameDuration;
            mCurrentTime *= acceleration;
            mFrameDuration = newFrameDuration;
			mTotalTime = mNumOfFrames * mFrameDuration;
        }
        private var mfps:int;
		
        /** Indicates if the clip is still playing. Returns <code>false</code> when the end 
         *  is reached. */
        public function get isPlaying():Boolean {
            if (mPlaying)
                return mLoop || mCurrentTime < totalTime;
            else
                return false;
        }
		
        /** Indicates if a (non-looping) movie has come to its end. */
        public function get isComplete():Boolean{
            return !mLoop && mCurrentTime >= totalTime;
        }
    }
}