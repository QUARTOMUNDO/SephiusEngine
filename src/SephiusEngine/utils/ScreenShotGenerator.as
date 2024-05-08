package SephiusEngine.utils 
{
	import air.update.logging.Level;
	import SephiusEngine.math.MathVector;
	import SephiusEngine.assetManagers.TextureManager;
	import SephiusEngine.core.GameCamera;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.gameStates.LevelManager;
	import SephiusEngine.core.levelManager.CameraControl;
	import SephiusEngine.core.levelManager.LevelArea;
	import SephiusEngine.userInterfaces.UserInterfaces;
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.PNGEncoderOptions;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import starling.extensions.brinkbit.fullscreenscreenextension.FullScreenExtension;
	
	/**
	 * ...
	 * @author Fernando Rabello
	 */
	public class ScreenShotGenerator {
		
		public function ScreenShotGenerator() {
			
		}
		
		public static function mapLevel2():void {
			var area:LevelArea;
			var areaIndex:int;
			
			var jumpWidth:int = FullScreenExtension.screenWidth;
			var jumpHeight:int = FullScreenExtension.screenHeight;
			
			var USVisible:Boolean = LevelManager.getInstance().userInterfaces.visible;
			
			LevelManager.getInstance().userInterfaces.visible = false;
			
			while (areaIndex < LevelManager.getInstance().levelRegion.areas.length){
				area = LevelManager.getInstance().levelRegion.areas[areaIndex];
				
				TextureManager.loadAsync = false;
				trace("NEXT AREA", areaIndex);
				
				createImages(area.bounds, jumpWidth, jumpHeight, String(area.globalId));
				
				areaIndex++;
			}
			
			TextureManager.loadAsync = true;
			LevelManager.getInstance().userInterfaces.visible = USVisible;
		}
		
		public static function mapLevel():void {
			var area:LevelArea;
			var areaIndex:int;
			
			var jumpWidth:int = FullScreenExtension.screenWidth;
			var jumpHeight:int = FullScreenExtension.screenHeight;
			
			var USVisible:Boolean = LevelManager.getInstance().userInterfaces.visible;
			
			LevelManager.getInstance().userInterfaces.visible = false;
			
			var finalbound:Rectangle = new Rectangle();
			
			while (areaIndex < LevelManager.getInstance().levelRegion.areas.length) {
				area = LevelManager.getInstance().levelRegion.areas[areaIndex];
				
				finalbound = finalbound.union(area.bounds);
				
				areaIndex++;
			}
			
			TextureManager.loadAsync = false;
			
			createImages(finalbound, jumpWidth, jumpHeight, "All");
			
			TextureManager.loadAsync = true;
			LevelManager.getInstance().userInterfaces.visible = USVisible;
		}
		
		private static function createImages(areaToMap:Rectangle, jumpWidth:int, jumpHeight:int, id:String):void {
			var screenIndex:int;
			var screenIndex2:int;
			
			var screenShotWidth:int = FullScreenExtension.screenRenderWidth;
			var screenShotHeight:int = FullScreenExtension.screenRenderHeight;
			
			var bitmap:BitmapData = new BitmapData(screenShotWidth, screenShotHeight, true);
			
			var camera:GameCamera = LevelManager.getInstance().view.camera;
			
			var disalbeCameraControl:Boolean  = CameraControl.disableCameraControl;
			var disableRandomness:Boolean  = camera.disableRandomness;
			var cameraEase:MathVector = camera.easing ;
			
			var someAreaNotLoaded:Boolean;
			
			var areasAdded:LevelArea;
			
			var areaWSteps:uint = Math.ceil(areaToMap.width / jumpWidth);
			var areaHSteps:uint = Math.ceil(areaToMap.height / jumpHeight);
			
			camera.useManualPosition = true;
			camera.manualPosition.x = areaToMap.x;
			camera.manualPosition.y = areaToMap.y;
			camera.zoom = 1;
			camera.z = 1;
			camera.rotation = 0;
			camera.easing.setTo(1, 1);
			camera.offsetEasing = 1;
			camera.offset.setTo(0, 0);
			camera.disableRandomness = true;
			
			screenIndex = 0;
			
			TextureManager.loadAsync = false;
			/*
			areaToMap.x = LevelManager.getInstance().mainPlayer.x;
			areaToMap.y = LevelManager.getInstance().mainPlayer.y;
			jumpWidth = 0;
			jumpHeight = 0;
			*/
			while (screenIndex <= areaHSteps) {
				trace("NEXT LINE", screenIndex);
				screenIndex2 = 0;
				
				while (screenIndex2 <= areaWSteps) {
					camera.manualPosition.x = areaToMap.x + (jumpWidth * screenIndex2);
					camera.manualPosition.y = areaToMap.y + (jumpHeight * screenIndex);
					camera.reset();
					
					LevelManager.getInstance().view.updateViewNewStates(0);
					LevelManager.getInstance().view.updateViewOldStates();
					LevelManager.getInstance().view.smoothViewStates(1);
					LevelManager.getInstance().verifyPresences(0);
					GameEngine.instance.state.globalEffects.updateEnvironment(0);
					
					someAreaNotLoaded = false;
					
					for each(areasAdded in LevelManager.getInstance().areasAdded) {
						if (!areasAdded.texturesLoaded)
							someAreaNotLoaded = true;
					}
					
					if (!someAreaNotLoaded) {
						trace("NEXT COLLUM", screenIndex2);
						trace(camera.realPosition, "x:" + (areaToMap.x + (jumpWidth * screenIndex2)), "y:" + (areaToMap.y + (jumpHeight * screenIndex)));
						bitmap.fillRect(bitmap.rect, 0);
						FullScreenExtension.stage.drawToBitmapData(bitmap);
						saveBitmaps(bitmap, "tLotDScrenShot_A" + id + "_" + screenIndex + "x" + screenIndex2);
						
						screenIndex2++;
					}
					else {
						//trace("waiting Area get loaded");	
					}
				}
				
				screenIndex++;
			}
			
			camera.useManualPosition = false;
			camera.manualPosition.x = 0;
			camera.manualPosition.y = 0;
			camera.disableRandomness = disableRandomness;
			CameraControl.disableCameraControl = disalbeCameraControl;
		}
		
		private static function saveBitmaps(bitmap:BitmapData, name:String):void{
			var fileStream:FileStream = new FileStream();
			var bytes:ByteArray = new ByteArray();
			
			var filePath:String;
			var appDirFile:File;
			var xmlFile:File;
			
			filePath = "app:/ScreenShots/" + name + ".png";
			appDirFile = new File(filePath);
			xmlFile = new File(appDirFile.nativePath);
			
			bitmap.encode(bitmap.rect, new PNGEncoderOptions(), bytes);
			
			fileStream.open(xmlFile, FileMode.WRITE);
			fileStream.writeBytes(bytes);
			fileStream.close();	
			
			bytes.clear();
			bytes = null;
		}
	}
}