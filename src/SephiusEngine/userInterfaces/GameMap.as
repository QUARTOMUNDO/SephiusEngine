package SephiusEngine.userInterfaces 
{
	import SephiusEngine.core.GameCamera;
	import SephiusEngine.core.GameData;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.levelManager.LevelSite;
	import SephiusEngine.levelObjects.GamePhysicalSprite;
	import SephiusEngine.userInterfaces.map.MapLocation;
	import SephiusEngine.userInterfaces.map.MapLocationIDTypes;
	import SephiusEngine.userInterfaces.map.ObjectMapLocation;
	import SephiusEngine.userInterfaces.map.SiteMap;
	import SephiusEngine.utils.AppInfo;

	import flash.utils.Dictionary;

	import org.osflash.signals.Signal;

	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.QuadBatch;
	import starling.display.Sprite;
	import starling.extensions.brinkbit.fullscreenscreenextension.FullScreenExtension;
	import starling.textures.SubTexture;

	import tLotDClassic.gameObjects.activators.MysticReceptacle;
	import tLotDClassic.gameObjects.activators.Pyra;
	import tLotDClassic.gameObjects.barriers.EnchantedBarrier;
	import tLotDClassic.gameObjects.barriers.SocketBarrier;
	import SephiusEngine.Languages.LanguageManager;
	import SephiusEngine.userInterfaces.map.MapTitle;

	public class GameMap extends Sprite{
		
		private var cMax:Number = .6;
		private var cMin:Number = 0;
		
		private var _mapBorderImage:Image;
		
		private var camera:GameCamera;
		
		/** Pack map name (map)*/
		private var packMapName:String = "GameMap";
		
		/** Border image name (map)*/
		private var borderImageName:String = "GameMap_BGVinhette";
		
		/** Bakcground image name (map)*/
		private var backImageName:String = "GameMap_BGTile";
		
		/** Bakcground image name (map)*/
		private var OblivionLandsBoxImage:String = "GameMap_BoxOblivionLands";
		
		/** Store the map for the existing sites in the game */ 
		public var mapSites:Dictionary = new Dictionary();
				
		/** Store the map for the existing sites in the game */ 
		public var mapTitles:Dictionary = new Dictionary();
				
		/** Vector which store all map locations. Used in update to avoid heavy acess to dictionary */
		public var MapLocations:Vector.<MapLocation> = new Vector.<MapLocation>();
		
		/** Store map locations by their global id. Should be in sync with GameData. 
		 * Some map locations come from Level Files (like pyras and barriers) others are created in runtime by the game mechanics (like obtaining a memo) */ 
		public var MapLocationsByID:Dictionary = new Dictionary();
				
		private var mapsContainer:Sprite = new Sprite();
		private var mapSubContainer:Sprite = new Sprite();
		
		/** Used to transform the map same way the view sistem works */
		private static var stageTest:DisplayObject;
		
		public var backTile:QuadBatch;
		public var backTile2:QuadBatch;
		public var backTileBig:QuadBatch;
		
		public var mapIndicators:Sprite = new Sprite();
		
		public function GameMap(){
			super();
			
			backTile = new QuadBatch;
			backTile2 = new QuadBatch;
			GameEngine.assets.checkInTexturePack(packMapName, null, "GAME_MAP");
			
			_mapBorderImage = new Image(GameEngine.assets.getTexture(borderImageName));
			
			var _mapBackImage:Image;
			var maxI:Number = 3;
			var maxI2:Number = 4;
			var rotated:Boolean = (GameEngine.assets.getTexture(backImageName) as SubTexture).rotated;
			
			_mapBorderImage.alpha = 0;
			_mapBorderImage.x += FullScreenExtension.screenLeft;
			_mapBorderImage.y += FullScreenExtension.screenTop;
			_mapBorderImage.width = FullScreenExtension.screenWidth;
			_mapBorderImage.height = FullScreenExtension.screenHeight;
			
			for (var i:int = -6; i <= 7; i++){
				for(var i2:int = -6; i2 <= 6; i2++){
					_mapBackImage = new Image((GameEngine.assets.getTexture(backImageName) as SubTexture));
					
					_mapBackImage.y = (i2 * _mapBackImage.height) - 1;	
					_mapBackImage.x = (i * _mapBackImage.width) - 1;	

					backTile.addImage(_mapBackImage);
				}
			}
			
			for (i = -2; i <= 2; i++){
				for(i2 = -2; i2 <= 2; i2++){
					_mapBackImage = new Image((GameEngine.assets.getTexture(backImageName) as SubTexture));
					_mapBackImage.y = (i2 * _mapBackImage.height) - 1;	
					_mapBackImage.x = (i * _mapBackImage.width) - 1;	
					backTile2.addImage(_mapBackImage);
				}
			}
			
			backTile.scaleX = backTile.scaleY = 10;
			backTile2.scaleX = backTile2.scaleY = 30;
						
			mapsContainer.addChild(backTile);
			mapsContainer.addChild(backTile2);
			mapsContainer.addChild(mapSubContainer);
			mapsContainer.addChild(mapIndicators);
			
			addChild(mapsContainer);
			addChild(_mapBorderImage);

			LanguageManager.ON_LANG_CHANGED.add(updateLang);
		}
		
		private var oAngle:Number = 0;
		
		private var oPosX:Number = 50400;
		private var oPosY:Number = 17404;
		
		/** Adds a site map to GameMap. Store the map in MapSites dictionary. Map can be retrived by site name. */
		public function addSiteLocation(siteName:String, X:Number, Y:Number, scaleX:Number, scaleY:Number, updateGameData:Boolean = true):void{
			var siteMap:SiteMap = new SiteMap(siteName, X, Y, scaleX, scaleY);
			mapSubContainer.addChild(siteMap)
			mapSites[siteName] = siteMap;

			onMapOnScreen.add(siteMap.showSiteMap);
			
			//Savegame verification
			if(GameData.getInstance().siteMapLocations.indexOf(siteName) != -1)
				siteMap.enabled = true;
		}

		public function addSiteLocationPiece(siteName:String, pieceID:String, X:Number, Y:Number, scaleX:Number, scaleY:Number):void{
			if(!mapSites[siteName])
				throw Error("Site map with name: " + siteName + "don't exist");

			(mapSites[siteName] as SiteMap).addPiece(pieceID, X, Y, scaleX, scaleY);
		}

		/** Add title to game map Title has a frame and a text. */
		public function addSiteLocationTitle(siteName:String, titleID:String, x:Number, y:Number, scaleX:Number, scaleY:Number):void{
			var mapTitle:MapTitle = new MapTitle(titleID, siteName, x, y, scaleX, scaleY);

			mapTitles[siteName] = mapTitle;
			addChild(mapTitle);

			mapSubContainer.addChild(mapTitle);
		}

		/** Add some location to game map, this location could be related to a game object. */
		public function addMapStaticLocation(globalID:String, X:Number, Y:Number, typeID:String, subTypeID:String = "", updateGameData:Boolean = true, inverted:Boolean=false, object:Object = null):void{
			if (globalID == ""){
				if (AppInfo.isDebugBuild)
					throw Error("[GAME MAP] Global ID is Invalid or empty");
				else
					return;
			}

			var secundaryMapLocationTexture:SubTexture;
			if(subTypeID != "" && object){
				var secTexName:String = getSecTexName(typeID, subTypeID, object);
				if (secTexName != "")
					secundaryMapLocationTexture = (GameEngine.assets.getTexture(secTexName) as SubTexture);
			}
			var mapLocationTexture:SubTexture = (GameEngine.assets.getTexture(getTexName(typeID, subTypeID)) as SubTexture);
			var objectMapLocation:MapLocation = new MapLocation(mapLocationTexture, X, Y, typeID, subTypeID, secundaryMapLocationTexture);
			
			objectMapLocation.GlobalID = globalID;
			
			objectMapLocation.alpha = 1;
			objectMapLocation.scaleRatio = 1;
			objectMapLocation.inverted = inverted;
			objectMapLocation.color = 0xebb455;
			
			mapIndicators.addChild(objectMapLocation);
			
			MapLocations.push(objectMapLocation);
			MapLocationsByID[globalID] = objectMapLocation;
			
			if(updateGameData)
				GameData.getInstance().addMapLocations(globalID);
		}
		
		public function removeMapStaticLocation(globalID:String, updateGameData:Boolean = true):void{
			if (globalID == ""){
				if (AppInfo.isDebugBuild)
					throw Error("[GAME MAP] Global ID is Invalid or empty");
				else
					return;
			}
				
			var mapLocation:MapLocation = MapLocationsByID[globalID];
			
			if (!mapLocation)
				return;
				
			if(MapLocations.indexOf(MapLocationsByID[mapLocation]) != -1)
				MapLocations.splice(MapLocations.indexOf(MapLocationsByID[mapLocation]), 1);
				
			if(updateGameData)	
				GameData.getInstance().removeMapLocations(globalID);
			
			MapLocationsByID[globalID].dispose();
			delete MapLocationsByID[globalID];
		}
		
		
		/** Adds a object to be tracked in the map. Store it in a dictionary. */
		public function addObjectMapLocation(object:GamePhysicalSprite, typeID:String, subTypeID:String = ""):void{
			var mapLocationTexture:SubTexture = (GameEngine.assets.getTexture(getTexName(typeID, subTypeID)) as SubTexture);
			var objectMapLocation:ObjectMapLocation = new ObjectMapLocation(mapLocationTexture, object, typeID, subTypeID);
			
			objectMapLocation.GlobalID = object.name;
			
			objectMapLocation.DynamicPosition = true;
			objectMapLocation.dynamicVisual = (typeID == (MapLocationIDTypes.TYPE_PLAYER_LOCATION || MapLocationIDTypes.TYPE_BOSS_LOCATION));
			
			objectMapLocation.alpha = 0;
			mapIndicators.addChild(objectMapLocation);
			
			MapLocations.push(objectMapLocation);
			MapLocationsByID[object] = objectMapLocation;
			
			objectMapLocation.UpdatePosition();
			
			object.onDestroyed.addOnce(removeObjectMapLocation);
		}
		
		public function removeObjectMapLocation(object:GamePhysicalSprite):void{
			object.onDestroyed.remove(removeObjectMapLocation);
			
			if(MapLocations.indexOf(MapLocationsByID[object]) != -1)
				MapLocations.splice(MapLocations.indexOf(MapLocationsByID[object]), 1);
			
			MapLocationsByID[object].dispose();
			delete MapLocationsByID[object];
		}

		public function updateLang(language:String=""):void {
			var mapTitle:MapTitle;
			for each (mapTitle in mapTitles){
				mapTitle.updateLang();
			}
		}

		public function getTexName(type:String, subType:String):String{
			switch (type) {
				case MapLocationIDTypes.TYPE_PYRA:
					if(subType == MapLocationIDTypes.SUBTYPE_LIGHT)
						return "GameMap_PyraLight";
					else
						return "GameMap_PyraDark";
				break;
				
				case MapLocationIDTypes.TYPE_MYSTIC_RECEPTACLE:
					if(subType == MapLocationIDTypes.SUBTYPE_LIGHT)
						return "GameMap_MysticReceptacleLight";
					else
						return "GameMap_MysticReceptacleDark";
				break;
				
				case MapLocationIDTypes.TYPE_MAP_DISCOVERY:
					return "GameMap_InterestPointCross";
				break;
				
				case MapLocationIDTypes.TYPE_BARRIER:
					if(subType == MapLocationIDTypes.SUBTYPE_BLOCKED)
						return "GameMap_BlockedBarrier";
					else if (subType == MapLocationIDTypes.SUBTYPE_MYSTIC)
						return "GameMap_MysticBarrier";
					else if (subType == MapLocationIDTypes.SUBTYPE_SOCKET)
						return "GameMap_SoketBarrier";
					else
						return "GameMap_SoketBarrier";
				break;
				
				case MapLocationIDTypes.TYPE_BOSS_LOCATION:
					return "GameMap_BossLocation";
				break;
				
				case MapLocationIDTypes.TYPE_INTEREST_LOCATION:
					return "GameMap_InterestPointFull";
				break;
				
				case MapLocationIDTypes.TYPE_PLAYER_LOCATION:
					return "GameMap_SephiusLocationLight";
				break;
				
				case MapLocationIDTypes.TYPE_BOSS_LOCATION:
					return "GameMap_BossLocation";
				break;
				
				default: "GameMap_InterestPointParcial";
			}
			
			return "GameMap_InterestPointParcial";
		}
		
		/** Used to show secundary information about the map location, like the key that opens a barrier or what is the last pyra used */
		public function getSecTexName(type:String, subType:String, object:Object):String{
			switch (type) {
				case MapLocationIDTypes.TYPE_PYRA:
					if((object as Pyra) && (object as Pyra).globalID == GameData.getInstance().lastUsedPyra)
						return "GameMap_PyraActivated";
				break;
				
				case MapLocationIDTypes.TYPE_MYSTIC_RECEPTACLE:
					if(object as MysticReceptacle)
						return "GameMap_Icon" + (object as MysticReceptacle).destinySite;
				break;
				
				case MapLocationIDTypes.TYPE_MAP_DISCOVERY:
					return "";
				break;
				
				case MapLocationIDTypes.TYPE_BARRIER:
					if(subType == MapLocationIDTypes.SUBTYPE_BLOCKED)
						return "";
					else if (subType == MapLocationIDTypes.SUBTYPE_MYSTIC){
						if(object as EnchantedBarrier)
							return "GameMap_Symbol"  + (object as EnchantedBarrier).opener; // Nature Symbol
					}
					else if (subType == MapLocationIDTypes.SUBTYPE_SOCKET){
						if(object as SocketBarrier)
							return "GameMap_Socket" + (object as SocketBarrier).opener;
					}
					else
						return "";
				break;
				
				case MapLocationIDTypes.TYPE_BOSS_LOCATION:
					return "";
				break;
				
				case MapLocationIDTypes.TYPE_INTEREST_LOCATION:
					return "";
				break;
				
				case MapLocationIDTypes.TYPE_PLAYER_LOCATION:
					return "";
				break;
				
				default: "";
			}
			
			return "";
		}
		
		public function enableSiteMap(site:LevelSite):void{
			if(mapSites[site.name]){
				mapSites[site.name].enabled = true;
				if (_mapOnScreen){
					mapSites[site.name].showSiteMap(_mapOnScreen, this);
				}
			}
			else	
				if(AppInfo.isDebugBuild)
					throw new Error("There is no Map sLocation for this site: " + site.name);
		}
		
		public function enableSiteMapByName(siteName:String):void{
			if(mapSites[siteName]){
				mapSites[siteName].enabled = true;
				if (_mapOnScreen){
					mapSites[siteName].showSiteMap(_mapOnScreen, this);
				}
			}
			else
				if(AppInfo.isDebugBuild)	
					throw new Error("There is no Map Location with ID: " + siteName);
		}
		
		public function lerp(start:Number, end:Number, percent:Number):Number {
			return (start + percent*(end - start));
		}
		
		public function remap(value:Number, from1:Number, to1:Number, from2:Number, to2:Number):Number {
			return (value - from1) / (to1 - from1) * (to2 - from2) + from2;
		}
		
		public function remapExponential(value:Number, from1:Number, to1:Number, from2:Number, to2:Number, exponent:Number = 2):Number {
			return Math.pow((value - from1) / (to1 - from1), exponent) * (to2 - from2) + from2;
		}	
		
		public function update():void{
			stageTest = GameEngine.instance.state.view.originDysplayObject as DisplayObject;
			mapsContainer.transformationMatrix = stageTest.transformationMatrix.clone();
			mapsContainer.transformationMatrix.concat(GameEngine.instance.state.view.viewRoot.transformationMatrix);
			var parent:DisplayObject = mapsContainer.getChildAt(0);
			var strangeAlpha:Number = (GameEngine.instance.state.view.camera.realZ * ( -1 / (cMax - cMin)) + (cMax / (cMax - cMin))); 
			
			backTile.alpha = 		strangeAlpha
			backTile2.alpha = 		strangeAlpha -.5;  
			_mapBorderImage.alpha = strangeAlpha
			mapSubContainer.alpha = strangeAlpha + 0.2;
			mapIndicators.alpha = strangeAlpha + 0.2;
			
			mapOnScreen = _mapBorderImage.alpha > .2;
			
			var mapLocation:MapLocation;
			for each (mapLocation in MapLocations){
				
				mapLocation.stageScale = remapExponential(mapsContainer.scaleX, 0.01, 0.5, 27, 1, 0.1);
				
				if(mapLocation.dynamicVisual)
					mapLocation.UpdateVisual(strangeAlpha);
					
				if (mapLocation.DynamicPosition)
					mapLocation.UpdatePosition();
			}
		}
		
		override public function dispose():void {
			super.dispose();
			GameEngine.assets.checkOutTexturePack(packMapName, "GAME_MAP");

			mapTitles = null;
			mapSites = null;

			LanguageManager.ON_LANG_CHANGED.remove(updateLang);
		}
		
		public var onMapOnScreen:Signal = new Signal(Boolean, GameMap);
		private var _mapOnScreen:Boolean;
		public function get mapOnScreen():Boolean {return _mapOnScreen;}
		public function set mapOnScreen(value:Boolean):void {
			if (_mapOnScreen == value)
				return;
				
			_mapOnScreen = value;
			onMapOnScreen.dispatch(value, this);
			trace("Map On Screen: ", value)
		}
	}
}