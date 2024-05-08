package SephiusEngine.core.levelManager 
{
	import SephiusEngine.core.levelManager.LevelArea;
	import flash.utils.Dictionary;
	/**
	 * Store information about a region site. A site is a group of region areas
	 * @author Fernando Rabello
	 */
	public class LevelSite {
		//                                                  name								region					ID		BG	effectParams
		//public static const DEATH_PLAINS:LevelSite = 		new LevelSite("Death Plains", 		"LANDS OF OBLIVION",	00,		00,	{useFogEffect:true,	useAuroraEffect:true, useFlyingObjectsEffects:true, useSunEffect:true, useRainEffect:true});
		//public static const PIT:LevelSite = 				new LevelSite("Pit", 				"LANDS OF OBLIVION",	01,		00,	{});
		//public static const ANCIENT_CAVERNS:LevelSite = 	new LevelSite("Ancient Caverns", 	"LANDS OF OBLIVION",	02,		01,	{});
		//public static const GOLDEN_LIGHT_ROCKS:LevelSite = 	new LevelSite("Golden Light Rocks", "LANDS OF OBLIVION",	03,		00,	{useFogEffect:true,	useAuroraEffect:true, useFlyingObjectsEffects:true, useSunEffect:true});
		//public static const DARK_DEEPS:LevelSite = 			new LevelSite("Dark Deeps", 		"LANDS OF OBLIVION",	04,		02,	{});
		//public static const FROZEN_SECLUSION:LevelSite = 	new LevelSite("Frozen Seclusion", 	"LANDS OF OBLIVION",	05,		03,	{});
		//public static const BURNING_LAIR:LevelSite = 		new LevelSite("Burning Lair", 		"LANDS OF OBLIVION",	06,		04,	{});
		//public static const EXTIRPATED_PEAK:LevelSite = 	new LevelSite("Extirpated Peak", 	"LANDS OF OBLIVION",	07,		00,	{useFogEffect:true,	useAuroraEffect:true, useFlyingObjectsEffects:true, useSunEffect:true, useRainEffect:true});
		//public static const THAYLAN_FORTRESS:LevelSite = 	new LevelSite("Thaylan Fortress", 	"LANDS OF OBLIVION",	08,		05,	{useFogEffect:true, useRainEffect:true});
		
		public static const UNKNOWN:LevelSite = 			new LevelSite("Unknown", 			null, 	09,		00,	{});
		
		public static const PIT_LEVEL:int = 2;
		public static const DEATH_PLAINS_LEVEL:int = 2;
		public static const ANCIENT_RUINS_LEVEL:int = 8;
		public static const PALE_BEYOND_LEVEL:int = 13;
		public static const DARK_DEEP_LEVEL:int = 13;
		public static const FROZEN_SECLUSION_LEVEL:int = 13;
		public static const BURNING_LAIR_LEVEL:int = 19;
		public static const EXTIRPATED_PEAK_LEVEL:int = 19;
		public static const THAYLAN_CIDADEL_LEVEL:int = 19;
		
		public static const PIT_VAR_NAME:String = "PIT";
		public static const DEATH_PLAINS_VAR_NAME:String = "DEATH_PLAINS";
		public static const ANCIENT_RUINS_VAR_NAME:String = "ANCIENT_RUINS";
		public static const PALE_BEYOND_VAR_NAME:String = "PALE_BEYOND";
		public static const DARK_DEEP_VAR_NAME:String = "DARK_DEEP";
		public static const FROZEN_SECLUSION_VAR_NAME:String = "FROZEN_SECLUSION";
		public static const BURNING_LAIR_VAR_NAME:String = "BURNING_LAIR";
		public static const EXTIRPATED_PEAK_VAR_NAME:String = "EXTIRPATED_PEAK";
		public static const THAYLAN_CIDADEL_VAR_NAME:String = "THAYLAN_CIDADEL";
		
		public static const PIT_NAME:String = "Pit";
		public static const DEATH_PLAINS_NAME:String = "Death Plains";
		public static const ANCIENT_RUINS_NAME:String = "Ancient Ruins";
		public static const PALE_BEYOND_NAME:String = "Pale Beyond";
		public static const DARK_DEEP_NAME:String = "Dark Deeps";
		public static const FROZEN_SECLUSION_NAME:String = "Frozen Seclusion";
		public static const BURNING_LAIR_NAME:String = "Burning Lair";
		public static const EXTIRPATED_PEAK_NAME:String = "Extirpated Peak";
		public static const THAYLAN_CIDADEL_NAME:String = "Thaylant Cidadel";
		
		public var name:String;
		public var bgm:String;
		public var bgfx:String;

		public var id:uint;
		public var region:LevelRegion;
		public var backGroundID:uint;
		public var backGround:LevelBackground;
		public var areas:Vector.<LevelArea> = new Vector.<LevelArea>();
		
		/**Define if this area should show fog effects */
		public var useFogEffect:Boolean = false;
		/**Define if this area should show fog effects */
		public var useRainEffect:Boolean = false;
		/**Define if this area should show Aurora effects */
		public var useAuroraEffect:Boolean = false;
		/**Define if this area should show fog effects */
		public var useFlyingObjectsEffects:Boolean = false;
		/**Define if this area should show FlyingObjects effects */
		public var useSunEffect:Boolean = false;
		/**Define if this area should show Sun effects */
		
		public function assignBackground(backGround:LevelBackground):void{
			this.backGround = backGround;
		}
		
		public function getSiteLevel():int{
			switch (name) {
				case DEATH_PLAINS_NAME:
					return DEATH_PLAINS_LEVEL;
					break;
				case PIT_NAME:
					return PIT_LEVEL;
					break;
				// adicione quantos casos (cases) forem necessários
				case ANCIENT_RUINS_NAME:
					return ANCIENT_RUINS_LEVEL;
					break;
				// adicione quantos casos (cases) forem necessários
				case FROZEN_SECLUSION_NAME:
					return FROZEN_SECLUSION_LEVEL;
					break;
				// adicione quantos casos (cases) forem necessários
				case BURNING_LAIR_NAME:
					return BURNING_LAIR_LEVEL;
					break;
				// adicione quantos casos (cases) forem necessários
				case DARK_DEEP_NAME:
					return DARK_DEEP_LEVEL;
					break;
				// adicione quantos casos (cases) forem necessários
				case PALE_BEYOND_NAME:
					return PALE_BEYOND_LEVEL;
					break;
				case EXTIRPATED_PEAK_NAME:
					return EXTIRPATED_PEAK_LEVEL;
					break;
				case THAYLAN_CIDADEL_NAME:
					return THAYLAN_CIDADEL_LEVEL;
					break;
				// adicione quantos casos (cases) forem necessários
				default:
					return 0;
					break;
			}			
		}
				
		public function LevelSite(name:String, region:LevelRegion, id:uint, backGroundID:uint, params:Object = null) {
			this.name = name;
			if(region)
				this.region = region;
				
			this.backGroundID = backGroundID;
			this.id = id;
			
			if (params) {
				var param:String;
				for (param in params) {
					this[param] = params[param];
				}
			}
		}
		
		public function createBackGround():LevelBackground {
			backGround = new LevelBackground(this);
			return backGround;
		}
		
		private var destroyed:Boolean;
		public function destroy():void{
			if (destroyed)
				return;
			
			var cArea:LevelArea;
			for each (cArea in areas){
				cArea.destroy();
			}
			areas.length = 0;
						
			if(backGround)
				backGround.destroy();
			
			region = null;
			destroyed = true;
		}
	}
}