package SephiusEngine.displayObjects.gameArtContainers {
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.gameStates.LevelManager;
	import SephiusEngine.displayObjects.AnimationPack;
	import SephiusEngine.displayObjects.GameArtContainer;
	import SephiusEngine.math.MathUtils;

	import org.osflash.signals.Signal;

	import starling.display.DisplayObject;
	import starling.display.Image;
	
	/**
	 * Contain a groups of sprite sheet animations inside. Used for level special effects like Auroras, rains and mysts.
	 * @author Fernando Rabello
	 */
	public class AnimationContainer extends GameArtContainer {
		/** Store all animations inside this object */
		public var animatedObjects:Vector.<AnimationPack> = new Vector.<AnimationPack>();
		
		/** All static objects (alternative) */
		public var staticObjects:Vector.<Image> = new Vector.<Image>();
		
		public var onAddChild:Signal;
		
		private var _id:String;
		public function get id():String {return _id;}
		public function set id(value:String):void {
			if (LevelManager.getInstance().levelRegion.areas[value].effects.indexOf(this) > -1)
				LevelManager.getInstance().levelRegion.areas[value].effects.splice(LevelManager.getInstance().levelRegion.areas[value].effects.indexOf(this), 1);
			_id = value;
			if (int(_id) > -1)
				LevelManager.getInstance().levelRegion.areas[_id].effects.push(this);
		}
		
		private static var _useAnimations:Boolean = true;
		
		private var _enabled:Boolean = false;
		
		public function AnimationContainer(name:String, areaID:int = -1) {
			onAddChild = new Signal(DisplayObject);
			super();
			this.name = name;
			this.id = String(areaID);
			
			mainChild = this;
		}
		
		public function get enabled():Boolean { return _enabled;}
		public function set enabled(value:Boolean):void {
			if (value == _enabled)
				return;
			
			_enabled = value;
			/*
			if (value) {
				changeAnimation("Loop");
				visible = true;
			}
			else {
				changeAnimation("");
				visible = false;
			}*/
		}
		
		/**
		 * Add main animation to SpellView
		 * @param	objectBaseName name of the pack of textures this object use
		 * @param	callback function witch will be called when the animation is ready
		 * @param	animFps frames per second animation play
		 * @param	smoothing bilinear etc.
		 * @param	singleAnimation is this animation has only 1 animation and should be played automatcly
		 */
		public function addAnimation(objectBaseName:String, callback:Function, animFps:Number = 30, smoothing:String = "bilinear", params:Object = null, originalAlpha:Number=1):AnimationPack {
			animatedObjects.push(new AnimationPack(objectBaseName, [addLayer, callback], animFps, smoothing, false, "all", originalAlpha, true, false));
			texturePacksUsed.push(objectBaseName);
			
			if(params)
				setParams(animatedObjects[animatedObjects.length - 1], params);
			
			return animatedObjects[animatedObjects.length -1];
		}
		
		/** Same as addAnimation but use a pré-created spritesheet animation */
		public function addAnimation2(object:AnimationPack):void {
			animatedObjects.push(object);
			addLayer(object);
		}
		
		/** Initial textures witch state need to load to be ready to run. 
		 * onReady can dispach if this packs does not gets loaded */
		public var texturePacksUsed:Vector.<String> = new Vector.<String>();
		private var texturePack:String;
		
		override public function activate():void {
			super.activate();
			
			if(!activated){
				for each (texturePack in texturePacksUsed) {
					GameEngine.assets.checkInTexturePack(texturePack, null, "EffectArt_" + texturePack );
				}
			}
		}
		
		override public function deactivate():void {
			super.deactivate();
			
			if(activated){
				for each (texturePack in texturePacksUsed) {
					GameEngine.assets.checkOutTexturePack(texturePack, "EffectArt_" + texturePack );
				}
			}
		}
		/**
		 * Add a image to the character view, with no animation
		 * @param	textureName texture name already loaded on the GameEngine.assets
		 * @param	width put -1 to maintain the texture own size or put a size you want
		 * @param	height -1 to maintain the texture own size or put a size you want
		 * @param	alpha image alpha
		 * @param	blendMode image blend mode
		 * @param	compAbove if image should be added above or below other childs
		 */
		public function addStaticArt(textureName:String = "", width:Number = -1, height:Number = -1, alpha:Number = 1, blendMode:String = "normal", compAbove:Boolean = true, params:Object = null):void {
			staticObjects.push(new Image(GameEngine.assets.getTexture(textureName)));
			staticObjects[staticObjects.length - 1].alignPivot();
			
			if (width > 0) 
				staticObjects[staticObjects.length - 1].width = width;
			if (height > 0) 
				staticObjects[staticObjects.length - 1].height = height;
			
			staticObjects[staticObjects.length - 1].blendMode = blendMode;
			
			if(_useAnimations)
				addLayer(staticObjects[staticObjects.length - 1], compAbove);
			
			setParams(staticObjects[staticObjects.length - 1], params);
		}
		
		/** Add a display object as child of the effect view. This class automaticly call this function when a display object art is loaded */
		protected function addLayer(displayObject:DisplayObject, compAbove:Boolean = true):void {
			if (displayObject as AnimationPack)
				(displayObject as AnimationPack).onReady.remove(addLayer);
			
			//trace("[SPECIAL EFFECT VIEW] Adding " + displayObject.name + " to " + this.name);
			
			if(!compAbove)
				addChildAt(displayObject, 0);
			else
				addChild(displayObject);
			
			if(_enabled && displayObject as AnimationPack){
				(displayObject as AnimationPack).changeAnimation("Loop");
				(displayObject as AnimationPack).currentFrame = MathUtils.randomInt(0, (displayObject as AnimationPack).numFrames -1);
			}
		}
		
		public function setParams(object:DisplayObject, params:Object):void{
			for (var param:String in params)
				object[param] = params[param];
		}
		
		override public function addChild(child:DisplayObject):DisplayObject {
			super.addChild(child);
			onAddChild.dispatch(child);
			return child;
		}
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
			super.addChildAt(child, index);
			onAddChild.dispatch(child);
			return child;
		}
		
		/** Change animation of the character view. Automatcly change all child animation who need to match animation with its parent*/
		public function changeAnimation(animation:String):void {
			var animationObject:AnimationPack;
			for each (animationObject in animatedObjects) {
				if(animationObject.isReady){
					animationObject.changeAnimation(animation);
					if (animation != "")
						animationObject.currentFrame = MathUtils.randomInt(0, animationObject.numFrames -1);
				}
			}
		}
		
		override public function dispose():void {
			if(parent)
				removeFromParent();
			
			for each(var animation:DisplayObject in animatedObjects){
				animation.dispose();
				animation = null;
			}
			
			for each(var staticObject:DisplayObject in staticObjects){
				staticObject.dispose();
				staticObject = null;
			}
			
			onAddChild.removeAll();
			
			super.dispose();
		}
		
		/** Determines if game will use static arts or animations. */
		public function get useAnimations():Boolean {return _useAnimations;}
		public function set useAnimations(value:Boolean):void {
			if (!value) {
				var animationObject:AnimationPack;
				var staticObject:Image;
				for each (animationObject in animatedObjects) {
					animationObject.changeAnimation("");
				}
				for each (staticObject in staticObject) {
					staticObject.visible = true;
				}
				
			}
			else {
				for each (animationObject in animatedObjects) {
					animationObject.changeAnimation("Loop");
					animationObject.currentFrame = MathUtils.randomInt(0, animationObject.numFrames -1)
				}
				for each (staticObject in staticObject) {
					staticObject.visible = true;
				}
				
			}
			_useAnimations = value;
		}
		
	}
}