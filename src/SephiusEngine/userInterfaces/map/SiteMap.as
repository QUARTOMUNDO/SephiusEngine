package SephiusEngine.userInterfaces.map 
{
	import SephiusEngine.core.GameData;
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.userInterfaces.GameMap;

	import com.greensock.TweenMax;

	import starling.textures.SubTexture;
	import starling.display.Image;
	import SephiusEngine.Languages.LanguageManager;
	import starling.display.Sprite;
	/**
	 * A Pieces of map which shows sites.
	 * @author Fernando Rabello
	 */
	public class SiteMap extends MapLocation {
		public var siteName:String;
		
		public var pieces:Vector.<Image> = new Vector.<Image>();

		public function SiteMap(siteName:String, X:Number, Y:Number, scaleX:Number, scaleY:Number) {
			this.siteName = siteName;
			super(null, X, Y, MapLocationIDTypes.TYPE_SITE, siteName);
			
			this.scaleX = scaleX;
			this.scaleY = scaleY;
			
			dynamicVisual = true;
			
			alphaRatio = alpha = 0;
		}
		
		public function addPiece(pieceID:String, x:Number, y:Number, scaleX:Number, scaleY:Number):void{
			var piece:Image = new Image(GameEngine.assets.getTexture("GameMap_Site" + siteName.replace(" ", "") + "" + pieceID) as SubTexture);
			piece.alignPivot();
			piece.x = x;
			piece.y = y;
			piece.scaleX = scaleX;
			piece.scaleY = scaleY;

			if(pieces.length < int(pieceID))//force piece to stay at informed index
				pieces.length = int(pieceID);

			pieces.insertAt(int(pieceID), piece);

			if(int(pieceID) < numChildren)
				addChildAt(piece, int(pieceID));
			else
				addChild(piece);
		}

		override public function UpdateVisual(alpha:Number):void {
			this.alpha = (alpha + 0.1) * alphaRatio;
		}
		
		public function showSiteMap(mapOnScreen:Boolean, gameMap:GameMap):void{
			if (mapOnScreen && enabled){
				TweenMax.to(this, 0.5, {alpha:1, delay:1});
				gameMap.onMapOnScreen.remove(showSiteMap);
				
				GameData.getInstance().addSiteMapLocations(siteName);
			}
		}

		override public function dispose():void{
			super.dispose();
			
			pieces.length = 0;
		}
	}
}