package SephiusEngine.userInterfaces {

	import SephiusEngine.Languages.LanguageManager;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.input.InputActionsNames;
	import SephiusEngine.input.maping.KeyboardActionMap;
	import SephiusEngine.userInterfaces.components.HelpSprite;

	import com.greensock.TweenMax;

	import starling.display.Image;
	import starling.display.Sprite;
	import starling.extensions.brinkbit.fullscreenscreenextension.FullScreenExtension;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	import tLotDClassic.GameData.Properties.HelpProperties;
	import tLotDClassic.gameObjects.characters.Sephius;

    /** Construc and show help message ingame. Help message are special due the fact 
     * they show not only texts but also buttoms icons.
     * Help text should be writen in a certain patern in order for the system to 
     * parse and construc the final display object with the message.
     * @autor Fernando Rabello
     */
	public class HelpUI extends Sprite{
        private static var _tMessageTextPool:Vector.<TextField> = new Vector.<TextField>();
        private static var _tMessageImagePool:Vector.<Image> = new Vector.<Image>();

        public var helpMessageOnScreen:Boolean;

		public var inGameHelpSprite:HelpSprite = new HelpSprite(GameEngine.assets.getTexture("Hud_DenseBigDecal"));
		public var menuHelpSprite:HelpSprite = new HelpSprite(GameEngine.assets.getTexture("Hud_DenseBigDecal"), "Dark");
		public var helpSectionHelpSprite:HelpSprite = new HelpSprite(GameEngine.assets.getTexture("Hud_DenseBigDecal"));

		public var videoHelpSprite:HelpSprite = new HelpSprite(GameEngine.assets.getTexture("Hud_DenseBigDecal"), "Dark");

        private var _player:Sephius;

        public var currentHelpProperties:HelpProperties;
        public var currentHelpSectionProperties:HelpProperties;
        public var currentMenuHelpProperties:HelpProperties;
		
        public var currentVideoHelpProperties:HelpProperties;

        private var _skin:String = "Light";
		/**Name of the skin HUD currently used */
		public function get skin():String {return _skin;}
		public function set skin(value:String):void {
			if(value == _skin)
				return;

            _skin = value;

            var massage:Object;
			if(inGameHelpSprite.onScreen){
				inGameHelpSprite.skinImage.color = _skin == "Light" ? 0xffffff : 0x000000;
				//For each item added same time this add a correponded art and move elements to right.
				for each (massage in inGameHelpSprite.helpTexts) {
					if(massage as TextField){
						(massage as TextField).color = _skin == "Light" ? 0xffffff : 0x000000;
						(massage as TextField).fontName = skin == "Light" ? "ChristianaWhite" : "ChristianaBlack";
					}
				}
			}
        }
        
        public function updateLang(langID:String):void{
            var massage:Object;

            constructHelpContainer(inGameHelpSprite, currentHelpProperties);
            constructHelpContainer(menuHelpSprite, HelpProperties.HELP_HELP_MENU);
        }

        public function HelpUI(player:Sephius){
            _player = player;
            LanguageManager.ON_LANG_CHANGED.add(updateLang);
        }


		/** Show help message in menu. on buttom of the screen*/
		public function showMenuHelpMessage(properties:HelpProperties):HelpSprite {
			currentMenuHelpProperties = properties;
			constructHelpContainer(menuHelpSprite, properties, false, 20, "Dark");
			menuHelpSprite.onScreen = true;
			return menuHelpSprite;
		}

		/** Show help message in menu  elp section*/
		public function showHelpSectionHelpMessage(properties:HelpProperties):HelpSprite {
			currentHelpSectionProperties = properties;
			constructHelpContainer(helpSectionHelpSprite, currentHelpSectionProperties, true, 20, _skin);
			helpSectionHelpSprite.onScreen = true;
			return helpSectionHelpSprite;
		}
		
		/** Show help message in game on the middle of the screen*/
		public function showIngameHelpMessage(properties:HelpProperties, autoHide:Boolean=true):void {
			currentHelpProperties = properties;
            constructHelpContainer(inGameHelpSprite, properties, false, 20, _skin);

			addChild(inGameHelpSprite);

			inGameHelpSprite.y = FullScreenExtension.stageHeight - 300;

			inGameHelpSprite.onScreen = true;

			_player.archivemnets.setHelpAsListined(currentHelpProperties.varName);

			inGameHelpSprite.alpha = 0;
			TweenMax.to(inGameHelpSprite, 1, { startAt:{alpha:0}, alpha:1 } );

			if(autoHide)
				TweenMax.delayedCall(5, hideHelpMessage, [inGameHelpSprite]);
			
			helpMessageOnScreen = true;
		}	

		public function hideHelpMessage(helpSprite:HelpSprite):void{
			TweenMax.to(inGameHelpSprite, 2, { alpha:0 } );
			TweenMax.delayedCall(2, descontructHelpMessage, [helpSprite]);
		}

        public static function constructHelpContainer(helpSprite:HelpSprite, properties:HelpProperties, breakLines:Boolean = false, fontSize:Number=25, skin:String=""):void{
			if (helpSprite.onScreen)
				descontructHelpMessage(helpSprite);

			helpSprite.unflatten();

			// Can be null if no help message was previously shown.
			if (!properties)
				return;
			
			var player:Sephius = GameEngine.instance.state.mainPlayer;
			if(!player)
				return;

            var deviceSufix:String;
			var deviceType:String = player.inputWatcher.gameDevices.length > 0 ? "GamePad" : "Keyboard";

            if(!properties.deviceExceptions)
				deviceSufix = "";
			else {
				if(deviceType == "Keyboard")
					deviceSufix =  "_KEYBOARD";
				else if(deviceType == "GamePad")
					deviceSufix =  "_GAMEPAD";
				else 
 					throw Error ("No device informed to show device exception help.");	
			}
			
            var message:String = LanguageManager.getSimpleLang("HelpElements", properties.varName + deviceSufix).name;
			var splitedPart:String;
			//First we divide the text in lines
			var tMessageLinesSplited:Array = message.split("\n"); 

            var tMessagesSpliteds:Vector.<Array> = new Vector.<Array>();
            var tMessageSplited:Array = [];

			for each(splitedPart in tMessageLinesSplited){
				//For each line we divide the text by the "|" identifer to find the buttoms
				tMessagesSpliteds.push(splitedPart.split("|"));
			}

			var mPiecesSplitLenght:int;

			var mi:int = 0;
			var isArrow:Boolean;
			var messageTextPiece:TextField;
			var messageImagePiece:Image;

			var offX:Number = 0;
			var offY:Number = 0;
			var finalWidth:Number = 0;

			for each(tMessageSplited in tMessagesSpliteds) {//Each Line
				mPiecesSplitLenght = tMessageSplited.length;
				offX = 0;

				for (mi = 0; mi < mPiecesSplitLenght; mi++) {//Each piece
					//Icon identifier
					if (tMessageSplited[mi].charAt(0) == "[") {
						tMessageSplited[mi] = tMessageSplited[mi].slice(1, tMessageSplited[mi].length);
						isArrow = (tMessageSplited[mi] == InputActionsNames.LEFT || tMessageSplited[mi] == InputActionsNames.RIGHT);
						
						if (_tMessageImagePool.length == 0){
							messageImagePiece = new Image(GameEngine.assets.getTexture("DeviceButtoms_PS4Circle"));
						}
						else{
							messageImagePiece = _tMessageImagePool.pop();
						}
						
						if (player.inputWatcher.gameDevices.length > 0)
							messageImagePiece.texture = GameEngine.assets.getTexture("DeviceButtoms_" + player.inputWatcher.deviceButtomsName + player.inputWatcher.currentMap[tMessageSplited[mi]]);	
						else 
							messageImagePiece.texture = GameEngine.assets.getTexture("DeviceButtoms_" + player.inputWatcher.deviceButtomsName + KeyboardActionMap.keyNamesFromCode[KeyboardActionMap.CURRENT[tMessageSplited[mi]]]);	
						
						messageImagePiece.readjustSize();
						messageImagePiece.alignPivot(((isArrow && player.inverted) ? HAlign.RIGHT : HAlign.LEFT), HAlign.CENTER);
						messageImagePiece.scaleX = .75 * ((isArrow && player.inverted) ? -1 : 1);
						messageImagePiece.scaleY = .75;

						helpSprite.helpImages.push(messageImagePiece);
						helpSprite.helpContents.push(messageImagePiece);

						helpSprite.helpContainer.addChild(messageImagePiece);

						messageImagePiece.x = offX;
						messageImagePiece.y = offY;
						offX += messageImagePiece.width;
					}
					//Text Field
					else {
						if (_tMessageTextPool.length == 0){
							messageTextPiece = createTextField(breakLines, fontSize);
						}
						else{
							messageTextPiece = _tMessageTextPool.pop();
						}
						
						var cskin:String = skin != "" ? skin : player.presence.placeNature;

						messageTextPiece.text = tMessageSplited[mi];
						messageTextPiece.fontSize = fontSize;
						messageTextPiece.color = cskin == "Light" ? 0xffffff : 0xffffff;
						messageTextPiece.fontName = cskin == "Light" ?  "ChristianaBlack" : "ChristianaWhite";

						helpSprite.helpTexts.push(messageTextPiece);
						helpSprite.helpContents.push(messageTextPiece);

						helpSprite.helpContainer.addChild(messageTextPiece);

						messageTextPiece.x = offX;
						messageTextPiece.y = offY;
						offX += messageTextPiece.width;
					}

					offX += 5;
				}

				offX = 0;
				offY += 30;
			}
			
			//helpSprite.skin.x = (offX * .5);
			helpSprite.skinImage.width = helpSprite.helpContainer.width + 250;
			helpSprite.skinImage.height = helpSprite.helpContainer.height + 50;
			helpSprite.skinImage.color = cskin == "Light" ? 0xffffff : 0x000000;

			if (!breakLines){
				helpSprite.x = (FullScreenExtension.stageWidth / 2);
				helpSprite.helpContainer.alignPivot(HAlign.CENTER, VAlign.CENTER);
			}

			helpSprite.flatten();
        }

		private static function descontructHelpMessage(helpSprite:HelpSprite):void {
			TweenMax.killTweensOf(helpSprite);
			TweenMax.killDelayedCallsTo(descontructHelpMessage);
			
			while (helpSprite.helpImages.length > 0) {
				helpSprite.helpContainer.removeChild(helpSprite.helpImages[helpSprite.helpImages.length -1]);
				_tMessageImagePool.push(helpSprite.helpImages.pop());
			}

			while (helpSprite.helpTexts.length > 0) {
				helpSprite.helpContainer.removeChild(helpSprite.helpTexts[helpSprite.helpTexts.length -1]);
				_tMessageTextPool.push(helpSprite.helpTexts.pop());
			}
			
			helpSprite.helpContainer.removeChildren(0, -1);

			helpSprite.helpContents.length = 0;

			helpSprite.removeFromParent();

			helpSprite.onScreen = false;
		}

		private static var _helpTextField:TextField;
		private static function createTextField(breakLines:Boolean, fontSize:Number):TextField {
			_helpTextField = new TextField(50, 50, "", "ChristianaWhite", fontSize, 0xffffff, true);
			_helpTextField.autoSize = TextFieldAutoSize.HORIZONTAL;
			_helpTextField.pivotY = _helpTextField.height / 2;
			return _helpTextField;
		}

        public function destroy():void{
            descontructHelpMessage(inGameHelpSprite);
            descontructHelpMessage(menuHelpSprite);

            inGameHelpSprite.dispose();
			menuHelpSprite.dispose();

			var messageTextPiece:TextField;
			var messageImagePiece:Image;

			for each (messageTextPiece in _tMessageTextPool){
				messageTextPiece.dispose();
			}
			for each (messageImagePiece in _tMessageImagePool){
				messageImagePiece.dispose();
			}

			_tMessageTextPool.length = 0;
			_tMessageImagePool.length = 0;

            LanguageManager.ON_LANG_CHANGED.remove(updateLang);
        }
    }
}