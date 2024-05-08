package SephiusEngine.userInterfaces.components.contents.subContents {
	import SephiusEngine.core.GameAssets;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.gameStates.LevelManager;
	import SephiusEngine.input.InputActionsNames;
	import SephiusEngine.input.maping.KeyboardActionMap;
	import SephiusEngine.userInterfaces.components.contents.SubContentComponent;

	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	import tLotDClassic.GameData.Properties.HelpProperties;
	import tLotDClassic.gameObjects.characters.Sephius;
	import SephiusEngine.userInterfaces.components.HelpSprite;
	import SephiusEngine.userInterfaces.UserInterfaces;
	import SephiusEngine.Languages.LanguageManager;
	
	/**
	 *  Content for Memo screen on game menu
	 * @author ...
	 */
	public class HelpSubContentComponent extends SubContentComponent {
		private var	image:Image;
		private var nameTitle:TextField = new TextField(50, 50, "Halugarde", "ChristianaBlack", 32, 0xffffff, true);
		//private var descriptionText:TextField = new TextField(750, 400, "Last words left by Kanpheyro...?! The hatred and sorrow can turn us into terrible things...Last words left by Kanpheyro...?! The hatred and sorrow can turn us into terrible things...Last words left by Kanpheyro...?! The hatred and sorrow can turn us into terrible things...", "ChristianaBlack", 20, 0xffffff, true);
		private var descriptionGroup:Sprite =  new Sprite();
		
		private var currentProperty:HelpProperties;
		
		public function HelpSubContentComponent() {
			super();
			this.touchable = false;
			
			//Description Group
			nameTitle.autoSize = TextFieldAutoSize.HORIZONTAL;
			nameTitle.alignPivot(HAlign.LEFT, VAlign.CENTER);
			nameTitle.x = 0;
			nameTitle.y = -40;
			
			/*
			descriptionText.alignPivot(HAlign.LEFT, VAlign.TOP);
			descriptionText.hAlign = HAlign.LEFT;
			descriptionText.vAlign = VAlign.TOP;
			descriptionText.x = nameTitle.x;
			descriptionText.y = 270 + 25;
			*/
			
			descriptionGroup.addChild(nameTitle);
			//descriptionGroup.addChild(descriptionText);
			
			descriptionGroup.x = -130;
			descriptionGroup.y = 270 + 25;
			
			addChild(descriptionGroup);
		}
		
		private var texName:String; 
		override public function setContent(content:Object):void {
			super.setContent(content);
			
			if(assets.rawAssetsGroups["info"]){
				assets.removeGroup("info");
				assets.purge();
			}
			
			currentProperty = content as HelpProperties;
			
			texName = "";
			var devicePartN:String = "";
			var worldPartN:String = "";
			var mode:String = "";
			
			if (currentProperty.imgDeviceExceptions)
				devicePartN = LevelManager.getInstance().mainPlayer.inputWatcher.deviceButtomsName;
			
			if(currentProperty.worldOriginExceptions)
				worldPartN = skin ? skin : LevelManager.getInstance().mainPlayer.presence.placeNature;
			
			if (currentProperty == HelpProperties.HELP_CONTROLS )
				mode = "ModeB";
			
			texName = "Help_" + worldPartN + currentProperty.objectBaseName + devicePartN + mode;
			
			//assets.verbose = true;
			
			assets.enqueueAsGroup("info", GameAssets.texturesPath.resolvePath("interfaces").resolvePath("help").resolvePath(texName + ".atf").url);
			assets.loadQueueGroup(onLoadArt, "info");
		}
		
		override public function updateData():void {
			if (!image){
				image = new Image(assets.getTexture(texName));
				image.alignPivot();
				image.x = 230;
				image.y = 40;
				image.scaleX = image.scaleY = .9;
			}
			addChildAt(image, 0);
			image.texture = assets.getTexture(texName);
			
			nameTitle.text = LanguageManager.getSimpleLang("HelpMenuElements", currentProperty.varName).name;

			//descriptionText.text = currentProperty.text;
			var helpSprite:HelpSprite = UserInterfaces.instance.helpUI.showHelpSectionHelpMessage(currentProperty);
			descriptionGroup.addChild(helpSprite);
		}
				
		public var skin:String;
		/** Change Top Menu Component Skin. Propagates trought menu itens changing then skin also */
		override public function changeSkin(skin:String):void {
			this.skin = skin;
			if (skin == "Dark") {
				nameTitle.fontName = "ChristianaWhite";
				//descriptionText.fontName = "ChristianaWhite";
			}
			else if (skin == "Light") {
				nameTitle.fontName = "ChristianaBlack";
				//descriptionText.fontName = "ChristianaBlack";
			}
		}
		
		override public function dispose():void {
			super.dispose();
			//destroyHelpMessage();
			//_tMessageTXPool.length = 0;
			//_tMessageIMGPool.length = 0;
			//tMessageObject.length = 0;
			//tMessageSplitedFinal.length = 0;
			nameTitle.dispose();
			image.dispose();
			currentProperty = null;
		}
	}
}