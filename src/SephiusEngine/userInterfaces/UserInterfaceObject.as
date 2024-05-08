package SephiusEngine.userInterfaces 
{
	import com.greensock.TweenMax;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.gameStates.LevelManager;
	import SephiusEngine.input.InputWatcher;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	
	/**
	 * Basic class for a user interface object
	 * @author Fernando Rabello
	 */
	public class UserInterfaceObject extends Sprite {
		public var inputWatcher:InputWatcher;
		public var onScreen:Boolean;
		protected var _main:GameEngine;
		
		public function UserInterfaceObject(inputWatcher:InputWatcher) {
			super();
			_main = GameEngine.instance;
			
			Starling.current.stage.addEventListener(Event.RESIZE, resize);
			//UserInterfaces.instance.addChildAt(this, 0);
			
			this.inputWatcher = inputWatcher;
			
			this.inputWatcher.onControllerAdded.add(changeDevice);
			this.inputWatcher.onControllerRemoved.add(changeDevice);
			
			init(null);
			
			if(inputWatcher.deviceButtomsName != "KeyboardBlack")
				changeDevice(inputWatcher.gameDevices[inputWatcher.gameDevices.length - 1].device.name);
			else
				changeDevice("None");
			
			//this.addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		public function update():void {
			updateInput();
		}
		
		protected function onTouch(event:TouchEvent):void {
			
		}
		
		public function changeDevice(deviceName:String):void {
			
		}
		
		protected function updateInput(): void {
			
		}
		
		public function show(id:String):void {
			onScreen = true;
			this.addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		public function hide():void {
			onScreen = false;
			this.removeEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		protected var _skin:String = "Light";
		public function get otherSkin():String { return skin == "Light" ? "Dark" : "Light"; }
		public function get skin():String {return _skin;}
		public function set skin(value:String):void {
			if (skin == value)
				return; 
			
			_skin = value == "Mestizo" ? "Light" : value;
		}
		
		public function changeSkin(skin:String = "Light"):void {
			this.skin = skin;
		}
		
		public function init(e:*):void {
			
		}
		
		public function resize(event:Event):void {
			
		}
		
		override public function dispose():void {
			super.dispose();
			
			TweenMax.killTweensOf(this);
			Starling.current.stage.removeEventListener(Event.RESIZE, resize);
			
			if(LevelManager.getInstance() && LevelManager.getInstance().mainPlayer)
				LevelManager.getInstance().mainPlayer.presence.onPlaceNatureChanged.remove(changeSkin);
		}
	}
}