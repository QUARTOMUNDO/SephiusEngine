package starling.filters 
{
	/**
	 * ...
	 * @author ...
	 */
	import flash.display3D.Context3D;
	import flash.display3D.Program3D;
	import flash.geom.Rectangle;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.filters.BlurFilter;
	import starling.filters.ColorMatrixFilter;
	import starling.filters.FragmentFilter;
	import starling.textures.Texture;
	
	public class HDRFilter extends FragmentFilter
	{
		protected var _blend:Program3D; // blend AGAL program
		protected var _colorMatrix:ColorMatrixFilter; // color matrix filter
		protected var _blur:SpecialBlurFilter; // blur filter to apply to the new layer
	 
		protected var _colorTex:Texture; // output of colormatrix
		protected var _blurTex:Texture; // output of the blur (and colormatrix)
		protected var _renderSupport:RenderSupport; // rendersupport to use new layer(s)
	 
		public function HDRFilter()
		{
			super();
			isFullscreenFX = true;
			_colorMatrix = new ColorMatrixFilter();
		}
	 
		public override function dispose():void
		{
			_blend.dispose();
			_colorMatrix.dispose();
			_blur.dispose();
	 
			_colorTex.dispose();
			_blurTex.dispose();
			_renderSupport.dispose();
			
			super.dispose();
		}
	 
		protected override function createPrograms():void
		{
			var fragmentProgramCode:String =
			"tex ft0, v0,  fs0 <2d, repeat, linear, mipnone>  \n" + // read from Original image
			"tex ft1, v0,  fs1 <2d, repeat, linear, mipnone>  \n" + // read from ColorMatrix + Blur texture
			"add ft2, ft1, ft0 \n" + // do the 'blend' - XXX: this might be wrong for what you want
			"mov oc, ft2 \n";
	 
			_blend = assembleAgal(fragmentProgramCode);
		}
	 
		protected override function activate(pass:int, context:Context3D, texture:Texture):void
		{
			context.setTextureAt(1, _blurTex.base);
			context.setProgram(_blend)
		}		
		
		protected override function deactivate(pass:int, context:Context3D, texture:Texture):void
		{
			context.setTextureAt(1, null);
		}
	 
		public override function render(object:DisplayObject, support:RenderSupport, parentAlpha:Number):void
		{
			if (_colorTex == null) {
				var sBounds:Rectangle = new Rectangle(0, 0, Starling.current.stage.stageWidth, Starling.current.stage.stageHeight);
				var sBoundsPot:Rectangle = new Rectangle(0, 0, Starling.current.stage.stageWidth, Starling.current.stage.stageHeight);
				var scale:Number = Starling.current.contentScaleFactor;
				//calculateBounds(object, object.stage, resolution * scale, false, sBounds, sBoundsPot);
				// setup the texture (new layer) and the rendersupport to use it
				_colorTex = Texture.empty(
					sBoundsPot.width,
					sBoundsPot.height,
					PMA,
					false,
					true,
					resolution * scale
				);
	 
				// create the blur filter and give it this as input
				_blur = new SpecialBlurFilter(_colorTex);
			}
	 
			if (_blurTex == null) {
				sBounds = new Rectangle(0, 0, Starling.current.stage.stageWidth, Starling.current.stage.stageHeight);
				sBoundsPot = new Rectangle(0, 0, Starling.current.stage.stageWidth, Starling.current.stage.stageHeight);
				scale = Starling.current.contentScaleFactor;
				//calculateBounds(object, object.stage, resolution * scale, false, sBounds, sBoundsPot);
				// setup the texture (new layer) and the rendersupport to use it
				_blurTex = Texture.empty(
					sBoundsPot.width,
					sBoundsPot.height,
					PMA,
					false,
					true,
					resolution * scale
				);
	 
			}
			_renderSupport = new RenderSupport();
			_renderSupport.renderTarget = _colorTex;
			_colorMatrix.render(object, _renderSupport, parentAlpha);
			_renderSupport.dispose();
	 
			_renderSupport = new RenderSupport();
			_renderSupport.renderTarget = _blurTex;
			_blur.render(object, _renderSupport, parentAlpha);
			_renderSupport.dispose();
	 
			// now render the blend (this)
			super.render(object, support, parentAlpha);
		}
	}

}