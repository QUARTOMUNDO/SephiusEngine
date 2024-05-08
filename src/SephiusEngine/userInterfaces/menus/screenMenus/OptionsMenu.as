package SephiusEngine.userInterfaces.menus.screenMenus {
	import SephiusEngine.Languages.LanguageManager;
	import SephiusEngine.core.levelManager.GameOptions;
	import SephiusEngine.input.InputActionsNames;
	import SephiusEngine.userInterfaces.UserInterfaces;
	import SephiusEngine.userInterfaces.components.menus.ScreenMenuComponent;
	import SephiusEngine.userInterfaces.components.menus.menuItens.ScreenMenuItem;
	import SephiusEngine.userInterfaces.menus.ScreenMenu;
	import SephiusEngine.utils.GraphicQualities;
	import SephiusEngine.utils.GraphicResolutions;

	import starling.display.DisplayObject;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import SephiusEngine.core.GameData;
	
	/**
	 * Menu witch shows game options
	 * NEED TO IMPLEMENT A SAVE SYSTEM FOR THIS
	 * @author Fernando Rabello
	 */
	public class OptionsMenu extends ScreenMenu {
		public var gamePlayMenu:ScreenMenuComponent;
		public var audioPlayMenu:ScreenMenuComponent;
		public var graphicPlayMenu:ScreenMenuComponent;
		public var effectsPlayMenu:ScreenMenuComponent;

		public function OptionsMenu(pack:String) {
			var title:String = LanguageManager.getSimpleLang("OptionsMenuElements", "GAME OPTIONS").name;
			titleText = new TextField(500, 65, title, "ChristianaWhite", 40, 0xffffff, true);
			titleText.touchable = false;

			rootMenu = new ScreenMenuComponent(Vector.<Array>(
			//Game Play
			[["LANGUAGE", ["LANGUAGE"]],
			["KEYBOARD LAYOUT", ["QWERTY", "QUERTZ", "AZERTY"]],
			["SHOW COMBAT INFORMATION", ["YES", "NO"]],
			["CAMERA MOVEMENT INTENSITY", ["0", "20", "40", "60", "80", "100"]], 
			["CAMERA ASSIST INTENSITY", ["0", "20", "40", "60", "80", "100"]], 
			["GAME DIFFICULTY", ["VERY EASY", "EASY", "NORMAL", "HARD", "VERY HARD", "HIT KILL"]], 

			//Audio
			["SOUND FX VOLUME", ["0", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100"]], 
			["MUSIC VOLUME", ["0", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100"]],
			["NARRATOR VOLUME", ["0", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100"]],

			//Graphics
			["WINDOW MODE", ["FULLSCREEN", "WINDOWED"]], 
			["RENDER RESOLUTION", [GraphicResolutions.RENDER_DOUBLE, GraphicResolutions.RENDER_UNCHANGED, GraphicResolutions.RENDER_HALF, GraphicResolutions.RENDER_FOURTH]], 
			["SCREEN RESOLUTION", [GraphicResolutions.SCREEN_DOUBLE, GraphicResolutions.SCREEN_UNCHANGED, GraphicResolutions.SCREEN_HALF, GraphicResolutions.SCREEN_FOURTH]], 
			["ANTI ALAISING", [GraphicQualities.ANTI_ALAISING_0, GraphicQualities.ANTI_ALAISING_2, GraphicQualities.ANTI_ALAISING_4, GraphicQualities.ANTI_ALAISING_8, GraphicQualities.ANTI_ALAISING_16]], 
			
			//Effects
			["DISABLE ALL EFFECTS", ["YES", "NO"]], 
			["NOISE EFFECT", ["ENABLED", "DISABLED"]], 
			["BLUR EFFECT", ["ENABLED", "DISABLED"]], 
			["DISABLE DOF EFFECT", ["ENABLED", "DISABLED"]], 
			["ENVIROMENTAL EFFECTS", ["ENABLED", "DISABLED"]],
			["SEPHIUS ART", ["ADVANCED", "LEGACY"]]]), 
			
			this, pack, ["Mestizo", "Mestizo"], "OptionsMenuElements");
			
			super(pack);
			
			this.addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		private var hmenuItem:ScreenMenuItem;
		override public function show(skin:String = "Light"):void {
			super.show(skin);
			
			for each(hmenuItem in rootMenu.menuItens) {
				switch(hmenuItem.itemID) {
					case "LANGUAGE" : 
						hmenuItem.currentState = hmenuItem.states.indexOf(GameOptions.LANGUAGE);
					break;
					case "KEYBOARD LAYOUT" :
						hmenuItem.currentState = GameOptions.KEYBOARD_LAYOUT == "QWERTY" ? 0 : (GameOptions.KEYBOARD_LAYOUT == "QWERTZ" ? 1 : 2);
						break;
					case "SHOW COMBAT INFORMATION" : 
						hmenuItem.currentState = GameOptions.DISABLE_COMBAT_INFORMATION ? 1 : 0;
						break;
					case "CAMERA MOVEMENT INTENSITY" : 
						hmenuItem.currentState = ((GameOptions.CAMERA_MOVEMENT_INTENSITY) / 10) / 2;
						break;
					case "CAMERA ASSIST INTENSITY" : 
						hmenuItem.currentState = ((GameOptions.CAMERA_ASSIST_INTENSITY) / 10) / 2;
						break;
					case "GAME DIFFICULTY" : 
						hmenuItem.currentState = GameOptions.GAME_DIFFICULTY;
						break;
					case "NARRATOR VOLUME" :
						hmenuItem.currentState = (GameOptions.NARRATOR_VOLUME / 10);
						break;
					case "SOUND FX VOLUME" : 
						hmenuItem.currentState = (GameOptions.SOUNDS_FX_VOLUME / 10);
						break;
					case "MUSIC VOLUME" : 
						hmenuItem.currentState = (GameOptions.MUSIC_VOLUME / 10);
						break;
					case "WINDOW MODE":
						if (GameOptions.WINDOW_MODE == GameOptions.WINDOW_MODE_FULLSCREEN)
							hmenuItem.currentState = 0;
						else if (GameOptions.WINDOW_MODE = GameOptions.WINDOW_MODE_WINDOWED)
							hmenuItem.currentState = 1;
						break;
					case "GRAPHIC RESOLUTION" : 
						if (GameOptions.GRAPHIC_RESOLUTION == GraphicResolutions.RENDER_DOUBLE)
							hmenuItem.currentState = 0;
						else if (GameOptions.GRAPHIC_RESOLUTION == GraphicResolutions.RENDER_UNCHANGED)
							hmenuItem.currentState = 1;
						else if (GameOptions.GRAPHIC_RESOLUTION == GraphicResolutions.RENDER_HALF)
							hmenuItem.currentState = 2;
						else if (GameOptions.GRAPHIC_RESOLUTION == GraphicResolutions.RENDER_FOURTH)
							hmenuItem.currentState = 3;
						break;
					case "SCREEN RESOLUTION" : 
						if (GameOptions.SCREEN_RESOLUTION == GraphicResolutions.SCREEN_DOUBLE)
							hmenuItem.currentState = 0;
						else if (GameOptions.SCREEN_RESOLUTION == GraphicResolutions.SCREEN_UNCHANGED)
							hmenuItem.currentState = 1;
						else if (GameOptions.SCREEN_RESOLUTION == GraphicResolutions.SCREEN_HALF)
							hmenuItem.currentState = 2;
						else if (GameOptions.SCREEN_RESOLUTION == GraphicResolutions.SCREEN_FOURTH)
							hmenuItem.currentState = 3;
						break;
					case "ANTI ALAISING" : 
						if (GameOptions.ANTI_ALAISING == GraphicQualities.ANTI_ALAISING_0)
							hmenuItem.currentState = 0;
						else if (GameOptions.ANTI_ALAISING == GraphicQualities.ANTI_ALAISING_2)
							hmenuItem.currentState = 1;
						else if (GameOptions.ANTI_ALAISING == GraphicQualities.ANTI_ALAISING_4)
							hmenuItem.currentState = 2;
						else if (GameOptions.ANTI_ALAISING == GraphicQualities.ANTI_ALAISING_8)
							hmenuItem.currentState = 3;
						else if (GameOptions.ANTI_ALAISING == GraphicQualities.ANTI_ALAISING_16)
							hmenuItem.currentState = 4;
						break;
					case "NOISE EFFECT" : 
						if (GameOptions.DISABLE_NOISE_EFFECT)
							hmenuItem.currentState = 1;
						else
							hmenuItem.currentState = 0;
						break;
					case "DISABLE ALL EFFECTS" : 
						if (GameOptions.DISABLE_ALL_EFFECTS)
							hmenuItem.currentState = 0;
						else
							hmenuItem.currentState = 1;
						break;
					case "BLUR EFFECT" : 
						if (GameOptions.DISABLE_DOF_EFFECT)
							hmenuItem.currentState = 1;
						else
							hmenuItem.currentState = 0;
						break;
					case "ENVIROMENTAL EFFECTS" : 
						if (GameOptions.DISABLE_ENVIROMENTAL_EFFECTS)
							hmenuItem.currentState = 1;
						else
							hmenuItem.currentState = 0;
						break;
					case "SEPHIUS ART" : 
						if (GameOptions.LEGACY_SEPHIUS)
							hmenuItem.currentState = 1;
						else
							hmenuItem.currentState = 0;
						break;
				}
			}
		}
		
		private var stateChangeOnHoldTime:Number = 0;
		private var stateChangeOnHoldResetTime:Number = 50;

		private var stateChangeOnHoldMaxTime:Number = 30;
		private var stateChangeOnHoldMinTime:Number = 10;

		override public function update():void {
			super.update();		
			
			//Pressing confirm buttom
			if (UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_CONFIRM)) {
				if(rootMenu.index != -1){
					rootMenu.selectecItem.currentState = (rootMenu.selectecItem.currentState + 1) % rootMenu.selectecItem.states.length;
					applySelection(rootMenu.selectecItem.itemID);
					soundComponent.play("UI_interface_enterAccept", "UI");
				}
			}

			//First press left or right always triggers
			if (UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_LEFT) || UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_RIGHT)){
				if(rootMenu.index != -1){
					if(UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_LEFT))
						rootMenu.selectecItem.previousState();
					else
						rootMenu.selectecItem.nextState();

					applySelection(rootMenu.selectecItem.itemID);
					soundComponent.play("UI_interface_enterAccept", "UI");
				}

				//Resets rate count down rate. So it will have initial rate when player start to press again
				stateChangeOnHoldResetTime = stateChangeOnHoldMaxTime;
				stateChangeOnHoldTime = stateChangeOnHoldResetTime;
			}

			//Holding buttom, trigger at some rate. This rate will increase over time gradually
			else if(stateChangeOnHoldTime <= 0){
				if (UserInterfaces.instance.inputWatcher.isDoing(InputActionsNames.INTERFACE_LEFT) || UserInterfaces.instance.inputWatcher.isDoing(InputActionsNames.INTERFACE_RIGHT)) {
					if(UserInterfaces.instance.inputWatcher.isDoing(InputActionsNames.INTERFACE_LEFT))
						rootMenu.selectecItem.previousState();
					else
						rootMenu.selectecItem.nextState();

					if(rootMenu.index != -1){
						applySelection(rootMenu.selectecItem.itemID);
						soundComponent.play("UI_interface_enterAccept", "UI");
					}

					//Trigger time decreases over time so rate will be faster
					if(stateChangeOnHoldResetTime > stateChangeOnHoldMinTime)
						stateChangeOnHoldResetTime *= 0.6;
						
					stateChangeOnHoldTime = stateChangeOnHoldResetTime;
				}
			}

			//Trigger rate.
			if(stateChangeOnHoldTime > 0)
				stateChangeOnHoldTime--;

		}
		
		private function onTouch(event:TouchEvent):void {
			if (UserInterfaces.instance.holdMenus)
				return;
			
			var touch:Touch = event.getTouch((event.target as DisplayObject).parent.parent);
			if (touch) {
				var menuItem:ScreenMenuItem = (event.target as DisplayObject).parent as ScreenMenuItem
				
				if(touch.phase == TouchPhase.HOVER){
					rootMenu.index = rootMenu.menuItens.indexOf(menuItem);
				}
				else if (touch.phase == TouchPhase.BEGAN){
					if(rootMenu.index != -1)
						soundComponent.play("UI_interface_enterAccept", "UI");
					
					menuItem.currentState = (menuItem.currentState + 1) % menuItem.states.length;	
					applySelection(menuItem.itemID)
				}
			}
		}
		
		private function applySelection(optionName:String):void {
			if(!rootMenu.selectecItem)
				return;
				
			var stateID:String = rootMenu.selectecItem.currentStateID;
			switch(optionName) {
				case "SHOW COMBAT INFORMATION" : 
					switch(rootMenu.selectecItem.currentStateID) {
						case "YES":
							GameOptions.DISABLE_COMBAT_INFORMATION = false;
							break;
						case "NO":
							GameOptions.DISABLE_COMBAT_INFORMATION = true;
							break;
					}
					break;
				case "CAMERA MOVEMENT INTENSITY" : 
					GameOptions.CAMERA_MOVEMENT_INTENSITY = (int(stateID));
					break;
				case "CAMERA ASSIST INTENSITY" : 
					GameOptions.CAMERA_ASSIST_INTENSITY = (int(stateID));
					break;
				case "GAME DIFFICULTY" : 
					GameOptions.GAME_DIFFICULTY = rootMenu.selectecItem.currentState;
					break;


				case "LANGUAGE" : 
					GameOptions.LANGUAGE = rootMenu.selectecItem.currentStateID;
					break;
				case "KEYBOARD LAYOUT" :
					GameOptions.KEYBOARD_LAYOUT = rootMenu.selectecItem.currentState == 0 ? "QWERTY" : (rootMenu.selectecItem.currentState == 1 ? "QWERTZ" : "AZERTY");
					break;
				case "SOUND FX VOLUME" : 
					GameOptions.SOUNDS_FX_VOLUME = (int(stateID));
					break;
				case "MUSIC VOLUME" : 
					GameOptions.MUSIC_VOLUME = (int(stateID));
					break;
				case "NARRATOR VOLUME" : 
					GameOptions.NARRATOR_VOLUME = (int(stateID));
					break;


				case "WINDOW MODE":
					switch(rootMenu.selectecItem.currentStateID) {
						case "FULLSCREEN":
							GameOptions.WINDOW_MODE = GameOptions.WINDOW_MODE_FULLSCREEN;
							break;
						case "WINDOWED":
							GameOptions.WINDOW_MODE = GameOptions.WINDOW_MODE_WINDOWED;
							break;
					}
					break;
				case "GRAPHIC RESOLUTION" : 
					switch(rootMenu.selectecItem.currentStateID) {
						case GraphicResolutions.RENDER_DOUBLE:
							GameOptions.GRAPHIC_RESOLUTION = GraphicResolutions.RENDER_DOUBLE;
							break;
						case GraphicResolutions.RENDER_UNCHANGED:
							GameOptions.GRAPHIC_RESOLUTION = GraphicResolutions.RENDER_UNCHANGED;
							break;
						case GraphicResolutions.RENDER_HALF:
							GameOptions.GRAPHIC_RESOLUTION = GraphicResolutions.RENDER_HALF;
							break;
						case GraphicResolutions.RENDER_FOURTH:
							GameOptions.GRAPHIC_RESOLUTION = GraphicResolutions.RENDER_FOURTH;
							break;
					}
					break;
				case "SCREEN RESOLUTION" : 
					switch(rootMenu.selectecItem.currentStateID) {
						case GraphicResolutions.SCREEN_DOUBLE:
							GameOptions.SCREEN_RESOLUTION = GraphicResolutions.SCREEN_DOUBLE;
							break;
						case GraphicResolutions.SCREEN_UNCHANGED:
							GameOptions.SCREEN_RESOLUTION = GraphicResolutions.SCREEN_UNCHANGED;
							break;
						case GraphicResolutions.SCREEN_HALF:
							GameOptions.SCREEN_RESOLUTION = GraphicResolutions.SCREEN_HALF;
							break;
						case GraphicResolutions.SCREEN_FOURTH:
							GameOptions.SCREEN_RESOLUTION = GraphicResolutions.SCREEN_FOURTH;
							break;
					}
					break;
				case "ANTI ALAISING" : 
					switch(rootMenu.selectecItem.currentStateID) {
						case GraphicQualities.ANTI_ALAISING_0.toFixed():
							GameOptions.ANTI_ALAISING = GraphicQualities.ANTI_ALAISING_0;
						break;
						case GraphicQualities.ANTI_ALAISING_2.toFixed():
							GameOptions.ANTI_ALAISING = GraphicQualities.ANTI_ALAISING_2;
						break;
						case GraphicQualities.ANTI_ALAISING_4.toFixed():
							GameOptions.ANTI_ALAISING = GraphicQualities.ANTI_ALAISING_4;
						break;
						case GraphicQualities.ANTI_ALAISING_8.toFixed():
							GameOptions.ANTI_ALAISING = GraphicQualities.ANTI_ALAISING_8;
						break;
						case GraphicQualities.ANTI_ALAISING_16.toFixed():
							GameOptions.ANTI_ALAISING = GraphicQualities.ANTI_ALAISING_16;
						break;
					}
					break;
				case "DISABLE ALL EFFECTS" : 
					switch(rootMenu.selectecItem.currentStateID) {
						case "YES":
							GameOptions.DISABLE_ALL_EFFECTS = true;
							break;
						case "NO":
							GameOptions.DISABLE_ALL_EFFECTS = false;
							break;
					}
					break;
				case "NOISE EFFECT" : 
					switch(rootMenu.selectecItem.currentStateID) {
						case "ENABLED":
							GameOptions.DISABLE_NOISE_EFFECT = false;
							break;
						case "DISABLED":
							GameOptions.DISABLE_NOISE_EFFECT = true;
							break;
					}
					break;
				case "BLUR EFFECT" : 
					switch(rootMenu.selectecItem.currentStateID) {
						case "ENABLED":
							GameOptions.DISABLE_DOF_EFFECT = false;
							break;
						case "DISABLED":
							GameOptions.DISABLE_DOF_EFFECT = true;
							break;
					}
					break;
				case "ENVIROMENTAL EFFECTS" : 
					switch(rootMenu.selectecItem.currentStateID) {
						case "ENABLED":
							GameOptions.DISABLE_ENVIROMENTAL_EFFECTS = false;
							break;
						case "DISABLED":
							GameOptions.DISABLE_ENVIROMENTAL_EFFECTS = true;
							break;
					}
					break;
				case "SEPHIUS ART" : 
					switch(rootMenu.selectecItem.currentStateID) {
						case "ADVANCED":
							GameOptions.LEGACY_SEPHIUS = false;
							break;
						case "LEGACY":
							GameOptions.LEGACY_SEPHIUS = true;
							break;
					}
					break;
			}
		}

		override public function hide():void{
			super.hide();
			GameData.getInstance().saveGameOptions();
		}
	}
}