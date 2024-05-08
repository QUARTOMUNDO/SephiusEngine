package SephiusEngine.displayObjects.particles {
	import SephiusEngine.displayObjects.particles.system.EssenceParticle;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.displayObjects.particles.ParticleSystem;
	import tLotDClassic.gameObjects.characters.Characters;
	import flash.display3D.Context3DBlendFactor;
	import flash.geom.Rectangle;
	import org.osflash.signals.Signal;
	import starling.display.BlendMode;
	import starling.extensions.particles.ColorArgb;
	import starling.textures.Texture;
	import starling.utils.deg2rad;
	
// =================================================================================================
//
//	Starling Framework - Particle System Extension
//	Copyright 2012 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================
	
	/**
	 * Particle system that simulate a essence cloud.
	 * Can give essence to a character that obsorb particles from it.
	 * Modified class from PDParticleSystem from starling.
	 * @author Fernando Rabello - Arthur Graná - Gamua OG
	 */
	public class ParticleCloud extends ParticleSystem 
	{
		// embed configuration XML
		[Embed(source="../../../../bin/assets/textures/high/effects/particles/Essence.pex", mimeType="application/octet-stream")]
		protected static const _essenceXML:Class;
		
		/** Object witch is bleeding this essence cloud */
		public var emitter:Object;
		
		public var emitterOffsetX:Number = 0;
		public var emitterOffsetY:Number = 0;
		
		public var inheritVelocityMult:Number = 18;
		public var inheritVelocityX:Number = 1;
		public var inheritVelocityY:Number = 1;
		public var inheritVelocityXVariance:Number = 1;
		public var inheritVelocityYVariance:Number = 1;
		
		public var dragX:Number = 1;
		public var dragY:Number = 1;
		public var dragXVariance:Number = .6;
		public var dragYVariance:Number = .6;
		
		/** If Essence is from Dark, Light or Mestizo(Sephius)*/
		public var textureName:String;
		
		protected var mRepelentForce:Number = 20;
		protected var mAttractorForce:Number = -90000 * 800;
		
        // emitter configuration                            // .pex element name
        protected var mEmitterType:int;                       // emitterType
        protected var mEmitterXVariance:Number;               // sourcePositionVariance x
        protected var mEmitterYVariance:Number;               // sourcePositionVariance y
        
        // particle configuration
        protected var mMaxNumParticles:int;                   // maxParticles
        protected var mLifespan:Number;                       // particleLifeSpan
        protected var mLifespanVariance:Number;               // particleLifeSpanVariance
        protected var mStartSize:Number;                      // startParticleSize
        protected var mStartSizeVariance:Number;              // startParticleSizeVariance
        protected var mEndSize:Number;                        // finishParticleSize
        protected var mEndSizeVariance:Number;                // finishParticleSizeVariance
        protected var mEmitAngle:Number;                      // angle
        protected var mEmitAngleVariance:Number;              // angleVariance
        protected var mStartRotation:Number;                  // rotationStart
        protected var mStartRotationVariance:Number;          // rotationStartVariance
        protected var mEndRotation:Number;                    // rotationEnd
        protected var mEndRotationVariance:Number;            // rotationEndVariance
        
        // gravity configuration
        protected var mSpeed:Number;                          // speed
        protected var mSpeedVariance:Number;                  // speedVariance
        protected var mGravityX:Number;                       // gravity x
        protected var mGravityY:Number;                       // gravity y
        protected var mRadialAcceleration:Number;             // radialAcceleration
        protected var mRadialAccelerationVariance:Number;     // radialAccelerationVariance
        protected var mTangentialAcceleration:Number;         // tangentialAcceleration
        protected var mTangentialAccelerationVariance:Number; // tangentialAccelerationVariance
        
        // radial configuration 
        protected var mMaxRadius:Number;                      // maxRadius
        protected var mMaxRadiusVariance:Number;              // maxRadiusVariance
        protected var mMinRadius:Number;                      // minRadius
        protected var mRotatePerSecond:Number;                // rotatePerSecond
        protected var mRotatePerSecondVariance:Number;        // rotatePerSecondVariance
        
        // color configuration
        protected var mStartColor:ColorArgb;                  // startColor
        protected var mStartColorVariance:ColorArgb;          // startColorVariance
        protected var mEndColor:ColorArgb;                    // finishColor
        protected var mEndColorVariance:ColorArgb;            // finishColorVariance
        
		/** Final number of particles created */
		protected var finalCount:int = 0;
		
		private var _amount:Number = 40;

		public function get amount():Number
		{
			return _amount;
		}

		public function set amount(value:Number):void
		{
			_amount = value;
		}
		public var particleAlpha:Number = 1;
		public var particleBlendMode:String = BlendMode.NORMAL;
		
		public var essenceConfig:XML
		public var essenceTexture:Texture
		
		public var areaRect:Rectangle;
		
		public var autoDestroy:Boolean = false;
		public var autoSetEmissionRate:Boolean = true;
		
		public var onParticleCloudDestroy:Signal = new Signal(String);
		
		public var alphaFadeRatio:Number = .1;
		
		public function ParticleCloud(name:String, textureName:String, particleEmitter:Object, amount:Number=40, emissionRate:Number=10, particleBlendMode:String = BlendMode.NORMAL){
			this.name = name;
			essenceConfig = XML(new _essenceXML());
			essenceTexture  = GameEngine.assets.getTexture(textureName)
			
			this.emitter = particleEmitter;
			this.textureName = textureName;
			
			parseConfig(essenceConfig);
			this.amount = amount;
            mMaxNumParticles = amount;
			
            super(essenceTexture, emissionRate, mMaxNumParticles, mMaxNumParticles,
                  BlendMode.getBlendFactors(particleBlendMode, false)[0], BlendMode.getBlendFactors(particleBlendMode, false)[1]);
            
            mPremultipliedAlpha = false;
			
			
			//trace("[ESSENCE CLOUD]:", particleLoot, deepEssenceLoot, exhaustionTime, Main.getInstance().stage.frameRate);
		}
		
		protected var Hlifespan:Number;
		protected var Hangle:Number;
		protected var Hspeed:Number;
		protected var speedInheritX:Number;
		protected var speedInheritY:Number;
		protected var HstartSize:Number;
		protected var HendSize:Number;
		protected var HstartColor:ColorArgb;
		protected var HcolorDelta:ColorArgb;
		protected var endColorRed:Number;
		protected var endColorGreen:Number;
		protected var endColorBlue:Number;
		protected var endColorAlpha:Number;
		protected var HstartRotation:Number;
		protected var HendRotation:Number;
        
		protected override function initParticle(aParticle:EssenceParticle):void  {
			finalCount++;
			
            particle = aParticle; 
         
            // for performance reasons, the random variances are calculated inline instead
            // of calling a function
            
            Hlifespan = mLifespan + mLifespanVariance * (Math.random() * 2.0 - 1.0); 
            if (Hlifespan <= 0.0) return;
            
            particle.currentTime = 0.0;
            particle.totalTime = Hlifespan;
            
            particle.x = mEmitterX + mEmitterXVariance * (Math.random() * 2.0 - 1.0);
            particle.y = mEmitterY + mEmitterYVariance * (Math.random() * 2.0 - 1.0);
            particle.startX = mEmitterX;
            particle.startY = mEmitterY;
            
            Hangle = mEmitAngle + mEmitAngleVariance * (Math.random() * 2.0 - 1.0);
            Hspeed = mSpeed + mSpeedVariance * (Math.random() * 2.0 - 1.0);
			
			speedInheritX =  ((emitter ? emitter.velocityScaled.x : 0) * inheritVelocityX * inheritVelocityMult);
			speedInheritY =  ((emitter ? emitter.velocityScaled.y : 0) * inheritVelocityY * inheritVelocityMult);
            speedInheritX += speedInheritX * (inheritVelocityXVariance * ((Math.random() * 1.0) - 1.0));
            speedInheritY += speedInheritY * (inheritVelocityYVariance * ((Math.random() * 1.0) - 1.0));
			
            particle.velocityX = Hspeed * Math.cos(Hangle) + speedInheritX;
            particle.velocityY = Hspeed * Math.sin(Hangle) + speedInheritY;
            
            particle.emitRadius = mMaxRadius + mMaxRadiusVariance * (Math.random() * 2.0 - 1.0);
            particle.emitRadiusDelta = mMaxRadius / Hlifespan;
            particle.emitRotation = mEmitAngle + mEmitAngleVariance * (Math.random() * 2.0 - 1.0); 
            particle.emitRotationDelta = mRotatePerSecond + mRotatePerSecondVariance * (Math.random() * 2.0 - 1.0); 
            particle.radialAcceleration = mRadialAcceleration + mRadialAccelerationVariance * (Math.random() * 2.0 - 1.0);
            particle.tangentialAcceleration = mTangentialAcceleration + mTangentialAccelerationVariance * (Math.random() * 2.0 - 1.0);
            
            HstartSize = mStartSize + mStartSizeVariance * (Math.random() * 2.0 - 1.0); 
            HendSize = mEndSize + mEndSizeVariance * (Math.random() * 2.0 - 1.0);
            if (HstartSize < 0.1) HstartSize = 0.1;
            if (HendSize < 0.1)   HendSize = 0.1;
            particle.scaleX = particle.scaleY = HstartSize / texture.width;
            particle.scaleDelta = ((HendSize - HstartSize) / Hlifespan) / texture.width;
            
            // colors
            
            HstartColor = particle.colorArgb;
            HcolorDelta = particle.colorArgbDelta;
            
            HstartColor.red   = mStartColor.red;
            HstartColor.green = mStartColor.green;
            HstartColor.blue  = mStartColor.blue;
            HstartColor.alpha = mStartColor.alpha;
            
            if (mStartColorVariance.red != 0)   HstartColor.red   += mStartColorVariance.red   * (Math.random() * 2.0 - 1.0);
            if (mStartColorVariance.green != 0) HstartColor.green += mStartColorVariance.green * (Math.random() * 2.0 - 1.0);
            if (mStartColorVariance.blue != 0)  HstartColor.blue  += mStartColorVariance.blue  * (Math.random() * 2.0 - 1.0);
            if (mStartColorVariance.alpha != 0) HstartColor.alpha += mStartColorVariance.alpha * (Math.random() * 2.0 - 1.0);
            
           endColorRed = mEndColor.red;
           endColorGreen = mEndColor.green;
           endColorBlue = mEndColor.blue;
           endColorAlpha = mEndColor.alpha;
			
            if (mEndColorVariance.red != 0)   endColorRed   += mEndColorVariance.red   * (Math.random() * 2.0 - 1.0);
            if (mEndColorVariance.green != 0) endColorGreen += mEndColorVariance.green * (Math.random() * 2.0 - 1.0);
            if (mEndColorVariance.blue != 0)  endColorBlue  += mEndColorVariance.blue  * (Math.random() * 2.0 - 1.0);
            if (mEndColorVariance.alpha != 0) endColorAlpha += mEndColorVariance.alpha * (Math.random() * 2.0 - 1.0);
            
            HcolorDelta.red   = (endColorRed   - HstartColor.red)   / Hlifespan;
            HcolorDelta.green = (endColorGreen - HstartColor.green) / Hlifespan;
            HcolorDelta.blue  = (endColorBlue  - HstartColor.blue)  / Hlifespan;
            HcolorDelta.alpha = (endColorAlpha - HstartColor.alpha) / Hlifespan;
			
            particle.alphaFadeDelta = (1 - 0) / Hlifespan / alphaFadeRatio;
			particle.hAlpha = 1;
			particle.alphaFade = 0;
			
            // rotation
            
            HstartRotation = mStartRotation + mStartRotationVariance * (Math.random() * 2.0 - 1.0); 
            HendRotation   = mEndRotation   + mEndRotationVariance   * (Math.random() * 2.0 - 1.0);
            
            particle.rotation = HstartRotation;
            particle.rotationDelta = (HendRotation - HstartRotation) / Hlifespan;
        }
		
        override public function advanceTime(passedTime:Number):void{
			super.advanceTime(passedTime);

			maxNumParticles = amount;

			if (autoDestroy && mNumParticles == 0)
				destoy();
		}

        override public function advanceEmitter():void{
			if(emitter){
				mEmitterX = emitter.x + emitterOffsetX;
				mEmitterY = emitter.y + emitterOffsetY;
			}
        } 

		protected var particle:EssenceParticle;
		protected var restTime:Number;
		protected var distanceX:Number;
		protected var distanceY:Number;
		protected var distanceScalar:Number;
		protected var radialX:Number;
		protected var radialY:Number;
		protected var tangentialX:Number; 
		protected var tangentialY:Number;
		protected var newY:Number;
		protected var repelentDistanceX:Number;
		protected var repelentDistanceY:Number;
		protected var repelentDistanceScalar:Number;
		protected var repelentRadialX:Number;
		protected var repelentRadialY:Number;
		protected var dragForceX:Number;
		protected var dragForceY:Number;
        protected override function advanceParticle(aParticle:EssenceParticle, passedTime:Number):void {
			mEmitterX = emitter ? emitter.x : 0;//Should be updated on advanceTime, not here.
			mEmitterY = emitter ? emitter.y : 0;//Should be updated on advanceTime, not here.
			
            particle = aParticle;
			
            restTime = particle.totalTime - particle.currentTime;
            passedTime = restTime > passedTime ? passedTime : restTime;
            particle.currentTime += passedTime;
            
			distanceX = particle.x - particle.startX;
			distanceY = particle.y - particle.startY;
			distanceScalar = Math.sqrt(distanceX * distanceX + distanceY * distanceY);
			
			if (distanceScalar < 0.01) distanceScalar = 0.01;
			
			radialX = distanceX / distanceScalar;
			radialY = distanceY / distanceScalar;
			tangentialX = radialX;
			tangentialY = radialY;
			
			radialX *= particle.radialAcceleration;
			radialY *= particle.radialAcceleration;
			
			newY = tangentialX;
			tangentialX = -tangentialY * particle.tangentialAcceleration;
			tangentialY = newY * particle.tangentialAcceleration;
			
			repelentDistanceX = particle.x - emitterX;
			repelentDistanceY = particle.y - emitterY;
			repelentDistanceScalar = Math.sqrt(repelentDistanceX * repelentDistanceX + repelentDistanceY * repelentDistanceY);
			
			if (repelentDistanceScalar < 0.01) repelentDistanceScalar = 0.01;
			
			repelentRadialX = repelentDistanceX / repelentDistanceScalar;
			repelentRadialY = repelentDistanceY / repelentDistanceScalar;
			
			repelentRadialX *= repelentForce;
			repelentRadialY *= repelentForce;
			
			dragForceX =  (particle.velocityX * dragX);
			dragForceY =  (particle.velocityY * dragY);
            dragForceX += dragForceX * (dragXVariance * ((Math.random() * 1.0) - 1.0));
            dragForceY += dragForceY * (dragYVariance * ((Math.random() * 1.0) - 1.0));
			
			particle.velocityX += passedTime * ((mGravityX + radialX + tangentialX + repelentRadialX) - dragForceX);
			particle.velocityY += passedTime * ((mGravityY + radialY + tangentialY + repelentRadialY) - dragForceY);
			
			particle.x += particle.velocityX * passedTime;
			particle.y += particle.velocityY * passedTime;
           
            particle.rotation += particle.rotationDelta * passedTime;
            
            particle.colorArgb.red   += particle.colorArgbDelta.red   * passedTime;
            particle.colorArgb.green += particle.colorArgbDelta.green * passedTime;
            particle.colorArgb.blue  += particle.colorArgbDelta.blue  * passedTime;
			particle.scaleX += particle.scaleDelta * passedTime;
			particle.scaleY += particle.scaleDelta * passedTime;
			particle.colorArgb.alpha += particle.colorArgbDelta.alpha * passedTime;
			
			if (Math.min(.80, ((particle.currentTime * particle.currentTime * 10) / particle.totalTime)) < .80)
				particle.colorArgb.alpha = (Math.min(.80, ((particle.currentTime * particle.currentTime * 99) / particle.totalTime)));
			
			particle.alpha = particle.colorArgb.alpha * particleAlpha;
            particle.color = particle.colorArgb.toRgb();
			
			if (areaRect && !areaRect.contains(particle.x, particle.y)) {
				removeParticle(particle);
			}
        }
		
        override public function removeParticle(aParticle:EssenceParticle):void {
			super.removeParticle(aParticle);
			if (autoDestroy && mNumParticles == 0)
				destoy();
		}
		
		public function destoy():void {
			stop();
			removeFromParent(true);
			GameEngine.instance.state.gameJuggler.remove(this);
			onParticleCloudDestroy.dispatch(this.name);
		}
		
        protected function updateEmissionRate():void {
			emissionRate = mMaxNumParticles / mLifespan;
        }

        
        protected function parseConfig(config:XML):void{
            mEmitterXVariance = parseFloat(config.sourcePositionVariance.attribute("x"));
            mEmitterYVariance = parseFloat(config.sourcePositionVariance.attribute("y"));
            mGravityX = parseFloat(config.gravity.attribute("x"));
            mGravityY = parseFloat(config.gravity.attribute("y"));
            mEmitterType = getIntValue(config.emitterType);
            mMaxNumParticles = getIntValue(config.maxParticles);
            mLifespan = Math.max(0.01, getFloatValue(config.particleLifeSpan));
            mLifespanVariance = getFloatValue(config.particleLifespanVariance);
            mStartSize = getFloatValue(config.startParticleSize);
            mStartSizeVariance = getFloatValue(config.startParticleSizeVariance);
            mEndSize = getFloatValue(config.finishParticleSize);
            mEndSizeVariance = getFloatValue(config.FinishParticleSizeVariance);
            mEmitAngle = deg2rad(getFloatValue(config.angle));
            mEmitAngleVariance = deg2rad(getFloatValue(config.angleVariance));
            mStartRotation = deg2rad(getFloatValue(config.rotationStart));
            mStartRotationVariance = deg2rad(getFloatValue(config.rotationStartVariance));
            mEndRotation = deg2rad(getFloatValue(config.rotationEnd));
            mEndRotationVariance = deg2rad(getFloatValue(config.rotationEndVariance));
            mSpeed = getFloatValue(config.speed);
            mSpeedVariance = getFloatValue(config.speedVariance);
            mRadialAcceleration = getFloatValue(config.radialAcceleration);
            mRadialAccelerationVariance = getFloatValue(config.radialAccelVariance);
            mTangentialAcceleration = getFloatValue(config.tangentialAcceleration);
            mTangentialAccelerationVariance = getFloatValue(config.tangentialAccelVariance);
            mMaxRadius = getFloatValue(config.maxRadius);
            mMaxRadiusVariance = getFloatValue(config.maxRadiusVariance);
            mMinRadius = getFloatValue(config.minRadius);
            mRotatePerSecond = deg2rad(getFloatValue(config.rotatePerSecond));
            mRotatePerSecondVariance = deg2rad(getFloatValue(config.rotatePerSecondVariance));
            mStartColor = getColor(config.startColor);
            mStartColorVariance = getColor(config.startColorVariance);
            mEndColor = getColor(config.finishColor);
            mEndColorVariance = getColor(config.finishColorVariance);
            mBlendFactorSource = getBlendFunc(config.blendFuncSource);
            mBlendFactorDestination = getBlendFunc(config.blendFuncDestination);
            
            function getIntValue(element:XMLList):int
            {
                return parseInt(element.attribute("value"));
            }
            
            function getFloatValue(element:XMLList):Number
            {
                return parseFloat(element.attribute("value"));
            }
            
            function getColor(element:XMLList):ColorArgb
            {
                var color:ColorArgb = new ColorArgb();
                color.red   = parseFloat(element.attribute("red"));
                color.green = parseFloat(element.attribute("green"));
                color.blue  = parseFloat(element.attribute("blue"));
                color.alpha = parseFloat(element.attribute("alpha"));
                return color;
            }
            
            function getBlendFunc(element:XMLList):String
            {
                var value:int = getIntValue(element);
                switch (value)
                {
                    case 0:     return Context3DBlendFactor.ZERO; break;
                    case 1:     return Context3DBlendFactor.ONE; break;
                    case 0x300: return Context3DBlendFactor.SOURCE_COLOR; break;
                    case 0x301: return Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR; break;
                    case 0x302: return Context3DBlendFactor.SOURCE_ALPHA; break;
                    case 0x303: return Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA; break;
                    case 0x304: return Context3DBlendFactor.DESTINATION_ALPHA; break;
                    case 0x305: return Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA; break;
                    case 0x306: return Context3DBlendFactor.DESTINATION_COLOR; break;
                    case 0x307: return Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR; break;
                    default:    throw new ArgumentError("unsupported blending function: " + value);
                }
            }
        }
        
        public function get emitterType():int { return mEmitterType; }
        public function set emitterType(value:int):void { mEmitterType = value; }

        public function get emitterXVariance():Number { return mEmitterXVariance; }
        public function set emitterXVariance(value:Number):void { mEmitterXVariance = value; }

        public function get emitterYVariance():Number { return mEmitterYVariance; }
        public function set emitterYVariance(value:Number):void { mEmitterYVariance = value; }

        public function get maxNumParticles():int { return mMaxNumParticles; }
        public function set maxNumParticles(value:int):void { 
            mMaxNumParticles = value; 
			if(autoSetEmissionRate)
				updateEmissionRate(); 
        }

        public function get lifespan():Number { return mLifespan; }
        public function set lifespan(value:Number):void { 
            mLifespan = Math.max(0.01, value);
			if(autoSetEmissionRate)
				updateEmissionRate();
        }

        public function get lifespanVariance():Number { return mLifespanVariance; }
        public function set lifespanVariance(value:Number):void { mLifespanVariance = value; }

        public function get startSize():Number { return mStartSize; }
        public function set startSize(value:Number):void { mStartSize = value; }

        public function get startSizeVariance():Number { return mStartSizeVariance; }
        public function set startSizeVariance(value:Number):void { mStartSizeVariance = value; }

        public function get endSize():Number { return mEndSize; }
        public function set endSize(value:Number):void { mEndSize = value; }

        public function get endSizeVariance():Number { return mEndSizeVariance; }
        public function set endSizeVariance(value:Number):void { mEndSizeVariance = value; }

        public function get emitAngle():Number { return mEmitAngle; }
        public function set emitAngle(value:Number):void { mEmitAngle = value; }

        public function get emitAngleVariance():Number { return mEmitAngleVariance; }
        public function set emitAngleVariance(value:Number):void { mEmitAngleVariance = value; }

        public function get startRotation():Number { return mStartRotation; } 
        public function set startRotation(value:Number):void { mStartRotation = value; }
        
        public function get startRotationVariance():Number { return mStartRotationVariance; } 
        public function set startRotationVariance(value:Number):void { mStartRotationVariance = value; }
        
        public function get endRotation():Number { return mEndRotation; } 
        public function set endRotation(value:Number):void { mEndRotation = value; }
        
        public function get endRotationVariance():Number { return mEndRotationVariance; } 
        public function set endRotationVariance(value:Number):void { mEndRotationVariance = value; }
        
        public function get speed():Number { return mSpeed; }
        public function set speed(value:Number):void { mSpeed = value; }

        public function get speedVariance():Number { return mSpeedVariance; }
        public function set speedVariance(value:Number):void { mSpeedVariance = value; }

        public function get gravityX():Number { return mGravityX; }
        public function set gravityX(value:Number):void { mGravityX = value; }

        public function get gravityY():Number { return mGravityY; }
        public function set gravityY(value:Number):void { mGravityY = value; }

        public function get radialAcceleration():Number { return mRadialAcceleration; }
        public function set radialAcceleration(value:Number):void { mRadialAcceleration = value; }

        public function get radialAccelerationVariance():Number { return mRadialAccelerationVariance; }
        public function set radialAccelerationVariance(value:Number):void { mRadialAccelerationVariance = value; }

        public function get tangentialAcceleration():Number { return mTangentialAcceleration; }
        public function set tangentialAcceleration(value:Number):void { mTangentialAcceleration = value; }

        public function get tangentialAccelerationVariance():Number { return mTangentialAccelerationVariance; }
        public function set tangentialAccelerationVariance(value:Number):void { mTangentialAccelerationVariance = value; }

        public function get maxRadius():Number { return mMaxRadius; }
        public function set maxRadius(value:Number):void { mMaxRadius = value; }

        public function get maxRadiusVariance():Number { return mMaxRadiusVariance; }
        public function set maxRadiusVariance(value:Number):void { mMaxRadiusVariance = value; }

        public function get minRadius():Number { return mMinRadius; }
        public function set minRadius(value:Number):void { mMinRadius = value; }

        public function get rotatePerSecond():Number { return mRotatePerSecond; }
        public function set rotatePerSecond(value:Number):void { mRotatePerSecond = value; }

        public function get rotatePerSecondVariance():Number { return mRotatePerSecondVariance; }
        public function set rotatePerSecondVariance(value:Number):void { mRotatePerSecondVariance = value; }

        public function get startColor():ColorArgb { return mStartColor; }
        public function set startColor(value:ColorArgb):void { mStartColor = value; }

        public function get startColorVariance():ColorArgb { return mStartColorVariance; }
        public function set startColorVariance(value:ColorArgb):void { mStartColorVariance = value; }

        public function get endColor():ColorArgb { return mEndColor; }
        public function set endColor(value:ColorArgb):void { mEndColor = value; }

        public function get endColorVariance():ColorArgb { return mEndColorVariance; }
        public function set endColorVariance(value:ColorArgb):void { mEndColorVariance = value; }
		
		public function get repelentForce():Number{ return mRepelentForce; }
		public function set repelentForce(value:Number):void { mRepelentForce = value; }
		
		public function get attractorForce():Number{ return mAttractorForce; }
		public function set attractorForce(value:Number):void { mAttractorForce = value; }
	}
}