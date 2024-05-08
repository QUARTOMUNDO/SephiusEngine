package SephiusEngine.core.gameplay.archivemnets {
	import tLotDClassic.GameData.Properties.CutsceneProperties;
	import tLotDClassic.GameData.Properties.HelpProperties;
	import tLotDClassic.GameData.Properties.StoryTellerProperties;
	import flash.utils.Dictionary;
	/**
	 * Story some game play data related with the game
	 * @author Fernando Rabello
	 */
	public class Archivemnets {
		//Game Archivemnets
		public var listenedHelps:Dictionary = new Dictionary();
		public var listenedStoryTellers:Dictionary = new Dictionary();
		public var listenedCutscenes:Dictionary = new Dictionary();
		
		//public var listenedHelps:Vector.<HelpProperties> = new Vector.<HelpProperties>();
		//public var listenedStoryTellers:Vector.<StoryTellerProperties> = new Vector.<StoryTellerProperties>();
		
		public function Archivemnets() {
			var hProperty:HelpProperties;
			for each(hProperty in HelpProperties.PROPERTIES_LIST) {
				listenedHelps[hProperty.varName] = { listened:false };
			}
			
			var sProperty:StoryTellerProperties;
			for each(sProperty in StoryTellerProperties.PROPERTIES_LIST) {
				listenedStoryTellers[sProperty.varName] = { listened:false };
			}
			
			var cProperty:CutsceneProperties;
			for each(cProperty in CutsceneProperties.PROPERTIES_LIST) {
				listenedCutscenes[cProperty.varName] = { listened:false };
			}
		}
		
		/** Set a particular Help Property to listened and return he text of that */
		public function setHelpAsListined(varName:String, deviceType:String = null):void {
			if (HelpProperties.PROPERTIES_LIST.indexOf(HelpProperties[varName]) == -1)
				throw Error("Wrong var name. There is no HelpProperty with var name " + varName);
			
			listenedHelps[varName].listened = true;
		}
		
		/** Set a particular StoryTeller to listened and return the text of that */
		public function setStoryTellerListined(varName:String):String {
			if (StoryTellerProperties.PROPERTIES_LIST.indexOf(StoryTellerProperties[varName]) == -1)
				throw Error("Wrong var name. There is no StoryTellerProperties with var name " + varName);
			
			listenedStoryTellers[varName].listened = true;
			
			return StoryTellerProperties[varName];
		}
		
		/** Set a particular Cutscene to listened and return the text of that */
		public function setCutsceneListined(varName:String):String {
			if (CutsceneProperties.PROPERTIES_LIST.indexOf(CutsceneProperties[varName]) == -1)
				throw Error("Wrong var name. There is no StoryTellerProperties with var name " + varName);
			
			listenedCutscenes[varName].listened = true;
			
			return StoryTellerProperties[varName];
		}
	}
}