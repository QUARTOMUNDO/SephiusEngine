package SephiusEngine.core.gameStates {
	import SephiusEngine.core.GameData;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.GameState;
	import SephiusEngine.core.effects.ParticleManager;
	import SephiusEngine.core.gameStates.GameTitle;
	import SephiusEngine.core.gameplay.damageSystem.DamageCollisionsManager;
	import SephiusEngine.core.gameplay.inventory.Inventory;
	import SephiusEngine.core.gameplay.properties.objectsInfos.BarrierState;
	import SephiusEngine.core.levelManager.GameOptions;
	import SephiusEngine.core.levelManager.LevelArea;
	import SephiusEngine.core.levelManager.LevelBackground;
	import SephiusEngine.core.levelManager.LevelMaker;
	import SephiusEngine.core.levelManager.LevelRegion;
	import SephiusEngine.core.levelManager.LevelSite;
	import SephiusEngine.core.levelManager.Presence;
	import SephiusEngine.core.levelManager.RegionBase;
	import SephiusEngine.displayObjects.particles.ParticleSystemEX;
	import SephiusEngine.levelObjects.GameObject;
	import SephiusEngine.levelObjects.GamePhysicalSprite;
	import SephiusEngine.levelObjects.interfaces.IInteragent;
	import SephiusEngine.levelObjects.interfaces.IPerceptible;
	import SephiusEngine.math.MathVector;
	import SephiusEngine.sounds.system.components.global.GlobalSoundComponent;
	import SephiusEngine.userInterfaces.UserInterfaces;
	import SephiusEngine.userInterfaces.map.MapLocationIDTypes;

	import flash.system.System;
	import flash.utils.Dictionary;

	import org.osflash.signals.Signal;

	import starling.core.Starling;

	import tLotDClassic.GameData.Properties.CutsceneProperties;
	import tLotDClassic.GameData.Properties.ItemProperties;
	import tLotDClassic.GameData.Properties.SpellProperties;
	import tLotDClassic.GameData.Properties.StatusProperties;
	import tLotDClassic.attributes.AttributesConstants;
	import tLotDClassic.gameObjects.activators.Pyra;
	import tLotDClassic.gameObjects.barriers.Barriers;
	import tLotDClassic.gameObjects.barriers.TriggeredBarrier;
	import tLotDClassic.gameObjects.characters.Characters;
	import tLotDClassic.gameObjects.characters.Sephius;
	import tLotDClassic.gameObjects.characters.Spawner;
	import tLotDClassic.gameObjects.rewards.Reward;
	import tLotDClassic.motionTracksDatas.AekonMTD;
	import tLotDClassic.motionTracksDatas.AlkamoKnightMTD;
	import tLotDClassic.motionTracksDatas.AlkathoMysticMTD;
	import tLotDClassic.motionTracksDatas.PlathanusBudMTD;
	import tLotDClassic.motionTracksDatas.PlathanusDarkMTD;
	import tLotDClassic.motionTracksDatas.PlathanusLightMTD;
	import tLotDClassic.ui.debug.DebugControls;
	import tLotDClassic.GameData.Properties.StoryTellerProperties;
	
	/**
	 * This class should menage levels loading, removing, add/remove to state areas and other Level processing.
	 * @author Fernando Rabello
	 */
	public class LevelManager extends GameState {
		public static var verbose:Boolean = true;
		
		private static var _instance:LevelManager;
		
		/** A Level Region contains all level áreas and other informations.
		 * Each Region is a entire game play or game chapter so to speaking.*/
		public var levelRegion:LevelRegion;
		
		public var levelRegionURL:String = "";
		
		/** Reference to GameEngine class */
		protected static var _main:GameEngine;
		
		public var barriers:Vector.<Barriers> = new Vector.<Barriers>();
		public var perceptibles:Vector.<IPerceptible> = new Vector.<IPerceptible>();
		public var objectsPerceived:Vector.<IPerceptible> = new Vector.<IPerceptible>();
		public var iteragents:Vector.<IInteragent> = new Vector.<IInteragent>();
		
		public var onAreaAdded:Signal = new Signal(LevelArea);
		public var onAreaRemoved:Signal = new Signal(LevelArea);
		public var onBackgroundChanged:Signal = new Signal(LevelBackground);
		
		/** Dispach a signal when all areas added was fully loaded */
		public var onAllAreasLoaded:Signal = new Signal();
		/** Dispach a signal when all areas added was fully loaded */
		public var onAllAreasNotLoaded:Signal = new Signal();
		
		public var areasAdded:Vector.<LevelArea> = new Vector.<LevelArea>();
		public var areasLoading:Vector.<LevelArea> = new Vector.<LevelArea>();
		public var areasPerceived:Vector.<LevelArea> = new Vector.<LevelArea>();
		
		/** Background witch is being shown */
		public var currentBackground:LevelBackground;
		public var backgroundLoading:Boolean;
		
		/** This class is a "singleton" there should be only 1 instance of it on the game. */
		static public function getInstance():LevelManager { return _instance; }
		
		public var storyTellerSoundComponent:GlobalSoundComponent;
		
		public function LevelManager(levelRegion_:LevelRegion) {
			super();
			_main = GameEngine.instance;
			onPlayingChange.add(pauseResumeTweens);
			_instance = this;
			levelRegion = levelRegion_;
			
			storyTellerSoundComponent = new GlobalSoundComponent("StoryTeller");
			_main.sound.soundSystem.registerComponent(storyTellerSoundComponent);
			
			onAreaAdded.add(GameEngine.instance.state.globalEffects.addAreaEffects);
			onAreaRemoved.add(GameEngine.instance.state.globalEffects.removeAreaEffects);
			
			// Adding packs this state uses to be loaded on the initialize function
			texturePacksUsed.push("Hud", "ItemIcon", "Rewards", "Menu", "SpellIcon", "WeaponIcon", "MemoIcon", "Essence", "Projectles");
			//texturePacksUsed.push("SiteAncientRuins", "SiteAncientRuinsBG", "SiteBurningLair", "SiteDarkDeeps", "SiteDeathPlains", "SiteDeathPlainsBG");
			//texturePacksUsed.push("noprotoneLokmoKnight", "noprotoneLokmoRanger", "noprotoneLokmoWarrior", "plathanusBudDark", "plathanusBudLight", "plathanusDark");
			if(DebugControls.debugEnabled)
				texturePacksUsed.push("Debug");
		}
		
		/**Initialize the level*/
		override public function initialize():void {
			super.initialize();
			
			Starling.current.showStats = GameOptions.SHOW_STATS;
			
			LevelMaker.processLevelRegion(levelRegion, prepareGame);
		}
		
		public function prepareGame():void {
			var initalArea:uint = GameData.getInstance().startingRegionBase[0];
			var localBase:uint = GameData.getInstance().startingRegionBase[1];
			
			if(levelRegion.basesByArea[initalArea].length == 0) {
				trace ("Area " + initalArea + " has no region base with this ID. Can´t start on this area. Starting using globalID");
				GameData.getInstance().currentRegionBase = levelRegion.bases[0].globalID;
			}
			else {
				if(levelRegion.basesByArea[initalArea].length <= localBase)
					localBase = levelRegion.basesByArea[initalArea].length - 1;
				
				GameData.getInstance().currentRegionBase = levelRegion.basesByArea[initalArea][localBase].globalID;
			}
			
			player1 = new Sephius("Sephius1", verifyStateReady, {level:GameData.getInstance().sephiusLevel}, 0);
			//player2 = new Sephius("Sephius2", {level:GameData.getInstance().sephiusLevel}, 1);
			mainPlayer = player1;
			
			player1.onGameSetted.addOnce(verifyStateReady);
			
			//Init UI elements
			UserInterfaces.instance.init();
			userInterfaces.gameMap.addObjectMapLocation(mainPlayer as GamePhysicalSprite, MapLocationIDTypes.TYPE_PLAYER_LOCATION, "Sephius");
			
			//disabled. Not sites maps are enables by collecting cartographer memos
				//mainPlayer.presence.onPlaceSiteChanged.add(userInterfaces.gameMap.enableSiteMap);
				//userInterfaces.gameMap.enableSiteMap(mainPlayer.presence.placeSite);

			var regionBase:RegionBase = levelRegion.bases[GameData.getInstance().currentRegionBase];
			mainPlayer.presence.lastRegionBase = regionBase;
			mainPlayer.presence.lastPlaceArea = levelRegion.unknownArea;
			mainPlayer.presence.placeArea = levelRegion.areas[levelRegion.areaMap.getAreaID(regionBase.x, regionBase.y)];
			mainPlayer.presence.placeNature = levelRegion.lumaMap.getPlaceNature(regionBase.x, regionBase.y);
			mainPlayer.presence.previousPlayedNumber = GameData.getInstance().timePayed;
			mainPlayer.presence.distanceTraveled = GameData.getInstance().distanceTraveled;
			
			mainPlayer.presence.onPlaceAreaChanged.add(resertSpawnerWaves);
			
			if(player2) {
				player2.presence.lastRegionBase = regionBase;
				player2.presence.lastPlaceArea = levelRegion.unknownArea;
				player2.presence.placeArea = levelRegion.areas[levelRegion.areaMap.getAreaID(regionBase.x, regionBase.y)];
				player2.presence.placeNature = levelRegion.lumaMap.getPlaceNature(regionBase.x, regionBase.y);
			}
			
			GameEngine.instance.state.view.camera.setUp(mainPlayer, new MathVector(0, 0), null, new MathVector(0.1, 0.1));
			GameEngine.instance.state.view.camera.reset();
			
			view.camera.presence.onPlaceSiteChanged.add(changeBackgroundBySiteName);
			view.camera.presence.onPlaceSiteChanged.add(GameEngine.instance.state.globalEffects.menageBackgroundEffects);
			view.camera.presence.lastRegionBase = regionBase;
			view.camera.presence.lastPlaceArea = levelRegion.unknownArea;
			view.camera.presence.placeArea = levelRegion.areas[levelRegion.areaMap.getAreaID(regionBase.x, regionBase.y)];
			view.camera.presence.placeNature = levelRegion.lumaMap.getPlaceNature(regionBase.x, regionBase.y);
			
			if(!mainPlayer.hud.characterInfoVisible){
				mainPlayer.hud.showHUD();
			}
			
			
			//GameEngine.instance.state.globalEffects.FLYING_OBJECTS = !GameOptions.DISABLE_FLYING_OBJECTS;
			GameOptions.GRAPHIC_RESOLUTION = GameOptions.GRAPHIC_RESOLUTION;
			GameOptions.ANTI_ALAISING = GameOptions.ANTI_ALAISING;
			//GameOptions.DISABLE_MUSIC = true;
			
			GameEngine.instance.state.globalEffects.SUN_EFFECT = !GameOptions.DISABLE_SUN;
			GameEngine.instance.state.globalEffects.FOG_EFFECT = !GameOptions.DISABLE_FOG;
			GameEngine.instance.state.globalEffects.RAIN_EFFECT = !GameOptions.DISABLE_RAIN;
			GameEngine.instance.state.globalEffects.AURORA_EFFECT = !GameOptions.DISABLE_AURORA;
			GameEngine.instance.state.globalEffects.LIGHT_EFFECT = true;
			GameEngine.instance.state.globalEffects.BLUR_EFFECT = !GameOptions.DISABLE_BLUR_EFFECTS;;
			GameEngine.instance.state.globalEffects.screenDephofField(!GameOptions.DISABLE_DOF_EFFECT);
			GameEngine.instance.state.globalEffects.screenNoise(!GameOptions.DISABLE_NOISE_EFFECT);
			GameEngine.instance.state.globalEffects.nullFilter();
			
			//Force compilation of MTD classes
			AekonMTD;
			AlkamoKnightMTD;
			AlkathoMysticMTD;
			PlathanusBudMTD;
			PlathanusDarkMTD;
			PlathanusLightMTD;
			
			//GameOptions.DISABLE_BLUR_EFFECTS = true;
			GameEngine.instance.state.globalEffects.setRamdomEnviroment();
			
			onNextStep.add(DamageCollisionsManager.update);
			onNextStep.add(GameEngine.instance.state.globalEffects.updateEnvironment);
			onNextStep.add(verifyPresences);
			
			verifyPresences(0);
			
			System.gc(); 

			if (!mainPlayer.archivemnets.listenedCutscenes[CutsceneProperties.SEPHIUS_RISING.varName].listened)
				UserInterfaces.instance.cutscene.show(CutsceneProperties.SEPHIUS_RISING.varName);
		}
		
		/** Define game initial values */
		public function setGameState(player:Sephius):void {
			// Create Effects
			add(GameEngine.instance.state.globalEffects.particles);
			ParticleSystemEX.defaultJuggler = GameEngine.instance.state.gameJuggler;

			add(mainPlayer);

			var item:Object;
			
			for each(item in GameData.getInstance().helpsListened) {
				player.archivemnets.listenedHelps[item].listened = true;
			}
			
			for each(item in GameData.getInstance().storyTellerslistened) {
				player.archivemnets.listenedStoryTellers[item].listened = true;
			}
			
			for each(item in GameData.getInstance().cutsceneslistened) {
				player.archivemnets.listenedCutscenes[item].listened = true;
			}
			
			player.characterAttributes.deepEssence = GameData.getInstance().sephiusDeepEssence;
			player.characterAttributes.peripheralEssence = GameData.getInstance().sephiusPeripheralEssence == -1 ? player.characterAttributes.maxPeripheralEssence : GameData.getInstance().sephiusPeripheralEssence;
			player.characterAttributes.mysticalEssence = GameData.getInstance().sephiusMysticalEssence == -1 ? player.characterAttributes.maxMysticalEssence : GameData.getInstance().sephiusMysticalEssence;
			player.characterAttributes.natureAmplifications = GameData.getInstance().sephiusNatureAmplifications;
			
			for each(item in GameData.getInstance().sephiusHeldItems) {
				if(item != ItemProperties.NONE){
					player.inventory.addObject(item.varName, Inventory.TYPE_ITEM, item.amount, item.equiped, false);
				}
			}
			
			for each(item in GameData.getInstance().sephiusHeldWeapons) {
				player.inventory.addObject(item.varName, Inventory.TYPE_WEAPON, item.amount, false, false);
			}
			for each(item in GameData.getInstance().sephiusHeldSpells) {
				player.inventory.addObject(item.varName, Inventory.TYPE_SPELL, item.amount, false, false);
			}
			for each(item in GameData.getInstance().sephiusHeldMemos) {
				player.inventory.addObject(item.varName, Inventory.TYPE_MEMO, item.amount, false, false);
			}

			/** Equiping item. Need to also implement equip of weapons and natures!!*/
			for each(item in GameData.getInstance().equipedItems) {
				player.inventory.equipObject(item as String, Inventory.TYPE_ITEM);
			}
			
			//Set coulddownls
			for each(item in GameData.getInstance().cooldowns) {
				player.items.heldItems[item.varName].disabled = true;
				player.items.heldItems[item.varName].cooldown = item.cooldown;
			}
			
			for (item in GameData.getInstance().rewardsByID) {
				Reward.rewardsByID[item] = true;
			}
			
			var newReward:Reward;
			var newRewardParams:Object;Reward.rewardsByID
			for (item in GameData.getInstance().rewardsDroped) {
				newRewardParams = GameData.getInstance().rewardsDroped[item];
				newRewardParams.areaBounded = levelRegion.areas[newRewardParams.areaBoundedID];
				newReward = new Reward(newRewardParams.globalID, newRewardParams, [0, 0], true);
				LevelManager.getInstance().levelRegion.areas[newRewardParams.areaBoundedID].addObject(newReward);
			}
			
			for each(item in GameData.getInstance().barriersOpened) {
				Barriers.BARRIERS_BY_ID[item].state = BarrierState.OPENED;
			}
			
			for each(item in GameData.getInstance().barriersClosed) {
				Barriers.BARRIERS_BY_ID[item].state = BarrierState.CLOSED;
			}

			var spell1:String = GameData.getInstance().sephiusSpell1;
			var Nullvarname:String = SpellProperties.NULL.varName;
			var spellsInventory:Dictionary = player.inventory.spells;
			if(GameData.getInstance().sephiusSpell1 != SpellProperties.NULL.varName)
				player.spells.spell1 = player.inventory.spells[GameData.getInstance().sephiusSpell1].property;
			
			if(GameData.getInstance().sephiusSpell2 != SpellProperties.NULL.varName)	
				player.spells.spell2 = player.inventory.spells[GameData.getInstance().sephiusSpell2].property;
			
			if(GameData.getInstance().sephiusItem1 != ItemProperties.NONE.varName)	
				player.items.item1 = player.inventory.items[GameData.getInstance().sephiusItem1];
			
			if(GameData.getInstance().sephiusItem2 != ItemProperties.NONE.varName)	
				player.items.item2 = player.inventory.items[GameData.getInstance().sephiusItem2];
			
			if(GameData.getInstance().sephiusWeapon1)	
				player.weapons.weapon1 = player.inventory.weapons[GameData.getInstance().sephiusWeapon1];
			
			if(GameData.getInstance().sephiusWeapon2)	
				player.weapons.weapon2 = player.inventory.weapons[GameData.getInstance().sephiusWeapon2];
			
			if(player.hud)
				player.hud.reset();
		}
		
		override public function get mainPlayer():Sephius {return super.mainPlayer;}
		override public function set mainPlayer(value:Sephius):void {
			if (_mainPlayer){
				_mainPlayer.presence.onPlaceSiteChanged.remove(changeGameMusicBySite);
				_mainPlayer.presence.onPlaceNatureChanged.remove(changeWorldNature);
			}
			
			super.mainPlayer = value;
			
			_mainPlayer.presence.onPlaceSiteChanged.add(changeGameMusicBySite);
			_mainPlayer.presence.onPlaceNatureChanged.add(changeWorldNature);
			changeWorldNature(_mainPlayer.presence.placeNature);
			changeGameMusicBySite(_mainPlayer.presence.placeSite);
		}
		
		public var worldNature:String = "Light";
		public function changeWorldNature(nature:String):void{
			worldNature = nature;
			if(userInterfaces.storyUI)
				userInterfaces.storyUI.skin = nature;
		}
		
		public function changeGameMusicByName(songName:String):void {
			GameEngine.instance.soundComponent.fadeOutAll(2);
			GameEngine.instance.soundComponent.play(songName, "BGFX", 0.6, true);
		}
		
		public function changeGameMusicBySite(site:LevelSite):void {
			GameEngine.instance.soundComponent.fadeOutAll(2);
			
			if (site == null)
				return;
			
			if (site.bgm && site.bgm != "")
				GameEngine.instance.soundComponent.play(site.bgm, "Site", .6, true);
			if (site.bgfx && site.bgfx != "")
				GameEngine.instance.soundComponent.play(site.bgfx, "BGFX", 0.6, true);
		}
		
		/** Teleport character to its next or previous region base */
		public function teleportToNextBase(character:Characters, count:int=1):void {
			var currentBase:RegionBase = character.presence.lastRegionBase;
			var step:int = count < 0 ? -1 : 1;
			var newAreaID:int = -1;
			while (count != 0) {
				trace("1///areaGlobalID: " + (currentBase.areaGlobalID) + " / locallID:" + (currentBase.locallID + step))
				if (step > 0){
					//Greater than the amount of bases on current area
					if ((currentBase.locallID + 1) > levelRegion.basesByArea[currentBase.areaGlobalID].length - 1) {
						newAreaID = currentBase.areaGlobalID; 
						currentBase = null;
						while (!currentBase){
							newAreaID = ((newAreaID + 1) > (levelRegion.areas.length - 1)) ? 0 : newAreaID + 1; //Last area
							newAreaID = (newAreaID > (levelRegion.basesByArea.length - 1)) ? 0 : newAreaID; // Last area that have bases
							
							if (levelRegion.basesByArea[newAreaID])//If there is no base on this area	
								currentBase = levelRegion.basesByArea[newAreaID][0]; // first base from new area
						}
					}
					else {
						currentBase = levelRegion.basesByArea[currentBase.areaGlobalID][currentBase.locallID + 1];
					}
				}
				else if (step < 0) {
					// Before the first base of this area
					if ((currentBase.locallID - 1) < 0) {
						newAreaID = currentBase.areaGlobalID;
						currentBase = null;
						while (!currentBase) {
							newAreaID = ((newAreaID - 1) < 0) ? levelRegion.basesByArea.length - 1 : newAreaID - 1; // First area
							//newAreaID = (newAreaID < 0) ? levelRegion.basesByArea.length - 1 : newAreaID; // First area that has bases

							if (levelRegion.basesByArea[newAreaID]) // If there is a base on this area
								currentBase = levelRegion.basesByArea[newAreaID][levelRegion.basesByArea[newAreaID].length - 1]; // Last base from the new area
						}
					}
					// Inside the limit
					else {
						currentBase = levelRegion.basesByArea[currentBase.areaGlobalID][currentBase.locallID - 1];
					}
				}
				
				if(count < 0)
					count++;
				else if (count > 0)
					count--;
			}
			
			if (!currentBase.teleportable){
				character.presence.lastRegionBase = currentBase;
				teleportToNextBase(character, step)
				return;
			}
			
			character.x = currentBase.x;
			character.y = currentBase.y;
			character.presence.lastRegionBase = currentBase;
			GameEngine.instance.state.view.camera.reset();
		}
		
		public function teleportToLastBase(character:Characters):void {
			character.x = character.presence.lastRegionBase.x;
			character.y = character.presence.lastRegionBase.y;
			character.velocity.x = character.velocity.y = 0;
			GameEngine.instance.state.view.camera.reset();
		}
		
		override protected function _onMainPlayerDeath(mainPlayer:Characters):void {
			super._onMainPlayerDeath(mainPlayer);
		}

		public var maximumNumberOfDeaths:int = 3;
		override public function set restartTimer(value:Number):void {
			super.restartTimer = value;
			//Resert the Game
			
			if (restartTimer <= 0 && !reseted && gameOverType == GAMEOVER_TYPE_PLAYER_DEATH) {
				teleportToLastBase(mainPlayer);
				_mainPlayer.statusAttributes.status.applyStatus(StatusProperties.damageInvunerable, true);
				_mainPlayer.characterAttributes.dead = false;
				_mainPlayer.gravityIntensity = 1;
				
				var spawner:Spawner;
				var barrier:Barriers;
				var pyra:Pyra;
				for each(hArea in areasAdded) {
					for each (spawner in hArea.spawners) {
						spawner.removeAllCreatures(true);
					}
					for each (barrier in hArea.barriers) {
						if(barrier as TriggeredBarrier)
							barrier.state = BarrierState.OPENED;
					}
					for each (pyra in hArea.pyras) {
						pyra.state = Pyra.STATE_OFF;
					}
				}
				
				changeGameMusicBySite(_mainPlayer.presence.placeSite);
				reseted = true;
			}
			else if (restartTimer <= 0 && !reseted && gameOverType == GAMEOVER_TYPE_BOSS_DEATH) {
				GameEngine.instance.replaceState(new GameTitle());
				GameEngine.instance.soundComponent.fadeOutAll(2, true);
				reseted = true;
			}
		}
		
		override public function cutsceneReset():void {
			super.cutsceneReset();
			GameEngine.instance.replaceState(new GameTitle());
			GameEngine.instance.soundComponent.fadeOutAll(2, true);
			reseted = true;
		}
		
		override public function add(object:GameObject):GameObject {
			if (object.addedToState)
				return object;
			
			super.add(object);
			
			if (object as Sephius)
				trace("=============SEPHIUS ADDED TO STATE==============");

			if (object as ParticleManager)
				trace("=============ParticleManager ADDED TO STATE==============");

			if (object as Barriers)
				barriers.push(object as Barriers);
			
			if (object as IPerceptible)
				perceptibles.push(object as IPerceptible);
			
			return object;
		}
		
		override public function remove(object:GameObject):void {
			if (!object.addedToState){
				//trace("object: " + object.varName + " was already removed. Why??");
				return;
			}
			
			super.remove(object);
			
			if (object as Barriers)
				barriers.splice(barriers.indexOf(object as Barriers), 1);
			
			if (object as IPerceptible)
				perceptibles.splice(perceptibles.indexOf(object as IPerceptible), 1);
		}
		
		/** Add or remove a area to current state by area global ID */
		public function addOrRemoveAreaByGlobalID(areaGlobalID:uint, addOrRemove:Boolean):void {
			if (areaGlobalID == levelRegion.unknownArea.globalId)
				return;
				
			if (levelRegion.areas.length < areaGlobalID)
				throw Error("Area ID is greater than the number of areas existing in current Level Region");
			
			if (addOrRemove && !levelRegion.areas[areaGlobalID].added) {
				trace("LEVELMANAGER adding Area " + areaGlobalID);	
				addAreaLoading(levelRegion.areas[areaGlobalID]);
				
				levelRegion.areas[areaGlobalID].addToState();
			}
			else if (!addOrRemove && levelRegion.areas[areaGlobalID].added) {
				trace("LEVELMANAGER removing Area " + areaGlobalID);
				
				OnAreaReady(levelRegion.areas[areaGlobalID]);
				
				onAreaRemoved.dispatch(levelRegion.areas[areaGlobalID]);
				areasAdded.splice(areasAdded.indexOf(levelRegion.areas[areaGlobalID]), 1);
				
				levelRegion.areas[areaGlobalID].removeFromState();
			}
		}
		
		/** Remove current background and add another to the state */
		public function changeBackground(background:LevelBackground):void {
			if (background == currentBackground || !background)
				return;
			
			trace("LEVELMANAGER Changing BG" + " old:" + (currentBackground ? currentBackground.site : "none") + " new:" + background.site);
			
			var object:GameObject;
			
			if (currentBackground) {
				currentBackground.removeFromState();
			}
			
			currentBackground = background;
			currentBackground.addToState();
			onBackgroundChanged.dispatch(currentBackground);
			
			if (!currentBackground.texturesLoaded){
				currentBackground.texturesLoaded = false;
				currentBackground.onTexturesLoaded.addOnce(removeBGLoading);
			}
			verifyStateReady();
		}
		
		/** Remove current background and add another to the state */
		public function changeBackgroundBySiteName(site:LevelSite):void {
			changeBackground(site.backGround);
		}
		
		/** ----------------------------------------------------- */
		/** --------------------- Assets Loading ----------------- */
		/** ----------------------------------------------------- */
		
		/** Set state as ready if all assets needed to state run gets loaded.
		 * In this case, the state textures, the bg textures and the textures for all areas added to the state. */
		public function verifyStateReady(item:*=null):void {
			if((currentBackground && currentBackground.texturesLoaded) && _allAreasLoaded && _texturesLoaded && _mainPlayer.loaded && _mainPlayer.gameSetted){
				onReady.dispatch(this);
				isReady = true;
				
				if (!Initialized){
					Initialized = true;
					onInitialized.dispatch(this);
				}
				
				trace ("[LEVELMANAGER] verifyStateReady - State is Ready!!!");
			}
			else{
				onNotReady.dispatch(this);
				isReady = false;
				
				trace ("[LEVELMANAGER] verifyStateReady - State is Waiting to be Ready");
				
				if (currentBackground)
					var currentBackgroundTexsLoaded:Boolean = currentBackground.texturesLoaded;
				if (_mainPlayer){
					var mainPlayerTexsLoaded:Boolean = _mainPlayer.loaded;
					var gameSetted:Boolean = _mainPlayer.gameSetted
				}
				
				trace ("[LEVELMANAGER] verifyStateReady - CurrentBackground's textures Loaded: " + currentBackgroundTexsLoaded);
				trace ("[LEVELMANAGER] verifyStateReady - All Areas is Loaded: " + _allAreasLoaded);
				trace ("[LEVELMANAGER] verifyStateReady - Textures Loaded: " + _texturesLoaded);
				trace ("[LEVELMANAGER] verifyStateReady - Main Player loaded: " + mainPlayerTexsLoaded);
				trace ("[LEVELMANAGER] verifyStateReady - Game Setted: " + gameSetted);
			}
		}
		
		
		/** Says if state textures get loaded */
		override public function set texturesLoaded(value:Boolean):void {
			super.texturesLoaded = value;
			trace("[LEVELMANAGER] States Texture " + (value ? "LOADED" : "NOT LOADED"));
			verifyStateReady();
		}
		
		/** Tell if all areas added to state have they textures loaded. When change dispach signal for each of both states (false or true)*/
		public function get allAreasLoaded():Boolean { return _allAreasLoaded; }
		public function set allAreasLoaded(value:Boolean):void { 
			if (value == allAreasLoaded)
				return;
			
			_allAreasLoaded = value; 
			
			if (!value){
				onAllAreasNotLoaded.dispatch();
				trace("[LEVELMANAGER] ALL AREAS " + (value ? "LOADED" : "NOT LOADED"));
			}
			else {
				onAllAreasLoaded.dispatch();
				trace("[LEVELMANAGER] ALL AREAS " + (value ? "LOADED" : "NOT LOADED"));
			}
			verifyStateReady();
		}
		private var _allAreasLoaded:Boolean;
		
		/** Remove area from a list of areas that is being loaded but was added to this state */
		private function OnAreaReady(area:LevelArea):void {
			if (areasAdded.indexOf(area) == -1){
				removingAreaLoading(area);
				onAreaAdded.dispatch(area);
				areasAdded.push(area);
				trace("[LEVELMANAGER] AREA " + area.globalId + " Removed from Loading List, areasLoading: " + areasLoading.length + printAreasInVector(areasLoading));
			}
		}
		
		/** Remove area from a list of areas that is being loaded but was added to this state */
		private function addAreaLoading(area:LevelArea):void {
			if(areasLoading.indexOf(area) == -1){
				areasLoading.push(area);
				allAreasLoaded = false;
				area.onTexturesLoaded.addOnce(OnAreaReady);
				trace("[LEVELMANAGER] AREA " + area.globalId + " Added from Loading List: areasLoading: " + areasLoading.length + printAreasInVector(areasLoading));
			}
		}
		
		/** Remove area from a list of areas that is being loaded but was added to this state */
		private function removingAreaLoading(area:LevelArea):void {
			if(areasLoading.indexOf(area) != -1){
				areasLoading.splice(areasLoading.indexOf(area), 1);
				
				area.onTexturesLoaded.remove(OnAreaReady);
				
				if (areasLoading.length == 0)
					allAreasLoaded = true;
				trace("[LEVELMANAGER] AREA " + area.globalId + " Added from Loading List: areasLoading" + areasLoading.length + printAreasInVector(areasLoading));
			}
		}
		
		private function printAreasInVector(areas:Vector.<LevelArea>):String{
			var areasString:String = ": ";
			for each (var area:LevelArea in areas){
				areasString += area.globalId + " / ";
			}
			return areasString;
		}
		
		/** Remove area from a list of areas that is being loaded but was added to this state */
		private function removeBGLoading(bg:LevelBackground):void {
			currentBackground.texturesLoaded = true;
			verifyStateReady();
			trace("[LEVELMANAGER] BG " + bg.site + " Removed from Loading List");
		}
				
		/** ----------------------------------------------------- */
		/** ----------------------------------------------------- */
		/** ----------------------------------------------------- */
		
		/**  Update function for Level class  */
		override public function update(timeDelta:Number):void {
			//if (!isReady)
				//return;
			
			super.update(timeDelta);
			
			GameEngine.instance.timeMarks.debugCountCheck(true);
			if (UserInterfaces.instance.debug)
				UserInterfaces.instance.debug.updateDebugs();
								GameEngine.instance.timeMarks.debugCountStepCheck();	
			GameData.getInstance().update();
			
			if(Spawner.waveTime <= Spawner.maxWaveTime)
				Spawner.waveTime++;
			
			//trace("B-LEVELMANGER-RENDER", (mainPlayer ? mainPlayer.characterView.mainAnimation.currentFrame : ""));
		}
		
		public function resertSpawnerWaves(area:LevelArea):void {
			if (area.globalId == 04) {
				Spawner.waveTime = 0;
			}
		}
		
		private var h_areaID:uint
		private var hArea:LevelArea;
		private var hPerceived:IPerceptible;
		private var cPresence:Presence;
		private var vpIndex:uint;
		private var vpIndex2:uint;
		private var waitCount:uint = 0;
		public function verifyPresences(timePassed:Number):void {
			//Perceive Areas
			areasPerceived.length = 0;
			
			for each(hArea in areasAdded) {
				hArea.perceived = false;
			}
			
			for (vpIndex = 0; vpIndex < Presence.PRESENCES_IN_USE.length; vpIndex++) {
				cPresence = Presence.PRESENCES_IN_USE[vpIndex];
				
				if (cPresence.controlLevel && cPresence.placeArea) {
					if (!cPresence.placeArea.perceived && cPresence.placeArea != levelRegion.unknownArea) {
						cPresence.placeArea.perceived = true;
						areasPerceived.push(cPresence.placeArea);
					}
					
					for each(hArea in cPresence.placeArea.adjacentAreas) {
						if (cPresence.useBounds){
							if (hArea.bounds.intersects(cPresence.bounds)) {
								if(!hArea.perceived){
									hArea.perceived = true;
									areasPerceived.push(hArea);
								}
							}
						}
						else {
							if (hArea.bounds.contains(cPresence.positionX, cPresence.positionY)){
								if(!hArea.perceived){
									hArea.perceived = true;
									areasPerceived.push(hArea);
								}
							}
						}
					}
				}
			}
			
			//remove non perceived areas
			for (vpIndex2 = 0; vpIndex2 < areasAdded.length; vpIndex2++) { 
				hArea = areasAdded[vpIndex2];
				if (!hArea.perceived)
					addOrRemoveAreaByGlobalID(hArea.globalId, false);
			}
			
			//Add perceived areas
			for (vpIndex2 = 0; vpIndex2 < areasPerceived.length; vpIndex2++) {
				hArea = areasPerceived[vpIndex2];
				if (!hArea.added)
					addOrRemoveAreaByGlobalID(hArea.globalId, true);
			}
			
			//-----------------------------------------------------------------------------------
			//Perceive Objects
			//We wait a little bit to avoid problems related to objects not being ready yet.
			if (isReady && waitCount < 20)
				waitCount++;
				
			if (isReady && waitCount >= 20){
				objectsPerceived.length = 0;
				var verificationCount:int = 0;
				var i:int = 0;

				//The main goal is to ensure that each frame only processes a limited number of objects 
				//and that over time, all objects are processed.
				while (perceptibles.length > 0 && verificationCount < AttributesConstants.maxPerceptiblesVerificationsPerFrame) {
					hPerceived = perceptibles[0];

					if (verifyPerceptible(hPerceived)) {
						if(!hPerceived.perceived)
							hPerceived.perceived = true;
						
						if(objectsPerceived.indexOf(hPerceived) == -1)
							objectsPerceived.push(hPerceived);
					}
					else{
						if(hPerceived.perceived)
							hPerceived.perceived = false;
						
						if(objectsPerceived.indexOf(hPerceived) != -1)
							objectsPerceived.splice(objectsPerceived.indexOf(hPerceived), 1);
					}

					// Check if this was a verified object and move it to the end.
					// The action of moving it to the end is enough to ensure we don't reprocess it immediately.
					perceptibles.push(perceptibles.splice(i, 1)[0]);

					verificationCount++; // Increment the verification count
				}
			}
		}
		
		/** Return true if given perceptible is being perceived by some presense */
		public function verifyPerceptible(perceptible:IPerceptible):Boolean {
			perceptible.perceivedCount = Presence.PRESENCES_IN_USE.length;
			
			for (vpIndex = 0; vpIndex < Presence.PRESENCES_IN_USE.length; vpIndex++) {
				cPresence = Presence.PRESENCES_IN_USE[vpIndex];
				
				if(!cPresence.perceiveObjects || !perceptible.perceptibleBounds.intersects(cPresence.bounds))
					perceptible.perceivedCount--;
			}
			
			if (perceptible.perceivedCount > 0)
				return true;
			else
				return false;
		}
		
		/** Pause or resume all current tweens. Used when game pauses in order to stop all logic witch uses TweenMax */
		public function pauseResumeTweens(value:Boolean):void {
			//if (value)
				//TweenMax.resumeAll();//ATTENTION this could cause problems...
			//else
				//TweenMax.pauseAll();
			
		}
		
		public function log(message:String):void {
			if (verbose)
				trace("[GLOBAL LEVEL MANAGER]:", message);
		}
		
		override public function destroy():void {
			if (destroyed)
				return;
			
			view.camera.presence.onPlaceSiteChanged.removeAll();
			
			levelRegion.destroy();
			levelRegion = null;
			
			GameEngine.instance.sound.soundSystem.unregisterComponent(storyTellerSoundComponent);
			storyTellerSoundComponent.destroy();
			storyTellerSoundComponent = null;
			
			_main = null;
			
			barriers.length = 0;
			
			onAreaAdded.removeAll();
			onAreaRemoved.removeAll();
			onBackgroundChanged.removeAll();
			
			onAllAreasLoaded.removeAll();
			onAllAreasNotLoaded.removeAll();
			
			onAreaAdded = null;
			onAreaRemoved = null;
			onBackgroundChanged = null;
			
			onAllAreasLoaded = null;
			onAllAreasNotLoaded = null;
			
			areasAdded.length = 0;
			areasLoading.length = 0;
			areasPerceived.length = 0;
			
			currentBackground = null;
			
			GameEngine.instance.state.globalEffects.SUN_EFFECT = false;
			GameEngine.instance.state.globalEffects.FOG_EFFECT = false;
			GameEngine.instance.state.globalEffects.RAIN_EFFECT = false;
			GameEngine.instance.state.globalEffects.AURORA_EFFECT = false;
			
			super.destroy();
			_instance = null;
		}
	}
}