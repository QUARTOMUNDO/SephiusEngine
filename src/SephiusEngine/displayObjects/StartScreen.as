package SephiusEngine.displayObjects {
	import SephiusEngine.assetManagers.ExtendedAssetManager;
	import SephiusEngine.core.GameAssets;

	import com.greensock.TweenMax;

	import flash.geom.Rectangle;

	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.extensions.brinkbit.fullscreenscreenextension.FullScreenExtension;
	import starling.filters.BlurFilter;
	import starling.text.TextField;
	import SephiusEngine.Languages.LanguageManager;
	
	/**
	 * ...
	 * @author Fernando Rabello
	 */
	public class StartScreen extends Sprite {
		public var logo:Image;
		public var back:Image;
		
		public var warning:TextField = new TextField(700, 300, "", "ChristianaWhite", 13, 0xffffff, true);
		public var warning2:TextField = new TextField(700, 500, "", "ChristianaWhite", 13, 0x000000, true);
		public var warningSprite:Sprite = new Sprite();
		public var warningSprite2:Sprite = new Sprite();
		public var blackBox:Quad = new Quad(20, 20, 0x000000);
		
		private var assets:ExtendedAssetManager;
		private var callback:Function;
		
		public function StartScreen(callback:Function) {
			super();
			alpha = 0;
			assets = new ExtendedAssetManager ( (GameAssets.texturePack == "high" ? 1 : GameAssets.texturePack == "medium" ? 0.6 : GameAssets.texturePack == "low" ? 0.41 : 1), true);
			assets.verbose = false;
			assets.enqueueAsGroup("StartScreen", GameAssets.texturesPath.resolvePath("startScreen"));
			assets.loadQueueGroup(initialize, "StartScreen");
			this.callback = callback;
			
			var equipQuestionLang:String = LanguageManager.getSimpleLang("StartElements", "START_WARNING").name;
			warning.text = equipQuestionLang;
			warning2.text = warning.text;
		}
		
		public function initialize(ratio:Number, groupName:String):void {
			if (ratio < 1)
				return;
			
			var screenScale:Number = 1;
			
			back = new Image(assets.getTexture("StartScreenBack"));
			back.name = "StartScreenBack";
			back.x = FullScreenExtension.screenLeft;
			back.y = FullScreenExtension.screenTop;
			back.width = FullScreenExtension.screenWidth;
			back.height = FullScreenExtension.screenHeight;
			
			logo = new Image(assets.getTexture("StartScreenLogo"));
			logo.name = "StartScreenLogo";
			logo.pivotX = logo.width / 2;
			logo.pivotY = logo.height / 2;
			logo.x = FullScreenExtension.stageWidth / 2;
			logo.y = (FullScreenExtension.stageHeight / 2) - 100;
			logo.height = ((512 * (screenScale / 1.5)) + 170) * .6;
			logo.width = ((1024 * (screenScale / 1.5)) + 340) * .6;

			warning.x = FullScreenExtension.stageWidth / 2;
			warning.y = (FullScreenExtension.stageHeight / 2) + 100;
			warning.alignPivot();
			warning.filter = BlurFilter.createDropShadow(2, 2, 0x000000, 1, 1);
			
			warning2.x = warning.x;
			warning2.y = warning.y;
			warning2.alignPivot();
			warning.filter = BlurFilter.createDropShadow(2, 2, 0x000000, 1, 1);
			
			warningSprite.addChild(warning);
			//warningSprite.clipRect = new Rectangle(warning.bounds.x, warning.bounds.y, warning.bounds.width -353, warning.bounds.height);
			warningSprite2.addChild(warning2);
			warningSprite2.clipRect = new Rectangle(warning2.bounds.x + 347, warning2.bounds.y, warning2.bounds.width, warning2.bounds.height);
			
			blackBox.x = warning2.x - (warning2.width * .5) + 70;
			blackBox.y = warning2.y - 50;
			blackBox.width = warning2.width - 135;
			blackBox.height = 100;
			
			this.addChild(back);
			this.addChild(logo);
			this.addChild(blackBox);
			this.addChild(warningSprite);
			//this.addChild(warningSprite2);
			
			alpha = 0;
			TweenMax.to(this, 1, { alpha:1, onComplete:callback ? callback : null } );
			
		}
		override public function dispose():void {
			assets.removeGroup("StartScreen");
			assets.dispose();
			assets = null;
			
			logo.dispose();
			back.dispose();
			super.dispose();
		}
	}
}