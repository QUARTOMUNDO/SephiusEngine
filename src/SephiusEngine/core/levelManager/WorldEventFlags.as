package SephiusEngine.core.levelManager 
{
	import flash.utils.Dictionary;
	import org.osflash.signals.Signal;
	/**
	 * Store event flags and dispatch changes to listners
	 * @author Fernando Rabello
	 */
	public class WorldEventFlags {
		public function WorldEventFlags() {	}
		
		public function get WorldFlags():Dictionary {return _WorldFlags; }
		private var _WorldFlags:Dictionary = new Dictionary();
		
		/**
		 * Set a world flag value and create one is don't exist
		 * @param	flag name
		 * @param	value desired
		 */
		public function SetWorldFlag(flag:String, value:int):void{
			if (!_WorldFlags[flag]){
				_WorldFlags[flag] = new WorldFlag(flag, value);
				return;
			}
			
			_WorldFlags[flag].value = value;
		}
		
		/**
		 * Add world flag callback function that will be called when world flag changes its value
		 * @param	flag name
		 * @param	callback function
		 */
		public function AddWorldFlagCallback(flag:String, callback:Function):void{
			if (!_WorldFlags[flag])
				_WorldFlags[flag] = new WorldFlag(flag, -1);
			
			_WorldFlags[flag].flagSignal.add(callback);
		}
		
		/**
		 * Remove a callback so it will not listen a flag change anymore
		 * @param	flag name
		 * @param	callback function
		 */
		public function RemoveWorldFlagCallback(flag:String, callback:Function):void{
			if (!_WorldFlags[flag])
				return;
			
			_WorldFlags[flag].flagSignal.remove(callback);
		}
		
		/**
		 * Used to determine if a flag exist
		 * @param	flag
		 * @return Return true if a certain flag name exist
		 */
		public function WorldFlagExist(flag:String):Boolean{
			if (!_WorldFlags[flag])
				return false;
			else
				return true;
		}
		
		/**
		 * Used to get flags values
		 * @param	flag name
		 * @return value for the flag name given
		 */
		public function GetWorldFlagValue(flag:String):int{
			if (!_WorldFlags[flag]){
				return -1;
			}
			else
				return _WorldFlags[flag].value;
		}
		
		/**
		 * Add 1 to a world flag, create a flag if not existed
		 * @param	flag
		 */
		public function AddToWorldFlag(flag:String):void{
			if (!_WorldFlags[flag]){
				_WorldFlags[flag] = new WorldFlag(flag, -1);
				return;
			}
			
			_WorldFlags[flag].value++;
		}
		
		/**
		 * Remove world flag completely
		 * @param	flag
		 */
		public function RemoveWorldFlag(flag:String):void{
			_WorldFlags[flag].destroy();
			delete _WorldFlags[flag];
		}
		
		/**
		 * Remove 1 from a world flag and destroy it if count reach 0
		 * @param	flag
		 */
		public function SubtractToWorldFlag(flag:String):void{
			if (!_WorldFlags[flag])
				return;
			
			_WorldFlags[flag].value--;
			
			if (_WorldFlags[flag].value <= 0)
				RemoveWorldFlag(flag);
		}
	}
}