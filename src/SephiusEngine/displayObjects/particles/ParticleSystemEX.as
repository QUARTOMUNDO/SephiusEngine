// =================================================================================================
//
//	Starling Framework - Particle System Extension
//	Copyright 2012 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package SephiusEngine.displayObjects.particles{
	import SephiusEngine.core.GameCamera;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.GamePhysics;
	import SephiusEngine.displayObjects.configs.SubTextureConfig;
	import SephiusEngine.displayObjects.configs.TexturesCache;
	import SephiusEngine.displayObjects.particles.system.EXParticle;
	import SephiusEngine.displayObjects.particles.system.Frame;
	import tLotDClassic.GameData.Properties.ParticleSystemProperties;
	import SephiusEngine.displayObjects.particles.system.ParticleEmitter;
	import SephiusEngine.levelObjects.interfaces.IAttractor;
	import SephiusEngine.levelObjects.interfaces.IEssenceAbsorber;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import nape.geom.Ray;
	import nape.geom.RayResult;
	import nape.geom.Vec2;
	import nape.shape.ShapeList;
	import nape.space.Space;
	import org.osflash.signals.Signal;
	import starling.animation.IAnimatable;
	import starling.animation.Juggler;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.DisplayObject;
	import starling.errors.MissingContextError;
	import starling.events.Event;
	import starling.extensions.particles.ColorArgb;
	import starling.filters.FragmentFilter;
	import starling.textures.SubTexture;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	import starling.utils.MatrixUtil;
	import starling.utils.VertexData;
	
	/**
	 * @author Fernando Rabello, Michael Trenkler
	 * @see http://flintfabrik.de
	 * @see #ParticleSystemEX()
	 * @see #init() ParticleSystemEX.init()
	 */
	public class ParticleSystemEX extends DisplayObject implements IAnimatable{
		/** The maximum number of particles possible (16383 or 0x3FFF). */
		public static const MAX_CAPACITY:int = 16383;
		
		/** If the systems duration exceeds as well as all particle lifespans, a complete event is fired and
		 * the system will be stopped. If this value is set to true, the particles will be returned to the pool.
		 * This does not affect any manual calls of stop.
		 * @see #start()
		 * @see #stop() */
		public static var autoClearOnComplete:Boolean = true;
		
		/** If the systems duration exceeds as well as all particle lifespans, a complete event is fired and
		 * the system will be stopped. If this value is set to true, the particles will be returned to the pool.
		 * This does not affect any manual calls of stop.
		 * @see #start()
		 * @see #stop() */
		public var autoClearOnComplete:Boolean = ParticleSystemEX.autoClearOnComplete;
		
		/** Forces the the sort flag for custom sorting on every frame instead of setting it when particles are removed. */
		public var forceSortFlag:Boolean = false;
		
		/** Set this Boolean to automatically add/remove the system to/from juggler, on calls of start()/stop().
		 * @see #start()
		 * @see #stop()
		 * @see #defaultJuggler
		 * @see #juggler() */
		public static var automaticJugglerManagement:Boolean = true;
		
		/** Default juggler to use when <a href="#automaticJugglerManagement">automaticJugglerManagement</a>
		 * is active (by default this value is the Starling's juggler).
		 * Setting this value will affect only new particle system instances.
		 * Juggler to use can be also manually set by particle system instance.
		 * @see #automaticJugglerManagement
		 * @see #juggler() */
		public static var defaultJuggler				:Juggler;
		protected var mJuggler							:Juggler = defaultJuggler;
		
		/** --------------------------------------------- */
		/** ---------------- System info----------------- */
		
		/** --------------------------------------------- */
		protected var mBatched							:Boolean = false;
		protected var mBatching							:Boolean = true;
		protected var mBounds							:Rectangle;
		protected var mCompleted						:Boolean;
		protected var mDisposed							:Boolean = false;
		protected var mFrameTime						:Number;
		public var areaRect:Rectangle;
		protected var mMaxCapacity						:int;
		protected var mNumBatchedParticles				:int = 0;
		protected var mNumParticles						:int = 0;
		protected var mPlaying							:Boolean = false;
		protected var mSmoothing						:String = TextureSmoothing.BILINEAR;
		protected var mSystemAlpha						:Number = 1;
		
		/** --------------------------------------------- */
		/** ----------particles / data / buffers--------- */
		/** --------------------------------------------- */
		
		protected static var sBufferSize				:uint = 0;
		protected static var sIndices					:Vector.<uint>;
		protected static var sIndexBuffer				:IndexBuffer3D;
		protected static var sParticlePool				:Vector.<EXParticle>;
		protected static var sPoolSize					:uint = 0;
		protected static var sVertexBufferIdx			:int = -1;
		protected static var sVertexBuffers				:Vector.<VertexBuffer3D>;
		protected static var sNumberOfVertexBuffers		:int;
		protected var mParticles						:Vector.<EXParticle>;
		protected var mVertexData						:VertexData;
		
		/** --------------------------------------------- */
		/** --------------- Animations Info -------------- */
		/** --------------------------------------------- */
		
		protected var mIsAnimated						:Boolean = false;
		protected var mLoops							:Number;
		protected var mFrameRate                        :int;
		protected var mFrameRateRatio					:Number = 1;
		protected var mRandomStartFrames				:Boolean = false;
		protected var mRandomArt						:Boolean = false;
		protected var mFrameLUT							:Vector.<Frame>;
		protected var mTexturesCaches					:Vector.<TexturesCache>;
		
		/** --------------------------------------------- */
		/** --------------- Shader Info ----------------- */
		/** --------------------------------------------- */
		protected var mTexture							:Texture;
		protected var mTinted							:Boolean = true;
		protected var mPremultipliedAlpha				:Boolean = true;
		protected var mFilter							:FragmentFilter = null;
		protected var mParticleBlendMode				:String;
		protected var mParticlePMA						:Boolean;
		
		/** --------------------------------------------- */
		/** --------------- Emitter Info ---------------- */
		/** --------------------------------------------- */
		/** List of emitters related witch this system */
		protected var mEmitters							:Vector.<ParticleEmitter> = new Vector.<ParticleEmitter>();
		
		/** Final number of particles that was created. -1 for infinite. If final count is archeved system will no longer create particles */
		public var finalCount							:int = 0;
		/** Final number of particles that can be created. -1 for infinite. If final count is archeved system will no longer create particles */
		public var finalAmount							:Number = -1;
		/** Dispach a signal when final amount is equal to final count */
		public var onDepleted							:Signal = new Signal();
		
		protected var mCurrentEmitter					:ParticleEmitter;
		
		protected var mEmitterIndex						:Number = -1;
		
		protected var mEmissionTime						:Number = -1;
		protected var mEmissionTimePredefined			:Number = -1;
		
		protected var mEmitterType						:uint;
		protected var mMaxNumParticles					:uint;
		
		protected var mEmitterX							:Number;
		protected var mEmitterY							:Number;
		protected var mEmitterXVariance					:Number;
		protected var mEmitterYVariance					:Number;
		protected var mEmitterRadius					:Number;
		protected var mEmitterRadiusVariance			:Number;
		protected var mEmissionAngle					:Number;
		protected var mEmissionAngleVariance			:Number;
		
		protected var mEmissionRotationSpeed			:Number;
		protected var mInheritEmissionAngle				:Boolean;
		protected var mEmissionRate						:Number = -1;
		
		/** --------------------------------------------- */
		/** --------------- Particle Info ----------------*/
		/** --------------------------------------------- */
		
		protected var mLifespan							:Number;
		protected var mLifespanVariance					:Number;
		protected var mSpawnTime						:Number = 0;
		protected var mFadeInTime						:Number = 0;
		protected var mFadeOutTime						:Number = 0;
		protected var mAlignedEmitterRotation			:Boolean = false;
		protected var mAlignedVelocityRotation			:Boolean = false;
		protected var mScaleMotionBlur					:Number = 0;
		public var mbUseCamera							:Boolean = false;
		public var mBounceCoefficient        			:Number = 1;
		protected var mBounceCoefficientVariance		:Number = 0;
		protected var mDisplacementX					:Number;
		protected var mDisplacementY					:Number;
		protected var mDisplacementRotation				:Number;
		protected var mStartSizeX						:Number; // startParticleSizeX
		protected var mStartSizeY						:Number; // startParticleSizeY
		protected var mStartSizeVarianceX				:Number; // startParticleSizeVarianceX
		protected var mStartSizeVarianceY				:Number; // startParticleSizeVarianceY
		protected var mEndSizeX							:Number; // finishParticleSizeX
		protected var mEndSizeY							:Number; // finishParticleSizeY
		protected var mEndSizeVarianceX					:Number; // finishParticleSizeVarianceX
		protected var mEndSizeVarianceY					:Number; // finishParticleSizeVarianceY
		protected var mSizeOscilationX					:Number;
		protected var mSizeOscilationY					:Number;
		protected var mSizeOscilationVarianceX			:Number;
		protected var mSizeOscilationVarianceY			:Number;
		protected var mSizeOscilationFrequencyX			:Number;
		protected var mSizeOscilationFrequencyY			:Number;
		protected var mSizeOscilationFrequencyVarianceX	:Number;
		protected var mSizeOscilationFrequencyVarianceY	:Number;
		protected var mSizeOscilationOffsetX			:Number;
		protected var mSizeOscilationOffsetY			:Number;
		protected var mStartRotation					:Number; // rotationStart
		protected var mStartRotationVariance			:Number; // rotationStartVariance
		protected var mEndRotation						:Number; // rotationEnd
		protected var mEndRotationVariance				:Number; // rotationEndVariance
		protected var mSpeed							:Number;
		protected var mSpeedVariance					:Number;
		
		/** --------------------------------------------- */
		/** --------------- Forces Info ----------------- */
		/** --------------------------------------------- */
		
		/** Determine if particles should collide with level */
		public var mPhysicsCollisions				:Boolean;
		protected var mWildness							:Number;
		protected var mWildnessVariance					:Number;
		protected var mGravityX							:Number; // gravity x
		protected var mGravityY							:Number; // gravity y
		protected var mRadialAcceleration				:Number; // radialAcceleration
		protected var mRadialAccelerationVariance		:Number; // radialAccelerationVariance
		protected var mTangentialAcceleration			:Number; // tangentialAcceleration
		protected var mTangentialAccelerationVariance	:Number; // tangentialAccelerationVariance
		protected var mRepelentForce					:Number;
		protected var mAttractorForce					:Number = -90000 * 800;
		protected var mPassiveAttraction				:Boolean = true;
		protected var mInheritVelocityX					:Number;
		protected var mInheritVelocityY					:Number;
		protected var mInheritVelocityXVariance			:Number;
		protected var mInheritVelocityYVariance			:Number;
		protected var mDrag								:Number;
		protected var mDragVariance						:Number;
		protected var mStartColor						:ColorArgb = new ColorArgb(1, 1, 1, 1); // startColor
		protected var mStartColorVariance				:ColorArgb = new ColorArgb(0, 0, 0, 0); // startColorVariance
		protected var mEndColor							:ColorArgb = new ColorArgb(1, 1, 1, 1); // finishColor
		protected var mEndColorVariance					:ColorArgb = new ColorArgb(0, 0, 0, 0); // finishColorVariance
		
		/** --------------------------------------------- */
		/** --------------- Other Info ------------------ */
		/** --------------------------------------------- */
		
		protected var mCustomFunc						:Function = undefined;
		protected var mSortFunction						:Function = undefined;
		protected var mExactBounds						:Boolean = false;
		protected var camera							:GameCamera;
		
		/** --------------------------------------------- */
		/** --------------- Helper objects -------------- */
		/** --------------------------------------------- */
		
		protected static var sHelperMatrix:Matrix = new Matrix();
		protected static var sHelperPoint:Point = new Point();
		protected static var sRenderAlpha:Vector.<Number> = new <Number>[1.0, 1.0, 1.0, 1.0];
		protected static var sRenderMatrix:Matrix3D = new Matrix3D;
		protected static var sInstances:Vector.<ParticleSystemEX> = new <ParticleSystemEX>[];
		protected static var sProgramNameCache:Dictionary = new Dictionary();
		
		protected static var sLUTsCreated:Boolean = false;
		protected static var sCosLUT:Vector.<Number> = new Vector.<Number>(0x800, true);
		protected static var sSinLUT:Vector.<Number> = new Vector.<Number>(0x800, true);
		protected static var sFixedPool:Boolean = false;
		protected static var sRandomSeed:uint = 1;
		
		/** All objects in state that can absorbe particles for any system active */
		public static var ATTRACTORS:Vector.<IAttractor> = new Vector.<IAttractor>();
		/** Dispach signal every frame particle is getting attracted per attractor. 
		 * You can logic related with relation of particle position and its attractor with this signal. */
		public var attractedParticleSignal:Signal = new Signal(EXParticle, ParticleSystemEX, IEssenceAbsorber);
		
		public var particleSystemProperties:ParticleSystemProperties;
		/** Creates a ParticleSystemEX instance.
		 * <p><strong>Note:  </strong>For best performance setup the system buffers by calling
		 * <a href="#ParticleSystemEX.init()">ParticleSystemEX.init()</a> <strong>before</strong> you create any instances!</p>
		 *
		 * <p>The config file has to be a XML in the following format, known as .pex file</p>
		 *
		 * <p><strong>Note:  </strong>It's strongly recommended to use textures with mipmaps.</p>
		 *
		 * <p><strong>Note:  </strong>You shouldn't create any instance before Starling created the context. Just wait some
		 * frames. Otherwise this might slow down Starling's creation process, since every ParticleSystemEX instance is listening
		 * for onContextCreated events, which are necessary to handle a context loss properly.</p>
		 * @param	config A SystemOptions instance
		 * @see #init() ParticleSystemEX.init() */
		public function ParticleSystemEX(config:ParticleSystemProperties){
			if (config == null)
				throw new ArgumentError("config must not be null");
			
			particleSystemProperties = config;
			
			sInstances.push(this);
			initInstance(config);
			
			camera = GameEngine.instance.state.view.camera;
			
			if(mPhysicsCollisions)
				space = GameEngine.instance.state.physics.space;
		}
		
		/** creating vertex and index buffers for the number of particles.
		 * @param	numParticles a value between 1 and 16383 */
		private static function createBuffers(numParticles:uint):void{
			if (sVertexBuffers)
				for (var i:int = 0; i < sVertexBuffers.length; ++i)
					sVertexBuffers[i].dispose();
			if (sIndexBuffer)
				sIndexBuffer.dispose();
			
			var context:Context3D = Starling.context;
			if (context == null) throw new MissingContextError();
			if (context.driverInfo == "Disposed") return;
			
			sVertexBuffers = new Vector.<VertexBuffer3D>();
			sVertexBufferIdx = -1;
			if (ApplicationDomain.currentDomain.hasDefinition("flash.display3D.Context3DBufferUsage"))
			{
				for (i = 0; i < sNumberOfVertexBuffers; ++i)
				{
					sVertexBuffers[i] = context.createVertexBuffer.call(context, numParticles * 4, VertexData.ELEMENTS_PER_VERTEX, "dynamicDraw"); // Context3DBufferUsage.DYNAMIC_DRAW; hardcoded for backward compatibility
				}
			}
			else
			{
				for (i = 0; i < sNumberOfVertexBuffers; ++i)
				{
					sVertexBuffers[i] = context.createVertexBuffer(numParticles * 4, VertexData.ELEMENTS_PER_VERTEX);
				}
			}
			
			var zeroBytes:ByteArray = new ByteArray();
			zeroBytes.length = numParticles * 16 * VertexData.ELEMENTS_PER_VERTEX; // numParticle * verticesPerParticle * bytesPerVertex * ELEMENTS_PER_VERTEX
			for (i = 0; i < sNumberOfVertexBuffers; ++i)
			{
				sVertexBuffers[i].uploadFromByteArray(zeroBytes, 0, 0, numParticles * 4);
			}
			zeroBytes.length = 0;
			
			if (!sIndices)
			{
				sIndices = new Vector.<uint>();
				var numVertices:int = 0;
				var indexPosition:int = -1;
				for (i = 0; i < MAX_CAPACITY; ++i)
				{
					sIndices[++indexPosition] = numVertices;
					sIndices[++indexPosition] = numVertices + 1;
					sIndices[++indexPosition] = numVertices + 2;
					
					sIndices[++indexPosition] = numVertices + 1;
					sIndices[++indexPosition] = numVertices + 3;
					sIndices[++indexPosition] = numVertices + 2;
					numVertices += 4;
				}
			}
			sIndexBuffer = context.createIndexBuffer(numParticles * 6);
			sIndexBuffer.uploadFromVector(sIndices, 0, numParticles * 6);
		}
		
		private function addedToStageHandler(e:starling.events.Event):void{
			mMaxCapacity = mMaxNumParticles ? Math.min(MAX_CAPACITY, mMaxNumParticles) : MAX_CAPACITY;
			
			if (e)
			{
				getParticlesFromPool();
				if (mPlaying)
					start(mEmissionTime);
			}
		}
		protected var HWildness:Number;
		protected var Hlifespan:Number;
		protected var Hangle:Number;
		protected var HangleDeg:Number;
		protected var Hspeed:Number;
		protected var HemitterRadiusX:Number;
		protected var HemitterRadiusY:Number;
		protected var speedInheritX:Number;
		protected var speedInheritY:Number;
		protected var HstartSizeX:Number;
		protected var HstartSizeY:Number;
		protected var HendSizeX:Number;
		protected var HendSizeY:Number;
		protected var HOSizeX:Number;
		protected var HOSizeY:Number;
		
		protected var HstartColorRed:Number;
		protected var HstartColorGreen:Number;
		protected var HstartColorBlue:Number;
		protected var HstartColorAlpha:Number;
		
		protected var HendColorRed:Number;
		protected var HendColorGreen:Number;
		protected var HendColorBlue:Number;
		protected var HendColorAlpha:Number;
		
		protected var HstartRotation:Number;
		protected var HendRotation:Number;
		protected var firstFrameWidth:Number;
		protected var firstFrameHeight:Number;
		protected var diagonalTextureSize:Number;
		protected var lastPositionX:Number;
		protected var cAnimaIdx:int = 0;
		protected var hFrameRate:uint;
		protected var fVelocityX:Number;
		protected var fVelocityY:Number;
		
		/** Sets the start values for a newly created particle, according to your system settings.
		 *
		 * <p>Note:
		 * 		The following snippet ...
		 *
		 * 			(((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
		 *
		 * 		... is a pseudo random number generator; directly inlined; to reduce function calls.
		 * 		Unfortunatelly it seems impossible to inline within inline functions.</p>
		 *
		 * @param	particle */
		[Inline]
		final protected function initParticle(particle:EXParticle):void{
			// for performance reasons, the random variances are calculated inline instead
			// of calling a function
			
			//Define Art, in case of multiple arts, define witch art this particle will use.
			//Define frame delta bases on texture cache framerate
			
			if (mTexturesCaches) {
				cAnimaIdx = mRandomArt ? mTexturesCaches.length * ((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x80000000) : cAnimaIdx;
				cAnimaIdx = cAnimaIdx > mTexturesCaches.length ? 0 : cAnimaIdx;
				particle.animationIdx = cAnimaIdx;
				hFrameRate = (mTexturesCaches[cAnimaIdx].frameRate * mFrameRateRatio);
				particle.frameAmount = mTexturesCaches[cAnimaIdx].configs.length;
				particle.frameIdx = particle.frame = mRandomStartFrames ? mTexturesCaches[cAnimaIdx].configs.length * ((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x80000000) : 0;
				particle.frameDelta = particle.frameAmount > 1 ? (hFrameRate) : 0;
				//cAnimaIdx++;
				
				if (mLifespan == -1)
					Hlifespan = mTexturesCaches[particle.animationIdx].configs.length  / hFrameRate;
				else 
					Hlifespan = mLifespan;
			}
			else if (mFrameLUT) {
				// No mult art here
				if (mIsAnimated) {
					hFrameRate = mFrameRate;
					particle.animationIdx = 0;
					particle.frameIdx = particle.frame = mRandomStartFrames ? mFrameLUT.length * ((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x80000000) : 0;
					particle.frameDelta = hFrameRate;
					particle.frameAmount = mFrameLUT.length ;
					
					if (mLifespan == -1)
						Hlifespan = mFrameLUT.length  / hFrameRate;
					else 
						Hlifespan = mLifespan;
				}
				//Mult art
				else {
					cAnimaIdx = mRandomArt ? (mFrameLUT.length * ((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x80000000)) : cAnimaIdx;
					cAnimaIdx = cAnimaIdx >= mFrameLUT.length ? 0 : cAnimaIdx;
					particle.animationIdx = 0;
					particle.frameIdx = cAnimaIdx;
					particle.frameDelta = 0;
					particle.frameAmount = 1;
					//cAnimaIdx++;
					
					if (mLifespan == -1)
						Hlifespan = 5;
					else 
						Hlifespan = mLifespan;
				}
			}
			
			Hlifespan = Hlifespan + mLifespanVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			Hlifespan = Hlifespan < 0 ? 0: Hlifespan;
			
			particle.justActivated = true;
			particle.sleeping = false;
			particle.active = true;
			particle.currentTime = 0.0;
			particle.totalTime = Hlifespan;
			particle.loopCount = 0;
			
			if (Hlifespan <= 0.0)
				return;
			
			HWildness = mWildness + mWildnessVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			particle.wildness = HWildness;
			
			HangleDeg = (particle.emitter.emissionAngle + particle.emitter.emissionAngleVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0));
			
			if(mInheritEmissionAngle && particle.emitter && particle.emitter.emitterRotation)
				HangleDeg += particle.emitter.emitterRotation;
			
			Hangle = (HangleDeg * 325.94932345220164765467394738691) & 2047;//Put value on one of the 2048 valores stores on LUT
			
			Hspeed = (mSpeed + mSpeedVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0)) * HWildness;
			
			HemitterRadiusX = sCosLUT[Hangle] * (particle.emitter.emitterRadius + (particle.emitter.emitterRadiusVariance) * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0));
			HemitterRadiusY = sSinLUT[Hangle] * (particle.emitter.emitterRadius + (particle.emitter.emitterRadiusVariance) * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0));
			
			particle.bounceCoefficient = mBounceCoefficient * (mBounceCoefficientVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0)) + mBounceCoefficient;
			particle.displacementX = -(mDisplacementX * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x80000000)));
			particle.displacementY = -(mDisplacementY * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x80000000)));
			particle.displacementRotation = mDisplacementRotation * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			
			particle.x = particle.oldX = particle.emitter.emitterX + HemitterRadiusX + particle.emitter.emitterXVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			particle.y = particle.oldY = particle.emitter.emitterY + HemitterRadiusY + particle.emitter.emitterYVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			
			particle.sleeping = false;
			particle.collided = false;
			particle.numCollisions = 0;
			
			particle.startX = particle.x;
			particle.startY = particle.y;
			particle.originX = particle.emitter.emitterX;
			particle.originY = particle.emitter.emitterY;
			
			if(mCurrentEmitter && (mInheritVelocityX || mInheritVelocityY)){
				speedInheritX = mInheritVelocityX * (mInheritVelocityXVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0)) + mInheritVelocityX;
				speedInheritY = mInheritVelocityY * (mInheritVelocityYVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0)) + mInheritVelocityY;
				speedInheritX = speedInheritX * particle.emitter.emitterVelocityX * HWildness;
				speedInheritY = speedInheritY * particle.emitter.emitterVelocityY * HWildness;
			}
			else {
				speedInheritX = 0;
				speedInheritY = 0;
			}
			
			particle.dragForce = mDrag * (mDragVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0)) + mDrag;
			
			particle.velocityX = (Hspeed * sCosLUT[Hangle]) + speedInheritX;
			particle.velocityY = (Hspeed * sSinLUT[Hangle]) + speedInheritY;
			
			particle.radialAcceleration = (mRadialAcceleration + mRadialAccelerationVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0)) * HWildness;
			particle.tangentialAcceleration = (mTangentialAcceleration + mTangentialAccelerationVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0)) * HWildness;
			
			HstartSizeX = mStartSizeX + mStartSizeVarianceX * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			HstartSizeY = mStartSizeY + mStartSizeVarianceY * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			HendSizeX = mEndSizeX + mEndSizeVarianceX * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			HendSizeY = mEndSizeY + mEndSizeVarianceY * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			
			if (HstartSizeX < 0.1) HstartSizeX = 0.1;
			if (HendSizeX < 0.1) HendSizeX = 0.1;
			if (HstartSizeY < 0.1) HstartSizeY = 0.1;
			if (HendSizeY < 0.1) HendSizeY = 0.1;
			
			
			if (mTexturesCaches) {
				firstFrameWidth = mTexturesCaches[particle.animationIdx].configs[particle.frameIdx].halfWidth * 2;
				firstFrameHeight = mTexturesCaches[particle.animationIdx].configs[particle.frameIdx].halfHeight * 2;
			}
			else if(mFrameLUT){
				firstFrameWidth = mFrameLUT[0].halfWidth * 2;
				firstFrameHeight = mFrameLUT[0].halfHeight * 2;
			}
			
			diagonalTextureSize = Math.sqrt((firstFrameWidth * firstFrameWidth) + (firstFrameHeight * firstFrameHeight));
			
			if(mSizeOscilationX || mSizeOscilationY){
				HOSizeX = mSizeOscilationX + mSizeOscilationVarianceX * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
				HOSizeY = mSizeOscilationY + mSizeOscilationVarianceY * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
				particle.oscilationX = (HOSizeX / diagonalTextureSize);
				particle.oscilationY = (HOSizeY / diagonalTextureSize);
				
				particle.oscilationFrequencyX = (mSizeOscilationFrequencyX + mSizeOscilationFrequencyVarianceX * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0)) * HWildness;
				particle.oscilationFrequencyY = (mSizeOscilationFrequencyY + mSizeOscilationFrequencyVarianceY * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0)) * HWildness;
				
				particle.oscilationAngleX = (mSizeOscilationFrequencyVarianceX + mSizeOscilationOffsetX) * HWildness;
				particle.oscilationAngleY = (mSizeOscilationFrequencyVarianceY + mSizeOscilationOffsetY) * HWildness;
				
				particle.oScaleX = sCosLUT[((particle.oscilationAngleX) * 325.94932345220164765467394738691) & 2047] * particle.oscilationX;
				particle.oScaleY = sSinLUT[((particle.oscilationAngleY) * 325.94932345220164765467394738691) & 2047] * particle.oscilationY;
			}
			else {
				particle.oscilationX = 0;
				particle.oscilationY = 0;
				
				particle.oscilationFrequencyX = 0;
				particle.oscilationFrequencyY = 0;
				
				particle.oscilationAngleX = 0;
				particle.oscilationAngleY = 0;
				
				particle.oScaleX = 1;
				particle.oScaleY = 1;
			}
			
			particle.scaleX = particle.oldScaleX = HstartSizeX / diagonalTextureSize;
			particle.scaleY = particle.oldScaleY = HstartSizeY / diagonalTextureSize;
			particle.scaleDeltaX = (((HendSizeX - HstartSizeX) / Hlifespan) / diagonalTextureSize) * HWildness;
			particle.scaleDeltaY = (((HendSizeY - HstartSizeY) / Hlifespan) / diagonalTextureSize) * HWildness;
			
			particle.motionScale = mScaleMotionBlur;
			
			if (mAlignedEmitterRotation){
				HstartRotation = HangleDeg + mStartRotation + mStartRotationVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
				HendRotation = HangleDeg + mEndRotation + mEndRotationVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			}
			else{
				HstartRotation = mStartRotation + mStartRotationVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
				HendRotation = mEndRotation + mEndRotationVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			}
			
			if (mScaleMotionBlur) {
				if(mbUseCamera){
					fVelocityX = particle.velocityX - camera.velocityX;
					fVelocityY = particle.velocityY - camera.velocityY;
				}
				else {
					fVelocityX = particle.velocityX;
					fVelocityY = particle.velocityY;
				}
				
				particle.rotation = getAngle(fVelocityY, fVelocityX);
				velocityScalar = Math.sqrt(fVelocityX * fVelocityX + fVelocityY * fVelocityY);
				particle.mScale = velocityScalar * mScaleMotionBlur;
			}
			else if (mAlignedVelocityRotation) {
				if(mbUseCamera){
					fVelocityX = particle.velocityX - camera.velocityX;
					fVelocityY = particle.velocityY - camera.velocityY;
				}
				else {
					fVelocityX = particle.velocityX;
					fVelocityY = particle.velocityY;
				}
				
				particle.rotation = getAngle(fVelocityY, fVelocityX);
				particle.mScale = 0;
			}
			else{
				particle.rotation = particle.oldRotation = particle.oldRotation = HstartRotation;
				particle.mScale = 0;
			}
			
			particle.oldRotation = particle.rotation;
			particle.rotationDelta = ((HendRotation - HstartRotation) / Hlifespan) * HWildness;
			
			particle.spawnFactor = 1;
			particle.fadeInFactor = 1;
			particle.fadeOutFactor = 1;
			
			// colors
			HstartColorRed = mStartColor.red;
			HstartColorGreen = mStartColor.green;
			HstartColorBlue = mStartColor.blue;
			HstartColorAlpha = mStartColor.alpha;
			
			if (mStartColorVariance.red != 0)
				HstartColorRed += mStartColorVariance.red * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			if (mStartColorVariance.green != 0)
				HstartColorGreen += mStartColorVariance.green * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			if (mStartColorVariance.blue != 0)
				HstartColorBlue += mStartColorVariance.blue * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			if (mStartColorVariance.alpha != 0)
				HstartColorAlpha += mStartColorVariance.alpha * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			
			HendColorRed = mEndColor.red;
			HendColorGreen = mEndColor.green;
			HendColorBlue = mEndColor.blue;
			HendColorAlpha = mEndColor.alpha;
			
			if (mEndColorVariance.red != 0)
				HendColorRed += mEndColorVariance.red * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			if (mEndColorVariance.green != 0)
				HendColorGreen += mEndColorVariance.green * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			if (mEndColorVariance.blue != 0)
				HendColorBlue += mEndColorVariance.blue * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			if (mEndColorVariance.alpha != 0)
				HendColorAlpha += mEndColorVariance.alpha * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			
			particle.colorRed = HstartColorRed;
			particle.colorGreen = HstartColorGreen;
			particle.colorBlue = HstartColorBlue;
			particle.colorAlpha = HstartColorAlpha;
			
			particle.colorDeltaRed = (HendColorRed - HstartColorRed) / Hlifespan;
			particle.colorDeltaGreen = (HendColorGreen - HstartColorGreen) / Hlifespan;
			particle.colorDeltaBlue = (HendColorBlue - HstartColorBlue) / Hlifespan;
			particle.colorDeltaAlpha = (HendColorAlpha - HstartColorAlpha) / Hlifespan;
			
			/*
			var variation:Number = particleEmitter.x - lastPositionX;
			if (variation <= 0){
				particle.colorRed = 0;
				particle.colorGreen = 0;
			}
			else if (variation > 7) {
				particle.colorBlue = 0;
				particle.colorGreen = 0;
			}
			else {
				particle.colorRed = 1;
				particle.colorGreen = 1;
				particle.colorBlue = 1;
			}
			
			lastPositionX = particleEmitter.x;*/
		}
		
        private var lastParticle:EXParticle;
		/** Does not actually remove the particle. 
		 * Instead it only put the particle to the end of the mParticles vector making particle not being simulated.
		 * No all particles on mParticles are simulated, only the amount describe buy mNumPaticles witch is always less than capacity with is the number of particles on the vertex proggram.*/
        public function removeParticle(particle:EXParticle):void {
			if (mNumParticles == 0) 
				return;
			
			//Find the last particle on the vector
			lastParticle = mParticles[mNumParticles - 1];
			//Set Particle on the last position the vector
			mParticles[mNumParticles - 1] = particle;
			//Replace Partcile by the lastParticle
			mParticles[mParticles.indexOf(particle)] = lastParticle;
			
			--mNumParticles;
			
			//trace("particle removed", particle.currentTime);
		}
		
		protected var angle:uint;
		protected var restTime:Number;
		protected var originDistanceX:Number;
		protected var originDistanceY:Number;
		protected var originDistanceScalar:Number;
		protected var radialX:Number;
		protected var radialY:Number;
		protected var tangentialX:Number; 
		protected var tangentialY:Number;
		protected var newY:Number;
		protected var dragForceX:Number;
		protected var dragForceY:Number;
		protected var repelentDistanceX:Number;
		protected var repelentDistanceY:Number;
		protected var repelentDistanceScalar:Number;
		protected var repelentRadialX:Number;
		protected var repelentRadialY:Number;
		protected var attractorRadialX:Number;
		protected var attractorRadialY:Number;
		protected var attractorDistanceX:Number;
		protected var attractorDistanceY:Number;
		protected var attractorDistanceScalar:Number;
		protected var velocityScalar:Number;
		protected var velocityMotionMult:Number = 0.01;
		
		protected var maximumVelocity:Number = 1500;
		
		protected var shapeList:ShapeList = new ShapeList();
		protected var partPosVec2:Vec2 = new Vec2();
		protected var partVelVec2:Vec2 = new Vec2();
		protected var ray:Ray = new Ray(Vec2.weak(), Vec2.weak());
		protected var rayResult:RayResult;
		protected var reflectAngle:Number;
		protected var space:Space;
		private static var aI:Number;
		private var aPosX:Number;
		private var aPosY:Number;
		
		/** Calculating property changes of a particle.
		 * @param	aParticle
		 * @param	passedTime */
		[Inline]
		final protected function advanceParticle(particle:EXParticle, passedTime:Number):void{
			if (particle.justActivated)
				particle.justActivated = false;
			
			restTime = particle.totalTime - particle.currentTime;
			passedTime = restTime > passedTime ? passedTime : restTime;
			particle.currentTime += passedTime;
			
			originDistanceX = particle.x - particle.originX;
			originDistanceY = particle.y - particle.originY;
			originDistanceScalar = Math.sqrt(originDistanceX * originDistanceX + originDistanceY * originDistanceY);
			
			if (originDistanceScalar < 0.01) originDistanceScalar = 0.01;
			
			radialX = 0;
			radialY = 0;
			tangentialX = 0;
			tangentialY = 0;
			repelentRadialX = 0;
			repelentRadialY = 0;
			dragForceX = 0;
			dragForceY = 0;
			attractorRadialX = 0;
			attractorRadialY = 0;
			
			if (particle.radialAcceleration || particle.tangentialAcceleration){
				radialX = originDistanceX / originDistanceScalar;
				radialY = originDistanceY / originDistanceScalar;
				tangentialX = radialX;
				tangentialY = radialY;
				
				radialX *= particle.radialAcceleration;
				radialY *= particle.radialAcceleration;
				
				newY = tangentialX;
				tangentialX = -tangentialY * particle.tangentialAcceleration;
				tangentialY = newY * particle.tangentialAcceleration;
			}
			
			if (mRepelentForce){
				repelentDistanceX = particle.x - particle.emitter.emitterX;
				repelentDistanceY = particle.y - particle.emitter.emitterY;
				repelentDistanceScalar = Math.sqrt(repelentDistanceX * repelentDistanceX + repelentDistanceY * repelentDistanceY);
				
				if (repelentDistanceScalar < 0.01) repelentDistanceScalar = 0.01;
				
				repelentRadialX = repelentDistanceX / repelentDistanceScalar;
				repelentRadialY = repelentDistanceY / repelentDistanceScalar;
				
				repelentRadialX *= mRepelentForce * particle.wildness;
				repelentRadialY *= mRepelentForce * particle.wildness;
			}
			
			if (mAttractorForce) {
				for (aI = 0; aI < ATTRACTORS.length; aI++ ) {
					// attractor should not absorb particles from witch it self is the emiiter
					if (emitters.length == 0 /*|| emitters.indexOf(ATTRACTORS[aI])*/){
						if (ATTRACTORS[aI].attractorAttributes.enabled && ((ATTRACTORS[aI].attractorAttributes.canAttract && passiveAttraction) || (ATTRACTORS[aI].attractorAttributes.attracting))) {
							if (!particle.absorber || particle.absorber == ATTRACTORS[aI]) {
								aPosX = ATTRACTORS[aI].x + (ATTRACTORS[aI].attractorAttributes.attracting ? (ATTRACTORS[aI].attractorAttributes.attractionOffsetX * (ATTRACTORS[aI].inverted ? -1 : 1)) : 0);
								aPosY = ATTRACTORS[aI].y + (ATTRACTORS[aI].attractorAttributes.attracting ? ATTRACTORS[aI].attractorAttributes.attractionOffsetY : 0);
								
								attractorDistanceX = particle.x - aPosX;
								attractorDistanceY = particle.y - aPosY;
								attractorDistanceScalar = particle.aborberDistanceScalar = Math.sqrt((attractorDistanceX * attractorDistanceX) + (attractorDistanceY * attractorDistanceY));
								
								if (attractorDistanceScalar < 0.01) attractorDistanceScalar = 0.01;
								
								// Distance ration * attractorForce / inverse square field * force
								attractorRadialX += (attractorDistanceX / attractorDistanceScalar) * 
													(ATTRACTORS[aI].attractorAttributes.attractionPower / 
													(attractorDistanceScalar * attractorDistanceScalar)) * 
													(mAttractorForce);
								attractorRadialY += (attractorDistanceY / attractorDistanceScalar) *
													(ATTRACTORS[aI].attractorAttributes.attractionPower / 
													(attractorDistanceScalar * attractorDistanceScalar)) * 
													(mAttractorForce);
								
								if (attractedParticleSignal.numListeners > 0)
									attractedParticleSignal.dispatch(particle, this, ATTRACTORS[aI]);
							}
						}
					}
				}
			}
			
			if (mDrag){
				dragForceX = (particle.velocityX * particle.dragForce );
				dragForceY = (particle.velocityY * particle.dragForce );
			}
			
			/** -------------------------------- */
			/** -------Particle Update---------- */
			/** -------------------------------- */
			
			particle.velocityX += passedTime * ((mGravityX + radialX + tangentialX + repelentRadialX + attractorRadialX) - dragForceX);
			particle.velocityY += passedTime * ((mGravityY + radialY + tangentialY + repelentRadialY + attractorRadialY) - dragForceY);
			
			partVelVec2.x = particle.velocityX; 
			partVelVec2.y = particle.velocityY; 
			
			if(partVelVec2.length > maximumVelocity)
				partVelVec2.length = maximumVelocity;
			
			particle.velocityX = partVelVec2.x;
			particle.velocityY = partVelVec2.y;
			
			if(mPhysicsCollisions && (particle.velocityX != 0 && particle.velocityX != 0)){
				if (!particle.sleeping) {
					ray.origin.x = particle.x;
					ray.origin.y = particle.y;
					ray.direction.x = particle.velocityX;
					ray.direction.y = particle.velocityY;
					ray.maxDistance = Math.sqrt((passedTime * particle.velocityX * passedTime * particle.velocityX) + (passedTime * particle.velocityY * passedTime * particle.velocityY)); // cast as far as 7px
					
					if(ray.direction.length > 0.1){
						rayResult = space.rayCast(
							ray,
							false,
							GamePhysics.PARTICLE_FILTER
						);
					}
					if (rayResult) {
						//trace("particle collided", rayResult.shape.body.userData.gameObject.name);
						partVelVec2.x = particle.velocityX; 
						partVelVec2.y = particle.velocityY;
						
						partVelVec2.angle = (2 * rayResult.normal.angle) - partVelVec2.angle + (3.14159265359);
						
						partVelVec2.x *= particle.bounceCoefficient; 
						partVelVec2.y *= particle.bounceCoefficient; 
						
						particle.velocityX = partVelVec2.x;
						particle.velocityY = partVelVec2.y;
						
						particle.collided = true;
						particle.numCollisions++;
						
						if (particle.numCollisions == 3)
							particle.sleeping = true;	
						
						rayResult.dispose();
					}
					else
						particle.collided = false;
				}
				rayResult = null;
			}
			
			particle.oldX = particle.x;
			particle.oldY = particle.y;
			particle.oldRotation = particle.rotation;
			particle.oldScaleX = particle.scaleX;
			particle.oldScaleY = particle.scaleY;
			
			if(!particle.sleeping){
				particle.x += particle.velocityX * passedTime;
				particle.y += particle.velocityY * passedTime;
				
				particle.oscilationAngleX += particle.oscilationFrequencyX * passedTime;
				particle.oscilationAngleY += particle.oscilationFrequencyY * passedTime;
				
				particle.oScaleX = sCosLUT[((particle.oscilationAngleX) * 325.94932345220164765467394738691) & 2047] * particle.oscilationX;
				particle.oScaleY = sSinLUT[((particle.oscilationAngleY) * 325.94932345220164765467394738691) & 2047] * particle.oscilationY;
				
				if (mScaleMotionBlur) {
					if(mbUseCamera){
						fVelocityX = particle.velocityX - camera.velocityX;
						fVelocityY = particle.velocityY - camera.velocityY;
					}
					else {
						fVelocityX = particle.velocityX;
						fVelocityY = particle.velocityY;
					}
					
					particle.rotation = getAngle(fVelocityY, fVelocityX);
					velocityScalar = Math.sqrt(fVelocityX * fVelocityX + fVelocityY * fVelocityY);
					particle.mScale = velocityScalar * mScaleMotionBlur * passedTime;
					
				}
				else if (mAlignedVelocityRotation && (particle.velocityY != 0 && particle.velocityX != 0)) {
					if(mbUseCamera){
						fVelocityX = particle.velocityX - camera.velocityX;
						fVelocityY = particle.velocityY - camera.velocityY;
					}
					else {
						fVelocityX = particle.velocityX;
						fVelocityY = particle.velocityY;
					}
					
					particle.rotation = getAngle(fVelocityY, fVelocityX);
				}
				else if(!mAlignedVelocityRotation){
					particle.rotation += particle.rotationDelta * passedTime;
					particle.mScale = 0;
				}
				
				particle.scaleX += particle.scaleDeltaX * passedTime;
				particle.scaleY += particle.scaleDeltaY * passedTime;
				
				if (particle.collided) {
					particle.oldX = particle.x;
					particle.oldY = particle.y;
					
					particle.oldScaleX = particle.scaleX;
					particle.oldScaleY = particle.scaleY;
					particle.oldRotation = particle.rotation;
				}
			}
			else if(mPhysicsCollisions){
				particle.rotation = particle.displacementRotation;
				particle.mScale = 0;
				particle.collided = false;
			}
			else {
				particle.mScale = 0;	
			}
			
			if (particle.frameAmount > 1 && (particle.loopCount > mLoops || mLoops != -1)){
				particle.frame = (particle.frame + particle.frameDelta * passedTime);
				particle.frameIdx = particle.frame;
				if ((particle.frameIdx > particle.frameAmount - 1) || particle.frameIdx < 0){
					particle.frameIdx %= particle.frameAmount;
					
					if (particle.frameIdx < 0)
						particle.frameIdx += particle.frameAmount;
					
					particle.loopCount++;
				}
			}
			
			if (mTinted){
				particle.colorRed += particle.colorDeltaRed * passedTime;
				particle.colorGreen += particle.colorDeltaGreen * passedTime;
				particle.colorBlue += particle.colorDeltaBlue * passedTime;
				particle.colorAlpha += particle.colorDeltaAlpha * passedTime;
			}
			
			if (areaRect && !areaRect.contains(particle.x, particle.y)) {
				particle.absorbed = true;
			}
			
			deltaTime = particle.currentTime / particle.totalTime;
			
			if (mSpawnTime)
				particle.spawnFactor = deltaTime < mSpawnTime ? deltaTime / mSpawnTime : 1;
			
			if (mFadeInTime)
				particle.fadeInFactor = deltaTime < mFadeInTime ? deltaTime / mFadeInTime : 1;
			
			if (mFadeOutTime){
				deltaTime = 1 - deltaTime;
				particle.fadeOutFactor = deltaTime < mFadeOutTime ? deltaTime / mFadeOutTime : 1;
			}
		}
		
		private var particle:EXParticle;
		private var particleIndex:int = 0;
		private var timeBetweenParticles:Number;
		private var hAngle:Number;
		
		/** Return angle between 2 points with values between 0 and 360(degrees) of 0 and 2Pi(radians). Can return both clockwise or an clockwise */
		public function getAngle(v1:Number, v2:Number):Number {
            hAngle = Math.atan2(v1, v2);
			
			hAngle = hAngle < 0 ? hAngle + (2 * 3.14159265359) : hAngle;
			
			return hAngle;
		}
		
		private var HpassedTime:Number;
		/** Loops over all particles and adds/removes/advances them according to the current time;
		 * writes the data directly to the raw vertex data.
		 *
		 * <p>Note: This function is called by Starling's Juggler, so there will most likely be no reason for
		 * you to call it yourself, unless you want to implement slow/quick motion effects.</p>
		 *
		 * @param	passedTime */
		public function advanceTime(passedTime:Number):void {
			var sortFlag:Boolean = false;
			
			//-----------------------------------------
			
			var allEmittersFinished:Boolean = emitters.length > 0;
			var allEmittersDepleted:Boolean = emitters.length > 0;
			
			for each (mCurrentEmitter in emitters) {
				// Update emitters when system was not initated yet?	
				if (!mParticles) {
					if (mCurrentEmitter.emissionTime && !mCurrentEmitter.depleted) {
						allEmittersDepleted = false;
						allEmittersFinished = false;
						mCurrentEmitter.emissionTime -= passedTime;
						if (mCurrentEmitter.emissionTime != Number.MAX_VALUE)
							mCurrentEmitter.emissionTime = Math.max(0.0, mCurrentEmitter.emissionTime - passedTime);
					}
					else {
						if(allEmittersFinished && allEmittersDepleted){
							stop(autoClearOnComplete);
							complete();
							return;
						}
					}
					return;
				}
				else {
					mCurrentEmitter.frameTime += passedTime;	
					mCurrentEmitter.emissionAngle += mEmissionRotationSpeed * passedTime;
					
					if (mCurrentEmitter.emissionTime > 0)
						allEmittersFinished = false;
					
					if (!mCurrentEmitter.depleted)
						allEmittersDepleted = false;
				}
			}
			
			particleIndex = 0;
			// advance existing particles
			while (particleIndex < mNumParticles){
				particle = mParticles[particleIndex];
				//Advance if: particle time less than total time, particle not absorbed, particle goes not beyond emitter area and system area
				//otherwise remove the particle
				if (particle.currentTime < particle.totalTime && !(particle.absorbed && particle.colorAlpha <= 0.01) && (!particle.emitter.areaRect || particle.emitter.areaRect.contains(particle.x, particle.y)) && (!areaRect || areaRect.contains(particle.x, particle.y))) {
					advanceParticle(particle, passedTime);
					++particleIndex;
				}
				else{
					particle.active = false;
					particle.emitter.numParticles--;
					particle.emitter = null;
					removeParticle(particle);
					sortFlag = true;
					//If system is not simulating any particle and all emitters finished or depleated or there no more emitters than clear the system
					if (mNumParticles == 0 && (allEmittersFinished || allEmittersDepleted || emitters.length == 0)){
						stop(autoClearOnComplete);
						complete();
						return;
					}
				}
			}
			
			var currentCapacity:int = mMaxCapacity / emitters.length;
			for each (mCurrentEmitter in emitters) {
				// create and advance new particles
				if (mCurrentEmitter.emissionTime > 0) {
					// We make time between partices proportional to number of emitters so total number of particles will tend to be preserved no matter how much emitters there are
					// We can create a var to desactvate this latter
					timeBetweenParticles = (emitters.length > 0 ? emitters.length : 1) / (mCurrentEmitter.useSystemEmissionRate ? mEmissionRate : mCurrentEmitter.emissionRate);
					allEmittersFinished = false;
					
					while (mCurrentEmitter.frameTime > 0){
						//Emission Rate could change between particles update
						timeBetweenParticles = (emitters.length > 0 ? emitters.length : 1) / (mCurrentEmitter.useSystemEmissionRate ? mEmissionRate : mCurrentEmitter.emissionRate);
						
						//Only create more particle if number of particles does not exceed the maximum capacity
						//Each emitter share capacity inversaly proportional to the number of emitter
						if ((mCurrentEmitter.numParticles < currentCapacity) && mNumParticles < mMaxCapacity) {
							//Only creare more particle if current emitter are not depleted
							if (!mCurrentEmitter.depleted) {
								allEmittersDepleted = false;
								
								//capacity determine the current resources used by the system. If number of particle exceeds the current capacity, we need to raise that
								if (mNumParticles == capacity)
									raiseCapacity(capacity);
								
								particle = mParticles[mNumParticles++];
								particle.emitter = mCurrentEmitter;
								mCurrentEmitter.finalCount++;
								mCurrentEmitter.numParticles++;
								
								initParticle(particle);
								advanceParticle(particle, mCurrentEmitter.frameTime);
								particle.justActivated = true;
								
								//Unassign emitter if it gets depleted
								if (mCurrentEmitter.finalAmount > 0 && mCurrentEmitter.finalAmount >= mCurrentEmitter.finalCount){
									mCurrentEmitter.depleted = true;
									mCurrentEmitter.onDepleted.dispatch(mCurrentEmitter);
									unassignEmitter(mCurrentEmitter);
								}
							}
						}
						
						mCurrentEmitter.frameTime -= timeBetweenParticles;
					}
					
					//Mantain emission time beteen 0 and Max Value
					if (mCurrentEmitter.emissionTime != Number.MAX_VALUE){
						mCurrentEmitter.emissionTime = Math.max(0.0, mCurrentEmitter.emissionTime - passedTime);
						
						//Unassign emitter if it gets finished its emission time
						if (mCurrentEmitter.emissionTime <= 0) {
							mCurrentEmitter.finished = true;
							mCurrentEmitter.onFinished.dispatch(mCurrentEmitter);
							unassignEmitter(mCurrentEmitter);
						}
					}
				}
			}
			
			//If all emitters is finished or depleated and number of particles reach 0, clear, stops and clear the system
			if ((allEmittersFinished || allEmittersDepleted || emitters.length == 0) && !mCompleted && mNumParticles == 0){
				stop(autoClearOnComplete);
				complete();
				return;
			}
			
			//-----------------------------------------
			
			if (!mParticles)
				return;
			//A custom function to be run on each particle
			if (mCustomFunc !== null){
				mCustomFunc(mParticles, mNumParticles);
			}
			//A sort function if there is a need to sort them
			if (sortFlag && mSortFunction !== null){
				mParticles = mParticles.sort(mSortFunction);
			}
		}
		
		private var vertexID:int = 0;
		
		private var red:Number;
		private var green:Number;
		private var blue:Number;
		private var particleAlpha:Number;
		private var pAlpha:Number;
		
		private var px:Number; 
		private var py:Number;
		private var pScaleX:Number; 
		private var pScaleY:Number;
		
		private var pRotation:Number;
		private var xOffset:Number;
		private var yOffset:Number;
		private var fOffsetX:Number;
		private var fOffsetY:Number;
		private var deltaRight:Number;
		private var deltaBottom:Number;
		private var deltaLeft:Number;
		private var deltaTop:Number;
		
		private var rawData:Vector.<Number>;
		private var frameDimensions:Frame;
		private var subTextureCnfig:SubTextureConfig;
		
		private var textureWidth:Number;
		private var textureHeight:Number;
		
		private var vtPosition:uint;
		private var deltaTime:Number;
		
		private var k:int;
		
		private var pAngle:uint;
        private var cos:Number;
        private var sin:Number;
        private var cosX:Number;
        private var cosY:Number;
        private var sinX:Number;
        private var sinY:Number;
        private var fcosX:Number;
        private var fcosY:Number;
        private var fsinX:Number;
        private var fsinY:Number;
		
		private var newScaleX:Number;
		private var newScaleY:Number;
		
		private var oldScaleX:Number;
		private var oldScaleY:Number;
		
		/** Store hald width of the sub texture. Usefull for some calculations  */
		private var halfWidth:Number = 1.0;
		/** Store half height of the sub texture. Usefull for some calculations */
		private var halfHeight:Number = 1.0;
		
		private var mappingLeft:Number = 0.0;
		private var mappingTop:Number = 0.0;
		private var mappingRight:Number = 1.0;
		private var mappingBottom:Number = 1.0;
		
		/** If texture is trimmed this store the right position of the trimmed rectangle */ 
		private var frameRight:Number = 0.0;
		/** If texture is trimmed this store the bottom position of the trimmed rectangle */ 
		private var frameBottom:Number = 0.0;
		/** If texture is trimmed this store the left position of the trimmed rectangle */ 
		private var frameLeft:Number = 0.0;
		/** If texture is trimmed this store the top position of the trimmed rectangle */ 
		private var frameTop:Number = 0.0;
		private var useFrame:Boolean = false;
		private var rotDiff:Number = 0;
		/** Since we separate game updates from render updates, 
		 * all animations should interpolates between current state and last state in order to be shown correctly on screen when render comes
		 * cause that we need to move vertex update to a separated function and interpolate the position inside this.
		 * Otherwise the particles will have a stuter behavior witch is something we want to avoid */
		public function smoothVertexState(fixedTimestepAccumulatorRatio:Number, oneMinusRatio:Number):void {
			if (!mPlaying)
				return;
			
			vertexID = 0;
			rawData = mVertexData.rawData;
			
			deltaRight = 0;
			deltaBottom = 0;
			deltaLeft = 0;
			deltaTop = 0;
			fOffsetX = 0;
			fOffsetY = 0;
			
			for (k = 0; k < mNumParticles; ++k){
				vertexID = k << 2;
				particle = mParticles[k];
				
				if(mFrameLUT){
					frameDimensions = mFrameLUT[particle.frameIdx];
					mappingLeft = frameDimensions.textureX;
					mappingTop = frameDimensions.textureY;
					mappingRight = frameDimensions.textureWidth;
					mappingBottom = frameDimensions.textureHeight;
				}
				else if (mTexturesCaches) {
					subTextureCnfig = mTexturesCaches[particle.animationIdx].configs[particle.frameIdx];
					mappingLeft = subTextureCnfig.mappingLeft;
					mappingTop = subTextureCnfig.mappingTop;
					mappingRight = subTextureCnfig.mappingRight;
					mappingBottom = subTextureCnfig.mappingBottom;
				}
				
				red = particle.colorRed;
				green = particle.colorGreen;
				blue = particle.colorBlue;
				
				//if (particle.justActivated){
					//red = 0;
					//green = particle.colorGreen;
					//blue = 0;
				//}
				
				particleAlpha = particle.colorAlpha * particle.fadeInFactor * particle.fadeOutFactor * mSystemAlpha;
				
				px = (particle.x * fixedTimestepAccumulatorRatio) + (particle.oldX * oneMinusRatio) + particle.displacementX;
				py = (particle.y * fixedTimestepAccumulatorRatio) + (particle.oldY * oneMinusRatio) + particle.displacementY;
				
				pRotation = (particle.rotation * fixedTimestepAccumulatorRatio) + (particle.oldRotation * oneMinusRatio);
				
				//Problem with Math.atan2 witch returns PI to -PI instead 0 to 2PI; This create rotation smo
				rotDiff = particle.oldRotation - particle.rotation;
				//trace(rotDiff);
				//if ((particle.oldRotation - particle.rotation) > 0.05)
					//trace("ops", rotDiff);
				
				newScaleX = (particle.scaleX + particle.oScaleX) * particle.spawnFactor;
				newScaleY = (particle.scaleY + particle.oScaleY) * particle.spawnFactor;
				oldScaleX = (particle.oldScaleX + particle.oScaleX) * particle.spawnFactor;
				oldScaleY = (particle.oldScaleY + particle.oScaleY) * particle.spawnFactor;
				
				pScaleX = (newScaleX * fixedTimestepAccumulatorRatio) + (oldScaleX * oneMinusRatio);
				pScaleY = (newScaleY * fixedTimestepAccumulatorRatio) + (oldScaleY * oneMinusRatio);
				
				deltaRight = 0;
                deltaBottom = 0;
                deltaLeft = 0;
                deltaTop = 0;
				
				useFrame = frameDimensions ? frameDimensions.useFrame : subTextureCnfig.useFrame;
				
				if (useFrame) {
					if(mFrameLUT){	
						deltaRight  = frameDimensions.frameWidth  + frameDimensions.frameX - frameDimensions.width;
						deltaBottom = frameDimensions.frameHeight + frameDimensions.frameY - frameDimensions.height;
						deltaLeft = frameDimensions.frameX;
						deltaTop = frameDimensions.frameY;
					}
					else if (mTexturesCaches) {
						deltaRight  = subTextureCnfig.frameRight;
						deltaBottom = subTextureCnfig.frameBottom;
						deltaLeft = subTextureCnfig.frameLeft
						deltaTop = subTextureCnfig.frameTop;
					}
					
					fOffsetX = (deltaLeft + deltaRight) * .5 * pScaleX;
					fOffsetY = (deltaTop + deltaBottom) * .5 * pScaleY;
				}
				
                if(mFrameLUT){
					xOffset = frameDimensions.halfWidth * pScaleX + particle.mScale;
					yOffset = frameDimensions.halfHeight * pScaleY;
				}
				else if (mTexturesCaches) {
					xOffset = subTextureCnfig.halfWidth * pScaleX + particle.mScale;
					yOffset = subTextureCnfig.halfHeight * pScaleY;
				}
				
				if (pRotation){
					pAngle = ((pRotation) * 325.94932345220164765467394738691) & 2047;
					cos = sCosLUT[pAngle];
					sin = sSinLUT[pAngle];
					cosX = cos * xOffset;
					cosY = cos * yOffset;
					sinX = sin * xOffset;
					sinY = sin * yOffset;
					fcosX = cos * fOffsetX;
					fcosY = cos * fOffsetY;
					fsinX = sin * fOffsetX;
					fsinY = sin * fOffsetY;
					
					vtPosition = vertexID << 3; // * 8
					rawData[vtPosition] = px - cosX + sinY - fcosX + fsinY;
					rawData[++vtPosition] = py - sinX - cosY - fsinX - fcosY;
					rawData[++vtPosition] = red;
					rawData[++vtPosition] = green;
					rawData[++vtPosition] = blue;
					rawData[++vtPosition] = particleAlpha;
					rawData[++vtPosition] = mappingLeft;
					rawData[++vtPosition] = mappingTop;
					
					rawData[++vtPosition] = px + cosX + sinY - fcosX + fsinY;
					rawData[++vtPosition] = py + sinX - cosY - fsinX - fcosY;
					rawData[++vtPosition] = red;
					rawData[++vtPosition] = green;
					rawData[++vtPosition] = blue;
					rawData[++vtPosition] = particleAlpha;
					rawData[++vtPosition] = mappingRight;
					rawData[++vtPosition] = mappingTop;
					
					rawData[++vtPosition] = px - cosX - sinY - fcosX + fsinY;
					rawData[++vtPosition] = py - sinX + cosY - fsinX - fcosY;
					rawData[++vtPosition] = red;
					rawData[++vtPosition] = green;
					rawData[++vtPosition] = blue;
					rawData[++vtPosition] = particleAlpha;
					rawData[++vtPosition] = mappingLeft;
					rawData[++vtPosition] = mappingBottom;
					
					rawData[++vtPosition] = px + cosX - sinY - fcosX + fsinY;
					rawData[++vtPosition] = py + sinX + cosY - fsinX - fcosY;
					rawData[++vtPosition] = red;
					rawData[++vtPosition] = green;
					rawData[++vtPosition] = blue;
					rawData[++vtPosition] = particleAlpha;
					rawData[++vtPosition] = mappingRight;
					rawData[++vtPosition] = mappingBottom;
					
				}
				else{
					vtPosition = vertexID << 3; // * 8
					rawData[vtPosition] = px - xOffset - fOffsetX;
					rawData[++vtPosition] = py - yOffset - fOffsetY;
					rawData[++vtPosition] = red;
					rawData[++vtPosition] = green;
					rawData[++vtPosition] = blue;
					rawData[++vtPosition] = particleAlpha;
					rawData[++vtPosition] = mappingLeft;
					rawData[++vtPosition] = mappingTop;
					
					rawData[++vtPosition] = px + xOffset - fOffsetX;
					rawData[++vtPosition] = py - yOffset - fOffsetY;
					rawData[++vtPosition] = red;
					rawData[++vtPosition] = green;
					rawData[++vtPosition] = blue;
					rawData[++vtPosition] = particleAlpha;
					rawData[++vtPosition] = mappingRight;
					rawData[++vtPosition] = mappingTop;
					
					rawData[++vtPosition] = px - xOffset - fOffsetX;
					rawData[++vtPosition] = py + yOffset - fOffsetY;
					rawData[++vtPosition] = red;
					rawData[++vtPosition] = green;
					rawData[++vtPosition] = blue;
					rawData[++vtPosition] = particleAlpha;
					rawData[++vtPosition] = mappingLeft;
					rawData[++vtPosition] = mappingBottom;
					
					rawData[++vtPosition] = px + xOffset - fOffsetX;
					rawData[++vtPosition] = py + yOffset - fOffsetY;
					rawData[++vtPosition] = red;
					rawData[++vtPosition] = green;
					rawData[++vtPosition] = blue;
					rawData[++vtPosition] = particleAlpha;
					rawData[++vtPosition] = mappingRight;
					rawData[++vtPosition] = mappingBottom;
				}
			}
		}
		
		/** Remaining initiation of the current instance (for JIT optimization).
		 * @param	config */
		private function initInstance(config:ParticleSystemProperties):void{
			parseSystemOptions(config);
			
			if(mEmissionRate == -1)
				mEmissionRate = mMaxNumParticles / mLifespan;
			
			mEmissionTime = 0.0;
			mFrameTime = 0.0;
			mMaxCapacity = mMaxNumParticles ? Math.min(MAX_CAPACITY, mMaxNumParticles) : MAX_CAPACITY;
			
			if (!sVertexBuffers || !sVertexBuffers[0])
				init();
			
			if(defaultJuggler == null)
				defaultJuggler = Starling.juggler;
			
			addEventListener(starling.events.Event.ADDED_TO_STAGE, addedToStageHandler);
			addedToStageHandler(null);
		}
		
		/** Initiation of anything shared between all systems. Call this function <strong>before</strong> you create any instance
		 * to set a custom size of your pool and Stage3D buffers.
		 *
		 * <p>If you don't call this method explicitly before createing an instance, the first constructor will
		 * create a default pool and buffers; which is OK but might slow down especially mobile devices.</p>
		 *
		 * <p>Set the <em>poolSize</em> to the absolute maximum of particles created by all particle systems together. Creating the pool
		 * will only hit you once (unless you dispose/recreate it/context loss). It will not harm runtime, but a number way to big will waste
		 * memory and take a longer creation process.</p>
		 *
		 * <p>If you're satisfied with the number of particles and want to avoid any accidental enhancement of the pool, set <em>fixed</em>
		 * to true. If you're not sure how much particles you will need, and fear particle systems might not show up more than the consumption
		 * of memory and a little slowdown for newly created particles, set <em>fixed</em> to false.</p>
		 *
		 * <p>The <em>bufferSize</em> determins how many particles can be rendered by one particle system. The <strong>minimum</strong>
		 * should be the maxParticles value set number in your pex file.</p>
		 * <p><strong>Note:   </strong>The bufferSize is always fixed!</p>
		 * <p><strong>Note:   </strong>If you want to profit from batching, take a higher value, e. g. enough for 5 systems. But avoid
		 * choosing an unrealistic high value, since the complete buffer will have to be uploaded each time a particle system (batch) is drawn.</p>
		 *
		 * <p>The <em>numberOfBuffers</em> sets the amount of vertex buffers in use by the particle systems. Multi buffering can avoid stalling of
		 * the GPU but will also increases it's memory consumption.</p>
		 *
		 * @param	poolSize Length of the particle pool.
		 * @param	fixed Whether the poolSize has a fixed length.
		 * @param	bufferSize The maximum number of particles which can be rendered with one draw call. between 1 and 16383. If you do not set this value, it will be set to 16383, which is it's maximum value.
		 * @param	numberOfBuffers The amount of vertex buffers used by the particle system for multi buffering.
		 *
		 * @see #ParticleSystemEX()
		 * @see #dispose() ParticleSystemEX.dispose()
		 * @see #disposePool() ParticleSystemEX.disposePool()
		 * @see #disposeBuffers() ParticleSystemEX.disposeBuffers() */
		public static function init(poolSize:uint = 16383, fixed:Boolean = false, bufferSize:uint = 0, numberOfBuffers:uint = 1):void{
			
			//registerPrograms();
			
			if (!bufferSize && sBufferSize)
				bufferSize = sBufferSize;
			if (bufferSize > MAX_CAPACITY){
				bufferSize = MAX_CAPACITY;
				trace("Warning: bufferSize exceeds the limit and is set to it's maximum value (16383)");
			}
			else if (bufferSize <= 0){
				bufferSize = MAX_CAPACITY;
				trace("Warning: bufferSize can't be lower than 1 and is set to it's maximum value (16383)");
			}
			sBufferSize = bufferSize;
			sNumberOfVertexBuffers = numberOfBuffers;
			createBuffers(sBufferSize);
			
			//run once
			if (!sLUTsCreated)
				initLUTs();
			
			if (!sParticlePool) {
				sFixedPool = fixed;
				sParticlePool = new Vector.<EXParticle>();
				sPoolSize = poolSize;
				var i:int = -1;
				while (++i < sPoolSize)
					sParticlePool[i] = new EXParticle();
			}
			
			if(defaultJuggler == null)
				defaultJuggler = Starling.juggler;
			
			// handle a lost device context
			Starling.current.stage3D.addEventListener(flash.events.Event.CONTEXT3D_CREATE, onContextCreated, false, 0, true);
		}
		
		/** Creats look up tables for sin and cos, to reduce function calls. */
		private static function initLUTs():void{
			for (var i:int = 0; i < 0x800; ++i){
				sCosLUT[i & 0x7FF] = Math.cos(i * 0.00306796157577128245943617517898); // 0.003067 = 2PI/2048
				sSinLUT[i & 0x7FF] = Math.sin(i * 0.00306796157577128245943617517898);
			}
			sLUTsCreated = true;
		}
		
		public var onComplete:Signal = new Signal(ParticleSystemEX);
		/** * Setting the complete state and throwing the event. */
		protected function complete():void{
			if (!mCompleted){
				mCompleted = true;
				dispatchEventWith(starling.events.Event.COMPLETE);
				onComplete.dispatch(this);
			}
		}
		
		/** * Disposes the system instance and frees it's resources */
		public override function dispose():void {
			if (mDisposed)
				throw Error("tying to dispose a particle system already disposed");
			
			sInstances.splice(sInstances.indexOf(this), 1);
			removeEventListener(starling.events.Event.ADDED_TO_STAGE, addedToStageHandler);
			
			mJuggler.remove(this);
			
			if(!cleared)
				stop(true);
			
			mBatched = false;
			super.filter = mFilter = null;
			unassignAllEmitters();
			removeFromParent();
			emitters.length = 0;
			mCurrentEmitter = null;
			super.dispose();
			mDisposed = true;
			onComplete.removeAll();
			onComplete = null;
			onClear.removeAll();
			onClear = null;
		}
		
		/** *  Whether the system has been disposed earlier */
		public function get disposed():Boolean{ return mDisposed; }
		
		/** * Disposes the created particle pool and Stage3D buffers, shared by all instances.
		 * Warning: Therefore all instances will get disposed as well! */
		public static function dispose():void{
			Starling.current.stage3D.removeEventListener(flash.events.Event.CONTEXT3D_CREATE, onContextCreated);
			
			disposeBuffers();
			disposePool();
		}
		
		/** * Disposes the Stage3D buffers and therefore disposes all system instances!
		 * Call this function to free the GPU resources or if you have to set
		 * the buffers to another size. */
		public static function disposeBuffers():void{
			for each (var instance:ParticleSystemEX in sInstances){
				instance.dispose();
			}
			if (sVertexBuffers) {
				for (var i:int = 0; i < sNumberOfVertexBuffers; ++i){
					sVertexBuffers[i].dispose();
					sVertexBuffers[i] = null;
				}
				sVertexBuffers = null;
				sNumberOfVertexBuffers = 0;
			}
			if (sIndexBuffer){
				sIndexBuffer.dispose();
				sIndexBuffer = null;
			}
			sBufferSize = 0;
		}
		
		/** * Clears the current particle pool.
		 * Warning: Also disposes all system instances! */
		public static function disposePool():void{
			for each (var instance:ParticleSystemEX in sInstances){
				instance.dispose();
			}
			sParticlePool = null;
		}
		
		/** @inheritDoc */
		public override function set filter(value:FragmentFilter):void{
			if (!mBatched)
				mFilter = value;
			super.filter = value;
		}
		
		/** * Returns a rectangle in stage dimensions (to support filters) if possible, or an empty rectangle
		 * at the particle system's position. Calculating the actual bounds would be too expensive. */
		public override function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null):Rectangle{
			if (resultRect == null)
				resultRect = new Rectangle();
			
			if (targetSpace == this || targetSpace == null){
				if (mBounds)
					resultRect = mBounds;
				else if (stage){
					// return full stage size to support filters ... may be expensive, but we have no other options, do we?
					resultRect.x = 0;
					resultRect.y = 0;
					resultRect.width = stage.stageWidth;
					resultRect.height = stage.stageHeight;
				}
				else{
					getTransformationMatrix(targetSpace, sHelperMatrix);
					MatrixUtil.transformCoords(sHelperMatrix, 0, 0, sHelperPoint);
					resultRect.x = sHelperPoint.x;
					resultRect.y = sHelperPoint.y;
					resultRect.width = resultRect.height = 0;
				}
				return resultRect;
			}
			else if (targetSpace){
				if (mBounds){
					getTransformationMatrix(targetSpace, sHelperMatrix);
					MatrixUtil.transformCoords(sHelperMatrix, mBounds.x, mBounds.y, sHelperPoint);
					resultRect.x = sHelperPoint.x;
					resultRect.y = sHelperPoint.y;
					MatrixUtil.transformCoords(sHelperMatrix, mBounds.width, mBounds.height, sHelperPoint);
					resultRect.width = sHelperPoint.x
					resultRect.height = sHelperPoint.y;
				}
				else if (stage){
					// return full stage size to support filters ... may be pretty expensive
					resultRect.x = 0;
					resultRect.y = 0;
					resultRect.width = stage.stageWidth;
					resultRect.height = stage.stageHeight;
				}
				else{
					getTransformationMatrix(targetSpace, sHelperMatrix);
					MatrixUtil.transformCoords(sHelperMatrix, 0, 0, sHelperPoint);
					resultRect.x = sHelperPoint.x;
					resultRect.y = sHelperPoint.y;
					resultRect.width = resultRect.height = 0;
				}
				
				return resultRect;
			}
			return resultRect = mBounds;
		
		}
		
		/** * Takes particles from the pool and assigns them to the system instance.
		 * If the particle pool doesn't have enough unused particles left, it will
		 * - either create new particles, if the pool size is expandable
		 * - or return false, if the pool size has been fixed
		 *
		 * Returns a Boolean for success
		 *
		 * @return */
		protected function getParticlesFromPool():Boolean{
			if (mParticles)
				return true;
			
			if (mDisposed)
				return false;
			
			if (sParticlePool.length >= mMaxNumParticles){
				mParticles = new Vector.<EXParticle>(mMaxNumParticles, true);
				var particleIdx:int = mMaxNumParticles;
				var poolIdx:int = sParticlePool.length;
				
				sParticlePool.fixed = false;
				while (particleIdx)
				{
					mParticles[--particleIdx] = sParticlePool[--poolIdx];
					mParticles[particleIdx].active = false;
					sParticlePool[poolIdx] = null;
				}
				sParticlePool.length = poolIdx;
				sParticlePool.fixed = true;
				
				mVertexData = new VertexData(mMaxNumParticles * 4);
				mNumParticles = 0;
				raiseCapacity(mMaxNumParticles - mParticles.length);
				return true;
			}
			
			if (sFixedPool)
				return false;
			
			var i:int = sParticlePool.length - 1;
			var len:int = mMaxNumParticles;
			sParticlePool.fixed = false;
			while (++i < len)
				sParticlePool[i] = new EXParticle();
			sParticlePool.fixed = true;
			return getParticlesFromPool();
		}
		
		/** * (Re)Inits the system (after context loss)
		 * @param	event */
		private static function onContextCreated(event:flash.events.Event):void{
			createBuffers(sBufferSize);
		}
		
		private function parseSystemOptions(systemOptions:ParticleSystemProperties):void{
			if (!systemOptions)
				return;
			
			const DEG2RAD:Number 						= 1 / 180 * 3.14159265359;
			
			mIsAnimated 								= systemOptions.isAnimated;
			mLoops 										= systemOptions.loops;
			mFrameRate                                  = systemOptions.frameRate;
			mFrameRateRatio                             = systemOptions.frameRateRatio;
			mRandomStartFrames 							= systemOptions.randomStartFrames;
			mRandomArt 									= systemOptions.randomArt;
			mFrameLUT 									= systemOptions.frameLUT;
			mTexturesCaches								= systemOptions.texturesCaches;
			
			mTexture 									= systemOptions.texture;
			mTinted 									= systemOptions.tinted;
			mParticleBlendMode 							= systemOptions.particleBlendMode;
			mParticlePMA 								= systemOptions.particlePMA;
			
			mMaxNumParticles 							= systemOptions.maxNumberParticles;
			mEmitterX 									= systemOptions.emitterX;
			mEmitterY 									= systemOptions.emitterY;
			mEmitterXVariance 							= systemOptions.emitterVarianceX;
			mEmitterYVariance 							= systemOptions.emitterVarianceY;
			mEmitterRadius								= systemOptions.emitterRadius;
			mEmitterRadiusVariance 						= systemOptions.emitterRadiusVariance;
			mEmissionRate 								= systemOptions.emissionRate;
			
			if (systemOptions.emissionRate == -1 && systemOptions.lifespan == -1)
				throw Error("if lifespan is -1 emission rate should have manual value greater than 0");
			
			mLifespan 									= systemOptions.lifespan;
			mLifespanVariance 							= systemOptions.lifespanVariance;
			mEmissionAngle 								= systemOptions.emissionAngle * DEG2RAD ;
			mEmissionAngleVariance 						= systemOptions.emissionAngleVariance * DEG2RAD * .5;
			mEmissionRotationSpeed 						= systemOptions.emissionRotationSpeed * DEG2RAD;
			mInheritEmissionAngle                      	= systemOptions.inheritEmissionAngle;
			mEmissionTimePredefined 					= mEmissionTimePredefined < 0 ? Number.MAX_VALUE : mEmissionTimePredefined;
			
			mSpawnTime 									= systemOptions.spawnTime;
			mFadeInTime 								= systemOptions.fadeInTime;
			mFadeOutTime 								= systemOptions.fadeOutTime;
			
			mAlignedEmitterRotation 					= systemOptions.alignedEmitterRotation;
			mAlignedVelocityRotation                    = systemOptions.alignedVelocityRotation;
			mScaleMotionBlur                    		= systemOptions.scaleMotionBlur;
			mbUseCamera                    				= systemOptions.mbUseCamera;
			
			mBounceCoefficient                   		= systemOptions.bounceCoefficient;
			mBounceCoefficientVariance                  = systemOptions.bounceCoefficientVariance;
			mDisplacementX								= systemOptions.displacementX;
			mDisplacementY								= systemOptions.displacementY;
			mDisplacementRotation						= systemOptions.displacementRotation;
			
			mStartSizeX 								= systemOptions.startParticleSizeX;
			mStartSizeY 								= systemOptions.startParticleSizeY;
			mStartSizeVarianceX 						= systemOptions.startParticleSizeVarianceX;
			mStartSizeVarianceY 						= systemOptions.startParticleSizeVarianceY;
			mEndSizeX 									= systemOptions.finishParticleSizeX;
			mEndSizeY 									= systemOptions.finishParticleSizeY;
			mEndSizeVarianceX 							= systemOptions.finishParticleSizeVarianceX;
			mEndSizeVarianceY 							= systemOptions.finishParticleSizeVarianceY;
			mSizeOscilationX 							= systemOptions.particleOscilationX;
			mSizeOscilationY 							= systemOptions.particleOscilationY;
			mSizeOscilationVarianceX 					= systemOptions.particleOscilationVarianceX;
			mSizeOscilationVarianceY 					= systemOptions.particleOscilationVarianceY;
			mSizeOscilationFrequencyX 					= systemOptions.particleOscilationFrequencyX;
			mSizeOscilationFrequencyY 					= systemOptions.particleOscilationFrequencyY;
			mSizeOscilationFrequencyVarianceX 			= systemOptions.particleOscilationFrequencyVarianceX;
			mSizeOscilationFrequencyVarianceY 			= systemOptions.particleOscilationFrequencyVarianceY;
			mSizeOscilationOffsetX 						= systemOptions.particleOscilationOffsetX;
			mSizeOscilationOffsetY 						= systemOptions.particleOscilationOffsetY;
			mStartRotation 								= systemOptions.rotationStart * DEG2RAD;
			mStartRotationVariance 						= systemOptions.rotationStartVariance * DEG2RAD;
			mEndRotation 								= systemOptions.rotationEnd * DEG2RAD;
			mEndRotationVariance 						= systemOptions.rotationEndVariance * DEG2RAD;
			mSpeed 										= systemOptions.speed;
			mSpeedVariance 								= systemOptions.speedVariance;
			
			mPhysicsCollisions							= systemOptions.physicsCollisions;
			mWildness								   	= systemOptions.wildness;
			mWildnessVariance						    = systemOptions.wildnessVariance;
			mGravityX 									= systemOptions.gravityX;
			mGravityY									= systemOptions.gravityY;
			mRadialAcceleration 						= systemOptions.radialAcceleration;
			mRadialAccelerationVariance 				= systemOptions.radialAccelerationVariance;
			mTangentialAcceleration 					= systemOptions.tangentialAcceleration;
			mTangentialAccelerationVariance 			= systemOptions.tangentialAccelerationVariance;
			mRepelentForce 								= systemOptions.repelentForce;
			mAttractorForce 							= systemOptions.attractorForce;
			mPassiveAttraction 							= systemOptions.passiveAttraction;
			mInheritVelocityX 							= systemOptions.inheritVelocityX;
			mInheritVelocityY 							= systemOptions.inheritVelocityY;
			mInheritVelocityXVariance 					= systemOptions.inheritVelocityXVariance;
			mInheritVelocityYVariance 					= systemOptions.inheritVelocityYVariance;
			mDrag 										= systemOptions.drag;
			mDragVariance 								= systemOptions.dragVariance;
			
			mStartColor.red 							= systemOptions.startColor.red;
			mStartColor.green 							= systemOptions.startColor.green;
			mStartColor.blue 							= systemOptions.startColor.blue;
			mStartColor.alpha 							= systemOptions.startColor.alpha;
			
			mStartColorVariance.red 					= systemOptions.startColorVariance.red;
			mStartColorVariance.green 					= systemOptions.startColorVariance.green;
			mStartColorVariance.blue 					= systemOptions.startColorVariance.blue;
			mStartColorVariance.alpha 					= systemOptions.startColorVariance.alpha;
			
			mEndColor.red 								= systemOptions.finishColor.red;
			mEndColor.green 							= systemOptions.finishColor.green;
			mEndColor.blue 								= systemOptions.finishColor.blue;
			mEndColor.alpha 							= systemOptions.finishColor.alpha;
			
			mEndColorVariance.red 						= systemOptions.finishColorVariance.red;
			mEndColorVariance.green 					= systemOptions.finishColorVariance.green;
			mEndColorVariance.blue 						= systemOptions.finishColorVariance.blue;
			mEndColorVariance.alpha 					= systemOptions.finishColorVariance.alpha;
			
			mFilter 									= systemOptions.filter;
			mCustomFunc 								= systemOptions.customFunction;
			mSortFunction 								= systemOptions.sortFunction;
			forceSortFlag 								= systemOptions.forceSortFlag;
			exactBounds 								= systemOptions.excactBounds;
		}
		
		private function raiseCapacity(byAmount:int):void{
			var oldCapacity:int = capacity;
			var newCapacity:int = Math.min(mMaxCapacity, capacity + byAmount);
			
			if (oldCapacity < newCapacity)
				mVertexData.numVertices = newCapacity * 4;
		}
		
		///////////////////////////////// QUAD BATCH EXCERPT /////////////////////////////////
		
		// program management
		
		private function getProgram(tinted:Boolean):Program3D{
			var target:Starling = Starling.current;
			var programName:String;
			
			if (mTexture)
				programName = getImageProgramName(mTinted, mTexture.mipMapping, mTexture.repeat, mTexture.format, mSmoothing);
			
			var program:Program3D = target.getProgram(programName);
			
			if (!program){
				// this is the input data we'll pass to the shaders:
				// 
				// va0 -> position
				// va1 -> color
				// va2 -> texCoords
				// vc0 -> alpha
				// vc1 -> mvpMatrix
				// fs0 -> texture
				
				var vertexShader:String;
				var fragmentShader:String;
				
				if (!mTexture) // Quad-Shaders
				{
					vertexShader = "m44 op, va0, vc1 \n" + // 4x4 matrix transform to output clipspace
						"mul v0, va1, vc0 \n"; // multiply alpha (vc0) with color (va1)
					
					fragmentShader = "mov oc, v0       \n"; // output color
				}
				else // Image-Shaders
				{
					vertexShader = tinted ? "m44 op, va0, vc1 \n" + // 4x4 matrix transform to output clipspace
						"mul v0, va1, vc0 \n" + // multiply alpha (vc0) with color (va1)
						"mov v1, va2      \n" // pass texture coordinates to fragment program
						: "m44 op, va0, vc1 \n" + // 4x4 matrix transform to output clipspace
						"mov v1, va2      \n"; // pass texture coordinates to fragment program
					
					fragmentShader = tinted ? "tex ft1,  v1, fs0 <???> \n" + // sample texture 0
						"mul  oc, ft1,  v0       \n" // multiply color with texel color
						: "tex  oc,  v1, fs0 <???> \n"; // sample texture 0
					
					fragmentShader = fragmentShader.replace("<???>", RenderSupport.getTextureLookupFlags(mTexture.format, mTexture.mipMapping, mTexture.repeat, smoothing));
				}
				
				program = target.registerProgramFromSource(programName, vertexShader, fragmentShader);
			}
			
			return program;
		}
		
		private static function getImageProgramName(tinted:Boolean, mipMap:Boolean = true, repeat:Boolean = false, format:String = "bgra", smoothing:String = "bilinear"):String{
			var bitField:uint = 0;
			
			if (tinted)
				bitField |= 1;
			if (mipMap)
				bitField |= 1 << 1;
			if (repeat)
				bitField |= 1 << 2;
			
			if (smoothing == TextureSmoothing.NONE)
				bitField |= 1 << 3;
			else if (smoothing == TextureSmoothing.TRILINEAR)
				bitField |= 1 << 4;
			
			if (format == Context3DTextureFormat.COMPRESSED)
				bitField |= 1 << 5;
			else if (format == "compressedAlpha")
				bitField |= 1 << 6;
			
			var name:String = sProgramNameCache[bitField];
			
			if (name == null){
				name = "QB_i." + bitField.toString(16);
				sProgramNameCache[bitField] = name;
			}
			
			return name;
		}
		
		///////////////////////////////// QUAD BATCH EXCERPT END /////////////////////////////////
		
		///////////////////////////////// QUAD BATCH MODIFICATIONS /////////////////////////////////
		
		/** Indicates if specific particle system can be batch to another without causing a state change.
		 *  A state change occurs if the system uses a different base texture, has a different
		 *  'tinted', 'smoothing', 'repeat' or 'blendMode' (blendMode, blendFactorSource,
		 *  blendFactorDestination) setting, or if it has a different filter instance.
		 *
		 *  <p>In Starling it is not recommended to use the same filter instance for multiple
		 *  DisplayObjects. Sharing a filter instance between instances of the ParticleSystemEX is
		 *  AFAIK the only existing exception to this rule IF the systems will get batched.</p> */
		public function isStateChange(tinted:Boolean, parentAlpha:Number, texture:Texture, pma:Boolean, smoothing:String, blendMode:String, particleBlendMode:String, particlePMA:Boolean, filter:FragmentFilter):Boolean{
			if (mNumParticles == 0)
				return false;
			else if (mTexture != null && texture != null)
				return mTexture.base != texture.base || mTexture.repeat != texture.repeat || mPremultipliedAlpha != pma || mSmoothing != smoothing || mTinted != (tinted || parentAlpha != 1.0) || this.blendMode != blendMode || this.mParticleBlendMode != particleBlendMode || this.mParticlePMA != particlePMA || this.mFilter != filter;
			else
				return true;
		}
		
		/** @inheritDoc */
		private static var sHelperRect:Rectangle = new Rectangle();
		
		public override function render(support:RenderSupport, parentAlpha:Number):void{
			mNumBatchedParticles = 0;
			getBounds(stage, batchBounds);
			
			if (mNumParticles){
				if (mBatching){
					if (!mBatched){
						var first:int = parent.getChildIndex(this);
						var last:int = first;
						var numChildren:int = parent.numChildren;
						var newcapacity:int;
						while (++last < numChildren){
							var next:DisplayObject = parent.getChildAt(last);
							if (next is ParticleSystemEX){
								var nextps:ParticleSystemEX = ParticleSystemEX(next);
								
								if (nextps.mParticles && !nextps.isStateChange(mTinted, alpha, mTexture, mPremultipliedAlpha, mSmoothing, blendMode, mParticleBlendMode, mParticlePMA, mFilter)){
									
									newcapacity = numParticles + mNumBatchedParticles + nextps.numParticles;
									if (newcapacity > sBufferSize)
										break;
									
									mVertexData.rawData.fixed = false;
									nextps.mVertexData.copyTo(this.mVertexData, (numParticles + mNumBatchedParticles) * 4, 0, nextps.numParticles * 4);
									mVertexData.rawData.fixed = true;
									mNumBatchedParticles += nextps.numParticles;
									
									nextps.mBatched = true;
									
									//disable filter of batched system temporarily
									nextps.filter = null;
									
									nextps.getBounds(stage, sHelperRect);
									if (batchBounds.intersects(sHelperRect))
										batchBounds = batchBounds.union(sHelperRect);
								}
								else{
									break;
								}
							}
							else{
								break;
							}
						}
						renderCustom(support, alpha * parentAlpha, support.blendMode);
					}
				}
				else{
					renderCustom(support, alpha * parentAlpha, support.blendMode);
				}
			}
			//reset filter
			super.filter = mFilter;
			mBatched = false;
		}
		
		/** @private */
		private var batchBounds:Rectangle = new Rectangle();
		private function renderCustom(support:RenderSupport, parentAlpha:Number = 1.0, blendMode:String = null):void{
			sVertexBufferIdx = ++sVertexBufferIdx % sNumberOfVertexBuffers;
			
			if (mNumParticles == 0 || !sVertexBuffers)
				return;
			
			// always call this method when you write custom rendering code!
			// it causes all previously batched quads/images to render.
			support.finishQuadBatch();
			
			// make this call to keep the statistics display in sync.
			// to play it safe, it's done in a backwards-compatible way here.
			if (support.hasOwnProperty("raiseDrawCount"))
				support.raiseDrawCount();
			
			//alpha *= this.alpha;
			
			var program:String = getImageProgramName(mTinted, mTexture.mipMapping, mTexture.repeat, mTexture.format, mSmoothing);
			
			var context:Context3D = Starling.context;
			
			sRenderAlpha[0] = sRenderAlpha[1] = sRenderAlpha[2] = mPremultipliedAlpha ? alpha : 1.0;
			sRenderAlpha[3] = alpha;
			
			if (context == null)
				throw new MissingContextError();
			
            var blendFactors:Array = BlendMode.getBlendFactors(mParticleBlendMode, mParticlePMA); 
			context.setBlendFactors(blendFactors[0], blendFactors[1]);
			
			MatrixUtil.convertTo3D(support.mvpMatrix, sRenderMatrix);
			
			context.setProgram(getProgram(mTinted));
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, sRenderAlpha, 1);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 1, sRenderMatrix, true);
			context.setTextureAt(0, mTexture.base);
			
			sVertexBuffers[sVertexBufferIdx].uploadFromVector(mVertexData.rawData, 0, Math.min(sBufferSize * 4, mVertexData.rawData.length / 8));
			
			context.setVertexBufferAt(0, sVertexBuffers[sVertexBufferIdx], VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			if (mTinted)
				context.setVertexBufferAt(1, sVertexBuffers[sVertexBufferIdx], VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4);
			context.setVertexBufferAt(2, sVertexBuffers[sVertexBufferIdx], VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			
			if (batchBounds)
				support.pushClipRect(batchBounds);
			context.drawTriangles(sIndexBuffer, 0, (Math.min(sBufferSize, mNumParticles + mNumBatchedParticles)) * 2);
			if (batchBounds)
				support.popClipRect();
			
			context.setVertexBufferAt(2, null);
			context.setVertexBufferAt(1, null);
			context.setVertexBufferAt(0, null);
			context.setTextureAt(0, null);
		}
		
		///////////////////////////////// QUAD BATCH MODIFICATIONS END /////////////////////////////////
		/** * Removes the system from the juggler and stops animation. */
		public function pause():void{
			if (automaticJugglerManagement)
				mJuggler.remove(this);
			mPlaying = false;
		}
		
		/** * Adds the system to the juggler and resumes the animation. */
		public function resume():void{
			if (automaticJugglerManagement)
				mJuggler.add(this);
			mPlaying = true;
		}
		
		/** * Starts the system to emit particles and adds it to the defaultJuggler if automaticJugglerManagement is enabled.
		 * @param	duration Emitting time in seconds. */
		public function start(duration:Number = 0):void{
			if (mCompleted)
				reset();
			
			if (mEmissionRate != 0 && !mCompleted){
				if (duration == 0){
					duration = mEmissionTimePredefined;
				}
				else if (duration < 0){
					duration = Number.MAX_VALUE;
				}
				mPlaying = true;
				mEmissionTime = duration;
				mFrameTime = 0;
				if (automaticJugglerManagement)
					mJuggler.add(this);
			}
		}
		
		protected var cleared:Boolean;
		public var onClear:Signal = new Signal(ParticleSystemEX);
		/** * Stopping the emitter creating particles.
		 * @param	clear Unlinks the particles returns them back to the pool and stops the animation. */
		public function stop(clear:Boolean = false):void{
			mEmissionTime = 0.0;
			//trace("PARTICLEEX", "particle", name, "stoped", "clear:" + clear);
			if (clear && cleared) {
				if (cleared)
					throw Error ("Clearing a alrady cleared particle system");
				cleared = true;
				pause();
				//trace("PARTICLEEX", "particle", name, "cleared");
				returnParticlesToPool();
				dispatchEventWith(starling.events.Event.CANCEL);
				onClear.dispatch(this);
			}
		}
		
		/** * Resets complete state and enables the system to play again if it has not been disposed.
		 * @return */
		public function reset():Boolean{
			if (!mDisposed){
				if(mEmissionRate == -1)
					mEmissionRate = mMaxNumParticles / mLifespan;
				mFrameTime = 0.0;
				mPlaying = false;
				while (mNumParticles)
				{
					mParticles[--mNumParticles].active = false;
				}
				mMaxCapacity = mMaxNumParticles ? Math.min(MAX_CAPACITY, mMaxNumParticles) : MAX_CAPACITY;
				cleared = false;
				mCompleted = false;
				if (!mParticles)
					getParticlesFromPool();
				return mParticles != null;
			}
			return false;
		}
		
		protected function returnParticlesToPool():void{
			mNumParticles = 0;
			
			if (mParticles){
				// handwritten concat to avoid gc
				var particleIdx:int = mParticles.length;
				var poolIdx:int = sParticlePool.length - 1;
				sParticlePool.fixed = false;
				while (particleIdx)
					sParticlePool[++poolIdx] = mParticles[--particleIdx];
				sParticlePool.fixed = true;
				mParticles = null;
			}
			mVertexData = null;
			
			var instance:ParticleSystemEX;
			var i:int = 0;
			
			// link cache to next waiting system
			if (sFixedPool){
				for (i = 0; i < sInstances.length; ++i){
					instance = sInstances[i];
					if (instance != this && !instance.mCompleted && instance.mPlaying && instance.parent && instance.mParticles == null){
						if (instance.getParticlesFromPool())
							break;
					}
				}
			}
		}
		
		protected function updateEmissionRate():void{ emissionRate = mMaxNumParticles / mLifespan; }
		
		/** @inheritDoc */
		override public function get alpha():Number{ return mSystemAlpha; }
		override public function set alpha(value:Number):void{ mSystemAlpha = value; }
		
		/** * Enables/Disables System internal batching. *
		 * Only ParticleSystemEXs which share the same parent and are siblings next to each other, can be batched.
		 * Of course the rules of "stateChanges" also apply.
		 * @see #isStateChange() */
		public function get batching():Boolean{ return mBatching; }
		public function set batching(value:Boolean):void{ mBatching = value; }
		
		/** * Source blend factor of the particles. *
		 * @see #blendFactorDestination
		 * @see flash.display3D.Context3DBlendFactor */
		public function get particleBlendMode():String{ return mParticleBlendMode; }
		public function set particleBlendMode(value:String):void{ mParticleBlendMode = value; }
		
		/** * Destination blend factor of the particles.
		 * @see #blendFactorSource
		 * @see flash.display3D.Context3DBlendFactor; */
		public function get particlePMA():Boolean{ return mParticlePMA; }
		public function set particlePMA(value:Boolean):void{ mParticlePMA = value; }
		
		/** The number of particles, currently fitting into the vertexData instance of the system. (Not necessaryly all of them are visible)*/
		[Inline]
		final public function get capacity():int{ return mVertexData ? mVertexData.numVertices / 4 : 0; }
		
		/** * Returns complete state of the system. The value is true if the system is done or has been
		 * stopped with the parameter clear. */
		public function get completed():Boolean{ return mCompleted; }
		
		/** * A custom function that can be applied to run code after every particle
		 * has been advanced, (sorted) and before it will be written to buffers/uploaded to the GPU.
		 * * @default undefined */
		public function set customFunction(func:Function):void{ mCustomFunc = func; }
		public function get customFunction():Function{ return mCustomFunc; }
		
		/** The number of particles, currently used by the system. (Not necessaryly all of them are visible). */
		public function get numParticles():int { return mNumParticles; }
		
		/** The duration of one animation cycle. */
		public function get cycleDuration():Number{ return mMaxNumParticles / mEmissionRate; }
		
		/** Number of emitted particles/second. */
		public function get emissionRate():Number{ return mEmissionRate; }
		public function set emissionRate(value:Number):void{ mEmissionRate = value; }
		
		/** Angle of the emitter in degrees. */
		public function get emissionAngle():Number{ return mEmissionAngle; }
		public function set emissionAngle(value:Number):void{ mEmissionAngle = value; }
		
		/** Wheather the particles rotation should respect the emit angle at birth or not. */
		public function set inheritEmissionAngle(value:Boolean):void{ mInheritEmissionAngle = value; }
		public function get inheritEmissionAngle():Boolean{ return mInheritEmissionAngle; }
		
		/** Variance of the emit angle in degrees. */
		public function get emissionAngleVariance():Number{ return mEmissionAngleVariance; }
		public function set emissionAngleVariance(value:Number):void{ mEmissionAngleVariance = value; }
		
		/** Emitter x position.
		 * @see #emitter
		 * @see #emitterObject
		 * @see #emitterY */
		public function get emitterX():Number{ return mEmitterX; }
		public function set emitterX(value:Number):void{ mEmitterX = value; }
		
		/** Variance of the emitters x position.
		 * @see #emitter
		 * @see #emitterObject
		 * @see #emitterX */
		public function get emitterXVariance():Number{ return mEmitterXVariance; }
		public function set emitterXVariance(value:Number):void{ mEmitterXVariance = value; }
		
		/** Emitter y position.
		 * @see #emitterX
		 * @see #emitterObject
		 * @see #emitter */
		public function get emitterY():Number{ return mEmitterY; }
		public function set emitterY(value:Number):void{ mEmitterY = value; }
		
		/** Variance of the emitters position.
		 * @see #emitter
		 * @see #emitterObject
		 * @see #emitterY */
		public function get emitterYVariance():Number{ return mEmitterYVariance; }
		public function set emitterYVariance(value:Number):void{ mEmitterYVariance = value; }
		
		/** Returns true if the system is currently emitting particles.
		 * @see playing
		 * @see start()
		 * @see stop() */
		public function get emitting():Boolean{ return Boolean(mEmissionTime); }
		
		/** Final particle color.
		 * @see #endColor
		 * @see #startColor
		 * @see #startColorVariance
		 * @see #tinted */
		public function get endColor():ColorArgb{ return mEndColor; }
		public function set endColor(value:ColorArgb):void{
			if(value)
				mEndColor = value;
		}
		
		/** Variance of final particle color
		 * @see #endColorVariance
		 * @see #startColor
		 * @see #startColorVariance
		 * @see #tinted */
		public function get endColorVariance():ColorArgb{ return mEndColorVariance; }
		public function set endColorVariance(value:ColorArgb):void{
			if(value)
				mEndColorVariance = value;
		}
		
		/** Final particle rotation in degrees.
		 * @see #endRotationVariance
		 * @see #startRotation
		 * @see #startRotationVariance */
		public function get endRotation():Number{ return mEndRotation; }
		public function set endRotation(value:Number):void{ mEndRotation = value; }
		
		/** Variation of final particle rotation in degrees.
		 * @see #endRotation
		 * @see #startRotation
		 * @see #startRotationVariance */
		public function get endRotationVariance():Number{ return mEndRotationVariance; }
		public function set endRotationVariance(value:Number):void{ mEndRotationVariance = value; }
		
		/** Final particle size in pixels.
		 * The size is calculated according to the width of the texture.
		 * If the particle is animated and SubTextures have differnt dimensions, the size is
		 * based on the width of the first frame.
		 * @see #endSizeVariance
		 * @see #startSize
		 * @see #startSizeVariance */
		public function get endSizeX():Number{ return mEndSizeX; }
		public function set endSizeX(value:Number):void { mEndSizeX = value; }
		
		public function get endSizeY():Number{ return mEndSizeY; }
		public function set endSizeY(value:Number):void{ mEndSizeY = value; }
		
		/** Variance of the final particle size in pixels.
		 * @see #endSize
		 * @see #startSize
		 * @see #startSizeVariance */
		public function get endSizeVarianceX():Number{ return mEndSizeVarianceX; }
		public function set endSizeVarianceX(value:Number):void { mEndSizeVarianceX = value; }
		
		public function get endSizeVarianceY():Number{ return mEndSizeVarianceY; }
		public function set endSizeVarianceY(value:Number):void{ mEndSizeVarianceY = value; }
		
		/** Whether the bounds of the particle system will be calculated or set to screen size.
		 * The bounds will be used for clipping while rendering, therefore depending on the size;
		 * the number of particles; applied filters etc. this setting might in-/decrease performance.
		 *
		 * Keep in mind:
		 * - that the bounds of batches will be united.
		 * - filters may have to change the texture size (performance impact)
		 *
		 * @see #getBounds() */
		public function get exactBounds():Boolean{ return mExactBounds; }
		public function set exactBounds(value:Boolean):void{
			mBounds = value ? new Rectangle() : null;
			mExactBounds = value;
		}
		
		/** The time to fade in spawning particles; set as percentage according to it's livespan. */
		public function get fadeInTime():Number{ return mFadeInTime; }
		public function set fadeInTime(value:Number):void{ mFadeInTime = Math.max(0, Math.min(value, 1)); }
		
		/** The time to fade out dying particles; set as percentage according to it's livespan. */
		public function get fadeOutTime():Number{ return mFadeOutTime; }
		public function set fadeOutTime(value:Number):void{ mFadeOutTime = Math.max(0, Math.min(value, 1)); }
		
		/** The horizontal gravity value.
		 * @see #EMITTER_TYPE_GRAVITY */
		public function get gravityX():Number{ return mGravityX; }
		public function set gravityX(value:Number):void{ mGravityX = value; }
		
		/** Determine if particles will be atracted even if attractor is not actually attrating */
		public function get passiveAttraction():Boolean{ return mPassiveAttraction; }
		public function set passiveAttraction(value:Boolean):void { mPassiveAttraction = value; }
		
		/** Amount of force partcile is attracted by a attractor.*/
		public function get attractorForce():Number{ return mAttractorForce; }
		public function set attractorForce(value:Number):void{ mAttractorForce = value; }
		
		/** The vertical gravity value.
		 * @see #EMITTER_TYPE_GRAVITY */
		public function get gravityY():Number{ return mGravityY; }
		public function set gravityY(value:Number):void{ mGravityY = value; }
		
		/** Lifespan of each particle in seconds.
		 * Setting this value also affects the emissionRate which is calculated in the following way
		 * 		emissionRate = maxNumParticles / mLifespan
		 * @see #emissionRate
		 * @see #maxNumParticles
		 * @see #lifespanVariance */
		public function get lifespan():Number{ return mLifespan; }
		public function set lifespan(value:Number):void{
			mLifespan = Math.max(0.01, value);
			mLifespanVariance = Math.min(mLifespan, mLifespanVariance);
			updateEmissionRate();
		}
		
		/** Variance of the particles lifespan.
		 * Setting this value does NOT affect the emissionRate.
		 * @see #lifespan */
		public function get lifespanVariance():Number{ return mLifespanVariance; }
		public function set lifespanVariance(value:Number):void{ mLifespanVariance = Math.min(mLifespan, value); }
		
		/** The maximum number of particles processed by the system.
		 * It has to be a value between 1 and 16383, however it can never be bigger than maxNumParticles.
		 * @see #maxNumParticles */
		public function get maxCapacity():uint{ return mMaxCapacity; }
		public function set maxCapacity(value:uint):void{ mMaxCapacity = Math.min(MAX_CAPACITY, maxNumParticles, value); }
		
		/** The maximum number of particles taken from the particle pool between 1 and 16383
		 * Changeing this value while the system is running may impact performance.
		 * @see #maxCapacity */
		public function get maxNumParticles():uint{ return mMaxNumParticles; }
		public function set maxNumParticles(value:uint):void{
			returnParticlesToPool();
			mMaxCapacity = Math.min(MAX_CAPACITY, value);
			mMaxNumParticles = maxCapacity;
			var success:Boolean = getParticlesFromPool();
			if (!success)
				stop();
			
			updateEmissionRate();
		}
		
		/** The minimal emitter radius.
		 * @see #EMITTER_TYPE_RADIAL */
		public function get emitterRadius():Number{ return mEmitterRadius; }
		public function set emitterRadius(value:Number):void{ mEmitterRadius = value; }
		
		/** The minimal emitter radius variance.
		 * @see #EMITTER_TYPE_RADIAL */
		public function get emitterRadiusVariance():Number{ return emitterRadiusVariance; }
		public function set emitterRadiusVariance(value:Number):void{ emitterRadiusVariance = value; }
		
		/** The number of unused particles remaining in the particle pool. */
		public static function get particlesInPool():uint{ return sParticlePool.length; }
		
		/** Whether the system is playing or paused.
		 * <p><strong>Note:</strong> If you're not using automaticJugglermanagement the returned value may be wrong.</p>
		 * @see emitting */
		public function get playing():Boolean{ return mPlaying; }
		
		/** The number of all particles created for the particle pool. */
		public static function get poolSize():uint{ return sPoolSize; }
		
		/** Overrides the standard premultiplied alpha value set by the system. */
		public function get premultipliedAlpha():Boolean{ return mPremultipliedAlpha; }
		public function set premultipliedAlpha(value:Boolean):void{ mPremultipliedAlpha = value; }
		
		/** Radial acceleration of particles.
		 * @see #radialAccelerationVariance
		 * @see #EMITTER_TYPE_GRAVITY */
		public function get radialAcceleration():Number{ return mRadialAcceleration; }
		public function set radialAcceleration(value:Number):void{ mRadialAcceleration = value; }
		
		/** Variation of the particles radial acceleration.
		 * @see #radialAcceleration
		 * @see #EMITTER_TYPE_GRAVITY */
		public function get radialAccelerationVariance():Number{ return mRadialAccelerationVariance; }
		public function set radialAccelerationVariance(value:Number):void{ mRadialAccelerationVariance = value; }
		
		/** If this property is set to a number, new initiated particles will start at a random frame.
		 * This can be done even though isAnimated is false. */
		public function get randomStartFrames():Boolean{ return mRandomStartFrames; }
		public function set randomStartFrames(value:Boolean):void{ mRandomStartFrames = value; }
		
		/** Particles rotation per second in degerees.
		 * @see #rotatePerSecondVariance */
		public function get emissionRotationSpeed():Number{ return mEmissionRotationSpeed; }
		public function set emissionRotationSpeed(value:Number):void{ mEmissionRotationSpeed = value; }
		
		/**  Sets the smoothing of the texture.
		 *  It's not recommended to change this value.
		 *  @default TextureSmoothing.BILINEAR */
		public function get smoothing():String{ return mSmoothing; }
		public function set smoothing(value:String):void{
			if (TextureSmoothing.isValid(value))
				mSmoothing = value;
		}
		
		/** A custom function that can be set to sort the Vector of particles.
		 * It will only be called if particles get added/removed.
		 * Anyway it should only be applied if absolutely necessary.
		 * Keep in mind, that it sorts the complete Vector.<EssenceParticle> and not just the active particles!
		 * @default undefined
		 * @see Vector#sort() */
		public function set sortFunction(func:Function):void{ mSortFunction = func; }
		public function get sortFunction():Function{ return mSortFunction; }
		
		/** The particles start color.
		 * @see #startColorVariance
		 * @see #endColor
		 * @see #endColorVariance
		 * @see #tinted */
		public function get startColor():ColorArgb{ return mStartColor; }
		public function set startColor(value:ColorArgb):void{
			if(value)
				mStartColor = value;
		}
		
		/** Variance of the particles start color.
		 * @see #startColor
		 * @see #endColor
		 * @see #endColorVariance
		 * @see #tinted */
		public function get startColorVariance():ColorArgb{ return mStartColorVariance; }
		public function set startColorVariance(value:ColorArgb):void{
			if(value)
				mStartColorVariance = value;
		}
		
		/** The particles start size.
		 * The size is calculated according to the width of the texture.
		 * If the particle is animated and SubTextures have differnt dimensions, the size is
		 * based on the width of the first frame.
		 * @see #startSizeVariance
		 * @see #endSize
		 * @see #endSizeVariance */
		public function get startSizeX():Number{ return mStartSizeX; }
		public function set startSizeX(value:Number):void { mStartSizeX = value; }
		
		public function get startSizeY():Number{ return mStartSizeY; }
		public function set startSizeY(value:Number):void{ mStartSizeY = value; }
		
		/** Variance of the particles start size.
		 * @see #startSize
		 * @see #endSize
		 * @see #endSizeVariance */
		public function get startSizeVarianceX():Number{ return mStartSizeVarianceX; }
		public function set startSizeVarianceX(value:Number):void { mStartSizeVarianceX = value; }
		
		public function get startSizeVarianceY():Number{ return mStartSizeVarianceY; }
		public function set startSizeVarianceY(value:Number):void{ mStartSizeVarianceY = value; }
		
		/** Start rotation of the particle in degrees.
		 * @see #startRotationVariance
		 * @see #endRotation
		 * @see #endRotationVariance */
		public function get startRotation():Number{ return mStartRotation; }
		public function set startRotation(value:Number):void{ mStartRotation = value; }
		
		/** Variation of the particles start rotation in degrees.
		 * @see #startRotation
		 * @see #endRotation
		 * @see #endRotationVariance */
		public function get startRotationVariance():Number{ return mStartRotationVariance; }
		public function set startRotationVariance(value:Number):void{ mStartRotationVariance = value; }
		
		/** The time to scale new born particles from 0 to it's actual size; set as percentage according to it's livespan. */
		public function get spawnTime():Number{ return mSpawnTime; }
		public function set spawnTime(value:Number):void{ mSpawnTime = Math.max(0, Math.min(value, 1)); }
		
		/** The particles velocity in pixels.
		 * @see #speedVariance */
		public function get speed():Number{ return mSpeed; }
		public function set speed(value:Number):void{ mSpeed = value; }
		
		/** Variation of the particles velocity in pixels.
		 * @see #speed */
		public function get speedVariance():Number{ return mSpeedVariance; }
		public function set speedVariance(value:Number):void { mSpeedVariance = value; }
		
		/** Tangential acceleration of particles.
		 * @see #EMITTER_TYPE_GRAVITY */
		public function get tangentialAcceleration():Number{ return mTangentialAcceleration; }
		public function set tangentialAcceleration(value:Number):void{ mTangentialAcceleration = value; }
		
		/** Variation of the particles tangential acceleration.
		 * @see #EMITTER_TYPE_GRAVITY */
		public function get tangentialAccelerationVariance():Number{ return mTangentialAccelerationVariance; }
		public function set tangentialAccelerationVariance(value:Number):void{ mTangentialAccelerationVariance = value; }
		
		/** The Texture/SubTexture which has been passed to the constructor. */
		public function get texture():Texture{ return mTexture; }
		
		/** Enables/Disables particle coloring
		 * @see #startColor
		 * @see #startColorVariance
		 * @see #endColor
		 * @see #endColorVariance */
		public function get tinted():Boolean{ return mTinted; }
		public function set tinted(value:Boolean):void{ mTinted = value; }
		
		/** Juggler to use when <a href="#automaticJugglerManagement">automaticJugglerManagement</a>
		 * is active.
		 * @see #automaticJugglerManagement */
		public function get juggler():Juggler{ return mJuggler; }
		public function set juggler(value:Juggler):void{
			// Not null and different required
			if (value == null || value == mJuggler)
				return;
			
			// Remove from current and add to new if needed
			if (mJuggler.contains(this))
			{
				mJuggler.remove(this);
				value.add(this);
			}
			
			mJuggler = value;
		}
		
		/** List of objects witch emits particles from this system. Particle System can emit particle for multiple emitters. */
		public function get emitters():Vector.<ParticleEmitter> { return mEmitters; }
		
		/** Add a emitter of this particle system. */
		public function assignEmitter(emitter:ParticleEmitter):void {
			if (!mPlaying && emitter.emissionTime > 0 && !emitter.depleted)
				start();
			
			if (emitter && emitters.indexOf(emitter) == -1){
				emitters.push(emitter);
				emitter.systemsAssigned.push(this);
			}
		}
		
		private var emiterIndex1:int;
		private var emiterIndex2:int;
		/** Remove a emitter from this particle system. */
		public function unassignEmitter(emitter:ParticleEmitter):void {
			emiterIndex1 = emitters.indexOf(emitter);
 			emiterIndex2 = emitter.systemsAssigned.indexOf(this);
			if (emitter && emiterIndex1 != -1)
				emitters.splice(emiterIndex1, 1);
			
			if (emitter && emiterIndex2 != -1)
				emitter.systemsAssigned.splice(emiterIndex2, 1);
		}
		
		private var hEmitter:ParticleEmitter;
		public function unassignAllEmitters():void {
			for each (hEmitter in emitters) {
				emiterIndex1 = hEmitter.systemsAssigned.indexOf(this);
				hEmitter.systemsAssigned.splice(emiterIndex1, 1);
			}
			hEmitter = null;
			emitters.length = 0;
		}
	}
}