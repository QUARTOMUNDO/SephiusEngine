package SephiusEngine.assetManagers
{
	import SephiusEngine.displayObjects.textures.ExtendedTextureAtlas;

	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ImageDecodingPolicy;
	import flash.system.LoaderContext;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;

	import starling.core.Starling;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;
    import starling.utils.cleanMasterString;
    
    
    /** 
	 * ADDED SUPPORT FOR MULTIPLE ASSETS BEING LOADED SAME TIME INDEPENDLY
	 * @author Fernando Rabello
	 * The AssetManager handles loading and accessing a variety of asset types. You can 
     *  add assets directly (via the 'add...' methods) or asynchronously via a queue. This allows
     *  you to deal with assets in a unified way, no matter if they are loaded from a file, 
     *  directory, URL, or from an embedded object.
     *  
     *  <p>If you load files from disk, the following types are supported:
     *  <code>png, jpg, atf, mp3, xml, fnt</code></p>
     */    
    public class ExtendedAssetManager
    {
        private const SUPPORTED_EXTENSIONS:Vector.<String> = 
            new <String>["png", "jpg", "jpeg", "atf", "mp3", "xml", "fnt"]; 
        
        private var mScaleFactor:Number;
        private var mUseMipMaps:Boolean;
        private var mVerbose:Boolean;
        
        private var mRawAssets:Array;
		/**
		 * Store RawAssets in groups for make then been loaded independly
		 */
        public var rawAssetsGroups:Dictionary = new Dictionary();
        private var mTextures:Dictionary;
        private var mAssetUsage:Dictionary;
        private var mAtlases:Dictionary;
        private var mSounds:Dictionary;
        private var mSoundsUsage:Dictionary;
        private var count:int = 0; 
        /** helper objects */
        private var sNames:Vector.<String> = new <String>[];
        
        /** Create a new AssetManager. The 'scaleFactor' and 'useMipmaps' parameters define
         *  how enqueued bitmaps will be converted to textures. */
        public function ExtendedAssetManager(scaleFactor:Number=-1, useMipmaps:Boolean=false)
        {
            mVerbose = false;
            mScaleFactor = scaleFactor > 0 ? scaleFactor : Starling.contentScaleFactor;
            mUseMipMaps = useMipmaps;
            mRawAssets = [];
            mTextures = new Dictionary();
            mAssetUsage = new Dictionary();
            mAtlases = new Dictionary();
            mSounds = new Dictionary();
            mSoundsUsage = new Dictionary();
        }
        
        /** Disposes all contained textures. */
        public function dispose():void
        {
            for each (var texture:Texture in mTextures)
                texture.dispose();
				
            for (var key:String in mAssetUsage)
                mAssetUsage[key] = 0;
				
            for each (var atlas:ExtendedTextureAtlas in mAtlases)
                atlas.dispose();
			
        }
        
        // retrieving
		
        /** Make AssetManager know how many times a texture is used. 
		 * Each time a texture is assigned to a object you should call this function.
		 * Each time a texture is removed from a object or if this object is destroyed you should call this function.
		 * This is usefull to see if a texture should be deployed from asset manager when is no longer used by any object.
		 * Usefull when you are working with dynamic object´s creation/destruction and multiple object using same textures.
         **/
        public function checkInOut(name:String, checkIn:Boolean):void  {
			log("ASSET: " + "Check" + (checkIn ? "IN" : "OUT") + " --" + name + "-- " + mAssetUsage[name]);
			if (!rawAssetsGroups[name])
				throw Error("There is no Asset Group with name " + name);
			
			if (!checkIn && mAssetUsage[name] <= 1) {
				removeGroup(name);
				/*
				for each( var textureAtlas:String in mRawAssetsGroups[name].atlasNames) {
					removeTextureAtlas(textureAtlas, true);
				}
				delete mRawAssetsGroups[name];
				delete mAssetUsage[name];
				*/
				return;
			}
			mAssetUsage[name] += checkIn ? 1 : -1;
        }
		
		public function removeGroup(name:String):void {
			if (!rawAssetsGroups[name]) {
				throw Error("[ASSET MANAGER]Asset group does not exist: " + name)
				return;
			}
			for each( var textureAtlas:String in rawAssetsGroups[name].atlasNames) {
				removeTextureAtlas(textureAtlas, true);
			}
			for each( var texture:String in rawAssetsGroups[name].textureNames) {
				removeTexture(texture, true);
			}
			delete rawAssetsGroups[name];
			delete mAssetUsage[name];
		}
		
		/**
		 * Return the number of objects that is using this texture.
		 * This is not automatic. You must checking and checkout texture each time you assign a texture to a object.
		 * If this function returns -1, its means that this group was not exist and was not send to load yet.
		 * If it´s returns 0, its means that this group exist but is in loading progress.
		 * If returns above 0, its means the group exist and assets was already loaded.
		 */
		public function getAssetGroupUsage(groupName:String):int {
			log("ASSET>Verifying Group Usage" + " --" + groupName+ "-- " + rawAssetsGroups[groupName]);
			if (rawAssetsGroups[groupName]) {
				if (rawAssetsGroups[groupName].onProgessFunctions.lenght > 0) {
					//trace("assets usage: -2: Assets are loading");
					return 0;
				}
				//trace("assets usage: Assets are loaded", mAssetUsage[groupName]);	
				return mAssetUsage[groupName];
			}
			else {
				//trace("assets usage: -1: Assets does not exist");
                return -1;
			}
		}
		
		/**
		 * Add a function to "listen" a asset group loading. 
		 * Used when 2 objects need same asset groups at same time.
		 */
		public function addOnProgressFunctionToAssetGroup(groupName:String, onProgressFunction:Function):void {
			rawAssetsGroups[groupName].onProgessFunctions.push(onProgressFunction);
		}
		
        /** Returns a texture with a certain name. The method first looks through the directly
         *  added textures; if no texture with that name is found, it scans through all 
         *  texture atlases. */
        public function getTexture(name:String, bypassToAtlasManager:Boolean = false):Texture
        {
            if (name in mTextures) return mTextures[name];
            else
            {
                for each (var atlas:ExtendedTextureAtlas in mAtlases)
                {
                    var texture:Texture = atlas.getTexture(name);
                    if (texture) return texture;
                }
				throw Error("there no texture with name " + name + " on this asset manager");
                return null;
            }
        }
        
        /** Returns all textures that start with a certain string, sorted alphabetically
         *  (especially useful for "MovieClip"). */
        public function getTextures(prefix:String="", result:Vector.<Texture>=null, sort:Boolean = true):Vector.<Texture>
        {
            if (result == null) result = new <Texture>[];
            
            for each (var name:String in getTextureNames(prefix, sNames, sort))
                result.push(getTexture(name));
            
            sNames.length = 0;
            return result;
        }
        
        /** Returns all texture names that start with a certain string, sorted alphabetically. */
        public function getTextureNames(prefix:String="", result:Vector.<String>=null, sort:Boolean = true):Vector.<String>
        {
            if (result == null) result = new <String>[];
            
            for (var name:String in mTextures)
                if (name.indexOf(prefix) == 0)
                    result.push(name);                
            
            for each (var atlas:ExtendedTextureAtlas in mAtlases)
                atlas.getNamesE(prefix, result, sort);
			if(sort)
				result.sort(Array.CASEINSENSITIVE);
            return result;
        }
		
		public function getAnimationNames(animationName:String = "", result:Vector.<String> = null):Vector.<String> {
            if (result == null) result = new <String>[];
            
            for each (var atlas:ExtendedTextureAtlas in mAtlases){
                atlas.getAnimationNames(animationName, result);
			}
				
            return result;
		}
		
		/** Returns a specifc part of all texture names that start with a certain string, sorted alphabetically
		 * @param	prefix string witch texture name should star with
		 * @param	splitChar charactere that divide the texture name in parts. Textures with pathern like "name_animation_0000" could be divided in 3 parts for example, retuning one of this 3 parts.
		 * @param	position Once texture name is divided in parts, this tell what part should be returned.
		 * @param	result
		 * @return
		 */
        public function getPartOfTextureNames(prefix:String="", splitChar:String="_", position:int=1, result:Vector.<String>=null, sorted:Boolean = true):Vector.<String>
        {
            if (result == null) result = new <String>[];
            
            for (var name:String in mTextures)
                if (name.indexOf(prefix) == 0)
                    result.push(name.split(splitChar)[position]);          
            
            for each (var atlas:ExtendedTextureAtlas in mAtlases) {
               for each (name in atlas.getNames(prefix)) {
				   if (result.indexOf(name.split(splitChar)[position]) == -1){
					result.push(name.split(splitChar)[position]);
					trace(name.split(splitChar)[position]);
				   }
			   }
			}
            if (sorted)
				result.sort(Array.CASEINSENSITIVE);
            return result;
        }
		
        /** Returns a texture atlas with a certain name, or null if it's not found. */
        public function getTextureAtlas(name:String):ExtendedTextureAtlas
        {
            return mAtlases[name] as ExtendedTextureAtlas;
        }
        
        /** Returns a sound with a certain name. */
        public function getSound(name:String):Sound
        {
            return mSounds[name];
        }
        
        /** Returns all sound names that start with a certain string, sorted alphabetically. */
        public function getSoundNames(prefix:String=""):Vector.<String>
        {
            var names:Vector.<String> = new <String>[];
            
            for (var name:String in mSounds)
                if (name.indexOf(prefix) == 0)
                    names.push(name);
            
            return names;
        }
        
        /** Generates a new SoundChannel object to play back the sound. This method returns a 
         *  SoundChannel object, which you can access to stop the sound and to control volume. */ 
        public function playSound(name:String, startTime:Number=0, loops:int=0, 
                                  transform:SoundTransform=null):SoundChannel
        {
            if (name in mSounds)
                return getSound(name).play(startTime, loops, transform);
            else 
                return null;
        }
        
        // direct adding
        
        /** Register a texture under a certain name. It will be availble right away. */
        public function addTexture(name:String, texture:Texture, groupName:String=""):void
        {
            log("Adding texture '" + name + "'");
            
            if (name in mTextures){
				texture.dispose();
                trace("Duplicate texture name: " + name);
			}
            else{
                mTextures[name] = texture;
				texture.name = name;
			}
			
			if(groupName != "")
				rawAssetsGroups[groupName].textureNames.push(texture.name);
        }
        
        /** Register a texture atlas under a certain name. It will be availble right away. */
        public function addTextureAtlas(name:String, atlas:ExtendedTextureAtlas, groupName:String=""):void
        {
            log("Adding texture atlas '" + name + "'");
            
            if (name in mAtlases){
               trace("Duplicate texture atlas name: " + name);
			}
            else{
                mAtlases[name] = atlas;
			}
			
			if(groupName != "")
				rawAssetsGroups[groupName].atlasNames.push(name);
        }
        
        /** Register a sound under a certain name. It will be availble right away. */
        public function addSound(name:String, sound:Sound, groupName:String=""):void
        {
            log("Adding sound '" + name + "'");
            
            if (name in mSounds)
                throw new Error("Duplicate sound name: " + name);
            else
                mSounds[name] = sound;
			
			if(groupName != "")
				rawAssetsGroups[groupName].atlasNames.push(groupName);
        }
        
        // removing
        
        /** Removes a certain texture, optionally disposing it. */
        public function removeTexture(name:String, dispose:Boolean=true):void
        {
            if (dispose && name in mTextures)
                mTextures[name].dispose();
            
            delete mTextures[name];
        }
        
        /** Removes a certain texture atlas, optionally disposing it. */
        public function removeTextureAtlas(name:String, dispose:Boolean=true):void
        {
			var textureName:String;
			var atlas:ExtendedTextureAtlas;
			
            if (dispose && name in mAtlases)
                mAtlases[name].dispose();
            
            delete mAtlases[name];
        }
        
        /** Removes a certain sound. */
        public function removeSound(name:String):void
        {
            delete mSounds[name];
			delete mSoundsUsage[name];
        }
        
        /** Removes assets of all types and empties the queue. */
        public function purge():void
        {
            for each (var texture:Texture in mTextures)
                texture.dispose();
            
            for each (var atlas:ExtendedTextureAtlas in mAtlases)
                atlas.dispose();
			
            mRawAssets.length = 0;
			rawAssetsGroups = new Dictionary();
			mAssetUsage = new Dictionary();
            mTextures = new Dictionary();
            mAtlases = new Dictionary();
			mSoundsUsage = new Dictionary();
            mSounds = new Dictionary();
        }
		
        // queued adding
		/**
		 * Same thing like enqueue function but separate assets in gropups
		 * Each group name are loaded independently. This allows classes to enqueue assets freely withou intervere with themselfs.
		* Enqueues one or more raw assets; they will only be available after successfully 
         *  executing the "loadQueue" method. This method accepts a variety of different objects:
         *  
         *  <ul>
         *    <li>Strings containing an URL to a local or remote resource. Supported types:
         *        <code>png, jpg, atf, mp3, fnt, xml</code> (texture atlas).</li>
         *    <li>Instances of the File class (AIR only) pointing to a directory or a file.
         *        Directories will be scanned recursively for all supported types.</li>
         *    <li>Classes that contain <code>static</code> embedded assets.</li>
         *  </ul>
         *  
         *  Suitable object names are extracted automatically: A file named "image.png" will be
         *  accessible under the name "image". When enqueuing embedded assets via a class, 
         *  the variable name of the embedded object will be used as its name. An exception
         *  are texture atlases: they will have the same name as the actual texture they are
         *  referencing.
		 * 
		 * @param	groupName
		 * @param	...rawAssets
		 */
        public function enqueueAsGroup(groupName:String, ...rawAssets):void
        {
			//trace(count, " - ", "AssetMM", "groupName:", groupName, "inside:", rawAssets, "getQualifiedClassName:", getQualifiedClassName(rawAsset));
			
			count++;
			
            var childNodeName:String;

			if (!rawAssetsGroups[groupName]){
				rawAssetsGroups[groupName] = { gRawAssets:new Array(), onProgessFunctions:new Array(), atlasNames:new Array(), textureNames:new Array() };
			}
            for each (var rawAsset:Object in rawAssets)
            {
				//trace(count," - ", "AssetMM", "groupName:", groupName, "inside:", rawAsset, "getQualifiedClassName:", getQualifiedClassName(rawAsset));
				
                if (rawAsset is Array)
                {
					//trace (count," - ", "é array");
					for each (var rawSubAsset:Object in rawAsset) {
						//trace(count," - ", "AssetMMM", "groupName:", groupName, "inside:", rawSubAsset, "getQualifiedClassName:", getQualifiedClassName(rawSubAsset));
						enqueueAsGroup.apply(this, [groupName, rawSubAsset]);
					}
                }
				
                else if (rawAsset is Class)
                {
                    var typeXml:XML = describeType(rawAsset);
                    var childNode:XML;

                    childNodeName = cleanMasterString(typeXml.@name);

                    if (mVerbose)
                        log("Looking for static embedded assets in '" + 
                            (childNodeName).split("::").pop() + "'"); 
                    
                    for each (childNode in typeXml.constant.(@type == "Class")){
                        childNodeName = cleanMasterString(childNode.@name);
                        push(rawAsset[childNodeName], childNodeName, groupName);
                    }
                    
                    for each (childNode in typeXml.variable.(@type == "Class")){
                        childNodeName = cleanMasterString(childNode.@name);
                        push(rawAsset[childNodeName], childNodeName, groupName);
                    }
					
					System.disposeXML(typeXml);
                }
                else if (getQualifiedClassName(rawAsset) == "flash.filesystem::File")
                {
					//trace (count," - ", (rawAsset as File).name); 
                    if (!rawAsset["exists"])
                    {
                        log("File or directory not found: '" + rawAsset["url"] + "'");
                    }
                    else if (!rawAsset["isHidden"])
                    {
                        if (rawAsset["isDirectory"])
                            enqueueAsGroup.apply(this, [groupName, rawAsset["getDirectoryListing"]()]);
                        else
                        {
							//trace (count," - ", (rawAsset as File).name); 
                            var extension:String = rawAsset["extension"].toLowerCase();
                            if (SUPPORTED_EXTENSIONS.indexOf(extension) != -1){
                                push(rawAsset["url"], null, groupName);
							}
                            else
                                log("Ignoring unsupported file '" + rawAsset["name"] + "'");
                        }
                    }
                }
                else if (rawAsset is String)
                {
                    push(rawAsset, null, groupName);
                }
                else
                {
                    log("Ignoring unsupported asset type: " + getQualifiedClassName(rawAsset));
                }
            }
            
            function push(asset:Object, name:String=null, groupName:String=null):void
            {
				
                if (name == null) name = getName(asset);
                log("Enqueuing '" + name + "'" + " / group: '" + groupName + "'");
                rawAssetsGroups[groupName].gRawAssets.push({ 
                    name: name, 
                    asset: asset
                });
            }
        }
		
		public static function countKeys(myDictionary:Dictionary):int 
		{
			var n:int = 0;
			for (var key:* in myDictionary) {
				n++;
			}
			return n;
		}		
		
		/**
		 * Same as loadQueue function but this works with enqueueAsGroup function
		 * Loads all enqueued assets asynchronously. The 'onProgress' function will be called
         *  with a 'ratio' between '0.0' and '1.0', with '1.0' meaning that it's complete.
		 */
        public function loadQueueGroup(onProgress:Function, groupName:String):void
        {
            if (Starling.context == null)
                throw new Error("The Starling instance needs to be ready before textures can be loaded.");
            
            var xmls:Vector.<XML> = new <XML>[];
			var atlasXmls:Vector.<XML> = new <XML>[];
            var numElements:int = rawAssetsGroups[groupName].gRawAssets.length;
            var currentRatio:Number = 0.0;
            var timeoutID:uint;
			var onProgressFunction:Function;
			if(!mAssetUsage[groupName])
				mAssetUsage[groupName] = 0;
			//trace("Load Assets", groupName, mAssetUsage[groupName], mRawAssetsGroups[groupName]);
            rawAssetsGroups[groupName].onProgessFunctions.push(onProgress);
			
            resume();
            
            function resume():void
            {
                currentRatio = 1.0 - (rawAssetsGroups[groupName].gRawAssets.length / numElements);
                if (rawAssetsGroups[groupName].gRawAssets.length)
                    timeoutID = setTimeout(processNext, 1);
                else
                    processXmls();
                
                if (onProgress != null) {
					for each (onProgressFunction in rawAssetsGroups[groupName].onProgessFunctions){
						onProgressFunction(currentRatio, groupName);
					}
				}
					
				//if (currentRatio == 1.0)
					//delete mRawAssetsGroups[groupName];
            }
            
            function processNext():void
            {
                if(rawAssetsGroups[groupName].gRawAssets.length > 0){
                    var assetInfo:Object = rawAssetsGroups[groupName].gRawAssets.pop();
                    loadRawAsset(assetInfo.name, assetInfo.asset, xmls, atlasXmls, progress, resume, groupName);
                }
                clearTimeout(timeoutID);
            }
            
            function processXmls():void
            {
                // xmls are processed seperately at the end, because the textures they reference
                // have to be available for other XMLs. Texture atlases are processed first:
                // that way, their textures can be referenced, too.
				
                /* Sort methods are very heavy
                xmls.sort(function(a:XML, b:XML):int { 
                    return a.localName() == "TextureAtlas" ? -1 : 1; 
                });
                */
				
                var name:String;
				var rootNode:String;
				var textureName:String;
				var atlasTexture:Texture
				var atlas:ExtendedTextureAtlas
				
                for each (var xml:XML in atlasXmls) {
					name = getName(xml.@imagePath.toString());
					rootNode = xml.localName();
					
					atlasTexture = getTexture(name);
					atlas = new ExtendedTextureAtlas(name, atlasTexture, xml)
					
					addTextureAtlas(name, atlas, groupName);
					removeTexture(name, false);
					System.disposeXML(xml);
				}
				
                for each (xml in xmls) {
					rootNode = xml.localName();
                    if (rootNode == "font")
                    {
                        name = getName(xml.pages.page.@file.toString());
                        
                        var fontTexture:Texture = getTexture(name);
                        TextField.registerBitmapFont(new BitmapFont(fontTexture, xml));
                        removeTexture(name, false);
						System.disposeXML(xml);
                    }
                    else
                        throw new Error("XML contents not recognized: " + rootNode);
                }
				
				atlasXmls = null;
				xmls = null;
            }
            
            function progress(ratio:Number):void
            {
                if (onProgress != null) {
					for each (onProgressFunction in rawAssetsGroups[groupName].onProgessFunctions) {
						onProgressFunction(currentRatio + (1.0 / numElements) * Math.min(1.0, ratio) * 0.99, groupName);
					}
				}
            }
        }
		
        private function loadRawAsset(name:String, rawAsset:Object, xmls:Vector.<XML>, atlasXmls:Vector.<XML>,
                                      onProgress:Function, onComplete:Function, groupName:String = ""):void
        {
            var extension:String = null;
            var onProgressFunction:Function;
			
            if (rawAsset is Class)
            {
                var asset:Object = new rawAsset();
                
                if (asset is Sound)
                {
                    addSound(name, asset as Sound);
                    onComplete();
                }
                else if (asset is Bitmap)
                {
                    addTexture(name, Texture.fromBitmap(asset as Bitmap, mUseMipMaps, false, mScaleFactor), groupName);
                    onComplete();
                }
                else if (asset is ByteArray)
                {
                    var bytes:ByteArray = asset as ByteArray;
                    var signature:String = String.fromCharCode(bytes[0], bytes[1], bytes[2]);
                    
                    if (signature == "ATF")
                    {
                        addTexture(name, Texture.fromAtfData(asset as ByteArray, mScaleFactor, 
                            mUseMipMaps, onComplete), groupName);
                    }
                    else
                    {
						var xmlTemp:XML = new XML(bytes);
						if (xmlTemp.localName() == "TextureAtlas")
							atlasXmls.push(xmlTemp);
						else
							xmls.push(xmlTemp);
                        onComplete();
                    }
                }
                else
                {
                    log("Ignoring unsupported asset type: " + getQualifiedClassName(asset));
                    onComplete();
                }
            }
            else if (rawAsset is String)
            {
                var url:String = rawAsset as String;
                extension = url.split(".").pop().toLowerCase();
                
                var urlLoader:URLLoader = new URLLoader();
                urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
                urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
                urlLoader.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
                urlLoader.addEventListener(Event.COMPLETE, onUrlLoaderComplete);
                urlLoader.load(new URLRequest(url));
            }
            
            function onIoError(event:IOErrorEvent):void
            {
                log("IO error: " + event.text);
                onComplete();
            }
            
            function onLoadProgress(event:ProgressEvent):void
            {
				onProgress(event.bytesLoaded / event.bytesTotal);
			}
            
            function onUrlLoaderComplete(event:Event):void
            {
                var urlLoader:URLLoader = event.target as URLLoader;
                var bytes:ByteArray = urlLoader.data as ByteArray;
                var sound:Sound;
                
                urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIoError);
                urlLoader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
                urlLoader.removeEventListener(Event.COMPLETE, onUrlLoaderComplete);
                
                switch (extension)
                {
                    case "atf":
                        addTexture(name, Texture.fromAtfData(bytes, mScaleFactor, mUseMipMaps, onComplete), groupName);
                        break;
                    case "fnt":
                    case "xml":
						var xmlTemp:XML = new XML(bytes);
						if (xmlTemp.localName() == "TextureAtlas")
							atlasXmls.push(xmlTemp);
						else
							xmls.push(xmlTemp);
                        onComplete();
                        break;
                    case "mp3":
                        sound = new Sound();
                        sound.loadCompressedDataFromByteArray(bytes, bytes.length);
                        addSound(name, sound);
                        onComplete();
                        break;
                    default:
                        var loaderContext:LoaderContext = new LoaderContext();
                        var loader:Loader = new Loader();
                        loaderContext.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
                        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
						loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
                        loader.loadBytes(urlLoader.data as ByteArray, loaderContext);
                        break;
                }
				urlLoader.close();
				urlLoader = null;
            }
            
            function onLoaderComplete(event:Event):void
            {
                event.target.removeEventListener(Event.COMPLETE, onLoaderComplete);
                var content:Object = event.target.content;
                
                if (content is Bitmap)
                    addTexture(name,
                        Texture.fromBitmap(content as Bitmap, mUseMipMaps, false, mScaleFactor), groupName);
                else
                    throw new Error("Unsupported asset type: " + getQualifiedClassName(content));
                
                onComplete();
            }
        }
        
        // helpers
		public function getTextureGroupName(textureName:String):String {
			if (!textureName)
				return "NULL";
				
			var atlas:ExtendedTextureAtlas;
			//var i:int;
			//var textureNamesLenght:int;
			//var atlasTextures:Vector.<String>;
			//var result:Vector.<String> = null;
			
			for each(atlas in mAtlases) {
				if (atlas.textureNames.indexOf(textureName) != -1) {
					//trace(atlas.name);
					return atlas.name;
				}
				else {
					//do nothing
				}
				
				/*
				atlasTextures = atlas.getNames(textureName, result, false);
				i = 0;
				if (atlasTextures.length == 1) {
					return atlas.name;
				}
				else if(atlasTextures.length > 1){
					while(i < atlasTextures.length){
						if (atlasTextures[i] == textureName)
							return atlas.name;
						i++ 
					}
				}*/
			}
			
			//trace("can´t find atlas for this texture name");
			return "NULL";
		}
		
        private function getName(rawAsset:Object):String
        {
            var matches:Array;
            var name:String;
            
            if (rawAsset is String || rawAsset is FileReference)
            {
                name = rawAsset is String ? rawAsset as String : (rawAsset as FileReference).name;
                name = name.replace(/%20/g, " "); // URLs use '%20' for spaces
                matches = /(.*[\\\/])?([\w\s\-]+)(\.[\w]{1,4})?/.exec(name);
                
                if (matches && matches.length == 4) return matches[2];
                else throw new ArgumentError("Could not extract name from String '" + rawAsset + "'");
            }
            else
            {
                name = getQualifiedClassName(rawAsset);
                throw new ArgumentError("Cannot extract names for objects of type '" + name + "'");
            }
        }
        
        private function log(message:String):void
        {
            if (verbose) trace("[AssetManager]", message);
        }
        
        // properties
        
        /** When activated, the class will trace information about added/enqueued assets. */
        public function get verbose():Boolean { return mVerbose; }
        public function set verbose(value:Boolean):void { mVerbose = value; trace("set verbose", mVerbose); }
        
        /** For bitmap textures, this flag indicates if mip maps should be generated when they 
         *  are loaded; for ATF textures, it indicates if mip maps are valid and should be
         *  used. */
        public function get useMipMaps():Boolean { return mUseMipMaps; }
        public function set useMipMaps(value:Boolean):void { mUseMipMaps = value; }
        
        /** Textures that are created from Bitmaps or ATF files will have the scale factor 
         *  assigned here. */
        public function get scaleFactor():Number { return mScaleFactor; }
        public function set scaleFactor(value:Number):void { mScaleFactor = value; }
    }
}