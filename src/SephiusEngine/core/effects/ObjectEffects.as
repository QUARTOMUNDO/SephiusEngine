 package SephiusEngine.core.effects
{
	import SephiusEngine.sounds.system.components.physics.PhysicSoundComponent;
	import com.greensock.*;
	import com.greensock.plugins.*;
	import tLotDClassic.GameData.Properties.StatusProperties;
	import SephiusEngine.core.levelManager.GameOptions;
	import SephiusEngine.displayObjects.AnimationPack;
	import SephiusEngine.displayObjects.GameArtContainer;
	import SephiusEngine.levelObjects.interfaces.IPhysicSoundEmitter;
	import SephiusEngine.levelObjects.interfaces.ISpriteView;
	import SephiusEngine.utils.ColorsUtils;
	import SephiusEngine.displayObjects.configs.SpriteProperties;
	import flash.utils.Dictionary;
	import starling.display.Image;
	import starling.extensions.particles.ColorArgb;
	import starling.filters.ColorMatrixFilter;
	import starling.filters.FragmentFilterMode;
	TweenPlugin.activate([EndArrayPlugin, TintPlugin, ColorMatrixFilterPlugin, ColorTransformPlugin]);
	
	/**
	 * This class deals with some special effects in the game objects.
	 * Things like color filters, status effects, glows and etc.
	 * Several kinds of objects should instantiate this class, like Sephius, NewEnemy, and level objects as well.
	 * @author ... Fernando Rabello
	 */
	public dynamic class ObjectEffects{
		private var parent:ISpriteView;
		private var _mainArt:Object;
		
		private var started:Boolean = false;
		
		private var activatedMatrixes:Vector.<String> = new Vector.<String>();
		
		public var matixFilter:ColorMatrixFilter = new ColorMatrixFilter();
		private var _contrast:Number = 0;
		private var _brightness:Number = 0;
		private var _saturation:Number = 0;
		private var _hue:Number = 0;
		private var _finalColor:int = ColorsUtils.WHITE;
		
		public var tweens:Dictionary =  new Dictionary();
		public var statusEffectsArts:Dictionary =  new Dictionary();
		
		public var activatedStatusColors:Vector.<String> = new Vector.<String>();
		public var activatedStatus:Vector.<StatusProperties> = new Vector.<StatusProperties>();
		
		public static var verbose:Boolean = false;
		
		public static var spriteProperty:SpriteProperties;
		public static var FILTRED_OBJECTS:Vector.<ISpriteView> = new Vector.<ISpriteView>();
		
		public function ObjectEffects(_parent:ISpriteView){
			parent = _parent;
			
			//soundComponent = new SpriteSoundComponent(_parent.spriteName, _parent as ISpriteView);
			//soundComponent.radius = 1000;
			
			matixFilter.adjustContrast(.5);
			matixFilter.adjustBrightness(.5);
			matixFilter.adjustSaturation(-.5);
			matixFilter.adjustHue(0);
			matixFilter.mode = FragmentFilterMode.ABOVE;
		}
		
		/* -------------------------------------------------------------//
		 * -----------------------status Effects -----------------------//
		 * -------------------------------------------------------------*/
		
		public function applyStatusEffects(On:Boolean, statusProperty:StatusProperties):void{
			if (GameOptions.DISABLE_ALL_EFFECTS)
				return;
			
			log("Effects Start " + statusProperty.objectBaseName + " " + On + " " + tweens[statusProperty.objectBaseName], parent)
			var index:int = activatedStatus.indexOf(statusProperty);
			
			if (On) {
				if(index == -1){
					activatedStatus.push(statusProperty);
					//trace("EFFECT " + statusProperty.name);
					if (!GameOptions.DISABLE_COLOR_EFFECTS_AND_FILTERS) {
						this[statusProperty.objectBaseName + "Angle"] = Math.PI * .5;
						
						applyColor(true, statusProperty);	
						applyFilter(true, statusProperty);	
					}
					if(!GameOptions.DISABLE_STATUS_EFFECTS){
						if (statusProperty.spriteParams && !statusEffectsArts[statusProperty.objectBaseName + "AnimationEffect"]) {
							statusEffectsArts[statusProperty.objectBaseName + "AnimationEffect"] = new AnimationPack(statusProperty.objectBaseName, null, 30, "bilinear", true, "all");//Create Status Art visualization.
							statusEffectsArts[statusProperty.objectBaseName + "AnimationEffect"].blendMode = statusProperty.spriteParams.blendMode;
							mainArt.parent.addChild(statusEffectsArts[statusProperty.objectBaseName + "AnimationEffect"]);//Add this art to CharacterView.
							TweenMax.to(statusEffectsArts[statusProperty.objectBaseName + "AnimationEffect"], 1, { startAt: { alpha:0 }, alpha:1 } );//Fade alpha.
							soundComponent.play("FX_status_" + statusProperty.objectBaseName, "status", 1, true)//Make character play the status sound.
						}
					}
				}
				else {
					this[statusProperty.objectBaseName + "Angle"] = Math.PI * .5;
				}
			}
			else {
				if(index != -1){
					activatedStatus.splice(index, 1);
					
					if (!GameOptions.DISABLE_COLOR_EFFECTS_AND_FILTERS) {
						delete this[statusProperty.objectBaseName + "Angle"];
						
						applyColor(false, statusProperty);	
						applyFilter(false, statusProperty);	
					}
					if(!GameOptions.DISABLE_STATUS_EFFECTS){
						if (statusProperty.spriteParams && statusEffectsArts[statusProperty.objectBaseName + "AnimationEffect"]) {
							TweenMax.to(statusEffectsArts[statusProperty.objectBaseName + "AnimationEffect"], 1, { startAt: { alpha:1 }, alpha:0, onComplete:statusEffectsArts[statusProperty.objectBaseName + "AnimationEffect"].dispose } );
							TweenMax.to(statusEffectsArts[statusProperty.objectBaseName + "AnimationEffect"], 0, { delay:1, onComplete:statusEffectsArts[statusProperty.objectBaseName + "AnimationEffect"].removeFromParent  } );
							statusEffectsArts[statusProperty.objectBaseName + "AnimationEffect"] = null;
							delete statusEffectsArts[statusProperty.objectBaseName + "AnimationEffect"];
							
							soundComponent.stop("FX_status_" + statusProperty.objectBaseName)//Make character stop the status sound.
						}
					}
				}
			}
		}
		//public function nullAnimation(varName:String):void { this[varName] = null; }
		
		public function applyColor(add:Boolean, statusProperty:StatusProperties):void {
			if (add)
				numOfColorsApplied++;
			else
				numOfColorsApplied--;
		}
		
		private var cAngle:Number;
		private var maxSinAngle:Number;
		private var minSinAngle:Number;
		private var cColor:ColorArgb = new ColorArgb();
		private var cColorIn:ColorArgb = new ColorArgb();
		private var cColorOut:ColorArgb = new ColorArgb();
		private var cHue:Number;
		private var cBrightness:Number;
		private var cContrast:Number;
		private var cSaturation:Number;
		/** This method define a single color from several status colors witch is actvated same time.
		 * As is impossible to stack filters at this time, we can only set only 1 color for a object.
		 * So if 2 status is activated the color result will be a subtraction of the 2 status colors */
		public function updateProperties(timeDelta:Number):void{
			color = ColorsUtils.WHITE;
			cColor.setChannels(1, 1, 1, 1);
			cHue		= 1;
			cBrightness = 1;
			cContrast 	= 1;
			cSaturation = 1;
			
			if (numOfColorsApplied == 0)
				return;
			
			var statusProperty:StatusProperties;
			for each (statusProperty in activatedStatus){
				if (statusProperty.type != StatusProperties.TYPE_NEUTRAL) {
					this[statusProperty.objectBaseName + "Angle"] += statusProperty.cycleTime * timeDelta ;
					this[statusProperty.objectBaseName + "Angle"] %= (2 * Math.PI);
					cAngle = this[statusProperty.objectBaseName + "Angle"];
					
					maxSinAngle = (Math.sin(cAngle) + 1) / 2;
					minSinAngle = 1 - maxSinAngle;
					
					//Update Colors
					cColor.red   *= (statusProperty.filterParams.colorIn.red * maxSinAngle)  + (statusProperty.filterParams.colorOut.red * minSinAngle);
					cColor.green *= (statusProperty.filterParams.colorIn.green * maxSinAngle)+ (statusProperty.filterParams.colorOut.green * minSinAngle);
					cColor.blue  *= (statusProperty.filterParams.colorIn.blue * maxSinAngle) + (statusProperty.filterParams.colorOut.blue * minSinAngle);
					
					//Update Hue, Brighness, Contrast and Sat
					cHue		*= 1 + (statusProperty.filterParams.hueIn * maxSinAngle)  		 + (statusProperty.filterParams.hueOut * minSinAngle);
					cBrightness *= 1 + (statusProperty.filterParams.brightnessIn * maxSinAngle)  + (statusProperty.filterParams.brightnessOut * minSinAngle);
					cContrast 	*= 1 + (statusProperty.filterParams.contrastIn * maxSinAngle)  	 + (statusProperty.filterParams.contrastOut * minSinAngle);
					cSaturation *= 1 + (statusProperty.filterParams.saturationIn * maxSinAngle)  + (statusProperty.filterParams.saturationOut * minSinAngle);
					
				}
			}
			
			hue			= cHue - 1;
			brightness 	= cBrightness - 1;
			contrast 	= cContrast - 1;
			saturation 	= cSaturation - 1;
			
			//trace(hue.toFixed(3), brightness.toFixed(3), contrast.toFixed(3), saturation.toFixed(3))
			
			color = cColor.toRgb();
		}
		
		public function applyFilter(add:Boolean, statusProperty:StatusProperties):void {
			if (add) {
				if (statusProperty.filterParams.useMatrix){
					numOfMatrixessApplied++;
					if(numOfMatrixessApplied > 0)
						mainArt.filter = matixFilter; 
				}
			}
			else if (!add) {
				if (statusProperty.filterParams.useMatrix) {
					numOfMatrixessApplied--;
					if(numOfMatrixessApplied <= 0)
						mainArt.filter = null; 
				}
			}
			//trace("Effects applying filter" + " useMatrix:" + statusProperty.filterParams.useMatrix + " add:" + add + " index:" + index + " activatedMatrixes:" +  activatedMatrixes + " parent:" + parent);
		}
		
		public function updateMatrixFilter():void {
			matixFilter.reset();
			matixFilter.adjustHue(hue);
			matixFilter.adjustSaturation(saturation);
			matixFilter.adjustBrightness(brightness);
			matixFilter.adjustContrast(contrast);
		}
		
		public function update(timeDelta:Number):void {
			updateProperties(timeDelta);
			if(numOfMatrixessApplied > 0){
				updateMatrixFilter();
			}
			//trace("OEFFECT " + mainArt.filter);
		}
		
		public function get soundComponent():PhysicSoundComponent {return (parent as IPhysicSoundEmitter).soundComponent;}
		
		/**
		 * Change the contrast of the matrix filter.
		 * In order to it become visible in the game, filter should be applied to the parent art (animation, not spriteArt).
		 */
		public function get contrast():Number {
			return _contrast;
		}
		
		public function set contrast(value:Number):void{
			value = Math.max(-1, Math.min(1, value));
			_contrast = value;
		}
		
		/**
		 * Change the brightness of the matrix filter.
		 * In order to it become visible in the game, filter should be applied to the parent art (animation, not spriteArt).
		 */
		public function get brightness():Number{
			return _brightness;
		}
		
		public function set brightness(value:Number):void{
			value = Math.max(-1, Math.min(1, value));
			_brightness = value;
		}
		
		/**
		 * Change the saturation of the matrix filter.
		 * In order to it become visible in the game, filter should be applied to the parent art (animation, not spriteArt).
		 */
		public function get saturation():Number{
			return _saturation;
		}
		
		public function set saturation(value:Number):void{
			value = Math.max(-1, Math.min(1, value));
			_saturation = value;
		}
		
		/**
		 * Change the hue of the matrix filter.
		 * In order to it become visible in the game, filter should be applied to the parent art (animation, not spriteArt).
		 */
		public function get hue():Number{
			return _hue;
		}
		
		public function set hue(value:Number):void{
			value = Math.max(-1, Math.min(1, value));
			
			_contrast = value;
		}
		
		private static function log(message:String, parent:Object = null):void{
			//if (verbose)
				//trace("[Effects]:", "[" + (parent ? parent.name : "") + "]", message);
		}
		
		/**
		 * Change the hue of the matrix filter.
		 * In order to it become visible in the game, filter should be applied to the parent art (animation, not spriteArt).
		 */
		public function get color():int {
			if(mainArt.color)	
				return mainArt.color;
			else
				return 0xffffff;
		}
		
		public function set color(value:int):void {
			if(mainArt && mainArt.color)	
				mainArt.color = value;
		}
		
		public function get mainArt():Object {
			if (!_mainArt) {
				if(parent.view.content as GameArtContainer)
					_mainArt = (parent.view.content as GameArtContainer).mainChild;
				else if (parent.view.content as Image)
					_mainArt = (parent.view.content as Image);
			}
			return _mainArt;
		}
		
		private var numOfColorsApplied:int = 0;
		private var numOfMatrixessApplied:int = 0;
		
		private var _disposed:Boolean = false;
		public function dispose():void {
			if (_disposed)
				return;
			
			parent = null;
			activatedMatrixes.length = 0;
			matixFilter.dispose();
			matixFilter = null;
			tweens = null;
			activatedStatusColors = null;
			numOfColorsApplied = 0;
			spriteProperty = null;
			FILTRED_OBJECTS.length = 0;
			TweenMax.killTweensOf(applyFilter);
			//TweenMax.killTweensOf(applyColor);
			TweenMax.killTweensOf(this);
			for each(var statusEffect:AnimationPack in statusEffectsArts) {
				if(!statusEffect.disposed)
					statusEffect.dispose();
				TweenMax.killTweensOf(statusEffect);
				statusEffect = null;
			}	
			statusEffectsArts = null;	
			_disposed = true;
			//trace("OBJECTEFFECT: Disposed ");
		}
		
	}
}