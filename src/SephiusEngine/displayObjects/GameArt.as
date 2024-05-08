package SephiusEngine.displayObjects 
{
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.effects.ParticleManager;
	import SephiusEngine.displayObjects.AnimationPack;
	import SephiusEngine.displayObjects.GameArtContainer;
	import SephiusEngine.levelObjects.interfaces.ISpriteView;

	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.extensions.particles.PDParticleSystem;
	import starling.utils.deg2rad;
	import SephiusEngine.displayObjects.ViewObjects.ViewParallax;
	
	/**
	 * GameArt is a container witch holds displayObjects used as visual representation for game objects
	 * GameArt also has other properties who constantly match its parent game object like color, alpha, blend mode and etc
	 * All Game object witch has a visual representation need to have its own GameArt
	 * @author Fernando Rabello
	 */
	public class GameArt extends Sprite {
		public var gameObject:ISpriteView;
		
		private var _content:DisplayObject;
		public function get gameArtContainer():GameArtContainer { return _content as GameArtContainer; }
		public function get animationPackContent():AnimationPack { return _content as AnimationPack; }
		public function get viewParalaxContainer():ViewParallax {return parent as ViewParallax;}
		
		/** Alternative content acess to avoid function call */
		public var contentVar:DisplayObject;
		// The reference to your art via the view.
		public function get content():DisplayObject {return _content;}
		public function set content(value:DisplayObject):void {
			if (_content == value || !gameObject)
				return;
			
			if (_content){
				removeChild(content);
				
				if (content is MovieClip) 
					GameEngine.instance.state.gameJuggler.remove(content as MovieClip);
				else if (content is PDParticleSystem) {
					GameEngine.instance.state.gameJuggler.remove(content as PDParticleSystem);
					(content as PDParticleSystem).stop();
				} 
			}
			transformationMatrix
			_content = contentVar = value;
			
			if (!_content)
				return;
			
			contentWidth = _content.width;
			contentHeight = _content.height;
			
			moveRegistrationPoint(gameObject.registration);
			addChild(content);
			
			if(activated){
				if (_content is MovieClip)
					GameEngine.instance.state.gameJuggler.add(content as MovieClip);
				else if (_content is PDParticleSystem)
					GameEngine.instance.state.gameJuggler.add(content as PDParticleSystem);
				else if(animationPackContent)
					animationPackContent.activate();
				else if(gameArtContainer)
					gameArtContainer.activate();
			}
			
			if(gameObject.viewAdded){
				GameEngine.instance.state.view.updateArtNewState(this);
				GameEngine.instance.state.view.updateArtOldState(this);
				GameEngine.instance.state.view.smoothArtState(this, .5, .5);
			}
		}
		
		/** Pass the name of a function inside a content object in order to get that update function called every frame */
		private var contentUpdateFunction:String = "";
		public var needSmoothContainerState:Boolean = false;
		
		public var group:uint;
		public var compAbove:Boolean = true;
		public var originalScaleY:Number = 1;
		public var originalScaleX:Number = 1;
		public var finalParallax:Number = 1;
		public var parallax:Number = 1;
		public var dephFactor:Number = 1;
		private var _color:uint = 0xffffff;
		public function get color():uint {return _color;}
		public function set color(value:uint):void {
			_color = value;
			
			if (_content && _content.hasOwnProperty("color"))
				(_content as Object).color = _color;
		}
		
		/** Locks */
		/** Lock art on the X axis. This mean it will not move related with camera on this axis */
		public var lockX:Boolean = false;
		/** Lock art on the Y axis. This mean it will not move related with camera on this axis */
		public var lockY:Boolean = false;
		/** Lock art scales. This mean it will not scale related with camera distance */
		public var lockScales:Boolean = false;
		/** Lock art rotation. This mean it will not rotate related with camera rotation 
		 * or it will rotate on inverted angle to make it appear as it should be if camera is not rotated */
		public var lockRotation:Boolean = false;
		
		private var _registration:String;
		
		public function get registration():String {return _registration;}
		public function set registration(value:String):void {
			if (_registration == value || !content)
				return;
			_registration = value;
			moveRegistrationPoint(_registration);
		}
		
		private var indexOf:int;
		public function get updateState():Boolean {return _updateState; }
		public function set updateState(value:Boolean):void {
			if (_updateState == value)
				return;
			
			_updateState = value;
			
			if (gameObject.viewAdded){
				indexOf = GameEngine.instance.state.view.viewObjectsToUpdate.indexOf(this);
				
				if (!value && indexOf != -1)
					GameEngine.instance.state.view.viewObjectsToUpdate.splice(indexOf, 1);
				else if(indexOf == -1)
					GameEngine.instance.state.view.viewObjectsToUpdate.push(this);
			}
		}
		private var _updateState:Boolean = true;
		
		public var updateStateOnce:Boolean;
		
		public var contentWidth:Number = 1;
		public var contentHeight:Number = 1;
		
		/** ------------------------------------------ */
		/** ----- Old state for interpolation ----- */
		/** ------------------------------------------ */
		/** Position object was at last physic step */
		public var px:Number = 0;
		/** Position object was at last physic step */
		public var py:Number = 0;
		/** rotation object was at last physic step */
		public var pRotation:Number = 0;
		/** scaleX object was at last physic step */
		public var pScaleX:Number = 1;
		/** scaleY object was at last physic step */
		public var pScaleY:Number = 1;
		/** originalScaleX object was at last physic step */
		public var pOriginalScaleX:Number = 1;
		/** originalScaleY object was at last physic step */
		public var pOriginalScaleY:Number = 1;
		/** alpha object was at last physic step */
		public var pAlpha:Number = 1;
		
		/** ------------------------------------------ */
		/** ----- New state for interpolation ----- */
		/** ------------------------------------------ */
		/** Position object was at last physic step */
		public var nx:Number = 0;
		/** Position object was at last physic step */
		public var ny:Number = 0;
		/** rotation object was at last physic step */
		public var nRotation:Number = 0;
		/** scaleX object was at last physic step */
		public var nScaleX:Number = 1;
		/** scaleY object was at last physic step */
		public var nScaleY:Number = 1;
		/** originalScaleX object was at last physic step */
		public var nOriginalScaleX:Number = 1;
		/** originalScaleY object was at last physic step */
		public var nOriginalScaleY:Number = 1;
		/** alpha object was at last physic step */
		public var nAlpha:Number = 1;
		
		private var center:Image;
		public static var DEBUG:Boolean = false;
		
		public function GameArt(gameObject:ISpriteView) {
			super();
			if (!gameObject)
				throw Error("SephiusEngine Object is null or does not implements ISpriteView");
			
			this.gameObject = gameObject;
			
			if (DEBUG){
				center = new Image(GameEngine.assets.getTexture("Debug_box"));
				center.alignPivot();
				center.scaleX = center.scaleY = .2;
				center.color = 0xA80061;
				addChild(center);
			}
			
			//content = gameObject.view;
			name = gameObject.spriteName;
			
			x = px = nx = gameObject.x;
			y = py = ny = gameObject.y;
			rotation = pRotation = deg2rad(gameObject.rotation);
			originalScaleX = pOriginalScaleX = nScaleX = gameObject.scaleX;
			originalScaleY = pOriginalScaleY = nScaleY = gameObject.scaleY;
			alpha = pAlpha = gameObject.alpha;
			
			lockX = gameObject.lockX;
			lockY = gameObject.lockY;
			lockRotation = gameObject.lockRotation;
			lockScales = gameObject.lockScales;
			
			pScaleX = scaleX;
			pScaleY = scaleY;
			
			blendMode = gameObject.blendMode;
			compAbove = gameObject.compAbove;
			group = gameObject.group;
			visible = gameObject.visible;
			registration = gameObject.registration;
			
			touchable = false;
		}
		
		/** Update art state avoiding smooth transition between frames. This avoid some glitches when objects change behavir to quickly and view can't keep up */
		public function updateViewState():void{
			GameEngine.instance.state.view.updateArtNewState(this);
			GameEngine.instance.state.view.updateArtOldState(this);
		}

		override public function addChild(child:DisplayObject):DisplayObject {
			super.addChild(child);
			if (DEBUG)
				setChildIndex(center, numChildren);
			return child;
		}
		
		/** Definie initial state for a Game art */
		public function initialize(object:ISpriteView):void {
			gameObject = object;
		}
		
		public var activated:Boolean;
		public function activate():void {
			if(!activated){
				activated = true;
				if (gameArtContainer) {
					gameArtContainer.activate();
					//trace("GACONT activated: ", name, gameArtContainer.name);
				}
				if (animationPackContent) {
					animationPackContent.activate();
					//trace("GACONT activated: ", name, atlasAnimationContent.name);
				}
			}
		}
		
		public function deactivate():void {
			if(activated){
				activated = false;
				if (gameArtContainer) {
					gameArtContainer.deactivate();
					//trace("GACONT activated: ", name, gameArtContainer.name);
				}
				if (animationPackContent) {
					animationPackContent.deactivate();
					//trace("GACONT activated: ", name, atlasAnimationContent.name);
				}
			}
		}
		
		/** Updates the content if it needs to be updated internally
		 * This updtate method has nothing to do with refash GameArt tansformations to mach camera and etc
		 */
		public function update(deltaTime:Number):void {
			if (contentUpdateFunction != "")
				_content[contentUpdateFunction]();
		}
		
		public function moveRegistrationPoint(registrationPoint:String):void {
			if(_content as DisplayObjectContainer){
				_content.pivotX = -gameObject.offsetX;
				_content.pivotY = -gameObject.offsetY;
			}
			else {
				_content.pivotX = -(gameObject.offsetX + (_content.width / 2));//Tying to fix offset for image objects
				_content.pivotY = -(gameObject.offsetY + (_content.height / 2));
			}
			
			_content.scaleX = gameObject.scaleOffsetX;
			_content.scaleY = gameObject.scaleOffsetY;
			_content.rotation = deg2rad(gameObject.rotationOffset);
			
			_registration = registrationPoint;
		}
		
		override public function dispose():void {
			if (gameObject as ParticleManager)
				return;
				
			super.dispose();
			
			removeChild(content);
			
			if (content is MovieClip) {
				GameEngine.instance.state.gameJuggler.remove(content as MovieClip);
			}
			else if (content is PDParticleSystem) {
				GameEngine.instance.state.gameJuggler.remove(content as PDParticleSystem);
				(content as PDParticleSystem).stop();
			} 
			gameObject = null;
			contentVar = _content = null
		}
	}
}