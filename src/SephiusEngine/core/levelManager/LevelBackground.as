package SephiusEngine.core.levelManager 
{
	import SephiusEngine.core.levelManager.ILevelElement;
	import SephiusEngine.core.levelManager.LevelRegion;
	import adobe.utils.CustomActions;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.displayObjects.gameArtContainers.AnimationContainer;
	import SephiusEngine.levelObjects.GameObject;
	import SephiusEngine.levelObjects.GameSprite;
	import flash.utils.Dictionary;
	import nape.geom.Vec2;
	import org.osflash.signals.Signal;
	import starling.display.DisplayObject;
	/**
	 * Information about a specified background in the game. Each area can use diferent backgrounds depending on witch site the area is.
	 * Static constants with default information about some backgrounds
	 * @author Fernando Rabello
	 */
	public class LevelBackground implements ILevelElement {
		public var name:String;
		
		/** Region in the world where this area belongs. The Pillars, Desert of Sighs, Noprotone, Halugarge and etc */
		public function get region():LevelRegion { return _region; }
		private var _region:LevelRegion;
		
		/** Site this BG is related to */
		public function get site():LevelSite { return _site; }
		private var _site:LevelSite;
		
		/** Area Number related with a region acording with level design*/
		public function get globalId():uint {return _globalId;}
		public function set globalId(value:uint):void {
			_globalId = value;
		}
		private var _globalId:uint;
		
		/** Array of game objects witch are not sprites and effects this area has */
		public function get otherObjects():Vector.<GameObject> {return _otherObjects;}
		private var _otherObjects:Vector.<GameObject> = new Vector.<GameObject>();
		
		/** Array of game objects this area has */
		public function get objects():Vector.<GameObject> {return _objects;}
		private var _objects:Vector.<GameObject> = new Vector.<GameObject>();
		
		/** Store all Barrilers related with this particular área */
		public function get sprites():Vector.<GameSprite> { return _sprites; }
		private var _sprites:Vector.<GameSprite> = new Vector.<GameSprite>();
		
		/** Store all effects (auroras, mists, rain, etc) samples associated with this particular area.
		 * EffectArts are not Game Objects, so you should not try to add lights via "addObject() Method."*/
		public function get effects():Vector.<AnimationContainer> { return _effects; }
		private var _effects:Vector.<AnimationContainer> = new Vector.<AnimationContainer>();
		
		/** Store all lists of specific objects */
		public function get objectLists():Array {return _objectLists;}
		private var _objectLists:Array = [];
		
		/** Store texture packs a level uses. When area is added Level Manager need to cheking those packs and loads correspondent textures */
		public function get texturePacksUsed():Vector.<String> { 
			var packsUsed:Vector.<String> = new Vector.<String>();
			for each (var packName:String in _texturePacksUsed){
				packsUsed.push(packName);
			}
			return packsUsed;
		}
		private var _texturePacksUsed:Vector.<String> = new Vector.<String>();
		
		/** Store Statistics information about a area. How many sprites or collision vertex it has and etc.  */
		public function get statistics():Object {return _statistics;}
		public function set statistics(value:Object):void {
			_statistics = value;
		}
		private var _statistics:Object = new Object();
		
		/** Store all arts samples associated with this particular area. Only stored when Level Maker process region for export..  */
		public function get spritesInfo():Vector.<Object> {return _spritesInfo;}
		public function set spritesInfo(value:Vector.<Object>):void {
			_spritesInfo = value;
		}
		private var _spritesInfo:Vector.<Object> = new Vector.<Object>();
		
		/** Store the position of the hole level element. Level element objects has its position related to world, not to the level element.
		 * You can use this information to retreive the relative position of the objects to its level element */
		public function get offset():Vec2 { return _offset; }
		public function set offset(value:Vec2):void {
			_offset = value;
		}
		private var _offset:Vec2 = new Vec2();
		
		/** If this background is added to state */
		public var added:Boolean = false;
		
		/** Tell if all textures was fully loaded. */
		public var texturesLoaded:Boolean;
		
		/** Dispach a signal when all textures gets fully loaded. */
		public var onTexturesLoaded:Signal = new Signal(LevelBackground);
		
		public function LevelBackground(site:LevelSite) {
			this.name = name;
			this._site = site;
			
			objectLists.push(_effects);
			objectLists.push(_sprites);
			objectLists.push(_otherObjects);
		}
		
		private var texturePack:String;
		
		/** Add a game object to this background. 
		 * Backgrounds divides objects by some groups.
		 * Like Lights, rewards, collisions, effects, pools, damagers, barriers and etc.
		 * You can iterate for each type of object acessing the correspondent list 
		 * or iterate trhough all objects by acessing "objects" property. */
		public function addObject(object:GameObject):void{
			if (object as AnimationContainer){
				if (_effects.indexOf(object as AnimationContainer) == -1)
					_effects.push(object as AnimationContainer);
			}
			else if (object as GameSprite){
				if (_sprites.indexOf(object as GameSprite) == -1)
					_sprites.push(object as GameSprite);
			}
			
			else{
				if (_otherObjects.indexOf(object) == -1)
					_otherObjects.push(object);
			}
			
			if (_objects.indexOf(object) == -1)
				_objects.push(object);
			
			if (added && !object.addedToState)
				GameEngine.instance.state.add(object);
		}
		
		public function addTexturePack(packName:String):void{
			if(_texturePacksUsed.indexOf(packName) == -1)
				_texturePacksUsed.push(packName);
		}
		
		/** Add a list of objects to this background.
		 * Area divide objects by some groups.
		 * Like Lights, rewards, collisions, effects, pools, damagers, barriers and etc.
		 * You can iterate for each type of object acessing the correspondent list 
		 * or iterate trhough all objects by acessing "objects" property. */
		public function addObjects(objects:Vector.<GameObject>):void{
			var iLength:int = objects.length;
			var i:int;
			for (i = 0; i < iLength; i++) {
				addObject(objects[i]);
			}
		}
		
		/** Remove a game object from this area */
		public function removeObject(object:GameObject):void{
			if (object as GameSprite){
				if (_sprites.indexOf(object as GameSprite) != -1)
					_sprites.splice(_sprites.indexOf(object as GameSprite), 1);
			}
			if (_objects.indexOf(object) != -1)
				_objects.splice(_objects.indexOf(object), 1);
			
			if (!added && object.addedToState)
				object.remove = true;
				trace("[LEVELBACKGROUND] Object " + object.name + " removed");			
		}
		
		public function addToState():void {
			var iLength:int = _sprites.length;
			var i:int;
			
			for (i = 0; i < iLength; i++) {
				GameEngine.instance.state.add(_sprites[i] as GameObject);
			}
			
			iLength = _otherObjects.length;
			
			for (i = 0; i < iLength; i++) {
				GameEngine.instance.state.add(_otherObjects[i] as GameObject);
			}
			
			added = true;
			trace("[LEVELBACKGROUND] BACKGROUND " + site.name + " Added");
			
			if(texturePacksUsed.length > 0){
				for each (texturePack in texturePacksUsed) {
					texturePacksMissing.push(texturePack);
					GameEngine.assets.checkInTexturePack(texturePack, onTextureLoaded, "LEVEL_BG" + _globalId);
				}
			}
			else{
				texturesLoaded = true;
				onTexturesLoaded.dispatch(this);
			}			
		}
		
		public function removeFromState():void {
			var iLength:int = _objects.length;
			var i:int;
			for (i = 0; i < iLength; i++) {
				_objects[i].remove = true;
			}
			
			added = false;
			
			for each (texturePack in texturePacksUsed) {
				GameEngine.assets.checkOutTexturePack(texturePack, "LEVEL_BG" + _globalId);
				if(texturePacksMissing.indexOf(texturePack) > -1)
					texturePacksMissing.splice(texturePacksMissing.indexOf(texturePack), 1);
				
			}
			
			onTexturesLoaded.removeAll();
		}
		
		private var texturePacksMissing:Vector.<String> = new Vector.<String>();
		/** Verify if all textures from this area was loaded */
		protected function onTextureLoaded(packName:String):void {
			//Remove from list, packs that was aready loaded. If all get removed continue
			if(texturePacksMissing.indexOf(packName) > -1){
				texturePacksMissing.splice(texturePacksMissing.indexOf(packName), 1);
				trace("[LEVELBACKGROUND] Texture pack " + packName + " for BG " + _globalId + " loaded. Missing:" + texturePacksMissing);
			}
			//else
				//throw Error("Texture Pack for BG: " + _globalId + " is not misssing. Or BG does not use this texture, or it was already removed from missing list");
			
			if (texturePacksMissing.length > 0)
				return;
			
			texturesLoaded = true;
			trace("[LEVELBACKGROUND] BACKGROUND " + _globalId + " LOADED");
			
			if (added)
				onTexturesLoaded.dispatch(this);
			if (!added)	
				trace("[LEVELBACKGROUND] BACKGROUND Not Added. Will no Dispatch");
				
			
		}
		
		public function destroy():void {
			if (added)
				removeFromState();
			
			objects.length = 0;
			var cobjects:GameObject;
			for each (cobjects in objects){
				cobjects.destroy();
			}			
			//**TODO destoy objects and dispose all resources**//
			
			var c_objects:GameObject;
			for each (c_objects in _objects){
				c_objects.destroy();
			}
			
			var c_objectLists:*;
			for each (c_objectLists in _objectLists){
				c_objectLists.length = 0;
			}
			
			_objectLists.length = 0;
			
			_texturePacksUsed.length = 0;
			_statistics = null;
			
			var c_spritesInfo:GameObject;
			for each (c_spritesInfo in _spritesInfo){
				c_spritesInfo.destroy();
			}			
			onTexturesLoaded.removeAll();
			
		}
		
	}

}