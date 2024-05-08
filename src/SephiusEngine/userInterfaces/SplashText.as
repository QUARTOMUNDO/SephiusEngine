package SephiusEngine.userInterfaces {
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.levelObjects.GameSprite;
	import tLotDClassic.gameObjects.characters.Creatures;
	import SephiusEngine.displayObjects.configs.AssetsConfigs;
	import SephiusEngine.utils.pools.SplashTextPool;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Bounce;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	
	/**
	 * This object shows some text above the character with a animation
	 * @author Fernando Rabello
	 */
	public class SplashText extends GameSprite
	{
		private var container:Sprite = new Sprite();
		private var art:Image;
		private var art2:Image;
		private var art3:Image;
		private var art4:Image;
		private var parent: Object;
		private var damageText:TextField = new TextField(500, 50, "", "ChristianaWhite", 16, 0x000000, true);
		
		public static var currentSplashText:SplashText;
		public static var currentParam:String;
		
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
		
		/** If true Special Sprite will stay on its parent position */
		public var linkPosition:Boolean = false;
		/**
		 * Constructor
		 * @param	name The name of the object
		 * @param	parent The  object that the DamageText will be fallow
		 * @param	text The amount of damage that the text will show
		 * @param	textType If the damage is classified as "strong", "normal", "powerful", "critical", "absorption" , among others
		 * @param	params Information used by Main, location, name, art, among other
		 */
		public function SplashText(name: String, params: Object = null) {
			group = AssetsConfigs.INTERFACES_ASSETS_GROUP;
			//name = name + "-" + MathUtils.randomInt(1, 1000);
			
			super(name, params);
			
			//registration = "center";
			
			updateCallEnabled = true;
			
			art = new Image(GameEngine.assets.getTexture("Hud_DarkSmallHigh"));
			art.alignPivot();
			//art2 = new Image(GameEngine.assets.getTexture("Hud_DarkSmallHigh"));
			//art2.alignPivot();
			//art3 = new Image(GameEngine.assets.getTexture("Hud_DarkSmallHigh"));
			//art3.alignPivot();
			//art4 = new Image(GameEngine.assets.getTexture("Hud_DarkSmallHigh"));
			//art4.alignPivot();
			
			damageText.hAlign = "center";
			damageText.alignPivot();
			
			container.addChild(art);
			//container.addChild(art2);
			//container.addChild(art3);
			//container.addChild(art4);
			container.addChild(damageText);
			view.content = container;
		}
		
		public static function showSplashText (parent:Object, value:Number, textType:String, params: Object = null, inSansico:Boolean = false):void {
			currentSplashText = SplashTextPool.getObject();
			currentSplashText.init(parent, value, textType, params, inSansico);
			GameEngine.instance.state.add(currentSplashText);
		}
		
		public function init(parent:Object, value:Number, textType:String, params: Object = null, inSansico:Boolean = false):void {
			view.content = container;
			damageText.text = value.toFixed(0);
			art.scaleX = damageText.text.length * .6;
			
			if (value < 0)
				damageText.color = 0xff66ff;
			else if (textType == "critical" || textType == "powerfull") 
				damageText.color = 0xffffff;
			else if (parent as Creatures)
				damageText.color = 0xdddddd;
			else
				damageText.color = 0xffff66;
				
			//damageText.color = (textType == "critical" || textType == "powerfull") ? 0xffff66 :  ? 0xff66ff : 0xffffff;
			
			if (inSansico) {
				damageText.fontName =  _lm.worldNature == "Dark" ? "ChristianaWhite" : "ChristianaWhite";
				art.texture = _lm.worldNature == "Dark" ? GameEngine.assets.getTexture("Hud_DarkSmallHigh") : GameEngine.assets.getTexture("Hud_LightSmallHigh");
				damageText.fontSize = 10;
			}
			else {
				damageText.fontName = "ChristianaWhite";
				art.texture = GameEngine.assets.getTexture("Hud_DarkSmallHigh");
				damageText.fontSize = 16;
			}
			
			this.parent = parent;
			
			for (currentParam in params){
				this[currentParam] = params[currentParam];
			}
			
			referencialPositionX = x;
			referencialPositionY = y;
			
			alpha = 1;
			
			TweenMax.to(this, .5, {startAt: { scaleY:6 }, scaleY:1, ease:Bounce.easeOut} );
			TweenMax.to(this,  !inSansico ? 2 : 4, { startAt: { displacementY:-30,  alpha:1 }, displacementY:-105, alpha:0, ease:Back.easeIn, onComplete:removeFromState} );
		}
		
         /* Update function
		 * @param	timeDelta This is a ratio explaining the amount of time that passed in relation to the amount of time that
		 * was supposed to pass. Multiply your stuff by this value to keep your speeds consistent no matter the frame rate. 		 
		 * */
		public override function update(timeDelta:Number):void {  
			if (parent && linkPosition) {
				x = parent.x + displacementX;
				y = parent.y + displacementY;
			}
			else {
				x = referencialPositionX + displacementX;
				y = referencialPositionY + displacementY;
			}
		}
		
		public function removeFromState():void {
			//(container.parent as StarlingArt).view = null;
			//container.removeFromParent();
			//view = null;
			GameEngine.instance.state.remove(this);
			SplashTextPool.returnObject(this);
		}
	}
}