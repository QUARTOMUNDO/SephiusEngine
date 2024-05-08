package SephiusEngine.levelObjects.activators {
	import SephiusEngine.core.GameData;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.GamePhysics;
	import SephiusEngine.core.gameStates.LevelManager;
	import SephiusEngine.displayObjects.configs.AssetsConfigs;
	import SephiusEngine.levelObjects.GamePhysicalObject;
	import SephiusEngine.levelObjects.GamePhysicalSprite;
	import SephiusEngine.userInterfaces.UserInterfaces;

	import flash.utils.Dictionary;

	import nape.phys.BodyType;

	import tLotDClassic.GameData.Properties.CharacterProperties;
	import tLotDClassic.GameData.Properties.HelpProperties;
	import tLotDClassic.gameObjects.characters.Creatures;
	import tLotDClassic.gameObjects.characters.Sephius;
	/**
	 * Call a story teller, a help or a cutscene when player touch on it
	 * @author Nilo Paiva & Fernando Rabello
	 */
	public class EventTrigger extends GamePhysicalObject {
		
		public static const STATE_OFF:String = "off";
		public static const STATE_ON:String = "on";
		
		public var areaGlobalID:uint;
		
		public static const TYPE_HELP:String = "Help";
		public static const TYPE_STORYTELLER:String = "Storyteller";
		public static const TYPE_CUTSCENE:String = "Cutscene";
		public static const TYPE_BOSS_ENCOUNTER:String = "Boss_Encounter";
		
		public var ID:String;
		public var messageType:String;
		
		public function EventTrigger(name:String, params:Object=null) {
			super(name, params);
		}
		
		private var aekon:Creatures;
		private var guenon:Creatures;
		private var sihlus:Creatures;
		private var darkFlame:Creatures;
		private var greatIce:Creatures;
		
		private var existingBosses:Dictionary = new Dictionary();
		
		private var triggerCount:int = 0;
		
		/**
		 * Logic when this interactor senses the player
		 * @param	interactor
		 */
		public function onInteractorSense(interactor:Sephius):void {
			triggerCount++;
			trace("onInteractorSense: " + messageType + " Count: " + triggerCount);
			
			if(messageType == TYPE_HELP){
				if (!interactor.archivemnets.listenedHelps[ID].listened){
					UserInterfaces.instance.helpUI.showIngameHelpMessage(HelpProperties[ID]);
				}
			}
			else if (messageType == TYPE_STORYTELLER) {
				if(!UserInterfaces.instance.storyUI.onScreen || (UserInterfaces.instance.storyUI.onScreen && ID != UserInterfaces.instance.storyUI.currentStoryTeller.varName)){
					if (!interactor.archivemnets.listenedStoryTellers[ID].listened)
						UserInterfaces.instance.storyUI.show(ID);
				}
			}
			else if (messageType == TYPE_CUTSCENE) {
				if (!interactor.archivemnets.listenedCutscenes[ID].listened)
					UserInterfaces.instance.cutscene.show(ID);
			}
			else if (messageType == TYPE_BOSS_ENCOUNTER) {
							
				var params:Object = { };
				params.group = AssetsConfigs.OBJECTS_ASSETS_GROUP;
				params.inverted = (this.x - interactor.x > 0) ? true : false;
				params.showSplashOnCreation = false;
				params.x = (this.x - interactor.x > 0) ? interactor.x + 1000 : interactor.x - 1000;
				params.y = this.y - 350;
				params.patrolRangeX = 4000;
				params.patrolRangeY = 200;	
				
				switch (ID) {
					case "AEKON_ENCOUNTER":
						if (!existingBosses["AEKON_Boss"] && GameData.getInstance().worldEventFlags.GetWorldFlagValue("Boss.Aekon.Dead") < 1){
							params.name = "AEKON_Boss";
							existingBosses[params.name] = new Creatures(CharacterProperties.AEKON, null, params);
							existingBosses[params.name].onDestroyed.addOnce(removeBoss);
							LevelManager.getInstance().changeGameMusicBySite(null);
						}
					break;
					case "GUEHON_SIHLUS_ENCOUNTER":
						if (!existingBosses["GUEHON_Boss"] && GameData.getInstance().worldEventFlags.GetWorldFlagValue("Boss.GuehnonGrown.Dead") < 1){
							params.name = "GUEHON_Boss";
							existingBosses[params.name] = new Creatures(CharacterProperties.GUEHNON_GROWN, null, params);
							existingBosses[params.name].onDestroyed.addOnce(removeBoss);
							LevelManager.getInstance().changeGameMusicBySite(null);
						}	
						/*
						if (!existingBosses["SIHLUS_Boss"] && GameData.getInstance().worldEventFlags.GetWorldFlagValue("Boss.SihlusGrown.Dead") < 1){
							params.name = "SIHLUS_Boss";
							existingBosses[params.name] = new Creatures(CharacterProperties.SIHLUS_GROWN, params);
							existingBosses[params.name].onDestroyed.addOnce(removeBoss);
							LevelManager.getInstance().changeGameMusicBySite(null);
						}*/	
					break;
					case "ICE_GREAT_ENCOUNTER":
						if (!existingBosses["ICE_GREAT_Boss"] && GameData.getInstance().worldEventFlags.GetWorldFlagValue("Boss.IceGreat.Dead") < 1){
							params.name = "ICE_GREAT_Boss";
							existingBosses[params.name] = new Creatures(CharacterProperties.ENTITY_ICE_GREAT, null, params);
							existingBosses[params.name].onDestroyed.addOnce(removeBoss);
							LevelManager.getInstance().changeGameMusicBySite(null);
						}
					break;
					case "DARK_FLAME_ENCOUNTER":
						if (!existingBosses["DARK_FLAME_Boss"] && GameData.getInstance().worldEventFlags.GetWorldFlagValue("Boss.DarkFlame.Dead") < 1){
							params.name = "DARK_FLAME_Boss";
							existingBosses[params.name] = new Creatures(CharacterProperties.ENTITY_DARK_FLAME, null, params);
							existingBosses[params.name].onDestroyed.addOnce(removeBoss);
							LevelManager.getInstance().changeGameMusicBySite(null);
						}
					break;
					default:
				}
				
				interactor.characterAttributes.canAct = true;//MAKE SEPHIUS PLAYABLE SOON AFTER CUTSCENE ENDS
			}
		}
		
		public function removeBoss(char:GamePhysicalSprite):void {
			existingBosses[char.name] = null;
			delete existingBosses[char.name];
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			if (Math.abs(this.x - GameEngine.instance.state.mainPlayer.x) > 1400 || Math.abs(this.y - GameEngine.instance.state.mainPlayer.y) > 700)
				state = STATE_OFF;
		}
		
		override public function createPhysics():void {
			_radius = _width;
			//_shapeType = "Circle";
			
			_interactionFilter = GamePhysics.PYRA_FILTER;
			_cbTypes.add(GamePhysics.REACT_CBTYPE);
			
			super.createPhysics();
			
			_mainShape.fluidEnabled = true;
			_mainShape.fluidProperties.density = 0;
			_mainShape.fluidProperties.viscosity = 0;
		}
		override public function addPhysics():void {
			super.addPhysics();
			_mainShape.sensorEnabled = false;
			_body.type = BodyType.STATIC;
		}
		
		override public function removePhysics():void {
			if (!_physicAdded)
				return;
			super.removePhysics();
		}
		
		public function get state():String {return _state;}
		public function set state(value:String):void {
			if (_state == value)
				return;
			
			_state = value;
		}
		private var _state:String = STATE_ON;
		
		/* INTERFACE SephiusEngine.levelObjects.interfaces.IPhysicSoundEmitter */
	}
}