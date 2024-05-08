package SephiusEngine.core.levelManager
{
	import org.osflash.signals.Signal;
	
	/**
	 * Store a single world flag
	 * @author Fernando Rabello
	 */
	public class WorldFlag{
		
		
		public function WorldFlag(name:String, value:int){
			_name = name;
			_value = value;
		}
		
		/**
		 * Set a flag value and dispatch a signal if value changed
		 */
		public function get value():int { return _value; }
		public function set value(value:int):void {
			if (_value == value)
				return;
			_value = value; 
			_flagSignal.dispatch(name, value);
		}
		private var _value:int = 0;
		
		public function get name():String { return _name;}
		private var _name:String = "";
		
		public function get flagSignal():Signal { return _flagSignal; }	
		private var _flagSignal:Signal = new Signal(String, int);
		
		public function destroy():void{
			_flagSignal.removeAll();
			_flagSignal = null;
		}
	}
}