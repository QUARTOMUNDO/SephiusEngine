package SephiusEngine.levelObjects.effects {
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.displayObjects.AnimationPack;
	import SephiusEngine.displayObjects.configs.AssetsConfigs;
	import SephiusEngine.levelObjects.interfaces.ISpriteSoundEmitter;
	import SephiusEngine.levelObjects.interfaces.ISpriteView;
	import SephiusEngine.math.MathUtils;
	import SephiusEngine.sounds.system.components.physics.SpriteSoundComponent;
	import SephiusEngine.utils.pools.SplashPool;

	import com.greensock.TweenMax;

	import starling.display.BlendMode;

	import tLotDClassic.attributes.AttributesConstants;
	
	/**
	 * This object is a splash animation that happen when a character takes damage
	 * This splash created from a Animation Sequence
	 * @author Fernando Rabello
	 */
	public class SplashAnimation extends SpecialSprite implements ISpriteSoundEmitter{
		private var splashName:String;
		private var outcome:String;
		
		public static const splashNames:Vector.<String> = new Vector.<String>();
		
		public static var currentSplash:SplashAnimation;
		/**
		 * Constructor
		 * @param	objectName The name of the object
		 * @param	splashName The name of the splash that must be used
		 * @param	splashAnimation 
		 * @param	parent The object that the splash will be applied
		 * @param	damageType If the damage is classified as "strong", "normal", "powerful", "critical", "absorption"
		 * @param	params Information used by Main, location, name, art, among other
		 */
		public function SplashAnimation(splashName:String, params:Object = null) {
			group = AssetsConfigs.EFFECTS2_ASSETS_GROUP;
			this.name = splashName + MathUtils.randomInt(1, 100000);
			super(this.name, params);
			view.updateState = false;
			compAbove = true;
			
		}
		
		override public function loadInitAndAdd():void {
			spriteArt = new AnimationPack("Damage", null);
			view.content = spriteArt;
		}
		
		public static function showSplash (parent:Object, splashName:String, params:Object = null, outcome:String="normal", useSound:Boolean = false):void {
			currentSplash = SplashPool.getObject();
			currentSplash.init(parent, splashName, params, outcome, useSound);
 			GameEngine.instance.state.add(currentSplash);
			//if(currentSplash.remove)
				//trace("Adding Sprite " + splashName + "-" + currentSplash.name + " is marked to be removed, but it should not!");
		}
		
		public function init(parent:Object, splashName:String, params:Object = null, outcome:String="normal", useSound:Boolean = false):void {
			this.outcome = outcome;
			this.useSound = useSound;
			this.blendMode = defineBlendMode(splashName);
			this.alpha = 1;
			this.updateGroup = true;
			this.scaleX = 1;
			this.scaleX = 1;
			
			if (!params || !params.scaleOffsetX) {
				scaleOffsetX = 1;
			}
			else{
				scaleOffsetX = params.scaleOffsetX;
			}
			
			if(!params || !params.scaleOffsetY)
				scaleOffsetY = 1;
			else{
				scaleOffsetY = params.scaleOffsetY;
			}
			
			this.offsetX = this.offsetY = this.rotationOffset = 0;
			this.color = 0xffffff;
			this.displacementX = this.displacementY = 0;
			this.rotation = 0;
			this.parent = parent as ISpriteView;
			
			this.splashName = splashName;
			
			x = 0;
			y = 0;
			
			for (var property:String in params) {
				this[property] = params[property];
			}
			
			if (parent && (!params || params.linkPosition)) {
				x = parent.x;
				y = parent.y;
			}
			
			(spriteArt as AnimationPack).changeAnimation(splashName);
			(spriteArt as AnimationPack).currentFrame = 0;
			(spriteArt as AnimationPack).color = this._color;
			
			x += displacementX;
			y += displacementY;
			
			//spriteArt.alignPivot();
			animation = splashName;
			
			updateCallEnabled = true;
			
			if (outcome == "critical" || outcome == "powerfull"){
				scaleOffsetX *= 2.5;
				scaleOffsetY *= 2.5;
			}
			else if (outcome == "weak"){
				scaleOffsetX *= .5;
				scaleOffsetY *= .5;
				alpha = 1;
			}
			else if (outcome == "essence"){
				scaleOffsetX *= 1;
				scaleOffsetY *= 1;
				alpha = 0.2;
			}
			else{
				scaleOffsetX *= 2;
				scaleOffsetY *= 2;
				alpha = 1;
			}
			
			view.updateStateOnce = true;
			calledToRemove = true;
			
			TweenMax.to(this, 0, { onComplete:removeFromState, delay:(((spriteArt as AnimationPack).totalTime) + (useSound ? 2 : 0)) } );
			/*
			if(useSound && splashName != "EssenceEthos" && splashName != "EssenceLight" && splashName != "EssenceDark" && splashName != "EssenceMestizo"){
				trace("------------------" + splashName + "-" + this.name + "-------------------");
				trace("splash:" + (spriteArt as AnimationPack).currentAnimation + " / currentFrame:" + (spriteArt as AnimationPack).currentFrame + " / x:" + x.toFixed() + " / y:" + y.toFixed() + " / group:" + group  + " / parallax:" + parallax + " / alpha:" + alpha + " / Sound:" + useSound);
				trace("splash volume:" + _soundComponent.volume + " /camVec: " + _soundComponent.camVec + " / " + updateCallEnabled);
				trace("splash spriteArtX:" + spriteArt.x + " / spriteArtY:" + spriteArt.y + " / scaleX:" + spriteArt.scaleX + " / spriteArtY:" + spriteArt.scaleY);
				trace("splash scaleX:" + scaleX + " / scaleY:" + scaleY + " / scaleOffsetX:" + scaleOffsetX + " / scaleOffsetY:" + scaleOffsetY);
				trace("splash view.x:" + view.x + " / view.y:" + view.y + " / view.scaleX:" + view.scaleX + " / view.scaleY:" + view.scaleY);
				trace("---------------------------------------------------");
			}*/
			//trace("splash viewparentX:" + view.parent.x + " / parent:" + view.parent.y);
			
			//trace(_soundComponent.updatePosition());
		}
		
		public function removeFromState():void {
			if (remove)
				trace("Removing splash " + splashName + "-" + this.name + " is already marked to be removed, but it should not!");
			
			remove = true;
			
			if (soundAdded)
				removeSound();
			
			//if(useSound && splashName != "EssenceEthos" && splashName != "EssenceLight" && splashName != "EssenceDark" && splashName != "EssenceMestizo")
				//trace(splashName + "-" + this.name + " removed" + " / " + updateCallEnabled);
			
			calledToRemove = false;
		}
		private var calledToRemove:Boolean;
		/**
         * Update function
		 * @param	timeDelta This is a ratio explaining the amount of time that passed in relation to the amount of time that
		 * was supposed to pass. Multiply your stuff by this value to keep your speeds consistent no matter the frame rate. 		 
		 * */
		public override function update(timeDelta:Number):void {
			/*
			if (parent) {
				if (linkPosition) {
					x = _parent.x + displacementX;
					y = _parent.y + displacementY;
				}
			}*/
			//trace("splash: " + x + " / " + y + " / " + (spriteArt as SpriteSheetAnimation).alpha);
			
			//if(useSound && splashName != "EssenceEthos" && splashName != "EssenceLight" && splashName != "EssenceDark" && splashName != "EssenceMestizo")
				//trace(splashName + "-" + this.name + " volume:" + _soundComponent.volume + " /camVec: " + _soundComponent.camVec + " / " + updateCallEnabled);
			
			if ((spriteArt as AnimationPack).isComplete)
				(spriteArt as AnimationPack).changeAnimation("");
		}
		
		private static function defineBlendMode(splashName:String):String {
			switch(splashName) {
				case "Eatrh" :
				case "Darkness" :
				case "Corruption" :	
				case "RockImpactNormal" :	
				case "RockImpactStrong" :	
				case "RockImpactWeak" :		
				case "WaterImpactStrong" :		
				case "WaterImpactMedium" :		
				case "WaterImpactWeak" :
				case "LargeEarthImpact" :		
				case "ViolentEarthImpact" :		
				case "MultipleEarthImpact" :		
				case "EarthImpact" :		
				case "EarthImpact" :		
				case "RockSplashBig" :
				case "RockAndGemSplashBig" :
				case "UrnSplash" :
				case "RockSplash" :
				case "LightCrystal" :
				case "DarkCrystal" :
				case "MestizoCrystal" :
				
				//case "CrautaryusDark" :
					return BlendMode.NORMAL;
				break;
				default:
					return BlendMode.SCREEN;
				break;
			}
		}
		
		/**
		 * Sets the sound of the splash based on the name of the splash
		 * @param	splashName About that element or type of the splash damage is related
		 */
		private function audioControl(splashName:String):void {
			if (splashName == "CrautaryusLight" || splashName == "CrautaryusDark")
				soundComponent.play("FX_splash_Creature" + MathUtils.randomInt(1, 3), "splash", 1);
			
			else if (splashName == "Armor")
				soundComponent.play("FX_splash_Armor" + MathUtils.randomInt(1, 7), "splash", 1);
			
			else if (splashName == "StrongSephius" || splashName == "WeakSephius" || splashName == "ArmorMixed")
				soundComponent.play("FX_splash_ArmorMixed" + MathUtils.randomInt(1, 4), "splash", 1);
			
			else if (splashName == "Wood")
				soundComponent.play("FX_splash_Wood" + MathUtils.randomInt(1, 4), "splash", 1);
			
			else if (splashName == "DarkEssenceGain" || splashName == "LightEssenceGain" || splashName == "MestizoEssenceGain")
				soundComponent.play("FXSpellSingularBio", "splash", 1);
			
			else if (splashName == "LightCrystal" || splashName == "DarkCrystal" || splashName == "MestizoCrystal")
				soundComponent.play("FX_object_gem_breaking" + MathUtils.randomInt(1, 4), "splash", 1.5);
			
			else if (splashName == "RockAndGemSplashBig")
				soundComponent.play("FX_splash_TombstoneGemBreaking", "splash", 1.5);
			
			else if (splashName == "RockSplashBig")
				soundComponent.play("FX_splash_TombstoneBreaking" + MathUtils.randomInt(1, 2), "splash", 1.5);
			
			else if (splashName == "UrnSplash")
				soundComponent.play("FX_splash_SansicoUrnBreaking", "splash", 1.5);
			
			else if (splashName == "RockSplash" || splashName == "RockSplash" || splashName == "RockSplash")
				soundComponent.play("FX_splash_rockHit" + MathUtils.randomInt(1, 4), "splash", 1.5);
			
			else if (splashName == "EssenceLight" || splashName == "EssenceDark" || splashName == "EssenceMestizo")
				soundComponent.play("FX_object_EssenceDeepGet" + MathUtils.randomInt(1, 5), "splash", .5);
			
			else if (splashName == "EssenceEthos")
				soundComponent.play("FX_object_EssenceEthosGet" + MathUtils.randomInt(1, 6), "splash", .3);
			
			else
				soundComponent.play("FX_splash_" + splashName, "splash", 1);
		}
		
		public static function setSplashNames():void {
			var animationName:String;
			for each (animationName in GameEngine.assets.getSubTexturesNames("Damage")) {
				splashNames.push(animationName);
			}
		}
		
		override public function addView():void {
			super.addView();
		}
		
		override public function removeView():void {
			super.removeView();
			
			SplashPool.returnObject(this);
			
			//if(calledToRemove)
				//if(useSound && splashName != "EssenceEthos" && splashName != "EssenceLight" && splashName != "EssenceDark" && splashName != "EssenceMestizo")
					//trace(splashName + "-" + this.name + " removed to the View" + " / " + updateCallEnabled);
		}
		
		
		
		override public function destroy():void{
			parent = null;
			super.destroy();
		}
		
		public function get soundComponent():SpriteSoundComponent { return _soundComponent; }
		public function set soundComponent(value:SpriteSoundComponent):void {
			_soundComponent = value;
		}
		private var _soundComponent:SpriteSoundComponent;
		
		public function createSound():void {
			_soundComponent = new SpriteSoundComponent(name+"_sound", this);
			_soundComponent.radius = AttributesConstants.soundComponentRadius;
		}
		
		public function destroySound():void {
			if (useSound) {
				if (soundAdded)
					removeSound();
				_soundComponent.destroy();
				_soundComponent = null;
			}
		}
		
		public function addSound():void {
			if(useSound){
				_ge.sound.soundSystem.registerComponent(_soundComponent);
				audioControl(splashName);
				_soundAdded = true;
			}
		}
		
		public function removeSound():void {
			_ge.sound.soundSystem.unregisterComponent(_soundComponent);
			_soundAdded = false;
		}
		
		public function get soundAdded():Boolean { return _soundAdded; }
		private var _soundAdded:Boolean;
		
		public var useSound:Boolean;
	}
}