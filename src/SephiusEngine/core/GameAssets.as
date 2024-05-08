package SephiusEngine.core 
{
	import SephiusEngine.assetManagers.ExtendedAssetManager;
	import SephiusEngine.assetManagers.TextureManager;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.displayObjects.configs.TexturesCache;
	import SephiusEngine.sounds.GameSoundGroup;

	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.system.System;

	import org.osflash.signals.Signal;

	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;
	import SephiusEngine.utils.AppInfo;
	/**
	 * Controls the assets managers game uses (AtlasManager, Sounds). It works like a warps, preventing game classes to reference methods and properties from actual asset managers
	 * @author Fernando Rabello
	 */
	public class GameAssets {
		/** ---------------------------------------------- */
		/** --------------- Game Fonts ------------------- */
		/** ---------------------------------------------- */
		[Embed(source="../../../embed/fontsConfigs/SansicoDarkWhite.fnt", mimeType="application/octet-stream")]
		private static const SansicoDarkWhiteFNT:Class;
		
		[Embed(source="../../../embed/fontsConfigs/SansicoDarkStone.fnt", mimeType="application/octet-stream")]
		private static const SansicoDarkStoneFNT:Class;
		
		[Embed(source="../../../embed/fontsConfigs/SansicoLightBlack.fnt", mimeType="application/octet-stream")]
		private static const SansicoLightBlackFNT:Class;
		
		[Embed(source="../../../embed/fontsConfigs/SansicoLightStone.fnt", mimeType="application/octet-stream")]
		private static const SansicoLightStoneFNT:Class;
		
		[Embed(source="../../../embed/fontsConfigs/ChristianaBlack.fnt", mimeType="application/octet-stream")]
		private static const ChristianaBlackFNT:Class;
		
		[Embed(source="../../../embed/fontsConfigs/ChristianaWhite.fnt", mimeType="application/octet-stream")]
		private static const ChristianaWhiteFNT:Class;
		
		[Embed(source="../../../embed/fonts/Cinzel-Regular.ttf", embedAsCFF="false", fontFamily="Cinzel")]
		private static const CinzelNT:Class;
		
		[Embed(source="../../../embed/fonts/Cinzel-Bold.ttf", embedAsCFF="false", fontFamily="Cinzel", fontWeight="bold")]
		private static const CinzelBoldFNT:Class;
		
		[Embed(source="../../../embed/fonts/Philosopher-Regular.ttf", embedAsCFF="false", fontFamily="Philosopher")]
		private static const PhilosopherFNT:Class;
		
		[Embed(source="../../../embed/fonts/Philosopher-Bold.ttf", embedAsCFF="false", fontFamily="Philosopher", fontWeight="bold")]
		private static const PhilosopherBoldFNT:Class;
		
		public var textures:TextureManager;
		public var sounds:ExtendedAssetManager;
		
		/** Define the texture pack game will load. low / medium / high.
		 * For PC, Ipad3 and 4, GalaxyS3 or 4 and similars, set "high"
		 * For iPad2, Iphones, set "medium"
		 * For Low spec Android mobiles, set "low" */
		static public var texturePack:String = "high";

		/** Define the URL for the textures to make easier to change the url trought the entire code. */
		static public var texturesPath:File = File.applicationDirectory.resolvePath("assets").resolvePath("textures").resolvePath(texturePack);
		static public var soundURL:File = File.applicationDirectory.resolvePath("assets").resolvePath("audio");
		
		private function setTextureReady():void { texturesReady = true ;  onTexturesReady.dispatch()}
		private function setSoundsReady():void { soundsReady = true ;  onSoundsReady.dispatch() }
		
		public var texturesReady:Boolean;
		public var soundsReady:Boolean;
		public var onTexturesReady:Signal = new Signal();
		public var onSoundsReady:Signal = new Signal();
		
		public function GameAssets() {
			var scalleFactor:Number = (texturePack == "high" ? 1 : texturePack == "medium" ? 0.6 : texturePack == "low" ? 0.41 : 1);
			
			textures = new TextureManager(scalleFactor, true);
			sounds = new ExtendedAssetManager (scalleFactor, true);
			
			init();
		}
		
		public function init():void {
			textures.processConfigs(texturesPath, setTextureReady);
			
			//Loading Sound Assets;
			sounds.enqueueAsGroup("Sounds", soundURL);
			sounds.loadQueueGroup(function(ratio:Number, groupName:String):void {
				if (ratio == 1.0) {
					addSoundsToSM("FX"); 
					addSoundsToSM("BGFX"); 
					addSoundsToSM("UI"); 
					addSoundsToSM("BGM");
					addSoundsToSM("STORYTELLER");
					addSoundsToSM("ST");
					setSoundsReady();
				}
			}, "Sounds");
		}
		
		/** Add a multiple sounds to sound manager via prefix */
		public function addSoundsToSM(prefix:String):void{
			//GameEngine.instance.sound.addGroup(new BGFXGroup());
			var soundNames:Vector.<String> = sounds.getSoundNames(prefix);
			var name:String;
			
			// define sound group according to prefix
			var soundGroup:String;
			switch(prefix){
				case "BGM" : soundGroup = GameSoundGroup.BGM; break;
				case "BGFX" : soundGroup = GameSoundGroup.BGFX; break;
				case "FX" : soundGroup = GameSoundGroup.FX; break;
				case "UI" : soundGroup = GameSoundGroup.UI; break;
				case "ST" : soundGroup = GameSoundGroup.STORYTELLER; break;
				case "STORYTELLER" : soundGroup = GameSoundGroup.STORYTELLER; break;
			} 
			
			//define if sounds will be permanent or not
			var perm:Boolean = false;
			//switch(soundGroup){
				//case SephiusEngineSoundGroup.BGM : perm = false; break;
				//case SephiusEngineSoundGroup.BGFX : perm = false; break;
			//}
			
			//add sound objects to sound manager
			for each(name in soundNames)
				GameEngine.instance.sound.addSound(name, {sound:getSound(name),permanent:perm, group:soundGroup } );
			
		}
		
		/** Gives the number of checking for a certain pack*/
		public function getPackUsage(objectName:String):int{
			return textures.packUsage[objectName];
		}
		
		/** Increase by 1 usage count for a particular pack. If usage was 0 before pack was not loaded and will be loaded now .
		 * Texture Manager will call the callback function when pack finish to load of will call imediattly if pack is already loaded*/
		public function checkInTexturePack(objectName:String, callback:Function, checker:String):void {
			textures.checkIn(objectName, callback, checker);
		}
		
		/** Reduce by 1 usage count for a particular pack. If usage reach 0 pack will be disposed */
		public function checkOutTexturePack(objectName:String, checker:String):void {
			textures.checkOut(objectName, checker);
		}
		
		/** Return the texture atlas with the name given. Thow error, only in debug build, if texture don't exist, and a debug tex in release build instead. */
		public function getAtlasTexture(name:String):Texture{
			if(textures.subTexByFullName[name])
				return textures.atlasTextures[name].texture;
			else{
				if(AppInfo.isDebugBuild){
					throw Error("Texture Atlas name don't exist");
				}
				else
					return textures.subTexByFullName["Debug_box"].textures[0];
			}
		}

		/** Return the texture with the name given. Thow error, only in debug build, if texture don't exist, and a debug tex in release build instead. */
        public function getTexture(name:String):Texture {
			if(textures.subTexByFullName[name])
				return textures.subTexByFullName[name].textures[0];
			else{
				if(AppInfo.isDebugBuild){
					throw Error("Texture name: " + name + " don't exist");
				}
				else
					return textures.subTexByFullName["Debug_box"].textures[0];
			}
		}
		
		/** Retrieves subtextures by name. Returns <code>null</code> if it is not found. */
        public function getTextures(objectName:String, subName:String):Vector.<Texture> {
			return textures.getTextures(objectName, subName);
		}
		
		/** Pack a TextureCache based on object name and sub names */
		public function getTextureCache(objectName:String, subNames:String ):TexturesCache {
			return textures.getTextureCache(objectName, subNames);
		}
		
		/** Pack a group of textures caches in a vector based on object name and sub names */
		public function getTextureCaches(objectName:String, subNames:Array = null):Vector.<TexturesCache> {
			return textures.getTextureCaches(objectName, subNames);
		}
		
		/** Retrieves a subtexture names by object name. Returns <code>null</code> if it is not found. */
        public function getSubTexturesNames(objectName:String):Vector.<String> {
			return textures.subTexturesNames[objectName];
		}
		
		/** Retrive the native texture name (atlas texture if is a subtexture) by a object name, subname and index (in case subname is related with a animation) */
		public function getTextureAtlasName(objectName:String, subName:String, index:int=0):String {
			if(textures.subTextures[objectName] && textures.subTextures[objectName][subName])
				return (textures.subTextures[objectName][subName] as TexturesCache).configs[index].baseTextureConfig.name;
			else{
				if(AppInfo.isDebugBuild){
					throw Error("ObjectName or SubName is invalid");
				}
				else
					return "Invalid";
			}
		}
		
		/** Return the size of the texture this object use usefull to avoid getBound() witch is expensive*/
		public function getTextureSize(objectName:String):Rectangle {
			return textures.getTextureSize(objectName);
		}
		
        /** Returns a sound with a certain name. */
        public function getSound(name:String):Sound {
			return sounds.getSound(name);
		}
		
        /** Returns all sound names that start with a certain string, sorted alphabetically. */
        public function getSoundNames(prefix:String = ""):Vector.<String> {
			return sounds.getSoundNames(prefix);
		}
		
		/** * Return the number of objects that is using a pack of textures.
		 * This is not automatic. You must checking and checkout texture each time you assign a texture to a object.
		 * If this function returns -1, its means that this group was not exist and was not send to load yet.
		 * If it´s returns 0, its means that this group exist but is in loading progress.
		 * If returns above 0, its means the group exist and assets was already loaded. */
		public function textureGroupUsage(groupName:String):int {
			return textures.packUsage[groupName];
		}
		
		/** Create fonts game use. */
		public function createFonts():void {
			var xml:XML;
			
			xml = XML(new SansicoLightStoneFNT());
			TextField.registerBitmapFont(new BitmapFont(getTexture("Fonts_SansicoLightStone"), xml), "SansicoLightStone");
			System.disposeXML(xml);
			
			xml = XML(new SansicoLightBlackFNT());
			TextField.registerBitmapFont(new BitmapFont(getTexture("Fonts_SansicoLightBlack"), xml), "SansicoLightBlack");
			System.disposeXML(xml);
			
			xml = XML(new SansicoDarkStoneFNT());
			TextField.registerBitmapFont(new BitmapFont(getTexture("Fonts_SansicoDarkStone"), xml), "SansicoDarkStone");
			System.disposeXML(xml);
			
			xml = XML(new SansicoDarkWhiteFNT());           
			TextField.registerBitmapFont(new BitmapFont(getTexture("Fonts_SansicoDarkWhite"), xml), "SansicoDarkWhite");
			System.disposeXML(xml);
			
			xml = XML(new ChristianaBlackFNT());
			TextField.registerBitmapFont(new BitmapFont(getTexture("Fonts_ChristianaBlack"), xml), "ChristianaBlack");
			System.disposeXML(xml);
			
			xml = XML(new ChristianaWhiteFNT());
			TextField.registerBitmapFont(new BitmapFont(getTexture("Fonts_ChristianaWhite"), xml), "ChristianaWhite");	
			System.disposeXML(xml);
			
			xml = null;
		}
	}
}