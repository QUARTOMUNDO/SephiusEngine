package SephiusEngine.input{
	import SephiusEngine.input.maping.MouseActionMap;
	import SephiusEngine.input.controllers.Mouse;

	/**
	 * Deal with action assignement to controller buttons using a buttom mapping
	 */
	public class GameMouse extends Mouse{
		
		public function GameMouse(name:String, params:Object=null){
			super(name, params);

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
			for (var actionName:String in MouseActionMap.CURRENT) {
				addMouseAction(actionName, MouseActionMap.CURRENT[actionName]);
			}
		}

		override public function update():void {
			MouseActionMap.update();
			resetAllKeyActions();
			addAllActions();
			// Notifies signal listeners
			super.update();
		}
    }
}