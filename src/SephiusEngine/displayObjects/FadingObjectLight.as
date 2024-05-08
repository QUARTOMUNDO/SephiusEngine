package SephiusEngine.displayObjects {
	import SephiusEngine.displayObjects.ObjectLight;
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	import starling.display.BlendMode;
	/**
	 * Its a Object Light witch automaticly fades and move for some thime
	 * Is not a permante object. It auto destroy itself after some time.
	 * @author Fernando Rabello
	 */
	public class FadingObjectLight extends ObjectLight {
		/** Time in seconds this light will last not caunting fade time. */
		private var duration:Number = 1;
		
		/** Time light will appear and disappear */
		private var fadeTime:Number = 1;
		
		/** The displacement where this splash should go from where it is create */
		private var dislocation:Number = 0;
		/** On witch direction light will go relative with light parents */
		private var dislocationAngle:Number = 0;
		
		public function FadingObjectLight(textureName:String, radius:uint=100, color:uint=0xfffffff, brightness:Number=1, duration:Number=2, fadeTime:Number=.5, dislocation:int=100, dislocationAngle:Number=0, params:Object=null) {
			super(textureName, radius, color, brightness, params);
			
			this.duration = duration;
			this.fadeTime = fadeTime;
			this.x = params.x;
			this.x -= dislocation * .5;
			this.y = params.y;
			this.dislocation = dislocation;
			this.dislocationAngle = dislocationAngle;
			
			//this.radius = 10;
			
			blendMode = BlendMode.SCREEN;
			
			TweenMax.fromTo(this, fadeTime, { brightness:0 }, { brightness:1, yoyo:true, repeat:1, repeatDelay:duration-fadeTime*2, onUpdate:update, ease:Linear.easeNone } );
			TweenMax.to(this, duration + fadeTime, { x:Math.cos(dislocationAngle)*dislocation, y:Math.sin(dislocationAngle)*dislocation + this.y  } );
		}
		
		public function resetLight(radius:uint=100, color:uint=0xfffffff, brightness:Number=1, duration:Number=2, fadeTime:Number=1, dislocation:int=100, dislocationAngle:Number=0, isErratic:String="none"):void {
			TweenMax.killTweensOf(this);
			
			this.duration = duration;
			this.fadeTime = fadeTime;
			
			this.isErratic = isErratic;
			this.color = color;
			
			TweenMax.to(this, fadeTime, { brightness:brightness, hexColors:{ color:color } , onUpdate:update, ease:Linear.easeNone } );
			TweenMax.to(this, fadeTime, { brightness:0, delay:duration - fadeTime, onUpdate:update, ease:Linear.easeNone } );
			
			//TweenMax.to(this, duration + fadeTime, { x:Math.cos(dislocationAngle)*dislocation, y:Math.sin(dislocationAngle)*dislocation + this.y  } );
		}
		
		public function update():void {
			//trace(brightness);
		}
		
		override public function dispose():void {
			TweenMax.killTweensOf(this);
			super.dispose();
		}
	}

}