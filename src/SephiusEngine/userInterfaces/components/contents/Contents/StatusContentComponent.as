package SephiusEngine.userInterfaces.components.contents.Contents {
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.gameStates.LevelManager;
	import SephiusEngine.userInterfaces.components.contents.ContentComponent;
	import tLotDClassic.GameData.Properties.naturesInfos.Natures;
	import flash.utils.Dictionary;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	import SephiusEngine.Languages.LanguageManager;
	
	/**
	 * Content for Status screen on InfoMenu
	 * @author Fernando Rabello
	 */
	public class StatusContentComponent extends ContentComponent {
		private var	menuStatue:Image = new Image(GameEngine.assets.getTexture("Menu_LightStatue"));
		
		private var sephiusAvatarGroup:Sprite = new Sprite();
		private var sephiusTitle:TextField = new TextField(50, 50, "SEPHIUS", "ChristianaBlack", 50, 0xffffff, true);
		private var essensikaLevelTitle:TextField = new TextField(50, 50, "ESSÊNSIKA LEVEL", "ChristianaBlack", 25, 0xffffff, true);
		private var levelText:TextField = new TextField(50, 50, "", "ChristianaBlack", 60, 0xffffff, true);
		private var essensikaTotalText:TextField = new TextField(50, 50, "", "ChristianaBlack", 25, 0xffffff, true);
		
		private var attributesGroup:Sprite = new Sprite();
		private var attributesTextsGroup:Sprite = new Sprite();
		private var attributesTitle:TextField = new TextField(50, 50, "ATTRIBUTES", "ChristianaBlack", 30, 0xffffff, true);
		private var attributesTexts1:Sprite = new Sprite();
		private var attributesTexts2:Sprite = new Sprite();
		private var attributesTextsFields:Vector.<TextField> = new Vector.<TextField>();
		
		private var textPE:TextField = new TextField(50, 50, "Peripheral Essence: ", "ChristianaBlack", 25, 0xffffff, true);
		private var textME:TextField = new TextField(50, 50, "Mystical Essence: ", "ChristianaBlack", 25, 0xffffff, true);
		private var textDE:TextField = new TextField(50, 50, "Deep Essence: ", "ChristianaBlack", 25, 0xffffff, true);
		private var textST:TextField = new TextField(50, 50, "Status: ", "ChristianaBlack", 25, 0xffffff, true);
		
		private var textSTR:TextField = new TextField(50, 50, "Strengh: ", "ChristianaBlack", 25, 0xffffff, true);
		private var textPRE:TextField = new TextField(50, 50, "Resistance: ", "ChristianaBlack", 25, 0xffffff, true);
		private var textEFF:TextField = new TextField(50, 50, "Efficiency: ", "ChristianaBlack", 25, 0xffffff, true);
		private var textSTA:TextField = new TextField(50, 50, "Defence: ", "ChristianaBlack", 25, 0xffffff, true);
		
		private var immunitiesGroup:Sprite = new Sprite();
		private var immunitiesTextsGroup:Sprite = new Sprite();
		private var immunitiesTitle:TextField = new TextField(50, 50, "MYSTICAL IMMUNITIES", "ChristianaBlack", 30, 0xffffff, true);
		
		private var immunitiesContainers:Dictionary = new Dictionary();
		private var immunitiesSymbols:Dictionary = new Dictionary();
		private var immunitiesTextFields:Dictionary = new Dictionary();
		
		/** Art divisors witch separates itens vertically*/
		private var vDivisors:Vector.<Image> = new Vector.<Image>();
		
		/** Art divisors witch separates itens horizontally*/
		private var hDivisors:Vector.<Image> = new Vector.<Image>();
		
		public function StatusContentComponent(objectParent:Object){
			super(objectParent);
			
			this.touchable = false;
			
			// -- Avatar Group --- //
				menuStatue.alignPivot();
				
				sephiusTitle.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
				sephiusTitle.alignPivot();
				sephiusTitle.x = menuStatue.x;
				sephiusTitle.y = menuStatue.y - menuStatue.height * .5;
				
				essensikaLevelTitle.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
				essensikaLevelTitle.alignPivot();
				essensikaLevelTitle.x = menuStatue.x;
				essensikaLevelTitle.y = menuStatue.y + menuStatue.height * .5 -15;
				
				levelText.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
				levelText.text = GameEngine.instance.state.mainPlayer.characterAttributes.level.toFixed(0);
				levelText.alignPivot();
				levelText.x = menuStatue.x;
				levelText.y = essensikaLevelTitle.y + essensikaLevelTitle.height * .5 + 20;
				
				essensikaTotalText.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;

				cText = LanguageManager.getSimpleLang("GameMenuElements", "Total").name;
				essensikaTotalText.text = GameEngine.instance.state.mainPlayer.characterAttributes.essencika.toFixed(0) + " " + cText;
				essensikaTotalText.alignPivot();
				essensikaTotalText.x = menuStatue.x;
				essensikaTotalText.y = levelText.y + levelText.height * .5 + 10;
				
				sephiusAvatarGroup.addChild(menuStatue);
				sephiusAvatarGroup.addChild(sephiusTitle);
				sephiusAvatarGroup.addChild(essensikaLevelTitle);
				sephiusAvatarGroup.addChild(levelText);
				sephiusAvatarGroup.addChild(essensikaTotalText);
				sephiusAvatarGroup.alignPivot(HAlign.CENTER, VAlign.TOP);
				sephiusAvatarGroup.x = -410;
				sephiusAvatarGroup.y = -135;
				
			// ----------------//
			
			// --- attributesGroup --- //
				attributesTitle.autoSize = TextFieldAutoSize.HORIZONTAL;
				attributesTitle.alignPivot();
				
				hDivisors.push(new Image(GameEngine.assets.getTexture("Menu_LightDivisorH")));
				hDivisors[0].alignPivot();
				hDivisors[0].x = attributesTitle.x;
				hDivisors[0].y = attributesTitle.height * .5 + 20; 

				var cText:String;

				cText = LanguageManager.getSimpleLang("GameMenuElements", "Peripheral Essence: ").name;
				textPE.text = cText + GameEngine.instance.state.mainPlayer.characterAttributes.peripheralEssence.toFixed() + " / " + GameEngine.instance.state.mainPlayer.characterAttributes.maxPeripheralEssence.toFixed();
				textPE.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;

				cText = LanguageManager.getSimpleLang("GameMenuElements", "Mystical Essence: ").name;
				textME.text = cText + GameEngine.instance.state.mainPlayer.characterAttributes.mysticalEssence.toFixed() + " / " + GameEngine.instance.state.mainPlayer.characterAttributes.maxMysticalEssence.toFixed();
				textME.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
				textME.y = textPE.y + textPE.height * .5 + textME.height * .5 + 20;

				cText = LanguageManager.getSimpleLang("GameMenuElements", "Deep Essence: ").name;
				textDE.text = cText + GameEngine.instance.state.mainPlayer.characterAttributes.deepEssence.toFixed() + " / " + GameEngine.instance.state.mainPlayer.characterAttributes.maxDeepEssence.toFixed();
				textDE.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
				textDE.y = textME.y + textME.height * .5 + textDE.height * .5 + 20;

				cText = LanguageManager.getSimpleLang("GameMenuElements", "Status: ").name;
				textST.text = cText + (GameEngine.instance.state.mainPlayer.characterAttributes.status.activatedStatus.length > 0 ? GameEngine.instance.state.mainPlayer.characterAttributes.status.activatedStatus : "Normal");
				textST.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
				textST.y = textDE.y + textDE.height * .5 + textST.height * .5 + 20;
				
				attributesTexts1.addChild(textPE);
				attributesTexts1.addChild(textME);
				attributesTexts1.addChild(textDE);
				attributesTexts1.addChild(textST);
				
				vDivisors.push(new Image(GameEngine.assets.getTexture("Menu_LightDivisor")));
				vDivisors[0].alignPivot();
				vDivisors[0].x = attributesTexts1.x + attributesTexts1.width + 50;
				vDivisors[0].y = attributesTexts1.y + attributesTexts1.height * .5;
				
				cText = LanguageManager.getSimpleLang("GameMenuElements", "Strengh: ").name;
				textSTR.text = cText + GameEngine.instance.state.mainPlayer.characterAttributes.strength.toFixed();
				textSTR.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
				
				cText = LanguageManager.getSimpleLang("GameMenuElements", "Resistance: ").name;
				textPRE.text = cText + (GameEngine.instance.state.mainPlayer.characterProperties.staticAttributes.natureResistances[Natures.Physical] + GameEngine.instance.state.mainPlayer.characterAttributes.physicalResistanceBuff).toFixed();
				textPRE.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
				textPRE.y = textSTR.y + textSTR.height * .5 + textPRE.height * .5 + 20;
				
				cText = LanguageManager.getSimpleLang("GameMenuElements", "Efficiency: ").name;
				textEFF.text = cText + (GameEngine.instance.state.mainPlayer.characterAttributes.efficiency +  GameEngine.instance.state.mainPlayer.characterAttributes.efficiencyBuff).toFixed();
				textEFF.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
				textEFF.y = textPRE.y + textPRE.height * .5 + textEFF.height * .5 + 20;
				
				cText = LanguageManager.getSimpleLang("GameMenuElements", "Defence: ").name;
				textSTA.text = cText + (GameEngine.instance.state.mainPlayer.characterAttributes.maxStamina).toFixed();
				textSTA.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
				textSTA.y = textEFF.y + textEFF.height * .5 + textSTA.height * .5 + 20;
				
				attributesTexts2.addChild(textSTR);
				attributesTexts2.addChild(textPRE);
				attributesTexts2.addChild(textEFF);
				attributesTexts2.addChild(textSTA);
				attributesTexts2.x = vDivisors[0].x + vDivisors[0].width * .5 + 50;
				
				attributesTextsFields.push(textPE);
				attributesTextsFields.push(textME);
				attributesTextsFields.push(textDE);
				attributesTextsFields.push(textST);
				attributesTextsFields.push(textSTR);
				attributesTextsFields.push(textPRE);
				attributesTextsFields.push(textEFF);
				attributesTextsFields.push(textSTA);
				
				attributesTextsGroup.addChild(attributesTexts1);
				attributesTextsGroup.addChild(vDivisors[0]);
				attributesTextsGroup.addChild(attributesTexts2);
				attributesTextsGroup.alignPivot(HAlign.CENTER, VAlign.TOP);
				attributesTextsGroup.x = 0;
				attributesTextsGroup.y =  hDivisors[0].y + hDivisors[0].height * .5 + 0;
				
				attributesGroup.addChild(attributesTitle);
				attributesGroup.addChild(hDivisors[0]);
				attributesGroup.addChild(attributesTextsGroup);
				attributesGroup.alignPivot(HAlign.CENTER, VAlign.TOP);
				attributesGroup.x = sephiusAvatarGroup.x + sephiusAvatarGroup.width * .5 +  attributesGroup.width * .5 + 100;
				attributesGroup.y = sephiusAvatarGroup.y;
				
				// ----------------- //
				
				// --- IMMUITIES GROUP --- //
				immunitiesTitle.autoSize = TextFieldAutoSize.HORIZONTAL;
				immunitiesTitle.alignPivot();
				
				hDivisors.push(new Image(GameEngine.assets.getTexture("Menu_LightDivisorH")));
				hDivisors[1].alignPivot();
				hDivisors[1].x = immunitiesTitle.x;
				hDivisors[1].y = immunitiesTitle.y + immunitiesTitle.height * .5 + 20; 
				
				var count:int = 0;
				var lastNature:String;
				
				for each(var nature:String in Natures.ALL_MYSTIC_NATURES) {
					immunitiesContainers[nature] = new Sprite();
					immunitiesTextFields[nature] = new TextField(50, 50, nature + ": " + (GameEngine.instance.state.mainPlayer.characterAttributes.mainSuffer.natureImmunity[nature]) + "%", "ChristianaBlack", 25, 0xffffff, true);
					immunitiesSymbols[nature] = new Image(GameEngine.assets.getTexture("SpellIcon_" + skin + nature));
					
					immunitiesSymbols[nature].alignPivot();
					immunitiesSymbols[nature].scaleX = immunitiesSymbols[nature].scaleY = .5;
					
					immunitiesTextFields[nature].autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
					immunitiesTextFields[nature].alignPivot(HAlign.LEFT, VAlign.CENTER);
					immunitiesTextFields[nature].x = immunitiesSymbols[nature].width * .5 - 5;
					immunitiesTextFields[nature].y = immunitiesSymbols[nature].y;
					
					immunitiesContainers[nature].addChild(immunitiesTextFields[nature]);
					immunitiesContainers[nature].addChild(immunitiesSymbols[nature]);
					
					if((count % 4) != 0)
						immunitiesContainers[nature].x = immunitiesContainers[lastNature].x + immunitiesContainers[lastNature].width + 15;
					else
						immunitiesContainers[nature].x = 0;
						
					//immunitiesContainers[nature].x = (200 * (count % 4));
					immunitiesContainers[nature].y = (50 * int(count / 4));
					
					count++;
					
					immunitiesTextsGroup.addChild(immunitiesContainers[nature]);
					
					lastNature = nature;
				}
				
				immunitiesTextsGroup.alignPivot(HAlign.CENTER, VAlign.TOP);
				immunitiesTextsGroup.y = hDivisors[1].y + hDivisors[1].height * .5 - 15;
				
				immunitiesGroup.addChild(immunitiesTitle);
				immunitiesGroup.addChild(hDivisors[1]);
				immunitiesGroup.addChild(immunitiesTextsGroup);
				
				immunitiesGroup.alignPivot(HAlign.CENTER, VAlign.TOP);
				immunitiesGroup.x = sephiusAvatarGroup.x + sephiusAvatarGroup.width * .5 +  attributesGroup.width * .5 + 70;
				immunitiesGroup.y = sephiusAvatarGroup.y + attributesGroup.height + 25;
				
				addChild(sephiusAvatarGroup);
				addChild(attributesGroup);
				addChild(immunitiesGroup);
				
				y = skin == "Dark" ? 0 : 15;
		}
		
		public function updateLang(langID:String=""):void{
			var cText:String;
			
			cText = LanguageManager.getSimpleLang("GameMenuElements", "Peripheral Essence: ").name;
			textPE.text = cText + GameEngine.instance.state.mainPlayer.characterAttributes.peripheralEssence.toFixed() + " / " + GameEngine.instance.state.mainPlayer.characterAttributes.maxPeripheralEssence.toFixed();
			
			cText = LanguageManager.getSimpleLang("GameMenuElements", "Mystical Essence: ").name;
			textME.text = cText + GameEngine.instance.state.mainPlayer.characterAttributes.mysticalEssence.toFixed() + " / " + GameEngine.instance.state.mainPlayer.characterAttributes.maxMysticalEssence.toFixed();
			
			cText = LanguageManager.getSimpleLang("GameMenuElements", "Deep Essence: ").name;
			textDE.text = cText + GameEngine.instance.state.mainPlayer.characterAttributes.deepEssence.toFixed() + " / " + GameEngine.instance.state.mainPlayer.characterAttributes.maxDeepEssence.toFixed();
			
			cText = LanguageManager.getSimpleLang("GameMenuElements", "Status: ").name;
			textST.text = cText + (GameEngine.instance.state.mainPlayer.characterAttributes.status.activatedStatus.length > 0 ? GameEngine.instance.state.mainPlayer.characterAttributes.status.activatedStatus : "Normal");
			
			cText = LanguageManager.getSimpleLang("GameMenuElements", "Strengh: ").name;
			textSTR.text = cText + GameEngine.instance.state.mainPlayer.characterAttributes.strength.toFixed();
			
			cText = LanguageManager.getSimpleLang("GameMenuElements", "Resistance: ").name;
			textPRE.text = cText + (GameEngine.instance.state.mainPlayer.characterProperties.staticAttributes.natureResistances[Natures.Physical] + GameEngine.instance.state.mainPlayer.characterAttributes.physicalResistanceBuff).toFixed();
			
			cText = LanguageManager.getSimpleLang("GameMenuElements", "Efficiency: ").name;
			textEFF.text = cText + (GameEngine.instance.state.mainPlayer.characterAttributes.efficiency +  GameEngine.instance.state.mainPlayer.characterAttributes.efficiencyBuff).toFixed();
			
			cText = LanguageManager.getSimpleLang("GameMenuElements", "Stamina: ").name;
			textSTA.text = cText + (GameEngine.instance.state.mainPlayer.characterAttributes.maxStamina).toFixed();
			
			essensikaTotalText.text = GameEngine.instance.state.mainPlayer.characterAttributes.essencika.toFixed(0) + " Total";
			levelText.text = GameEngine.instance.state.mainPlayer.characterAttributes.level.toFixed(0);

			attributesTitle.text = LanguageManager.getSimpleLang("GameMenuElements", "ATTRIBUTES").name;

			immunitiesTitle.text = LanguageManager.getSimpleLang("GameMenuElements", "MYSTICAL IMMUNITIES").name;

			var count:int = 0;
			var lastNature:String;
			var nature:String;
			for each(nature in Natures.ALL_MYSTIC_NATURES) {
			    cText = LanguageManager.getSimpleLang("NatureNames", nature).name;
				immunitiesTextFields[nature].text = cText + ": " + (GameEngine.instance.state.mainPlayer.characterAttributes.mainSuffer.natureImmunity[nature]) + "%"
				if((count % 4) != 0)
					immunitiesContainers[nature].x = immunitiesContainers[lastNature].x + immunitiesContainers[lastNature].width + 15;
				else
					immunitiesContainers[nature].x = 0;
					
				immunitiesContainers[nature].y = (50 * int(count / 4));
				
				count++;
				lastNature = nature;
			}
		}

		override public function updateData():void {
			updateLang();
		}
		
		override public function hide():void {
			super.hide();
		}
		
		/** Change Top Menu Component Skin. Propagates trought menu itens changing then skin also */
		override public function changeSkin(skin:String):void {
			menuStatue.texture = GameEngine.assets.getTexture("Menu_" + skin + "Statue");
			
			if (skin == "Dark"){
				sephiusTitle.fontName = "ChristianaWhite";
				essensikaLevelTitle.fontName = "ChristianaWhite";
				levelText.fontName = "ChristianaWhite";
				essensikaTotalText.fontName = "ChristianaWhite";
				attributesTitle.fontName = "ChristianaWhite";
				immunitiesTitle.fontName = "ChristianaWhite";
				
				for each(var textField:TextField in attributesTextsFields){
					textField.fontName = "ChristianaWhite";
				}
				
				for each(textField in immunitiesTextFields){
					textField.fontName = "ChristianaWhite";
				}
				
				y = 0;
			}
			else if (skin == "Light") {
				sephiusTitle.fontName = "ChristianaBlack";
				essensikaLevelTitle.fontName = "ChristianaBlack";
				levelText.fontName = "ChristianaBlack";
				essensikaTotalText.fontName = "ChristianaBlack";
				attributesTitle.fontName = "ChristianaBlack";
				immunitiesTitle.fontName = "ChristianaBlack";
				
				for each(textField in attributesTextsFields){
					textField.fontName = "ChristianaBlack";
				}
				
				for each(textField in immunitiesTextFields){
					textField.fontName = "ChristianaBlack";
				}
				
				y = 15;
			}
			
			for each(var divisor:Image in vDivisors){
				divisor.texture = GameEngine.assets.getTexture("Menu_" + skin + "Divisor");
			}
			
			for each(divisor in hDivisors){
				divisor.texture = GameEngine.assets.getTexture("Menu_" + skin + "DivisorH");
			}
			
			for (var nature:String in immunitiesSymbols){
				immunitiesSymbols[nature].texture = GameEngine.assets.getTexture("SpellIcon_" + skin + nature);
			}
		}
		
		override public function dispose():void {
			super.dispose();
			menuStatue.dispose();
			sephiusAvatarGroup.removeChildren(0, -1, true);
			attributesTextsGroup.removeChildren(0, -1, true);
			attributesGroup.removeChildren(0, -1, true);
			immunitiesTextsGroup.removeChildren(0, -1, true);
			immunitiesGroup.removeChildren(0, -1, true);
			for each(var containers:Sprite in immunitiesContainers){
				containers.removeChildren(0, -1, true);
			}
			for each(var symbols:Image in immunitiesSymbols){
				symbols.dispose();
			}
			for each(var textField:TextField in immunitiesTextFields){
				textField.dispose();
			}
		}
	}
}