package SephiusEngine.userInterfaces.components.contents.subContents {
	import SephiusEngine.Languages.LanguageManager;
	import SephiusEngine.core.GameAssets;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.gameplay.inventory.objects.Item;
	import SephiusEngine.userInterfaces.components.contents.SubContentComponent;

	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	import tLotDClassic.GameData.Properties.ItemProperties;
	import SephiusEngine.Languages.LoreLanguageElement;
	/**
	 *  Content for Status screen on InfoMenu
	 * @author Fernando Rabello
	 */
	public class ItemSubContentComponent extends SubContentComponent {
		private var item:Item;
		
		private var	itemImage:Image = new Image(GameEngine.assets.getTexture("Hud_LightScreenSplash"));
		
		private var itemUsageTitle:TextField = new TextField(50, 50, "USAGE", "ChristianaBlack", 26, 0xffffff, true);
		private var itemUsageText:TextField = new TextField(250, 200, "Last words left by Kanpheyro...?! The hatred and sorrow can turn us into terrible things...", "ChristianaBlack", 20, 0xffffff, true);
		private var usageGroup:Sprite = new Sprite();
		
		private var divisor:Image = new Image(GameEngine.assets.getTexture("Menu_LightDivisor"));
		
		private var itemSansicoNameTitle:TextField = new TextField(50, 50, "Halugard", "SansicoLightStone", 27, 0xffffff, true);
		private var itemNameTitle:TextField = new TextField(50, 50, "Halugarde", "ChristianaBlack", 32, 0xffffff, true);
		
		private var itemAmountText:TextField = new TextField(50, 50, "Amount: ", "ChristianaBlack", 25, 0xffffff, true);
		public var itemEquipedText:TextField = new TextField(50, 50, "Equiped: ", "ChristianaBlack", 25, 0xffffff, true);
		private var itemColdDownText:TextField = new TextField(50, 50, "Colddown: ", "ChristianaBlack", 25, 0xffffff, true);
		private var itemDescriptionText:TextField = new TextField(430, 400, "Last words left by Kanpheyro...?! The hatred and sorrow can turn us into terrible things...Last words left by Kanpheyro...?! The hatred and sorrow can turn us into terrible things...Last words left by Kanpheyro...?! The hatred and sorrow can turn us into terrible things...", "ChristianaBlack", 20, 0xffffff, true);
		private var descriptionGroup:Sprite =  new Sprite();
		private var currentProperty:ItemProperties;
		
		public function ItemSubContentComponent() {
			super();
			this.touchable = false;
			
			itemImage.width = 512;
			itemImage.height = 512;
			itemImage.alignPivot();
			//itemImage.x = itemImage.width * .5 - 15;
			itemImage.y = 40;
			
			//Usage Group
			itemUsageTitle.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			itemUsageTitle.alignPivot(HAlign.CENTER, VAlign.TOP);
			itemUsageTitle.x = itemImage.x;
			
			itemUsageText.alignPivot(HAlign.CENTER, VAlign.TOP);
			itemUsageText.hAlign = HAlign.CENTER;
			itemUsageText.vAlign = VAlign.TOP;
			itemUsageText.x = itemUsageTitle.x
			itemUsageText.y = itemUsageTitle.y + itemUsageTitle.height * .5 + 20;
			
			usageGroup.addChild(itemUsageTitle);
			usageGroup.addChild(itemUsageText);
			usageGroup.y = itemImage.y + itemImage.height * .5 - 50;
			usageGroup.x = itemImage.x;
			
			//Description Group
			itemSansicoNameTitle.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			itemSansicoNameTitle.alignPivot(HAlign.LEFT, VAlign.TOP);
			itemSansicoNameTitle.y = itemImage.y - itemImage.height * .5 + 30;
			itemSansicoNameTitle.visible = false;
			
			itemNameTitle.autoSize = TextFieldAutoSize.HORIZONTAL;
			itemNameTitle.alignPivot(HAlign.LEFT, VAlign.CENTER);
			itemNameTitle.y = itemSansicoNameTitle.y + itemSansicoNameTitle.height + 30;
			
			itemEquipedText.autoSize = TextFieldAutoSize.HORIZONTAL;
			itemEquipedText.alignPivot(HAlign.LEFT, VAlign.CENTER);
			itemEquipedText.y = itemNameTitle.y + itemNameTitle.height * .5 + itemAmountText.height * .5;
			
			itemAmountText.autoSize = TextFieldAutoSize.HORIZONTAL;
			itemAmountText.alignPivot(HAlign.LEFT, VAlign.CENTER);
			itemAmountText.y = itemEquipedText.y + itemEquipedText.height * .5;
			
			itemColdDownText.autoSize = TextFieldAutoSize.HORIZONTAL;
			itemColdDownText.alignPivot(HAlign.LEFT, VAlign.CENTER);
			itemColdDownText.y = itemAmountText.y + itemAmountText.height * .5;
			
			itemDescriptionText.alignPivot(HAlign.LEFT, VAlign.TOP);
			itemDescriptionText.hAlign = HAlign.LEFT;
			itemDescriptionText.vAlign = VAlign.TOP;
			itemDescriptionText.x = 0
			itemDescriptionText.y = itemColdDownText.y + itemColdDownText.height * .5 + 15;
			
			descriptionGroup.addChild(itemSansicoNameTitle);
			descriptionGroup.addChild(itemNameTitle);
			descriptionGroup.addChild(itemEquipedText);
			descriptionGroup.addChild(itemAmountText);
			descriptionGroup.addChild(itemColdDownText);
			descriptionGroup.addChild(itemDescriptionText);
			
			descriptionGroup.x = itemImage.x + itemImage.width * .5 - 85;
			
			addChild(usageGroup);
			addChild(descriptionGroup);
			addChild(itemImage);
		}
		
		override public function setContent(content:Object):void {
			super.setContent(content);
			
			if(assets.rawAssetsGroups["info"]){
				assets.removeGroup("info");
				assets.purge();
			}
			
			item = content as Item;
			currentProperty = item.property as ItemProperties;
			//assets.verbose = true;
			
			var url:String = GameAssets.texturesPath.resolvePath("interfaces").resolvePath("items").resolvePath(currentProperty.image + ".atf").url;
			assets.enqueueAsGroup("info", [url]);
			assets.loadQueueGroup(onLoadArt, "info");
		}

		private var equiped:String;
		private var notEquiped:String;
		private var amount:String;
		private var colddown:String;
		private var none:String;	
		private var seconds:String;
		private var minutes:String;

		override public function updateData():void {
			itemImage.texture = assets.getTexture(currentProperty.image);

			itemUsageTitle.text = LanguageManager.getSimpleLang("GameMenuElements", "USAGE").name;

			var itemsData:LoreLanguageElement = LanguageManager.getLoreLang("ItemsData", currentProperty.varName);

			itemUsageText.text = itemsData.usage;
			itemNameTitle.text = itemsData.name;

			equiped = 		LanguageManager.getSimpleLang("GameMenuElements", "Equiped").name;
			notEquiped = 	LanguageManager.getSimpleLang("GameMenuElements", "Not Equiped").name;
			amount = 		LanguageManager.getSimpleLang("GameMenuElements", "Amount").name;
			colddown = 		LanguageManager.getSimpleLang("GameMenuElements", "Colddown").name;
			none = 			LanguageManager.getSimpleLang("GameMenuElements", "None").name;
			seconds = 		LanguageManager.getSimpleLang("GameMenuElements", "Seconds").name;
			minutes = 		LanguageManager.getSimpleLang("GameMenuElements", "Minutes").name;

			itemEquipedText.text = item.equiped ? equiped : notEquiped;
			//itemEquipedText.color = skin == "Light" ? (item.equiped ? 0x004666 : 0x000000) : (item.equiped ? 0xD23804 : 0xffffff) ;
			itemAmountText.text = amount + ": " + item.amount;
			itemColdDownText.text = colddown + ": " + (currentProperty.coldDown == 0 ? none : currentProperty.coldDown % 60 != 0 ? currentProperty.coldDown + " " + seconds : Number(currentProperty.coldDown / 60).toFixed(0) + " " + minutes);
			itemDescriptionText.text = itemsData.description[0].replace(/\n/g, '\n	');//using just 1 page for description at this time
			
			//trace(usageGroup.x, usageGroup.y, usageGroup.alpha, usageGroup.visible, usageGroup.parent);
		}
		
		public var skin:String;
		/** Change Top Menu Component Skin. Propagates trought menu itens changing then skin also */
		override public function changeSkin(skin:String):void {
			this.skin = skin;
			if (skin == "Dark") {
				itemSansicoNameTitle.fontName = "SansicoDarkWhite";
				//itemSansicoNameTitle.color = 0x0000000;
				itemSansicoNameTitle.fontSize = 30;
				itemUsageTitle.fontName = "ChristianaWhite";
				itemUsageText.fontName = "ChristianaWhite";
				itemNameTitle.fontName = "ChristianaWhite";
				itemEquipedText.fontName = "ChristianaWhite";
				itemAmountText.fontName = "ChristianaWhite";
				itemColdDownText.fontName = "ChristianaWhite";
				itemDescriptionText.fontName = "ChristianaWhite";
			}
			else if (skin == "Light") {
				itemSansicoNameTitle.fontName = "Sansico" + skin + "Stone";
				itemSansicoNameTitle.fontSize = 27;
				itemSansicoNameTitle.color = 0xffffff;
				itemUsageTitle.fontName = "ChristianaBlack";
				itemUsageText.fontName = "ChristianaBlack";
				itemNameTitle.fontName = "ChristianaBlack";
				itemEquipedText.fontName = "ChristianaBlack";
				itemAmountText.fontName = "ChristianaBlack";
				itemColdDownText.fontName = "ChristianaBlack";
				itemDescriptionText.fontName = "ChristianaBlack";
			}
		}
		
	}
}