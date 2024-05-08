package SephiusEngine.Languages {

    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;

    import org.osflash.signals.Signal;

    import starling.utils.cleanMasterString;
    import SephiusEngine.utils.AppInfo;

    /** Store series of dictionaries with all text used in the game that need translation.
     * It reads from XML files located in "Lang" folder.
	 * @author Fernando Rabello
     */
    public class LanguageManager {
        /** Directory of Game Data in debug mode */
        public static var LANGUAGE_DATA_LOCATION:File = File.applicationDirectory.resolvePath("lang");

        /** Store languages files that are used to construct dictionaries existing in this class. */
        public static var AVAIABLE_LANGAGES_NAMES:Vector.<String> = new Vector.<String>();
        public static var AVAIABLE_LANGAGES_FILES_BY_ID:Dictionary = new Dictionary();
        public static var AVAIABLE_LANGAGES_ID_FROM_NAMES:Dictionary = new Dictionary();
        public static var AVAIABLE_LANGAGES_NAMES_FROM_ID:Dictionary = new Dictionary();
        
        /** Store languages files that are used to construct dictionaries existing in this class. */
        public static function get NUM_OF_AVAIABLE_LANGAGES():uint{
        	return AVAIABLE_LANGAGES_NAMES.length;
        }

        /** Current language used */
        private static var _CURRENT_LANGUAGE_ID:String = "en";
        private static var _CURRENT_LANGUAGE_NAME:String = "ENGLISH";
        public static function get CURRENT_LANGUAGE():String{return _CURRENT_LANGUAGE_ID;}

        /** a dictionary that stores all characters dialogues for a particular language */
        private static var DialogueLanguageElements:Dictionary = new Dictionary();

        /** a dictionary stores start splash text elements for a particular language */
        private static var StartElements:Dictionary = new Dictionary();
        /** a dictionary stores start menu ui text elements for a particular language */
        private static var StartMenuElements:Dictionary = new Dictionary();
        /** a dictionary stores game menu ui text elements for a particular language */
        private static var GameMenuElements:Dictionary = new Dictionary();
        /** a dictionary stores option menu ui text elements for a particular language */
        private static var OptionsMenuElements:Dictionary = new Dictionary();
        /** a dictionary stores help menu ui text elements for a particular language */
        private static var HelpMenuElements:Dictionary = new Dictionary();
        /** a dictionary stores help elements ui text elements for a particular language */
        private static var HelpElements:Dictionary = new Dictionary();
        /** a dictionary stores pause menu ui text elements for a particular language */
        private static var PauseMenuElements:Dictionary = new Dictionary();
        /** a dictionary stores title menu ui text elements for a particular language */
        private static var TitleMenuElements:Dictionary = new Dictionary();
        /** a dictionary stores exit menu ui text elements for a particular language */
        private static var ExitMenuElements:Dictionary = new Dictionary();
        /** a dictionary stores Equip menu ui text elements for a particular language */
        private static var EquipMenuElements:Dictionary = new Dictionary();
        /** a dictionary stores Override menu ui text elements for a particular language */
        private static var OverrideMenuElements:Dictionary = new Dictionary();
        /** a dictionary stores hud ui text elements for a particular language */
        private static var HUDElements:Dictionary = new Dictionary();

        /** a dictionary stores site names for a particular language */
        private static var SiteNames:Dictionary = new Dictionary();

        /** a dictionary stores nature's data text elements for a particular language */
        private static var NatureNames:Dictionary = new Dictionary();
        /** a dictionary stores Status's data text elements for a particular language */
        private static var StatusNames:Dictionary = new Dictionary();
        /** a dictionary stores spell's data text elements for a particular language */
        private static var SpellsData:Dictionary = new Dictionary();
        /** a dictionary stores wapeons's data text elements for a particular language */
        private static var WeaponsData:Dictionary = new Dictionary();
        /** a dictionary stores item's data text elements for a particular language */
        private static var ItemsData:Dictionary = new Dictionary();
        /** a dictionary stores memos's data text elements for a particular language */
        private static var MemosData:Dictionary = new Dictionary();

        public static var LANGUAGE_FILE_EXTENTION:String = "xml";

        public static function init():void{
            var allFiles:Array = LANGUAGE_DATA_LOCATION.getDirectoryListing(); 
            var langID:String;
            var file:File;
            var fileName:String;
            var langName:String;

            for each(file in allFiles) {
                langName = getLanguageName(file);
                if ((file.extension) == LANGUAGE_FILE_EXTENTION) {
                    fileName = file.name.replace(".xml", "");
                    if(file.name.split("_").length == 2){
                        langID = fileName.split("_")[1];
                        AVAIABLE_LANGAGES_NAMES.push(langName)
                        AVAIABLE_LANGAGES_FILES_BY_ID[langID] = file;
                        AVAIABLE_LANGAGES_ID_FROM_NAMES[langName] = langID;
                        AVAIABLE_LANGAGES_NAMES_FROM_ID[langID] = langName;
                    }
                }
            }
        }

        private static function getLanguageName(file:File):String{
            var fileStream:FileStream = new FileStream();
            var bytes:ByteArray = new ByteArray();
            var XMLFileObject:XML;

            fileStream.open(file, FileMode.READ);
            fileStream.readBytes(bytes);
            fileStream.close();	

            var languageXML:XML = new XML(bytes);

            return cleanMasterString(languageXML.@language);
        }

        public static function changeLanguage(langID:String):void{
            if(AVAIABLE_LANGAGES_FILES_BY_ID[langID]){
                _CURRENT_LANGUAGE_ID = langID;
            }
            else if(AVAIABLE_LANGAGES_ID_FROM_NAMES[langID]){//Try by name
                _CURRENT_LANGUAGE_ID = AVAIABLE_LANGAGES_ID_FROM_NAMES[langID];
            }
            else{
                throw Error("[LANGUAGE MANAGER] Language ID/name: " + langID + " is invalid");
            }

            var fileStream:FileStream = new FileStream();
            var bytes:ByteArray = new ByteArray();
            var XMLFileObject:XML;

            fileStream.open(AVAIABLE_LANGAGES_FILES_BY_ID[_CURRENT_LANGUAGE_ID], FileMode.READ);
            fileStream.readBytes(bytes);
            fileStream.close();	

            var languageXML:XML = new XML(bytes);
            var languageData:XML
            var langNode:XML
            var elementNode:XML
            var sceneNode:XML
            var lineNode:XML
            var charName:String;
            var lines:Vector.<String>;
            var langNodeID:String;
            var elementID:String;
            var langNodeIDCategory:String;
            var langNodeIDSubCategory:String;
            var validLangNodeIDTypes:Array = ["Value", "Usage", "Description"];
            var myPattern:RegExp = /            /g;
            _CURRENT_LANGUAGE_NAME = cleanMasterString(languageXML.@language);
            var cValue:String;
            for each(langNode in languageXML.children()){
                langNodeID = cleanMasterString(langNode.name());

                //Characters dialogues structures
                if(langNodeID == "DialogueLanguageElements"){
                    charName = cleanMasterString(langNode.@CharacterName);
                    LanguageManager[langNodeID][charName] = new DialogueLanguageElement(langNodeID, charName, _CURRENT_LANGUAGE_ID);
                    
                    for each(sceneNode in langNode.Scene){
                        lines = new Vector.<String>();
                        for each(lineNode in sceneNode.Line){
                            lines.push(lineNode.text());  
                        }

                        (LanguageManager[langNodeID][charName] as DialogueLanguageElement).setScene(cleanMasterString(sceneNode.@baseName), lines);
                    }
                }
                //This identify a patern like "SpellsNames", "SpellsUsages"" PaleSpellDescriptions" which is part of same dictionay structure LoreLanguageElement
                else if (langNodeID == "LoreElement"){
                    langNodeIDCategory = cleanMasterString(langNode.@Category);
                    langNodeIDSubCategory = cleanMasterString(langNode.@SubCategory);

                    for each(elementNode in langNode.Element){
                        elementID = cleanMasterString(elementNode.@elementID);
                        if(!LanguageManager[langNodeIDCategory][elementID])
                            LanguageManager[langNodeIDCategory][elementID] = new LoreLanguageElement(elementID, _CURRENT_LANGUAGE_ID);

                        cValue = cleanMasterString(elementNode.@value);
                        cValue = cValue.replace(/\r\n/g, '\n');  // Replace \r\n (Windows line endings) with \n
                        cValue = cValue.replace(/\r/g, '\n');    // Replace remaining \r (Mac line endings) with \n	
                        
                        cValue = cValue.replace(myPattern, '    ');    // Replace long spacing to normal paragraph spacing

                        LanguageManager[langNodeIDCategory][elementID]["set" + langNodeIDSubCategory](cValue, 0);
                    }
                }
                //Simple structures
                else{
                    for each(elementNode in langNode.Element){
                        langNodeIDCategory = cleanMasterString(langNode.@Category);
                        elementID = cleanMasterString(elementNode.@elementID);

                        cValue = cleanMasterString(elementNode.@value);
                        cValue = cValue.replace(/\r\n/g, '\n');  // Replace \r\n (Windows line endings) with \n
                        cValue = cValue.replace(/\r/g, '\n');    // Replace remaining \r (Mac line endings) with \n	
                        cValue = cValue.replace(myPattern, '');    // Replace long spacing to normal paragraph spacing

                        LanguageManager[langNodeIDCategory][elementID] = new SimpleLanguageElement(cleanMasterString(elementNode.@elementID), cValue, _CURRENT_LANGUAGE_ID);
                    }
                }
            }
        
            bytes.clear();
            bytes = null;

            ON_LANG_CHANGED.dispatch(_CURRENT_LANGUAGE_ID);
        }

        public static var ON_LANG_CHANGED:Signal = new Signal(String);

        public static function getAvaiableLanguages():Array{
            var AVAIABLE_LANGAGES_ARRAY:Array = new Array();
            var langName:String;

            for each(langName in AVAIABLE_LANGAGES_NAMES){
                AVAIABLE_LANGAGES_ARRAY.push(langName);
            }

            return AVAIABLE_LANGAGES_ARRAY;
        }

        public static function getCurrentLandID():String{
            return _CURRENT_LANGUAGE_ID;
        } 

        public static function getCurrentLangName():String{
            return _CURRENT_LANGUAGE_NAME;
        } 

        public static var noReportMissingTranslation:Boolean = true;

        /** returns a simple language element (generally containing a single text) by giving the id of the element and language section */
        public static function getSimpleLang(langSection:String, elementID:String):SimpleLanguageElement{
            if (!LanguageManager[langSection][elementID])
                if(AppInfo.isDebugBuild && !noReportMissingTranslation)
                    return new SimpleLanguageElement(elementID, "TRANSLATION MISSING", _CURRENT_LANGUAGE_ID);
                else
                    return new SimpleLanguageElement(elementID, elementID, _CURRENT_LANGUAGE_ID);

                
            return LanguageManager[langSection][elementID] as SimpleLanguageElement;
        }

        /** returns a lore language element by giving the id of the element and language section. Lore language element store a name, usage and description. */
        public static function getLoreLang(langSection:String, elementID:String):LoreLanguageElement{
            if (!LanguageManager[langSection][elementID]){
                var lle:LoreLanguageElement = new LoreLanguageElement(elementID, _CURRENT_LANGUAGE_ID);
                lle.name = AppInfo.isDebugBuild ? "TRANSLATION NAME MISSING" : elementID;
                lle.usage = "TRANSLATION USAGE MISSING";
                lle.description.push("TRANSLATION DESCRIPTION MISSING");
                return lle;
            }
            
            return LanguageManager[langSection][elementID] as LoreLanguageElement;
        }

        /** returns dialogue element structure for a particular character. Dialogue element have a list of scenes each scene is a text*/
        public static function getDialogueSceneLang(langSection:String, charID:String):DialogueLanguageElement{
            if (!LanguageManager[langSection][charID]){
                throw Error("[LANGUAGE MANAGER] Character ID not found");
            }
            return LanguageManager[langSection][charID] as DialogueLanguageElement;
        }
    }
}