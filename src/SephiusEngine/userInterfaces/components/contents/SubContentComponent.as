package SephiusEngine.userInterfaces.components.contents {
	import com.greensock.TweenMax;
	import SephiusEngine.assetManagers.ExtendedAssetManager;
	import SephiusEngine.core.GameAssets;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	
	/**
	 * Generic sub menu content.
	 * @author Fernando Rabello
	 */
	public class SubContentComponent extends Sprite{
		public var assets:ExtendedAssetManager;
		
		public function SubContentComponent(){
			super();
			assets = new ExtendedAssetManager ((GameAssets.texturePack == "high" ? 1 : GameAssets.texturePack == "medium" ? 0.6 : GameAssets.texturePack == "low" ? 0.41 : 1), true);
			alpha = 0;
		}
		
		public function setContent(content:Object):void {
			alpha = 0;
			assets.dispose();
		}
		
		public function updateData():void {
			
		}
		
		public function show():void {
			alpha = 0;
			TweenMax.to(this, .3, { alpha:1 } );
		}
		
		public function changeSkin(skin:String):void {
			
		}
		
		protected function onLoadArt(ratio:Number, itemName:String = "Null"):void {
			if (ratio == 1) {
				updateData();
				show();
			}
		}
		
		override public function dispose():void {
			var id:String;
			for(id in this) {
				if (this[id] as DisplayObject){
					(this[id] as DisplayObject).removeFromParent(true);
					this[id] = null;
				}
			}	
			
			super.dispose();
			assets.dispose();
			assets.purge();
			assets = null;
		}
	}
}