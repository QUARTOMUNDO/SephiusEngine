package SephiusEngine.utils {
	import flash.desktop.NativeApplication;
	import flash.system.Capabilities;
	/**
	 * Give some info about system and the app which is running
	 * @author Fernando Rabello
	 */
	public class AppInfo {
		public function AppInfo() {}
			
		/**
		 * Returns true if the user is running the app on a Debug Flash Player.
		 * Uses the Capabilities class
		 **/
		public static function get isDebugPlayer() : Boolean{ return Capabilities.isDebugger; }
		
		/**
		 * Returns true if the swf is built in debug mode
		 **/
		public static function get isDebugBuild() : Boolean{
			var st:String = new Error().getStackTrace();
			return (st && st.search(/:[0-9]+]$/m) > -1);
		}
			
		/**
		 * Returns true if the swf is built in release mode
		 **/
		public static function get isReleaseBuild() : Boolean{
			return !isDebugBuild;
		}	
		
		/**
		 * Returns Air version application running is
		 **/
		public static function get runtimeVersion() : String{
			return NativeApplication.nativeApplication.runtimeVersion;
		}		
	}
}