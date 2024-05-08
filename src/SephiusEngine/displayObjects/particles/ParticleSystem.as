// =================================================================================================
//
//	Starling Framework - Particle System Extension
//	Copyright 2012 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package SephiusEngine.displayObjects.particles
{
	import com.adobe.utils.AGALMiniAssembler;
	import SephiusEngine.displayObjects.particles.system.EssenceParticle;
	import SephiusEngine.utils.pools.ParticlePool;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.osflash.signals.Signal;
	import starling.animation.IAnimatable;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.errors.MissingContextError;
	import starling.events.Event;
	import starling.extensions.particles.Particle;
	import starling.textures.Texture;
	import starling.utils.MatrixUtil;
	import starling.utils.VertexData;
    
    
    
    /** Dispatched when emission of particles is finished. */
    [Event(name = "complete", type = "starling.events.Event")]
	
	/**
	 * Particle system that simulate a essence cloud.
	 * Can give essence to a character that obsorb particles from it.
	 * Modified class from PDParticleSystem from starling.
	 * @author Fernando Rabello - Arthur Graná - Gamua OG
	 */
    public class ParticleSystem extends DisplayObject implements IAnimatable
    {
		/** Texture this particle System is using */
        private var mTexture:Texture;
		
		/** Store all particles being simulated */
        protected var mParticles:Vector.<EssenceParticle>;
        
        private var mProgram:Program3D;
        private var mVertexData:VertexData;
        private var mVertexBuffer:VertexBuffer3D;
        private var mIndices:Vector.<uint>;
        private var mIndexBuffer:IndexBuffer3D;
		
		/** Have no idea... */
        public var mFrameTime:Number;
		/** Number of particles being simulated */
        public var mNumParticles:int;
		/** Amount of particles on the vertex shader? */
        public var mMaxCapacity:int;
		/** Number of particles emited per second */
        public var mEmissionRate:Number;
		/** amount of time system should emit particles. Default is infinite */
        public var mEmissionTime:Number;
        
        /** Helper objects. */
        private static var sHelperMatrix:Matrix = new Matrix();
        private static var sHelperPoint:Point = new Point();
        private static var sRenderAlpha:Vector.<Number> = new <Number>[1.0, 1.0, 1.0, 1.0];
        
        protected var mEmitterX:Number;
        protected var mEmitterY:Number;
        protected var mPremultipliedAlpha:Boolean;
        protected var mBlendFactorSource:String;     
        protected var mBlendFactorDestination:String;
        
        public function ParticleSystem(texture:Texture, emissionRate:Number, 
                                       initialCapacity:int=128, maxCapacity:int=8192,
                                       blendFactorSource:String=null, blendFactorDest:String=null)
        {
            if (texture == null) throw new ArgumentError("texture must not be null");
			
            mTexture = texture;
            mPremultipliedAlpha = texture.premultipliedAlpha;
            mParticles = new Vector.<EssenceParticle>(0, false);
            mVertexData = new VertexData(0);
            mIndices = new <uint>[];
            mEmissionRate = emissionRate;
            mEmissionTime = 0.0;
            mFrameTime = 0.0;
            mEmitterX = mEmitterY = 0;
            mMaxCapacity = Math.min(8192, maxCapacity);
            
            mBlendFactorDestination = blendFactorDest || Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
            mBlendFactorSource = blendFactorSource ||
                (mPremultipliedAlpha ? Context3DBlendFactor.ONE : Context3DBlendFactor.SOURCE_ALPHA);
            
            createProgram();
            raiseCapacity(initialCapacity);
            
            // handle a lost device context
            Starling.current.stage3D.addEventListener(Event.CONTEXT3D_CREATE, 
                onContextCreated, false, 0, true);
        }
        
		public var disposed:Boolean;
		/** Retuirn all particles to the pool and dispose other vars */
        public override function dispose():void
        {
			if (disposed)
				return;
			
            for (k=0; k<mParticles.length; ++k){
				ParticlePool.returnObject(mParticles[k]);
			}
			mParticles.fixed = false;
			mParticles.length = 0;
			mParticles.fixed = true;
			
            Starling.current.stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
            
            if (mVertexBuffer) mVertexBuffer.dispose();
            if (mIndexBuffer)  mIndexBuffer.dispose();
            if (mProgram)      mProgram.dispose();
            
			onComplete.removeAll();
			onComplete = null;
			disposed = true;
            super.dispose();
        }
        
        private function onContextCreated(event:Object):void
        {
            createProgram();
            raiseCapacity(0);
        }
        
        protected function createParticle():EssenceParticle
        {
            return ParticlePool.getObject();
        }
		
		public var onComplete:Signal = new Signal(ParticleSystem);
        private var lastParticle:EssenceParticle;
		/** Does not actually remove the particle. 
		 * Instead it only put the particle to the end of the mParticles vector making particle not being simulated.
		 * No all particles on mParticles are simulated, only the amount describe buy mNumPaticles witch is always less than capacity with is the number of particles on the vertex proggram.*/
        public function removeParticle(aParticle:EssenceParticle):void {
			if (mNumParticles == 0) 
				return;
			
			//Find the last particle on the vector
			lastParticle = mParticles[int(mNumParticles - 1)];
			//Set aParticle on the last position the vector
			mParticles[int(mNumParticles - 1)] = aParticle;
			//Replace aPartcile by the lastParticle
			mParticles[mParticles.indexOf(aParticle)] = lastParticle;
			
			--mNumParticles;
			
			if (mNumParticles == 0) {
				dispatchEvent(new Event(Event.COMPLETE));
				var particleSystem:ParticleSystem = this as ParticleSystem;
				onComplete.dispatch(particleSystem);
				
			}
		}
		
        protected function initParticle(particle:EssenceParticle):void
        {
            particle.x = mEmitterX;
            particle.y = mEmitterY;
            particle.currentTime = 0;
            particle.totalTime = 1;
            particle.color = Math.random() * 0xffffff;
        }

        protected function advanceParticle(particle:EssenceParticle, passedTime:Number):void
        {
            particle.y += passedTime * 250;
            particle.alpha = 1.0 - particle.currentTime / particle.totalTime;
            particle.scaleX = particle.scaleY = 1.0 - particle.alpha; 
            particle.currentTime += passedTime;
        }
        
        private var HoldCapacity:int;
        private var HnewCapacity:int;
        private var Hcontext:Context3D;
		private var HbaseVertexData:VertexData;
        private var HnumVertices:int;
        private var HnumIndices:int;
		private var i:int;
        private function raiseCapacity(byAmount:int):void
        {
            HoldCapacity = capacity;
            HnewCapacity = Math.min(mMaxCapacity, capacity + byAmount);
            Hcontext = Starling.context;
            
            if (Hcontext == null) throw new MissingContextError();
			
            HbaseVertexData = new VertexData(4);
            HbaseVertexData.setTexCoords(0, 0.0, 0.0);
            HbaseVertexData.setTexCoords(1, 1.0, 0.0);
            HbaseVertexData.setTexCoords(2, 0.0, 1.0);
            HbaseVertexData.setTexCoords(3, 1.0, 1.0);
            mTexture.adjustVertexData(HbaseVertexData, 0, 4);
            
            mParticles.fixed = false;
            mIndices.fixed = false;
            
            for (i=HoldCapacity; i<HnewCapacity; ++i)  
            {
                HnumVertices = i * 4;
                HnumIndices  = i * 6;
                
				//trace("--------------------------------");
				
                mParticles[i] = createParticle();
                mVertexData.append(HbaseVertexData);
                
                mIndices[    HnumIndices   ] = HnumVertices;
                mIndices[int(HnumIndices+1)] = HnumVertices + 1;
                mIndices[int(HnumIndices+2)] = HnumVertices + 2;
                mIndices[int(HnumIndices+3)] = HnumVertices + 1;
                mIndices[int(HnumIndices+4)] = HnumVertices + 3;
                mIndices[int(HnumIndices+5)] = HnumVertices + 2;
            }
            
            mParticles.fixed = true;
            mIndices.fixed = true;
            
            // upload data to vertex and index buffers
            
            if (mVertexBuffer) mVertexBuffer.dispose();
            if (mIndexBuffer)  mIndexBuffer.dispose();
            
            mVertexBuffer = Hcontext.createVertexBuffer(HnewCapacity * 4, VertexData.ELEMENTS_PER_VERTEX);
            mVertexBuffer.uploadFromVector(mVertexData.rawData, 0, HnewCapacity * 4);
            
            mIndexBuffer  = Hcontext.createIndexBuffer(HnewCapacity * 6);
            mIndexBuffer.uploadFromVector(mIndices, 0, HnewCapacity * 6);
        }
        
        /** Starts the sysytem for a certain time. @default infinite time */
        public function start(duration:Number=Number.MAX_VALUE):void
        {
            if (mEmissionRate != 0)                
                mEmissionTime = duration;
        }
        
        /** Stops the system and removes all existing particles. */
        public function stop():void
        {
            mEmissionTime = 0.0;
            mNumParticles = 0;
        }
        
        /** Pauses the system; when you 'start' again, it will continue from the old state. */
        public function pause():void
        {
            mEmissionTime = 0.0;
        }
        
        /** Returns an empty rectangle at the particle system's position. Calculating the
         *  actual bounds would be too expensive. */
        public override function getBounds(targetSpace:DisplayObject, 
                                           resultRect:Rectangle=null):Rectangle
        {
            if (resultRect == null) resultRect = new Rectangle();
            
            getTransformationMatrix(targetSpace, sHelperMatrix);
            MatrixUtil.transformCoords(sHelperMatrix, 0, 0, sHelperPoint);
            
            resultRect.x = sHelperPoint.x;
            resultRect.y = sHelperPoint.y;
            resultRect.width = resultRect.height = 0;
            
            return resultRect;
        }
		
		private var particleIndex:int;
		private var particle:EssenceParticle;
		private var nextParticle:EssenceParticle;
		private var timeBetweenParticles:Number;
		
		private var vertexID:int = 0;
		private var color:uint;
		private var pAlpha:Number;
		private var pPotation:Number;
		private var px:Number; 
		private var py:Number;
		private var xOffset:Number; 
		private var yOffset:Number;
		private var textureWidth:Number;
		private var textureHeight:Number;
		
		private var k:int;
		private var j:int;
		
        private var cos:Number;
        private var sin:Number;
        private var cosX:Number;
        private var cosY:Number;
        private var sinX:Number;
        private var sinY:Number;
		private var lastNumParticles:uint;
        public function advanceTime(passedTime:Number):void
        {
            advanceEmitter();
            particleIndex = 0;
            particle = null;
            nextParticle = null;
			lastNumParticles = mNumParticles;
            // advance existing particles
            
            while (particleIndex < mNumParticles)
            {
                particle = mParticles[particleIndex];
                
                if (particle.currentTime < particle.totalTime)
                {
					if (particle.absorbed && particle.alpha <= 0.01) {
						removeParticle(mParticles[particleIndex]);	
					}
					else {
						advanceParticle(particle, passedTime);
						++particleIndex;
					}
                }
                else
                {
					removeParticle(mParticles[particleIndex]);
                }
            }
			
            //trace("PARTICLESYS:mEmissionTime " + mEmissionTime);
			
			if (passedTime == 0)
				throw Error("time passed is 0. Why?");
			
            // create and advance new particles
            /** amount of time system should emit particles. Default is infinite */
            if (mEmissionTime > 0)
            {
                timeBetweenParticles = 1.0 / mEmissionRate;
                mFrameTime += passedTime;
                //trace("PARTICLESYS: mFrameTime" + mFrameTime + " /mNumParticles " + mNumParticles + "/mMaxCapacity " + mMaxCapacity);
				if(mFrameTime == 0)
					trace("PARTICLESYS: frametime is zero");
				while (mFrameTime > 0)
                {
                    if (mNumParticles < mMaxCapacity)
                    {
                        if (mNumParticles == capacity)
                            raiseCapacity(capacity);
						//trace("PARTICLESYS: " + "taking particles from pool");
                        particle = mParticles[int(mNumParticles++)];
                        initParticle(particle);
                        advanceParticle(particle, mFrameTime);
						//Emission Rate could change between particles update
						timeBetweenParticles = 1.0 / mEmissionRate;
                    }
                    
                    mFrameTime -= timeBetweenParticles;
                }
                
                if (mEmissionTime != Number.MAX_VALUE)
                    mEmissionTime = Math.max(0.0, mEmissionTime - passedTime);
            }
			
			if (mNumParticles == 0 && lastNumParticles == 0 && mEmissionTime > 0)
				throw Error("No particle created. Why?");
			
            // update vertex data
            
            vertexID = 0;
            //var alpha:Number;
			pAlpha = NaN;
			color = NaN;
            textureWidth = mTexture.width;
            textureHeight = mTexture.height;
            
			//Update Vertex
            for (k=0; k<mNumParticles; ++k)
            {
                vertexID = k << 2;
                particle = mParticles[k];
                color = particle.color;
                pAlpha = particle.alpha;
                pPotation = particle.rotation;
                px = particle.x;
                py = particle.y;
                xOffset = textureWidth  * particle.scaleX >> 1;
                yOffset = textureHeight * particle.scaleY >> 1;
                
                for (j=0; j<4; ++j)
                {
                    mVertexData.setColor(vertexID+j, color);
                    mVertexData.setAlpha(vertexID+j, pAlpha);
                }
                
                if (pPotation)
                {
                    cos  = Math.cos(pPotation);
                    sin  = Math.sin(pPotation);
                    cosX = cos * xOffset;
                    cosY = cos * yOffset;
                    sinX = sin * xOffset;
                    sinY = sin * yOffset;
                    
                    mVertexData.setPosition(vertexID,   px - cosX + sinY, py - sinX - cosY);
                    mVertexData.setPosition(vertexID+1, px + cosX + sinY, py + sinX - cosY);
                    mVertexData.setPosition(vertexID+2, px - cosX - sinY, py - sinX + cosY);
                    mVertexData.setPosition(vertexID+3, px + cosX - sinY, py + sinX + cosY);
                }
                else 
                {
                    // optimization for rotation == 0
                    mVertexData.setPosition(vertexID,   px - xOffset, py - yOffset);
                    mVertexData.setPosition(vertexID+1, px + xOffset, py - yOffset);
                    mVertexData.setPosition(vertexID+2, px - xOffset, py + yOffset);
                    mVertexData.setPosition(vertexID+3, px + xOffset, py + yOffset);
                }
            }
        }
        
        public function advanceEmitter():void{
            mEmitterX = 0;
            mEmitterY = 0;
        } 

        public override function render(support:RenderSupport, alpha:Number):void
        {
            if (mNumParticles == 0) return;
            
            // always call this method when you write custom rendering code!
            // it causes all previously batched quads/images to render.
            support.finishQuadBatch();
            
            // make this call to keep the statistics display in sync.
            // to play it safe, it's done in a backwards-compatible way here.
            if (support.hasOwnProperty("raiseDrawCount"))
                support.raiseDrawCount();
            
            alpha *= this.alpha;
            
            var context:Context3D = Starling.context;
            var pma:Boolean = texture.premultipliedAlpha;
            
            sRenderAlpha[0] = sRenderAlpha[1] = sRenderAlpha[2] = pma ? alpha : 1.0;
            sRenderAlpha[3] = alpha;
            
            if (context == null) throw new MissingContextError();
            
            mVertexBuffer.uploadFromVector(mVertexData.rawData, 0, mNumParticles * 4);
            mIndexBuffer.uploadFromVector(mIndices, 0, mNumParticles * 6);
            
            context.setBlendFactors(mBlendFactorSource, mBlendFactorDestination);
            context.setTextureAt(0, mTexture.base);
            
            context.setProgram(mProgram);
            context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, support.mvpMatrix3D, true);
            context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, sRenderAlpha, 1);
            context.setVertexBufferAt(0, mVertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2); 
            context.setVertexBufferAt(1, mVertexBuffer, VertexData.COLOR_OFFSET,    Context3DVertexBufferFormat.FLOAT_4);
            context.setVertexBufferAt(2, mVertexBuffer, VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
            
            context.drawTriangles(mIndexBuffer, 0, mNumParticles * 2);
            
            context.setTextureAt(0, null);
            context.setVertexBufferAt(0, null);
            context.setVertexBufferAt(1, null);
            context.setVertexBufferAt(2, null);
        }
        
        // program management
        
        private function createProgram():void
        {
            var mipmap:Boolean = mTexture.mipMapping;
            var textureFormat:String = mTexture.format;
            var context:Context3D = Starling.context;
            
            if (context == null) throw new MissingContextError();
            if (mProgram) mProgram.dispose();
            
            // create vertex and fragment programs from assembly.
            
            var textureOptions:String = "2d, clamp, linear, " + (mipmap ? "mipnearest" : "mipnone");
            
            if (textureFormat == Context3DTextureFormat.COMPRESSED)
                textureOptions += ", dxt1";
            else if (textureFormat == "compressedAlpha")
                textureOptions += ", dxt5";
            
            var vertexProgramCode:String =
                "m44 op, va0, vc0 \n" + // 4x4 matrix transform to output clipspace
                "mul v0, va1, vc4 \n" + // multiply color with alpha and pass to fragment program
                "mov v1, va2      \n";  // pass texture coordinates to fragment program
            
            var fragmentProgramCode:String =
                "tex ft1, v1, fs0 <" + textureOptions + "> \n" + // sample texture 0
                "mul oc, ft1, v0";                               // multiply color with texel color
            
            var vertexProgramAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            vertexProgramAssembler.assemble(Context3DProgramType.VERTEX, vertexProgramCode);
            
            var fragmentProgramAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            fragmentProgramAssembler.assemble(Context3DProgramType.FRAGMENT, fragmentProgramCode);
                
            mProgram = context.createProgram();
            mProgram.upload(vertexProgramAssembler.agalcode, fragmentProgramAssembler.agalcode);
        }
        
        public function get capacity():int { return mVertexData.numVertices / 4; }
        public function get numParticles():int { return mNumParticles; }
        
        public function get maxCapacity():int { return mMaxCapacity; }
        public function set maxCapacity(value:int):void { mMaxCapacity = Math.min(8192, value); }
        
        public function get emissionRate():Number { return mEmissionRate; }
        public function set emissionRate(value:Number):void { 
			mEmissionRate = value; 
			//this is wrong, i think
			//if (mFrameTime < -(1.0 / mEmissionRate))
				//mFrameTime = -1.0 / mEmissionRate;
		}
        
        public function get emitterX():Number { return mEmitterX; }
        public function set emitterX(value:Number):void { mEmitterX = value; }
        
        public function get emitterY():Number { return mEmitterY; }
        public function set emitterY(value:Number):void { mEmitterY = value; }
        
        public function get blendFactorSource():String { return mBlendFactorSource; }
        public function set blendFactorSource(value:String):void { mBlendFactorSource = value; }
        
        public function get blendFactorDestination():String { return mBlendFactorDestination; }
        public function set blendFactorDestination(value:String):void { mBlendFactorDestination = value; }
        
        public function get texture():Texture { return mTexture; }
        public function set texture(value:Texture):void { mTexture = value; createProgram(); }
    }
}