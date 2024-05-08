package SephiusEngine.userInterfaces.components {
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.levelManager.GameOptions;
	import SephiusEngine.userInterfaces.UserInterfaces;

	import com.greensock.TweenMax;

	import flash.display.BitmapData;

	import starling.core.Starling;
	import starling.display.Image;
	import starling.extensions.brinkbit.fullscreenscreenextension.FullScreenExtension;
	import starling.filters.FullScreenBlurFilter;
	import starling.textures.RenderTexture;
	import starling.textures.Texture;
	
	/**
	 * Blur Effect in menus backgrounds
	 * @author Fernando Rabello
	 */
	public class BackgroundBlur extends Image {
		private var backgroundBitmapData:BitmapData;
		private var backgroundFilter:FullScreenBlurFilter;
		private var uiFilter:FullScreenBlurFilter;
		private var renderToTexture:RenderTexture;
		
		/** "RenderTexture" or "BitmapData" or "StageBlur" */
		private var effectTechnique:String = "";
		
		public function BackgroundBlur(effectTechnique:String) {
			this.effectTechnique = effectTechnique;
			
			if(effectTechnique == "BitmapData"){
				backgroundBitmapData = new BitmapData(Starling.current.backBufferWidth, Starling.current.backBufferHeight, false);
				var screenshotTexture:Texture = Texture.fromBitmapData(FullScreenExtension.stage.drawToBitmapData(backgroundBitmapData));
			}
			else
				renderToTexture = new RenderTexture(1920, 1080, true, 1);
			
			super(effectTechnique == "RenderTexture" ? renderToTexture : effectTechnique == "BitmapData" ? screenshotTexture : Texture.empty(10, 10));
			
			alignPivot();
			y = GameEngine.instance.stage.stageHeight * .05;
			touchable = false;
			name = "ScreenBlur";
			
			if(effectTechnique == "BitmapData")
				backgroundBitmapData.dispose();
		}
		
		public function renderBackgroundBlur():void {
			if (GameOptions.DISABLE_BLUR_EFFECTS)
				return;
			
			if (!backgroundFilter)
				backgroundFilter = new FullScreenBlurFilter(.5, .5, .3);
			
			if (effectTechnique == "RenderTexture") {
				//LocalEffects.pauseFilters(true);
				renderToTexture.draw(FullScreenExtension.stage, null, 1);
				//LocalEffects.pauseFilters(false);
				filter = backgroundFilter;
			}
			else if (effectTechnique == "BitmapData") {
				backgroundBitmapData = new BitmapData(Starling.current.backBufferWidth, Starling.current.backBufferHeight, false);
				texture.dispose();
				texture = Texture.fromBitmapData(FullScreenExtension.stage.drawToBitmapData(backgroundBitmapData));
				backgroundBitmapData.dispose();
				
				backgroundFilter.resolution = 1;
				backgroundFilter.blurX = 3;
				backgroundFilter.blurY = 3;
				
				filter = backgroundFilter;
			}
			else if (effectTechnique == "StageBlur") {
				backgroundFilter.blurX = 0.5;
				backgroundFilter.blurY = 0.5;
				backgroundFilter.resolution = .5;
				
				if(GameEngine.instance.state.view)
					GameEngine.instance.state.view.viewRoot.filter = backgroundFilter;
				
				backgroundFilter.clearCache();
			}
		}
		
		public function animateBackgroundBlurIn():void {
			//LocalEffects.pauseFilters(true);
			backgroundFilter.blurX = 0;
			backgroundFilter.blurY = 0;
			//TweenMax.to(this, 1, { scaleX:(1.1), scaleY:(1.1) } );
			backgroundFilter.clearCache();
			
			TweenMax.killTweensOf(backgroundFilter);
			TweenMax.killDelayedCallsTo(removeBGFilter);
			
			if (effectTechnique == "StageBlur" || effectTechnique == "RenderTexture") {
				TweenMax.to(backgroundFilter, 1, { blurX:3, blurY:3 } );
				TweenMax.to(backgroundFilter, 1, { onComplete:backgroundFilter.cache } );
			}
			if (effectTechnique == "BitmapData" ) {
				TweenMax.to(backgroundFilter, 2, { blurX:20, blurY:20 } );
				TweenMax.to(backgroundFilter, 2, { onComplete:backgroundFilter.cache } );
			}
		}
		
		public function animateBackgroundBlurOut():void {
			//LocalEffects.pauseFilters(false);
			//TweenMax.to(this, 1, { scaleX:(1), scaleY:(1) } );
			if (effectTechnique == "StageBlur") {
				backgroundFilter.clearCache();
				TweenMax.to(backgroundFilter, 1, { blurX:0, blurY:0 } );
				TweenMax.delayedCall(1, removeBGFilter);
			}
		}
		
		public function rendeUIBlur():void {
			if (!uiFilter)
				uiFilter = new FullScreenBlurFilter(.5, .5, .5);
			
			uiFilter.blurX = 0.0;
			uiFilter.blurY = 0.0;
			uiFilter.resolution = 1;
			
			if (effectTechnique == "StageBlur") {
				if(UserInterfaces.instance.pauseMenu)
					UserInterfaces.instance.pauseMenu.filter = uiFilter;
				
				if (UserInterfaces.instance.titleMenu)
					UserInterfaces.instance.titleMenu.filter = uiFilter;
			}
		}
		
		public function animateUIBlurIn():void {
			//LocalEffects.pauseFilters(true);
			uiFilter.blurX = 0;
			uiFilter.blurY = 0;
			//TweenMax.to(this, 1, { scaleX:(1.1), scaleY:(1.1) } );
			uiFilter.clearCache();
			
			TweenMax.killTweensOf(uiFilter);
			TweenMax.killDelayedCallsTo(removeUIFilter2);
			
			if (effectTechnique == "StageBlur") {
				TweenMax.to(uiFilter, 1, { blurX:25, blurY:25 } );
				TweenMax.to(uiFilter, 1, { onComplete:uiFilter.cache } );
			}
		}
		
		public function animateUIBlurOut():void {
			//LocalEffects.pauseFilters(false);
			//TweenMax.to(this, 1, { scaleX:(1), scaleY:(1) } );
			if (effectTechnique == "StageBlur") {
				uiFilter.clearCache();
				TweenMax.to(uiFilter, 1, { blurX:0, blurY:0 } );
				TweenMax.delayedCall(1, removeUIFilter2);
			}
		}
		
		public function removeUIFilter2():void {
			if(UserInterfaces.instance.pauseMenu)
				UserInterfaces.instance.pauseMenu.filter = null;
			if (UserInterfaces.instance.titleMenu)
				UserInterfaces.instance.titleMenu.filter = null;
		}
		
		public function removeBGFilter():void {
			if(GameEngine.instance.state.view)
				GameEngine.instance.state.view.viewRoot.filter = null;
		}
		
		override public function dispose():void {
			super.dispose();
			if(backgroundBitmapData){
				backgroundBitmapData.dispose();
				backgroundBitmapData = null;
			}
			if(backgroundFilter){
				backgroundFilter.dispose();
				backgroundFilter = null;
			}
			if(renderToTexture){
				renderToTexture.dispose();
				renderToTexture = null;
			}
			if(uiFilter){
				uiFilter.dispose();
				uiFilter = null;
			}
			if (renderToTexture) {
				renderToTexture.dispose();
				renderToTexture = null;
			}
			
		}
	}
}