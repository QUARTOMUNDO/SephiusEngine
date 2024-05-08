package SephiusEngine.core.levelManager {

	import SephiusEngine.core.GameAssets;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.GamePhysics;
	import SephiusEngine.core.gameStates.LevelManager;
	import SephiusEngine.core.levelManager.AreaBounds;
	import SephiusEngine.core.levelManager.AreaMap;
	import SephiusEngine.core.levelManager.ILevelElement;
	import SephiusEngine.core.levelManager.LevelArea;
	import SephiusEngine.core.levelManager.LevelBackground;
	import SephiusEngine.core.levelManager.LevelRegion;
	import SephiusEngine.core.levelManager.LevelSite;
	import SephiusEngine.core.levelManager.LumaMap;
	import SephiusEngine.core.levelManager.RegionBase;
	import SephiusEngine.displayObjects.AnimationPack;
	import SephiusEngine.displayObjects.LightSprite;
	import SephiusEngine.displayObjects.configs.AssetsConfigs;
	import SephiusEngine.displayObjects.gameArtContainers.AnimationContainer;
	import SephiusEngine.displayObjects.gameArtContainers.LevelArt;
	import SephiusEngine.levelObjects.GameObject;
	import SephiusEngine.levelObjects.GamePhysicalObject;
	import SephiusEngine.levelObjects.GameSprite;
	import SephiusEngine.levelObjects.damagers.DamageCollisions;
	import SephiusEngine.levelObjects.specialObjects.LevelCollision;
	import SephiusEngine.levelObjects.specialObjects.LevelCollisionPoly;
	import SephiusEngine.utils.GameFilesUtils;

	import flash.display.IGraphicsData;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	import nape.geom.GeomPoly;
	import nape.geom.GeomPolyList;
	import nape.geom.Vec2;
	import nape.geom.Vec2List;
	import nape.shape.Polygon;
	import nape.shape.ShapeList;

	import org.osflash.signals.Signal;

	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.PolyImage;
	import starling.display.QuadBatch;
	import starling.display.QuadPolyData;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import starling.utils.cleanMasterString;

	import tLotDClassic.gameObjects.activators.Pyra;
	import starling.utils.rad2deg;
	import starling.display.DisplayObject;

	/**
	 * This Class is a factory to create several level objects. It loads a SWF or a XML previously exported and parse those objects to set the level.
	 * It couls also export a Level Region to a XML to be loaded on other state. 
	 * @author Fernando Rabello
	 */
	public class LevelMaker {
		
		public function LevelMaker() {}
		
		public static var onLevelRegionProcessed:Signal = new Signal();
		
		public static var loadingSitesProcessed:Signal = new Signal();
		
		public static var xmlLoading:int = 0;
		public static var loadingSites:Vector.<String> = new Vector.<String>();
		public static var loadingAreas:Vector.<String> = new Vector.<String>();
		public static var loadingBackGrounds:Vector.<String> = new Vector.<String>();

		/** Process a Level Region loading correspondent file config and creating all level objects. Dispach a signal when process finish. */
		public static function processLevelRegion(levelRegion:LevelRegion, callback:Function):void {
			//loadRegionAreasDeprecated(levelRegion);
			onLevelRegionProcessed.addOnce(callback);
			StartLevelLoadingPipeline(levelRegion);
		}
		
		private static function FinishLevelLoadingPipeline(levelRegion:LevelRegion):void{
			processAreasRelations(levelRegion);
			System.gc();
			onLevelRegionProcessed.dispatch();
		}
		
		private static function StartLevelLoadingPipeline(levelRegion:LevelRegion):void{
			var levelDefinitionFile:File = GameFilesUtils.LEVEL_DATA_DIRECTORY.resolvePath(levelRegion.url + "_Definition" + GameFilesUtils.LEVE_DATA_EXTENSION);
			loadXMLFile(levelRegion, null, levelDefinitionFile);
		}
		
		private static var updateLevelData:Boolean = true;
		private static function loadXMLFile(levelRegion:LevelRegion, site:LevelSite, xmlFile:File):void{
			GameFilesUtils.loadLevelData(xmlFile, onLevelXMLLoaded);
			xmlLoading = xmlLoading + 1;
			trace("xmlLoading ++ = " + xmlLoading);

			function onLevelXMLLoaded(xml:XML):void{
				processDataXML(levelRegion, site, xml)
			}
		}

		private static function processDataXML(levelRegion:LevelRegion, site:LevelSite, xml:XML):void{
			var regionName:String = cleanMasterString(xml.@regionName);
			var dataTypeName:String = cleanMasterString(xml.localName());
			switch (dataTypeName) 
			{
				case "Definitions":
					processLevelRegionDefinition(LevelRegion[regionName], xml);
				break;
				
				case "AreaMaps":
					processLevelMaps(LevelRegion[regionName], xml);
				break;
				
				case "LevelSite":
					processLevelSites(LevelRegion[regionName], site, xml);
				break;
				
				default:
					throw Error("[LEVELMAKER] XML has not a Level patern (AreaMaps or Level Region etc");
			}
			
			System.disposeXML(xml);
			
			//If all XMLs was downloaded
			xmlLoading = xmlLoading - 1;
			trace("xmlLoading -- = " + xmlLoading);
			if (xmlLoading <= 0)
				FinishLevelLoadingPipeline(LevelRegion[regionName]);
		}

		/** [DEPRECATED] Load a XML and process it dependning on wich data it contains */
		private static function loadXMLData(levelRegion:LevelRegion, site:LevelSite, dataURL:String):void{
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			xmlLoader.addEventListener(Event.COMPLETE, onXMLComplete);
			xmlLoader.load(new URLRequest(dataURL));	
			xmlLoading = xmlLoading + 1;
			trace("xmlLoading ++ = " + xmlLoading);
			
			function onXMLComplete(event:Event):void {
				xmlLoader.removeEventListener(Event.COMPLETE, onXMLComplete);
				//xmlLoader = event.target as URLLoader;	
				
				var xmlData:ByteArray = xmlLoader.data as ByteArray;
				var xml:XML;
				
				// check if the XML data is compressed
				var isCompressed:Boolean = false;
				if (xmlData[0] == 0x1F && xmlData[1] == 0x8B)
					isCompressed = true;

				if (isCompressed) {
					xmlData.uncompress()
					xml = new XML(xmlData);
					trace("[LEVELMAKER] XML data for deinition " + xml.localName() + " is compressed.");
					
				} else {
					xml = new XML(xmlData.readUTFBytes(xmlData.length));
					trace("[LEVELMAKER] XML data for deinition " + xml.localName() + " is uncompressed.");
				}
				
				var regionName:String = cleanMasterString(xml.@regionName);
				var dataTypeName:String = cleanMasterString(xml.localName());
				switch (dataTypeName) 
				{
					case "Definitions":
						processLevelRegionDefinition(LevelRegion[regionName], xml);
					break;
					
					//case "Bases":
						//processLevelBases(LevelRegion[regionName], xml);
					//break;
					
					case "AreaMaps":
						processLevelMaps(LevelRegion[regionName], xml);
					break;
					
					//case "Site":
						//processLevelSites(LevelRegion[regionName], xml);
					//break;
					
					case "LevelSite":
						processLevelSites(LevelRegion[regionName], site, xml);
					break;
					
					//case "Backgrounds":
						//processLevelBackGrounds(LevelRegion[regionName], xml);
					//break;
					
					default:
						throw Error("[LEVELMAKER] XML has not a Level patern (AreaMaps or Level Region etc");
				}
				
				System.disposeXML(xml);
				
				xmlData.clear();
				xmlLoader.close();
				xmlLoader = null;
				
				//If all XMLs was downloaded
				xmlLoading = xmlLoading - 1;
				trace("xmlLoading -- = " + xmlLoading);
				if (xmlLoading <= 0)
					FinishLevelLoadingPipeline(LevelRegion[regionName]);
			}
		}
		
		private static function processLevelRegionDefinition(levelRegion:LevelRegion, xml:XML):void {
			//loadXMLData(levelRegion, levelRegion.url + "_Bases" + extention);
			//loadXMLData(levelRegion, null, levelRegion.url + "_Maps" + extention);
			
			processLevelSitesDefinitions(levelRegion, xml);
			
		}

		/** Process level sites from a given XML data */
		private static function processLevelSitesDefinitions(levelRegion:LevelRegion, xml:XML):void {
			// ---------------------------
			// Process Sites
			// ---------------------------
			var LevelSiteDefinitionNode:XML;
			
			var siteID:int;
			var regionName:String;
			var areaID:int;
			var backGroundID:int;
			var BGID:int;
			var bgm:String;
			var bgfx:String;
			var rect:Rectangle;
			var gameObject:GameObject;
			var site:LevelSite;
			var siteName:String;
			var params:Object = {};
			var xmlFile:File;

			for each (LevelSiteDefinitionNode in xml.LevelSiteDefinition) {
				siteID = parseInt(LevelSiteDefinitionNode.@id);
				regionName = cleanMasterString(LevelSiteDefinitionNode.@region);
				siteName = cleanMasterString(LevelSiteDefinitionNode.@name);
				backGroundID = parseInt(LevelSiteDefinitionNode.@backGroundID);
				
				params.bgm = cleanMasterString(LevelSiteDefinitionNode.@BGM);
				params.bgfx = cleanMasterString(LevelSiteDefinitionNode.@BGFX);
				
				params.useAuroraEffect = getBoolean(LevelSiteDefinitionNode.@useAuroraEffect);
				params.useFlyingObjectsEffects = getBoolean(LevelSiteDefinitionNode.@useFlyingObjectsEffects);
				params.useFogEffect = getBoolean(LevelSiteDefinitionNode.@useFogEffect);
				params.useRainEffect = getBoolean(LevelSiteDefinitionNode.@useRainEffect);
				params.useSunEffect = getBoolean(LevelSiteDefinitionNode.@useSunEffect);
				
				if (!levelRegion.SitesDict[siteName]){
					site = new LevelSite(siteName, levelRegion, siteID, backGroundID, params);
					levelRegion.addSite(site);
				}
				
				//Load Areas
				xmlFile = GameFilesUtils.LEVEL_DATA_DIRECTORY.resolvePath(LevelSiteDefinitionNode.@URL + GameFilesUtils.LEVE_DATA_EXTENSION);
				loadXMLFile(levelRegion, site, xmlFile);

				//loadXMLData(levelRegion, site, LevelSiteDefinitionNode.@URL + extention);
			}
			
			var AreaMapsNode:XML;
			for each (AreaMapsNode in xml.DefinitionAreaMaps) {
				//Load Areas
				xmlFile = GameFilesUtils.LEVEL_DATA_DIRECTORY.resolvePath(cleanMasterString(AreaMapsNode.@URL) + GameFilesUtils.LEVE_DATA_EXTENSION);
				loadXMLFile(levelRegion, null, xmlFile);

				//loadXMLData(levelRegion, null, AreaMapsNode.@URL + extention);
			}
		}
		
		/** Process backgrounds from a given XML data */
		private static function processLevelAreas(levelRegion:LevelRegion, AreasNode:XML, site:LevelSite):void{
			// ---------------------------
			// Process Areas
			// ---------------------------
			var levelAreaNode:XML;
			var areaID:int;
			var rect:Rectangle;
			var gameObject:GameObject;
			for each (levelAreaNode in AreasNode.LevelArea) {
				areaID = parseInt(levelAreaNode.@globalId);
				rect = getRectangle(levelAreaNode.@bounds);
				levelRegion = LevelRegion[levelAreaNode.@regionName];
				
				log("---------------------------------");
				log("Processing a Area " + areaID);
				log("---------------------------------");
				
				levelRegion.createArea(areaID, site);
				levelRegion.areas[areaID].setBounds(rect.x, rect.y, rect.width, rect.height);
				log("AreaBounds: " + levelRegion.areas[areaID].bounds);
				
				// ---------------------------
				// Process Area Game Objects
				// ---------------------------
				processLevelElementXML(levelRegion.areas[areaID], levelAreaNode, GameEngine.assets);//Change the last argument to false to desable object combining.
				
				//Define each level object parent area so ir can be used by game engine latter
				for each (gameObject in levelRegion.areas[areaID].objects) {
					gameObject.parentArea = levelRegion.areas[areaID];
				}
			}
		}
		
		/** Process level bases (player start locations) from a given XML data */
		private static function processLevelBases(levelArea:LevelArea, xml:XML):void {
			// ---------------------------
			// Region Bases
			// ---------------------------
			trace("[LEVELMAKER] Processing Bases " + levelArea.region.name + " " + xml.localName());
			var regionBase:RegionBase;
			var baseNode:XML;
			for each (baseNode in xml.Base) {
				regionBase = new RegionBase(levelArea, baseNode.@x, baseNode.@y);
				levelArea.region.addBase(regionBase);
				log("Adding RegionBase. Global ID: " + regionBase.globalID);
			}
		}
		
		/** Process level maps from a given XML data */
		private static function processLevelMaps(levelRegion:LevelRegion, xml:XML):void {
			trace("[LEVELMAKER] Processing Area Maps " + levelRegion.name + " " + xml.localName());
			var node:XML;
			var areaMapNode:XML;
			var values:Vector.<uint>;
			var lumaMapNode:XML;
			var siteMapNode:XML;

			// ---------------------------
			// Process Area Map
			// ---------------------------
			for each (node in xml.AreaMap) {
				log("Processing AreaMap");
				
				levelRegion.areaMap = new AreaMap();
				
				levelRegion.areaMap.convertColorIDtoAreaID = false;
				levelRegion.areaMap.mapHeight = node.@mapHeight;
				levelRegion.areaMap.mapWidth = node.@mapWidth;
				levelRegion.areaMap.numberOfColors = node.@numberOfColors;
				levelRegion.areaMap.positionX = node.@positionX;
				levelRegion.areaMap.positionY = node.@positionY;
				levelRegion.areaMap.scaleX = node.@scaleX;
				levelRegion.areaMap.scaleY = node.@scaleY;
				
				for each (areaMapNode in node.AreasIDs) {
					levelRegion.areaMap.areasIDs = Vector.<uint>(getArray(areaMapNode.@values, uint));
				}
				
				for each (areaMapNode in node.MapValue) {
					values = Vector.<uint>(getArray(areaMapNode.@values.split(","), uint));
					levelRegion.areaMap.colorIDs.push(values);
				}
			}
			
			// ---------------------------
			// Process Luma Map
			// ---------------------------
			for each (node in xml.LumaMap) {
				levelRegion.lumaMap = new LumaMap();
				log("Processing LumaMap");
				
				levelRegion.lumaMap.mapHeight = node.@mapHeight;
				levelRegion.lumaMap.mapWidth = node.@mapWidth;
				levelRegion.lumaMap.positionX = node.@positionX;
				levelRegion.lumaMap.positionY = node.@positionY;
				levelRegion.lumaMap.scaleX = node.@scaleX;
				levelRegion.lumaMap.scaleY = node.@scaleY;
				
				for each (lumaMapNode in node.MapValue) {
					levelRegion.lumaMap.booleans.push(Vector.<Boolean>(getArray(lumaMapNode.@values, Boolean)));
				}
			}
			
			// ---------------------------
			// Process Sites Maps
			// ---------------------------

			var className:String;
			var siteName:String;
			var texName:String;
			var subID:String;
			var siteMapPieceNode:XML;
			var pieceID:String;

			for each (node in xml.SiteMaps) {
				for each (siteMapNode in node.MapLocation){
					className = cleanMasterString(siteMapNode.@className);
					siteName = cleanMasterString(siteMapNode.@siteName);
					subID = cleanMasterString(siteMapNode.@subID);

					if(className == "SiteMap"){
						LevelManager.getInstance().userInterfaces.gameMap.addSiteLocation(siteName, siteMapNode.@positionX, siteMapNode.@positionY, siteMapNode.@scaleX, siteMapNode.@scaleY); 
						
						for each (siteMapPieceNode in siteMapNode.SiteMapPiece){
							pieceID = cleanMasterString(siteMapPieceNode.@pieceID);
							LevelManager.getInstance().userInterfaces.gameMap.addSiteLocationPiece(siteName, pieceID, siteMapPieceNode.@positionX, siteMapPieceNode.@positionY, siteMapPieceNode.@scaleX, siteMapPieceNode.@scaleY);
						}
					}
					
					if(className == "MapTitle"){
						var textName:String = cleanMasterString(siteMapNode.@subID);
						LevelManager.getInstance().userInterfaces.gameMap.addSiteLocationTitle(siteName, subID, siteMapNode.@positionX, siteMapNode.@positionY, siteMapNode.@scaleX, siteMapNode.@scaleY); 
					}
				}
			}
		}
		
		/** Process backgrounds from a given XML data */
		private static function processLevelBackGround(levelRegion:LevelRegion, site:LevelSite, levelBGNode:XML):void{
			// ---------------------------
			// Process Background
			// ---------------------------
			site.createBackGround();
			//levelRegion.createBackGround(BGID.toString(), BGID, site);
			
			// ---------------------------
			// Process Backgrounds Game Objects
			// ---------------------------
			
			log("---------------------------------");
			log("Processing a Background " + site.name);
			log("---------------------------------");
			
			processLevelElementXML(site.backGround, levelBGNode, GameEngine.assets);//Change the last argument to false to desable object combining.
		}
		
		/** Process level areas from a given XML data */
		private static function processLevelSites(levelRegion:LevelRegion, site:LevelSite, LevelSiteXML:XML):void{
			// ---------------------------
			// Process Areas
			// ---------------------------			
			processLevelAreas(levelRegion, LevelSiteXML, site);
			
			// ---------------------------
			// Process Background
			// ---------------------------
			var levelBackgroundXMLList:XMLList = LevelSiteXML.LevelBackground;
			if (levelBackgroundXMLList.length() > 0) {
				processLevelBackGround(levelRegion, site, levelBackgroundXMLList[0]);
			} else {
				trace("No LevelBackground found");
			}
		}
		
		/** Process area relations which is which areas are close to other areas */
		private static function processAreasRelations(levelRegion:LevelRegion):void{
			// ---------------------------
			// Process Areas Relation
			// ---------------------------
			var area:LevelArea;
			var area2:LevelArea;
			var currentBound:AreaBounds;
			var currentBound2:AreaBounds;
			
			for each(area in levelRegion.areas) {
				if(area){
					currentBound = area.bounds;
					
					for each(area2 in levelRegion.areas) {
						if(area2){
							if(area2 != area){
								currentBound2 = area2.bounds;
								
								if (currentBound.intersects(currentBound2))
									area.adjacentAreas.push(area2);
							}
						}
					}
				}
			}
		}
		
		private static var useMatrix:Boolean = true;
		private static function setDisplayObjectTransform(displayObject:DisplayObject, childrenNode:XML):void{
			displayObject.name						= cleanMasterString(childrenNode.@name);
			displayObject.blendMode					= cleanMasterString(childrenNode.@blendMode);
			displayObject.alpha						= childrenNode.@alpha;

			if (childrenNode.@transformMode == "matrix" || (!childrenNode.hasOwnProperty("@transformMode") && LevelMaker.useMatrix)){
				displayObject.transformationMatrix.a 	= childrenNode.@matrixA;
				displayObject.transformationMatrix.b 	= childrenNode.@matrixB;
				displayObject.transformationMatrix.c 	= childrenNode.@matrixC;
				displayObject.transformationMatrix.d 	= childrenNode.@matrixD;
				displayObject.transformationMatrix.tx 	= childrenNode.@matrixTx;
				displayObject.transformationMatrix.ty 	= childrenNode.@matrixTy;
				//childImage.transformationMatrix.setTo(childrenNode.@matrixA, childrenNode.@matrixB, childrenNode.@matrixC, childrenNode.@matrixD, childrenNode.@matrixTx, childrenNode.@matrixTy);
				
				//childImage.x						= childrenNode.@x;
				//childImage.y						= childrenNode.@y;
			}
			else if (childrenNode.@transformMode == "normal"){
				displayObject.x						= childrenNode.@x;
				displayObject.y						= childrenNode.@y;
				displayObject.scaleX				= childrenNode.@scaleX;
				displayObject.scaleY				= childrenNode.@scaleY;
				displayObject.skewX					= childrenNode.@skewX;
				displayObject.skewY					= childrenNode.@skewY;
				displayObject.rotation				= childrenNode.@rotation;
			}
		}
		
		public static function defineParallax(params:Object):void {
			//------ This define parallaxes depending on the object group. used to make parallax changes easier
			if (params.group == AssetsConfigs.LIGHTS_ASSETS_GROUP) {
				params.parallax = AssetsConfigs.LIGHTS_PARALLAX;
				params.scaleOffsetX = AssetsConfigs.LIGHTS_PARALLAX;
				params.scaleOffsetY = AssetsConfigs.LIGHTS_PARALLAX;
			}
			else if (params.group == AssetsConfigs.PLATAFORM_BACK1_ASSETS_GROUP) {
				params.parallax = AssetsConfigs.PLATAFORM_BACK1_ASSETS_PARALLAX;
				params.scaleOffsetX = AssetsConfigs.PLATAFORM_BACK1_ASSETS_PARALLAX;
				params.scaleOffsetY = AssetsConfigs.PLATAFORM_BACK1_ASSETS_PARALLAX;
			}
			else if (params.group == AssetsConfigs.PLATAFORM_BACK2_ASSETS_GROUP) {
				params.parallax = AssetsConfigs.PLATAFORM_BACK2_ASSETS_PARALLAX;
				params.scaleOffsetX = AssetsConfigs.PLATAFORM_BACK2_ASSETS_PARALLAX;
				params.scaleOffsetY = AssetsConfigs.PLATAFORM_BACK2_ASSETS_PARALLAX;
			}
			else if (params.group == AssetsConfigs.PLATAFORM_BACK3_ASSETS_GROUP) {
				params.parallax = AssetsConfigs.PLATAFORM_BACK3_ASSETS_PARALLAX;
				params.scaleOffsetX = AssetsConfigs.PLATAFORM_BACK3_ASSETS_PARALLAX;
				params.scaleOffsetY = AssetsConfigs.PLATAFORM_BACK3_ASSETS_PARALLAX;
			}
			else if (params.group == AssetsConfigs.PLATAFORM_ZERO_ASSETS_GROUP) {
				params.parallax = AssetsConfigs.PLATAFORM_ZERO_ASSETS_PARALLAX;
				params.scaleOffsetX = AssetsConfigs.PLATAFORM_ZERO_ASSETS_PARALLAX;
				params.scaleOffsetY = AssetsConfigs.PLATAFORM_ZERO_ASSETS_PARALLAX;
			}
			else if (params.group == AssetsConfigs.PLATAFORM_FRONT1_ASSETS_GROUP){
				params.parallax = AssetsConfigs.PLATAFORM_FRONT1_ASSETS_PARALLAX;
				params.scaleOffsetX = AssetsConfigs.PLATAFORM_FRONT1_ASSETS_PARALLAX;
				params.scaleOffsetY = AssetsConfigs.PLATAFORM_FRONT1_ASSETS_PARALLAX;
			}
			else if (params.group == AssetsConfigs.PLATAFORM_FRONT2_ASSETS_GROUP){
				params.parallax = AssetsConfigs.PLATAFORM_FRONT2_ASSETS_PARALLAX;
				params.scaleOffsetX = AssetsConfigs.PLATAFORM_FRONT2_ASSETS_PARALLAX;
				params.scaleOffsetY = AssetsConfigs.PLATAFORM_FRONT2_ASSETS_PARALLAX;
			}
		}
		
		public static function processGameSprite(levelElement:ILevelElement, offset:Vec2, elementXML:XML, textureSource:GameAssets):void {
			var mainContainer:LevelArt, imageContainer:QuadBatch, lightContainer:Sprite, effectContainer:AnimationContainer;	
			var childImage:Image, childLight:LightSprite, childEffect:AnimationPack, gameSprite:GameSprite;
			var params:Object = {}, useMatrix:Boolean = true;
			var gameSpriteNode:XML;
			
			if (elementXML.localName() == "GameSprite") {
				// ---------------------------
				// Process GameSprite
				// ---------------------------
				log("Processing GameSprite " + elementXML.localName());
				
				gameSpriteNode = elementXML;
				
				params = {};
				params.name 			= cleanMasterString(gameSpriteNode.@name);
				if(levelElement as LevelArea)
					params.parentAreaID 	= (levelElement as LevelArea).globalId;
				params.group 			= parseInt(gameSpriteNode.@group);
				params.parallax 		= parseFloat(gameSpriteNode.@parallax);
				
				if (isNaN(params.parallax))
					params.parallax = 1;
				
				//Hole GameSprite Will have position Area is
				params.alpha 			= parseFloat(gameSpriteNode.@alpha);
				params.blendMode 		= cleanMasterString(gameSpriteNode.@blendMode);
				params.x 				= parseFloat(gameSpriteNode.@x) + offset.x;
				params.y 				= parseFloat(gameSpriteNode.@y) + offset.y;
				params.scaleOffsetX 	= parseFloat(gameSpriteNode.@scaleOffsetX);
				params.scaleOffsetY 	= parseFloat(gameSpriteNode.@scaleOffsetY);
				params.registration 	= "topLeft";
				
				defineParallax(params);

				var containerNodes:XML;
				var viewNode:XML;
				
				//Some Level files have a intermediary VIEW tag before the containers, since is annoying to deal with this VIEW tag in export this part can process both formats.
				var hasViewNode:Boolean = false;
				for each(viewNode in gameSpriteNode.View) {
					hasViewNode = true;
					containerNodes = viewNode;
				}
				
				if(!hasViewNode)
					containerNodes = gameSpriteNode;
				
				mainContainer = new LevelArt();
				mainContainer.touchable = false;
				mainContainer.name = "View _" + params.parentAreaID + "_" +  params.group;
				params.view = mainContainer;
				
				// ---------------------------
				// Process Containers and Childrens
				// ---------------------------
				var containerNode:XML, childrenNode:XML;
				var texture:Texture, polyImage:PolyImage, polyImagePiece:Image, polyDatas:Vector.<QuadPolyData>, polyData:QuadPolyData;
				var vPosString:String, vCoordsString:String, vColorsString:String, vAlphasString:String, vertexDataNode:XML;
				var atlasName:String;
				var texName:String;
				
				for each(containerNode in containerNodes.QuadBatchContainer) {
					trace("Processing QuadBatchContainer", containerNode.@atlas);
					
					atlasName = cleanMasterString(containerNode.@atlas);
					levelElement.addTexturePack(atlasName);		
					
					UpdateObjectCount(containerNode);
					
					imageContainer = new QuadBatch();
					imageContainer.name = cleanMasterString(containerNode.@name);
					mainContainer.addChild(imageContainer);
					
					for each(childrenNode in containerNode.Image) {
						UpdateObjectCount(childrenNode);
						texName = cleanMasterString(childrenNode.@texture);
						texture = textureSource.getTexture(texName);
						
						if (childrenNode.@type == "Polygon") {
							polyImage = new PolyImage(texture);
							polyDatas = new Vector.<starling.display.QuadPolyData>();
							//trace("=========================================");
							for each (vertexDataNode in childrenNode.PolygonData) {
								vPosString = vertexDataNode.@Positions;
								vCoordsString = vertexDataNode.@Coords;
								vColorsString = vertexDataNode.@Colors;
								
								vAlphasString = vertexDataNode.@Alphas;
								
								polyData = new QuadPolyData();
								polyData.parseVertexDataString(vPosString, vCoordsString, vColorsString, vAlphasString, vertexDataNode.@PointCount);
								polyDatas.push(polyData);
								
								polyImagePiece = new Image(texture);
								polyImagePiece.color = childrenNode.@color;

								setDisplayObjectTransform(polyImagePiece, childrenNode);
								polyImage.addPolygon(polyImagePiece, polyData);
							}
							//trace("=========================================");
							
							imageContainer.addQuadBatch(polyImage);
						} 
						else {
							childImage = new Image(texture);
							childImage.alignPivot();
							childImage.color = childrenNode.@color;
							setDisplayObjectTransform(childImage, childrenNode);
							imageContainer.addImage(childImage, mainContainer.alpha, null, childImage.blendMode);
						}
					}
				}
				for each(containerNode in containerNodes.SpriteContainer) {
					trace("Processing SpriteContainer", containerNode.@atlas);
					atlasName = cleanMasterString(containerNode.@atlas);
					levelElement.addTexturePack(atlasName);		
					
					UpdateObjectCount(containerNode);
					
					lightContainer = new Sprite();
					lightContainer.name = cleanMasterString(containerNode.@name);
					mainContainer.addChild(lightContainer);
					
					for each(childrenNode in containerNode.LightSprite) {
						UpdateObjectCount(childrenNode);
						
						atlasName = cleanMasterString(childrenNode.@texture).split("_")[0];
				
						childLight = new LightSprite(textureSource.getTexture(cleanMasterString(childrenNode.@texture)), levelElement as LevelArea, childrenNode.@radius, childrenNode.@color);
						childLight.alignPivot();
						childLight.light.castShadow = getRight(childrenNode.@castShadow);

						setDisplayObjectTransform(childLight, childrenNode);
						
						lightContainer.addChild(childLight);
					}
				}
				for each(containerNode in containerNodes.AnimationContainer) {
					trace("Processing AnimationContainer", containerNode.@atlas);
					atlasName = cleanMasterString(containerNode.@atlas);
					levelElement.addTexturePack(atlasName);		
					
					UpdateObjectCount(containerNode);
					
					effectContainer = new AnimationContainer("AnimationContainer" + params.parentAreaID, params.parentAreaID);
					effectContainer.name = cleanMasterString(containerNode.@name);
					mainContainer.addChildAt(effectContainer, 0);
					
					for each(childrenNode in containerNode.EffectArt) {
						UpdateObjectCount(childrenNode);
						
						atlasName = cleanMasterString(childrenNode.@texture).split("_")[0];
						
						childEffect = new AnimationPack(childrenNode.@texture, null, 30, "bilinear", true, "all", 1, true, false);

						//childEffect = effectContainer.addAnimation(childrenNode.@texture, null, 30, "bilinear", null, childrenNode.@alpha) as AtlasAnimation;
						//childImage.alignPivot();
						
						//childEffect.name						= cleanMasterString(childrenNode.@name);
						//childEffect.blendMode					= childrenNode.@blendMode;
						//childEffect.alpha						= childrenNode.@alpha;
						

						setDisplayObjectTransform(childEffect, childrenNode);
						childEffect.color 						= childrenNode.@color;

						/*
						if(!useMatrix){
							childEffect.x						= childrenNode.@x;
							childEffect.y						= childrenNode.@y;
							childEffect.scaleX					= childrenNode.@scaleX;
							childEffect.scaleY					= childrenNode.@scaleY;
							childEffect.skewX					= childrenNode.@skewX;
							childEffect.skewY					= childrenNode.@skewY;
							childEffect.rotation				= childrenNode.@rotation;
						}
						else{
							childEffect.transformationMatrix.a 	= childrenNode.@matrixA;
							childEffect.transformationMatrix.b 	= childrenNode.@matrixB;
							childEffect.transformationMatrix.c 	= childrenNode.@matrixC;
							childEffect.transformationMatrix.d 	= childrenNode.@matrixD;
							childEffect.transformationMatrix.tx = childrenNode.@matrixTx;
							childEffect.transformationMatrix.ty = childrenNode.@matrixTy;
						}*/
						
						effectContainer.addAnimation2(childEffect);
					}
				}
				
				gameSprite = new GameSprite ("GameSpritesContainer_" + params.group, params);
				gameSprite.view.updateState = false;
				levelElement.addObject(gameSprite);
				gameSpriteNode = null;
			}
		}
		
		public static var objectCounts:Object = {};
		
		private static function UpdateObjectCount(elementXML:XML):void{
			if (!objectCounts[elementXML.localName()])
				objectCounts[elementXML.localName()] = 0;
			
			objectCounts[elementXML.localName()]++;		
		}
		
		private static function UpdatePhysicsPointCount(finalNumberOfVertex:int):void{
			if (!objectCounts.FinalNumberOfVertex)
				objectCounts.FinalNumberOfVertex = 0;	
			objectCounts.FinalNumberOfVertex++;		
		}
		
		private static function UpdatePhysicsShapeCount(OritinalShape:int, FinalShapes:int):void{
			if (!objectCounts.OritinalShapeCount)
				objectCounts.OritinalShapeCount = 0;
			if (!objectCounts.FinalShapesCount)
				objectCounts.FinalShapesCount = 0;
			
			objectCounts.OritinalShapeCount++;		
			objectCounts.FinalShapesCount++;		
		}
		
		/** Create all objects inside a area or a background. */
		public static function processLevelElementXML(levelElement:ILevelElement, elementXML:XML, textureSource:GameAssets):void {
			var offset:Vec2 = Vec2.get();
			
			var areaObjects:XMLList = elementXML.children();
			var customParams:XMLList;
			var params:Object = {};
			
			var levelCollisionNode:XML, processedCollisionNode:XML, damageCollisionNode:XML, processedShapeNode:XML, boxCollisionNode:XML, boxShapeNode:XML;
			var customObjectNode:XML, customParamsNode:XML;
			
			var customObject:GameObject;

			var classObject:Class;
			
			var rawShapeCount:int, rawPointCount:int, processedShapeCount:int, processedPointCountprocessedPointCount:int;
			var otherCount:Dictionary = new Dictionary();
			
			var shapes:ShapeList, damageShapes:ShapeList, levelCollision:LevelCollision, damageCollisions:DamageCollisions, polygon:Polygon;
			
			var polygonMatrix:Matrix, shapePoint1:Vec2;
			var shapePoints:Vec2List = new Vec2List();
			
			var pyra:Pyra;

			var rotation:Number;

			offset.x = elementXML.@x;
			offset.y = elementXML.@y;
			
			objectCounts = {};
			
			for each (customObjectNode in areaObjects) {
				UpdateObjectCount(customObjectNode);
				
				if (customObjectNode.localName() == "GameSprite") {
					elementXML.@GameSprites = elementXML.@GameSprites + 1;
					
					processGameSprite(levelElement, offset, customObjectNode, textureSource);
				}
				
				else if (customObjectNode.localName() == "LevelCollision") {
					// ----------------------------
					// Process Physics
					// ---------------------------
					rawShapeCount = customObjectNode.RawCollision.@shapeCount;
					rawPointCount = customObjectNode.RawCollision.pointCount;
					
					//processedShapeCount = customObjectNode.ProcessedCollision.@shapeCount;
					//processedPointCount = customObjectNode.ProcessedCollision.@pointCount;
					
					log("Processing Physics " + customObjectNode.localName());
					shapes = new ShapeList();
					
					//Process the raw shapes if there is no processes collision node existing
					var processedCollisionsNodes:XMLList = customObjectNode.elements("ProcessedCollision");
					if(processedCollisionsNodes.length() == 0){
						var RawCollision:XML;
						for each (RawCollision in customObjectNode.elements("RawCollision")) {
							UpdateObjectCount(RawCollision);
							
							shapes.merge(decomposeRawShapes(RawCollision, true))
						}		
					}
					for each (processedCollisionNode in customObjectNode.ProcessedCollision) {
						for each (processedShapeNode in processedCollisionNode.ProcessedShape) {
							UpdateObjectCount(processedShapeNode);
							
							polygon = LevelCollisionPoly.CUSTOM_POLYGON(getVec2List(processedShapeNode.@points));
							
							polygon.userData.group = int(processedShapeNode.@group);
							polygon.userData.parallax = AssetsConfigs["PARALLAX" + polygon.userData.group];
							
							polygon.translate(Vec2.get((processedShapeNode.@x) / GamePhysics.SCALE, (processedShapeNode.@y) / GamePhysics.SCALE, true));
							shapes.add(polygon as Polygon);
						}
					}
					for each (boxCollisionNode in customObjectNode.BoxCollision) {
						for each (boxShapeNode in boxCollisionNode.BoxShape) {
							UpdateObjectCount(boxShapeNode);
							
							polygonMatrix = new Matrix(boxShapeNode.@matrixA, boxShapeNode.@matrixB, boxShapeNode.@matrixC, boxShapeNode.@matrixD, boxShapeNode.@matrixTx, boxShapeNode.@matrixTy);
							polygon = LevelCollisionPoly.BEVELED_BOX_FROM_MATRIX(polygonMatrix, .2, boxShapeNode.@width / 2 / GamePhysics.SCALE, boxShapeNode.@height / 2 / GamePhysics.SCALE, boxShapeNode.@x / GamePhysics.SCALE, boxShapeNode.@y / GamePhysics.SCALE,  Number(boxShapeNode.@rotation) * Math.PI / 180, getRight(boxShapeNode.@oneWay)) as Polygon;
							
							polygon.userData.group =  int(boxShapeNode.@group);
							polygon.userData.parallax = AssetsConfigs["PARALLAX" + polygon.userData.group];
							shapes.add(polygon as Polygon);
						}
					}
					
					if(shapes && shapes.length > 0){
						levelCollision = new LevelCollision("levelObjectCollision_" + levelElement.globalId, shapes, { x:offset.x, y:offset.y, height:10, width:10, rotation:rotation } );
						levelElement.addObject(levelCollision);
					}
				}
				else if (customObjectNode.localName() == "DamageCollision") {
					// ---------------------------
					// Processing Spikes
					// ---------------------------
					log("Prossessing: " + customObjectNode.localName());
					params = { };
					//customParams = customObjectNode.CustomParams.@* ;
						
					//if (!otherCount["DamageCollision"])
						//otherCount["DamageCollision"] = 0;
					
					//otherCount["DamageCollision"]++;
					
					// ----------------------------
					// Process Physics
					// ---------------------------
					
					log("Processing Physics " + customObjectNode.localName());
					
					damageShapes = new ShapeList();
					for each (RawCollision in customObjectNode.elements("RawCollision")) {
						UpdateObjectCount(RawCollision);
						
						damageShapes.merge(decomposeRawShapes(RawCollision, true))
					}
					
					if(damageShapes && damageShapes.length > 0){
						damageCollisions = new DamageCollisions("Damage Collision" +  + levelElement.globalId, damageShapes, { x:offset.x, y:offset.y, rotation:rotation , height:10, width:10 } );
						levelElement.addObject(damageCollisions);
					}
				}
				else if (customObjectNode.localName() == "Pyra") {
					log("Prossessing Pyras");
					params = { };
					
					params.x 				= parseFloat(customObjectNode.@x) + offset.x;
					params.y 				= parseFloat(customObjectNode.@y) + offset.y;
					params.group 			= parseInt(customObjectNode.@group);
					params.globalID 		= cleanMasterString(customObjectNode.@globalID);
					params.parallax 		= AssetsConfigs["PARALLAX" + cleanMasterString(customObjectNode.@group)];
					
					if (!otherCount["Pyras"])
						otherCount["Pyras"] = 0;
					
					otherCount["Pyras"]++;
					
 					pyra = new Pyra("Pyra_" +  levelElement.globalId + "_" + otherCount["SpikPyrases"], customObjectNode.@type, levelElement as LevelArea, params );
					levelElement.addObject(pyra);
				}
				else if (customObjectNode.localName() == "Bases") {
					processLevelBases(levelElement as LevelArea, customObjectNode);
				}
				else {
					// ---------------------------
					// Process Custom Objects
					// ---------------------------
					log("Prossessing Custom Objects: " + customObjectNode.localName());
					params = { };
					
					var hasCustomParamNode:Boolean = customObjectNode.hasOwnProperty("CustomParams");
					var customParamNode:XML;
					
					if(hasCustomParamNode){
						customParams = customObjectNode.CustomParams.@ * ;
						customParamNode = customObjectNode.CustomParams[0];
					}
					else{
						customParams = customObjectNode.@ * ;
						customParamNode = customObjectNode;
					}

					for each (customParamsNode in customParams) {
						varName = cleanMasterString(customParamsNode.localName());
						params[varName] = getRight(cleanMasterString(customParamsNode));
						if(varName == "globalID")
							trace("globalID");
						//if (isNaN(params[varName]))
							//trace("LevelMaker some problem happen");
					}
					
					// Deals with class full names that changed and are not same in level file and game code.
					var customClassFullName:String = classDefinitionCheck(params["className"]);
					
					classObject = getDefinitionByName(customClassFullName) as Class;
					
					var customClassName:String = customClassFullName.split(".").pop();
					
					params.x += offset.x;
					params.y += offset.y;
					
					customObject = new classObject(cleanMasterString(customObjectNode.@name), params);
					levelElement.addObject(customObject);
				}
			}
			
			var propName:String;
			var propValue:*;
			for (propName in objectCounts) {
				propValue = objectCounts[propName];
				trace("[OBJECT COUNTS]: " + propName + ": " + propValue);
			}		
			
			//trace ("Raw Point Count:", rawPointCount);
			//trace ("Processed Shape Count:", processedShapeCount);
			//trace ("Processed Point Count:", processedPointCount);	
		}
		
		/** Deals with class full names that chaged and are not the same in level file and game code */
		public static function classDefinitionCheck(className:String):String {
			//className = className.replace("epifanica", "SephiusEngine");
			var classNameTree:Array = className.split(".");
			className = classNameTree.pop();
			
			//className.replace("epifanica", "SephiusEngine");
			
			switch (className) {
				case "Spawner":
					return "tLotDClassic.gameObjects.characters.Spawner";
					break;
					
				case "EffectArt":
					return "SephiusEngine.displayObjects.gameArtContainers.EffectArt";
					break;
					
				case "Pool":
					return "tLotDClassic.gameObjects.pools.Pool";
					break;
					
				case "EventTrigger":
					return "SephiusEngine.levelObjects.activators.EventTrigger";
					break;
					
				case "ReagentCollider":
					return "SephiusEngine.levelObjects.activators.ReagentCollider";
					break;
					
				case "MysticReceptacle":
					return "tLotDClassic.gameObjects.activators.MysticReceptacle";
					break;
					
				case "Pyra":
					return "tLotDClassic.gameObjects.activators.Pyra";
					break;
					
				case "BreakableObject":
					return "tLotDClassic.gameObjects.breakableObjects.BreakableObject";
					break;
					
				case "Barriers":
					return "tLotDClassic.gameObjects.barriers.BreakableObject";
					break;
					
				case "BlockedBarrier":
					return "tLotDClassic.gameObjects.barriers.BlockedBarrier";
					break;
					
				case "EnchantedBarrier":
					return "tLotDClassic.gameObjects.barriers.EnchantedBarrier";
					break;
					
				case "TriggeredBarrier":
					return "tLotDClassic.gameObjects.barriers.TriggeredBarrier";
					break;
					
				case "SocketBarrier":
					return "tLotDClassic.gameObjects.barriers.SocketBarrier";
					break;
					
				case "Reward":
					return "tLotDClassic.gameObjects.rewards.Reward";
					break;
					
				default:
					return className;
			}
		}
		
		/*Useful functions*/
		private static function getRight(value:String):*{
			if (value.charAt(0) == "[") {
				value = value.slice(1, value.length - 1); 
				
				if(((value.indexOf(",")) != -1))
					return value.split(",");	
				else
					return [getRight(value)];
			}
			else if (value == "true" || value == "false")
				return getBoolean(value);
			else if (!isNaN(Number(value)) && (!isNaN(Number(String(value).charAt(0))) || (((String(value).charAt(0) == "." || String(value).charAt(0) == "-") && !isNaN(Number(String(value).charAt(1)))))))
				return Number(value);	
			//else if (!isNaN(parseFloat(value)))//Create problems with globalID having numbers and text
				//return parseFloat(value);	
			else
				return value;	
		}
		
		private static var vecList:Vec2List = new Vec2List();
		private static var vecPointString:String;
		private static function getVec2List(value:String):Vec2List {
			vecList.clear();
			recArray.length = 0;
			
			recArray = value.split(",");
			
			index = 0;
			var xs:String;
			var ys:String;
			var x:Number;
			var y:Number;
			
			while (index < recArray.length) {
				xs = recArray[index];
				ys = recArray[index + 1];
				x = recArray[index];
				y = recArray[index + 1];
				vecList.add(new Vec2(x, y));
				index += 2;
			}
			
			return vecList.copy();
		}
		
		private static function getMatrix(value:String):Matrix {
			recString = value.slice(1, value.length - 1);
			recArray = recString.split(", ");
			cObject = getObject(recArray);
			
			return new Matrix(object.a, object.b, object.c, object.d, object.tx, object.ty);
		}
		
		private static var recArray:Array;
		private static var recString:String;
		private static var cObject:Object;
		/** Return a Rectangle Object based on a string with patern:
		 * "(x=value, y=value, w=value, h=value)" */
		private static function getRectangle(value:String):Rectangle {
			recString = value.slice(1, value.length - 1);
			recString = recString.replace(/\s+/g, "");
			recArray = recString.split(",");
			
			cObject = getObject(recArray);
			
			cObject.x = Number(cObject.x);
			cObject.y = Number(cObject.y);
			cObject.w = Number(cObject.w);
			cObject.h = Number(cObject.h);
			
			if (isNaN(cObject.x) || isNaN(cObject.y) || isNaN(cObject.w) || isNaN(cObject.h))
				throw Error("Rectangle Generated has some NaN component");
				
			return new Rectangle(cObject.x, cObject.y, cObject.w, cObject.h);
		}
		
		private static var object:Object = { };
		private static var index:int;
		private static var varName:String;
		private static var value:*;
		/** Return a Object with properties / values bases on a array with strings with patern "var=value"*/
		private static function getObject(data:Array):Object {
			object = { };
			for (index in data) {
				varName = data[index].split("=")[0];
				value = data[index].split("=")[1];
				
				if (value == "true" || value == "false")
					value = getBoolean(value);
				
				object[varName] = value;
			}
			return object;
		}
		
		private static function getBoolean(value:String):Boolean {
			if (value == "false")
				return false;
			else
				return true;
		}
		
		private var cArray:Array = new Array();
		/** Return a array from a string with values separatade by ",". Also convert the array values to specied type*/
		private static function getArray(value:String, valueType:Class):Array {
			var cArray:Array;
			var index:int;
			
			cArray = value.split(",");
			
			for (index = 0; index < cArray.length; index++) {
				if (valueType == Boolean) {
					if(cArray[index] == "false" || cArray[index] == "true")
						cArray[index] = cArray[index] == "false" ? false : true;
					else
						cArray[index] = cArray[index] == "0" ? false : true;
				}
				else {
					cArray[index] = valueType(cArray[index]);
				}
			}
			
			return cArray;
		}
		
		// Get a Raw Collision and Decompose into Convex Shapes then save into the current XML being used which can be resaved with the new data
		public static function decomposeRawShapes(RawCollisionNode:XML, storeDataForExport:Boolean = true):ShapeList{
			var currentShape:Polygon;
			var shapeData:Vector.<Number> = new Vector.<Number>();
			var shapePoints:Vec2List = new Vec2List();
			var eShapePoints:Vec2List = new Vec2List();
			var sIndex:int = 0;
			var pointData:Array = [];
			var pi:int;
			var pPoint:Vec2;
			var shapePoint1:Vec2;
			var eShapePoint:Vec2;
			var shape:Shape;
			var graphicsPath:IGraphicsData;
			var pointCount:uint = 0;
			var totalShapeCount:uint = 0;
			var geomPoly:GeomPoly;
			var polygon:Polygon;
			var ePolygon:Polygon;
			var originalGeomPolyList:GeomPolyList;
			var finalGeomPolyList:GeomPolyList = new GeomPolyList();
			
			var originalLocalShapeCount:int = 0;
			var finalLocalShapeCount:int = 0;
			var finalNumberOfVertex:int = 0;
			
			var ShapeX:Number;
			var ShapeY:Number;
			var ShapeRotation:Number;
			
			var GameObjectNode:XML = RawCollisionNode.parent();
			var ProcessedCollisionNode:XML;
			var RawShapeNode:XML;
			
			var currentGroup: int;  
			
			var processedCollisionsNodes:XMLList = GameObjectNode.elements("ProcessedCollision");
			
			var CollisionShapes:ShapeList = new ShapeList();
			
			if(processedCollisionsNodes.length() == 0){
				ProcessedCollisionNode = new XML( <ProcessedCollision/> ); 
				GameObjectNode.appendChild(ProcessedCollisionNode);
			}
			else{
				ProcessedCollisionNode = processedCollisionsNodes.first();
			}
			
			for each (RawShapeNode in RawCollisionNode.elements("RawShape")) {
				UpdateObjectCount(RawShapeNode);
				
				ShapeX = RawShapeNode.@x;
				ShapeY = RawShapeNode.@y;
				ShapeRotation = RawShapeNode.@rotation;
				currentGroup = RawShapeNode.@group;  
				
				var pointsString:String = RawShapeNode.@points;
				var pointsVector:Vector.<String> = Vector.<String>(pointsString.split(","));
				
				shapePoints.clear();
				
				//Create a point for each par of number value
				for (sIndex = 0; sIndex <= pointsVector.length - 2; sIndex += 2) {
					shapePoint1 = Vec2.get(parseFloat(pointsVector[sIndex]), parseFloat(pointsVector[sIndex + 1]));
					shapePoints.add(shapePoint1);
				}
				//if (RawShapeNode.@name == "RawShape.Ugabuga"){
					//trace(RawShapeNode.@name);
				//}
				//trace(RawShapeNode.@name);
				//trace(shapePoints)
				
				// We need to have option to store shapePoints before decompose to be exported later
				if (storeDataForExport) {
					var collisionInfo:Object 		= {};
					collisionInfo.type 				= "RawPolygon";
					collisionInfo.oneWay 			= RawShapeNode.@oneWay;
					
					pointData = [];
					for (pi = 0; pi < shapePoints.length; pi++) {
						pPoint = shapePoints.at(pi);
						pointData.push(pPoint.x);
						pointData.push(pPoint.y);
					}
				
					collisionInfo.points 			= pointData;
					
					collisionInfo.x 				= ShapeX;
					collisionInfo.y 				= ShapeY;
					collisionInfo.rotation 			= ShapeRotation;
					
					collisionInfo.group = currentGroup;
					collisionInfo.parallax = AssetsConfigs["PARALLAX" + currentGroup];
				}
				
				geomPoly = GeomPoly.get(shapePoints);
				geomPoly = geomPoly.simplify(10);
				
				/** Decompose shape on convex parts */
				if (geomPoly.size() > 3) {
					originalGeomPolyList = geomPoly.simpleDecomposition();
					originalLocalShapeCount += originalGeomPolyList.length;
					
					while (!originalGeomPolyList.empty()) {
						finalGeomPolyList.merge(originalGeomPolyList.pop().convexDecomposition(true));
					}
					
					finalLocalShapeCount += finalGeomPolyList.length;
					
					//Add shape
					while (!finalGeomPolyList.empty()) {
						polygon = LevelCollisionPoly.CUSTOM_POLYGON(finalGeomPolyList.pop());
						polygon.rotate(ShapeRotation);
						polygon.translate(Vec2.get(ShapeX / GamePhysics.SCALE, ShapeY / GamePhysics.SCALE, true));
						
						polygon.userData.x = ShapeX;
						polygon.userData.y = ShapeY;
						polygon.userData.rotation = ShapeRotation;

						polygon.userData.type = cleanMasterString(RawShapeNode.@type);
						
						polygon.userData.group = currentGroup == AssetsConfigs.PLATAFORM_FRONT2_ASSETS_GROUP ? AssetsConfigs.OBJECTS_ASSETS_GROUP : currentGroup;
						polygon.userData.parallax = AssetsConfigs["PARALLAX" + polygon.userData.group];
						
						CollisionShapes.add(polygon as Polygon);
						
						finalNumberOfVertex +=  polygon.localVerts.length;
						
						if (GameObjectNode.localName() ==  "DamageCollision")
							polygon.userData.type = cleanMasterString(RawShapeNode.@type);
						
					}
					
					finalLocalShapeCount;
					originalLocalShapeCount;
					finalNumberOfVertex;
				}
				else{
					finalNumberOfVertex += 3;
				}
				
				UpdatePhysicsPointCount(finalNumberOfVertex);
				UpdatePhysicsShapeCount(originalLocalShapeCount, finalLocalShapeCount);
			}
			return CollisionShapes;
		}
		
		/** Export all level region data to XML file.
		 * This function save several date on diferent formats in order to be usefull not only for Starling level maker system but to be use on other engines as well
		 * When Level Maker process a SWF it retain several additional information witch normally is lost when level creation is finished. 
		 * The XML created on this process save this information as we should need on other engines.*/
		private static function exportLevelRegion(levelRegion:LevelRegion):void {
			var xmls:Vector.<XML> = new Vector.<XML>();
			// create the <LevelRegion /> node
			var levelRegionNode:XML 		= new XML( <LevelRegion/> ); 
			xmls.push(levelRegionNode);
			
			var areaMapNode:XML; 
			var areaMapColorIDNode:XML; 
			var areaMapAreaIDNode:XML; 
			
			var lumaMapNode:XML; 
			var lumaMapBooleanIDNode:XML; 
			
			var sitesNode:XML;
			var areaNode:XML;
			var bgNode:XML;
			var gameObjectNode:XML;
			var pyraNode:XML;
			var gameSpriteNode:XML;
			var objectViewNode:XML;
			var spriteObjectNode:XML;
			var spriteStateNode:XML;
			var spriteStateNodes:Dictionary = new Dictionary();
			var rawCollisionNode:XML;
			var processedCollisionNode:XML;
			var oneWayCollisionNode:XML;
			var rawShapesNode:XML;
			var processedShapesNode:XML;
			var oneWayShapesNode:XML;
			var customObjectNode:XML;
			var regionBasesNode:XML;
			var regionBaseNode:XML;
			
			var site:LevelSite;
			var area:LevelArea;
			var bg:LevelBackground;
			var gameObject:GameObject;
			var gameSprite:GameSprite;
			var spriteInfoObject:Object;
			var collisionInfoObject:nape.shape.Shape;
			var oneWayInfoObject:Object;
			var rawShapesInfoObject:Object;
			var processedShapesInfoObject:Object;
			
			var processedSpikeShapes:Polygon;
			
			var paramName:String;
			
			var areaBound:AreaBounds;
			var background:LevelBackground;
			var regionBase:RegionBase;
			var className:String;
			
			levelRegionNode 						= new XML( <LevelRegion/> ); 
			xmls.push(levelRegionNode);
			
			levelRegionNode.@name 					= levelRegion.name;
			levelRegionNode.@sansicoName 			= levelRegion.sansicoName;
			levelRegionNode.@worldNature 			= levelRegion.worldNature;
			levelRegionNode.@unknownArea 			= levelRegion.unknownArea.globalId;
			levelRegionNode.@url 					= levelRegion.url;
			levelRegionNode.@areasCount 			= levelRegion.areas.length;
			levelRegionNode.@sitesCount 			= levelRegion.sites.length;
			levelRegionNode.@basesCount		 		= levelRegion.basesCount;
			
			// Area Map
			areaMapNode 							= new XML( <AreaMap/> ); 
			xmls.push(areaMapNode);
			
			areaMapNode.@unkownAreaGlonalID		 	= levelRegion.areaMap.unkownAreaGlonalID;
			areaMapNode.@numberOfColors		 		= levelRegion.areaMap.numberOfColors;
			areaMapNode.@mapWidth		 			= levelRegion.areaMap.mapWidth;
			areaMapNode.@mapHeight		 			= levelRegion.areaMap.mapHeight;
			areaMapNode.@scaleX		 				= levelRegion.areaMap.scaleX;
			areaMapNode.@scaleY		 				= levelRegion.areaMap.scaleY;
			areaMapNode.@positionX		 			= levelRegion.areaMap.positionX;
			areaMapNode.@positionY		 			= levelRegion.areaMap.positionY;
			
			areaMapAreaIDNode						= new XML( <{"AreasIDs"}/> ); 
			xmls.push(areaMapAreaIDNode);
			
			areaMapAreaIDNode.@values		 		= levelRegion.areaMap.areasIDs;
			
			var widthIndex:uint;
			var widthIndex2:uint;
			var values:Vector.<uint>;
			var value:uint;
			
			for (widthIndex in levelRegion.areaMap.colorIDs) {
				areaMapColorIDNode 					= new XML( <{"MapValue"}/> ); 
				xmls.push(areaMapColorIDNode);
				
				values = new Vector.<uint>();
				
				for (widthIndex2 in levelRegion.areaMap.colorIDs[widthIndex]){
					value = levelRegion.areaMap.areasIDs[levelRegion.areaMap.colorIDs[widthIndex][widthIndex2]];
					values.push(value)
				}
				
				areaMapColorIDNode.@values			= values;
				
				areaMapNode.appendChild(areaMapColorIDNode);
			}
			
			areaMapNode.appendChild(areaMapAreaIDNode);
			levelRegionNode.appendChild(areaMapNode);
			
			// Luma Map
			lumaMapNode 							= new XML( <LumaMap/> ); 
			xmls.push(lumaMapNode);
			
			lumaMapNode.@mapWidth		 			= levelRegion.lumaMap.mapWidth;
			lumaMapNode.@mapHeight		 			= levelRegion.lumaMap.mapHeight;
			lumaMapNode.@scaleX		 				= levelRegion.lumaMap.scaleX;
			lumaMapNode.@scaleY		 				= levelRegion.lumaMap.scaleY;
			lumaMapNode.@positionX		 			= levelRegion.lumaMap.positionX;
			lumaMapNode.@positionY		 			= levelRegion.lumaMap.positionY;
			
			for (widthIndex in levelRegion.lumaMap.booleans) {
				lumaMapBooleanIDNode 				= new XML( <{"MapValue"}/> ); 
				xmls.push(lumaMapBooleanIDNode);
				
				lumaMapBooleanIDNode.@values		= Vector.<uint>(levelRegion.lumaMap.booleans[widthIndex]);
				lumaMapNode.appendChild(lumaMapBooleanIDNode);
			}
			
			levelRegionNode.appendChild(lumaMapNode);
			
			// ---------------------------
			// Region Bases
			// ---------------------------
			regionBasesNode = new XML( <{"Bases"}/> ); 
			xmls.push(regionBasesNode);
			
			regionBasesNode.@baseCount 		= levelRegion.basesCount;
			
			for each(regionBase in levelRegion.bases) {
				regionBaseNode = new XML( <{"Base"}/> ); 
				xmls.push(regionBaseNode);
				
				regionBaseNode.@areaGlobalID		= regionBase.areaGlobalID;
				regionBaseNode.@locallID			= regionBase.locallID;
				regionBaseNode.@globalID			= regionBase.globalID;
				regionBaseNode.@x					= regionBase.x;
				regionBaseNode.@y					= regionBase.y;
				
				regionBasesNode.appendChild(regionBaseNode);
			}
			
			levelRegionNode.appendChild(regionBasesNode);
			
			for each(site in levelRegion.sites) {
				// Processing sites infomation
				sitesNode = new XML( <LevelSite/> ); 
				xmls.push(sitesNode);
				
				sitesNode.@name 					= site.name;
				sitesNode.@backGroundID 			= site.backGroundID;
				sitesNode.@id 						= site.id;
				sitesNode.@useAuroraEffect 			= site.useAuroraEffect;
				sitesNode.@useFlyingObjectsEffects 	= site.useFlyingObjectsEffects;
				sitesNode.@useFogEffect 			= site.useFogEffect;
				sitesNode.@useRainEffect 			= site.useRainEffect;
				sitesNode.@useSunEffect 			= site.useSunEffect;
				
				for each(area in levelRegion.areas) {
					if(area.site == site){
						// Processing area infomation for each site
						areaNode = new XML( <LevelArea/> );
						xmls.push(areaNode);
						
						areaNode.@globalId 					= area.globalId;
						areaNode.@localId 					= area.localId;
						areaNode.@region 					= area.region.name;
						areaNode.@site 						= area.site.id;
						areaNode.@x 						= area.offset.x;
						areaNode.@y 						= area.offset.y;
						areaNode.@bounds					= area.bounds;
						
						areaNode.@objectCount 				= area.statistics.objectCount;
						areaNode.@spritesContainersCount 	= area.statistics.spritesContainersCount;
						areaNode.@spriteCount 				= area.statistics.spriteCount;
						
						//areaNode.@composedPlatformCount 	= area.areaStatistics.composedPlatformCount;
						//areaNode.@pointCount 				= area.areaStatistics.pointCount;
						//areaNode.@otherCount 				= area.areaStatistics.otherCount;
						
						objectViewNode = null;
						
						for each(gameObject in area.objects) {
							// Processing object infomation for each area
							
							className = getQualifiedClassName(gameObject);
							className = className.split("::")[1];
							
							gameObjectNode = new XML( <{className}/> );
							xmls.push(gameObjectNode);
							
							gameObjectNode.@name 			= gameObject.name;
							gameObjectNode.@parentAreaID 	= gameObject.parentArea.globalId;
							
							spriteStateNodes = new Dictionary();
							
							// Diferent types of GameObjects demand diferent type of data exported
							// We do not want to export all object properties since it is mostly useless
							// We want to export only the properties witch is actually setted by level editor
							switch(className) {
								case "GameSprite":
									gameObjectNode.@group 			= (gameObject as GameSprite).group;
									gameObjectNode.@alpha 			= (gameObject as GameSprite).alpha;
									gameObjectNode.@blendMode 		= (gameObject as GameSprite).blendMode;
									gameObjectNode.@x 				= (gameObject as GameSprite).x;
									gameObjectNode.@y 				= (gameObject as GameSprite).y;
									gameObjectNode.@scaleOffsetX 	= (gameObject as GameSprite).scaleOffsetX;
									gameObjectNode.@scaleOffsetY 	= (gameObject as GameSprite).scaleOffsetY;
									gameObjectNode.@parallax 		= (gameObject as GameSprite).parallax;
									
									if (isNaN(gameObjectNode.@parallax))
										gameObjectNode.@parallax = 1;
									
									// If GameObject has a view export it
									if((gameObject as GameSprite).view.content){
										objectViewNode = new XML( <{"View"}/> );
										xmls.push(objectViewNode);
										
										objectViewNode.@containersCount = !((gameObject as Object).view.content as DisplayObjectContainer) ? 0 : ((gameObject as Object).view.content as DisplayObjectContainer).numChildren;
									}
									
									var stateName:String = "";
									var spriteCount:int = 0;
									for each(spriteInfoObject in area.spritesInfo) {
										// Process all sprite information for each view´s group container
										// Level sprites was previously combined to mult polygon objects to save processing
										// When importing a SWF Level makes store the sprites information to be exported, otherwise those information is completly lost
										// When importing this XML to other engine we want to retain all the sprites information cause other engine would use diferent types of optimizations and we want to be able to edit sprites compose on those engines
										// For Starling import we could prefer to use the actual vertex date from those containers to recrete them instead part several sprite information. But this is optional.
										// This organize the sprite info by state container and group container
										// State container is a container witch holds all sprites witch share same group, atlas texture and blend mode (this is like this because is the way engine optitimise the render)
										// Group Container is the container witch holds all state containers witch share same group
										// This is not the way level was originally created on Flash Pro but is a better way to store the data since is closer the way the engine works in its optimization system.
										if (spriteInfoObject.group == (gameObject as GameSprite).group) {
											stateName = spriteInfoObject.atlas + "_" + spriteInfoObject.blendMode;
											
											if (!spriteStateNodes[stateName]){
												spriteStateNodes[stateName]	= new XML( <{"Container"}/> );
												xmls.push(spriteStateNodes[stateName]);
												
												spriteStateNodes[stateName].@name = stateName;
												spriteStateNodes[stateName].@className = spriteInfoObject.className;
												spriteStateNodes[stateName].@group = spriteInfoObject.group;
												spriteStateNodes[stateName].@atlas = spriteInfoObject.atlas;
												spriteStateNodes[stateName].@blendMode = spriteInfoObject.blendMode;
												spriteStateNodes[stateName].@spriteCount = 0;
											}
											
											spriteObjectNode = new XML( <{spriteInfoObject.className}/> );
											xmls.push(spriteObjectNode);
											
											spriteObjectNode.@className 			= spriteInfoObject.className;
											spriteObjectNode.@name 					= spriteInfoObject.name;
											
											spriteObjectNode.@matrixA 	= (spriteInfoObject.transformationMatrix as Matrix).a;
											spriteObjectNode.@matrixB 	= (spriteInfoObject.transformationMatrix as Matrix).b;
											spriteObjectNode.@matrixC 	= (spriteInfoObject.transformationMatrix as Matrix).c;
											spriteObjectNode.@matrixD 	= (spriteInfoObject.transformationMatrix as Matrix).d;
											spriteObjectNode.@matrixTx 	= (spriteInfoObject.transformationMatrix as Matrix).tx;
											spriteObjectNode.@matrixTy 	= (spriteInfoObject.transformationMatrix as Matrix).ty;
											
											spriteObjectNode.@x 					= spriteInfoObject.x;
											spriteObjectNode.@y 					= spriteInfoObject.y;
											spriteObjectNode.@alpha 				= spriteInfoObject.alpha;
											spriteObjectNode.@rotation 				= spriteInfoObject.rotation;
											spriteObjectNode.@scaleX 				= spriteInfoObject.scaleX;
											spriteObjectNode.@scaleY 				= spriteInfoObject.scaleY;
											spriteObjectNode.@skewX 				= spriteInfoObject.skewX;
											spriteObjectNode.@skewY 				= spriteInfoObject.skewY;
											spriteObjectNode.@texture 				= spriteInfoObject.texture;
											spriteObjectNode.@blendMode 			= spriteInfoObject.blendMode;
											spriteObjectNode.@atlas 				= spriteInfoObject.atlas;
											spriteObjectNode.@group 				= spriteInfoObject.group;
											
											//trace(spriteInfoObject.className);
											
											if(spriteInfoObject.className != "EffectArt"){
												//Store the actual position for each sprite vertex. This bypass matrix information and is usefull to import data for 3D applications.
												for (var vi:int = 0; vi <= 3; vi++){
													var VertexDataStrting:String = "";
													
													VertexDataStrting += "x:" 	   + spriteInfoObject["VertexData" + vi].x      + ","; 	   
													VertexDataStrting += "y:" 	   + spriteInfoObject["VertexData" + vi].y      + ","; 
													VertexDataStrting += "alpha:"  + spriteInfoObject["VertexData" + vi].alpha  + ",";  
													VertexDataStrting += "colorR:" + spriteInfoObject["VertexData" + vi].colorR + ","; 
													VertexDataStrting += "colorG:" + spriteInfoObject["VertexData" + vi].colorG + ","; 
													VertexDataStrting += "colorB:" + spriteInfoObject["VertexData" + vi].colorB + ","; 
													VertexDataStrting += "coordX:" + spriteInfoObject["VertexData" + vi].coordX + ","; 
													VertexDataStrting += "coordY:" + spriteInfoObject["VertexData" + vi].coordY; 
													
													spriteObjectNode.@["VertexData" + vi] = VertexDataStrting;
												}
											}
											
											if (spriteInfoObject.className == "LightSprite"){
												spriteObjectNode.@color 			= spriteInfoObject.color;
												spriteObjectNode.@castShadow 		= spriteInfoObject.castShadow;
												spriteObjectNode.@radius 			= spriteInfoObject.radius;
											}
											
											spriteStateNodes[stateName].appendChild( spriteObjectNode );
											spriteStateNodes[stateName].@spriteCount++;
											spriteCount++;
										}
									}
									
									if ((gameObject as GameSprite).view.content) {
										objectViewNode.@spriteCount = spriteCount;
									}
									
									for each(spriteStateNode in spriteStateNodes) {
										objectViewNode.appendChild( spriteStateNode );
									}
									
									gameObjectNode.appendChild( objectViewNode);
									
									break;
								case "LevelCollision":
									// Process Raw Collision witch is the data witch comes from Flash pro.
									// Its simpler than the processed data witch decompose concave shapes to several convex shapes
									// If you want to export collision to other programm this data should be more usefull
									rawCollisionNode = new XML( <{"RawCollision"}/> );
									xmls.push(rawCollisionNode);
									
									rawCollisionNode.@shapeCount = area.rawCollisionInfo.length;
									gameObjectNode.@x = (gameObject as GamePhysicalObject).x;
									gameObjectNode.@y = (gameObject as GamePhysicalObject).y;
									gameObjectNode.@physichScale = gameObject.paramsInfo.physichScale;
									
									var pointCount:int = 0;
									for each(rawShapesInfoObject in area.rawCollisionInfo) {
										rawShapesNode = new XML( <{"RawShape"}/> );
										xmls.push(rawShapesNode);
										
										rawShapesNode.@type 		= rawShapesInfoObject.type;
										rawShapesNode.@oneWay  		= false;
										rawShapesNode.@group 		= rawShapesInfoObject.group;
										rawShapesNode.@parallax		= rawShapesInfoObject.parallax;
										rawShapesNode.@x 			= rawShapesInfoObject.x;
										rawShapesNode.@y 			= rawShapesInfoObject.y;
										rawShapesNode.@points 		= rawShapesInfoObject.points;
										
										//Points are stored in a vector of numbers each pair represent a vetex/point
										pointCount += rawShapesInfoObject.points.length / 2;
										
										rawCollisionNode.appendChild( rawShapesNode ); 
									}
									
									rawCollisionNode.@pointCount = pointCount;
									
									// Process the processed collision with is the data actually used by the game
									// Concave shapes was decomposed to several convex shapes with lot of more points
									// This data is more suitable for be imported by the game itself since avoid level makes to decompose the shapes when level is creating.
									processedCollisionNode = new XML( <{"ProcessedCollision"}/> );
									xmls.push(processedCollisionNode);
									
									processedCollisionNode.@shapeCount 				= (gameObject as LevelCollision).body.shapes.length;
									processedCollisionNode.@pointCount 				= area.statistics.pointCount;
									processedCollisionNode.@composedPlatformCount 	= area.statistics.composedPlatformCount;
									
									for each(processedShapesInfoObject in area.processedCollisionInfo) {
										processedShapesNode = new XML( <{"ProcessedShape"}/> );	
										xmls.push(processedShapesNode);
										
										processedShapesNode.@type 			= processedShapesInfoObject.type;
										processedShapesNode.@oneWay  		= false;
										processedShapesNode.@group 			= processedShapesInfoObject.group;
										processedShapesNode.@parallax 		= processedShapesInfoObject.parallax;
										processedShapesNode.@x 				= processedShapesInfoObject.x;
										processedShapesNode.@y 				= processedShapesInfoObject.y;
										processedShapesNode.@points 		= processedShapesInfoObject.points;
										
										processedCollisionNode.appendChild( processedShapesNode ); 
									}
									// beside the normal collisions we have one way collisiont witch is platforms witch player only collides from above. On other games it also be called cloud platforms
									// This objects need to be stored separataly from normal collisions cause engine need additional information about platform location and angle that cannot be stored on combined polygons
									oneWayCollisionNode = new XML( <{"BoxCollision"}/> );
									xmls.push(oneWayCollisionNode);
									
									var oneWayCount:uint = 0;
									
									for each(oneWayInfoObject in area.oneWaycollisionInfo) {
										oneWayShapesNode = new XML( <{"BoxShape"}/> );
										xmls.push(oneWayShapesNode);
										
										oneWayShapesNode.@type 					= oneWayInfoObject.type;
										oneWayShapesNode.@oneWay 				= oneWayInfoObject.oneWay;
										oneWayShapesNode.@group 				= oneWayInfoObject.group;
										oneWayShapesNode.@parallax 				= oneWayInfoObject.parallax;
										
										oneWayShapesNode.@matrixA 	= (oneWayInfoObject.transformationMatrix as Matrix).a;
										oneWayShapesNode.@matrixB 	= (oneWayInfoObject.transformationMatrix as Matrix).b;
										oneWayShapesNode.@matrixC 	= (oneWayInfoObject.transformationMatrix as Matrix).c;
										oneWayShapesNode.@matrixD 	= (oneWayInfoObject.transformationMatrix as Matrix).d;
										oneWayShapesNode.@matrixTx 	= (oneWayInfoObject.transformationMatrix as Matrix).tx;
										oneWayShapesNode.@matrixTy 	= (oneWayInfoObject.transformationMatrix as Matrix).ty;
										
										oneWayShapesNode.@width 				= oneWayInfoObject.width;
										oneWayShapesNode.@height 				= oneWayInfoObject.height;
										oneWayShapesNode.@x 					= oneWayInfoObject.x;
										oneWayShapesNode.@y 					= oneWayInfoObject.y;
										oneWayShapesNode.@rotation 				= oneWayInfoObject.rotation;
										
										oneWayCount++;
										
										oneWayCollisionNode.appendChild( oneWayShapesNode ); 
									}
									
									oneWayCollisionNode.@shapeCount = oneWayCount;
									
									gameObjectNode.appendChild( rawCollisionNode ); 
									gameObjectNode.appendChild( processedCollisionNode ); 
									gameObjectNode.appendChild( oneWayCollisionNode ); 
									
									break;
								case "Spikes":
									//Custom objects store params witch comes from original level editor. Only this data is saved. Not all properties witch has default values*/
									customObjectNode = new XML( <{"CustomParams"}/> );
									customObjectNode.@className = className;
									customObjectNode.@physichScale = (gameObject as DamageCollisions).paramsInfo.physichScale;
									
									xmls.push(customObjectNode);
									
									for (paramName in gameObject.paramsInfo) {
										if (gameObject.paramsInfo[paramName] as Array || gameObject.paramsInfo[paramName] as Vector.<*>)
											customObjectNode.@[paramName] = "[" + gameObject.paramsInfo[paramName] + "]";
										else
											customObjectNode.@[paramName] = gameObject.paramsInfo[paramName];
									}
									
									// Process the processed collision with is the data actually used by the game
									// Concave shapes was decomposed to several convex shapes with lot of more points
									// This data is more suitable for be imported by the game itself since avoid level makes to decompose the shapes when level is creating.
									processedCollisionNode = new XML( <{"ProcessedCollision"}/> );
									xmls.push(processedCollisionNode);
									
									processedCollisionNode.@shapeCount 				= (gameObject as DamageCollisions).body.shapes.length;
									processedCollisionNode.@pointCount 				= area.statistics.pointCount;
									
									var i:int = 0;
									var sLenght:int = (gameObject as DamageCollisions).body.shapes.length;
									
									for (i = 0; i < sLenght; i++) {
										processedSpikeShapes = (gameObject as DamageCollisions).body.shapes.at(i) as Polygon;
										
										processedShapesNode = new XML( <{"ProcessedShape"}/> );	
										xmls.push(processedShapesNode);
										
										processedShapesNode.@type 		= processedSpikeShapes.userData.type;
										processedShapesNode.@points 		= setPolgonData(processedSpikeShapes);
										processedShapesNode.@x 				= processedSpikeShapes.userData.x;
										processedShapesNode.@y 				= processedSpikeShapes.userData.y;
										
										processedCollisionNode.appendChild( processedShapesNode ); 
									}
									
									gameObjectNode.appendChild( processedCollisionNode ); 
									gameObjectNode.appendChild( customObjectNode );
									
									break;
								case "Pyra":
									//pyraNode = new XML( <{"Pyra"}/> );
									gameObjectNode.@type = (gameObject as Pyra).type;
									//gameObjectNode.@areaGlobalID = (gameObject as Pyra).areaGlobalID;
									gameObjectNode.@globalID = (gameObject as Pyra).globalID;
									gameObjectNode.@x = (gameObject as Pyra).x - area.offset.x;
									gameObjectNode.@y = (gameObject as Pyra).y - area.offset.y;
									gameObjectNode.@group = (gameObject as Pyra).group;
									
									//gameObjectNode.appendChild( pyraNode ); 
									break;	
								default:
									//Custom objects store params witch comes from original level editor. Only this data is saved. Not all properties witch has default values*/
									customObjectNode = new XML( <{"CustomParams"}/> );
									customObjectNode.@className = className;
									xmls.push(customObjectNode);
									
									for (paramName in gameObject.paramsInfo) {
										if (gameObject.paramsInfo[paramName] as Array || gameObject.paramsInfo[paramName] as Vector.<*>)
											customObjectNode.@[paramName] = "[" + gameObject.paramsInfo[paramName] + "]";
										else
											customObjectNode.@[paramName] = gameObject.paramsInfo[paramName];
									}
									
									//gameObject.paramsInfo = null;
									
									gameObjectNode.appendChild( customObjectNode ); 
									break;
							}
							
							// add the <areaNode> node to <sitesNode>
							areaNode.appendChild( gameObjectNode ); 
						}
						// add the <areaNode> node to <sitesNode>
						sitesNode.appendChild( areaNode ); 
						
						//Dispose all export data info from areas
						area.spritesInfo.length = 0;
						area.rawCollisionInfo.length = 0;
						area.oneWaycollisionInfo.length = 0;
						area.processedCollisionInfo.length = 0;
						area.statistics = null;
					}
				}
				
				// add the <sitesNode> node to <levelRegionNode>
				levelRegionNode.appendChild( sitesNode ); 
			}
			
			for each(site in levelRegion.sites) {
				bg = site.backGround;
				
				bgNode = new XML( <LevelBackground/> ); 
				xmls.push(bgNode);
				
				bgNode.@name 					= bg.name;
				bgNode.@globalId 				= bg.globalId;
				bgNode.@region 					= bg.region.name;
				bgNode.@x 						= bg.offset.x;
				bgNode.@y 						= bg.offset.y;
				
				bgNode.@objectCount 			= bg.statistics.objectCount;
				bgNode.@spritesContainersCount 	= bg.statistics.spritesContainersCount;
				bgNode.@spriteCount 			= bg.statistics.spriteCount;
				
				for each(gameSprite in bg.objects) {
					
					className = getQualifiedClassName(gameSprite);
					className = className.split("::")[1];
					
					gameSpriteNode = new XML( <{className}/> );
					xmls.push(gameSpriteNode);
					
					gameSpriteNode.@name 			= gameSprite.name;
					
					spriteStateNodes = new Dictionary();
					
					// Diferent types of GameObjects demand diferent type of data exported
					// We do not want to export all object properties since it is mostly useless
					// We want to export only the properties witch is actually setted by level editor
					gameSpriteNode.@group 			= gameSprite.group;
					gameSpriteNode.@alpha 			= gameSprite.alpha;
					gameSpriteNode.@blendMode 		= gameSprite.blendMode;
					gameSpriteNode.@x 				= gameSprite.x;
					gameSpriteNode.@y 				= gameSprite.y;
					gameSpriteNode.@scaleOffsetX 	= gameSprite.scaleOffsetX;
					gameSpriteNode.@scaleOffsetY 	= gameSprite.scaleOffsetY;
					gameSpriteNode.@parallax 		= gameSprite.parallax;
					
					// If GameObject has a view export it
					if((gameSprite as GameSprite).view.content){
						objectViewNode = new XML( <{"View"}/> );
						xmls.push(objectViewNode);
						
						objectViewNode.@containersCount = !((gameSprite as Object).view.content as DisplayObjectContainer) ? 0 : ((gameSprite as Object).view.content as DisplayObjectContainer).numChildren;
					}
					
					stateName = "";
					spriteCount = 0;
					for each(spriteInfoObject in bg.spritesInfo) {
						// Process all sprite information for each view´s group container
						// Level sprites was previously combined to mult polygon objects to save processing
						// When importing a SWF Level makes store the sprites information to be exported, otherwise those information is completly lost
						// When importing this XML to other engine we want to retain all the sprites information cause other engine would use diferent types of optimizations and we want to be able to edit sprites compose on those engines
						// For Starling import we could prefer to use the actual vertex date from those containers to recrete them instead part several sprite information. But this is optional.
						// This organize the sprite info by state container and group container
						// State container is a container witch holds all sprites witch share same group, atlas texture and blend mode (this is like this because is the way engine optitimise the render)
						// Group Container is the container witch holds all state containers witch share same group
						// This is not the way level was originally created on Flash Pro but is a better way to store the data since is closer the way the engine works in its optimization system.
						if (spriteInfoObject.group == gameSprite.group) {
							stateName = spriteInfoObject.group + "_" + spriteInfoObject.atlas + "_" + spriteInfoObject.blendMode;
							
							if (!spriteStateNodes[stateName]){
								spriteStateNodes[stateName]	= new XML( <{"Container"}/> );
								
								xmls.push(spriteStateNodes[stateName]);
								
								xmls.push(spriteStateNodes[stateName]);
								spriteStateNodes[stateName].@name 			= stateName;
								spriteStateNodes[stateName].@group 			= spriteInfoObject.group;
								spriteStateNodes[stateName].@className 		= spriteInfoObject.className;
								spriteStateNodes[stateName].@atlas 			= spriteInfoObject.atlas;
								spriteStateNodes[stateName].@blendMode 		= spriteInfoObject.blendMode;
								spriteStateNodes[stateName].@spriteCount 	= 0;
							}
							
							spriteObjectNode = new XML( <{spriteInfoObject.className}/> );
							xmls.push(spriteObjectNode);
							
							spriteObjectNode.@className 			= spriteInfoObject.className;
							spriteObjectNode.@name 					= spriteInfoObject.name;
							
							spriteObjectNode.@matrixA 	= (spriteInfoObject.transformationMatrix as Matrix).a;
							spriteObjectNode.@matrixB 	= (spriteInfoObject.transformationMatrix as Matrix).b;
							spriteObjectNode.@matrixC 	= (spriteInfoObject.transformationMatrix as Matrix).c;
							spriteObjectNode.@matrixD 	= (spriteInfoObject.transformationMatrix as Matrix).d;
							spriteObjectNode.@matrixTx 	= (spriteInfoObject.transformationMatrix as Matrix).tx;
							spriteObjectNode.@matrixTy 	= (spriteInfoObject.transformationMatrix as Matrix).ty;
							
							spriteObjectNode.@x 					= spriteInfoObject.x;
							spriteObjectNode.@y 					= spriteInfoObject.y;
							spriteObjectNode.@alpha 				= spriteInfoObject.alpha;
							spriteObjectNode.@rotation 				= spriteInfoObject.rotation;
							spriteObjectNode.@scaleX 				= spriteInfoObject.scaleX;
							spriteObjectNode.@scaleY 				= spriteInfoObject.scaleY;
							spriteObjectNode.@skewX 				= spriteInfoObject.skewX;
							spriteObjectNode.@skewY 				= spriteInfoObject.skewY;
							spriteObjectNode.@texture 				= spriteInfoObject.texture;
							spriteObjectNode.@blendMode 			= spriteInfoObject.blendMode;
							spriteObjectNode.@atlas 				= spriteInfoObject.atlas;
							spriteObjectNode.@group 				= spriteInfoObject.group;
							
							//trace(spriteInfoObject.className);
							
							if(spriteInfoObject.className != "EffectArt"){
								//Store the actual position for each sprite vertex. This bypass matrix information and is usefull to import data for 3D applications.
								for (vi = 0; vi <= 3; vi++){
									VertexDataStrting = "";
									
									VertexDataStrting += "x:" 	   + spriteInfoObject["VertexData" + vi].x      + ","; 	   
									VertexDataStrting += "y:" 	   + spriteInfoObject["VertexData" + vi].y      + ","; 
									VertexDataStrting += "alpha:"  + spriteInfoObject["VertexData" + vi].alpha  + ",";  
									VertexDataStrting += "colorR:" + spriteInfoObject["VertexData" + vi].colorR + ","; 
									VertexDataStrting += "colorG:" + spriteInfoObject["VertexData" + vi].colorG + ","; 
									VertexDataStrting += "colorB:" + spriteInfoObject["VertexData" + vi].colorB + ","; 
									VertexDataStrting += "coordX:" + spriteInfoObject["VertexData" + vi].coordX + ","; 
									VertexDataStrting += "coordY:" + spriteInfoObject["VertexData" + vi].coordY; 
									
									spriteObjectNode.@["VertexData" + vi] = VertexDataStrting;
								}
							}
							
							spriteStateNodes[stateName].appendChild( spriteObjectNode );
							spriteStateNodes[stateName].@spriteCount++;
							spriteCount++;
						}
					}
					
					if ((gameSprite as GameSprite).view.content) {
						objectViewNode.@spriteCount = spriteCount;
					}
					
					for each(spriteStateNode in spriteStateNodes) {
						objectViewNode.appendChild( spriteStateNode );
					}
					
					gameSpriteNode.appendChild( objectViewNode);
					bgNode.appendChild( gameSpriteNode ); 
					bgNode
					className.split(".");
				}
				
				levelRegionNode.appendChild( bgNode );
				
				//Dispose all export data info from areas
				bg.spritesInfo.length = 0;
				bg.statistics = null;
			}
			var file:File;
			var fileStream:FileStream = new FileStream();
			var bytes:ByteArray = new ByteArray();
			
			var filePath:String;
			var appDirFile:File;
			var xmlFile:File;
			
			filePath = File.applicationDirectory.resolvePath("levels").resolvePath(levelRegion.name + "_uncompressed" + ".xml").url;
			appDirFile = new File(filePath);
			xmlFile = new File(appDirFile.nativePath);
			
			//file = File.applicationDirectory.resolvePath("levels/" + levelRegion.name + "_uncompressed" + ".xml");
			fileStream.open(xmlFile, FileMode.WRITE);
			fileStream.writeUTFBytes(levelRegionNode.toXMLString());
			fileStream.close();	
			
			filePath = File.applicationDirectory.resolvePath("levels").resolvePath(levelRegion.name + ".xml").url;
			appDirFile = new File(filePath);
			xmlFile = new File(appDirFile.nativePath);
			
			bytes.writeUTFBytes( levelRegionNode ); // "levelRegionNode" being your root XML node
			bytes.compress(); // compress it			
			fileStream.open(xmlFile, FileMode.WRITE);
			fileStream.writeBytes(bytes);
			fileStream.close();	
			bytes.clear();
			bytes = null;
			
			var cxml:Object;
			for each(cxml in xmls) {
				if (cxml as XML)	
					System.disposeXML(cxml as XML);
			}
			cxml = null;
		}
		
		private static function setPolgonData(polygon:Polygon):Array {
			var pointData:Array;
			var pPoint:Vec2;
			var pi:int;
			var piLenght:int = polygon.localVerts.length;
			pointData = [];
			
			for (pi = 0; pi < piLenght; pi++) {
				pPoint = polygon.localVerts.at(pi);
				pointData.push(pPoint.x);
				pointData.push(pPoint.y);
			}
			
			return pointData;
		}
		
		public static var verbose:Boolean = false;
		public static function log(message:String):void {
			if (verbose)
				trace("[LEVELMAKER]:", message);
		}
	}
}