package SephiusEngine.assetManagers{
	import SephiusEngine.assetManagers.loaders.PNGTextureLoader;
	import SephiusEngine.assetManagers.loaders.TextureLoadRequest;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.displayObjects.configs.NativeTextureConfig;
	import SephiusEngine.displayObjects.configs.SubTextureConfig;
	import SephiusEngine.displayObjects.configs.TexturesCache;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display3D.textures.TextureBase;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	import org.osflash.signals.Signal;

	import starling.textures.Texture;
	import starling.utils.cleanMasterString;
	import SephiusEngine.utils.AppInfo;
	
	/**
	 * This Class load all Atlas in the game and pre process them
	 * @author Fernando Rabello
	 */
	public class TextureManager{
		public static var sep:String = "/";

		/** The names of the base textures witch make a atlas */
		public var atlasTextures:Dictionary = new Dictionary();
		
		/** The number of packs currently loaded */
		public var numOfPacksLoaded:int = 0;
		/** The number of textures currently loaded */
		public var numOfTexturesLoaded:int = 0;
		
		/** The total number of packs loaded or not */
		public var numOfPacks:int = 0;
		/** The total number of textures loaded or not */
		public var numOfTextures:int = 0;
		
		/** The URLs of the base textures witch make a atlas */
		public var atlasTexturesURLs:Dictionary = new Dictionary();
		/** Witch atlas textures are loaded */
		public var atlasTexturesLoaded:Dictionary = new Dictionary();
		/** If a pack of atlas is loaded */
		public var atlasPacksLoaded:Dictionary = new Dictionary();
		/** Inform witch packs uses a particular texture. Usefull for atlas witch has more than 1 pack of animations */
		public var atlasTexturesRelations:Dictionary = new Dictionary();
		/** Tell how much times a atlas texture pack is used by other objects.
		 * Objects should make a check in/ check out every time it use a pack in order to system work right
		 * When usage is 0 texture pack is automacly disposed*/
		public var packUsage:Dictionary = new Dictionary();
		public var packUsageByChecker:Dictionary = new Dictionary();
		
		/** All animations divided grouped by a prefix (pack) name */
		public var subTextures:Dictionary = new Dictionary();
		/** All animations divided grouped by a prefix (pack) name */
		public var subTexturesNames:Dictionary = new Dictionary();
		/** Store all textures by full texture name */
		public var subTexByFullName:Dictionary = new Dictionary();
		
		/** Store atfData to be uploaded to GPU latter. This could be used on PC only cause it will raise a lot memory consumption */
		public var atfDatas:Dictionary = new Dictionary();
		/** List of pack names withc atf textures should stay loaded */
		public var persistentATFs:Dictionary = new Dictionary();
		
		public var packsSubtextureSizes:Dictionary = new Dictionary();
		
		private var helperTextureVector:Vector.<Texture> = new Vector.<Texture>();
		private var helperConfigVector:Vector.<SubTextureConfig> = new Vector.<SubTextureConfig>();
		
		private var helperTextureVector2:Vector.<Texture> = helperTextureVector;
		private var helperConfigVector2:Vector.<SubTextureConfig> = helperConfigVector;
		
		/** Dispach a signal when a texture is loaded, sending the name of the texture */
		public var onTextureCreated:Signal = new Signal(Dictionary);
		/** Dispach a signal when all textures related with a pack is loaded, sending the pack name */
		public var onTexturePackCreated:Dictionary = new Dictionary();
		
		public var verbose:Boolean = false;
        private var mScaleFactor:Number;
        private var mUseMipMaps:Boolean;
		
		public var onReady:Signal = new Signal();
		
		public function TextureManager(scaleFactor:Number=-1, useMipmaps:Boolean=false){
			mScaleFactor = scaleFactor;
			mUseMipMaps = useMipmaps;
		}
		public function processConfigs(texturesURL:File, callback:Function):void{
			processAtlasConfigs(false, texturesURL);
			onReady.addOnce(callback);
		}
		
		public function get fileCount():int { return _fileCount; };
		public function set fileCount(value:int):void { 
			_fileCount = value; 
			//trace(_fileCount); 
			if (fileCount <= 0)
				onReady.dispatch();
		}
		private var _fileCount:int = 0;
		
		/** Find and load all xmls in a folder, url string or File Object */
		private function processAtlasConfigs(retainATFData:Boolean, ... rawAssets):void {
			var objectName:String;
			var regExp:RegExp;
			var extention:String;
			var atlasName:String;
			
			for each (var rawAsset:Object in rawAssets){
				if (rawAssets as String)
					regExp;
				
				/** If rawAsset is a array inside rawAssets, send it back to function only itself */
				if (rawAsset is Array){
					for each (var rawSubAsset:Object in rawAsset){
						processAtlasConfigs.apply(TextureManager, [retainATFData, rawSubAsset]);
					}
				}
				//If rawAssets is a File Object. Process it */
				else if (getQualifiedClassName(rawAsset) == "flash.filesystem::File"){
					//URL informed to File object does not exist */
					if (!rawAsset["exists"]){
						log("[TEXTURE MANAGER]File or directory not found: '" + rawAsset["url"] + "'");
					}
					//Only process files witch is not hidden */
					else if (!rawAsset["isHidden"]){
						/** The URL informed in File object is a directory. Send back to the function the list inside this directory */
						if (rawAsset["isDirectory"])
							processAtlasConfigs.apply(TextureManager, [retainATFData, rawAsset["getDirectoryListing"]()]);
						else{
							atlasName = rawAsset["url"].split(sep).pop();
							extention = rawAsset["extension"].toLowerCase();
							atlasName = atlasName.split(".")[0];
							
							/** Only process XMLs */
							if (extention == "xml") {
								fileCount++;	
								loadAtlasConfig(String(rawAsset["url"]), atlasName, retainATFData);
							}
							else {
								if(verbose)
									log("[TEXTURE MANAGER]Ignoring file '" + rawAsset["name"] + "' - Its not a XML");
							}
						}
					}
				}
				else if (rawAsset is String){
					atlasName = rawAsset.split(sep).pop();
					extention = atlasName.split(".")[1];
					atlasName = objectName.split(".")[0];
					
					if (extention != "xml") 
						throw Error("[TEXTURE MANAGER]Ignoring file '" + rawAsset["name"] + "' - Its not a XML");
					
					fileCount++;	
					loadAtlasConfig(String(rawAsset), atlasName, retainATFData);
				}
				else {
					if(verbose)
						log("[TEXTURE MANAGER]Ignoring unsupported asset type: " + getQualifiedClassName(rawAsset));
				}
			}
		}
		
		private function loadAtlasConfig(url:String, atlasName:String, retainATFData:Boolean):void {
			if(verbose)
				log("[TEXTURE MANAGER]Loading XML: " + url);
			
			persistentATFs[atlasName] = retainATFData;
			
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.addEventListener(Event.COMPLETE, onUrlLoaderComplete);
			urlLoader.load(new URLRequest(url));	
			
			function onUrlLoaderComplete(event:Event):void {
				var urlLoader:URLLoader = event.target as URLLoader;	
				var bytes:ByteArray = urlLoader.data as ByteArray;
				urlLoader.removeEventListener(Event.COMPLETE, onUrlLoaderComplete);
					
				var xmlTemp:XML = new XML(bytes);
				if (xmlTemp.localName() == "TextureAtlas")
					parseAtlasXml(xmlTemp, retainATFData, url);
				else
					throw Error("[TEXTURE MANAGER] XML for:" + atlasName + " has not a TextureAtlas patern");
				
				System.disposeXML(xmlTemp);
				
				urlLoader.close();
				urlLoader = null;

				bytes.clear();
				bytes = null;
			}
		}

		private var appPathString:String = File.applicationDirectory.url;

		private function parseAtlasXml(atlasXml:XML, retainATFData:Boolean, XMLUrl:String):void{
			if(verbose)
				log("[TEXTURE MANAGER]Parsing XML related to texture: " + atlasXml.@imagePath.toString());
			
			var objectName:String;
			var atlasName:String = atlasXml.@imagePath.toString();

			//var path:String = url.split(".")[0];
			
			var region:Rectangle;
			var frame:Rectangle;
			var tempNames:Array;
			var subName:String;
			var frameNumber:uint;
			var isAnimation:Boolean;
			var index:int = 0;
			var rotated:Boolean;
			var subTexture:XML;
			var texture:XML = atlasXml;
			var textureWidth:int = int(texture.@width);
			var textureHeight:int = int(texture.@height);
			var pma:Boolean = Boolean(texture.@pma);
			var repeat:Boolean = Boolean(texture.@repeat);
			var textureMipMap:Boolean = Boolean(atlasXml.@mipMap == "false" ? false : true);

			var frameX:Number;
			var frameY:Number;
			var frameWidth:Number;
			var frameHeight:Number;
			
			if (!textureMipMap)
				trace("mipmap false");
			
			var width:uint;
			var height:uint;
			
			//We extract the path of the file wihout the "app:/" and removing the "xml" extention. Them we verify if there is the conterpat png or art tex file
			var textureURL:String = XMLUrl.substr(appPathString.length, XMLUrl.length - (appPathString.length + 3));

			// See if texture file is PNG if it is texture can have power of 2 sizes
			var pngFile:File = File.applicationDirectory.resolvePath(textureURL + "png");
			var atfFile:File = File.applicationDirectory.resolvePath(textureURL + "atf");
			var textIsPNG:Boolean = pngFile.exists;

			if (!textureWidth || !textureHeight)
				throw Error("atlasXml does not contain information about texture witdh and/or height"); 
			
			if (!(textureWidth > 0 && (textureWidth & (textureWidth - 1)) == 0) && !textIsPNG)
				throw Error("texture witdh is not power of 2"); 
			
			if (!(textureHeight > 0 && (textureHeight & (textureHeight - 1)) == 0) && !textIsPNG)
				throw Error("texture height is not power of 2"); 
			
			if (pngFile.exists){
				textureURL = pngFile.url;
			}
			else if (atfFile.exists) {
				textureURL = atfFile.url;
			}
			else{
				throw Error("there is texture on url: " + textureURL + " neither using extention atf not png");
			}
			
			atlasName = atlasName.split(".")[0];
			
			//if (textIsPNG)
				//trace("Texture Managewhgat is this")
			
			for each (subTexture in atlasXml.SubTexture){
				tempNames = cleanMasterString(subTexture.@name).split("_");
				
				if (tempNames.length >= 3) {
					isAnimation	= true;
					frameNumber = uint(tempNames[tempNames.length - 1]);
					subName = tempNames[tempNames.length - 2];
					tempNames.pop();
					tempNames.pop();
				}
				else{
					frameNumber = 0;
					subName = tempNames[tempNames.length - 1];
					tempNames.pop();
				}
				
				objectName = tempNames.join("_");
				
				if (!atlasTexturesURLs[objectName])
					atlasTexturesURLs[objectName] = new Array();
				
				if(atlasTexturesURLs[objectName].indexOf(textureURL) == -1)
					atlasTexturesURLs[objectName].push(textureURL);				
				
				if (!atlasTexturesRelations[atlasName])
					atlasTexturesRelations[atlasName] = new Array();
				
				if (atlasTexturesRelations[atlasName].indexOf(objectName) < 0)
					atlasTexturesRelations[atlasName].push(objectName);
				
				region = new Rectangle();
				frame = null;
				
				region.x = parseFloat(subTexture.@x) / mScaleFactor;
				region.y = parseFloat(subTexture.@y) / mScaleFactor;
				region.width = parseFloat(subTexture.@width) / mScaleFactor;
				region.height = parseFloat(subTexture.@height) / mScaleFactor;

				rotated = parseBool(subTexture.@rotated);

                frameX      	= parseFloat(subTexture.@frameX) / mScaleFactor;
                frameY      	= parseFloat(subTexture.@frameY) / mScaleFactor;
                frameWidth  	= parseFloat(subTexture.@frameWidth)  / mScaleFactor;
                frameHeight 	= parseFloat(subTexture.@frameHeight) / mScaleFactor;
				
                if (frameWidth > 0 && frameHeight > 0){
					frame = new Rectangle();
					
					frame.x = parseFloat(subTexture.@frameX) / mScaleFactor;
					frame.y = parseFloat(subTexture.@frameY) / mScaleFactor;
					frame.width = parseFloat(subTexture.@frameWidth) / mScaleFactor;
					frame.height = parseFloat(subTexture.@frameHeight) / mScaleFactor;
					
					if(!packsSubtextureSizes[objectName])
						packsSubtextureSizes[objectName] = new Rectangle(0, 0, frame.width, frame.height);
				}
				else{
					// This will create problems!!!
					//frame.x = 0;
					//frame.y = 0;
					//frame.width = region.width;
					//frame.height = region.height;
					if(!packsSubtextureSizes[objectName])
						packsSubtextureSizes[objectName] = new Rectangle(0, 0, region.width, region.height);
				}
				
				if (!atlasTexturesLoaded[objectName]){
					atlasTexturesLoaded[objectName] = new Dictionary();
					packUsage[objectName] = 0;
					onTexturePackCreated[objectName] = new Signal(String);
					atlasPacksLoaded[objectName] = "unloaded";
					numOfPacks++;
				}
				
				if (!atlasTextures[atlasName]) {
					atlasTextures[atlasName] = new NativeTextureConfig(atlasName, textureWidth, textureHeight, false, textureMipMap, mScaleFactor, repeat);
					numOfTextures++;
				}
				
				if (!atlasTexturesLoaded[objectName][atlasName]) {
					atlasTexturesLoaded[objectName][atlasName] = "unloaded";
				}
				
				if (!subTextures[objectName]){
					subTextures[objectName] = new Dictionary();
					subTexByFullName[objectName + "_" + subName] = new Dictionary();
					subTexturesNames[objectName] = new Vector.<String>();
				}
				
				if (!subTextures[objectName][subName]){
					subTextures[objectName][subName] = new TexturesCache(subName, objectName, isAnimation);
					subTexByFullName[objectName + "_" + subName] = subTextures[objectName][subName];
					subTexturesNames[objectName].push(subName);
				}
				
				(subTextures[objectName][subName] as TexturesCache).setTextureAndConfig(atlasTextures[atlasName].texture, region, frame, frameNumber, atlasTextures[atlasName] as NativeTextureConfig, rotated);
				
				System.disposeXML(subTexture);
			}
			
			fileCount--;
			
			System.disposeXML(atlasXml);
		}
		
		private function restoreTextureFromContextLost(url:String, process:Function):void{
			
		}
		
		private function processTextures(objectName:String, ... rawAssets):void {
			var regExp:RegExp;
			var extention:String;
			var url:String;
			var atlasName:String;
			
			for each (var rawAsset:Object in rawAssets){
				if (rawAssets as String)
					regExp;
				
				/** If rawAsset is a array inside rawAssets, send it back to function only itself */
				if (rawAsset is Array){
					for each (var rawSubAsset:Object in rawAsset){
						processTextures.apply(TextureManager, [objectName, rawSubAsset]);
					}
				}
				else if (rawAsset as String) {
					url = rawAsset as String;
					extention = url.split(sep).pop().split(".")[1];
					atlasName = url.split(sep).pop().split(".")[0];
					if(verbose)
						log("[TEXTURE MANAGER]Processing texture: " + atlasName);
					
					if(extention == "atf" || extention == "png"){
						if (persistentATFs[atlasName] && atfDatas[atlasName]){
							restoreTexture(objectName, atlasName);
							return;
						}
						//continue
					}
					else 
						throw Error("extention os non ATF nor PNG");
					
					if ((atlasTextures[atlasName] as NativeTextureConfig).dataUploaded){
						if(verbose)
							log("[TEXTURE MANAGER] Texture with name: " + objectName + " already exist. Ignoring")
						return;
					}
					
					if (extention == "atf" || extention == "png"){
						var index:String;
						for (index in atlasTexturesRelations[atlasName]){
							atlasTexturesLoaded[atlasTexturesRelations[atlasName][index]][atlasName] = "loading"; //Texture from this pack is loading
							
							if (atlasPacksLoaded[atlasTexturesRelations[atlasName][index]] == "unloaded")
								atlasPacksLoaded[atlasTexturesRelations[atlasName][index]] = "loading"; //Pack is loading
						}
					}

					var textureRequest:TextureLoadRequest = new TextureLoadRequest(objectName, atlasName, url, extention, null);
					
					if (extention == "png") {
						var imgLoader:PNGTextureLoader = new PNGTextureLoader();
						
						imgLoader.objectName = objectName;
						imgLoader.atlasName = atlasName;
						imgLoader.url = url;
						imgLoader.textureLoadRequest = textureRequest;

						imgLoader.load(new URLRequest(url));
						imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, textureDataLoadCompletePNG);
					}
					else {
						if(loadAsync){
							var file:File = new File(url);
							textureRequest.fileStream = new FileStream();

							textureRequest.fileStream.addEventListener(Event.COMPLETE, 
																				function(event:Event):void {
																					textureDataLoadCompleteATF(event, textureRequest);
																				});
							textureRequest.fileStream.addEventListener(IOErrorEvent.IO_ERROR, 
																				function(event:IOErrorEvent):void {
																					textureDataLoadATFError(event, textureRequest);
																				});
							textureRequest.fileStream.openAsync(file, FileMode.READ);
						}
						else{
							uploadTextureDataToGPU(objectName, atlasName, loadTextureData(url));
						}
					}
					
				}
				else 
					if(verbose)
						log ("[TEXTURE MANAGER] rawAssets not supported " + rawAsset);
			}
		}

		public static function loadTextureData(filePath:String):ByteArray{
			var file:File;
			var fileStream:FileStream = new FileStream();
			var bytes:ByteArray = new ByteArray();
			
			var appDirFile:File;
			var xmlFile:File;
			
			appDirFile = new File(filePath);
			xmlFile = new File(appDirFile.nativePath);
			
			fileStream.open(xmlFile, FileMode.READ);
			fileStream.readBytes(bytes);
			fileStream.close();	
			
			return bytes;
		}

        private function textureDataLoadATFError(event:IOErrorEvent, textureRequest:TextureLoadRequest):void {
            textureRequest.fileStream.close();
            textureRequest.fileStream.removeEventListener(Event.COMPLETE, textureDataLoadCompleteATF);
            textureRequest.fileStream.removeEventListener(IOErrorEvent.IO_ERROR, textureDataLoadATFError);
            
            throw Error("[TEXTURE MANAGER] Texture can't be loaded " + event.text);
        }

		private function textureDataLoadCompletePNG(event:Event):void {
			var textureData:Object;
			var bitmapData:BitmapData = Bitmap(event.target.content).bitmapData;
			var imgLoaded:PNGTextureLoader = event.target.loader as PNGTextureLoader;

			textureData = bitmapData;

			imgLoaded.contentLoaderInfo.removeEventListener(Event.COMPLETE, textureDataLoadCompletePNG);
			
			uploadTextureDataToGPU(imgLoaded.textureLoadRequest.objectName, imgLoaded.textureLoadRequest.atlasName, textureData);
		}

		private function textureDataLoadCompleteATF(event:Event, textureRequest:TextureLoadRequest):void {
			try {
				var textureData:Object;
				
				var objectNameLoaded:String;
				var atlasNameLoaded:String;
				var url:String;

				var textureDataBytes:ByteArray = new ByteArray();
				textureRequest.fileStream.readBytes(textureDataBytes);
				
				textureData = textureDataBytes;
				
				uploadTextureDataToGPU(textureRequest.objectName, textureRequest.atlasName, textureData);

				textureRequest.fileStream.close();
				textureRequest.fileStream.removeEventListener(Event.COMPLETE, textureDataLoadCompleteATF);
				textureRequest.fileStream.removeEventListener(IOErrorEvent.IO_ERROR, textureDataLoadATFError);	
				
			} catch (e:Error) {
				// Handle the error, possibly logging it or showing an error message
				trace("Error loading texture data: " + e.message);
				textureDataBytes.clear();
				textureDataBytes = null;
				// Consider additional recovery or notification steps here
			} finally {
				// Ensuring the file stream is always closed and listeners are removed
				if (textureRequest.fileStream) {
					textureRequest.fileStream.close();
					textureRequest.fileStream.removeEventListener(Event.COMPLETE, textureDataLoadCompleteATF);
					textureRequest.fileStream.removeEventListener(IOErrorEvent.IO_ERROR, textureDataLoadATFError);
				}
			}
		}			
		
		private function parseBool(value:String):Boolean { return !(value == "" || value.toLowerCase() == "false"); }
		
		public static var loadAsync:Boolean = true;
		private function uploadTextureDataToGPU(objectName:String, atlasName:String, textureData:Object):void {
			if (packUsage[objectName] <= 0)	{
				if (textureData as ByteArray) {
					(textureData as ByteArray).clear();
					//(atlasTextures[atlasName].texture as Texture).root.onRestore = null;
				}
				else if (textureData as BitmapData) {
					(textureData as BitmapData).dispose();
					//(atlasTextures[atlasName].texture as Texture).root.onRestore = null;
				}
				
				(atlasTextures[atlasName] as NativeTextureConfig).dataUploaded = false;
				
				if(verbose)
					log("[TEXTURE MANAGER] Pack got usage 0 before texture got loaded: Disposing '" + atlasName + "' " + ((textureData as ByteArray) ? "ByteArray" : (textureData as BitmapData) ? "ByteArray" : "unsuported"));
				
				var index:String;
				for (index in atlasTexturesRelations[atlasName]){
					atlasTexturesLoaded[atlasTexturesRelations[atlasName][index]][atlasName] = "unloaded"; //Texture from this pack is unloaded
					
					if (atlasPacksLoaded[atlasTexturesRelations[atlasName][index]] != "unloaded")
						atlasPacksLoaded[atlasTexturesRelations[atlasName][index]] = "unloaded"; //Pack is unloaded
				}
			}
			else{
				if(verbose)
					log("[TEXTURE MANAGER]Adding texture '" + atlasName + "' " + ((textureData as ByteArray) ? "ByteArray" : (textureData as BitmapData) ? "ByteArray" : "unsuported"));
				
				if (textureData as ByteArray){
					(atlasTextures[atlasName].texture as Texture).root.uploadAtfData(textureData as ByteArray, 0, loadAsync ? textureCreatedDispatcher : null);
					(atlasTextures[atlasName].texture as Texture).root.objectName = objectName;
					(atlasTextures[atlasName].texture as Texture).root.atlasName = atlasName;
					(textureData as ByteArray).clear();
					if (!loadAsync)
						textureCreatedDispatcher((atlasTextures[atlasName].texture as Texture));
				}
				else if (textureData as BitmapData) {
					(atlasTextures[atlasName].texture as Texture).root.uploadBitmapData(textureData as BitmapData);
					(atlasTextures[atlasName].texture as Texture).root.objectName = objectName;
					(atlasTextures[atlasName].texture as Texture).root.atlasName = atlasName;
					textureCreatedDispatcher(atlasTextures[atlasName].texture);
					(textureData as BitmapData).dispose();
				}
				else {
					throw Error("[TEXTURE MANAGER] texture data not supported");
				}
			}
		}
		
        private var mNumLostTextures:int;
        private var mNumRestoredTextures:int;
		
		private function restoreTexture(objectName:String, atlasName:String):void{
			if(verbose)
				log("[TEXTURE MANAGER] uploadATFData '" + atlasName + "'");
			(atlasTextures[atlasName].texture as Texture).root.uploadAtfData(atfDatas[atlasName], 0, textureCreatedDispatcher);
		}
		
		/** Remove a function used as callback for a particular pack */
		public function removeCallback(packName:String, callback:Function):void{
			onTexturePackCreated[packName].remove(callback);
		}

		/** Tell AtlasManager a object will use a particular Atlas pack
		 * If pack was not loaded yet Atlas Manager will load it
		 * You need to add a function to atlasPacksLoaded signal in order to know when this pack will be aviable */
		public function checkIn(packName:String, callback:Function, checker:String):void{
			if (!packUsage.hasOwnProperty(packName))
				throw Error("[TEXTURE MANAGER] Texture Pack " + packName + " does not Exist");
			
			if (!packUsageByChecker[checker])
				packUsageByChecker[checker] = 1;
			else
				packUsageByChecker[checker]++;
			
			packUsage[packName]++;
			
			if(verbose)
				log("[TEXTURE MANAGER] Adding Usage for: " + packName + " / current: " + packUsage[packName]);
			
			if (atlasPacksLoaded[packName] == "unloaded") {
				if(verbose)
					log("[TEXTURE MANAGER] " + " atlas pack " + packName + " is " + atlasPacksLoaded[packName] + "(unloaded?)");
				
				//Need to know atlasName from object name
				processTextures(packName, atlasTexturesURLs[packName]);
				
				if(callback)
					onTexturePackCreated[packName].addOnce(callback);
			}
			else if (atlasPacksLoaded[packName] == "loading") {
				if(verbose)
					log("[TEXTURE MANAGER] " + " atlas pack " + packName + " is " + atlasPacksLoaded[packName] + "(loading?)");
				
				if(callback)
					onTexturePackCreated[packName].addOnce(callback);
			}
			else {
				if(verbose)
					log("[TEXTURE MANAGER] " + " atlas pack " + packName + " is " + atlasPacksLoaded[packName] + "(loaded?)");
				if(callback)
					callback.call(TextureManager, packName);
			}
		}
		
		/** Tell Atlas Manager a object is not using a particular Atlas pack anymore
		 * If atlas usage reach 0 this pack will be disposed freeing memory */
		public function checkOut(objectName:String, checker:String):void{
			if (!packUsage.hasOwnProperty(objectName))
				throw Error("Texture Pack " + objectName + " does not Exist");
			
			if (!packUsageByChecker[checker])
				throw Error("Checker did not check in before check out, there is some error on the logic");
			
			packUsageByChecker[checker]--;
			
			if (packUsageByChecker[checker] == 0)
				delete packUsageByChecker[checker];
			
			packUsage[objectName]--;
			
			if(packUsage[objectName] < 0)
				throw Error ("pack usage pack was checkout more than it was check in. There is a problem with you code doing that");
			
			if(verbose)
				log("[TEXTURE MANAGER] Removing Texture Usage for " + objectName + " / Remaining " + packUsage[objectName]);
			
			if (packUsage[objectName] == 0) {
				if(verbose)
					log("[TEXTURE MANAGER] " + " atlas usage is 0, disposing pack " + objectName);
				disposeAtlasTexturePack(objectName);
			}
		}
		
		private function textureCreatedDispatcher(texture:Texture):void{
			if(verbose)
				log("[TEXTURE MANAGER] " + texture.name + " is Loaded");
			
			var atlasName:String = texture.name;
			var dispatchPack:Boolean = true;
			
			var index:String;
			var atlasNameTemp:String;
			var packName:String;
			var addTXLoadCount:int = 0;
			
			for (index in atlasTexturesRelations[atlasName]){
				packName = atlasTexturesRelations[atlasName][index]; //Pack Name
				
				if(!(atlasTextures[atlasName] as NativeTextureConfig).dataUploaded){
					(atlasTextures[atlasName] as NativeTextureConfig).dataUploaded = true;
					numOfTexturesLoaded++; 
				}
				
				atlasTexturesLoaded[packName][atlasName] = "loaded"; //Texture from this pack is loaded
				
				if(verbose)
					log("[TEXTURE MANAGER] Atlas " + atlasName + " loaded - packName: " + packName + " packUsage: " + packUsage[packName] + " time: " + GameEngine.timeSinceEngineStart);
				
				dispatchPack = true; //Reset dispah order
				
				//See if all textures for the packs was loaded
				for (atlasNameTemp in atlasTexturesLoaded[packName]){
					if (atlasTexturesLoaded[packName][atlasNameTemp] != "loaded")
						dispatchPack = false;
				}
				
				if (dispatchPack) {
					if(verbose)
						log("[TEXTURE MANAGER] Pack " + packName + " isLoaded - " + GameEngine.timeSinceEngineStart);
					
					numOfPacksLoaded++;
					addTXLoadCount++;
					
					atlasPacksLoaded[packName] = "loaded";
					
					onTexturePackCreated[packName].dispatch(packName);
				}
			}
			//trace("TEXTURE MANAGER", texture.name, addTXLoadCount);
			
			//if(addTXLoadCount == 0)
				//trace("TEXTURE MANAGER NO COUNT CNHANGED", texture.name, addTXLoadCount);
			
			onTextureCreated.dispatch(atlasTextures);
		}
		
		/** Dispose Atlas textures from a particular pack. Subtextures creted from this textures will not be destroyed but will not be able to be rendered */
		public function disposeAtlasTexturePack(objectName:String):void{
			var atlasName:String;
			var packName:String;
			var dispose:Boolean;
			var addTXLoadCount:int = 0;
			
			for (atlasName in atlasTexturesLoaded[objectName]) {
				dispose = true;
				
				for each(packName in atlasTexturesRelations[atlasName]) {
					if (packUsage[packName] > 0){
						dispose = false;
						if(verbose)
							log("[TEXTURE MANAGER] " + "other pack " + packName + " using this texture do not dispose");
					}
				}
				
				if (dispose && (atlasTextures[atlasName] as NativeTextureConfig).dataUploaded){
					(atlasTextures[atlasName] as NativeTextureConfig).texture.dispose();
					(atlasTextures[atlasName] as NativeTextureConfig).dataUploaded = false;
					
					numOfTexturesLoaded--;
					
					if(verbose)
						log("[TEXTURE MANAGER] " + " atlas texture " + atlasName + " disposed " + atlasTextures[atlasName]);
					
					for each(packName in atlasTexturesRelations[atlasName]) {
						if (atlasPacksLoaded[packName] != "unloaded") {
							
							if (atlasPacksLoaded[packName] != "loading"){
								numOfPacksLoaded--;
								addTXLoadCount--;
							}
							
							if (numOfPacksLoaded < 0)
								trace ("TEXTURE MANGER. num of packs Below 0, WHATS HAPPENED???");
							
							atlasPacksLoaded[packName] = "unloaded";
							
							if(verbose)
								log("[TEXTURE MANAGER] Pack " + packName + " unloaded");
							
							atlasTexturesLoaded[packName][atlasName] = "unloaded";
						}
					}
				}
				
				else if (!dispose){
					atlasPacksLoaded[objectName] = "loadedByOtherPack";
				}
			}
			//trace("TEXTURE MANAGER", objectName, addTXLoadCount);
			
			//if(addTXLoadCount == 0)
				//trace("TEXTURE MANAGER NO COUNT CNHANGED", objectName, addTXLoadCount);
		}

		
		/** Return the size of the texture this object use usefull to avoid getBound() witch is expensive*/
		public function getTextureSize(objectName:String):Rectangle {
			return packsSubtextureSizes[objectName];
		}
		
		/** Retrieves a subtextures by object name. */
		public function getTextures(objectName:String, subName:String):Vector.<Texture>{
			if (subTextures[objectName][subName].textures[0] == null){
				if(AppInfo.isDebugBuild)
					throw Error("Some of the animations frames has no information. Certify XML file has config for all frames and animation start at frame 0");
				else
					return subTexByFullName["Debug_box"].textures[0];	
			}
			else
				return subTextures[objectName][subName].textures;
		}
		
		/** Pack a TextureCache based on object name and sub names */
		public function getTextureCache(objectName:String, subName:String ):TexturesCache {
			if (subTextures[objectName][subName].textures[0] == null)
				if(AppInfo.isDebugBuild)
					throw Error("Some of the animations frames has no information. Certify XML file has config for all frames and animation start at frame 0");
				else
					return subTexByFullName["Debug_box"].textures[0];	
			else
				return subTextures[objectName][subName];
		}
		
		private var hSubName:String;
		private var hcIndex:uint;
		private var hBaseTexture:TextureBase;
		private var helperTextureCaches:Vector.<TexturesCache> = new Vector.<TexturesCache>();
		private var hTexturesCache:TexturesCache;
		/** Pack a group of textures caches in a vector based on object name and sub names */
		public function getTextureCaches(objectName:String, subNames:Array = null ):Vector.<TexturesCache> {
			helperTextureCaches = new Vector.<TexturesCache>();
			
			if (!subNames || subNames.length == 0)
				subNames = subTexturesNames[objectName];
			
			if(subNames.length > 1){
				for (hcIndex in subNames) {
					hSubName = subNames[hcIndex];
					hTexturesCache = subTextures[objectName][hSubName];
					
					if (!hBaseTexture)
						hBaseTexture = hTexturesCache.textures[0].base;
					
					if (hTexturesCache.textures[0].base && hBaseTexture != hTexturesCache.textures[0].base)
						throw Error ("SubNames uses diferent base textures, this is not supported");
					
					helperTextureCaches.push(hTexturesCache);
				}
			}
			else if (subNames.length == 1) {
				helperTextureCaches.push(subTextures[objectName][subNames[0]])
			}
			
			return helperTextureCaches;
		}
		
		private function log(message:String):void {
			if (!message || message == "")
				trace("TEXTUREMANAGER: No message");
			if (verbose)
				trace(message);
		}
	}
}