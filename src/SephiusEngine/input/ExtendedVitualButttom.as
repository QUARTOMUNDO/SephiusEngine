package SephiusEngine.input 
{
	import adobe.utils.CustomActions;
	import SephiusEngine.input.controllers.AVirtualButton;
	import starling.display.DisplayObjectContainer;
	import starling.extensions.brinkbit.fullscreenscreenextension.FullScreenExtension;

	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	/**
	 * SephiusEngine Vitrual Button with aditional features.
	 * Features Added: Multiple Actions, Button Scale when pressed, Container to add
	 * @author Fernando Rabello
	 */
	public class ExtendedVitualButttom extends AVirtualButton {
		// main Sprite container.
		public var graphic:starling.display.Sprite;
		public var parent:DisplayObjectContainer;
		public var buttonBaseImage:Image;
		
		public var buttomDownState:Boolean = false;
		
		private var _buttonUpTexture:Texture;
		private var _buttonDownTexture:Texture;
		
		public var buttomActions:Array = new Array();
		/**
		 * @param	name
		 * @param	parent parent where graphics will be added to the dislpay list.
		 * @param	params
		 */
		public function ExtendedVitualButttom(name:String, parent:DisplayObjectContainer=null, params:Object = null) {
			this.parent = parent;
			super(name, params);
		}
		
		override protected function initGraphics():void {
			
			graphic = new starling.display.Sprite();

			if (!buttonUpTexture) {
				var tempSprite:Sprite = new Sprite();
				var tempBitmapData:BitmapData = new BitmapData(_buttonradius * 2, _buttonradius * 2, true, 0x00FFFFFF);
				
				tempSprite.graphics.clear();
				tempSprite.graphics.beginFill(0x000000, 0.1);
				tempSprite.graphics.drawCircle(_buttonradius, _buttonradius, _buttonradius);
				tempSprite.graphics.endFill();
				tempBitmapData.draw(tempSprite);
				buttonUpTexture = Texture.fromBitmapData(tempBitmapData);
				tempSprite = null;
				tempBitmapData = null;
			}

			if (!buttonDownTexture) {
				var tempSprite2:Sprite = new Sprite();
				var tempBitmapData2:BitmapData = new BitmapData(_buttonradius * 2, _buttonradius * 2, true, 0x00FFFFFF);

				tempSprite2.graphics.clear();
				tempSprite2.graphics.beginFill(0xEE0000, 0.85);
				tempSprite2.graphics.drawCircle(_buttonradius, _buttonradius, _buttonradius);
				tempSprite2.graphics.endFill();
				tempBitmapData2.draw(tempSprite2);
				buttonDownTexture = Texture.fromBitmapData(tempBitmapData2);
				tempSprite2 = null;
				tempBitmapData2 = null;
			}

			buttonBaseImage = new Image(buttonUpTexture);
			buttonBaseImage.pivotX = buttonBaseImage.pivotY = _buttonradius;

			tempSprite = null;
			tempBitmapData = null;

			graphic.x = _x;
			graphic.y = _y;

			graphic.addChild(buttonBaseImage);
			if (!parent)
				FullScreenExtension.stage.addChild(graphic);
			else
				parent.addChild(graphic);

			graphic.addEventListener(TouchEvent.TOUCH, handleTouch);
		}
		
		private function handleTouch(e:TouchEvent):void {
			
			var buttonTouch:Touch = e.getTouch(buttonBaseImage);

			if (buttonTouch) {
				
				switch (buttonTouch.phase) {
					
					case TouchPhase.BEGAN:
						(buttonTouch.target as Image).texture = buttonDownTexture;
						(buttonTouch.target as Image).scaleX = 0.9;
						(buttonTouch.target as Image).scaleY = 0.9;
						buttomDownState = true;
						triggerON(buttonAction, 1,null, buttonChannel);
						
						if (buttomActions.length > 0) {
							for (var i:int = 0; i < buttomActions.length; i++) {
								trace(buttomActions)
								triggerON(buttomActions[i], 1, null, buttonChannel);
							}
						}
						break;
						
					case TouchPhase.ENDED:
						(buttonTouch.target as Image).texture = buttonUpTexture;
						(buttonTouch.target as Image).scaleX = 1;
						(buttonTouch.target as Image).scaleY = 1;
						buttomDownState = false;
						triggerOFF(buttonAction, 0, null, buttonChannel);
						if (buttomActions.length > 0) {
							for (i; i < buttomActions.length; i++) {
								triggerOFF(buttomActions[i], 0, null, buttonChannel);
							}
						}
						break;
				}
			}
		}
		
		override public function set visible(value:Boolean):void {
			graphic.visible = value;
			_visible = value;
		}
		
		public function get buttonUpTexture():Texture 
		{
			return _buttonUpTexture;
		}
		
		public function set buttonUpTexture(value:Texture):void 
		{
			_buttonUpTexture = value;
			
			if (!buttonBaseImage) return;
			
			if (buttomDownState == false) {
				buttonBaseImage.texture = _buttonUpTexture;
				buttonBaseImage.pivotX = buttonBaseImage.texture.width / 2
				buttonBaseImage.pivotY = buttonBaseImage.texture.height / 2
				buttonBaseImage.readjustSize();
			}
		}
		
		public function get buttonDownTexture():Texture 
		{
			return _buttonDownTexture;
		}
		
		public function set buttonDownTexture(value:Texture):void 
		{
			_buttonDownTexture = value;
			
			if (!buttonBaseImage) return;
			
			if (buttomDownState == true) {
				buttonBaseImage.texture = _buttonDownTexture;
				buttonBaseImage.pivotX = buttonBaseImage.texture.width / 2
				buttonBaseImage.pivotY = buttonBaseImage.texture.height / 2
				buttonBaseImage.readjustSize();
			}
		}

		override public function destroy():void {
			
			graphic.removeEventListener(TouchEvent.TOUCH, handleTouch);
			
			graphic.removeChildren();
			
			if(!parent)
				FullScreenExtension.stage.removeChild(graphic);
			else 
				parent.removeChild(graphic);
			buttonUpTexture.dispose();
			buttonDownTexture.dispose();
			buttonBaseImage.dispose();
			
			super.destroy();
		}
	}
}