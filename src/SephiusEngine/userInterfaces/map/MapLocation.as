package SephiusEngine.userInterfaces.map {
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.display.Sprite;
	/**
	 * Describe a location to be shown in the map
	 * @author Fernando Rabello
	 */     
	public class MapLocation extends Sprite  {
		public var baseIcon:Image;
		public var secundaryIcon:Image;

		public function get GlobalID():String {return _globalID; }
		public function set GlobalID(value:String):void {
			_globalID = value;
		}
		private var _globalID:String;
		
		public function get typeID():String {return _typeID;}
		private var _typeID:String;
		
		public function get subTypeID():String {return _subTypeID;}
		private var _subTypeID:String;
		
		/** Determine if this map location is static on the map or can move it's place dynamicly*/
		public var DynamicPosition:Boolean;
		
		/** Determine if this map location can have some sort of visual animation. So update function will be called to update what is necessary each frame*/
		public var dynamicVisual:Boolean;
		
		private var animationPhaseRandom:Number = Math.random();
		
		public function get color():Number {return _color;}
		public function set color(value:Number):void {
			_color = value;
			baseIcon.color = _color;
		}
		private var _color:Number = 1;

		public function get stageScale():Number {return _stageScale;}
		public function set stageScale(value:Number):void {
			_stageScale = value;
			scaleX = scaleRatio * _stageScale * (inverted ? -1 : 1);
			scaleY = scaleRatio * _stageScale;
		}
		private var _stageScale:Number = 1;
		
		public function get scaleRatio():Number {return _scaleRatio;}
		public function set scaleRatio(value:Number):void {
			_scaleRatio = value;
			scaleX = scaleRatio * stageScale * (inverted ? -1 : 1);
			scaleY = scaleRatio * stageScale;
		}
		private var _scaleRatio:Number = 3;
		
		public var inverted:Boolean;

		public var alphaRatio:Number = 1;
		
		public function MapLocation(texture:Texture, X:Number, Y:Number, typeID:String, subTypeID:String = "", secundaryTexture:Texture = null ) {
			super();
			
			if(texture){
				baseIcon = new Image(texture);
				baseIcon.alignPivot();
				
				addChild(baseIcon);
			}

			if(secundaryTexture){
				secundaryIcon = new Image(secundaryTexture);
				secundaryIcon.alignPivot();
				addChild(secundaryIcon);

				secundaryIcon.x = 10;
				secundaryIcon.y = 10;
			}

			this.x = X;
			this.y = Y;
			
			scaleX = scaleRatio;
			scaleY = scaleRatio;
			
			_typeID = typeID;
			_subTypeID = subTypeID;
			
			//DynamicVisual = true;
			
			oAngle = animationPhaseRandom;
		}
		
		public function update():void{
		}
		
		public function UpdatePosition():void {
		}
		
		private var oAngle:Number = 0;
		public function UpdateVisual(alpha:Number):void {
			oAngle += 0.1;
			if (oAngle > (Math.PI * 2))
				oAngle = 0;
			
			scaleX = scaleY = ((.15 + (.15 * Math.abs(Math.sin(oAngle)))) * scaleRatio) * stageScale;
			
			this.alpha = alpha;
		}
		
		public function get enabled():Boolean {return _enabled;}
		public function set enabled(value:Boolean):void {
			_enabled = value;
			visible = value;
		}
		
		private var _enabled:Boolean;
		
		override public function dispose():void {
			if(baseIcon)
				baseIcon.dispose();
			removeFromParent();
			super.dispose();
		} 

	}
}