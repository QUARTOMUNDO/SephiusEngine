package SephiusEngine.userInterfaces.components.contents.subContents {
	import SephiusEngine.Languages.LoreLanguageElement;
	import SephiusEngine.core.GameAssets;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.gameplay.inventory.objects.Memo;
	import SephiusEngine.userInterfaces.components.contents.SubContentComponent;

	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	import tLotDClassic.GameData.Properties.MemoProperties;
	import SephiusEngine.Languages.LanguageManager;
	
	/**
	 *  Content for Memo screen on game menu
	 * @author ...
	 */
	public class MemoSubContentComponent extends SubContentComponent 
	{
		private var memo:Memo;
		
		private var	memoImage:Image = new Image(GameEngine.assets.getTexture("Hud_LightScreenSplash"));
		
		private var memoUsageTitle:TextField = new TextField(50, 50, "USAGE", "ChristianaBlack", 26, 0xffffff, true);
		private var memoUsageText:TextField = new TextField(250, 200, "Last words left by Kanpheyro...?! The hatred and sorrow can turn us into terrible things...", "ChristianaBlack", 20, 0xffffff, true);
		private var usageGroup:Sprite = new Sprite();
		
		private var divisor:Image = new Image(GameEngine.assets.getTexture("Menu_LightDivisor"));
		
		private var memoSansicoNameTitle:TextField = new TextField(50, 50, "Halugard", "SansicoLightStone", 27, 0xffffff, true);
		private var memoNameTitle:TextField = new TextField(50, 50, "Halugarde", "ChristianaBlack", 32, 0xffffff, true);
		
		private var memoDescriptionText:TextField = new TextField(430, 600, "Last words left by Kanpheyro...?! The hatred and sorrow can turn us into terrible things...Last words left by Kanpheyro...?! The hatred and sorrow can turn us into terrible things...Last words left by Kanpheyro...?! The hatred and sorrow can turn us into terrible things...", "ChristianaBlack", 20, 0xffffff, true);
		private var descriptionGroup:Sprite =  new Sprite();
		
		private var currentProperty:MemoProperties;
		
		public function MemoSubContentComponent() {
			super();
			this.touchable = false;
			
			memoImage.width = 512;
			memoImage.height = 512;
			memoImage.alignPivot();
			//memoImage.x = memoImage.width * .5 - 15;
			memoImage.y = 40;
			
			//Usage Group
			memoUsageTitle.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			memoUsageTitle.alignPivot(HAlign.CENTER, VAlign.TOP);
			memoUsageTitle.x = memoImage.x;
			
			memoUsageText.alignPivot(HAlign.CENTER, VAlign.TOP);
			memoUsageText.hAlign = HAlign.CENTER;
			memoUsageText.vAlign = VAlign.TOP;
			memoUsageText.x = memoUsageTitle.x
			memoUsageText.y = memoUsageTitle.y + memoUsageTitle.height * .5 + 20;
			
			usageGroup.addChild(memoUsageTitle);
			usageGroup.addChild(memoUsageText);
			usageGroup.y = memoImage.y + memoImage.height * .5;
			usageGroup.x = memoImage.x;
			
			//Description Group
			memoSansicoNameTitle.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			memoSansicoNameTitle.alignPivot(HAlign.LEFT, VAlign.TOP);
			memoSansicoNameTitle.y = memoImage.y - memoImage.height * .5 + 30;
			memoSansicoNameTitle.visible = false;
			
			memoNameTitle.autoSize = TextFieldAutoSize.HORIZONTAL;
			memoNameTitle.alignPivot(HAlign.LEFT, VAlign.CENTER);
			memoNameTitle.y = memoSansicoNameTitle.y + memoSansicoNameTitle.height + 30;
			
			memoDescriptionText.alignPivot(HAlign.LEFT, VAlign.TOP);
			memoDescriptionText.hAlign = HAlign.LEFT;
			memoDescriptionText.vAlign = VAlign.TOP;
			memoDescriptionText.x = 0
			memoDescriptionText.y = memoNameTitle.y + memoNameTitle.height * .5 + 15;
			memoDescriptionText.autoSize = TextFieldAutoSize.VERTICAL;

			descriptionGroup.addChild(memoSansicoNameTitle);
			descriptionGroup.addChild(memoNameTitle);
			descriptionGroup.addChild(memoDescriptionText);
			
			descriptionGroup.x = memoImage.x + memoImage.width * .5 - 85;

			addChild(memoImage);
			addChild(usageGroup);
			addChild(descriptionGroup);
		}
		
		override public function setContent(content:Object):void {
			super.setContent(content);
			
			if(assets.rawAssetsGroups["info"]){
				assets.removeGroup("info");
				assets.purge();
			}
			
			memo = content as Memo;
			currentProperty = memo.property as MemoProperties;
			
			//assets.verbose = true;
			
			assets.enqueueAsGroup("info", [GameAssets.texturesPath.resolvePath("interfaces").resolvePath("memos").resolvePath(currentProperty.image + ".atf").url	]);
			assets.loadQueueGroup(onLoadArt, "info");
		}
		
		override public function updateData():void {
			memoImage.texture = assets.getTexture(currentProperty.image);
			
			memoUsageTitle.text = LanguageManager.getSimpleLang("GameMenuElements", "USAGE").name;

			var memoData:LoreLanguageElement = LanguageManager.getLoreLang("MemosData", currentProperty.varName);

			memoUsageText.text = memoData.usage;
			memoSansicoNameTitle.text = currentProperty.name;
			memoNameTitle.text = memoData.name;
			memoDescriptionText.text = memoData.description[0].replace(/\n/g, '\n   ');
			
			//trace(usageGroup.x, usageGroup.y, usageGroup.alpha, usageGroup.visible, usageGroup.parent);
		}
		
		
		/** Change Top Menu Component Skin. Propagates trought menu itens changing then skin also */
		override public function changeSkin(skin:String):void {
			if (skin == "Dark") {
				memoSansicoNameTitle.fontName = "SansicoDarkWhite";
				//memoSansicoNameTitle.color = 0x0000000;
				memoSansicoNameTitle.fontSize = 30;
				memoUsageTitle.fontName = "ChristianaWhite";
				memoUsageText.fontName = "ChristianaWhite";
				memoNameTitle.fontName = "ChristianaWhite";
				memoDescriptionText.fontName = "ChristianaWhite";
			}
			else if (skin == "Light") {
				memoSansicoNameTitle.fontName = "Sansico" + skin + "Stone";
				memoSansicoNameTitle.fontSize = 27;
				memoSansicoNameTitle.color = 0xffffff;
				memoUsageTitle.fontName = "ChristianaBlack";
				memoUsageText.fontName = "ChristianaBlack";
				memoNameTitle.fontName = "ChristianaBlack";
				memoDescriptionText.fontName = "ChristianaBlack";
			}
		}
	}
}