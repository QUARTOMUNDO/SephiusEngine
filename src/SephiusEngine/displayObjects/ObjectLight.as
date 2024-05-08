package SephiusEngine.displayObjects 
{
	import SephiusEngine.core.GameAssets;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.displayObjects.LightSprite;

	import starling.display.DisplayObjectContainer;
	
	/**
	 * Light witch is child of another object
	 * @author Fernando Rabello
	 */
	public class ObjectLight extends LightSprite {
		/** Special Sprite will fallow it´s parent if it has one */
		private var _lightParent:DisplayObjectContainer;
		
		/** Name of texture this Special Sprite should use */
		public var textureName:String;
		
		/** If true Special Sprite will rotate with its parent */
		public var linkRotation:Boolean = false;
		
		public var referentialRotation:Number = 0;
		
		/** If true Special Sprite will invert with its parent */
		public var linkInvertion:Boolean = false;
		
		/** If true Special Sprite will invert with its parent */
		public var linkAlpha:Boolean = false;
		
		/** If sprite should appear above or below its parent */
		public var compositionMode:String = "above";
		
		public var alignment:String = "center";
		
		public var assets:GameAssets;
		
		private var brighnessMultipler:Number = 1;
		private var sizeMultipler:Number = 1;
		
		/** If true, light radius and brightness will simulate a erratic light source like a flame */ 
		/* Values: none, slow, medium, fast */
		public var isErratic:String = "none"; 
		public var erraticIntesnsity:Number = 1;
		private var erraticAngle:Number = 0;
		
		public function ObjectLight(textureName:String, radius:uint = 100, color:uint = 0xfffffff, brightness:Number = 1, params:Object = null) {
			if (!assets)	
				assets = GameEngine.assets;
			
			super(assets.getTexture(textureName), null, radius, color, brightness, false);
			
			if(params)
				initialize(params);
				
			if(alignment == "center")
				alignPivot();
			
			this.color = color;
			
			referentialRotation = rotation;	
			
			name = "Light-" + textureName;
			
			addedToState = true;
			
			if(lightParent)
				enabled = true;
		}
		
		public function initialize(params:Object = null):void {
			for (var param:String in params){
				this[param] = params[param];
			}
		}
		
		override public function updateLight(timePassed:Number):void {
			if (isErratic != "none"){			
				erraticAngle = (erraticAngle + (isErratic == "fast" ? 0.5 : isErratic == "medium" ? 0.25 : isErratic == "slow" ? 0.1 : 0)) % Math.PI;
				brighnessMultipler = Math.sin(erraticAngle) * erraticIntesnsity;
				//sizeMultipler = Math.sin(erraticAngle) * erraticIntesnsity;
			}
			
			super.updateLight(timePassed);
			
			light.brightness = brightness * brighnessMultipler;
			//pointLight.radius = radius;
			
			if (!linkRotation)
				rotation = referentialRotation - _lightParent.rotation;
			
			this.width = radius * .5;
			this.height = radius * .5;
			this.alpha = brightness * .5;
			
			light.setColor(this.color);
		}
		
		override public function get width():Number {
			return super.width;
		}
		
		override public function get height():Number {
			return super.height;
		}
		
		override public function dispose():void {
			lightParent = null;
			assets = null;
			super.dispose();
		}
		
		public function get lightParent():DisplayObjectContainer{return _lightParent;}
		public function set lightParent(value:DisplayObjectContainer):void {
			if(value){
				if(compositionMode == "above")
					value.addChild(this);
				else if (compositionMode == "below")
					value.addChildAt(this, 0);
			}
			else if(_lightParent && !value) {
				lightParent.removeChild(this);
			}
			_lightParent = value;
		}
		
		override public function set enabled(value:Boolean):void {
			super.enabled = value;
			
			if(!value) {
				visible = false;
			}
			else
				visible = true;
		}
	}
}