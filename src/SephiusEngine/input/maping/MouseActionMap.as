package SephiusEngine.input.maping {
	import SephiusEngine.input.controllers.Mouse;

	import flash.events.MouseEvent;
	
	/**
	 * Maping for actions using gamepads
	 * @author Fernando Rabello
	 */
	public class MouseActionMap{
		private static var _CURRENT:Object = getDefaultMapping();
		public static function get CURRENT():Object { return _CURRENT; }

		public static function update():void {
			_CURRENT = getDefaultMapping();
		}

		private static function getDefaultMapping():Object {
			return {
				WEAPON_1: Mouse.LEFT,
				WEAPON_2: Mouse.RIGHT,

				SPELL_1: Mouse.LEFT_MODIFIED,
				SPELL_2: Mouse.RIGHT_MODIFIED,

				USE_ITEM: Mouse.MIDDLE,

				RING_SELECTION_UP: Mouse.WHEEL_UP,
				RING_SELECTION_DOWN: Mouse.WHEEL_DOWN,

				CAMERA_INWARD: Mouse.WHEEL_UP,
				CAMERA_OUTWARD: Mouse.WHEEL_DOWN,

				INTERFACE_UP: Mouse.WHEEL_UP,
				INTERFACE_DOWN: Mouse.WHEEL_DOWN,

				INTERFACE_CONFIRM: Mouse.LEFT,
				INTERFACE_CONFIRM: Mouse.LEFT_MODIFIED,
				INTERFACE_CANCEL: Mouse.RIGHT,
				INTERFACE_CANCEL: Mouse.RIGHT_MODIFIED
			};
		}
	}
}