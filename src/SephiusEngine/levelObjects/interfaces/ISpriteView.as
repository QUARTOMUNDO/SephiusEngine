package SephiusEngine.levelObjects.interfaces{
	import SephiusEngine.displayObjects.GameArt;
	import org.osflash.signals.Signal;
	import starling.display.DisplayObject;
	 /*** All objects that need to have graphical representations on screen need to implement this, if your
	 * objects are in a state that uses the SephiusView as its view (most common). Often, especially
	 * when working with Box2D, game object units will be different than than view object units.
	 * In Box2D, units are in meters, but graphics are rendered in pixels.
	 * Sephius Engine does not put a requirement on whether the game logic or the view manager should
	 * perform the conversion. 
	 * If you desire the game logic to perform the unit conversion, the values should be multiplied by
	 * [commonly] 30 before being returned in order to convert the meter values to pixel values.
	 */	
	public interface ISpriteView{	
		/** sprite name */
		function get spriteName():String;
		
		/** The x position of the object. */	
		function get x():Number;
		
		/** The y position of the object. */
		function get y():Number;
		
		/** The z position of the object. */
		function get z():Number;
		
		/** The width of the object. */
		function get width():Number;
		
		/** The height of the object. */
		function get height():Number;
		
		/** The depth of the object (used for 3D content). */
		function get depth():Number;
		
		/** Objec scalleX (this should scale physic body?) */
		function get scaleX():Number;
		
		/** Object scalleY (this should scale physic body?) */
		function get scaleY():Number;
		
		/** Object scalleZ (this should scale physic body?) */
		function get scaleZ():Number;
		
		/**
		 * The rotation value of the object.
		 * <p>Commonly, flash uses degrees to display art rotation, but game logic is usually in radians.
		 * If a conversion is necessary and you choose the game object to perform the conversion rather than
		 * the view manager, then you will want to perform your conversion here.</p>
		 */
		function get rotation():Number;
		
		function get rotationRad():Number;
		
		/** The ratio at which the object scrolls in relation to the camera. */
		function get parallax():Number;
		
		/**
		 * The group property specifies the depth sorting. Objects placed in group 1 will be behind objects placed in group 2.
		 * Note that groups and parallax are unrelated, so be careful not to have an object have a lower parallax value than an object 
		 * in a group below it.
		 */
		function get group():uint;
		
		function get updateGroup():Boolean;
		function set updateGroup(value:Boolean):void;
		
		/** The visibility of the object.  */
		function get visible():Boolean;
		
		/** Sprite alpha */
		function get alpha():Number;
		
		/** Blend mode composition */
		function get blendMode():String;
		
		/** Texture multiply color */
		function get color():uint;
		
		/** Tell the sprite should be added to view ate below or above other elements */
		function get compAbove():Boolean;
		
		/**
		 * This is where you specify what your graphical representation of your SephiusObject will be.
		 * 
		 * <p>You can specify your <code>view</code> value in multiple ways:</p>
		 * 
		 * <p>If you want your graphic to be a SWF, PNG, or JPG that
		 * is loaded at runtime, then assign <code>view</code> a String URL relative to your game's SWF, just like you would
		 * if you were loading any file in Flash. (graphic = "graphics/Hero.swf")</p>
		 * 
		 * <p>If your graphic is embedded into the SWF, you can assign the <code>view</code> property in two ways: Either by package SephiusEngine.levelObjects.interfaces string
		 * notation (view = "com.myGame.MyHero"), or by using a direct class reference (graphic = MyHero). The first method, String notation, is useful
		 * when you are using a level editor such as the Flash IDE or GLEED2D because all data must come through in String form. However, if you
		 * are hardcoding your graphic class, you can simply pass a direct reference to the class.
		 * Whichever way you specify your class, your class must be (on some level) a <code>DisplayObject</code>.</p>
		 * 
		 * <p>You can specify your <code>view</code> as an instance of a display object depending of your view renderer.</p>
		 * 
		 * <p>If you are using a level editor and using the ObjectMaker to batch-create your
		 * SephiusObjects, you will need to specify the entire classpath in string form and let the factory turn your string
		 * into an actual class. Also, the class definition (MyHeroGraphic, for example) will need to be compiled into your code
		 * somewhere, otherwise the game will not be able to get the class definition from a String.</p>
		 * 
		 * <p>If your graphic is an external file such as a PNG, JPG, or SWF, you can provide the path to the file (either an absolute path,
		 * or a relative path from your HTML file or SWF). The SpriteView will detect that it is an external file and
		 * load the file using the LoadManager class.</p>
		 */
		function get view():GameArt;
		
		/**
		 * A string representing the current animation state that your object is in, such as "run", "jump", "attack", etc.
		 * The SpriteView checks this property every frame and, if your graphic is a SWF, attempts to "gotoAndPlay()" to a
		 * label with the name of the <code>animation</code> property.
		 * 
		 * If you want your graphic to not loop, you should call stop() on the last frame of your animation from within your SWF file.
		 */
		function get animation():String;
		
		/**
		 * If true, the view will invert your graphic. This is common in side-scrolling games so that you don't have to draw
		 * right-facing and left-facing versions of all your graphics. If you are using the inverted property to invert your
		 * graphics, make sure you set your registration to "center" or the graphic will flip like a page turning instead of a card
		 * flipping. 
		 */
		function get inverted():Boolean;
		
		/**
		 * Specify either "topLeft" or "center" to position your graphic's registration. Please note that this is
		 * only useful for graphics that are loaded dynamically at runtime (PNGs, SWFs, and JPGs). If you are embedding
		 * your art, you should handle the registration in your embedded class.
		 */
		function get registration():String;
		
		/** The x offset from the graphic's registration point. */
		function get offsetX():Number;
		
		/** The y offset from the graphic's registration point.*/
		function get offsetY():Number;
		
		/** The Z offset from the graphic's registration point.*/
		function get offsetZ():Number;
		
		/** Affect the sprite scale */
		function get scaleOffsetX():Number;
		
		/** Affect the sprite scale */
		function get scaleOffsetY():Number;
		
		/** Affect the sprite scale */
		function get scaleOffsetZ():Number;
		
		/** The rotation offset from the graphic's registration point. */
		function get rotationOffset():Number;
		
		/** Create GameArt container */
		function createView():GameArt;
		
		/** Destroys GameArt Container */
		function destroyView():void
		
		/** If GameArt was added to the state */
		function get viewAdded():Boolean;
		
		/** adds visual representation to objects */
		function addView():void;
		
		/** removes visual representation from objects */
		function removeView():void;
		
		/** Lock art on the X axis. This mean it will not move related with camera on this axis */
		function get lockX():Boolean;
		
		/** Lock art on the Y axis. This mean it will not move related with camera on this axis */
		function get lockY():Boolean;
		
		/** Lock art scales. This mean it will not scale related with camera distance */
		function get lockScales():Boolean;
		
		/** Lock art rotation. This mean it will not rotate related with camera rotation 
		 * or it will rotate on inverted angle to make it appear as it should be if camera is not rotated */
		function get lockRotation():Boolean;
		
		function get onDestroyed():Signal;
	}
}