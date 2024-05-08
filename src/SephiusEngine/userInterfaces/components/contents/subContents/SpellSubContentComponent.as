package SephiusEngine.userInterfaces.components.contents.subContents {
	import SephiusEngine.Languages.LanguageManager;
	import SephiusEngine.core.GameAssets;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.gameplay.inventory.objects.SpellKnowledge;
	import SephiusEngine.levelObjects.interfaces.ISpellCaster;
	import SephiusEngine.userInterfaces.components.contents.SubContentComponent;

	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	import tLotDClassic.GameData.Properties.SpellProperties;
	import tLotDClassic.attributes.holders.SpellsAttributes;
	import SephiusEngine.Languages.LoreLanguageElement;
	
	/**
	 *  Content for Spells screen on InfoMenu
	 * @author Fernando Rabello
	 */
	public class SpellSubContentComponent extends SubContentComponent {
		private var spell:SpellKnowledge;
		
		private var divisor:Image = new Image(GameEngine.assets.getTexture("Menu_LightDivisor"));
		
		private var	spellImage1:Image = new Image(GameEngine.assets.getTexture("Hud_DarkScreenSplash"));
		private var	spellImage2:Image = new Image(GameEngine.assets.getTexture("Hud_DarkScreenSplash"));
		private var imageGroup:Sprite =  new Sprite();
		
		private var	spellTitleSansico:TextField = new TextField(20, 20, "light", "SansicoLightStone", 27, 0xffffff, true);
		private var	spellTitle:TextField = new TextField(20, 20, "Light", "ChristianaBlack", 27, 0xffffff, true);
		private var	spellArea:TextField = new TextField(20, 20, "Elementomancy", "ChristianaBlack", 27, 0xffffff, true);
		private var titleGroup:Sprite =  new Sprite();

		private var	natureApplication:TextField = new TextField(20, 20, "Mystic Application", "ChristianaBlack", 22, 0xffffff, true);
		private var	consuption:TextField = new TextField(20, 20, "Consuption", "ChristianaBlack", 22, 0xffffff, true);
		private var	mysticPower:TextField = new TextField(20, 20, "Mystic Power", "ChristianaBlack", 22, 0xffffff, true);
		private var	natureAmplification:TextField = new TextField(20, 20, "Mystic Amplification", "ChristianaBlack", 22, 0xffffff, true);
		private var	natures:TextField = new TextField(20, 20, "Natures: ", "ChristianaBlack", 22, 0xffffff, true);
		
		private var statsGroup:Sprite =  new Sprite();
		
		private var	discriptionTitle:TextField = new TextField(50, 50, "Description:", "ChristianaBlack", 27, 0xffffff, true);
		private var	discription:TextField = new TextField(700, 400, "Last words left by Kanpheyro...?! The hatred and sorrow can turn us into terrible things...Last words left by Kanpheyro...?! The hatred and sorrow can turn us into terrible things...Last words left by Kanpheyro...?! The hatred and sorrow can turn us into terrible things...", "ChristianaBlack", 20, 0xffffff, true);
		private var discriptionGroup:Sprite =  new Sprite();
		
		private var divisorSmall:Image = new Image(GameEngine.assets.getTexture("Menu_DivisorHHalf"));
		
		private var currentProperty:SpellProperties;
		
		public var skin:String;
		
		public function SpellSubContentComponent() {
			super();
			this.touchable = false;
			
			//Image Group
			spellImage1.width = spellImage1.height = 512;
			spellImage1.alignPivot();
			spellImage1.x = 0;
			spellImage1.y = 30;
			
			spellImage2.width = spellImage2.height = 210;
			spellImage2.alignPivot();
			spellImage2.x = 110;
			spellImage2.y = 150;
			
			imageGroup.addChild(spellImage1);
			imageGroup.alignPivot();
			imageGroup.addChild(spellImage2);
			
			//Title Group
			spellTitleSansico.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			spellTitleSansico.alignPivot(HAlign.LEFT, VAlign.TOP);
			spellTitleSansico.hAlign = HAlign.LEFT;
			spellTitleSansico.vAlign = VAlign.TOP;
			
			spellTitle.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			spellTitle.alignPivot(HAlign.LEFT, VAlign.TOP);
			spellTitle.hAlign = HAlign.LEFT;
			spellTitle.vAlign = VAlign.TOP;
			spellTitle.x = spellTitleSansico.x;
			spellTitle.y = spellTitleSansico.y + spellTitleSansico.height - 5;
			
			spellArea.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			spellArea.alignPivot(HAlign.LEFT, VAlign.TOP);
			spellArea.hAlign = HAlign.LEFT;
			spellArea.vAlign = VAlign.TOP;
			spellArea.x = spellTitle.x;
			spellArea.y = spellTitle.y + spellTitle.height - 5;
			
			divisorSmall.alignPivot(HAlign.LEFT, VAlign.CENTER);
			divisorSmall.x = spellArea.x;
			divisorSmall.y = spellArea.y + spellArea.height + 10;
			
			natures.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			natures.alignPivot(HAlign.LEFT, VAlign.TOP);
			natures.hAlign = HAlign.LEFT;
			natures.vAlign = VAlign.TOP;
			natures.x = spellArea.x;
			natures.y = spellArea.y + spellArea.height + 20;
			
			natureApplication.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			natureApplication.alignPivot(HAlign.LEFT, VAlign.TOP);
			natureApplication.hAlign = HAlign.LEFT;
			natureApplication.vAlign = VAlign.TOP;
			natureApplication.x = natures.x;
			natureApplication.y = natures.y + natures.height + 10;
			
			natureAmplification.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			natureAmplification.alignPivot(HAlign.LEFT, VAlign.TOP);
			natureAmplification.hAlign = HAlign.LEFT;
			natureAmplification.vAlign = VAlign.TOP;
			natureAmplification.x = natureApplication.x;
			natureAmplification.y = natureApplication.y + natureApplication.height + 6;
			
			consuption.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			consuption.alignPivot(HAlign.LEFT, VAlign.TOP);
			consuption.hAlign = HAlign.LEFT;
			consuption.vAlign = VAlign.TOP;
			consuption.x = natureAmplification.x;
			consuption.y = natureAmplification.y + natureAmplification.height + 6;
			
			mysticPower.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			mysticPower.alignPivot(HAlign.LEFT, VAlign.TOP);
			mysticPower.hAlign = HAlign.LEFT;
			mysticPower.vAlign = VAlign.TOP;
			mysticPower.x = consuption.x;
			mysticPower.y = consuption.y + consuption.height + 6;
			
			titleGroup.addChild(spellTitleSansico);
			titleGroup.addChild(spellTitle);
			titleGroup.addChild(spellArea);
			titleGroup.addChild(divisorSmall);
			
			titleGroup.addChild(natureApplication);
			
			titleGroup.addChild(consuption);
			titleGroup.addChild(mysticPower);
			titleGroup.addChild(natureAmplification);
			titleGroup.addChild(natures);
			
			titleGroup.x = spellImage1.x + spellImage1.width * .5 - 50;
			titleGroup.y = spellImage1.y - spellImage1.height * .5 + 120;
			
			//Discription Group
			discriptionTitle.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			discriptionTitle.alignPivot(HAlign.LEFT, VAlign.TOP);
			discriptionTitle.hAlign = HAlign.LEFT;
			discriptionTitle.vAlign = VAlign.TOP;
			
			discription.alignPivot(HAlign.LEFT, VAlign.TOP);
			discription.hAlign = HAlign.LEFT;
			discription.vAlign = VAlign.TOP;
			discription.y = discriptionTitle.y + discriptionTitle.height + 10;
			
			discriptionGroup.addChild(discriptionTitle);
			discriptionGroup.addChild(discription);
			discriptionGroup.x = spellImage1.x - spellImage1.width * .25;
			discriptionGroup.y = spellImage1.y + spellImage1.height * .45 - 30;
			
			addChild(spellImage1);
			addChild(spellImage2);
			addChild(titleGroup);
			addChild(discriptionGroup);
		}
		
		private var consumptionT:String;
		private var spellPowerT:String;
		private var natureApplicationsT:String;
		private var natureApplicationT:String;
		private var natureAmplificationsT:String;
		private var natureAmplificationT:String;
		private var naturesT:String;	
		private var natureT:String;	

		private var hMysticPower:Vector.<Number> = new Vector.<Number>();
		override public function updateData():void {
			spellImage1.texture = assets.getTexture("SpellImage_" + currentProperty.damageNatures.aboveZero[0]);
			if(currentProperty.damageNatures.aboveZero.length == 2){
				spellImage2.texture = assets.getTexture("SpellImage_" + currentProperty.damageNatures.aboveZero[1]);
				spellImage2.visible = true;
			}
			else
				spellImage2.visible = false;

			var spellData:LoreLanguageElement = LanguageManager.getLoreLang("SpellsData", currentProperty.varName);

			consumptionT = 			LanguageManager.getSimpleLang("GameMenuElements", "Consumption").name;
			spellPowerT = 			LanguageManager.getSimpleLang("GameMenuElements", "Spell Power").name;
			natureApplicationsT = 	LanguageManager.getSimpleLang("GameMenuElements", "Nature Applications").name;
			natureApplicationT = 	LanguageManager.getSimpleLang("GameMenuElements", "Nature Application").name;
			natureAmplificationsT = LanguageManager.getSimpleLang("GameMenuElements", "Nature Amplifications").name;
			natureAmplificationT = 	LanguageManager.getSimpleLang("GameMenuElements", "Nature Amplification").name;
			naturesT = 				LanguageManager.getSimpleLang("GameMenuElements", "Natures").name;

			discriptionTitle.text = LanguageManager.getSimpleLang("GameMenuElements", "DescriptionTitle").name;
			spellTitleSansico.text = currentProperty.name.split("_").join(" ").toLowerCase();
			spellTitle.text = LanguageManager.getSimpleLang("SpellsData", currentProperty.varName).name;
			spellArea.text = LanguageManager.getSimpleLang("SpellsData", SpellProperties.getSpellSchool(currentProperty.varName)).name;
			discription.text = spellData.description[0].replace(/\n/g, '\n	');
			consuption.text = consumptionT + ": " + SpellsAttributes.getSpellConsumptionByAttibutes(GameEngine.instance.state.mainPlayer, currentProperty).toFixed(0);
			mysticPower.text = spellPowerT + ": " + SpellsAttributes.getSpellPower(GameEngine.instance.state.mainPlayer as ISpellCaster, currentProperty).toFixed(0);
			natureApplication.text = (currentProperty.isCompound ? natureApplicationsT + ": " : natureApplicationT + ": ") + (currentProperty.isCompound ? (currentProperty.natureApplications[currentProperty.damageNatures.aboveZero[0]]  + ", " + currentProperty.natureApplications[currentProperty.damageNatures.aboveZero[1]]) : currentProperty.natureApplications[currentProperty.damageNatures.aboveZero[0]]);
			natures.text = (currentProperty.isCompound ? naturesT + ": " : natureT + ": ") + currentProperty.damageNatures.aboveZero[0] + (currentProperty.isCompound ? ", " + currentProperty.damageNatures.aboveZero[1] : "");
			natureAmplification.text = (currentProperty.isCompound ? natureAmplificationsT + ": " : natureAmplificationT + ": ") + (currentProperty.isCompound ? Number(GameEngine.instance.state.mainPlayer.characterAttributes.natureAmplifications[currentProperty.damageNatures.aboveZero[0]]).toFixed(1) + ", " + Number(GameEngine.instance.state.mainPlayer.characterAttributes.natureAmplifications[currentProperty.damageNatures.aboveZero[1]]).toFixed(1) : Number(GameEngine.instance.state.mainPlayer.characterAttributes.natureAmplifications[currentProperty.damageNatures.aboveZero[0]]).toFixed(1));
			
			consuption.hAlign = HAlign.RIGHT;
			mysticPower.hAlign = HAlign.RIGHT;
			
			natureAmplification.hAlign = HAlign.RIGHT;
			natureAmplification.color = currentProperty.isCompound ? ((currentProperty.natureApplications[currentProperty.damageNatures.aboveZero[0]] > GameEngine.instance.state.mainPlayer.characterAttributes.natureAmplifications[currentProperty.damageNatures.aboveZero[0]] || currentProperty.natureApplications[currentProperty.damageNatures.aboveZero[1]] > GameEngine.instance.state.mainPlayer.characterAttributes.natureAmplifications[currentProperty.damageNatures.aboveZero[1]]) ? 0xF90000 :  0xffffff) : ((currentProperty.natureApplications[currentProperty.damageNatures.aboveZero[0]] > GameEngine.instance.state.mainPlayer.characterAttributes.natureAmplifications[currentProperty.damageNatures.aboveZero[0]]) ? 0xF90000 : 0xffffff);
			natureAmplification.fontName = currentProperty.isCompound ? ((currentProperty.natureApplications[currentProperty.damageNatures.aboveZero[0]] > GameEngine.instance.state.mainPlayer.characterAttributes.natureAmplifications[currentProperty.damageNatures.aboveZero[0]] || currentProperty.natureApplications[currentProperty.damageNatures.aboveZero[1]] > GameEngine.instance.state.mainPlayer.characterAttributes.natureAmplifications[currentProperty.damageNatures.aboveZero[1]]) ?  "ChristianaWhite" :  skin == "Dark" ? "ChristianaWhite" : "ChristianaBlack") : ((currentProperty.natureApplications[currentProperty.damageNatures.aboveZero[0]] > GameEngine.instance.state.mainPlayer.characterAttributes.natureAmplifications[currentProperty.damageNatures.aboveZero[0]]) ? "ChristianaWhite" : skin == "Dark" ? "ChristianaWhite" : "ChristianaBlack");
		}
		
		override public function setContent(content:Object):void {
			super.setContent(content);
			
			if(assets.rawAssetsGroups["info"]){
				assets.removeGroup("info");
				assets.purge();
			}
			
			spell = content as SpellKnowledge;
			currentProperty = spell.property as SpellProperties;
			//assets.verbose = true;
		
			assets.enqueueAsGroup("info", [GameAssets.texturesPath.resolvePath("interfaces").resolvePath("spells").resolvePath("SpellImage_" + currentProperty.damageNatures.aboveZero[0] + ".atf").url]);
			if (currentProperty.damageNatures.aboveZero.length == 2) {
				assets.enqueueAsGroup("info", [GameAssets.texturesPath.resolvePath("interfaces").resolvePath("spells").resolvePath("SpellImage_" + currentProperty.damageNatures.aboveZero[1] + ".atf").url	]);
			}
			assets.loadQueueGroup(onLoadArt, "info");
		}
		
		/** Change Top Menu Component Skin. Propagates trought menu itens changing then skin also */
		override public function changeSkin(skin:String):void {
			if (skin == "Dark") {
				spellImage1.color = 0xffffff;
				spellImage2.color = 0xffffff;
				spellTitleSansico.fontName = "SansicoDarkWhite";
				spellTitleSansico.fontSize = 30;
				spellTitle.fontName = "ChristianaWhite";
				spellArea.fontName = "ChristianaWhite";
				natureApplication.fontName = "ChristianaWhite";
				discriptionTitle.fontName = "ChristianaWhite";
				discription.fontName = "ChristianaWhite";
				consuption.fontName = "ChristianaWhite";
				mysticPower.fontName = "ChristianaWhite";
				natureAmplification.fontName = "ChristianaWhite";
				natures.fontName = "ChristianaWhite";
			}
			else if (skin == "Light") {
				spellImage1.color = 0x000000;
				spellImage2.color = 0x000000;
				spellTitleSansico.fontName = "Sansico" + skin + "Stone";
				spellTitleSansico.fontSize = 27;
				spellTitle.fontName = "ChristianaBlack";
				spellArea.fontName = "ChristianaBlack";
				natureApplication.fontName = "ChristianaBlack";
				discriptionTitle.fontName = "ChristianaBlack";
				discription.fontName = "ChristianaBlack";
				consuption.fontName = "ChristianaBlack";
				mysticPower.fontName = "ChristianaBlack";
				natureAmplification.fontName = "ChristianaBlack";
				natures.fontName = "ChristianaBlack";
			}
			this.skin = skin;
		}
	}
}