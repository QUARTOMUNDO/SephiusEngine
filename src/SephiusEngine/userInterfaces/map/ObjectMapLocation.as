package SephiusEngine.userInterfaces.map 
{
	import SephiusEngine.levelObjects.GameObject;
	import SephiusEngine.levelObjects.GamePhysicalSprite;
	import starling.textures.Texture;
	
	/**
	 * Used to track object's position on the map
	 * @author Fernando Rabello
	 */
	public class ObjectMapLocation extends MapLocation {
		public function get targetObject():GamePhysicalSprite {return _targetObject;}
		private var _targetObject:GamePhysicalSprite;
		
		public function ObjectMapLocation(texture:Texture, gameObject:GamePhysicalSprite, typeID:String, subTypeID:String="") {
			super(texture, 0, 0, typeID, subTypeID);
			_targetObject = gameObject;
			_targetObject.onDestroyed.addOnce(removeObject);
			scaleRatio = 5;
		}
		
		override public function UpdatePosition():void {
			if(_targetObject && DynamicPosition){
				x = _targetObject.x;
				y = _targetObject.y;
			}
		}
		
		private function removeObject(gameObject:GameObject):void{
			_targetObject = null;
		}
		
		override public function dispose():void {
			super.dispose();
			if(_targetObject){
				_targetObject.onDestroyed.remove(removeObject)
				_targetObject = null;
			}
		}
	}
}