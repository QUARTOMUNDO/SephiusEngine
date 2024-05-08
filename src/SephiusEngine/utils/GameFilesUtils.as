package SephiusEngine.utils 
{
	import com.hurlant.crypto.symmetric.AESKey;

	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.events.IOErrorEvent;
	import flash.events.Event;
	
	/**
	 * Useful functions to work loading and saving game files
	 * @author Fernando Rabello
	 */
	public class GameFilesUtils {
		/** Used to force to use encrypt/compressed files for data, save and levels. Even is running in release mode. */
		private static var forceFiles:Boolean = false;
		private static var forceFilesValue:Boolean = true;
		public static function get debugFiles():Boolean{
			return forceFiles ? forceFilesValue : AppInfo.isDebugBuild;
		}

		/** Define if data / save and level files will be compressed  */
		private static var useCompression:Boolean = false;

		/** Extension used for game data running in debug mode */
		public static var GAME_DATA_EXTENTION_DEBUG:String = ".xml";
		/** Extension used for game data running un release mode */
		public static var GAME_DATA_EXTENTION_RELESE:String = ".segd";
		/** Extension used for game data automaticly defined */
		public static var GAME_DATA_EXTENSION:String = debugFiles ? GAME_DATA_EXTENTION_DEBUG : GAME_DATA_EXTENTION_RELESE;

		/** Directory of Game Data in debug mode */
		public static var GAME_DATA_DIRECTORY_DEBUG:File = File.applicationDirectory.resolvePath("gameData").resolvePath("uncompressed");
		/** Directory of Game Data in Release mode */
		public static var GAME_DATA_DIRECTORY_RELESE:File = File.applicationDirectory.resolvePath("gameData").resolvePath("release");
		/** Directory of Game Data automaticly defined */
		public static var GAME_DATA_DIRECTORY:File = debugFiles ? GAME_DATA_DIRECTORY_DEBUG : GAME_DATA_DIRECTORY_RELESE;

		/** Extension used for game data running in debug mode */
		public static var LEVEL_DATA_EXTENTION_DEBUG:String = ".xml";
		/** Extension used for game data running un release mode */
		public static var LEVEL_DATA_EXTENTION_RELESE:String = ".seld";
		/** Extension used for game data automaticly defined */
		public static var LEVE_DATA_EXTENSION:String = debugFiles ? LEVEL_DATA_EXTENTION_DEBUG : LEVEL_DATA_EXTENTION_RELESE;

		/** Directory of Level Data in debug mode */
		public static var LEVEL_DATA_DEBUG:File = File.applicationDirectory.resolvePath("levels").resolvePath("uncompressed");
		/** Directory of Level Data in Release mode */
		public static var LEVEL_DATA_RELESE:File = File.applicationDirectory.resolvePath("levels").resolvePath("release");
		/** Directory of Level Data automaticly defined */
		public static var LEVEL_DATA_DIRECTORY:File = debugFiles ? LEVEL_DATA_DEBUG : LEVEL_DATA_RELESE;
		
		/** Extension used for game data running in debug mode */
		public static var SAVE_DATA_EXTENTION_DEBUG:String = ".xml";
		/** Extension used for game data running un release mode */
		public static var SAVE_DATA_EXTENTION_RELESE:String = ".sesd";
		/** Extension used for game data automaticly defined */
		public static var SAVE_DATA_EXTENSION:String = debugFiles ? SAVE_DATA_EXTENTION_DEBUG : SAVE_DATA_EXTENTION_RELESE;

		/** Extension used for game data running in debug mode */
		public static var OPTIONS_DATA_EXTENTION_DEBUG:String = ".xml";
		/** Extension used for game data running un release mode */
		public static var OPTIONS_DATA_EXTENTION_RELESE:String = ".xml";
		/** Extension used for game data automaticly defined */
		public static var OPTIONS_DATA_EXTENSION:String = debugFiles ? OPTIONS_DATA_EXTENTION_DEBUG : OPTIONS_DATA_EXTENTION_RELESE;

		/** Directory of Level Data automaticly defined */
		public static var SAVE_DATA_DIRECTORY:File = File.userDirectory.resolvePath("tLotD_ORIGINS").resolvePath("SaveData");
		
		/** Directory of Level Data automaticly defined */
		public static var OPTIONS_DATA_DIRECTORY:File = File.userDirectory.resolvePath("tLotD_ORIGINS").resolvePath("OptionsData");
		
		public function GameFilesUtils() {}

        private static function get currentOSUser():String{
            var userDir:String = File.userDirectory.nativePath;
            var userName:String = userDir.substr(userDir.lastIndexOf(File.separator) + 1);
            return userName;
        }

		private static var updateLevelData:Boolean = true;
		/** Loads level data */
		public static function loadLevelData(xmlFile:File, callback:Function, params:Object=null):void{
			var fileStream:FileStream = new FileStream();
			fileStream.addEventListener(Event.COMPLETE, onLoadLevelDataCompleted);
			fileStream.addEventListener(IOErrorEvent.IO_ERROR, onLoadLevelDataError);			
			fileStream.openAsync(xmlFile, FileMode.READ);

			function onLoadLevelDataCompleted(event:Event):void{
				var bytes:ByteArray = new ByteArray();
				var XMLFileObject:XML;

				fileStream.readBytes(bytes);
				fileStream.close();	
				fileStream.removeEventListener(Event.COMPLETE, onLoadLevelDataCompleted);
				fileStream.removeEventListener(IOErrorEvent.IO_ERROR, onLoadLevelDataError);

				if(LEVE_DATA_EXTENSION == LEVEL_DATA_EXTENTION_RELESE){
					bytes.uncompress();
					decryptByteArray(bytes)
				}	
					
				XMLFileObject = new XML(bytes);

				if(LEVE_DATA_EXTENSION != LEVEL_DATA_EXTENTION_RELESE && updateLevelData){
					//get the release file name which is identical to uncompressed file but with different extention
					var releaseFileName:String = xmlFile.name.split(".")[0] + LEVEL_DATA_EXTENTION_RELESE;
					var releaseFile:File = new File(LEVEL_DATA_RELESE.resolvePath(releaseFileName).nativePath);
					saveLevelData(XMLFileObject, releaseFile);
				}
				
				callback(XMLFileObject); // Callback is called with the loaded XML data
			}	

			function onLoadLevelDataError(event:IOErrorEvent):void {
				fileStream.removeEventListener(Event.COMPLETE, onLoadLevelDataCompleted);
				fileStream.removeEventListener(IOErrorEvent.IO_ERROR, onLoadLevelDataError);
				throw Error ("[GameFilesUtils] Level Data can't be loaded")
			}
		}


		/** Saves a compressed and encryted version of level data. This version is used in release builds */
		private static function saveLevelData(xmlToSave:XML, file:File):void{
			var fileStream:FileStream = new FileStream();
			var bytes:ByteArray = new ByteArray();
			
			bytes = encryptXML(xmlToSave);
			bytes.compress();	
			
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeBytes(bytes);
			fileStream.close();	
			
			bytes.clear();
			bytes = null;
		}

		public static function saveSaveOptionsData(xmlToSave:XML):void{
			try{
				var fileStream:FileStream = new FileStream();
				var bytes:ByteArray = new ByteArray();
				var optionsFile:File = new File(OPTIONS_DATA_DIRECTORY.resolvePath("OptionsData" + OPTIONS_DATA_EXTENSION).url);
				fileStream.open(optionsFile, FileMode.WRITE);
				
				//if (OPTIONS_DATA_EXTENSION == OPTIONS_DATA_EXTENTION_RELESE) {
					//bytes = encryptXML(xmlToSave);
					//bytes.compress();    
					//fileStream.writeBytes(bytes);
				//}
				//else {
					fileStream.writeUTFBytes(xmlToSave.toXMLString());
				//}
				
				fileStream.close();    
				fileStream = null;

				bytes.clear();
				bytes = null;
			}
			catch (e:Error) {
				// Handle the error, possibly logging it or showing an error message
				trace("Error saving Options data: " + e.message);
				// Consider additional recovery or notification steps here			
			}
			finally {
				// Ensuring the file stream is always closed and listeners are removed
				if (fileStream) {
					fileStream.close();
					fileStream = null;
				}
			}			
		}

		public static function loadOptionsData():XML{
			var fileStream:FileStream = new FileStream();
			var bytes:ByteArray = new ByteArray();
			var XMLFileObject:XML;
			
			var xmlFile:File;
			xmlFile = OPTIONS_DATA_DIRECTORY.resolvePath("OptionsData" + OPTIONS_DATA_EXTENSION);
			
			if(xmlFile.exists){
				fileStream.open(xmlFile, FileMode.READ);
				fileStream.readBytes(bytes);
				fileStream.close();	

				//if(OPTIONS_DATA_EXTENSION == OPTIONS_DATA_EXTENTION_RELESE){
					//bytes.uncompress();
					//decryptByteArray(bytes);
				//}

				XMLFileObject = new XML(bytes);
				
				return XMLFileObject;		
			}
			return null;
		}

		private static var lastSaveFile:File;
		public static function saveSaveData(xmlToSave:XML):void{
			try{
				var fileStream:FileStream = new FileStream();
				var bytes:ByteArray = new ByteArray();
				var increment:int;
				
				if(!lastSaveFile)
					lastSaveFile = getSaveFiles().pop();
				
				if(lastSaveFile)
					increment = extractIncrementNumber(lastSaveFile.name) + 1;
				else
					increment = 1;

				//200 save files limit
				increment = increment % 100;

				lastSaveFile = new File(SAVE_DATA_DIRECTORY.resolvePath("GameSave" + "_" + increment + SAVE_DATA_EXTENSION).url);
				
				fileStream.open(lastSaveFile, FileMode.WRITE);
				
				if (SAVE_DATA_EXTENSION == SAVE_DATA_EXTENTION_RELESE) {
					bytes = encryptXML(xmlToSave);
					bytes.compress();    
					fileStream.writeBytes(bytes);
				}
				else {
					fileStream.writeUTFBytes(xmlToSave.toXMLString());
				}
				
				fileStream.close();    
				fileStream = null;

				bytes.clear();
				bytes = null;
			}
			catch (e:Error) {
				// Handle the error, possibly logging it or showing an error message
				trace("Error saving save data: " + e.message);
				// Consider additional recovery or notification steps here			
			}
			finally {
				// Ensuring the file stream is always closed and listeners are removed
				if (fileStream) {
					fileStream.close();
					fileStream = null;
				}
			}			
		}

		/** Loads the last save data saved in User Directory */
		public static function loadSaveData():XML{
			var fileStream:FileStream = new FileStream();
			var bytes:ByteArray = new ByteArray();
			var lastSaveFile:File = getSaveFiles().pop();
			
			if (!lastSaveFile.exists)
				throw Error ("Save File Don't Exist. Trying to load without have save at least one time?");

			trace("[GAME DATA] Loading Save Data: " + lastSaveFile.name);

			fileStream.open(lastSaveFile, FileMode.UPDATE);
			fileStream.readBytes(bytes);
			fileStream.close();	
			
			if(SAVE_DATA_EXTENSION == SAVE_DATA_EXTENTION_RELESE){
				bytes.uncompress();
				decryptByteArray(bytes);
			}

			return new XML(bytes);
		}

		public static function saveDataExist():Boolean {
			if(getSaveFiles().length > 0)
				return true;
			else
				return false
		}

		private static function extractIncrementNumber(filename:String):int {
			// Use a regular expression to match the structure "_[number]."
			var regex:RegExp = /_(\d+)\./;
			var results:Array = filename.match(regex);
			
			if (results && results.length > 1) {
				return int(results[1]); // Return the captured number
			}
			
			return -1; // Return -1 if no number is found
		}	
			
		/** Return all save files sorted by time of creation*/
		private static function getSaveFiles():Vector.<File> {
			if(!SAVE_DATA_DIRECTORY.exists)
				SAVE_DATA_DIRECTORY.createDirectory();
			
			var allFiles:Array = SAVE_DATA_DIRECTORY.getDirectoryListing();
			var savedFiles:Vector.<File> = new Vector.<File>();
			
			for each(var file:File in allFiles) {
				if (("." + file.extension) == SAVE_DATA_EXTENSION) {
					savedFiles.push(file);
				}
			}
			
			// Sort the files by creation date
			savedFiles.sort(
							function(a:File, b:File):int {
								if (a.creationDate.time > b.creationDate.time) return 1;
								if (a.creationDate.time < b.creationDate.time) return -1;
								return 0;
														}
							);
			
			return savedFiles;
		}

		private static var overrideSEGD:Boolean = true;
		public static function loadGameData(fileName:String):XML{
			var fileStream:FileStream = new FileStream();
			var bytes:ByteArray = new ByteArray();
			var XMLFileObject:XML;
			
			var xmlFile:File;
			xmlFile = GAME_DATA_DIRECTORY.resolvePath(fileName + GAME_DATA_EXTENSION);
			
			fileStream.open(xmlFile, FileMode.READ);
			fileStream.readBytes(bytes);
			fileStream.close();	

			if(GAME_DATA_EXTENSION == GAME_DATA_EXTENTION_RELESE){
				bytes.uncompress();
				decryptByteArray(bytes);
			}

			XMLFileObject = new XML(bytes);
			
			if(GAME_DATA_EXTENSION == GAME_DATA_EXTENTION_DEBUG && overrideSEGD)
				saveSEGD(XMLFileObject, fileName);

			return XMLFileObject;
		}
		
		/** Will sabe Game Data file compressed and encrypted */
		private static function saveSEGD(xmlToSave:XML, fileName:String):void{
			var fileStream:FileStream = new FileStream();
			var bytes:ByteArray = new ByteArray();
			
			var xmlFile:File;
			xmlFile = new File(GAME_DATA_DIRECTORY_RELESE.resolvePath(fileName + GAME_DATA_EXTENTION_RELESE).nativePath);

			bytes = encryptXML(xmlToSave);
			bytes.compress();	
			
			fileStream.open(xmlFile, FileMode.WRITE);
			fileStream.writeBytes(bytes);
			fileStream.close();	
			
			bytes.clear();
			bytes = null;
		}
		
		/** Sabe Game Data on debug directory. It will be uncompressed and not encrypted data */
		private static function saveSEGDDebug(xmlToSave:XML, fileName:String):void{
			var fileStream:FileStream = new FileStream();

			encryptXML(xmlToSave);

			var xmlFile:File;
			xmlFile = GAME_DATA_DIRECTORY_RELESE.resolvePath(fileName + GAME_DATA_EXTENTION_DEBUG);
			
			fileStream.open(xmlFile, FileMode.WRITE);
			fileStream.writeUTFBytes(xmlToSave.toXMLString());
			fileStream.close();	
		}
		
		/**
		 * Return a key to be used to encrypt and decrypt game data files
		 */
		public static function getEncryptionKey():ByteArray {
			var key:ByteArray = new ByteArray();
			key.writeUTF("tLotDClasicKey");//Fixed key just to prevent normal player form access the game data

			return key;
		}		

		public static function encryptXML(xmlData:XML):ByteArray {
			var aes:AESKey = new AESKey (getEncryptionKey());
			
			var dataToEncrypt:ByteArray = new ByteArray();
			dataToEncrypt.writeUTFBytes(xmlData.toXMLString());
			
			aes.encrypt(dataToEncrypt);
			
			return dataToEncrypt;
		}

		public static function decryptByteArray(encryptedData:ByteArray):void {
			var aes:AESKey = new AESKey(getEncryptionKey());
			aes.decrypt(encryptedData);
		}		
	}
}