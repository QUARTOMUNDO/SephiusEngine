package SephiusEngine.userInterfaces {
	import SephiusEngine.Languages.LanguageManager;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.input.InputActionsNames;
	import SephiusEngine.input.InputWatcher;

	import com.greensock.TweenMax;

	import starling.display.Image;
	import starling.display.Sprite;
	import starling.extensions.brinkbit.fullscreenscreenextension.FullScreenExtension;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	import tLotDClassic.GameData.Properties.ItemProperties;
	import tLotDClassic.GameData.Properties.MemoProperties;
	import tLotDClassic.GameData.Properties.WeaponProperties;
	import tLotDClassic.gameObjects.rewards.Reward;
	import SephiusEngine.input.maping.KeyboardActionMap;
	import tLotDClassic.GameData.Properties.SpellProperties;
	import tLotDClassic.GameData.Properties.NatureProperties;

	public class NewRewardUI extends Sprite{
        private var root:Sprite = new Sprite();
        private var bg:Image = new Image(GameEngine.assets.getTexture("NewReward_BG"));
        private var frame:Image = new Image(GameEngine.assets.getTexture("NewReward_BGLight"));
        private var ornament:Image = new Image(GameEngine.assets.getTexture("NewReward_OrnamentLight"));
        private var iconHighlight:Image = new Image(GameEngine.assets.getTexture("NewReward_IconHighlight"));
        private var iconHighlight2:Image = new Image(GameEngine.assets.getTexture("NewReward_IconHighlight"));
        private var divisor:Image = new Image(GameEngine.assets.getTexture("NewReward_DivisorH"));
        private var icon:Image = new Image(GameEngine.assets.getTexture("NewReward_OrnamentLight"));
        private var closeIndicator:Image = new Image(GameEngine.assets.getTexture("NewReward_CloseIndicatorLight"));

        private var rewardName:TextField = new TextField(50, 50, "Reward Name", "ChristianaWhite", 30, 0xffffff, true);
        private var usageText:TextField = new TextField(50, 50, "Usage text for the reward", "ChristianaWhite", 20, 0xffffff, true);
        
        private var gotoInventoryText:TextField = new TextField(50, 50, "Details", "ChristianaWhite", 20, 0xffffff, true);
        private var inventoryButtom:Image = new Image(GameEngine.assets.getTexture("NewReward_CloseIndicatorLight"));
        
        public var rewardID:String;
        public var rewardType:String;

        public var enabled:Object;

        public var inputWatcher:InputWatcher;

        public function NewRewardUI(){
            LanguageManager.ON_LANG_CHANGED.add(updateLang);

            GameEngine.assets.checkInTexturePack("NewReward", null, "UserInterface");

            addChild(root);
            root.addChild(bg);
            root.addChild(frame);
            root.addChild(ornament);
            root.addChild(iconHighlight);
            root.addChild(iconHighlight2);
            root.addChild(divisor);
            root.addChild(icon);
            root.addChild(closeIndicator);
            root.addChild(rewardName);
            root.addChild(usageText);
            root.addChild(gotoInventoryText);
            root.addChild(inventoryButtom);

            setLayout();
        }

        private var _skin:String = "Light";
		/**Name of the skin HUD currently used */
		public function get skin():String {return _skin;}
		public function set skin(value:String):void {
			if(value == _skin)
				return;

            _skin = value;

            bg.color = _skin == "Light" ? 0xffffff : 0x000000;

            frame.texture = GameEngine.assets.getTexture("NewReward_BG" + _skin);
            
            ornament.texture = GameEngine.assets.getTexture("NewReward_Ornament" + _skin);
            
            closeIndicator.texture = GameEngine.assets.getTexture("NewReward_CloseIndicator" + _skin);

            rewardName.fontName = skin == "Dark" ? "ChristianaWhite" : "ChristianaDark";
            rewardName.color = _skin == "Dark" ? 0xffffff : 0x000000;
            
            usageText.fontName = skin == "Dark" ? "ChristianaWhite" : "ChristianaDark";
            usageText.color = _skin == "Dark" ? 0xffffff : 0x000000;
            
            gotoInventoryText.fontName = skin == "Dark" ? "ChristianaWhite" : "ChristianaDark";
            gotoInventoryText.color = _skin == "Dark" ? 0xffffff : 0x000000;
        }

		public function setGamePlaying(play:Boolean):void {
			GameEngine.instance.state.paused = !play;
			GameEngine.instance.stage.focus = GameEngine.instance.stage;
		}

        private function setLayout():void{
            this.alpha = 0.999;

			root.x = FullScreenExtension.stageWidth * .5;
			root.y = FullScreenExtension.stageHeight * .45;

            bg.alignPivot();
            bg.color = 0x000000;
            bg.width = frame.width + 150;
            bg.height = frame.height + 150;

            frame.alignPivot();
            
            ornament.alignPivot();
            ornament.y = (-frame.height / 2) + 15 // Alight to top

            iconHighlight.alignPivot();
            iconHighlight.x = (-frame.width / 2) + (iconHighlight.width / 2) + 10;//Alight Left

            iconHighlight2.alignPivot();
            iconHighlight2.scaleX = 1;
            iconHighlight2.x = iconHighlight.x;

            iconHighlight2.alpha = iconHighlight.alpha = 0.5;

            //icon.width = icon.height = 200;
            //icon.alignPivot();
            icon.x = iconHighlight.x;
            icon.y = iconHighlight.y;
            
            closeIndicator.alignPivot();
            closeIndicator.x = 0;
            closeIndicator.y = (frame.height / 2) - 20;

            inventoryButtom.alignPivot();
            inventoryButtom.x = (frame.width / 2) - 40;
            inventoryButtom.y = (frame.height / 2) - 20;

            rewardName.width = frame.width * 0.7;
            //rewardName.autoSize = TextFieldAutoSize.VERTICAL;
            rewardName.alignPivot();
            rewardName.x = (frame.width / 2) - (rewardName.width / 2) - 15;
            //rewardName.y = -(frame.height / 2) + (rewardName.height / 2) + 30;

            divisor.alignPivot();
            divisor.width = frame.width * 0.65;
            divisor.x = rewardName.x;
            //divisor.y = rewardName.y + (rewardName.height / 2) + (divisor.height / 2) + 5;

            usageText.width = frame.width * 0.65;
            usageText.autoSize = TextFieldAutoSize.VERTICAL;
            usageText.alignPivot();
            usageText.x = rewardName.x;
            //usageText.y = divisor.y + (divisor.height / 2) + (usageText.height / 2) + 5;
            
            gotoInventoryText.alignPivot(HAlign.RIGHT, VAlign.CENTER);
            gotoInventoryText.width = 200;
            gotoInventoryText.autoSize = TextFieldAutoSize.HORIZONTAL;
            gotoInventoryText.x = inventoryButtom.x - (inventoryButtom.width / 2) - (gotoInventoryText.width / 2) - 15;
            gotoInventoryText.y = inventoryButtom.y;
        }

        private var ciOscAmp:Number = 7;
        private var ciOscSpeed:Number = 0.02;
        private var ciOstimer:Number = 0;
        private var ciOsCicle:Number = 0;
        public function update():void{
            if(inputWatcher.justDid(InputActionsNames.INTERFACE_CONFIRM) || inputWatcher.justDid(InputActionsNames.INTERFACE_PAUSE) 
            || inputWatcher.justDid(InputActionsNames.INTERFACE_CANCEL) || inputWatcher.justDid(InputActionsNames.INTERFACE_CANCEL_B)){
                hide();
            }
            if(inputWatcher.justDid(InputActionsNames.INTERFACE_MENU_INFO)){
                var section:String;
                var subID:String;
                switch(rewardType) {
                    case Reward.REWARD_TYPE_WEAPON:
                        section = "WEAPONS";
                        break;
                    case Reward.REWARD_TYPE_ITEM:
                        section = "ITEMS";
                        break;
                        case Reward.REWARD_TYPE_SPELL:
                        section = "SPELLS";
                        break;
                    case Reward.REWARD_TYPE_MEMO:
                        section = "MEMOS";
                        break;
                    default:
                        section = "";
                        break;
                }

                UserInterfaces.instance.gameMenu.show(skin, section, rewardID);
                hide();
            }

            iconHighlight.rotation += Math.PI * 0.004;
            iconHighlight2.rotation -= Math.PI * 0.003;

            ciOstimer += ciOscSpeed;
            ciOsCicle = Math.sin(Math.PI * ciOstimer);

            closeIndicator.y = (closeIndicator.y = (frame.height / 2) - 20) + (ciOsCicle * ciOscAmp) ;
        }

        public function updateLang(langID:String):void{
            var massage:Object;

            var langCategory:String;
            var titlePrefix:String;
            switch(rewardType) {
                case Reward.REWARD_TYPE_WEAPON:
                    langCategory = "WeaponsData";
                    titlePrefix = LanguageManager.getSimpleLang("HUDElements", "Weapon").name + ": ";
                    break;
                case Reward.REWARD_TYPE_ITEM:
                    langCategory = "ItemsData";
                    titlePrefix = LanguageManager.getSimpleLang("HUDElements", "Item").name + ": ";
                    break;
                    case Reward.REWARD_TYPE_SPELL:
                    langCategory = "SpellsData";
                    titlePrefix = LanguageManager.getSimpleLang("HUDElements", "New Nature").name + ": ";
                    break;
                case Reward.REWARD_TYPE_MEMO:
                    langCategory = "MemosData";
                    titlePrefix = ""
                    break;
                default:
                    langCategory = "";
                    break;
            }

            if(langCategory == "")
                return;

            rewardName.text = titlePrefix + LanguageManager.getLoreLang(langCategory, rewardID).name;
            rewardName.alignPivot();
            
            usageText.text = LanguageManager.getLoreLang(langCategory, rewardID).usage;
            usageText.alignPivot();

            gotoInventoryText.text = LanguageManager.getSimpleLang("HelpElements", "GO_TO_INVENTORY").name;
            gotoInventoryText.x = inventoryButtom.x - (inventoryButtom.width / 2) - (gotoInventoryText.width / 2) - 15;
            gotoInventoryText.y = inventoryButtom.y;

            rewardName.y = -(frame.height / 2) + (rewardName.height / 2) + 45;
            divisor.y = rewardName.y + (rewardName.height / 2) + (divisor.height / 2) - 12;
            usageText.y = divisor.y + (divisor.height / 2) + (usageText.height / 2) - 2;
        }

        private function updateRewardIcon():void{
            var iconTextName:String;
            switch(rewardType){
                case Reward.REWARD_TYPE_WEAPON:
                    iconTextName = WeaponProperties.PROPERTY_BY_VAR_NAME[rewardID].icon;
                    icon.texture = GameEngine.assets.getTexture(iconTextName);
                    icon.color = 0xffffff;
                    iconHighlight.color = 0xffffff;
                    iconHighlight2.color = 0xffffff;
                    icon.readjustSize();
                    icon.alignPivot();
                    icon.width = 100;
                    icon.height = 200;
                    break;
                case Reward.REWARD_TYPE_ITEM:
                    iconTextName = ItemProperties.PROPERTY_BY_VAR_NAME[rewardID].icon;
                    icon.texture = GameEngine.assets.getTexture(iconTextName);
                    icon.color = 0xffffff;
                    iconHighlight.color = 0xffffff;
                    iconHighlight2.color = 0xffffff;
                    icon.readjustSize();
                    icon.alignPivot();
                    icon.width = icon.height = 200;
                    break;
                case Reward.REWARD_TYPE_SPELL:
                    iconTextName = "SpellIcon_" + skin + SpellProperties[rewardID].name;
                    icon.texture = GameEngine.assets.getTexture(iconTextName);
                    icon.color = 0xffffff;
                    iconHighlight.color = iconHighlight2.color = NatureProperties[SpellProperties[rewardID].name].color;
                    icon.readjustSize();
                    icon.alignPivot();
                    icon.width = icon.height = 150;
                    break;
                case Reward.REWARD_TYPE_MEMO:
                    iconTextName = MemoProperties.PROPERTY_BY_VAR_NAME[rewardID].icon;
                    icon.texture = GameEngine.assets.getTexture(iconTextName);
                    icon.color = 0xffffff;
                    iconHighlight.color = 0xffffff;
                    iconHighlight2.color = 0xffffff;
                    icon.alignPivot();
                    icon.width = icon.height = 200;
                    break;
                default:
                    iconTextName = "NewReward_OrnamentLight";
                    break
            }
        }

        public function show(rewardID:String, rewardType:String, parent:Sprite):void{
            setGamePlaying(false);

            this.rewardID = rewardID;
            this.rewardType = rewardType;
            
            updateLang("");

            this.skin = skin;

            updateRewardIcon();

            var deviceSufix:String;
			var deviceType:String = inputWatcher.gameDevices.length > 0 ? "GamePad" : "Keyboard";
            if(deviceType == "Keyboard")
                deviceSufix = KeyboardActionMap.keyNamesFromCode[KeyboardActionMap.CURRENT.INTERFACE_MENU_INFO];
            else if(deviceType == "GamePad")
                deviceSufix =  inputWatcher.currentMap["INTERFACE_MENU_INFO"];
            else 
                throw Error ("No device informed to show device exception help.");	

            inventoryButtom.texture = GameEngine.assets.getTexture("DeviceButtoms_" + inputWatcher.deviceButtomsName + deviceSufix);
            inventoryButtom.alignPivot();

            alpha = 0;
            enabled = true;
            parent.addChild(this);

            ciOsCicle = ciOstimer = 0;

            TweenMax.to(this, 0.5, { startAt:{alpha:0}, alpha:1 } );

            GameEngine.instance.soundComponent.play("UI_New" + rewardType + "Collected", "UI", 1);
        }

        public function hide():void{
            TweenMax.to(this, 0.5, { startAt:{alpha:alpha}, alpha:0 } );
            TweenMax.delayedCall(0.5, remove);

            if(!UserInterfaces.instance.gameMenu.visible)
                TweenMax.delayedCall(.3, setGamePlaying, [true]);
        }

        private function remove():void{
            removeFromParent(false);
            enabled = false;
        }

        override public function dispose():void{
            super.dispose();
            bg.dispose();
            frame.dispose();
            ornament.dispose();
            iconHighlight.dispose();
            divisor.dispose();
            icon.dispose();
            closeIndicator.dispose();

            rewardName.dispose();
            usageText.dispose();
            gotoInventoryText.dispose();

            inventoryButtom.dispose();

            GameEngine.assets.checkOutTexturePack("NewReward", "UserInterface");

            inputWatcher = null;
        }

    }
}