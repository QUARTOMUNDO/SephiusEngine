package SephiusEngine.core.gameplay.properties.objectsInfos {
	/**
	 * Define states for barriers
	 * @author Fernando Rabello
	 */
	public class BarrierState {
		private var _name:String;
		public function get name():String { return(_name); }
		
		private var _varName:String;
		public function get varName():String { return(_varName); }
		
		private var _moving:Boolean;
		public function get moving():Boolean { return(_moving); }
		
		private var _canInteract:Boolean;
		public function get canInteract():Boolean { return(_canInteract); }
		
		/** Initial State. It does noting */
		public static const IDLE:								BarrierState = new BarrierState ("idle", "IDLE", false, false);
		
		//States                                                                                   name 
		public static const OPENED:								BarrierState = new BarrierState ("opened", "OPENED", false, false);
		public static const OPENING: 							BarrierState = new BarrierState ("opening", "OPENING", true, false);
		public static const CLOSED: 							BarrierState = new BarrierState ("closed", "CLOSED", false, true);
		public static const CLOSING: 							BarrierState = new BarrierState ("closing", "CLOSING", true, false);
		
		public function BarrierState(name:String, varName:String, moving:Boolean, canInteract:Boolean) {
			_name = name;
			_varName = varName;
			_moving = moving;
			_canInteract = canInteract;
		}
		
	}

}