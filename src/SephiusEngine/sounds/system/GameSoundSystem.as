package SephiusEngine.sounds.system 
{
	//import Game.core.Game_internal;
	import SephiusEngine.math.MathVector;
	import SephiusEngine.sounds.SoundManager;
	import SephiusEngine.sounds.system.components.GameSoundComponent;
	import SephiusEngine.sounds.system.components.SoundComponentType;
	import SephiusEngine.core.GameCamera;
	import SephiusEngine.core.GameEngine;
	import flash.geom.Rectangle;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.textures.Texture;
	
	/**
	 * Game sound system uses components
	 */
	public class GameSoundSystem 
	{
		private static var _instance:GameSoundSystem;
		
		private var _ge:GameEngine;
		private var _sm:SoundManager;
		
		//private var soundPositionsViews:Vector.<DisplayObject> = new Vector.<DisplayObject>();
		//private var soundDistancesViews:Vector.<DisplayObject> = new Vector.<DisplayObject>();
		//private static var screenCenterView:Image;
		
		public var components:Vector.<GameSoundComponent>;
		
		public var camera:GameCamera;
		public var camRect:Rectangle = new Rectangle();
		public var camCenter:MathVector = new MathVector();
		
		public var DEBUG:Boolean = false;
		
		//private static var soundIconTexture:Texture;
		//private static var areaSoundTexture:Texture;
		//private static var pointSoundTexture:Texture;
		
		public function GameSoundSystem(sm:SoundManager) 
		{
			_sm = sm;
			_ge = GameEngine.instance;
			components = new Vector.<GameSoundComponent>();
			_instance = this;
		}
		
		public static function getInstance():GameSoundSystem
		{
			return _instance;
		}
		
		public function registerComponent(sc:GameSoundComponent):void
		{
			/*
			if (!soundIconTexture){
				soundIconTexture = GameEngine.assets.getTexture("Debug_SoundIcon");
				areaSoundTexture = GameEngine.assets.getTexture("Debug_SoundArea");
				pointSoundTexture = GameEngine.assets.getTexture("Debug_SoundPoint");
			}*/
			
			sc.initialize();
			components.push(sc);
			/*
			var soundImage1:DisplayObject = new Image(soundIconTexture);
			var soundImage2:DisplayObject ;
			if (sc.type == SoundComponentType.POINT)
				soundImage2 = new Image(pointSoundTexture);
			else if (sc.type == SoundComponentType.AREA)
				soundImage2 = new Image(areaSoundTexture);
			else
				soundImage2 = new Quad (10, 10);
			
			soundImage1.pivotY = soundImage1.height * .5;
			soundImage1.pivotX = soundImage1.width * .5;
			soundImage1.scaleX = soundImage1.scaleY = .6;
			
			soundImage2.pivotY = soundImage2.height * .5;
			soundImage2.pivotX = soundImage2.width * .5;
			
			soundPositionsViews.push(soundImage1);
			soundDistancesViews.push(soundImage2);
			
			if (!screenCenterView){
				//screenCenterView = new Image(GameEngine.assets.getTexture("Debug_CanCenterIcon"));
				//screenCenterView.scaleX = screenCenterView.scaleY = .5
			}*/
		}
		
		public function unregisterComponent(sc:GameSoundComponent):void
		{
			sc.destroy();
			var i:int = components.lastIndexOf(sc);
			if(GameEngine.instance.debugCanvas){
				//soundPositionsViews[i].removeFromParent(true);
				//soundDistancesViews[i].removeFromParent(true);
			}
			if(i > -1){
				//soundPositionsViews[i] = null;
				//soundDistancesViews[i] = null;
				//soundPositionsViews.splice(i, 1);
				//soundDistancesViews.splice(i, 1);
				components.splice(i, 1);
			}
			//trace("GameSOUNDSYSTEM " + sc.name + " component unregistred");
		}
		
		public function update(timeDelta:Number):void
		{
			var c:GameSoundComponent;
			var camRotation:Number;
			
			if (_ge.state.view && _ge.state.view.camera){
				camera = _ge.state.view.camera;
				camCenter = camera.realPosition;
				camRotation = camera.realRotation;
			}
			else{
				camera = null;
				camCenter.x = camCenter.y = 0;
				camRotation = 0;
			}
			/*
			if(screenCenterView){
				screenCenterView.x = camCenter.x;
				screenCenterView.y = camCenter.y;
			}*/
			
			for each (c in components)
			{
				c.updatePosition();
				
				if (c.type != SoundComponentType.GLOBAL) //test anything non global
				{
					c.camVec.x = c.position.x - camCenter.x;
					c.camVec.y = c.position.y - camCenter.y;
					c.camVec.angle += camRotation;
				}
				
				c.update(timeDelta);
				/*
				if (DEBUG && _ge.debugCanvasVisible)
				{
					var cIndex:int = components.indexOf(c);
					
					//Add sound component art to debug canvas if it already does not be added. 
					if (!GameEngine.instance.debugCanvas.contains(soundPositionsViews[cIndex]))
						GameEngine.instance.debugCanvas.addChild(soundPositionsViews[cIndex]);
					if (!GameEngine.instance.debugCanvas.contains(soundDistancesViews[cIndex]))
						GameEngine.instance.debugCanvas.addChild(soundDistancesViews[cIndex]);
					if (!GameEngine.instance.debugCanvas.contains(screenCenterView))
						GameEngine.instance.debugCanvas.addChild(screenCenterView);
					
					soundPositionsViews[cIndex].x = c.position.x;
					soundPositionsViews[cIndex].y = c.position.y;
					soundPositionsViews[cIndex].visible = true;
					
					//_ce.debugCanvas.graphics.moveTo(camCenter.x,camCenter.y);
					//_ce.debugCanvas.graphics.lineStyle(0.2, 0xFF0000, 0.3);
					//_ce.debugCanvas.graphics.lineTo(c.position.x, c.position.y);
					
					//_ce.debugCanvas.graphics.beginFill(0x00FF00, 0.8);
					//_ce.debugCanvas.graphics.drawCircle(camCenter.x, camCenter.y, 10);
					
					//_ce.debugCanvas.graphics.beginFill(0xFF0000, 0.8);
					//_ce.debugCanvas.graphics.drawCircle(c.position.x, c.position.y, 10);
					
					if (c.radius > 0)
					{
						soundDistancesViews[cIndex].x = c.position.x;
						soundDistancesViews[cIndex].y = c.position.y;
						soundDistancesViews[cIndex].height = c.radius * 2;
						soundDistancesViews[cIndex].width = c.radius * 2;
						soundDistancesViews[cIndex].visible = true;
						
						//_ce.debugCanvas.graphics.beginFill(0xFF0000, 0.1);
						//_ce.debugCanvas.graphics.drawCircle(c.position.x, c.position.y, c.radius);
					}
				}
				else {
					soundPositionsViews[cIndex].visible = false;
					soundDistancesViews[cIndex].visible = false;
				}*/
			}
		}
		
		public function destroy():void
		{
			var sc:GameSoundComponent = components.pop();
			while (sc) {
				sc.destroy();
				sc = components.pop();
			}
			
			components.length = 0;
			components = null;
			/*
			soundPositionsViews.length = 0;
			soundDistancesViews.length = 0;
			soundPositionsViews = null;
			soundDistancesViews = null;
			screenCenterView.dispose();*/
			
			_ge = null;
			_sm = null;
			_instance = null;
		}
		
	}

}