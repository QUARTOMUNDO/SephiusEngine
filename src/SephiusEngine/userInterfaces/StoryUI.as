 package SephiusEngine.userInterfaces {
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.gameStates.LevelManager;
	import SephiusEngine.input.InputActionsNames;
	import SephiusEngine.input.maping.KeyboardActionMap;

	import com.greensock.TweenMax;
	import com.greensock.easing.Sine;

	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.extensions.brinkbit.fullscreenscreenextension.FullScreenExtension;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	import tLotDClassic.GameData.Properties.StoryTellerProperties;
	
	/**
	 * Show storyteller texts, dialogs and lore texts on screen
	 * @author Fernando Rabello
	 */
	public class StoryUI extends UserInterfaceObject {
		public var _storyTellerContainer	:Sprite = new Sprite();
		public var _storyTellerBContainer	:Sprite = new Sprite();
		public var _storyTellerNextIconC	:Sprite = new Sprite();
		
		public var _storyTellerNextButtom	:Image = new Image(GameEngine.assets.getTexture("DeviceButtoms_PS4L3"));
		public var _storyTellerNextIcon1	:Image = new Image(GameEngine.assets.getTexture("DeviceButtoms_GenericFoward"));
		public var _storyTellerNextIcon2	:Image = new Image(GameEngine.assets.getTexture("DeviceButtoms_GenericFoward"));
		
		private var _storyTellerMessageSkin	:Quad = new Quad(10, 10, 0x000000);
		private var _storyTellerMessageSkin2:Quad = new Quad(10, 10, 0x000000);
		
		private var _storyTellerText		:TextField = new TextField(1000, 50, "", "ChristianaWhite", 40, 0x000000, true);
		
		public var currentID:String = "";

		public function StoryUI() {
			super(UserInterfaces.instance.inputWatcher);
			
			this._storyTellerContainer.touchable = false;
			this._storyTellerContainer.touchable  = false;
		}
		
		override public function update():void {
			super.update();	
			if (LevelManager.getInstance().mainPlayer){
				//skin = LevelManager.getInstance().mainPlayer.presence.placeNature;
			}
		}
		
		override protected function updateInput(): void {
			super.updateInput();
			
			if (onScreen && currentStoryTeller.holdGame && (UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_CONFIRM))) {
				nextStoryTellerPart("");
			}
		}

		//Stops Story UI if it become not visible
		override public function set visible(value:Boolean):void{
			super.visible = value;

			if (value && currentID != ""){
				show(currentID);
			}

			else if (!value && onScreen){
				hide();
			}
		}
		
		public var currentStoryTeller:StoryTellerProperties
		private var cSTIndex:int;
		private var fromIndex:uint=0;

		/** Show show StoryTeller texts in HUD*/
		override public function show(id:String):void {
			super.show(id);

			currentID = id;

			if(!StoryTellerProperties[id])
				throw Error("wrong storyTeller varName / id: " + id);
			
			if (onScreen)
				supressStoryTeller();
			
			currentStoryTeller = StoryTellerProperties[id];
			cSTIndex = fromIndex;
			
			//LevelManager.getInstance().storyTellerSoundComponent.onSoundEnding.add(nextStoryTellerPart);
			nextStoryTellerPart("");
			
			this.addChild(_storyTellerContainer);
			_storyTellerContainer.addChild(_storyTellerText);
			
			if(currentStoryTeller.holdGame){
				_storyTellerContainer.addChild(_storyTellerBContainer);
				TweenMax.to(_storyTellerNextButtom, .36, { delay:.36 , startAt: { scaleX:.55, scaleY:.55 }, scaleX:.45, scaleY:.45, repeat:-1, yoyo:true, ease:Sine.easeInOut } );
				TweenMax.to(_storyTellerNextIconC, .36, { startAt: { x:0 }, x:5, repeat:-1, yoyo:true, ease:Sine.easeInOut } );
				
				if (inputWatcher.deviceButtomsName != "KeyboardBlack")
					_storyTellerNextButtom.texture = GameEngine.assets.getTexture("DeviceButtoms_" + inputWatcher.deviceButtomsName + inputWatcher.currentMap[InputActionsNames.INTERFACE_CONFIRM]);	
				else 
					_storyTellerNextButtom.texture = GameEngine.assets.getTexture("DeviceButtoms_" + inputWatcher.deviceButtomsName + KeyboardActionMap.keyNamesFromCode[KeyboardActionMap.CURRENT[InputActionsNames.INTERFACE_CONFIRM]]);	
				
				_storyTellerNextButtom.readjustSize();
				_storyTellerNextButtom.alignPivot(HAlign.CENTER, HAlign.CENTER);
			}
			
			_storyTellerContainer.alpha = 0;
			_storyTellerText.alpha = 1;
			
			TweenMax.to(_storyTellerContainer, 3, { startAt: { alpha:0 }, alpha:1 } );
			TweenMax.to(_storyTellerBContainer, 3, { startAt: { alpha:0 }, alpha:1 } );
		}		
		
		public function nextStoryTellerPart(soundName:String):void {
			if (!currentStoryTeller)
				return;

			var cTexts:Vector.<String> = currentStoryTeller.getSceneTexts();

			if (cSTIndex >= cTexts.length){
				hide();
				_main.state.mainPlayer.archivemnets.setStoryTellerListined(currentStoryTeller.varName);
				currentID = "";
				fromIndex = 0;
				return;
			}
			
			_storyTellerText.text = cTexts[cSTIndex];
			_storyTellerText.pivotY = _storyTellerText.height / 2;
			_storyTellerText.pivotX = _storyTellerText.width / 2;
			
			LevelManager.getInstance().storyTellerSoundComponent.onSoundEnding.remove(nextStoryTellerPart);
			LevelManager.getInstance().storyTellerSoundComponent.stop("");
			currentStoryTeller.sceneID
			var audioName:String = "ST_" + currentStoryTeller.varName + "_" + cSTIndex;

			LevelManager.getInstance().storyTellerSoundComponent.play(audioName, "STORYTELLER", .6);
			LevelManager.getInstance().storyTellerSoundComponent.onSoundEnding.add(nextStoryTellerPart);
			
			cSTIndex++;
			fromIndex = cSTIndex;
		}
		
		override public function hide():void {
			super.hide();
			
			TweenMax.killTweensOf(_storyTellerText);
			TweenMax.killTweensOf(_storyTellerContainer);
			TweenMax.killTweensOf(_storyTellerBContainer);
			TweenMax.killTweensOf(_storyTellerNextButtom);
			TweenMax.killTweensOf(_storyTellerNextIconC);
			
			TweenMax.to(_storyTellerText, 3, { delay:0, alpha:0} );
			TweenMax.to(_storyTellerBContainer, 3, { delay:0, alpha:0 } );
			TweenMax.to(_storyTellerContainer, 3, { delay:0, alpha:0 } );
			
			TweenMax.delayedCall(3, supressStoryTeller, []);
			
			LevelManager.getInstance().storyTellerSoundComponent.stop("");
		}
		
		public function supressStoryTeller():void {
			TweenMax.killTweensOf(_storyTellerText);
			TweenMax.killTweensOf(_storyTellerContainer);
			TweenMax.killTweensOf(_storyTellerNextIconC);
			TweenMax.killTweensOf(_storyTellerNextButtom);
			TweenMax.killTweensOf(_storyTellerBContainer);
			TweenMax.killDelayedCallsTo(supressStoryTeller);
			
			_storyTellerText.removeFromParent();
			_storyTellerContainer.removeFromParent();
			_storyTellerBContainer.removeFromParent();
			
			LevelManager.getInstance().storyTellerSoundComponent.onSoundEnding.remove(nextStoryTellerPart);
			LevelManager.getInstance().storyTellerSoundComponent.stop("");
		}

		override public function changeDevice(deviceName:String):void{
			if (inputWatcher.deviceButtomsName != "KeyboardBlack")
				_storyTellerNextButtom.texture = GameEngine.assets.getTexture("DeviceButtoms_" + inputWatcher.deviceButtomsName + inputWatcher.currentMap[InputActionsNames.INTERFACE_CONFIRM]);	
			else 
				_storyTellerNextButtom.texture = GameEngine.assets.getTexture("DeviceButtoms_" + inputWatcher.deviceButtomsName + KeyboardActionMap.keyNamesFromCode[KeyboardActionMap.CURRENT[InputActionsNames.INTERFACE_CONFIRM]]);	
			
			_storyTellerNextButtom.readjustSize();
			_storyTellerNextButtom.alignPivot(HAlign.CENTER, HAlign.CENTER);
		}
		
		override public function set skin(value:String):void {
			if (skin == value)
				return; 
			
			super.skin = value;
			
			_storyTellerMessageSkin.color = _skin == "Light" ? 0x000000 : 0x000000;
			_storyTellerMessageSkin2.color = _skin == "Light" ? 0x000000 : 0x000000;
			_storyTellerText.color = skin == "Light" ? 0xffffff : 0xffffff;
			
		}
		
		override public function init(e:*):void {
			super.init(e);	
			
			_storyTellerMessageSkin.setVertexAlpha(0, 0);
			_storyTellerMessageSkin.setVertexAlpha(1, 0);
			
			_storyTellerMessageSkin.alignPivot(HAlign.CENTER, VAlign.BOTTOM);
			_storyTellerMessageSkin2.alignPivot(HAlign.CENTER, VAlign.BOTTOM);
			
			_storyTellerMessageSkin.width = _storyTellerMessageSkin2.width = FullScreenExtension.screenWidth;
			_storyTellerMessageSkin.height = 70;
			_storyTellerMessageSkin2.height = 90;
			_storyTellerMessageSkin.x = _storyTellerMessageSkin2.x = FullScreenExtension.screenLeft + (FullScreenExtension.screenWidth * .5);
			_storyTellerMessageSkin2.y = FullScreenExtension.screenBottom;
			_storyTellerMessageSkin.y = _storyTellerMessageSkin2.y - _storyTellerMessageSkin2.height;
			
			_storyTellerText.fontSize = 25;
			_storyTellerText.text = "";
			_storyTellerText.autoSize = TextFieldAutoSize.HORIZONTAL;
			_storyTellerText.color = 0xffffff;
			_storyTellerText.pivotY = _storyTellerText.height / 2;
			_storyTellerText.pivotX = _storyTellerText.width / 2;
			_storyTellerText.x = FullScreenExtension.screenWidth * .5;
			_storyTellerText.y = _storyTellerMessageSkin2.y - (_storyTellerMessageSkin2.height * .5);
			
			_storyTellerNextButtom.x = 0;
			_storyTellerNextButtom.y = 0;
			_storyTellerNextButtom.scaleX = .5;
			_storyTellerNextButtom.scaleY = .5;
			
			_storyTellerNextIcon1.scaleX = .5;
			_storyTellerNextIcon1.scaleY = .5;
			_storyTellerNextIcon1.x = -((_storyTellerNextButtom.width * .5) + (_storyTellerNextIcon1.width * .5) - 5);
			_storyTellerNextIcon1.y = 0;
			_storyTellerNextIcon1.alignPivot();
			
			_storyTellerNextIcon2.scaleX = .5;
			_storyTellerNextIcon2.scaleY = .5;
			_storyTellerNextIcon2.x = _storyTellerNextIcon1.x - (_storyTellerNextIcon1.width * .5) - (_storyTellerNextIcon2.width * .5) + 18;
			_storyTellerNextIcon2.y = _storyTellerNextIcon1.y;
			_storyTellerNextIcon2.alignPivot();
			
			_storyTellerNextIconC.x = 5;
			_storyTellerNextIconC.scaleX = -.75;
			_storyTellerNextIconC.scaleY = .75;
			
			_storyTellerNextIconC.addChild(_storyTellerNextIcon1);
			_storyTellerNextIconC.addChild(_storyTellerNextIcon2);
			
			_storyTellerBContainer.addChild(_storyTellerNextButtom);
			_storyTellerBContainer.addChild(_storyTellerNextIconC);
			
			_storyTellerBContainer.x = FullScreenExtension.screenWidth * .5;
			_storyTellerBContainer.y = _storyTellerMessageSkin2.y - (_storyTellerMessageSkin2.height * .5) - 50;
			_storyTellerBContainer.pivotX = _storyTellerBContainer.width * .5;
			
			_storyTellerContainer.addChild(_storyTellerMessageSkin2);
			_storyTellerContainer.addChild(_storyTellerMessageSkin);
			_storyTellerContainer.addChild(_storyTellerText);
			_storyTellerContainer.addChild(_storyTellerBContainer);
		}
		
		override public function resize(event:Event):void {
			super.resize(event);
			
			_storyTellerMessageSkin.width = _storyTellerMessageSkin2.width = FullScreenExtension.screenWidth;
			_storyTellerMessageSkin.x = _storyTellerMessageSkin2.x = FullScreenExtension.screenLeft + (FullScreenExtension.screenWidth * .5);
			_storyTellerMessageSkin2.y = FullScreenExtension.screenBottom;
			_storyTellerMessageSkin.y = _storyTellerMessageSkin2.y - _storyTellerMessageSkin2.height;
			
			_storyTellerText.x = _storyTellerMessageSkin.x ;
			_storyTellerText.y = _storyTellerMessageSkin2.y - (_storyTellerMessageSkin2.height * .5);
			
			_storyTellerBContainer.x = FullScreenExtension.screenLeft + FullScreenExtension.screenWidth * .5;
			_storyTellerBContainer.y = _storyTellerMessageSkin2.y - (_storyTellerMessageSkin2.height * .5) - 50;
		}
		
		override public function dispose():void {
			TweenMax.killTweensOf(_storyTellerText);
			TweenMax.killTweensOf(_storyTellerContainer);
			TweenMax.killTweensOf(_storyTellerNextIconC);
			TweenMax.killTweensOf(_storyTellerNextButtom);
			TweenMax.killTweensOf(_storyTellerBContainer);
			TweenMax.killDelayedCallsTo(supressStoryTeller);
			
			var id:String;
			for(id in this) {
				if (this[id] as DisplayObject){
					(this[id] as DisplayObject).removeFromParent(true);
					this[id] = null;
				}
			}	
			Starling.current.stage.removeEventListener(Event.RESIZE, resize);
			super.dispose();
		}
	}
}