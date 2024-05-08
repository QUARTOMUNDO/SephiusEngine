package SephiusEngine.levelObjects {
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.gameStates.LevelManager;
	import SephiusEngine.displayObjects.GameArt;
	import SephiusEngine.levelObjects.GameObject;
	import SephiusEngine.levelObjects.interfaces.ISpriteView;
	import org.osflash.signals.Signal;
	import starling.display.DisplayObject;


	/** Basic class for Sprite in the game */	
	public class GameSprite extends GameObject implements ISpriteView{
		
		/**  Dispatched whenever the object animation changes. */		
		public var onAnimationChange:Signal = new Signal(String);
		
		public function get viewAdded():Boolean{ return _viewAdded; };
		protected var _viewAdded:Boolean = false;
		
		public function GameSprite(name:String, params:Object = null){
			_ge = GameEngine.instance;
			_lm = LevelManager.getInstance();
			
			if(params && params.view)
				spriteName = params.view.name;
			else
				spriteName = name;
			
			super(name, params);
		}
		
		override public function update(timeDelta:Number):void{
			super.update(timeDelta);
		}
		
		override public function destroy():void{
			super.destroy();
			_onDestroyed.dispatch(this);
			_onDestroyed.removeAll();
		}
		
		public function createView():GameArt {
			view = new GameArt(this);
			if (paramsInfo.view);
				view.content = paramsInfo.view;
			return view;
		}
		
		/** Destroy the visual representation container (GameArt) */		
		public function destroyView():void {
			if (_viewAdded)
				removeView();
			
			view.dispose();
		}
		
		/** Add the visual representation container (GameArt) from the view root */		
		public function addView():void {
			if (_viewAdded)
				return;
			
			if(view.updateState)
				GameEngine.instance.state.view.viewObjectsToUpdate.push(view);
			
			GameEngine.instance.state.view.viewObjects.push(view);
			
			if(view.content){
				GameEngine.instance.state.view.updateArtNewState(view);
				GameEngine.instance.state.view.updateArtOldState(view);
				GameEngine.instance.state.view.smoothArtState(view, .5, .5);
			}
			
			GameEngine.instance.state.view.updateGroupForSprite(view, view.compAbove);
			_viewAdded = true;
			view.activate();
			//trace("bject witch is ISpriteView: art added: " + SephiusEngineObject.spriteName);
		}
		
		/** Removes the visual representation container (GameArt) from the view root  */		
		public function removeView():void {
			if (_viewAdded){ 
				view.removeFromParent();
				if (GameEngine.instance.state.view){
					if(view.updateState)
						GameEngine.instance.state.view.viewObjectsToUpdate.splice(GameEngine.instance.state.view.viewObjectsToUpdate.indexOf(view), 1);
					
					GameEngine.instance.state.view.viewObjects.splice(GameEngine.instance.state.view.viewObjects.indexOf(view), 1);
					//delete GameEngine.instance.state.view.viewObjectsByName[this];
				}
				_viewAdded = false;
				view.deactivate();
				//trace("Object witch is ISpriteView: art removed: " + SephiusEngineObject.spriteName);
			}
		}
		
		public function get onDestroyed():Signal {return _onDestroyed;}
		public function set onDestroyed(value:Signal):void {_onDestroyed = value;}
		private var _onDestroyed:Signal = new Signal(ISpriteView);
		
		public function get spriteName():String { return _spriteName; }
		public function set spriteName(value:String):void { _spriteName = value; }
		protected var _spriteName:String = "GameSprite";
		
		public function get x():Number{ return _x; }
		public function set x(value:Number):void { _x = value; }
		protected var _x:Number = 0;
		
		public function get y():Number{ return _y; }
		public function set y(value:Number):void{ _y = value; }
		protected var _y:Number = 0;
		
		public function get z():Number { return 0; }
		
		public function get width():Number { return _width; }
		public function set width(value:Number):void { _width = value; }
		protected var _width:Number = 30;
		
		public function get height():Number{ return _height; }
		public function set height(value:Number):void{ _height = value; }
		protected var _height:Number = 30;
		
		public function get depth():Number { return 0; }
		
		public function get scaleX():Number{ return _scaleX; }
		public function set scaleX(value:Number):void { _scaleX = value; }
		protected var _scaleX:Number = 1;
		
		public function get scaleY():Number { return _scaleY; }
		public function set scaleY(value:Number):void { _scaleY = value; }
		protected var _scaleY:Number = 1;
		
		public function get scaleZ():Number { return 1; }
		
		public function get rotation():Number{ return _rotation; }
		public function set rotation(value:Number):void { _rotation = value; }
		protected var _rotation:Number = 0;
		
		public function get rotationRad():Number { return _rotation;}
		public function set rotationRad(value:Number):void{_rotation = value; }
		
		public function get parallax():Number { return _parallax; }
		public function set parallax(value:Number):void { _parallax = value; }
		protected var _parallax:Number = 1;
		
		/** The group is similar to a z-index sorting. Default is 0, 1 is over.  */
		public function get group():uint{ return _group; }
		public function set group(value:uint):void { _group = value; }
		protected var _group:uint = 0;
		
		/** Force Engine to update view layer. usefull if you want a gameobject to be behind or above objects witch was added latter than this one */
		public function get updateGroup():Boolean { return _updateGroup; }
		public function set updateGroup(value:Boolean):void { _updateGroup = value; }
		private var _updateGroup:Boolean;
		
		public function get visible():Boolean { return _visible; }
		public function set visible(value:Boolean):void { _visible = value; }
		protected var _visible:Boolean = true;
		
		public function get alpha():Number{ return _alpha; }
		public function set alpha(value:Number):void { _alpha = value; }
		protected var _alpha:Number = 1;
		
		public function get blendMode():String { return _blendMode; }
		public function set blendMode(value:String):void  { _blendMode = value; }
		protected var _blendMode:String = "normal";
		
		public function get color():uint { return _color; }
		public function set color(value:uint):void { _color = value; }
		protected var _color:uint = 0xffffff;
		
		public function get compAbove():Boolean{ return _compAbove; }
		public function set compAbove(value:Boolean):void { _compAbove = value; }
		protected var _compAbove:Boolean = true;
		
		/** The view can be a class, a string to a file, or a display object. It must be supported by the view you target. */
		public function get view():GameArt{ return _view; }
		public function set view(value:GameArt):void {
			if (!value)
				removeView();
			_view = value; 
		}
		protected var _view:GameArt = null;
		
		public function get animation():String { return _animation; }
		public function set animation(value:String):void { _animation = value; }
		protected var _animation:String = "";
		
		/** Used to invert the view on the y-axis, number of animations friendly! */
		public function get inverted():Boolean{ return _inverted;}
		public function set inverted(value:Boolean):void { _inverted = value; }
		protected var _inverted:Boolean = false;
		
		public function get registration():String { return _registration; }
		public function set registration(value:String):void { _registration = value; }
		protected var _registration:String = "center";
		
		public function get offsetX():Number{ return _offsetX; }
		public function set offsetX(value:Number):void { _offsetX = value; }
		protected var _offsetX:Number = 0;
		
		public function get offsetY():Number { return _offsetY; }
		public function set offsetY(value:Number):void{ _offsetY = value; }
		protected var _offsetY:Number = 0;
		
		public function get offsetZ():Number { return 0; }
		
		public function get scaleOffsetX():Number { return _scaleOffsetX; }
		public function set scaleOffsetX(value:Number):void { _scaleOffsetX = value; }
		protected var _scaleOffsetX:Number = 1;
		
		public function get scaleOffsetY():Number { return _scaleOffsetY; }
		public function set scaleOffsetY(value:Number):void{ _scaleOffsetY = value;}
		protected var _scaleOffsetY:Number = 1;
		
		public function get scaleOffsetZ():Number { return 1; }
		
		public function get rotationOffset():Number{ return _rotationOffset; }
		public function set rotationOffset(value:Number):void{ _rotationOffset = value; }
		protected var _rotationOffset:Number = 0;
		
		public function get lockX():Boolean { return _lockX; }
		public function set lockX(value:Boolean):void { _lockX = value; }
		protected var _lockX:Boolean = false;
		
		public function get lockY():Boolean { return _lockY; }
		public function set lockY(value:Boolean):void { _lockY = value; }
		protected var _lockY:Boolean = false;
		
		public function get lockScales():Boolean { return _lockScales; }
		public function set lockScales(value:Boolean):void { _lockScales = value; }
		protected var _lockScales:Boolean = false;
		
		public function get lockRotation():Boolean { return _lockRotation; }
		public function set lockRotation(value:Boolean):void { _lockRotation = value; }
		protected var _lockRotation:Boolean = false;
	}
}