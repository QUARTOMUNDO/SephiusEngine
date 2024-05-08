package SephiusEngine.displayObjects.gameArtContainers 
{
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.displayObjects.GameArtContainer;
	import SephiusEngine.displayObjects.particles.ParticleSystemEX;
	import starling.display.DisplayObject;
	import starling.textures.SubTexture;
	
	/**
	 * Art for particle Systems
	 * @author Fernando Rabello
	 */
	public class ParticleArt extends GameArtContainer {
		public static var particles:Vector.<ParticleSystemEX> = new Vector.<ParticleSystemEX>();
		
		public function ParticleArt() {
			super();
		}
		
		private var i:uint;
		
		override public function smoothState(fixedTimestepAccumulatorRatio:Number, oneMinusRatio:Number):void {
			for (i = 0; i < particles.length; i++) {
				particles[i].smoothVertexState(fixedTimestepAccumulatorRatio, oneMinusRatio);
			}
		}
		
		override public function addChild(child:DisplayObject):DisplayObject {
			if(child as ParticleSystemEX){
				particles.push(child as ParticleSystemEX);
			}
			
			return super.addChild(child);
		}
		
		override public function removeChild(child:DisplayObject, dispose:Boolean = false):DisplayObject {
			if((child as ParticleSystemEX) && particles.indexOf((child as ParticleSystemEX)) > -1){
				particles.splice(particles.indexOf((child as ParticleSystemEX)), 1);
			}
			
			return super.removeChild(child, dispose);
		}
	}
}