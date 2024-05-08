package SephiusEngine.core.levelManager {
	
	import SephiusEngine.core.levelManager.AreaMap;
	import SephiusEngine.core.levelManager.LevelArea;
	import SephiusEngine.core.levelManager.LevelBackground;
	import SephiusEngine.core.levelManager.LevelSite;
	import SephiusEngine.core.levelManager.LumaMap;
	import SephiusEngine.core.levelManager.RegionBase;
	import air.update.logging.Level;
	import SephiusEngine.levelObjects.GameObject;
	import SephiusEngine.levelObjects.GameSprite;
	import SephiusEngine.core.gameStates.LevelManager;
	import SephiusEngine.userInterfaces.UserInterfaces;
	import flash.utils.Dictionary;
	
	/**
	 * Information about a specified region in the game.
	 * Static constants with default information about some areas.
	 * Region is a group of areas where there no loading between this areas.
	 * Normaly a region is a intire gameplay related with a game chapter.
	 * @author Fernando Rabello
	 */
	public class LevelRegion {
		
		//                  Level                                     				name,					varName					worldNature
		public static const THE_PILLARS:			LevelRegion = new LevelRegion("THE PILLARS",			"THE_PILLARS", 			"Dark", "levels/Pillars_Data");
		public static const DESERT_OF_SIGNS:		LevelRegion = new LevelRegion("DESERT OF SIGNS",		"DESERT_OF_SIGNS", 		"Dark", "levels/DesertOfSigns_Data");
		public static const LANDS_OF_OBLIVION:		LevelRegion = new LevelRegion("LANDS OF OBLIVION",		"LANDS_OF_OBLIVION", 	"Mestizo", "LandsOfOblivion");
		public static const NOPROTHONE_HALUGARDE:	LevelRegion = new LevelRegion("NOPROTHONE HALUGARDE",	"NOPROTHONE_HALUGARDE", "Dark", "levels/Noprotone_Data");
		
		/** Region name in the world represented by this object. The Pillars, Desert of Sighs, Noprotone, Halugarge and etc */
		public var name:String;

		public var varName:String; 
		
		/** Region name (in Sansico language) in the world represented by this object. The Pillars, Desert of Sighs, Noprotone, Halugarge and etc */
		public var sansicoName:String; 
		
		/** World nature Light or Darkness or Mestizo. Used for game mechanics */
		public var worldNature:String;
		
		/** All areas this region contains. */
		public var areas:Vector.<LevelArea> = new Vector.<LevelArea>();
		
		/** All sites this region contains. */
		public var sites:Vector.<LevelSite> = new Vector.<LevelSite>();
		/** Store all site using site objects as keys*/ 
		public var SitesDict:Dictionary = new Dictionary(); 
		/** Store all site using site name as keys*/ 
		public var SitesByName:Dictionary = new Dictionary(); 
		
		public var unknownArea:LevelArea;
		
		/** File where level areas should be loaded. Does not include the file extention. Level Makes will look for .xml and afet for a .swf */
		public var url:String;
		
		/** File where level maps should be loaded. Does not include the file extention. Level Makes will look for .xml and afet for a .swf */
		public var maps_url:String;
		
		/** Places where player could start the game. Like checkpoints. Stored by area. Some areas could have multiple region bases. Others could have none. */
		public var basesByArea:Vector.<Vector.<RegionBase>> = new Vector.<Vector.<RegionBase>>();
		
		/** Places where player could start the game. Like checkpoints. Stored by area. Some areas could have multiple region bases. Others could have none. */
		public var bases:Vector.<RegionBase> = new Vector.<RegionBase>();
		
		/** Store the number of bases a region has */
		public var basesCount:uint = 0;
		
		/** LumaMap object used by UI to change UI skin and other ingame mechanics */
		public var lumaMap:LumaMap;
		
		/** AreaMap object used by Level Manager to determine on witch area player is */
		public var areaMap:AreaMap;
		
		/**
		 * @param	name a string with the region name
		 * @param	worldNature Light Dark or Mestizo
		 * @param	areas a array with strings containing areas sites names and ids
		 */
		public function LevelRegion(name:String, varName:String, worldNature:String, dataURL:String) {			
			this.name = name;
			this.sansicoName = getSansicoRegionName(name);
			this.worldNature = worldNature;
			this.url = dataURL;
			this.varName = varName;
			
			unknownArea = new LevelArea(99, LevelSite.UNKNOWN, this);
			unknownArea.setBounds(0, 0, 0, 0);
		}
		
		/** Add a area to this region */
		public function createArea(globalID:uint, site:LevelSite):void {
			var newArea:LevelArea = new LevelArea(globalID, site, this);
			
			if ((areas.length - 1) < newArea.globalId)
				areas.length = newArea.globalId + 1;
			
			areas[newArea.globalId] = newArea;
			
			unknownArea.adjacentAreas.push(newArea);
		}
		
		/** Add a site to this region should be called internally when a area is added */
		public function addSite(site:LevelSite):void {
			if ((sites.length - 1) < site.id)
				sites.length = site.id + 1;
				
			SitesByName[site.name] = site;
			SitesDict[site] = site;
			sites[site.id] = site;
		}
		
		/** Add a site to this region should be called internally when a area is added */
		public function removeSite(site:LevelSite):void {
			if ((sites.indexOf(site) != - 1))
				sites.removeAt(sites.indexOf(site));
				
			SitesByName[site] = null;
			delete SitesDict[site];
			
			SitesByName[site.name] = null;
			delete SitesDict[site];
			
			site.destroy();
		}
		
		/** Add a site to this region should be called internally when a area is added */
		public function addBase(base:RegionBase):void {
			if ((basesByArea.length - 1) < base.areaGlobalID){
				basesByArea.length = base.areaGlobalID + 1;
			}
			
			if (!basesByArea[base.areaGlobalID])
				basesByArea[base.areaGlobalID] = new Vector.<RegionBase>()
			
			basesByArea[base.areaGlobalID].push(base);
			
			if ((bases.length - 1) < base.globalID){
				bases.length = base.globalID + 1;
			}
			
			bases[base.globalID] = base;
			
			basesCount++;
		}
		
		/**
		 * Convets a name of a region to the right var name presented in LevelRegion class
		 * @param	region
		 * @return
		 */
		public static function regionNameFixer(region:String):String{
			switch (region){
				case "THE PILLARS":
				case "The Pillars":
					return "THE_PILLARS";
					break;
					
				case "DESERT OF SIGNS":
				case "Desert of Sighs":
					return "DESERT_OF_SIGNS";
					break;
					
				case "LANDS OF OBLIVION":
				case "Lands of Oblivion":
					return "LANDS_OF_OBLIVION";
					break;
					
				case "NOPROTHONE HALUGARDE":
				case "Noprothone Halugarde":
					return "NOPROTHONE_HALUGARDE";
					break;
					
				case "SANDBOX1":
				case "SandBox1":
					return "SANDBOX1";
					break;
					
				case "SANDBOX2":
				case "SandBox2":
					return "SANDBOX2";
					break;
			}
			throw Error("Name not recognized. Please review the name casted with the cases in LevelRegion class");
		}
		
		/** Return the name of a region in Sansico language. Used for interfaces */
		public static function getSansicoRegionName(regionName:String):String {
			switch (regionName) {
				case "THE PILLARS":
					return "eh pelaris"
					break;
					
				case "DESERT OF SIGNS":
					return "doserte weh hymayh"
					break;
					
				case "LANDS OF OBLIVION":
					return "tarres we ohkuecimento"
					break;
					
				case "NOPROTHONE HALUGARDE":
					return "halugarde - noprothone";
					break;
					
				case "SANDBOX1":
				case "SANDBOX2":
					return "sandbox"
					break;
			}
			return "vozia";
		}
		
		private var destroyed:Boolean;
		public function destroy():void {
			//TODO: destroy Level Region
			if (destroyed)
				return;
			
			var csite:LevelSite;
			for each (csite in sites){
				removeSite(csite)				
			}
			
			sites.length = 0;
			SitesDict = new Dictionary();
			
			//unknownArea = null;
			unknownArea.adjacentAreas.length = 0;
			
			bases.length = 0;
			RegionBase.resetIDS();
			
			var cbackbases:Vector.<RegionBase>;
			for each (cbackbases in basesByArea){
				if(cbackbases)
					cbackbases.length = 0;
			}
			
			basesByArea.length = 0;
			
			lumaMap.destroy(); 
			lumaMap = null;
			areaMap.areasIDs
			areaMap.destroy(); 
			areaMap = null;
			destroyed = true;
		}
	}
}