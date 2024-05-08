package SephiusEngine.userInterfaces.components.contents.subContents {
	import SephiusEngine.core.GameAssets;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.gameplay.inventory.objects.Weapon;
	import tLotDClassic.behaviors.playerBehaviors.PlayerWeapons;
	import tLotDClassic.GameData.Properties.WeaponProperties;
	import SephiusEngine.userInterfaces.components.contents.SubContentComponent;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	import flash.filesystem.File;
	import SephiusEngine.Languages.LanguageManager;
	import SephiusEngine.Languages.LoreLanguageElement;
	/**
	 * ...
	 * @author ...
	 */
	public class WeaponSubContentComponent extends SubContentComponent {
		private var weapon:Weapon;
		
		private var	weaponImage:Image = new Image(GameEngine.assets.getTexture("Hud_LightScreenSplash"));
		
		private var weaponUsageTitle:TextField = new TextField(50, 50, "USAGE", "ChristianaBlack", 26, 0xffffff, true);
		private var weaponUsageText:TextField = new TextField(250, 200, "Last words left by Kanpheyro...?! The hatred and sorrow can turn us into terrible things...", "ChristianaBlack", 20, 0xffffff, true);
		private var usageGroup:Sprite = new Sprite();
		
		private var divisor:Image = new Image(GameEngine.assets.getTexture("Menu_LightDivisor"));
		
		private var weaponSansicoNameTitle:TextField = new TextField(50, 50, "Halugard", "SansicoLightStone", 27, 0xffffff, true);
		private var weaponNameTitle:TextField = new TextField(50, 50, "Halugarde", "ChristianaBlack", 32, 0xffffff, true);
		
		private var weaponDescriptionText:TextField = new TextField(430, 400, "Last words left by Kanpheyro...?! The hatred and sorrow can turn us into terrible things...Last words left by Kanpheyro...?! The hatred and sorrow can turn us into terrible things...Last words left by Kanpheyro...?! The hatred and sorrow can turn us into terrible things...", "ChristianaBlack", 20, 0xffffff, true);
		private var weaponType:TextField = new TextField(50, 50, "Sword", "ChristianaBlack", 25, 0xffffff, true);
		private var weaponPower:TextField = new TextField(50, 50, "Attak Power: 128", "ChristianaBlack", 25, 0xffffff, true);
		private var natures:TextField = new TextField(250, 50, "Natures: Physical, Ice", "ChristianaBlack", 20, 0xffffff, true);
		private var descriptionGroup:Sprite =  new Sprite();
		
		private const texts:Vector.<TextField> = new Vector.<TextField>();
		private var currentProperty:WeaponProperties;
		
		public function WeaponSubContentComponent() {
			super();
			
			this.touchable = false;
			
			weaponImage.width = 256;
			weaponImage.height = 512;
			weaponImage.alignPivot();
			//weaponImage.x = weaponImage.width * .5 - 15;
			weaponImage.y = 40;
			weaponImage.rotation = .3;
			
			//Usage Group
			weaponUsageTitle.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			weaponUsageTitle.alignPivot(HAlign.CENTER, VAlign.TOP);
			weaponUsageTitle.x = weaponImage.x;
			texts.push(weaponUsageTitle);
			
			weaponUsageText.alignPivot(HAlign.CENTER, VAlign.TOP);
			weaponUsageText.hAlign = HAlign.CENTER;
			weaponUsageText.vAlign = VAlign.TOP;
			weaponUsageText.x = weaponUsageTitle.x
			weaponUsageText.y = weaponUsageTitle.y + weaponUsageTitle.height * .5 + 20;
			texts.push(weaponUsageText);
			
			usageGroup.addChild(weaponUsageTitle);
			usageGroup.addChild(weaponUsageText);
			usageGroup.y = weaponImage.y + 256;
			usageGroup.x = weaponImage.x;
			
			//Description Group
			weaponSansicoNameTitle.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			weaponSansicoNameTitle.alignPivot(HAlign.LEFT, VAlign.TOP);
			weaponSansicoNameTitle.y = weaponImage.y - 256 + 30;
			weaponSansicoNameTitle.visible = false;
			texts.push(weaponSansicoNameTitle);
			
			weaponNameTitle.autoSize = TextFieldAutoSize.HORIZONTAL;
			weaponNameTitle.alignPivot(HAlign.LEFT, VAlign.CENTER);
			weaponNameTitle.y = weaponSansicoNameTitle.y + weaponSansicoNameTitle.height + 30;
			texts.push(weaponNameTitle);
			
			weaponType.autoSize = TextFieldAutoSize.HORIZONTAL;
			weaponType.alignPivot(HAlign.LEFT, VAlign.CENTER);
			weaponType.y = weaponNameTitle.y + weaponNameTitle.height * .5 + weaponNameTitle.height * .5;
			
			weaponPower.autoSize = TextFieldAutoSize.HORIZONTAL;
			weaponPower.alignPivot(HAlign.LEFT, VAlign.CENTER);
			weaponPower.y = weaponType.y + weaponType.height * .5;
			
			natures.autoSize = TextFieldAutoSize.HORIZONTAL;
			natures.alignPivot(HAlign.LEFT, VAlign.TOP);
			natures.y = weaponPower.y;
			
			weaponDescriptionText.alignPivot(HAlign.LEFT, VAlign.TOP);
			weaponDescriptionText.hAlign = HAlign.LEFT;
			weaponDescriptionText.vAlign = VAlign.TOP;
			weaponDescriptionText.y = natures.y + natures.height + 15;
			
			texts.push(weaponDescriptionText);
			
			descriptionGroup.addChild(weaponSansicoNameTitle);
			descriptionGroup.addChild(weaponNameTitle);
			descriptionGroup.addChild(weaponType);
			descriptionGroup.addChild(weaponPower);
			descriptionGroup.addChild(natures);
			descriptionGroup.addChild(weaponDescriptionText);
			
			descriptionGroup.x = weaponImage.x + 128 + 20;
			
			addChild(usageGroup);
			addChild(descriptionGroup);
			addChild(weaponImage);
		}
		
		override public function setContent(content:Object):void {
			super.setContent(content);
			
			if(assets.rawAssetsGroups["info"]){
				assets.removeGroup("info");
				assets.purge();
			}
			
			weapon = content as Weapon;
			currentProperty = weapon.property as WeaponProperties;
			//assets.verbose = true;
			assets.enqueueAsGroup("info", [GameAssets.texturesPath.resolvePath("interfaces").resolvePath("weapons").resolvePath(currentProperty.image + ".atf").url	]);
			assets.loadQueueGroup(onLoadArt, "info");
		}
		
		private var shieldT:String;
		private var defencePercentT:String;
		private var allT:String;
		private var attackPowerT:String;
		private var naturesT:String;	

		override public function updateData():void {
			weaponImage.texture = assets.getTexture(currentProperty.image);
			weaponImage.rotation = (currentProperty.weaponType == shieldT) ? 0 : .3;
			
			var naturesV:Vector.<String> = currentProperty.natures.aboveZero.concat();
			var defencePercent:Vector.<String> = new Vector.<String>();
			var power:int = 0;
			var nature:String;
			for each (nature in currentProperty.natures.aboveZero) {
				power = currentProperty.natures[nature];
				defencePercent.push(" " + power.toFixed(0) + "%")
			}

			var weaponData:LoreLanguageElement = LanguageManager.getLoreLang("WeaponsData", currentProperty.varName);

			shieldT = 			LanguageManager.getSimpleLang("GameMenuElements", "Shield").name;
			defencePercentT = 	LanguageManager.getSimpleLang("GameMenuElements", "Defence Percent").name;
			allT = 				LanguageManager.getSimpleLang("GameMenuElements", "All").name;
			attackPowerT = 		LanguageManager.getSimpleLang("GameMenuElements", "Attack Power").name;
			naturesT = 			LanguageManager.getSimpleLang("GameMenuElements", "Natures").name;

			weaponUsageTitle.text = LanguageManager.getSimpleLang("GameMenuElements", "DescriptionTitle").name;
			weaponUsageText.text = weaponData.usage;
			weaponSansicoNameTitle.text = weaponData.name;
			weaponNameTitle.text = weaponData.name;
			weaponType.text = LanguageManager.getSimpleLang("WeaponsData", currentProperty.weaponType).name;
			weaponPower.text = (currentProperty.weaponType == shieldT) ? (defencePercentT + ": " + ((defencePercent.length > 5) ? (allT + defencePercent[0]) : defencePercent.toString())) : (attackPowerT + ": " + PlayerWeapons.weaponTotalDamage(weapon, GameEngine.instance.state.mainPlayer));
			natures.text = naturesT + ":" + (naturesV.length > 5 ? allT : naturesV.toString());
			weaponDescriptionText.text = weaponData.description[0].replace(/\n/g, '\n	');
			
			trace(usageGroup.x, usageGroup.y, usageGroup.alpha, usageGroup.visible, usageGroup.parent);
		}
		
		/** Change Top Menu Component Skin. Propagates trought menu itens changing then skin also */
		override public function changeSkin(skin:String):void {
			if (skin == "Dark") {
				weaponSansicoNameTitle.fontName = "SansicoDarkWhite";
				//weaponSansicoNameTitle.color = 0x0000000;
				weaponSansicoNameTitle.fontSize = 30;
				weaponUsageTitle.fontName = "ChristianaWhite";
				weaponUsageText.fontName = "ChristianaWhite";
				weaponNameTitle.fontName = "ChristianaWhite";
				weaponDescriptionText.fontName = "ChristianaWhite";
				weaponType.fontName = "ChristianaWhite";
				weaponPower.fontName = "ChristianaWhite";
				natures.fontName = "ChristianaWhite";
			}
			else if (skin == "Light") {
				weaponSansicoNameTitle.fontName = "Sansico" + skin + "Stone";
				weaponSansicoNameTitle.fontSize = 27;
				weaponSansicoNameTitle.color = 0xffffff;
				weaponUsageTitle.fontName = "ChristianaBlack";
				weaponUsageText.fontName = "ChristianaBlack";
				weaponNameTitle.fontName = "ChristianaBlack";
				weaponDescriptionText.fontName = "ChristianaBlack";
				weaponType.fontName = "ChristianaBlack";
				weaponPower.fontName = "ChristianaBlack";
				natures.fontName = "ChristianaBlack";
			}
		}
	}
}