package starling.filters 
{
	import flash.display3D.Context3DProgramType;
	import starling.textures.Texture;
	import flash.display3D.Context3D;
	import starling.core.Starling;
	/**
	 * Filter witch does nothing, only used to allow game to change resolution.
	 * @author Fernando Rabello.
	 */
	public class NullFilter extends FragmentFilter 
	{
		
		public function NullFilter(numPasses:int=1, resolution:Number=1.0) 
		{
			super(numPasses, resolution);
			
		}
		
		override protected function createPrograms():void {
			var target:Starling = Starling.current;
			
			return target.registerProgramFromSource("nullS", STD_VERTEX_SHADER, STD_FRAGMENT_SHADER);
		}
		
		override protected function activate(pass:int, context:Context3D, texture:Texture):void 
		{
            context.setProgramConstantsFromVector(Context3DProgramType.VERTEX,   4, mOffsets);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, mWeights);
		}
	}

}