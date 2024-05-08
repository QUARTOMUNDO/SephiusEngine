package SephiusEngine.core {
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.gameplay.attributes.subAttributes.NatureGauge;
	import SephiusEngine.core.gameplay.inventory.Inventory;
	import SephiusEngine.core.gameplay.inventory.objects.Weapon;
	import SephiusEngine.core.levelManager.LevelRegion;
	import SephiusEngine.core.levelManager.WorldEventFlags;
	import SephiusEngine.levelObjects.effects.SplashAnimation;
	import SephiusEngine.utils.GameFilesUtils;

	import com.greensock.TweenMax;

	import flash.system.Capabilities;
	import flash.utils.Dictionary;

	import tLotDClassic.GameData.Properties.BarrierProperties;
	import tLotDClassic.GameData.Properties.CharacterProperties;
	import tLotDClassic.GameData.Properties.CutsceneProperties;
	import tLotDClassic.GameData.Properties.EssenceProperties;
	import tLotDClassic.GameData.Properties.HelpProperties;
	import tLotDClassic.GameData.Properties.ItemProperties;
	import tLotDClassic.GameData.Properties.MemoProperties;
	import tLotDClassic.GameData.Properties.NatureProperties;
	import tLotDClassic.GameData.Properties.PropertiesDataManager;
	import tLotDClassic.GameData.Properties.SpellProperties;
	import tLotDClassic.GameData.Properties.StatusProperties;
	import tLotDClassic.GameData.Properties.StoryTellerProperties;
	import tLotDClassic.GameData.Properties.WeaponProperties;
	import tLotDClassic.GameData.Properties.naturesInfos.Natures;
	import tLotDClassic.attributes.AttributesConstants;
	import tLotDClassic.attributes.holders.CharactersAttributes;
	import tLotDClassic.gameObjects.activators.MysticReceptacle;
	import tLotDClassic.gameObjects.barriers.Barriers;
	import tLotDClassic.gameObjects.barriers.TriggeredBarrier;
	import tLotDClassic.gameObjects.characters.Sephius;
	import tLotDClassic.gameObjects.rewards.Reward;
	import SephiusEngine.core.levelManager.GameOptions;
	
	/**
	 * ...
	 * @author ... Fernando Rabello
	 * Store several Game Data from a particular game state
	 */
	public class  GameData{
		
		private static var _instance:GameData;
		
		/**-------------------------------------------------
		 *                Game Information
		 ----------------------------------------------*/
		 
		public var isLoading:Boolean = false;
		
		//public function get saveData():SharedObject { return _saveData; }
		//public function set saveData(value:SharedObject):void { _saveData = value; }
		//private var _saveData:SharedObject;
		
		public function get gameSlot():int { return -1; }
		
		/** Determine the game cicle, after player ends the game game begings again. This tells on witch game cicle playes is */
		public function get currentGameCicle():int { return _currentGameCicle; }
		public function set currentGameCicle(value:int):void { 
			_currentGameCicle = value; 
			if(_currentGameCicle > 0)
				CharactersAttributes.baseLevelScalled = (_currentGameCicle * AttributesConstants.gameCycleLevelIncrease);
		}
		private var _currentGameCicle:int = 0;
		
		public var numberOfLoads:int = 0;
		
		public var storyTellerslistened:Vector.<String> = new Vector.<String>();
		public var cutsceneslistened:Vector.<String> = new Vector.<String>();
		public var helpsListened:Vector.<String> = new Vector.<String>();
		
		/**--------------------------------------------------
		 *             Sephius Informations 
		 --------------------------------------------------*/
		//Actual Values are values readed by other classes and the GameSave trough re-write normal values as this ones.
		//Normal values are values readed by Sephius itself. Because Sephius can´t read a value that directs to himself. Is so there no set of value at all.
		
		public var timePayed:Number = 0;
		
		public var distanceTraveled:int = 0;
		
		/** Total of enemies thar player has killed in the game */
		public function get enemiesKilled():int{return _enemiesKilled;}
		public function set enemiesKilled(value:int):void { _enemiesKilled = value; }
		private var _enemiesKilled:int;
		
		/** Total of times Player was killed in the game*/
		public function get numberOfDeaths():int{return _numberOfDeaths;}
		public function set numberOfDeaths(value:int):void { _numberOfDeaths = value; }
		private var _numberOfDeaths:int = 0;
		
		/** Sephius Actual Level*/
		private var _sephiusLevel:int;
		public function get sephiusLevel():int { return _sephiusLevel; }
		public function set sephiusLevel(value:int):void { _sephiusLevel = value;}
		
		private var _sephiusEssencika:Number;
		public function get sephiusEssencika():Number { return _sephiusEssencika; }
		public function set sephiusEssencika(value:Number):void { _sephiusEssencika = value; }

		private var _essenceTendency:Number;
		public function get essenceTendency():Number { return _essenceTendency; }
		public function set essenceTendency(value:Number):void { _essenceTendency = value; }
		
		private var _sephiusDeepEssence:Number = 0;
		public function get sephiusDeepEssence():Number { return _sephiusDeepEssence; }
		public function set sephiusDeepEssence(value:Number):void { _sephiusDeepEssence = value; }
		
		private var _sephiusPeripheralEssence:Number = -1;
		public function get sephiusPeripheralEssence():Number { return _sephiusPeripheralEssence; }
		public function set sephiusPeripheralEssence(value:Number):void { 
			_sephiusPeripheralEssence = value; 
		}
		
		private var _sephiusMysticalEssence:Number = -1;
		public function get sephiusMysticalEssence():Number { return _sephiusMysticalEssence; }
		public function set sephiusMysticalEssence(value:Number):void { _sephiusMysticalEssence = value; }
		
		public var sephiusNatureAmplifications:NatureGauge;
		
		public var sephiusInitialNatureAmplifications:NatureGauge;
		public var sephiusInitialNatureImunity:NatureGauge;
		
		public var startSet:String = "demo";
		
		/** Itens player start in a "new game" */
		public var sephiusInitialHeldItemList:Array = Inventory.newGameHeldtems();
		public var sephiusHeldItems:Array = new Array();
		/** Store itens cooldowns state at the last play */
		public var cooldowns:Array = new Array();
		
		/** Weapons player start in a "new game"*/
		public var sephiusInitialHeldWeaponsList:Array = Inventory.newGameHeldWeapons();
		public var sephiusHeldWeapons:Array = [];
		
		/** Weapons player start in a "new game"*/
		public var sephiusInitialHeldMemoList:Array = Inventory.newGameHeldMemos();
		public var sephiusHeldMemos:Array = [];
		
		/** Weapons player start in a "new game"*/
		public var sephiusHeldSpells:Array = [];
		
		/** Spells selected on the HUD*/
		public var sephiusSpell1:String = SpellProperties.NULL.varName;
		public var sephiusSpell2:String = SpellProperties.NULL.varName;
		
		/** Items selected on the HUD*/
		public var sephiusItem1:String = ItemProperties.NONE.varName;
		public var sephiusItem2:String = ItemProperties.NONE.varName;
		
		public var equipedItems:Array = [];
		
		/** Weapon selected on the HUD*/
		public var sephiusWeapon1:String = WeaponProperties.NONE.varName;
		public var sephiusWeapon2:String = WeaponProperties.NONE.varName;
		
		/**Witch side Sephius is facing*/
		public var sephiusFacingRight:Boolean = true;
		
		public var lastUsedPyra:String = "";
		/**------------------------------------------
		*            World Informations
		---------------------------------------------*/
		/**Light ou Dark*/
		public function get worldSide():String { return _worldSide }
		public function set worldSide(value:String):void { _worldSide = value; }
		private var _worldSide:String = "Dark";
		
		/** Name of the region player is exploring*/
		public function get currentRegion():LevelRegion { return _currentRegion }
		public function set currentRegion(value:LevelRegion):void { _currentRegion = value; }
		private var _currentRegion:LevelRegion;
		
		/** Store event flags with values to be used in game progression */
		public function get worldEventFlags():WorldEventFlags { return _worldEventFlags}
		private var _worldEventFlags:WorldEventFlags = new WorldEventFlags();
		
		/**------------------------------------------
		*            	Level Informations
		---------------------------------------------*/
		public var startingRegion:LevelRegion = LevelRegion.LANDS_OF_OBLIVION;
		
		/** Witch region base player will start on new game. First number means a area. Second the local id of the base if area has more than 1 region base */
		public var startingRegionBase:Array;
		
		/** Witch region base player will start on new game. First number means a area. Second the local id of the base if area has more than 1 region base */
		public var initialRegionBase:Array = [00, 0];
		
		/** Witch region base player is assign. Player will restart on this base next time he load the game. */
		public var currentRegionBase:uint = 0;
		
		 /**Total of Levels a region has*/
		public function get TotalOfLevels():uint { return _totalOfLevels; }
		public function set TotalOfLevels(value:uint):void { _totalOfLevels = value; }
		private var _totalOfLevels:uint;
		
		/** Areas player already explored*/
		public function get AreasExplored():Array { return _areasExplored }
		public function set AreasExplored(value:Array):void { _areasExplored = value; }
		private var _areasExplored:Array;
		
		/** Barriers player already has opened. Barreirs added here will start the game opened*/
		public function get barriersOpened():Array { return _barriersOpened; }
		public function set barriersOpened(value:Array):void {  _barriersOpened = value;  }
		private var _barriersOpened:Array = new Array();
		
		/** Barriers that was closed. Barreirs added here will start the game closed */
		public function get barriersClosed():Array { return _barriersClosed; }
		public function set barriersClosed(value:Array):void {  _barriersClosed = value;  }
		private var _barriersClosed:Array = new Array();
				
		/** Locations stored on the map. 
		 * Other objects can see here if their GlobalID exist in order to determine if they already should appear on the map, 
		 * or if they should be actavated by the game mechanics */
		public function get mapLocations():Vector.<String> { return _mapLocations; }
		public function set mapLocations(value:Vector.<String>):void {  _mapLocations = value;  }
		private var _mapLocations:Vector.<String> = new Vector.<String>();
		
		public function addMapLocations(value:String):void {
			if (value == "")
				throw Error("[GAMEDATA] Global ID is Invalid or empty");
				
			if (_mapLocations.indexOf(value) == -1){
				_mapLocations.push(value);
				trace("[GAMEDATA] Map Location Added: ");
			}
		}
		public function removeMapLocations(value:String):void {
			if (value == "")
				throw Error("[GAMEDATA] Global ID is Invalid or empty");
				
			if (_mapLocations.indexOf(value) != -1){
				_mapLocations.splice(barriersOpened.indexOf(value), 1);
				trace("[GAMEDATA] Map Location Removed: ");	
			}
		}
		
		/** Store what sites have map reveled */
		public function get siteMapLocations():Vector.<String> { return _siteMapLocations; }
		public function set siteMapLocations(value:Vector.<String>):void {  _siteMapLocations = value;  }
		private var _siteMapLocations:Vector.<String> = new Vector.<String>();
		
		public function addSiteMapLocations(siteName:String):void {
			if (siteName == "")
				throw Error("[GAMEDATA] Global ID is Invalid or empty");
				
			if (_siteMapLocations.indexOf(siteName) == -1){
				_siteMapLocations.push(siteName);
				trace("[GAMEDATA] siteMapLocations Added: ");
			}
		}
		
		/** Barriers that was closed. Barreirs added here will start the game closed */
		public function get receptacles():Dictionary { return _receptacles; }
		public function set receptacles(value:Dictionary):void {  _receptacles = value;  }
		private var _receptacles:Dictionary = new Dictionary();
		
		public function addReceptacleState(receptacleID:String, state:Boolean):void{
			receptacles[receptacleID] = state;
		}
		
		/** Set barrier initial state to opened or closed. When set, barrier will start game opened or closed */
		public function setBarrierInitialState(barrierGlobalID:String, opened:Boolean):void {
			if (opened) {
				if (barriersOpened.indexOf(barrierGlobalID) == -1)
					barriersOpened.push(barrierGlobalID);
				if (barriersClosed.indexOf(barrierGlobalID) != -1)
					barriersClosed.splice(barriersClosed.indexOf(barrierGlobalID), 1);
			}
			else {
				if (barriersClosed.indexOf(barrierGlobalID) == -1)
					barriersClosed.push(barrierGlobalID);
				if (barriersOpened.indexOf(barrierGlobalID) != -1)
					barriersOpened.splice(barriersClosed.indexOf(barrierGlobalID), 1);
			}
		}
		
		public function addOppenedBarriers(value:int):void {
			if (barriersOpened.indexOf(value) == -1)
				barriersOpened.push(value);
			trace("[GAMEDATA]barriers Collection: ", barriersOpened);
		}
		public function removeOppenedBarriers(value:int):void {
			if (barriersOpened.indexOf(value) != -1)
				barriersOpened.splice(barriersOpened.indexOf(value), 1);
		}
		
		/** String of a level file name, used to determine level informations*/
		public function get levelString():String { return _levelString; }
		public function set levelString(value:String):void { _levelString = value; }
		private var _levelString:String;
		
		
		/** Array of informations about the level (nome do level)*/
		public function get levelInformations():Array{return _levelInformations;}
		public function set levelInformations(value:Array):void {_levelInformations = value;}
		private var _levelInformations:Array;
		
		/** List of respawners that are in "coldDown" state*/
		public var respawnersWaiting:Array = new Array();
		
		/** List of count down times of respawners that are in "coldDown" state*/
		public var respawnersWaitingTimes:Array = new Array();
		
		/** List of Bosses that was already killed*/
		public var bossesKilled:Array = new Array();
		
		public var rewardsByID:Dictionary = new Dictionary();
		
		public var rewardsDroped:Dictionary = new Dictionary();
		
		/** List of placed or unique items already colleted*/
		public var uniqueRewardsColeted:Array = new Array();
		
		/** List of placed or unique weapons already colleted*/
		public var uniqueWeaponColeted:Array = new Array();
		
		/** -----------------------------------------------
		 *           Sephius Archivments
		------------------------------------------------- */
		
		/** GameData menage and store player´s gameplay data in order it can be loaded on a latter game 
		 * It also has some methods witch can be acessed by other classes related with player progress */
		public function GameData(pvt:PrivateClass) {
			trace ("[GAMEDATA] created");
			//Sort Properties list
			SpellProperties.sortPropertyLists();
			ItemProperties.sortPropertyLists();
			WeaponProperties.sortPropertyLists();
			StatusProperties.sortPropertyLists();
			CharacterProperties.sortPropertyLists();
			BarrierProperties.sortPropertyLists();
			EssenceProperties.sortPropertyLists();
			NatureProperties.sortPropertyLists();
			MemoProperties.sortPropertyLists();
			
			if(PropertiesDataManager.useSocketConnections && Capabilities.isDebugger)
				PropertiesDataManager.createSocketConnection();
		}
		
		public function overrideProperties():void {
			PropertiesDataManager.overrideProperties(true);
		}
		
		/**
		 * Get this singleton instance of GlobalInfoCollection
		 * @return
		 */
		public static function getInstance():GameData {
			if (!_instance)
				_instance = new GameData(new PrivateClass());
			return _instance;
		}

		public function createGameOptionsSaveData():XML{
			var GOSD:XML = new XML(<GameOptionsSaveData/>);

			var varName:String;
			var node:XML;
			for each(varName in GameOptions.VAR_NAMES){
				GameOptions[varName];	
				node = new XML(<{varName}/>);
				node.@value = String(GameOptions[varName]);
				GOSD.appendChild(node);
			}

			return GOSD;
		}

		public function loadGameOptions():void{
			var ODXML:XML = GameFilesUtils.loadOptionsData();
			var child:XML;
			var childName:String;
			var childValue:String;
			if(ODXML){
				for each(child in ODXML.children()){
					childName = child.name();
					childValue = child.@value;

					trace("[GameData] Element Name: " + child.name() + ", Value: " + child.@value);
					
					if(GameOptions[childName] is Boolean)
						GameOptions[childName] = childValue == "false" ? false : true;
					else if(GameOptions[childName] is String)
						GameOptions[childName] = childValue;
					else
						GameOptions[childName] = Number(childValue);
				}

				trace("[GameData] Game Options Load Completed");
			}
			else
				trace("[GameData] Game Options File Don't Exist. Using Default Values");
		} 

		public function saveGameOptions():void{
			GameFilesUtils.saveSaveOptionsData(createGameOptionsSaveData());
		}

		public function showcaseGame(gameCicle:int = 0):void{
			//GameSave.getInstance().deleteGame(saveData);
			Weapon.WEAPONS.length = 0;
			
			_mapLocations.length = 0;
			_siteMapLocations.length = 0;
			
			var NA:Object = new Object();
			
			sephiusInitialHeldItemList = Inventory.demoHeldtems();
			sephiusInitialHeldWeaponsList = Inventory.demoHeldWeapons();
			sephiusInitialHeldMemoList = Inventory.demoHeldMemos();
			
			sephiusItem1 = ItemProperties.NERCANTE_KNIFE.varName;
			sephiusItem2 = ItemProperties.MESTIZO_ESSENCE_CRYSTAL.varName;
			
			sephiusWeapon2 = WeaponProperties.GRENDA_PRETAHTHESH_ASCURE.varName;
			sephiusWeapon1 = WeaponProperties.FOLKEN.varName;
			
			NA[Natures.Fire] = 20; NA[Natures.Ice] = 20; NA[Natures.Water] = 20; NA[Natures.Earth] = 20; 
			NA[Natures.Air] = 20; NA[Natures.Light] = 20; NA[Natures.Darkness] = 20; NA[Natures.Corruption] = 20;
			NA[Natures.Bio] = 20; NA[Natures.Psionica] = 20;
			
			sephiusSpell1 = SpellProperties.EARTH.varName;
			sephiusSpell2 = SpellProperties.DARKNESS.varName;
			
			helpsListened.length = 0;
			storyTellerslistened.length = 0;
			cutsceneslistened.length = 0;
			
			sephiusInitialNatureAmplifications = CharactersAttributes.setMysticAmplificationFromObject(NA);
			sephiusInitialNatureImunity = CharacterProperties.SEPHIUS.staticAttributes.natureResistances;
			
			sephiusFacingRight = (Math.random() > .5);
			
			currentGameCicle = gameCicle;
			sephiusDeepEssence = 0;
			sephiusMysticalEssence = -1;
			sephiusPeripheralEssence = -1;
			sephiusNatureAmplifications = sephiusInitialNatureAmplifications;
			_sephiusLevel = 0;
			
			sephiusHeldItems = sephiusInitialHeldItemList;
			sephiusHeldWeapons = sephiusInitialHeldWeaponsList;
			sephiusHeldMemos = sephiusInitialHeldMemoList;
			sephiusHeldSpells = Inventory.startGameHeldSpells(sephiusNatureAmplifications);
			
			uniqueRewardsColeted = new Array();
			uniqueWeaponColeted = new Array();
			
			worldSide = startingRegion.worldNature;
			currentRegion = startingRegion;
			startingRegionBase = [03, 1];
			
			barriersOpened.length = 0;
			barriersClosed.length = 0;
			
			rewardsByID = new Dictionary();
			rewardsDroped = new Dictionary();
			
			numberOfDeaths = 0;
			timePayed = 0; 
			distanceTraveled = 0;
			
			SplashAnimation.setSplashNames();
			
			overrideProperties();
			
			GameFilesUtils.saveSaveData(createGameSaveData());
			
			TweenMax.delayedCall(1, GameEngine.instance.startGame, [startingRegion]);
			//GameEngine.instance.sound.muteAllWithFade(false, "Song");
			
		}
		
		public function newGame(gameCicle:int = 0):void{
			//GameSave.getInstance().deleteGame(saveData);
			Weapon.WEAPONS.length = 0;
			
			_mapLocations.length = 0;
			_siteMapLocations.length = 0;
			
			var NA:Object = new Object();
			sephiusInitialHeldItemList = Inventory.newGameHeldtems();
			sephiusInitialHeldWeaponsList = Inventory.newGameHeldWeapons();
			sephiusInitialHeldMemoList = Inventory.newGameHeldMemos();
			
			sephiusSpell1 = SpellProperties.NULL.varName;
			sephiusSpell2 = SpellProperties.NULL.varName;
			
			sephiusItem1 = ItemProperties.NONE.varName;
			sephiusItem2 = ItemProperties.NONE.varName;
			
			sephiusWeapon1 = WeaponProperties.NONE.varName;
			sephiusWeapon2 = WeaponProperties.NONE.varName;
			
			NA[Natures.Fire] = 0; NA[Natures.Ice] = 0; NA[Natures.Water] = 0; NA[Natures.Earth] = 0; 
			NA[Natures.Air] = 0; NA[Natures.Light] = 0; NA[Natures.Darkness] = 0; NA[Natures.Corruption] = 0;
			NA[Natures.Bio] = 0; NA[Natures.Psionica] = 0;
			
			helpsListened.length = 0;
			storyTellerslistened.length = 0;
			cutsceneslistened.length = 0;
			
			sephiusInitialNatureAmplifications = CharactersAttributes.setMysticAmplificationFromObject(NA);
			sephiusInitialNatureImunity = CharacterProperties.SEPHIUS.staticAttributes.natureResistances;
			
			sephiusFacingRight = false;
			
			currentGameCicle = gameCicle;
			sephiusDeepEssence = 0;
			sephiusMysticalEssence = -1;
			sephiusPeripheralEssence = -1;
			sephiusNatureAmplifications = sephiusInitialNatureAmplifications;
			_sephiusLevel = 0;
			 
			sephiusHeldItems = sephiusInitialHeldItemList;
			sephiusHeldWeapons = sephiusInitialHeldWeaponsList;
			sephiusHeldMemos = sephiusInitialHeldMemoList;
			sephiusHeldSpells = Inventory.startGameHeldSpells(sephiusNatureAmplifications);
			
			uniqueRewardsColeted = new Array();
			uniqueWeaponColeted = new Array();
			
			worldSide = startingRegion.worldNature;
			currentRegion = startingRegion;
			startingRegionBase = [00, 1];
			
			barriersOpened.length = 0;
			barriersClosed.length = 0;			
			
			rewardsByID = new Dictionary();
			rewardsDroped = new Dictionary();
			
			numberOfDeaths = 0;
			timePayed = 0; 
			distanceTraveled = 0;
			
			SplashAnimation.setSplashNames();
			
			overrideProperties();

			GameFilesUtils.saveSaveData(createGameSaveData());
			
			TweenMax.delayedCall(1, GameEngine.instance.startGame, [startingRegion]);
			//GameEngine.instance.sound.muteAllWithFade(false, "Song");
			
		}
		
		public function continueGame():void {
			Weapon.WEAPONS.length = 0;	
			
			var SGXML:XML = GameFilesUtils.loadSaveData();
			
			var ivNode:XML;
			
			var gameStatsNode:XML;
			var selectedItemNode:XML;
			var selectedItemNode2:XML;
			
			var wpNode2:XML;
			var wpNode3:XML;
			
			var itemNode2:XML;
			var itemNode3:XML;
			
			var memoNode2:XML;
			var memoNode3:XML;
			
			var naNode2:XML;
			var naNode3:XML;
			
			var spellNode2:XML;
			var spellNode3:XML;
			
			currentRegion = startingRegion;
			worldSide = currentRegion.worldNature;
			
			SplashAnimation.setSplashNames();
			
			overrideProperties();
			
			for each (gameStatsNode in SGXML.NumberOfDeaths) {
				numberOfDeaths = gameStatsNode.@value;
			}
			
			for each (gameStatsNode in SGXML.TimePlayed) {
				timePayed = gameStatsNode.@value;
			}
			
			for each (gameStatsNode in SGXML.DistanceTraveled) {
				distanceTraveled = gameStatsNode.@value;
			}
			
			for each (gameStatsNode in SGXML.HelpsListened) {
				helpsListened = Vector.<String>(String(gameStatsNode.@value).split(","));
			}
			
			for each (gameStatsNode in SGXML.StoryTellerslistened) {
				storyTellerslistened = Vector.<String>(String(gameStatsNode.@value).split(","));
			}
			
			for each (gameStatsNode in SGXML.Cutsceneslistened) {
				cutsceneslistened = Vector.<String>(String(gameStatsNode.@value).split(","));
			}
			
			for each (gameStatsNode in SGXML.GameCicles) {
				currentGameCicle = gameStatsNode.@value;
			}				
			
			for each (gameStatsNode in SGXML.Attributes) {
				sephiusDeepEssence = gameStatsNode.@deepEssence;
				sephiusMysticalEssence = gameStatsNode.@mysticalEssence;
				sephiusPeripheralEssence = gameStatsNode.@peripheralEssence;
				_sephiusLevel = gameStatsNode.@level;
			}
			
			for each (gameStatsNode in SGXML.RegionBase) {
				startingRegionBase = [ Number(gameStatsNode.@areaGlobalID), Number(gameStatsNode.@locallID) ];
			}				
			
			for each (gameStatsNode in SGXML.SelectedSpell) {
				sephiusSpell1 = gameStatsNode.@Spell1;
				sephiusSpell2 = gameStatsNode.@Spell2;
			}			
			
			for each (gameStatsNode in SGXML.SelectedItem) {
				sephiusItem1 = gameStatsNode.@Item1;
				sephiusItem2 = gameStatsNode.@Item2;
			}	
			
			for each (gameStatsNode in SGXML.ItemsEquipedNode) {
				equipedItems.push(gameStatsNode.@Item1)
			}	
			
			for each (gameStatsNode in SGXML.SelectedWeapon) {
				sephiusWeapon1 = gameStatsNode.@Weapon1;
				sephiusWeapon2 = gameStatsNode.@Weapon2;
			}
			
			barriersOpened.length = 0;
			barriersClosed.length = 0;
			
			for each (selectedItemNode in SGXML.Barriers) {
				for each (selectedItemNode2 in selectedItemNode.BarriersOpened) {
					barriersOpened.push(String(selectedItemNode2.@globalID));
				}
				for each (selectedItemNode2 in selectedItemNode.BarriersClosed) {
					barriersClosed.push(String(selectedItemNode2.@globalID));
				}
			}		
			
			var receptacle:MysticReceptacle;
			for each (selectedItemNode in SGXML.MysticReceptacle) {
				_receptacles[selectedItemNode.@globalID] = selectedItemNode.@receptacleActivated;
			}		
			
			var mapLocationsNode:XML;
			var mapLocationNode:XML;
			var mapLocationID:String;
			for each (mapLocationsNode in SGXML.MapLocations) {
				for each (mapLocationNode in mapLocationsNode.MapLocation) {
					mapLocationID = String(mapLocationNode.@globalID);
					_mapLocations.push(mapLocationID);
				}
			}		
			
			var siteMapLocationsNode:XML;
			var siteMapLocationNode:XML;
			var siteMapLocationID:String;
			for each (siteMapLocationsNode in SGXML.SiteMapLocations) {
				for each (siteMapLocationNode in siteMapLocationsNode.SiteMapLocation) {
					siteMapLocationID = String(siteMapLocationNode.@siteName);
					_siteMapLocations.push(siteMapLocationID);
				}
			}		
			
			/*for each (selectedItemNode in SGXML.ItemsEquipedNode) {
				for each (selectedItemNode2 in selectedItemNode.Item) {
					equipedItems.push(String(selectedItemNode2.@varName));
				}
			}	*/	
			
			var newReward:Reward;
			var newRewardParams:Object = {};
			rewardsByID = new Dictionary();
			rewardsDroped = new Dictionary();
			
			for each (selectedItemNode in SGXML.Rewards) {
				Reward.maxGlobalID = selectedItemNode.@maxGlobalID;
				
				for each (selectedItemNode2 in selectedItemNode.CollectedRewards) {
					rewardsByID[String(selectedItemNode2.@globalID)] = true;
				}
				for each (selectedItemNode2 in selectedItemNode.DropedRewards) {
					newRewardParams = {};
					newRewardParams.x = Number(selectedItemNode2.@x);
					newRewardParams.y = Number(selectedItemNode2.@y);
					newRewardParams.group = int(selectedItemNode2.@group);
					newRewardParams.globalID = String(selectedItemNode2.@globalID);
					newRewardParams.rewardType = String(selectedItemNode2.@rewardType);
					newRewardParams.rewardID = String(selectedItemNode2.@rewardID);
					newRewardParams.rewardAmount = int(selectedItemNode2.@rewardAmount);
					newRewardParams.areaBoundedID = int(selectedItemNode2.@areaBoundedID);
					rewardsDroped[String(selectedItemNode2.@globalID)] = newRewardParams;
				}
			}		
			
			for each(ivNode in SGXML.Inventory){
				sephiusHeldWeapons.length = 0;
				for each(wpNode2 in ivNode.HeldWeapons){
					for each(wpNode3 in wpNode2.Weapon) {
						sephiusHeldWeapons.push({ varName:String(wpNode3.@varName) });
					}	
				}	
				
				sephiusHeldItems.length = 0;
				for each(itemNode2 in ivNode.HeldItems){
					for each(itemNode3 in itemNode2.Item) {
						sephiusHeldItems.push({ varName:String(itemNode3.@varName), amount:int(itemNode3.@amount), remainingColdDownTime:Number(itemNode3.@remainingColdDownTime), equiped:itemNode3.@equiped });
					}
				}	
				
				sephiusHeldMemos.length = 0;
				for each(memoNode2 in ivNode.HeldMemos){
					for each(memoNode3 in memoNode2.Memo) {
						sephiusHeldMemos.push({ varName:String(memoNode3.@varName) });
					}	
				}	
				
				var object:Object = {};
				sephiusHeldSpells.length = 0;
				for each(spellNode2 in ivNode.NatureAmplification){
					for each(spellNode3 in spellNode2.Nature) {
						object[String(spellNode3.@nature)] = Number(spellNode3.@amplification);
						sephiusHeldSpells.push(object);
					}	
				}	
				
				sephiusNatureAmplifications = CharactersAttributes.setMysticAmplificationFromObject(object);
				sephiusHeldSpells = Inventory.startGameHeldSpells(sephiusNatureAmplifications);
			}
			
			TweenMax.delayedCall(1, GameEngine.instance.startGame, [startingRegion]);
		}

		public function saveDataExist():Boolean{
			return GameFilesUtils.saveDataExist();
		}

		public function createGameSaveData(player:Sephius = null):XML{
			var GMXML:XML = new XML(<GameSaveData/>);
			var gameStatsNode:XML;
			
			var invNode:XML = new XML(<{"Inventory"}/>);
			
			var itemsNode:XML = new XML(<{"HeldItems"}/>);
			//var itemsEquipedNode:XML = new XML(<{"ItemsEquipedNode"}/>);
			var weaponsNode:XML = new XML(<{"HeldWeapons"}/>);
			var memosNode:XML = new XML(<{"HeldMemos"}/>);
			
			var spellsNode:XML = new XML(<{"NatureAmplification"}/>);
			var amplificationsNode:XML = new XML(<{"Nature"}/>);
			
			var barriersNode:XML = new XML(<{"Barriers"}/>);
			var receptaclesNode:XML = new XML(<{"MysticReceptacles"}/>);
			var rewardsNode:XML = new XML(<{"Rewards"}/>);
			
			var barrierNode:XML;
			var receptacleNode:XML;
			var itemNode:XML;
			var weaponNode:XML;
			var spellNode:XML;
			var rewardNode:XML;
			
			var memoNode:XML;
			var item:Object;
			var weapons:Object;
			var memo:Object;
			var spell:String;
			var nature:String;
			var barrier:Barriers;
			var reward:Reward;
			
			var listNelp:Array = [];
			
			if (!player) {
				gameStatsNode = new XML(<{"NumberOfDeaths"}/>);
				gameStatsNode.@value = 0;
				GMXML.appendChild(gameStatsNode);
				
				gameStatsNode = new XML(<{"TimePlayed"}/>);
				gameStatsNode.@value = 0;
				GMXML.appendChild(gameStatsNode);
				
				gameStatsNode = new XML(<{"DistanceTraveled"}/>);
				gameStatsNode.@value = 0;
				GMXML.appendChild(gameStatsNode);
				
				gameStatsNode = new XML(<{"GameCicles"}/>);
				gameStatsNode.@value = currentGameCicle;
				GMXML.appendChild(gameStatsNode);
				
				gameStatsNode = new XML(<{"RegionBase"}/>);
				gameStatsNode.@areaGlobalID = startingRegionBase[0];
				gameStatsNode.@locallID = startingRegionBase[1];
				GMXML.appendChild(gameStatsNode);
				
				gameStatsNode = new XML(<{"SelectedSpell"}/>);
				gameStatsNode.@Spell1 = sephiusSpell1;
				gameStatsNode.@Spell2 = sephiusSpell2;
				GMXML.appendChild(gameStatsNode);
				
				gameStatsNode = new XML(<{"SelectedItem"}/>);
				gameStatsNode.@Item1 = sephiusItem1;
				gameStatsNode.@Item2 = sephiusItem2;
				GMXML.appendChild(gameStatsNode);
				
				gameStatsNode.@Item1 = sephiusItem1;
				gameStatsNode.@Item2 = sephiusItem2;
				GMXML.appendChild(gameStatsNode);
				
				gameStatsNode = new XML(<{"SelectedWeapon"}/>);
				gameStatsNode.@Weapon1 = sephiusWeapon1;
				gameStatsNode.@Weapon2 = sephiusWeapon2;
				GMXML.appendChild(gameStatsNode);	
				
				gameStatsNode = new XML(<{"Attributes"}/>);
				gameStatsNode.@level				= 0;
				gameStatsNode.@peripheralEssence 	= -1;
				gameStatsNode.@deepEssence 	 		= 0;
				gameStatsNode.@mysticalEssence 		= -1;
				GMXML.appendChild(gameStatsNode);
				
				GMXML.appendChild(barriersNode);
				GMXML.appendChild(receptaclesNode);
				GMXML.appendChild(rewardsNode);
				
				for each (item in sephiusInitialHeldItemList){
					itemNode = new XML(<{"Item"}/>);
					
					itemNode.@varName = item.varName;
					itemNode.@amount = item.amount;
					itemNode.@remainingColdDownTime = item.remainingColdDownTime;
					itemNode.@equiped = item.equiped; 

					itemsNode.appendChild(itemNode);
				}
				invNode.appendChild(itemsNode);
				
				for each (weapons in sephiusInitialHeldWeaponsList){
					weaponNode = new XML(<{"Weapon"}/>);
					weaponNode.@varName = weapons.varName;
					
					weaponsNode.appendChild(weaponNode);
				}
				invNode.appendChild(weaponsNode);
				
				for each (memo in sephiusInitialHeldMemoList){
					memoNode = new XML(<{"Memo"}/>);
					memoNode.@varName = memo.varName;
					
					memosNode.appendChild(memoNode);
				}
				invNode.appendChild(memosNode);
				
				for each (nature in Natures.ALL_MYSTIC_NATURES){
					spellNode = new XML(<{"Nature"}/>);
					spellNode.@nature = nature;
					spellNode.@amplification = sephiusInitialNatureAmplifications[nature];
					
					spellsNode.appendChild(spellNode);
				}
				invNode.appendChild(spellsNode);
				
				GMXML.appendChild(invNode);
				
				//return GMXML;
			}
			else {
				gameStatsNode = new XML(<{"NumberOfLoads"}/>);
				gameStatsNode.@value = numberOfLoads;
				GMXML.appendChild(gameStatsNode);
				
				gameStatsNode = new XML(<{"NumberOfDeaths"}/>);
				gameStatsNode.@value = numberOfDeaths;
				GMXML.appendChild(gameStatsNode);
				
				gameStatsNode = new XML(<{"TimePlayed"}/>);
				gameStatsNode.@value = player.presence.totalTimePlayedNumber;
				GMXML.appendChild(gameStatsNode);
				
				gameStatsNode = new XML(<{"DistanceTraveled"}/>);
				gameStatsNode.@value = player.presence.distanceTraveled;
				GMXML.appendChild(gameStatsNode);
				
				gameStatsNode = new XML(<{"HelpsListened"}/>);
				
				listNelp = [];
				
				var hProperty:HelpProperties;
				for each(hProperty in HelpProperties.PROPERTIES_LIST) {
					if (player.archivemnets.listenedHelps[hProperty.varName].listened) {
						helpsListened.push(hProperty.varName);
						listNelp.push(hProperty.varName);
					}
				}
				
				if(listNelp.length > 0){
					gameStatsNode.@value = listNelp.join(",");
					GMXML.appendChild(gameStatsNode);
				}
				
				gameStatsNode = new XML(<{"StoryTellerslistened"}/>);
				
				listNelp = [];
				var sProperty:StoryTellerProperties;
				for each(sProperty in StoryTellerProperties.PROPERTIES_LIST) {
					if (player.archivemnets.listenedStoryTellers[sProperty.varName].listened) {
						storyTellerslistened.push(sProperty.varName);
						listNelp.push(sProperty.varName);
					}
				}
				
				if(listNelp.length > 0){
					gameStatsNode.@value = listNelp.join(",");
					GMXML.appendChild(gameStatsNode);
				}
				
				gameStatsNode = new XML(<{"Cutsceneslistened"}/>);
				
				listNelp = [];
				var cProperty:CutsceneProperties;
				for each(cProperty in CutsceneProperties.PROPERTIES_LIST) {
					if (player.archivemnets.listenedCutscenes[cProperty.varName].listened) {
						cutsceneslistened.push(cProperty.varName);
						listNelp.push(cProperty.varName);
					}
				}
				
				if(listNelp.length > 0){
					gameStatsNode.@value = listNelp.join(",");
					GMXML.appendChild(gameStatsNode);
				}
				
				gameStatsNode = new XML(<{"GameCicles"}/>);
				gameStatsNode.@value = currentGameCicle;
				GMXML.appendChild(gameStatsNode);
				
				gameStatsNode = new XML(<{"RegionBase"}/>);
				gameStatsNode.@areaGlobalID = player.presence.lastRegionBase.areaGlobalID;
				gameStatsNode.@locallID = player.presence.lastRegionBase.locallID;
				GMXML.appendChild(gameStatsNode);
				
				gameStatsNode = new XML(<{"MapLocations"}/>);
				GMXML.appendChild(gameStatsNode);
				var mapLocationID:String;
				for each (mapLocationID in _mapLocations){
					itemNode = new XML(<{"MapLocation"}/>);
					
					itemNode.@globalID = mapLocationID;
					
					gameStatsNode.appendChild(itemNode);
				}
								
				gameStatsNode = new XML(<{"SiteMapLocations"}/>);
				GMXML.appendChild(gameStatsNode);
				var siteMapLocationID:String;
				for each (siteMapLocationID in _siteMapLocations){
					itemNode = new XML(<{"SiteMapLocation"}/>);
					
					itemNode.@siteName = siteMapLocationID;
					
					gameStatsNode.appendChild(itemNode);
				}
								
				gameStatsNode = new XML(<{"SelectedSpell"}/>);
				gameStatsNode.@Spell1 = player.hud.selectedSpell1;
				gameStatsNode.@Spell2 = player.hud.selectedSpell2;
				GMXML.appendChild(gameStatsNode);
				
				gameStatsNode = new XML(<{"SelectedItem"}/>);
				gameStatsNode.@Item1 = player.hud.selectedItem1;
				gameStatsNode.@Item2 = player.hud.selectedItem2;
				GMXML.appendChild(gameStatsNode);
				
				gameStatsNode = new XML(<{"SelectedWeapon"}/>);
				gameStatsNode.@Weapon1 = player.hud.selectedWeapon1;
				gameStatsNode.@Weapon2 = player.hud.selectedWeapon2;
				GMXML.appendChild(gameStatsNode);	
				
				/*for each(item in player.inventory.itemsEquipedSorted){
					itemNode = new XML(<{"Item"}/>);
					itemNode.@varName = item.property.varName;
					
					itemsEquipedNode.appendChild(itemNode);
				}
				GMXML.appendChild(itemsEquipedNode);	*/
				
				gameStatsNode = new XML(<{"Attributes"}/>);
				gameStatsNode.@level				 	= player.characterAttributes.level - AttributesConstants.baseLevel;
				gameStatsNode.@peripheralEssence		= player.characterAttributes.peripheralEssence.toFixed();
				gameStatsNode.@deepEssence 		 		= player.characterAttributes.deepEssence.toFixed();
				gameStatsNode.@mysticalEssence 	 		= player.characterAttributes.mysticalEssence.toFixed();	
				GMXML.appendChild(gameStatsNode);
				
				gameStatsNode = new XML(<{"Status"}/>);
				gameStatsNode.@times = player.statusAttributes.status.times;
				gameStatsNode.@statusConditions = player.statusAttributes.status.statusConditions;
				GMXML.appendChild(gameStatsNode);
				
				gameStatsNode = new XML(<{"LastSafetySituation"}/>);
				gameStatsNode.@x = player.x;
				gameStatsNode.@y = player.y;
				gameStatsNode.@action = player.action.varName;
				gameStatsNode.@rotation = player.rotation;
				gameStatsNode.@velocity = player.velocity;
				GMXML.appendChild(gameStatsNode);
				
				for each (item in barriersClosed) {
					if(!(Barriers.BARRIERS_BY_ID[item] as TriggeredBarrier)){	
						barrierNode = new XML(<{"BarriersClosed"}/>);
						barrierNode.@globalID =  Barriers.BARRIERS_BY_ID[item].globalID;
						barrierNode.@state =  Barriers.BARRIERS_BY_ID[item].state.varName;
						
						barriersNode.appendChild(barrierNode);
					}
				}
				
				for each (item in barriersOpened) {
					if(!(Barriers.BARRIERS_BY_ID[item] as TriggeredBarrier)){
						barrierNode = new XML(<{"BarriersOpened"}/>);
						barrierNode.@globalID = Barriers.BARRIERS_BY_ID[item].globalID;
						barrierNode.@state =  Barriers.BARRIERS_BY_ID[item].state.varName;
						
						barriersNode.appendChild(barrierNode);
					}
				}
				
				GMXML.appendChild(barriersNode);
				
				var key:String;
				var receptacleActivated:Boolean;
				
				for (key in _receptacles) {
				  receptacleActivated = _receptacles[key];
				  
				  // Create a new XML node for each key
				  receptacleNode = new XML(<{"MysticReceptacle"}/>);
				  receptacleNode.@globalID = key;
				  receptacleNode.@receptacleActivated = receptacleActivated;

				  receptaclesNode.appendChild(receptacleNode);
				}				
								
				GMXML.appendChild(receptaclesNode);
				
				rewardsNode.@maxGlobalID = Reward.maxGlobalID;
				
				for each (reward in Reward.rewards){
					if(reward.droped && reward.areaBounded){
						rewardNode = new XML(<{"DropedRewards"}/>);
						rewardNode.@x = reward.x;
						rewardNode.@y = reward.y;
						rewardNode.@group = reward.group;
						rewardNode.@globalID = reward.globalID;
						rewardNode.@areaBoundedID = reward.areaBounded.globalId;
						rewardNode.@rewardType = reward.rewardType;
						rewardNode.@rewardID = reward.rewardID;
						rewardNode.@rewardAmount = reward.rewardAmount;
						rewardsNode.appendChild(rewardNode);
					}
					else if(!reward.droped && reward.collected){
						rewardNode = new XML(<{"CollectedRewards"}/>);
						rewardNode.@globalID = reward.globalID;
						rewardNode.@areaBounded = reward.areaBounded.globalId;
						rewardsNode.appendChild(rewardNode);
					}
				}
				
				GMXML.appendChild(rewardsNode);
				
				for each (item in player.inventory.itemsSorted){
					itemNode = new XML(<{"Item"}/>);
					itemNode.@varName = item.property.varName;
					itemNode.@amount = item.amount;
					itemNode.@remainingColdDownTime = item.remainingColdDownTime;
					itemNode.@equiped = item.equiped; 
					
					itemsNode.appendChild(itemNode);
				}
				
				invNode.appendChild(itemsNode);
				
				for each (weapons in player.inventory.weaponsSorted){
					weaponNode = new XML(<{"Weapon"}/>);
					weaponNode.@varName = weapons.property.varName;
					
					weaponsNode.appendChild(weaponNode);
				}
				
				invNode.appendChild(weaponsNode);
				
				for each (memo in player.inventory.memosSorted){
					memoNode = new XML(<{"Memo"}/>);
					memoNode.@varName = memo.property.varName;
					
					memosNode.appendChild(memoNode);
				}
				
				invNode.appendChild(memosNode);
				
				for each (spell in Natures.ALL_MYSTIC_NATURES){
					spellNode = new XML(<{"Nature"}/>);
					spellNode.@nature = spell;
					spellNode.@amplification = player.characterAttributes.natureAmplifications[spell];
					
					spellsNode.appendChild(spellNode);
				}
				
				invNode.appendChild(spellsNode);
				
				GMXML.appendChild(invNode);				
			}
			return GMXML;
		}
		
		public function saveGame(player:Sephius):void{
			GameFilesUtils.saveSaveData(createGameSaveData(player));
			
			if(player)
				player.hud.gameSaved();
		}
			
		/**
		 * Changes the HUD when Sphius world changes
		 * @param	worldSide_
		 */
		public function changeWorldSide(worldSide_:String):void {
		}
		
		public function resetSavePoints(worldSide_:String):void
		{
		}
		
		public function resetEssenceClouds():void
		{
		}
		
		public function changeBarrier():void
		{
		}
		
		public function changeDamageObjects():void
		{
		}
		
		public function changePlatform():void
		{
		}
		
		public function changeReward():void
		{
		}
		
		public function changePhysicBarrier():void
		{
		}
		
		public function changeReceptacle():void
		{
		}
		
		//Reset all respawners when sephius switch world side.
		public function resetRespawners(worldSide_: String):void
		{
		}
		
		//Change all SephiusEngineSprite arts Light or Darkness
		public function setSpritesArtsType(worldSide_: String):void
		{
		}
		
		//Change all SephiusEngineSprite arts Light or Darkness
		public function resertSpritesArtsType():void
		{
		}
		
		//Change HUD art Light or Darkness
		public function setHUDArtType(worldSide_: String):void
		{
		}
		
		public function update():void{
			sephiusLevel			 = GameEngine.instance.state.mainPlayer.characterAttributes.level;
			sephiusPeripheralEssence = GameEngine.instance.state.mainPlayer.characterAttributes.peripheralEssence;
			sephiusMysticalEssence 	 = GameEngine.instance.state.mainPlayer.characterAttributes.mysticalEssence;
			sephiusDeepEssence 		 = GameEngine.instance.state.mainPlayer.characterAttributes.deepEssence;			
		}
		
		/**
		 * Retrive data from a Object data and convert to a dictionary
		 * Uses to retrive dictionaries from SharedObject.
		 * Param name are converted in a key and values to a a dictionary key value.
		 * @param	object object data
		 * @return
		 */
		public function objectToDictionary(object:Object, valueClass:Class):Dictionary
		{
			var dictionary:Dictionary = new Dictionary();
			
			for (var key:String in object)
			{
				//trace ("dictionary[" + key + "] = " + (object[key] as valueClass) + " class: " + valueClass);
				dictionary[key.toString()] = valueClass(object[key]);
			}
			return dictionary;
		}
		
		/**
		 * Retrive data from a Object data and convert to a dictionary
		 * Uses to retrive dictionaries from SharedObject.
		 * Param name are converted in a key and values to a a dictionary key value.
		 * @param	object object data
		 * @return
		 */
		public function arrayObjectToVectorString(vectorObject:Array):Array
		{
			var arrayString:Array = new Array;
			
			for each(var key:String in vectorObject)
			{
				arrayString.push(key);
			}
			return arrayString;
		}
				/*Useful functions*/
		private static function getRight(value:String):*{
			if ((String(value).indexOf(",")) != -1)
				return value.split(",");	
			else if (value == "true" || value == "false")
				return getBoolean(value);
			else if (!isNaN(Number(String(value).charAt(0))) || ((String(value).charAt(0) == "." || String(value).charAt(0) == "-") && !isNaN(Number(String(value).charAt(1)))))
				return Number(value);	
			else
				return value;
		}
		
		private static function getBoolean(value:String):Boolean {
			if (value == "false")
				return false;
			else
				return true;
		}
	}
}
class PrivateClass {}
