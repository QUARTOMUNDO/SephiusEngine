package SephiusEngine.levelObjects.effects 
{
	import SephiusEngine.core.GameAssets;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.levelObjects.GameSprite;
	import SephiusEngine.levelObjects.interfaces.ISpriteView;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	
	/**
	 * Extention of sptire with some other features like blending modes, easy alpha control and etc.
	 * Special Sprites has no animations and its textures are loaded when game start. So there is no need to inform texture path or load then before create this object.
	 * If have a parent, Special Sprite will fallow it using offsets into account.
	 * @author Fernando Rabello.
	 */
	public class SpecialSprite extends GameSprite 
	{
		/** Special Sprite will fallow it´s parent if it has one */
		protected var _parent:ISpriteView;
		
		/** Name of texture this Special Sprite should use */
		public var textureName:String;
		
		/** Art visualization. It could be a Animation Effect or a Image */
		public var spriteArt:DisplayObject;
		
		/** If true Special Sprite will stay on its parent position */
		public var linkPosition:Boolean = true;
		
		/** If true Special Sprite will rotate with its parent */
		public var linkRotation:Boolean = false;
		
		/** If true Special Sprite will scale with its parent */
		public var linkScale:Boolean = false;
		
		/** If true Special Sprite will invert with its parent */
		public var linkInvertion:Boolean = false;
		
		/** If true Special Sprite will invert with its parent */
		public var linkAlpha:Boolean = false;
		
		/** If true Special Sprite will invert with its parent */
		public var linkBlendMode:Boolean = false;
		
		/** If true Special Sprite will invert with its parent */
		public var linkCompMode:Boolean = false;
		
		/** If true Special Sprite will invert with its parent */
		public var linkGroup:Boolean = true;
		
		/** If true Special Sprite will invert with its parent */
		public var linkAnimations:Boolean = false;
		
		/** If true Special Sprite will invert with its parent */
		public var linkVisible:Boolean = false;
		
		/** If sprite should appear above or below its parent */
		public var compositionMode:String = "above";
		
		/** Position relative to original x witch this sprite will be displaced from. 
		 * This is diferent from offset cause will actually change the position of the object, not only its art.
		 * Offset also impact on sprite pivot position, so if you don´t want that use displacement instead*/
		public var displacementX:Number  = 0;
		
		/** Position relative to original y witch this sprite will be displaced from. 
		 * This is diferent from offset cause will actually change the position of the object, not only its art.
		 * Offset also impact on sprite pivot position, so if you don´t want that use displacement instead*/
		public var displacementY:Number  = 0;
		
		/** Position where this object was created or the last position of the object parent */
		private var referencialPositionX:Number = 0;
		
		/** Position where this object was created or the last position of the object parent */
		private var referencialPositionY:Number = 0;
		
		public var assets:GameAssets;
		
		/**
		 * @param	name Name of this object
		 * @param	textureName A valid name of a texture witch was loaded by asset manager when game start
		 * @param	parent If exist the sprite will fallow its parent
		 * @param	transformParams {rotate, scale, positionOffset, rotationOffset, scaleOffset}
		 * @param   compositionMode Tell if Sprite should appear above or behind the parent (if it has one).
		 * @param	objectParams SephiusEngine Object params
		 */
		public function SpecialSprite(name:String, params:Object = null)	{
			this.name = name;
			if (!params)
				params = {};
			
			params.registration = "center";
			
			super(name, params);
			
			if (!assets)	
				assets = GameEngine.assets;
			
			if (parent && linkPosition) {
				this.x = parent.x;
				this.y = parent.y;
			}
			
			referencialPositionX = this.x;
			referencialPositionY = this.y;
			
			this.x += displacementX;
			this.y += displacementY;
			
			loadInitAndAdd();
		}
		
		override public function update(timeDelta:Number):void {
			if (parent) {
				if (linkPosition) {
					referencialPositionX = _parent.x;
					referencialPositionY = _parent.y;
				}
				
				x = referencialPositionX + displacementX; 
				y = referencialPositionY + displacementY;
				
				if (linkAlpha)
					alpha = _parent.alpha;
				
				if (linkBlendMode)
					blendMode = _parent.blendMode;
					
				if (linkCompMode)
					compAbove = _parent.compAbove;
				
				if (linkGroup)
					group = _parent.group + (compositionMode == "above" ? 1 : compositionMode == "superAbove" ? 4 : -1);
				
				if (linkVisible)
					visible = _parent.visible;
					
				if (linkScale){
					scaleX = _parent.scaleX;
					scaleY = _parent.scaleY;
				}
				
				if (linkRotation)
					rotation = _parent.rotation;
					
				if (linkInvertion)
					inverted = _parent.inverted;
			}
		}
		
		/**
		 * This function load, initialize and add the character to stage
		 * Verify if the character texture was already loaded, if not, enqueue the textures. 
		 * If textures are being loaded when it happens it just add onArtLoaded function as progress function for asset manager. 
		 */
		public function loadInitAndAdd():void {
			if(textureName){
				spriteArt = new Image(assets.getTexture(textureName));
				spriteArt.alignPivot();
				view.content = (spriteArt as Image);
			}
			else{
				spriteArt = new Sprite();
				view.content = (spriteArt as Sprite);
			}
			
			if (_parent){
				updateCallEnabled = true;	
				
				if (linkPosition) {
					referencialPositionX = _parent.x;
					referencialPositionY = _parent.y;
				}
				
				x = referencialPositionX + displacementX; 
				y = referencialPositionY + displacementY;
				
				if (linkAlpha)
					alpha = _parent.alpha;
				
				if (linkBlendMode)
					blendMode = _parent.blendMode;
					
				if (linkCompMode)
					compAbove = _parent.compAbove;
				
				if (linkGroup)
					group = _parent.group + (compositionMode == "above" ? 1 : compositionMode == "superAbove" ? 4 : -1);
				
				if (linkVisible)
					visible = _parent.visible;
					
				if (linkScale){
					scaleX = _parent.scaleX;
					scaleY = _parent.scaleY;
				}
				
				if (linkRotation)
					rotation = _parent.rotation;
					
				if (linkInvertion)
					inverted = _parent.inverted;
			}
		}
		
		override public function set animation(value:String):void {
			_animation = value;
			onAnimationChange.dispatch(value);
		}
		
		public function removeParent(parent:ISpriteView):void {
			_parent.onDestroyed.remove(removeParent);
			_parent = null;
		}
		
		public function get parent():ISpriteView {
			return _parent;
		}
		
		public function set parent(value:ISpriteView):void {
			if (!value)
				return;
			
			if (_parent) {
				_parent.onDestroyed.remove(removeParent);
				_parent = null;
			}
			
			if(value){
				_parent = value;
				_parent.onDestroyed.addOnce(removeParent);
			}
			
			if (linkPosition) {
				referencialPositionX = _parent.x;
				referencialPositionY = _parent.y;
			}
			
			if (linkAlpha)
				alpha = _parent.alpha;
			
			if (linkBlendMode)
				blendMode = _parent.blendMode;
				
			if (linkCompMode)
				compAbove = _parent.compAbove;
			
			if (linkGroup)
				group = _parent.group + (compositionMode == "above" ? 1 : compositionMode == "superAbove" ? 4 : -1);
			
			if (linkVisible)
				visible = _parent.visible;
				
			if (linkScale){
				scaleX = _parent.scaleX;
				scaleY = _parent.scaleY;
			}
			
			if (linkRotation)
				rotation = _parent.rotation;
				
			if (linkInvertion)
				inverted = _parent.inverted;
		}
		
		override public function destroy():void {
			//trace("destoying", spriteArt.parent.name);
			if (!spriteArt)
				throw Error(this.name + " sprites does not exist. Why?");
			//if(spriteArt){
				//spriteArt.dispose();
				//spriteArt = null;
			//}
			super.destroy();
			onAnimationChange.removeAll();
			updateCallEnabled = false;	
			//Main.getInstance().state.remove(this);
		}
	}

}