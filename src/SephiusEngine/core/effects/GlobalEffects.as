package SephiusEngine.core.effects
{
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.effects.ParticleManager;
	import SephiusEngine.core.gameStates.LevelManager;
	import SephiusEngine.core.gameplay.damageSystem.DamageManager;
	import SephiusEngine.core.levelManager.GameOptions;
	import SephiusEngine.core.levelManager.LevelArea;
	import SephiusEngine.core.levelManager.LevelSite;
	import SephiusEngine.displayObjects.AnimationPack;
	import SephiusEngine.displayObjects.LightSprite;
	import SephiusEngine.displayObjects.gameArtContainers.AnimationContainer;
	import SephiusEngine.input.InputActionsNames;
	import SephiusEngine.levelObjects.GameSprite;
	import SephiusEngine.levelObjects.effects.SpecialSprite;
	import SephiusEngine.levelObjects.effects.SplashAnimation;
	import SephiusEngine.math.MathUtils;
	import SephiusEngine.userInterfaces.SplashText;
	import SephiusEngine.userInterfaces.UserInterfaces;
	import SephiusEngine.userInterfaces.components.BackgroundBlur;

	import com.greensock.TweenMax;
	import com.greensock.easing.Bounce;

	import flash.geom.Point;

	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.extensions.brinkbit.fullscreenscreenextension.FullScreenExtension;
	import starling.extensions.lighting.core.LightLayer;
	import starling.extensions.lighting.geometry.QuadShadowGeometry;
	import starling.extensions.lighting.lights.PointLight;
	import starling.filters.ColorMatrixFilter;
	import starling.filters.DisplacementMapFilter;
	import starling.filters.FragmentFilterMode;
	import starling.filters.FullScreenBlurFilter;
	import starling.filters.NoiseFilter;
	import starling.filters.TiltShiftFilter;

	import tLotDClassic.GameData.Properties.SpellProperties;
	import tLotDClassic.GameData.Properties.creatureInfos.Actions;
	import tLotDClassic.gameObjects.characters.Characters;
	import tLotDClassic.gameObjects.vfx.BackgroundFlyingObjects;
	import tLotDClassic.attributes.AttributesConstants;
	
	/**
	 * Control effects witch happens globally light illumination, fog, aurora and etc
	 * @author Fernando Rabello
	 */
	public class GlobalEffects {
		public var verbose:Boolean = false;
		
		public var backgroundBlurFilter:FullScreenBlurFilter;
		public var backgroundDisplaceFilter:DisplacementMapFilter;
		public var HDR_FILTER:ColorMatrixFilter;
		public var NOISE_FILTER:NoiseFilter;
		public var DOF_FILTER:TiltShiftFilter;
		//public var BLOOM_FILTER:LightStreakFilter = new LightStreakFilter(10, 4);
		public var NULL_FILTER:FullScreenBlurFilter;
		
		public var uiBackgroundBlur:BackgroundBlur;	
		
		/** Easy access of particle system in the game */
		public var particles:ParticleManager = new ParticleManager("particles");
		/** Store light objects */
		public var lightObjects:Vector.<LightSprite> = new Vector.<LightSprite>();
		private var globalLightsIntensity:Number = 1;
		
		/** ------------------------------------------------------------------- */
		/** ---------------------- Site Effects   ----------------------------- */
		/** ------------------------------------------------------------------- */
		
		/** Store fog objects */
		public var fogObjects:Vector.<GameSprite> = new Vector.<GameSprite>();
		/** Store Rain object */
		public var rainObject:GameSprite;
		/* Store aurora object */
		public var auroraObject:GameSprite;
		/** Store Sun Object */
		public var sunObject:SpecialSprite;
		
		/** ------------------------------------------------------------------- */
		/** ---------------------- Fog Effects   ----------------------------- */
		/** ------------------------------------------------------------------- */
		
		/** Intensity of fog effect controlled by system */
		public var fogIntensity:Number = .2;
		/**Defult value of fog mult. Use this const to return fog mult to default value. 55 */
		public const defaultFogIntensityMult:Number = 1;
		/** Control over intensity of environment fog globally. Rise to create a stronger effect */
		public var fogIntensityMult:Number = defaultFogIntensityMult;
		
		private var _fogColor:uint = 0xD0CEBF;
		/** Color of fog effect */
		public function get fogColor():uint {return _fogColor;}
		public function set fogColor(value:uint):void{
			_fogColor = value;
			var specialSprite:GameSprite;
			for each (specialSprite in fogObjects) {
				specialSprite.color = _fogColor;
			}
		}
		
		public function GlobalEffects() {
			initScreenBlur()
		}
		
		public function initScreenBlur():void {
			if (!GameOptions.DISABLE_BLUR_EFFECTS)
				uiBackgroundBlur = new BackgroundBlur(GameEngine.instance.state as LevelManager ? "StageBlur" : "StageBlur");
			
			//HDR_EFFECT = true;
		}
		
		/*
		public static function getParticleManager():ParticleManager {
			if(!particles)
				particles = new ParticleManager("particles");
			return particles;
		}*/
		
		/** Add effects for a area witch was added to state. Making effects work. */
		public function addAreaEffects(area:LevelArea):void {
			var light:LightSprite; 
			var effect:AnimationContainer;
			for each(light in LevelManager.getInstance().levelRegion.areas[area.globalId].lights){
				light.fadeIn = true;
				light.enabled = true;
				light.disableWithFade = false;
				light.addedToState = true;
			}
			for each(effect in LevelManager.getInstance().levelRegion.areas[area.globalId].effects)
				effect.enabled = true;
		}
		
		/** remove effects for a area witch was added to state. Also removing then from being processed */
		public function removeAreaEffects(area:LevelArea):void {
			var light:LightSprite; 
			var effect:AnimationContainer;
			for each(light in LevelManager.getInstance().levelRegion.areas[area.globalId].lights){
				light.disableWithFade = true;
				light.fadeOut = true;
				light.addedToState = false;
			}
			for each(effect in LevelManager.getInstance().levelRegion.areas[area.globalId].effects)
				effect.enabled = false;
		}
		
		public function menageBackgroundEffects(site:LevelSite):void {
			if (!GameOptions.DISABLE_RAIN)
				if (RAIN_EFFECT)
					if (site.useRainEffect){
						rainObject.animation = "Loop";
						rainObject.visible = true;
					}
					else {
						if(isRaining)
							isRaining = false;
						rainObject.animation = "";
						rainObject.visible = false;
					}
			
			if (!GameOptions.DISABLE_FOG)
				if (FOG_EFFECT)
					if (site.useFogEffect)
						fogIntensityMult = defaultFogIntensityMult;
					else
						fogIntensityMult = 0;
			
			if (!GameOptions.DISABLE_AURORA)
				if (AURORA_EFFECT)
					if (site.useAuroraEffect)
						auroraObject.visible = true;
					else
						auroraObject.visible = false;
			
			if (!GameOptions.DISABLE_FLYING_OBJECTS)
				if (site.useFlyingObjectsEffects && !FLYING_OBJECTS)
					FLYING_OBJECTS = true;
				else if(!site.useFlyingObjectsEffects && FLYING_OBJECTS)
					FLYING_OBJECTS = false;
			
			if (!GameOptions.DISABLE_SUN)
				if (SUN_EFFECT)
					if (site.useSunEffect)
						sunObject.visible = true;
					else
						sunObject.visible = false;
		}
		
		public function setRamdomEnviroment():void {
			if (!GameOptions.DISABLE_FOG && GameEngine.instance.state.view.camera.presence.placeArea.site.useFogEffect) {
				if (_isMisty) {
					if (MathUtils.randomInt(1, 10) > 9)
						isMisty = true;
				}
				else {
					if (MathUtils.randomInt(1, 10) > 9)
						isMisty = true;
				}
			}
			
			if(!GameOptions.DISABLE_RAIN && GameEngine.instance.state.view.camera.presence.placeArea.site.useRainEffect){
				if (_isRaining) {
					if (MathUtils.randomInt(1, 10) > 9)
						isRaining = true;
				}
				else {
					if (MathUtils.randomInt(1, 10) > 9)
						isRaining = true;
				}
			}
			TweenMax.delayedCall(MathUtils.randomInt(5, 15) * 60, setRamdomEnviroment);
		}
		
		private var angle:Number = 0;
		private var scaleAngled:Number = 1;
		private var timeSinceStart:Number = 0;
		private var placeNatureFactor:Number = 1;
		private var placeNatureFactorSpeed:Number = 0.3;
		private var targetPlaceNatureFactor:Number = 1;

		public function updateEnvironment(timePassed:Number):void {
			timeSinceStart += timePassed;

			targetPlaceNatureFactor = GameEngine.instance.state.mainPlayer.presence.placeNature == "Light" ? 1 : 0;
			placeNatureFactor = (targetPlaceNatureFactor + targetPlaceNatureFactor) / placeNatureFactorSpeed;

			var fogAlpha:Number = (1 / GameEngine.instance.state.view.camera.deepFactor / 1.1) * fogIntensity * fogIntensityMult;
			//DOF_FILTER.center = Math.sin(timeSinceStart) * 5;

			if(DOF_FILTER)
				DOF_FILTER.amount = 0.04 * GameEngine.instance.state.view.camera.deepFactor;

			//Sun update
			if (SUN_EFFECT) {
				sunObject.alpha = (((fogAlpha * fogAlpha) * .45) + 0.15) * placeNatureFactor;
			}
			
			var fogObject:GameSprite;
			
			if (NOISE_EFFECT) {
				NOISE_FILTER.seedX = (NOISE_FILTER.seedX + 0.1) % 10;
			}
			
			//Fog update
			if(FOG_EFFECT){
				for each (fogObject in fogObjects) {
					if (fogObject.group < 10){
						fogObject.alpha = fogAlpha;
					}
					else{
						fogObject.alpha = fogAlpha * fogAlpha * .2;
					}
				}
			}
			//Illumination update
			if(LIGHT_EFFECT){
				if (GameEngine.instance.state.mainPlayer.updateCallEnabled ) {
					sephiusLight.x = GameEngine.instance.state.mainPlayer.characterView.parent.localToGlobal(new Point(0, 0)).x + FullScreenExtension.screenLeft;
					sephiusLight.y = GameEngine.instance.state.mainPlayer.characterView.parent.localToGlobal(new Point(0, 0)).y + FullScreenExtension.screenTop;
					sephiusLight.radius = AttributesConstants.sephius_lightBaseRadius * Math.abs(GameEngine.instance.state.mainPlayer.characterView.parent.parent.scaleX);//ViewParallax
					
					//Ease function for sephius light radius
					sephiusLightRadiusDiff = sephiusLightRadiusTarget - sephiusLightRadius;
					sephiusLightRadius += sephiusLightRadiusDiff * 0.02;
					
					//Reduce radius depending on Sephius y position. Simules darkness when in deep of a cave.
					sephiusLight.radius /= sephiusLightRadius;
					sephiusLight.brightness = Math.min(1, sephiusLight.radius / 1000);
					
					//if (sephiusLight.radius < 0)
   						//throw Error ("sephiusLight.radius is negative");
					
					if (sephiusLight.radius == 0)
   						sephiusLight.radius = Number.MAX_VALUE;
					
					//Sephius Effects controls
					if ((GameEngine.instance.state.mainPlayer.action == Actions.SEPHIUS_CASTING_LOOP || GameEngine.instance.state.mainPlayer.action == Actions.SEPHIUS_CASTING_START)){
						if (SpellProperties.isSpellAviable(GameEngine.instance.state.mainPlayer, GameEngine.instance.state.mainPlayer.spells.compoundSpell)){
							if(!GameEngine.instance.state.mainPlayer.characterView.lightEffect1.enabled)
								GameEngine.instance.state.mainPlayer.characterView.lightEffect1.enabled = true;
						}
						else {
							GameEngine.instance.state.mainPlayer.characterView.layeredAnimation1.alpha = 0;
						}
					}
					else {
						GameEngine.instance.state.mainPlayer.characterView.layeredAnimation1.alpha = 1;
						if(GameEngine.instance.state.mainPlayer.characterView.lightEffect1.enabled)
							GameEngine.instance.state.mainPlayer.characterView.lightEffect1.enabled = false;
					}
					
					sephiusQuadShadowObject.x = GameEngine.instance.state.mainPlayer.characterView.parent.localToGlobal(new Point(0, 0)).x;
					sephiusQuadShadowObject.y = GameEngine.instance.state.mainPlayer.characterView.parent.localToGlobal(new Point(0, 0)).y;
					sephiusQuadShadowObject.rotation = GameEngine.instance.state.view.camera.realRotation + GameEngine.instance.state.mainPlayer.characterView.parent.rotation;
					sephiusQuadShadowObject.scaleX = GameEngine.instance.state.mainPlayer.characterView.parent.scaleX;
					sephiusQuadShadowObject.scaleY = GameEngine.instance.state.mainPlayer.characterView.parent.scaleY;
				}
				
				var light:LightSprite;
				for each (light in lightObjects) {
					light.updateLight(timePassed);
				}
			}
			
			if (GameEngine.instance.state.mainPlayer.inputWatcher.isDoing(InputActionsNames.CAMERA_INWARD) && GameEngine.instance.state.mainPlayer.inputWatcher.isDoing(InputActionsNames.MODIFICATION_KEY_2)){
				if (fogIntensityMult < 9.97)
					fogIntensityMult += 0.03;
			}
			
			if (GameEngine.instance.state.mainPlayer.inputWatcher.isDoing(InputActionsNames.CAMERA_OUTWARD) && GameEngine.instance.state.mainPlayer.inputWatcher.isDoing(InputActionsNames.MODIFICATION_KEY_2)){
				if (fogIntensityMult > 0.03)
					fogIntensityMult -= 0.03;
			}
			//trace("fogIntensity " + fogIntensity + "fogIntensityMult " + fogIntensityMult + " fogAlpha " + fogAlpha + " camera factor " + (1 / GameEngine.instance.state.view.camera.realZ / 1.1) + " final alpha: " + specialSprite.alpha)
		}
		/* -------------------------------------------------------------//
		 * ----------------------- Other Effects -----------------------//
		 * -------------------------------------------------------------*/
		
		/** Used to allow changin in game resolution */
		public function nullFilter():void {
			if(!NULL_FILTER){
				NULL_FILTER = new FullScreenBlurFilter(0, 0, 1);
				GameEngine.instance.state.view.viewRootParent1.filter = NULL_FILTER;
				NULL_FILTER.resolution = GameEngine.instance.state.view.resolution * GameEngine.instance.state.view.defaultResolutionRatio;
			}
		}
		
		public function screenDephofField(on:Boolean):void {
			if (!GameOptions.DISABLE_DOF_EFFECT && on) {
				DOF_FILTER = new TiltShiftFilter(0.1, 4.5442, 4);
				DOF_FILTER.resolution = GameEngine.instance.state.view.resolution * GameEngine.instance.state.view.defaultResolutionRatio;
				GameEngine.instance.state.view.viewBackGround.filter = DOF_FILTER;
			}
			else if (!on && DOF_FILTER) {
				GameEngine.instance.state.view.viewBackGround.filter = null;
				DOF_FILTER.dispose();
				DOF_FILTER = null;
			}
		}
		
		public function screenNoise(on:Boolean):void {
			if (!GameOptions.DISABLE_NOISE_EFFECT && on) {
				NOISE_FILTER = new NoiseFilter(.05);
				//NOISE_FILTER.resolution = FullScreenExtension.stageWidth / FullScreenExtension.screenRenderWidth;
				NOISE_FILTER.resolution = GameEngine.instance.state.view.resolution * GameEngine.instance.state.view.defaultResolutionRatio;
				GameEngine.instance.state.view.viewRootParent2.filter = NOISE_FILTER;
			}
			else if (!on && NOISE_FILTER){
				GameEngine.instance.state.view.viewRootParent2.filter = null;
				NOISE_FILTER.dispose();
				NOISE_FILTER = null;
			}
		}
		
		public function animateBackgroundBlurIn():void {
			if(!GameOptions.DISABLE_BLUR_EFFECTS)
				uiBackgroundBlur.animateBackgroundBlurIn();
		}
		
		public function animateBackgroundBlurOut():void {
			if(!GameOptions.DISABLE_BLUR_EFFECTS)
				uiBackgroundBlur.animateBackgroundBlurOut();
		}
		
		public function renderBackgroundBlur():void {
			if(!GameOptions.DISABLE_BLUR_EFFECTS)
				uiBackgroundBlur.renderBackgroundBlur();
		}
		
		public function rendeUIBlur():void {
			if(!GameOptions.DISABLE_BLUR_EFFECTS)
				uiBackgroundBlur.rendeUIBlur();
		}
		
		public function animateUIBlurIn():void {
			if(!GameOptions.DISABLE_BLUR_EFFECTS)
				uiBackgroundBlur.animateUIBlurIn();
		}
		
		public function animateUIBlurOut():void {
			if(!GameOptions.DISABLE_BLUR_EFFECTS)
				uiBackgroundBlur.animateUIBlurOut();
		}
		
		/* -------------------------------------------------------------//
		 * ------------------- Enviromental Effects --------------------//
		 * -------------------------------------------------------------*/
		public var lightLayer:LightLayer;
		
		public var sephiusLight:PointLight;
		public var sephiusLightRadius:Number = 0;
		private var _sephiusLightRadiusTarget:Number= 0;
		public var sephiusLightRadiusDiff:Number = 0;
		
		public var sephiusShadow:QuadShadowGeometry;
		public var sephiusQuadShadowObject:Quad;
		private var sephiusLightBrighness:Number = 0;
		private var sephiusLightFactorAngle:Number = 0;
		
		public var sephiusLightHeightReference:Number = 17500;
		public var sephiusLightTargetReductor:Number = 0.000000023;
		
		public function get sephiusLightRadiusTarget():Number {
			if(GameEngine.instance.state.mainPlayer.y > sephiusLightHeightReference){
				_sephiusLightRadiusTarget = ((GameEngine.instance.state.mainPlayer.y - AttributesConstants.sephius_LightHeightReference) * (GameEngine.instance.state.mainPlayer.y - AttributesConstants.sephius_LightHeightReference)) * AttributesConstants.sephius_LightTargetReductor;
			}
			else
				_sephiusLightRadiusTarget = 0.001;
			
			_sephiusLightRadiusTarget *= GameEngine.instance.state.mainPlayer.presence.placeNature == "Light" ? 0.001 : 1;
			
			return _sephiusLightRadiusTarget;
		}
		
		public function get LIGHT_EFFECT():Boolean { return lightLayer ? true : false; }
		public function set LIGHT_EFFECT(value:Boolean):void {
			if (value && !lightLayer) {
				lightLayer = new LightLayer(FullScreenExtension.screenWidth, FullScreenExtension.screenHeight, 0x000000, 0, 6);
				
				//create a white light that will follow the mouse position
				sephiusLight = new PointLight(1000, 500, 2000 / sephiusLightRadiusTarget, 0xffffff, 1);
				sephiusLight.castShadow = false;
				
				sephiusQuadShadowObject = new Image(GameEngine.assets.getTexture("SiteDeathPlains_End"));
				sephiusQuadShadowObject.width = 35;
				sephiusQuadShadowObject.height = 130;
				sephiusShadow = new QuadShadowGeometry(sephiusQuadShadowObject);
				
				sephiusQuadShadowObject.pivotX = sephiusQuadShadowObject.width >> 1;
				sephiusQuadShadowObject.pivotY = sephiusQuadShadowObject.height >> 1;
				
				lightLayer.addLight(sephiusLight);
				lightLayer.addShadowGeometry(sephiusShadow);
				
				GameEngine.instance.state.view.effectsCanvas.addChild(lightLayer);
			}
			else if (!value && lightLayer) {
				var light:LightSprite
				for each (light in lightObjects) {
					light.addedToRender = false;
				}
				lightLayer.removeFromParent(true);
				lightLayer = null;
				sephiusLight = null;
				sephiusQuadShadowObject.dispose();
				sephiusShadow.dispose();
			}
		}
		
		private var cImage:Image;
		public function get FOG_EFFECT():Boolean { return fogObjects ? true : false; }
		public function set FOG_EFFECT(value:Boolean):void {
			if (value) {
				if(fogObjects.length == 0) {
					cImage = new Image(GameEngine.assets.getTexture("SiteDeathPlainsBG_MistyDenseDouble"));
					//cImage.alignPivot();
					//fogObjects.push(new GameSprite("fogObject" + fogObjects.length, { view:cImage, x:0, 		y:35000,  scaleOffsetX:30, scaleOffsetY:5,   parallax:.01, group:1,  idType:"fog", lockX:true} ));
					//cImage = new Image(GameEngine.assets.getTexture("SiteDeathPlainsBG_MistyDenseDouble"));
					//cImage.alignPivot();
					fogObjects.push(new GameSprite("fogObject" + fogObjects.length, { view:cImage, x:0, 		y:28000,  scaleOffsetX:30, scaleOffsetY:15,  parallax:.03, group:2,  idType:"fog", lockX:true} ));
					cImage = new Image(GameEngine.assets.getTexture("SiteDeathPlainsBG_MistyDenseDouble"));
					//cImage.alignPivot();
					fogObjects.push(new GameSprite("fogObject" + fogObjects.length, { view:cImage, x:0, 		y:31000, scaleOffsetX:20, scaleOffsetY:30,  parallax:.05, group:3,  idType:"fog", lockX:true} ));
					cImage = new Image(GameEngine.assets.getTexture("SiteDeathPlainsBG_MistyDenseDouble"));
					//cImage.alignPivot();
					fogObjects.push(new GameSprite("fogObject" + fogObjects.length, { view:cImage, x:0, 		y:21500, scaleOffsetX:30, scaleOffsetY:40,  parallax:.2,  group:5,  idType:"fog", lockX:true} ));
					cImage = null;
				}
				
				for each (var fogObject:GameSprite in fogObjects) {
					var fogAlpha:Number = (1 / GameEngine.instance.state.view.camera.realZ / 1.1) * fogIntensity * fogIntensityMult;
					fogObject.alpha = fogAlpha;
					LevelManager.getInstance().add(fogObject);
				}
			}
			else if (!value) {
				for each (fogObject in fogObjects) {
					fogObject.kill = true;
				}
				if(fogObjects.length > 0){
					fogObjects.length = 0;
				}
			}
		}
		
		/** Forse disabling rain due problem it creates in this simple implementation */
		public function get RAIN_EFFECT():Boolean { 
			//return rainObject ? true : false; 
			return false;
		}
		public function set RAIN_EFFECT(value:Boolean):void {
			if (value && !rainObject) {
				var rainView:AnimationPack = new  AnimationPack("LevelFXRain", [], 30, "bilinear", true, "all");
				rainObject = new GameSprite("Rain", { view:rainView, group:15, parallax:0.0, scaleOffsetX:3, scaleOffsetY:5, x:0, y:0, blendMode:BlendMode.SCREEN, lockX:true, lockY:true  } );
				GameEngine.instance.state.add(rainObject);
				rainObject.alpha = 0;
			}
			else if (!value && rainObject) {
				rainObject.kill = true;
				rainObject = null;
			}
		}
		
		public function get AURORA_EFFECT():Boolean { return auroraObject ? true : false; }
		public function set AURORA_EFFECT(value:Boolean):void {
			if (value && !auroraObject) {
				var auroraView:AnimationPack = new AnimationPack("LevelFXAurora", [], 30, "bilinear", true, "all");
				auroraObject = new GameSprite("Aurora", { view:auroraView, x: -0, y: -30000, parallax:.01, group:5, blendMode:BlendMode.SCREEN } );
				
				GameEngine.instance.state.add(auroraObject);
				auroraObject.scaleOffsetX = 7.6;
				auroraObject.scaleOffsetY = 4.7;
				auroraObject.alpha = .3;
			}
			else if (!value && auroraObject) {
				auroraObject.kill = true;
				auroraObject = null;
			}
		}
		
		public function get SUN_EFFECT():Boolean { return sunObject ? true : false; }
		public function set SUN_EFFECT(value:Boolean):void {
			if (value && !sunObject) {
				sunObject = new SpecialSprite("sun", { textureName:"SiteDeathPlainsBG_Sun", x:-34000, y:20000, parallax:.01, group:6, idType:"fogLight", blendMode:BlendMode.SCREEN } );
				GameEngine.instance.state.add(sunObject);
				sunObject.spriteArt.alignPivot();
				sunObject.scaleOffsetX = 2;
				sunObject.scaleOffsetY = 2;
			}
			else if (!value && sunObject) {
				sunObject.kill = true;
				sunObject = null;
			}
		}
		
		private var flyingObjectsPool:Vector.<BackgroundFlyingObjects> = new Vector.<BackgroundFlyingObjects>();
		public function createFlyingObjectsPool():void {
			flyingObjectsPool.push( new BackgroundFlyingObjects("Strahthons1", { textureName:"LevelFXStrahtonFlying", frequency:25, group:1, parallax:0.045 }));
			flyingObjectsPool.push( new BackgroundFlyingObjects("Strahthons2", { textureName:"LevelFXStrahtonFlying", frequency:20, group:2, parallax:0.1 } ));
			flyingObjectsPool.push( new BackgroundFlyingObjects("Strahthons3", { textureName:"LevelFXStrahtonFlying", frequency:15, group:3, parallax:0.2 } ));
		}
		
		private var _flyingObjectsOn:Boolean = false;
		public function get FLYING_OBJECTS():Boolean { return _flyingObjectsOn; }
		public function set FLYING_OBJECTS(value:Boolean):void {
			if (value && !_flyingObjectsOn) {
				if(flyingObjectsPool.length == 0)
					createFlyingObjectsPool();
				var flyingObject:BackgroundFlyingObjects;
				for each (flyingObject in flyingObjectsPool) {
					flyingObject.enabled = true;
					LevelManager.getInstance().add(flyingObject);
				}
				_flyingObjectsOn = true;
			}
			else if (!value && _flyingObjectsOn) {
				for each (flyingObject in flyingObjectsPool) {
					flyingObject.enabled = false;
					LevelManager.getInstance().remove(flyingObject);
				}
				_flyingObjectsOn = false;
			}
		}
		
		public function get NOISE_EFFECT():Boolean { return NOISE_FILTER ? true : false; }
		
		public function get BLUR_EFFECT():Boolean {return backgroundBlurFilter ? true : false;}
		public function set BLUR_EFFECT(value:Boolean):void {
			if(value)
				backgroundBlurFilter = new FullScreenBlurFilter(.5, .5, .5);
			else if(backgroundBlurFilter){
				backgroundBlurFilter.dispose();
				backgroundBlurFilter = null
			}
		}
		
		public function get HDR_EFFECT():Boolean {return HDR_FILTER ? true : false;}
		public function set HDR_EFFECT(value:Boolean):void {
			if(value){
				HDR_FILTER = new ColorMatrixFilter();
				HDR_FILTER.resolution = 0.005;
				HDR_FILTER.adjustContrast(.8);
				HDR_FILTER.adjustSaturation(.5);
				HDR_FILTER.adjustBrightness(-.3);
				HDR_FILTER.mode = FragmentFilterMode.ABOVE;
			}
			else if (HDR_FILTER){
				HDR_FILTER.dispose();
				HDR_FILTER = null
			}
		}
		
		public function disableEffects():void {
			
		}
		
		private var _isRaining:Boolean = false;
		/** Makes it rain */
		public function get isRaining():Boolean { return _isRaining; }
		public function set isRaining(value:Boolean):void {
			_isRaining = value;
			if (value) {
				rainObject.animation = "Loop";
				TweenMax.to(rainObject, 7, { alpha:1 } );
				TweenMax.to(this, 30, { hexColors: { fogColor:0xB9B7AE }} );
				trace("its starting to rain!!!");
			}
			else {
				TweenMax.to(rainObject, 7, { alpha:0 } );
				TweenMax.to(rainObject, 0, { animation:"", delay:7 } );
				TweenMax.to(this, 30, { hexColors: { fogColor:0xffffff }} );	
				trace("its stoping to rain!!!");
			}
		}
		
		private var _isMisty:Boolean = false;
		/**makes time cloud */
		public function get isMisty():Boolean { return _isMisty }
		public function set isMisty(value:Boolean):void {
			_isMisty = value;
			if(value){
				TweenMax.to(this, 5, { fogIntensity:1 } );
				//customSplashTextsByDemand("The weather is getting misty...", LevelManager.sephius, true );
				trace("The weather is getting misty...");
			}
			else{
				TweenMax.to(this, 5, { fogIntensity:0.2 } );
				//customSplashTextsByDemand("The misty is dissipating...", LevelManager.sephius, true );
				trace("The misty is dissipating...");
			}
		}
		
		/* -------------------------------------------------------------//
		 * ----------------------- Interface Effects -------------------//
		 * -------------------------------------------------------------*/
		
		public function criticalEffect():void {
			if (GameOptions.DISABLE_ALL_EFFECTS)
				return;
				
			if(!GameOptions.DISABLE_UI_EFFECTS)
				UserInterfaces.instance.hud.critical();
		}
		
		public function screenBright():void {
			if (GameOptions.DISABLE_ALL_EFFECTS)
				return;
				
			if(!GameOptions.DISABLE_UI_EFFECTS)
				UserInterfaces.instance.hud.critical();
		}
		
		public function screenBluring(type:String = "damage"):void {
			if (BLUR_EFFECT){
				//if (!backgroundDisplaceFilter)
					//backgroundDisplaceFilter = new DisplacementMapFilter(GameEngine.assets.getTexture("ZoOClouds1"), null, BitmapDataChannel.RED, BitmapDataChannel.RED, 40, 40, true);
					
				if (type == "damage" && !GameEngine.instance.state.mainPlayer.characterAttributes.dead) {
					GameEngine.instance.state.view.viewRoot.filter = backgroundBlurFilter;
					TweenMax.to(backgroundBlurFilter, .5, { startAt: { blurX:8, blurY:8 }, blurX:0, blurY:0, ease:Bounce.easeInOut, onComplete:removeScreenBlur } );
				}
				if(type == "status" && !GameEngine.instance.state.mainPlayer.characterAttributes.dead){
					GameEngine.instance.state.view.viewRoot.filter = backgroundBlurFilter;
					TweenMax.to(backgroundBlurFilter, 1, { startAt: { blurX:.2, blurY:.2 }, blurX:2, blurY:2, yoyo:true, repeat: -1, ease:Bounce.easeInOut } );
				}
				if (type == "death") {
					TweenMax.killTweensOf(backgroundBlurFilter);
					GameEngine.instance.state.view.viewRoot.filter = backgroundBlurFilter;
					TweenMax.to(backgroundBlurFilter, 3, { startAt: { blurX:0, blurY:0 }, blurX:15, blurY:15, ease:Bounce.easeInOut } );
				}
				//TweenMax.to(backgroundDisplaceFilter.mapPoint, 2, { startAt:{ y:0 }, y:500, yoyo:true, repeat:-1, ease:Bounce.easeInOut } );
			}
		}
		
		public function removeScreenBlur():void {
			GameEngine.instance.state.view.viewRoot.filter = null;
		}
		
		
		/* -------------------------------------------------------------//
		 * ----------------------- Splashes ----------------------------//
		 * -------------------------------------------------------------*/
		
		/** Define a splash by a spell name in case a spell should generate a special splash. If spell is not listed then method will call splash by nature dominance */
		public function defineSplashBySpellDamage(spellname:String, damage:DamageManager, showSplashArt:Boolean = true, showSplashText:Boolean = true):void {
			if (GameOptions.DISABLE_SPLASHES)
				return;
				
			switch (spellname){
				case "Lightning": 
				case "Lightning_Orb": 
					if(showSplashText && !GameOptions.DISABLE_COMBAT_INFORMATION)
						SplashText.showSplashText(damage.sufferAttribute.holder.sufferParent, damage.totalPower, damage.outcome, { x:damage.originLocation.x, y:damage.originLocation.y, linkPosition:false });
					if(showSplashArt)
						SplashAnimation.showSplash(damage.sufferAttribute.holder.sufferParent, "Bolt", { x:damage.originLocation.x, y:damage.originLocation.y, linkPosition:false}, damage.outcome, true);
					break;
				
				default: 
					defineSplashByDamageNatureDominance(damage, showSplashArt, showSplashText);
					break;
			}
		}
		
		/** Define a splash by the nature dominance, in other words, witch damage nature was greater. If nature was physic, than method call normal splash by name */
		public function defineSplashByDamageNatureDominance(damage:DamageManager, showSplashArt:Boolean = true, showSplashText:Boolean = true):void {
			if (GameOptions.DISABLE_SPLASHES)
				return;
			
			log("defining splash by Nature: " + damage.natureDominance + " DamageType:" + damage.outcome + " Damage:" + damage.totalPower + " show art?" + showSplashArt + " show text?" + showSplashText);
			
			if (showSplashText && !GameOptions.DISABLE_COMBAT_INFORMATION)
				SplashText.showSplashText(damage.sufferAttribute.holder.sufferParent, damage.totalPower, damage.outcome, { x:damage.originLocation.x, y:damage.originLocation.y, linkPosition:false } );
			
			if (showSplashArt)
				if (SplashAnimation.splashNames.indexOf(damage.natureDominance) > -1)
					SplashAnimation.showSplash(damage.sufferAttribute.holder.sufferParent, damage.natureDominance, { x:damage.originLocation.x, y:damage.originLocation.y, linkPosition:false}, damage.outcome, damage.totalPower > 0);
		}
		
		public function defineSplashByDefaultDamage(damage:DamageManager, showSplashArt:Boolean = true, showSplashText:Boolean = true):void {
			if (GameOptions.DISABLE_SPLASHES)
				return;
			
			var currentSplash:String = (damage.outcome == "weak" || damage.outcome == "normal") ? damage.sufferAttribute.weakSplash : damage.sufferAttribute.normalSplash;
			if (damage.defended)
				currentSplash = damage.sufferAttribute.defenceSplash;
			
			log("defineSplashByDefault: " + currentSplash + damage.natureDominance + " DamageType:" + damage.outcome + " Damage:" + damage.totalPower + " show art?" + showSplashArt + " show text?" + showSplashText);
			
			if (showSplashArt)
				if (SplashAnimation.splashNames.indexOf(currentSplash) > -1)
					SplashAnimation.showSplash(damage.sufferAttribute.holder.sufferParent, currentSplash, { x:damage.originLocation.x, y:damage.originLocation.y, linkPosition:false }, damage.outcome, true );
			
			if ((showSplashText && !GameOptions.DISABLE_COMBAT_INFORMATION))
				SplashText.showSplashText(damage.sufferAttribute.holder.sufferParent, damage.totalPower, damage.outcome, { x:damage.originLocation.x, y:damage.originLocation.y, linkPosition:false });
		}
		
		public function splashByEssenceAbsorbation(essenceNature:String, params:Object = null):void {
			if (GameOptions.DISABLE_SPLASHES)
				return;
				
			if (SplashAnimation.splashNames.indexOf("Essence" + essenceNature) > -1)
				SplashAnimation.showSplash(null, "Essence" + essenceNature, params, "essence", true);
		}
		
		public function spawnSplash(parent:Object):void {
			if (GameOptions.DISABLE_SPLASHES)
				return;
			
			var color:uint = 0xffffff;
			var size:Number = 13;
			if (parent as Characters) {
				color = parent.characterProperties.mainEssenceProperties.origin == "Dark" ? 0xff6b70 : parent.characterProperties.mainEssenceProperties.origin == "Light" ?  0x77a7ff : 0xffffff;
				size = parent.size * 2;
			}
			
			SplashAnimation.showSplash(parent, "SpawnSplash1", { x:parent.x, y:parent.y, scaleOffsetX:(size * .01), scaleOffsetY:(size * .01), color:color, linkPosition:false }, "normal", false);
		}
		
		/** Just create a splash using given name */
		public function splashByDamand(splashName:String, parent:Object, params:Object = null, type:String = "normal", useSound:Boolean = false):void {
			if (GameOptions.DISABLE_SPLASHES)
				return;
				
			if (SplashAnimation.splashNames.indexOf(splashName) > -1)
				SplashAnimation.showSplash(parent, splashName, params, type, useSound);
		}
		
		/** Define a splash by the nature dominance, in other words, witch damage nature was greater. If nature was physic, than method call normal splash by name */
		public function customSplashTextsByDemand(value:Number, parent:Object, inSansico:Boolean = false, offsetX:Number=0, offsetY:Number=0):void {
			if (GameOptions.DISABLE_SPLASHES)
				return;
			
			SplashText.showSplashText(parent, value, "normal", { x:parent.x, y:parent.y, displacementX:offsetX, displacementY:offsetY, linkPosition:true }, inSansico);
		}
		
		private function log(message:String, parent:Object = null):void{
			if (verbose)
				trace("[Effects]:", "[" + (parent ? parent.name : "") + "]", message);
		}
		
		public function dispose():void {
			this.AURORA_EFFECT = false;
			this.BLUR_EFFECT = false;
			this.FLYING_OBJECTS = false;
			this.FOG_EFFECT = false;
			this.HDR_EFFECT = false;
			this.LIGHT_EFFECT = false;
			this.RAIN_EFFECT = false;
			
			if(DOF_FILTER)
				DOF_FILTER.dispose();
			DOF_FILTER = null;
			
			if(NOISE_FILTER)
				NOISE_FILTER.dispose();
			NOISE_FILTER = null;
			
			if(HDR_FILTER)
				HDR_FILTER.dispose();
			HDR_FILTER = null
			
			//if(BLOOM_FILTER)
				//BLOOM_FILTER.dispose();
			//BLOOM_FILTER = null
			
			if(NULL_FILTER)
				NULL_FILTER.dispose();
			NULL_FILTER = null
			
			screenNoise(false);
			screenDephofField(false);
			
			uiBackgroundBlur.dispose();
			uiBackgroundBlur = null;
			
			lightObjects.length = 0;
		}
	}
}