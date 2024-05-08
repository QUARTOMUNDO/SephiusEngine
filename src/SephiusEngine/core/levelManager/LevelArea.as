package SephiusEngine.core.levelManager 
{
	import SephiusEngine.core.GameEngine;
	import tLotDClassic.attributes.AttributesConstants;
	import SephiusEngine.core.levelManager.IComplexLevelElement;
	import SephiusEngine.core.levelManager.ILevelElement;
	import SephiusEngine.core.levelManager.LevelRegion;
	import SephiusEngine.core.levelManager.LevelSite;
	import SephiusEngine.displayObjects.gameArtContainers.AnimationContainer;
	import SephiusEngine.displayObjects.LightSprite;
	import SephiusEngine.levelObjects.GameObject;
	import SephiusEngine.core.levelManager.AreaBounds;
	import SephiusEngine.levelObjects.GameSprite;
	import tLotDClassic.gameObjects.barriers.Barriers;
	import tLotDClassic.gameObjects.characters.Spawner;
	import SephiusEngine.levelObjects.interfaces.IDamagerObject;
	import tLotDClassic.gameObjects.activators.Pyra;
	import tLotDClassic.gameObjects.pools.Pool;
	import tLotDClassic.gameObjects.rewards.Reward;
	import SephiusEngine.levelObjects.specialObjects.LevelCollision;
	import flash.utils.Dictionary;
	import nape.geom.GeomPoly;
	import nape.geom.Vec2;
	import nape.geom.Vec2List;
	import org.osflash.signals.Signal;
	import starling.display.DisplayObject;
	/**
	 * Information about a specified area in the game.
	 * Static constants with default information about some areas
	 * @author Fernando Rabello
	 */
	public class LevelArea implements ILevelElement, IComplexLevelElement {
		/** Area Number (related with a site). Used for interfaces and ingame maps*/
		public function get localId():uint { return _localId; }
		private var _localId:uint;
		
		/** Site name where this area is. Caves, Deeps, Surface, High Pass and etc */
		public function get site():LevelSite { return _site; }
		private var _site:LevelSite;
		
		/** Region in the world where this area belongs. The Pillars, Desert of Sighs, Noprotone, Halugarge and etc */
		public function get region():LevelRegion { return _region; }
		private var _region:LevelRegion;
		
		/** Store all objects this area has */
		public function get objects():Vector.<GameObject> { return _objects; }
		private var _objects:Vector.<GameObject> = new Vector.<GameObject>();
		
		/** Store all Barrilers related with this particular área */
		public function get sprites():Vector.<GameSprite> { return _sprites; }
		private var _sprites:Vector.<GameSprite> = new Vector.<GameSprite>();
		
		/** Store all effects (auroras, mists, rain, etc) samples associated with this particular area.
		 * EffectArts are not Game Objects, so you should not try to add lights via "addObject() Method."*/
		public function get effects():Vector.<AnimationContainer> { return _effects; }
		private var _effects:Vector.<AnimationContainer> = new Vector.<AnimationContainer>();
		
		/** Array of other objects this area has */
		public function get otherObjects():Vector.<GameObject> { return _otherObjects; }
		private var _otherObjects:Vector.<GameObject> = new Vector.<GameObject>();
		
		/** Store all Level collisions associated with this particular area.*/
		public function get collisions():Vector.<LevelCollision> { return _collisions; }
		private var _collisions:Vector.<LevelCollision> = new Vector.<LevelCollision>();
		
		/** Store all lights samples associated with this particular area.
		 * LightSprites are not Game Objects, so you should not try to add lights via "addObject() Method."*/
		public function get lights():Vector.<LightSprite> { return _lights; }
		private var _lights:Vector.<LightSprite> = new Vector.<LightSprite>();
		
		/** Store all effects (auroras, mists, rain, etc) samples associated with this particular area.*/
		public function get rewards():Vector.<Reward> { return _rewards; }
		private var _rewards:Vector.<Reward> = new Vector.<Reward>();
		
		/** Store all damagers (spikes mostly) samples associated with this particular area.*/
		public function get damagers():Vector.<IDamagerObject> { return _damagers; }
		private var _damagers:Vector.<IDamagerObject> = new Vector.<IDamagerObject>();
		
		/** Store all pools samples associated with this particular area.*/
		public function get pools():Vector.<Pool> { return _pools; }
		private var _pools:Vector.<Pool> = new Vector.<Pool>();
		
		/** Store all Spawners associated with this particular area.*/
		public function get spawners():Vector.<Spawner> { return _spawners; }
		private var _spawners:Vector.<Spawner> = new Vector.<Spawner>();
		
		/** Store all Barrilers related with this particular área */
		public function get barriers():Vector.<Barriers> { return _barriers; }
		private var _barriers:Vector.<Barriers> = new Vector.<Barriers>();
		
		/** Store all Pyra related with this particular área */
		public function get pyras():Vector.<Pyra> { return _pyras; }
		private var _pyras:Vector.<Pyra> = new  Vector.<Pyra>();
		
		/** Store all lists of specific objects */
		public function get objectLists():Array { return _objectLists; }
		private var _objectLists:Array = [];
		
		/** Witch areas are nearby this area. Used to determine witch areas Level Manager need to verify if should be added to state. */
		public var adjacentAreas:Vector.<LevelArea> = new Vector.<LevelArea>();
		
		/** Area Number related with a region acording with level design*/
		public function get globalId():uint {return _globalId;}
		public function set globalId(value:uint):void {
			_globalId = value;
		}
		private var _globalId:uint;
		
		/** Store texture packs a level uses. When area is added Level Manager need to cheking those packs and loads correspondent textures */
		public function get texturePacksUsed():Vector.<String> { 
			var packsUsed:Vector.<String> = new Vector.<String>();
			for each (var packName:String in _texturePacksUsed){
				packsUsed.push(packName);
			}
			return packsUsed;
		}
		private var _texturePacksUsed:Vector.<String> = new Vector.<String>();
		
		public function addTexturePack(packName:String):void{
			if(_texturePacksUsed.indexOf(packName) == -1)
				_texturePacksUsed.push(packName);
		}	
		
		/** Tell if all textures was fully loaded. */
		public function get texturesLoaded():Boolean { return _texturesLoaded;}
		public function set texturesLoaded(value:Boolean):void {
			if(value)
				trace("[LEVELAREA] Area Textures" + _globalId + " SET TO LOADED");
			else
				trace("[LEVELAREA] Area Textures" + _globalId + " SET TO NOT LOADED");
			_texturesLoaded = value;
			
		}
		private var _texturesLoaded:Boolean;
		
		/** Dispach a signal when all textures gets fully loaded. */
		public var onTexturesLoaded:Signal = new Signal(LevelArea);
		
		/** Area bounds defined manually in level editor. Bound determine when area should be added to state. 
		 * LevelManager verify if player is inside a area bound, and if he is, this area will be added if not, this area will be removed from state. */
		public function get bounds():AreaBounds { return _bounds; }
		private var _bounds:AreaBounds;
		
		/** Store the position of the hole level element. Level element objects has its position related to world, not to the level element.
		 * You can use this information to retreive the relative position of the objects to its level element */
		public function get offset():Vec2 { return _offset; }
		public function set offset(value:Vec2):void {
			_offset = value;
		}
		private var _offset:Vec2 = new Vec2();
		
		/** If this area is added to state */
		public var added:Boolean = false;
		
		/** If this area was perceived by a presence object. Its mean it should be added to state */
		public var perceived:Boolean = false;
		
		/** -----------------------------------------------*/
		/** -------------- for export ---------------------*/
		/** -----------------------------------------------*/
		/** Store all collision Shapes associated with this particular area. Only stored when Level Maker process region for export..  */
		public var rawCollisionInfo:Vector.<Object> = new Vector.<Object>();
		/** Store all processed Shapes associated with this particular area. Only stored when Level Maker process region for export..  */
		public var processedCollisionInfo:Vector.<Object> = new Vector.<Object>();
		/** Store all collision Shapes associated with this particular area. Only stored when Level Maker process region for export..  */
		public var oneWaycollisionInfo:Vector.<Object> = new Vector.<Object>();
		
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
		
		public function LevelArea(globalId:uint, site:LevelSite, region:LevelRegion){
			this._globalId = globalId;
			this._site = site;
			this._region = region;
			
			objectLists.push(_lights);
			objectLists.push(_effects);
			objectLists.push(_rewards);
			objectLists.push(_damagers);
			objectLists.push(_pools);
			objectLists.push(_collisions);
			objectLists.push(_spawners);
			objectLists.push(_barriers);
			objectLists.push(_sprites);
			objectLists.push(_pyras);
			objectLists.push(_otherObjects);
			objectLists.push(_objects);
			
			this.site.areas.push(this);
			this._localId = site.areas.length - 1;
			
		}
		
		/** Add a game object to this area. 
		 * Area divide objects by some groups.
		 * Like Lights, rewards, collisions, effects, pools, damagers, barriers and etc.
		 * You can iterate for each type of object acessing the correspondent list 
		 * or iterate trhough all objects by acessing "objects" property. */
		public function addObject(object:GameObject):void{
			if (object as GameSprite){
				if (_sprites.indexOf(object as GameSprite) == -1)
					_sprites.push(object as GameSprite);
			}
			else if (object as LevelCollision){
				if (_collisions.indexOf(object as LevelCollision) == -1)
					_collisions.push(object as LevelCollision);
			}
			else if (object as Reward){
				if (_rewards.indexOf(object as Reward) == -1){
					_rewards.push(object as Reward);
					
					if((object as Reward).areaBounded)
						(object as Reward).areaBounded.removeObject(object);
					
					(object as Reward).areaBounded = this;
				}
			}
			else if (object as Pool){
				if (_pools.indexOf(object as Pool) == -1)
					_pools.push(object as Pool);
			}
			else if (object as IDamagerObject){
				if (_damagers.indexOf(object as IDamagerObject) == -1)
					_damagers.push(object as IDamagerObject);
			}
			else if (object as Spawner){
				if (_spawners.indexOf(object as Spawner) == -1)
					_spawners.push(object as Spawner);
			}
			else if (object as Barriers){
				if (_barriers.indexOf(object as Barriers) == -1)
					_barriers.push(object as Barriers);
			}
			else if (object as Pyra){
				if (_pyras.indexOf(object as Pyra) == -1)
					_pyras.push(object as Pyra);
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
		
		/** Add a list of objects to this area.
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
			else if (object as LevelCollision){
				if (_collisions.indexOf(object as LevelCollision) != -1)
					_collisions.splice(_collisions.indexOf(object as LevelCollision), 1);
			}
			else if (object as Reward){
				if (_rewards.indexOf(object as Reward) != -1){
					(object as Reward).areaBounded = null;
					_rewards.splice(_rewards.indexOf(object as Reward), 1);
				}
			}
			else if (object as IDamagerObject){
				if (_damagers.indexOf(object as IDamagerObject) != -1)
					_damagers.splice(_damagers.indexOf(object as IDamagerObject), 1);
			}
			else if (object as Pool){
				if (_pools.indexOf(object as Pool) != -1)
					_pools.splice(_pools.indexOf(object as Pool), 1);
			}
			else if (object as Spawner){
				if (_spawners.indexOf(object as Spawner) != -1)
					_spawners.splice(_spawners.indexOf(object as Spawner), 1);
			}
			else if (object as Barriers){
				if (_barriers.indexOf(object as Barriers) != -1)
					_barriers.splice(_barriers.indexOf(object as Barriers), 1);
			}
			else if (object as Pyra){
				if (_pyras.indexOf(object as Pyra) != -1)
					_pyras.splice(_pyras.indexOf(object as Pyra), 1);
			}
			
			if (_objects.indexOf(object) != -1)
				_objects.splice(_objects.indexOf(object), 1);
			
			if (!added && object.addedToState)
				object.remove = true;
		}
		
		/** Add object to state if area is already added */
		public function addObjectToState(object:GameObject):void {
			if(added && object.addedToState)
				GameEngine.instance.state.add(object);
		}
		
		/** Add this area to the state. This mean add all its objects as well */
		public function addToState():void {
			var i:int;
			var iLength:int = _pools.length;
			
			for (i = 0; i < iLength; i++) {
				GameEngine.instance.state.add(_pools[i] as GameObject);
			}
			
			iLength = _damagers.length;
			
			for (i = 0; i < iLength; i++) {
				GameEngine.instance.state.add(_damagers[i] as GameObject);
			}
			
			iLength = _sprites.length;
			
			for (i = 0; i < iLength; i++) {
				GameEngine.instance.state.add(_sprites[i]);
			}
			
			iLength = _rewards.length;
			
			for (i = 0; i < iLength; i++) {
				if(!_rewards[i].collected)
					GameEngine.instance.state.add(_rewards[i] as GameObject);
			}
			
			iLength = _collisions.length;
			
			for (i = 0; i < iLength; i++) {
				GameEngine.instance.state.add(_collisions[i] as GameObject);
			}
			
			iLength = _spawners.length;
			
			for (i = 0; i < iLength; i++) {
				GameEngine.instance.state.add(_spawners[i] as GameObject);
			}
			
			iLength = _barriers.length;
			
			for (i = 0; i < iLength; i++) {
				GameEngine.instance.state.add(_barriers[i] as GameObject);
			}
			
			iLength = _pyras.length;
			
			for (i = 0; i < iLength; i++) {
				GameEngine.instance.state.add(_pyras[i] as GameObject);
			}
			
			iLength = _otherObjects.length;
			
			for (i = 0; i < iLength; i++) {
				GameEngine.instance.state.add(_otherObjects[i] as GameObject);
			}
			
			added = true;
			
			if (texturePacksUsed.length > 0){
				for each (texturePack in texturePacksUsed) {
					texturePacksMissing.push(texturePack);
					trace("[LEVELAREA] textures ARE NOT loaded, STARTING TO LOAD")
					GameEngine.assets.checkInTexturePack(texturePack, onTextureLoaded, "LEVEL_AREA" + _globalId);
				}
			}
			else{
				trace("[LEVELAREA] textures ALREADY loaded, MOVE ON")
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
				GameEngine.assets.checkOutTexturePack(texturePack, "LEVEL_AREA" + _globalId);
				
				if (GameEngine.assets.textures.packUsage[texturePack] == 0)
					texturesLoaded = false;
				
				if(texturePacksMissing.indexOf(texturePack) > -1)
					texturePacksMissing.splice(texturePacksMissing.indexOf(texturePack), 1)
			}
			texturesLoaded = false;
			onTexturesLoaded.removeAll();
		}
		
		private var texturePack:String;
		private var texturePacksMissing:Vector.<String> = new Vector.<String>();
		/** Verify if all textures from this area was loaded */
		protected function onTextureLoaded(packName:String):void {
			if (!added)	
				return;
			
			//Remove from list, packs that was aready loaded. If all get removed continue
			if(texturePacksMissing.indexOf(packName) > -1){
				texturePacksMissing.splice(texturePacksMissing.indexOf(packName), 1)
				//trace("[LEVELAREA] Texture pack " + packName + " for Area " + _globalId + " loaded. Missing:" + texturePacksMissing);
			}
			else
				throw Error("[LEVELAREA] exture Pack for Area: " + _globalId + " is not misssing. Or Area does not use this texture, or it was already removed from missing list");
			
			if (texturePacksMissing.length > 0)
				return;
			
			texturesLoaded = true;
			
			onTexturesLoaded.dispatch(this);
		}
		
		/** Determine the bound of the area, the bound is uses by Level Manager to determine witch areas should be added or removed */
		public function setBounds(x:Number, y:Number, width:Number, height:Number):void {
			_bounds = new AreaBounds(x, y, width, height);
			_bounds.name = globalId.toFixed();
			_bounds.parentArea = this;
		}
		
		private var destroyed:Boolean;
		public function destroy():void {
			if (destroyed)
				return;
				
			if (added)
				removeFromState();
			
			this.site.areas.splice(this.site.areas.indexOf(this), 1);
			_region = null;
			_site = null;
			
			//** Destroy objects and other resources **//
			
			adjacentAreas.length = 0;
			
			var c_object:GameObject;
			for each (c_object in _objects){
				c_object.destroy();
			}
			
			var c_objectLists:*;
			for each (c_objectLists in _objectLists){
				c_objectLists.length = 0;
			}
			
			_objectLists.length = 0;
			
			_texturePacksUsed.length = 0;
			onTexturesLoaded.removeAll();
			rawCollisionInfo.length = 0;
			processedCollisionInfo.length = 0;
			oneWaycollisionInfo.length = 0;
			_statistics = null;
			var c_spritesInfo:GameObject;
			for each (c_spritesInfo in _spritesInfo){
				c_spritesInfo.destroy();
			}
			_spritesInfo.length = 0;
			texturePacksMissing.length = 0;
			
			destroyed = true;
		}
	}
}