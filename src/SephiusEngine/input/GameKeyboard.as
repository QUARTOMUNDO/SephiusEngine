package SephiusEngine.input{
	import SephiusEngine.input.controllers.Keyboard;
	import SephiusEngine.input.maping.KeyboardActionMap;
	
	/**
	 * Deal with action assignement to controller buttons using a buttom mapping
	 */
	public class GameKeyboard extends Keyboard{
		
		public function GameKeyboard(name:String, params:Object=null){
			super(name, params);
			/*
			removeAction("left");
			removeAction("up");
			removeAction("right");
			removeAction("down");
			removeAction("duck");
			removeAction("jump");
			*/
			defaultChannel = 0;
			
			addAllActions();
			
		}
		/**
		 * Get all static public variables and add each of one automatcly
		 * So it´s just need to add actions info like static vars and then will be active in the game.
		 * Not need to right all of then.
		 */
		private function addAllActions():void{
			trace("Adding keyboard actions.")
			for (var actionName:String in KeyboardActionMap.CURRENT) {
				addKeyAction(actionName, KeyboardActionMap.CURRENT[actionName]);
			}
		}

		override public function update():void {
			KeyboardActionMap.update();
			resetAllKeyActions();
			addAllActions();
			// Notifies signal listeners
			super.update();
		}
	}       
}           