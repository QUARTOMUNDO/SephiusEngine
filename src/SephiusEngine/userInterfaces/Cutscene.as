package SephiusEngine.userInterfaces 
{
	import SephiusEngine.core.GameData;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.gameStates.GameTitle;
	import SephiusEngine.core.gameStates.LevelManager;
	import tLotDClassic.GameData.Properties.CutsceneProperties;
	import SephiusEngine.input.InputActionsNames;

	import com.greensock.TweenMax;
	import com.greensock.loading.SWFLoader;

	import fl.video.FLVPlayback;

	import flash.display.MovieClip;

	import org.osflash.signals.Signal;

	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.extensions.brinkbit.fullscreenscreenextension.FullScreenExtension; 
	import flash.filesystem.File;

	/**
	 * ...
	 * @author Nilo & Farnando Fabello
	 */
	public class Cutscene extends UserInterfaceObject {
		private var _swfLoader:SWFLoader;
		
		public var running:Boolean;
		public var currentProperty:CutsceneProperties;
		public var onCutsceeEnded:Signal = new Signal();
		public var callback:Function;
		
		private var background:Quad = new Quad(10, 10, 0x000000);
		
		public var video:FLVPlayback;
		public var cutsceneContainer:MovieClip = new MovieClip();
		
		private var loaded:Boolean;
		private var showWhenLoaded:String;
		
		private const INTRO_START_GAME_URL:File = File.applicationDirectory.resolvePath("CutscenesContainer.swf");

		public function Cutscene() {
			super(UserInterfaces.instance.inputWatcher);
			//UserInterfaces.instance.addChild(this);
			

			_swfLoader = new SWFLoader(INTRO_START_GAME_URL.url);
			_swfLoader.load();
			_swfLoader.getContent(INTRO_START_GAME_URL.url).loader.addEventListener("complete", init);
		}
		
		private var scaleRation:Number;
		private var defaultScaleX:Number;
		private var defaultScaleY:Number;

		override public function init(e:*):void {
			if (!e)
				return;
				
			cutsceneContainer = _swfLoader.rawContent as MovieClip;
			//cutsceneContainerRoot.addChild(cutsceneContainer);
			
			video = cutsceneContainer.intro;
			//video.stop();
			_swfLoader.getContent(INTRO_START_GAME_URL.url).loader.removeEventListener("complete", init);
			
			cutsceneContainer.addChild(video);
			
			defaultScaleX = 1920;

			defaultScaleY = 1080;
			
			scaleRation = defaultScaleY / defaultScaleX;
			
			background.x = FullScreenExtension.screenLeft;
			background.y = FullScreenExtension.screenTop;
			background.width = FullScreenExtension.screenWidth;
			background.height = FullScreenExtension.screenHeight;
			
			cutsceneContainer.x = -FullScreenExtension.screenLeft * FullScreenExtension.sizeRatio;
			cutsceneContainer.y = -FullScreenExtension.screenTop * FullScreenExtension.sizeRatio;
			cutsceneContainer.width = FullScreenExtension.screenRenderWidth ;
			cutsceneContainer.height = cutsceneContainer.width * scaleRation;
			
			loaded = true;
		}
		
		override public function show(id:String):void {
			if (!loaded){
				showWhenLoaded = id;
				return;
			}
			
			//Cutscene was already listened abort
			if (CutsceneProperties[id].listenable)
				if(LevelManager.getInstance())
					if(LevelManager.getInstance().mainPlayer)
						if(LevelManager.getInstance().mainPlayer.archivemnets.listenedCutscenes[id].listened)
							return;
				
			onScreen = true;
			this.addEventListener(TouchEvent.TOUCH, onTouch);
			
			if (running)
				hide();
			
			if(callback)
				onCutsceeEnded.addOnce(callback);
			
			if(GameEngine.instance.state as LevelManager){
				GameEngine.instance.state.paused = true;
				UserInterfaces.instance.menusContainers.visible = false;
				GameEngine.instance.state.view.visible = false;
			}
			else if (GameEngine.instance.state as GameTitle){
				GameEngine.instance.state.paused = true;
				UserInterfaces.instance.menusContainers.visible = false;
				UserInterfaces.instance.titleMenu.holdTitle = true;
			}
			
			cutsceneContainer.alpha = 0;
			background.alpha = 0;
			
			TweenMax.killChildTweensOf(cutsceneContainer);
			TweenMax.to(cutsceneContainer, 2, { alpha:1 } );
			TweenMax.to(background, 2, { alpha:1 } );
			
			currentProperty = CutsceneProperties[id];
			video.play(currentProperty.file.url);
			
			Starling.current.nativeStage.addChild(cutsceneContainer);
			this.addChild(background);
			
			running = true;
		}
		
		override public function hide():void {
			this.removeEventListener(TouchEvent.TOUCH, onTouch);
			
			if(GameEngine.instance.state as LevelManager && callback != GameEngine.instance.state.cutsceneReset){
				GameEngine.instance.state.paused = false;
				UserInterfaces.instance.menusContainers.visible = true;
				GameEngine.instance.state.view.visible = true;
			}
			else if(GameEngine.instance.state as GameTitle as GameTitle && (callback != GameData.getInstance().newGame && callback != GameData.getInstance().showcaseGame)){
				GameEngine.instance.state.paused = false;
				UserInterfaces.instance.menusContainers.visible = true;
				UserInterfaces.instance.titleMenu.holdTitle = false;
			}

			TweenMax.delayedCall(2, stopVideo);
			TweenMax.delayedCall(2, resetVideo);
			TweenMax.delayedCall(2, Starling.current.nativeStage.removeChild, [cutsceneContainer]);
			TweenMax.delayedCall(2, this.removeChild, [background]);
			TweenMax.to(cutsceneContainer, 2, { alpha:0 } );
			TweenMax.to(background, 2, { alpha:0 } );
			///TweenMax.to(this, 2, { onScreen:false } );
			TweenMax.delayedCall(2, setOnScreen, [false]);
			
			currentProperty = null;
			//video.stop();
			
			running = false;
		}
		
		private function stopVideo():void{
			if(video && !isNaN(video.totalTime))
				video.stop();
		}

		private function resetVideo():void{
			if(video && !isNaN(video.totalTime))
				video.playheadPercentage = 0;
		}
		
		private function setOnScreen(value:Boolean):void{
			onScreen = value;
		}
		
		override protected function onTouch(event:TouchEvent):void {
			if(!currentProperty.skipable)
				return;
			
			super.onTouch(event);
			var touch:Touch = event.getTouch((event.target as DisplayObject));
			var menuIndex:int;
			if (touch) {
				if (touch.phase == TouchPhase.HOVER) {
				}
				else if (touch.phase == TouchPhase.BEGAN) {
					if (onScreen){
						if (currentProperty.listenable)
							if(LevelManager.getInstance())
								if(LevelManager.getInstance().mainPlayer)
									LevelManager.getInstance().mainPlayer.archivemnets.setCutsceneListined(currentProperty.varName);
						hide();
						onCutsceeEnded.dispatch();
					}
				}
			}
		}
		
		override public function resize(event:Event):void {
			super.resize(event);
			
			background.x = FullScreenExtension.screenLeft;
			background.y = FullScreenExtension.screenTop;
			background.width = FullScreenExtension.screenWidth;
			background.height = FullScreenExtension.screenHeight;
			
			if(cutsceneContainer){
				cutsceneContainer.x = -FullScreenExtension.screenLeft * FullScreenExtension.sizeRatio;
				cutsceneContainer.y = -FullScreenExtension.screenTop * FullScreenExtension.sizeRatio;
				cutsceneContainer.width = FullScreenExtension.screenRenderWidth ;
				cutsceneContainer.height = cutsceneContainer.width * scaleRation;
			}
		}
		
		private var playheadPercentage:Number = 0;
		override public function update():void {
			super.update();
			//trace(alpha, cutsceneContainer.alpha, cutsceneContainer.visible, visible, background.visible, background.alpha)
			
			if (showWhenLoaded){
				show(showWhenLoaded);
				showWhenLoaded = null;
			}
			
			if (!running)
				return;
			
			var isnan:Boolean = isNaN(video.playheadPercentage);
			
			if (!video.playing && !isnan){
				//if(video.playheadPercentage)
					//playheadPercentage = video.playheadPercentage;
				
				video.play();
				
				//if(playheadPercentage)
					//video.playheadPercentage = playheadPercentage;
			}
			else if (!isnan){
				playheadPercentage = video.playheadPercentage;
			}
			
			if (!isnan && (video.playheadPercentage > 99) ||
				(currentProperty.skipable && (UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_CONFIRM) ||
				UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_CANCEL) ||
				UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_CANCEL_B) ||
				UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_EXIT) ||
				UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_EXIT_B) ||
				UserInterfaces.instance.inputWatcher.justDid(InputActionsNames.INTERFACE_START)))){
				
				trace(video.playheadPercentage);
				
				if (currentProperty.listenable && LevelManager.getInstance())
					if(LevelManager.getInstance().mainPlayer)
						LevelManager.getInstance().mainPlayer.archivemnets.setCutsceneListined(currentProperty.varName);
					
				hide();
				
				onCutsceeEnded.dispatch();
			}
		}
		
		override public function dispose():void {
			super.dispose();
			Starling.current.stage.removeEventListener(Event.RESIZE, resize);
			cutsceneContainer = null;
			
			if(video.playing)
				video.stop();
			
			_swfLoader.unload();
			_swfLoader.dispose(true);
			_swfLoader = null;
			
			video = null;
			onCutsceeEnded.removeAll();
		}
	}
}