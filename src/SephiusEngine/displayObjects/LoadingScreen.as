package SephiusEngine.displayObjects {
	import SephiusEngine.assetManagers.ExtendedAssetManager;
	import SephiusEngine.core.GameAssets;
	import SephiusEngine.core.GameState;
	import SephiusEngine.math.MathUtils;

	import com.greensock.TweenMax;

	import flash.filesystem.File;

	import org.osflash.signals.Signal;

	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.extensions.brinkbit.fullscreenscreenextension.FullScreenExtension;
	import starling.text.TextField;
	import SephiusEngine.Languages.LanguageManager;
	
	/**
	 * Screen witch will appear every time a state is loading 
	 * @author Fernando Rabello
	 */
	public class LoadingScreen extends Sprite {
		private var backgound:Image;
		private var loadingIcon:MovieClip;
		private var loadingText:TextField;
		private var assets:ExtendedAssetManager;
		private var currentBG:uint = 0;
		public var onLoaded:Signal;
		public var loaded:Boolean = false;
		public var onLoadScreenHided:Signal;
		private var shadow:Image;
		public var numberOfBGs:int = 17;
		
		private var loadingScreenOnScreen:Boolean;
		
		public function LoadingScreen() {
			super();
			assets = new ExtendedAssetManager ((GameAssets.texturePack == "high" ? 1 : GameAssets.texturePack == "medium" ? 0.6 : GameAssets.texturePack == "low" ? 0.41 : 1), true);
			onLoaded = new Signal();
			onLoadScreenHided = new Signal();
			
			loadingText = new TextField(1000, 50, "LOADING...", "ChristianaWhite", 25, 0xffffff, true);
			loadingText.text = LanguageManager.getSimpleLang("StartElements", "LOADING").name  + "...";
			loadingText.alignPivot();
			loadingText.x = FullScreenExtension.stageWidth * .5;
			loadingText.y = FullScreenExtension.stageHeight * .5;
			loadingText.alpha = 0;
			
			this.alpha = 0;
			
			addChild(loadingText);
			
			unsortBGs();
		}
		
		private static var sortedNumbers:Array;
		private static var unsortedNumbers:Array;
		private function unsortBGs():void{
			sortedNumbers = [];
			unsortedNumbers = [];
			imgIndex = 0;
			
			for(var i:int = 0; i < numberOfBGs; i++){
				sortedNumbers.push(i);
			}			
			
			var rindex:int;
			while (sortedNumbers.length > 0){
				rindex = MathUtils.randomInt(0, sortedNumbers.length - 1);
				unsortedNumbers.push(sortedNumbers[rindex]);
				sortedNumbers.removeAt(rindex);
			}			
		}
		
		public var onScreen:Boolean;
		
		private static var imgIndex:int = 0;
		public function show():void { 
			loadingScreenOnScreen = true;
			//<dirty code>
			if (assets == null){
				trace("Assets is null");
				assets = new ExtendedAssetManager(1, true);
			}
			onScreen = true;
			currentBG = unsortedNumbers[imgIndex++];
			
			if(imgIndex == unsortedNumbers.length)
				unsortBGs();
			
			var loadDirectory:File = GameAssets.texturesPath.resolvePath("loadingScreen");
			var LoadingATFDirectory:String = loadDirectory.resolvePath("Loading.atf").url;
			var LoadingXMLDirectory:String = loadDirectory.resolvePath("Loading.xml").url;
			var Loading_ShadowDirectory:String = loadDirectory.resolvePath("Loading_Shadow.png").url;
			var Loading_BGDirectory:String = loadDirectory.resolvePath("Loading_BG" + currentBG + ".jpg").url;

			if(!loaded){
				assets.enqueueAsGroup("LoadingScreen", [LoadingATFDirectory, LoadingXMLDirectory]);
				assets.enqueueAsGroup("LoadingScreen", [Loading_ShadowDirectory]);
				assets.enqueueAsGroup("LoadingScreen", [Loading_BGDirectory]);
				assets.loadQueueGroup(onArt, "LoadingScreen");
			}
			
			alpha = 0;
			loadingText.alpha = 0;
			
			//TweenMax.to(loadingText, 1, { alpha:1 } );
		}
		
		public function hideLoadingScreen(state:GameState):void { 
			onScreen = false;
			//TweenMax.to(this, 1, { alpha:0, delay:0 } );
			//TweenMax.delayedCall(1, disposeLoadingAssets);
			//state.onReady.remove(hideLoadingScreen);
		}
		
		private var fadeSpeed:Number = (1 / (60 * 2));
		public function update():void{
			if (onScreen && alpha < 1){
				alpha += fadeSpeed;
				loadingText.alpha = alpha;
			}
			else if (!onScreen && alpha > 0){
				alpha -= fadeSpeed;
				loadingText.alpha = alpha;
			}
			if (loaded && !onScreen && alpha <= 0){
				disposeLoadingAssets();
				alpha = 0;
				loadingText.alpha = 0;
			}
		}
		
		protected function onArt(ratio:Number, itemName:String = "Null"):void {
			if (ratio == 1) {
				var scaleRation:Number;
				
				shadow = new Image(assets.getTexture("Loading_Shadow"));
				shadow.alignPivot();
				shadow.scaleX = shadow.scaleY = 10;
				shadow.x = FullScreenExtension.stageWidth * .5;
				shadow.y = FullScreenExtension.stageHeight * .5 - 60;
				TweenMax.to(shadow, 1, { alpha:1 } );
				
				backgound = new Image(assets.getTexture("Loading_BG" + currentBG));
				if (FullScreenExtension.screenWidth > backgound.width)
					scaleRation = FullScreenExtension.screenWidth / backgound.width;
				else
					scaleRation = FullScreenExtension.screenHeight / backgound.height;
				
				backgound.alignPivot();
				backgound.scaleX = backgound.scaleY = scaleRation;
				backgound.x = FullScreenExtension.stageWidth * .5;
				backgound.y = FullScreenExtension.stageHeight * .5;
				
				loadingIcon = new MovieClip(assets.getTextures("Loading_Ico"), 60);
				
				loadingIcon.alignPivot();
				loadingIcon.scaleX = loadingIcon.scaleY = 2;
				loadingIcon.blendMode = BlendMode.SCREEN;
				loadingIcon.x = FullScreenExtension.stageWidth * .5;
				loadingIcon.y = FullScreenExtension.stageHeight * .5 - 60;
				
				Starling.current.juggler.add(loadingIcon);
				loadingIcon.loop = true;
				loadingIcon.play();
			}
			
			if (backgound && loadingIcon) {
				addChild(shadow);
				addChild(loadingIcon);
				addChild(loadingText);
				addChildAt(backgound, 0);
				alpha = 0;
				TweenMax.to(this, 1, { alpha:1, onComplete:dispachLoaded } );
				loaded = true;
			}
		}
		
		private function disposeLoadingAssets():void {
			loadingScreenOnScreen = false;
			loaded = false;
			Starling.current.juggler.remove(loadingIcon);
			removeChild(backgound, true);
			removeChild(shadow, true);
			removeChild(loadingIcon, true);
			backgound = null;
			shadow = null;
			loadingIcon = null;
			onLoadScreenHided.dispatch();
			onLoadScreenHided.removeAll();
			//onLoadScreenHided = null;
			
			if(assets){
				assets.removeGroup("LoadingScreen");
				assets.dispose();
				assets = null;
			}
			loadingText.alpha = 0;
			removeFromParent();
		}
		
		private function dispachLoaded():void {
			onLoaded.dispatch();
			loaded = true;
		}
	}
}