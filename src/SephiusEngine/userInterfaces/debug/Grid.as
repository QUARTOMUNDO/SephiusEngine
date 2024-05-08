package SephiusEngine.userInterfaces.debug {
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.displayObjects.configs.AssetsConfigs;
	import SephiusEngine.levelObjects.GameSprite;

	import starling.display.*;

	import tLotDClassic.gameObjects.characters.Sephius;
	/**
	 * ...
	 * @author Fernando Rabello
	 */
	public class Grid extends GameSprite 
	{
		private var sephius:Sephius;
		private var image:Image;
		private var started:Boolean = false;
		private var _textureName:String;
		
		public function Grid(textureName:String, params:Object = null) 
		{
			//updateCallEnabled = true;
			group = AssetsConfigs.OBJECTS_ASSETS_GROUP - 1;
			super("DebugGrid", params);
			sephius = GameEngine.instance.state.mainPlayer;
			_textureName = textureName;
			
			this.x = sephius.x;
			this.y = sephius.y;
			
			GameEngine.assets.checkInTexturePack("DebugGrid", createArtContent, "GRID");
		}
		
		override public function update(timeDelta:Number):void {
		}
		
		public function createArtContent(groupName:String):void {
			trace("loading grid", _group, x, y, GameEngine.assets.getTexture(_textureName));
			image = new Image(GameEngine.assets.getTexture(_textureName));
			image.alignPivot();
			view.content = image;
			GameEngine.instance.state.add(this);
			started = true;
		}
		
		override public function destroy():void {
			if(image){
				image.removeFromParent(true);
				image = null;
				GameEngine.assets.checkOutTexturePack("DebugGrid", "GRID");
				//kill = true;
			}
			super.destroy()
		}
	}

}