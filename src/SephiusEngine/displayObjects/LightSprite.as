package SephiusEngine.displayObjects 
{
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.levelManager.LevelArea;
	import SephiusEngine.displayObjects.GameArt;

	import com.greensock.TweenMax;

	import flash.geom.Point;
	import flash.geom.Rectangle;

	import starling.display.BlendMode;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.extensions.brinkbit.fullscreenscreenextension.FullScreenExtension;
	import starling.extensions.lighting.lights.PointLight;
	import starling.textures.Texture;
	
	/**
	 * A image with a light object together.
	 * It automatcly see if it is on screen and if so add it´s light to a LightLayer effect.
	 * @author Fernando Rabello	
	 */
	public class LightSprite extends Image {
		private static var zeroPoint:Point = new Point();
		private static var absolutePosition:Point = new Point();
		
		/** The light object used in render */
		public var light:PointLight;
		
		public var addedToRender:Boolean = false;
		public var addedToState:Boolean = false;
		public var onScreen:Boolean = false;
		
		/** Light radius is proportional to the camera zoom and sprite scalle, so there is need this property to allow user to set original radius */
		public var radius:uint = 100;
		public var brightness:Number = 1;
		
		private var gameArt:GameArt;
		private var lightRect:Rectangle;
		
		private var delayedDisabled:TweenMax;
		private var brightnessFader:TweenMax;
		
		private var fadeTotalTime:Number = 2;
		private var fadeTime:Number = 0;
		
		private var fadedBrightness:Number = 1;
		public var disableWithFade:Boolean;
		
		public var _disposeWithFade:Boolean;
		public function get disposeWithFade():Boolean { return _disposeWithFade; }
		public function set disposeWithFade(value:Boolean):void {
			disableWithFade = true;
			fadeOut = true;
		}
		
		public function LightSprite(texture:Texture, area:LevelArea, radius:uint = 100, color:uint = 0xfffffff, brightness:Number = 1, shouldFade:Boolean = true){
			super(texture);
			light = new PointLight(this.x, this.y, radius, color, brightness);	
			this.radius = radius;
			this.brightness = brightness;
			this.blendMode = BlendMode.SCREEN;
			
			if(area){
				area.lights.push(this);
				trace('Light added to area: ',  area.globalId, ' light count: ', area.lights.length);
			}
			else{
				//trace('Light added to null AREA!!!!: ');
			}
			
			lightRect = new Rectangle(0, 0, radius * 10, radius * 10);
			
			if (color <= 0 || isNaN(color))
				throw Error("Color given for this light is invalid, should be a int and greater than 0");
			
			if (shouldFade){
				fadeIn = true;
				fadeTime = fadeTotalTime;
			}
		}

		private var viewScale:Number = 1;
		public function updateLight(timePassed:Number):void {
			if (!this.parent)
				return;
			
			if(fadeOut) {
				if (fadeTime > 0){
					fadeTime -= timePassed;
					fadeTime = fadeTime < 0 ? 0 : fadeTime;
				}
				else {
					fadeOut = false;
					fadedBrightness = 0;
				}
				
			}
			else if(fadeIn) {
				if (fadeTime < fadeTotalTime){
					fadeTime += timePassed;
					fadeTime = fadeTime > fadeTotalTime ? fadeTotalTime : fadeTime;
				}
				else {
					fadeIn = false;
					fadedBrightness = 1;
				}
			}
			
			fadedBrightness = fadeTime / fadeTotalTime;
			
			if(addedToState) {
				//Try to find the GameArt witch is needed to see light transformations
				var parent:DisplayObjectContainer = this.parent;
				while (!gameArt && parent){ 
					gameArt = parent as GameArt;
					parent = parent.parent;
				}
				
				zeroPoint.x = pivotX;
				zeroPoint.y = pivotY;
				localToGlobal(zeroPoint, absolutePosition);
				
				if (!gameArt)
					return;

				viewScale = gameArt.viewParalaxContainer ? gameArt.viewParalaxContainer.scaleX : viewScale;

				light.x = absolutePosition.x + FullScreenExtension.screenLeft;
				light.y = absolutePosition.y + FullScreenExtension.screenTop;
				light.radius = Math.abs(radius * viewScale * GameEngine.instance.state.view.camera.realZoom);
				light.brightness = brightness * fadedBrightness;
				
				lightRect.width = lightRect.height = light.radius * 2;
				lightRect.x = light.x - (lightRect.width * .5);
				lightRect.y = light.y - (lightRect.height * .5);
				
				onScreen = GameEngine.instance.outScreenRec.intersects(lightRect);
				
				if (this.visible && !addedToRender && onScreen){
					GameEngine.instance.state.globalEffects.lightLayer.addLight(light);
					addedToRender = true;
				}
				else if((!this.visible && addedToRender) || ((!onScreen) && addedToRender)){
					GameEngine.instance.state.globalEffects.lightLayer.removeLight(light);
					addedToRender = false;
				}
			}
			else {
				light.radius = Math.abs(radius * viewScale * GameEngine.instance.state.view.camera.realZoom);
				light.brightness = brightness * fadedBrightness;
			}
			
			if (fadedBrightness <= 0) {
				if (disableWithFade && _enabled)
					enabled = false;
				if (disposeWithFade && !disposed)
					dispose();
			}
		}
		
		private var disposed:Boolean;
		override public function dispose():void {
			if (disposed)
				throw Error("light alrady disposed");
			disposed = true;
			enabled = false;
			light = null;
			gameArt = null;
			addedToRender = false;
			super.dispose();
		}
		
		public function get enabled():Boolean { return (!this.parent) ? false : _enabled;}
		public function set enabled(value:Boolean):void {
			if (value && !this.parent) {
				trace("Can´t enable this lightSprite. It has no display object parent!")
				_enabled = false;
				return;
			}
			
			if (value == _enabled)
				return;
			
			_enabled = value;
			//trace("Light " + name + " " + (_enabled ? "enabled" : "disabled"));
			
			if (!value) {
				if(GameEngine.instance.state.globalEffects.lightObjects.indexOf(this) > -1)
					GameEngine.instance.state.globalEffects.lightObjects.splice(GameEngine.instance.state.globalEffects.lightObjects.indexOf(this), 1);
				if (addedToRender) {
					if (GameEngine.instance.state.globalEffects.lightLayer)
						GameEngine.instance.state.globalEffects.lightLayer.removeLight(light);
					addedToRender = false;
				}
				visible = false;
			}
			else {
				GameEngine.instance.state.globalEffects.lightObjects.push(this);
				visible = true;
			}
		}
		private var _enabled:Boolean = false;
		
		public function get fadeIn():Boolean { return _fadeIn; }
		public function set fadeIn(value:Boolean):void {
			_fadeIn = value;
			//fadeTime = 0;
		}
		private var _fadeIn:Boolean = false;
		
		public function get fadeOut():Boolean { return _fadeOut; }
		public function set fadeOut(value:Boolean):void {
			_fadeOut = value;
			//fadeTime = fadeTotalTime;
		}
		private var _fadeOut:Boolean = false;
		
	}
}