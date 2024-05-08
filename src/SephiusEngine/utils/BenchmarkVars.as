package SephiusEngine.utils
{
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.displayObjects.configs.TexturesCache;
	import SephiusEngine.assetManagers.TextureManager;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	public class BenchmarkVars extends Sprite
	{
		private static var staticVar : int = 0;
		private var instanceVar : int = 0;
		
		protected var _mcSequences:Dictionary = new Dictionary(true);
		
		private var ref : TextureManager = new TextureManager ();

		public function BenchmarkVars(){
			super();
			////////
			////////
			GameEngine.instance.addChild(this);
			
			this.x = 200;
			this.y = 200;
			
			var tf : TextField = new TextField ();
			tf.width = stage.stageWidth;
			tf.height = stage.stageHeight;
			tf.textColor = 0xffffff;
			tf.wordWrap = true;
			addChild ( tf );

			var trace : Function = function ( s : String ) : void
			{
				tf.appendText ( s + '\n' );
			}

			////////
			////////

			var time1 : Number,
				time2 : Number,
				i : int,
				n : int = 5000000;

			trace ( 'Each test is performed at ' + n + ' iterations.\n' );

			////////
			////////

			time1 = getTimer ();
			for ( i = 0; i < n; i ++ )
				instanceVar = instanceVar + 1;
			time1 = getTimer () - time1;

			trace ( 'Getting & setting a property of this object :\n    ' + time1 + ' millisec' );

			time2 = getTimer ();
			for ( i = 0; i < n; i ++ )
				staticVar = staticVar + 1;
			time2 = getTimer () - time2;

			trace ( 'Getting & setting a static property of this class :\n    ' + time2 + ' millisec' );

			trace ( 'Static access is slower by ' + int ( time2 / time1 * 100 - 99.5 ) + '%.\n' );

			////////
			////////
			/*
			time2 = getTimer ();
			for ( i = 0; i < 1; i ++ ){
				for each (var animation2:TexturesCache in TextureManager.subTextures["Sephius"]) {
					GameEngine.assets.getTextures("Sephius", animation2.name);
					TextureManager.packsSubtextureSizes["Sephius"].width * .5;
				}
			}
			time2 = getTimer () - time2;*/

			trace ( 'Getting & setting a static _mcSequences of AtlasManager class :\n    ' + time2 + ' millisec' );

			trace ( 'Static access is slower by ' + int ( time2 / time1 * 100 - 99.5 ) + '%.\n' );

			////////
			////////

			time1 = getTimer ();
			for ( i = 0; i < n; i ++ )
				instanceMethod ();
			time1 = getTimer () - time1;

			trace ( 'Calling a method of this object :\n    ' + time1 + ' millisec' );

			time2 = getTimer ();
			for ( i = 0; i < n; i ++ )
				staticMethod ();
			time2 = getTimer () - time2;

			trace ( 'Calling a static method of this class :\n    ' + time2 + ' millisec' );

			trace ( 'Static access is slower by ' + int ( time2 / time1 * 100 - 99.5 ) + '%.\n' );

			////////
			////////
			/*
			time1 = getTimer ();
			for ( i = 0; i < n; i ++ )
				ref.getTextureSize2("Sephius");
			time1 = getTimer () - time1;

			trace ( 'Calling a method of another object :\n    ' + time1 + ' millisec' );

			time2 = getTimer ();
			for ( i = 0; i < n; i ++ )
				GameEngine.assets.getTexturesize("Sephius");
			time2 = getTimer () - time2;
			*/
			trace ( 'Calling a static method of another class :\n    ' + time2 + ' millisec' );

			trace ( 'Static access is slower by ' + int ( time2 / time1 * 100 - 99.5 ) + '%.\n' );
		}

		public function instanceMethod () : int
		{
			return 1;
		}

		public static function staticMethod () : int
		{
			return 1;
		}

	}
	
}