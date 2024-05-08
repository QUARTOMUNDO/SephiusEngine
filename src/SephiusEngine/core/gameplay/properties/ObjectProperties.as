package SephiusEngine.core.gameplay.properties 
{
	import flash.utils.Dictionary;
	/**
	 * Store Object properties
	 * @author Fernando Rabello
	 */
	public class ObjectProperties {
		private var _name:String;
		private var _objectBaseName:String;
		private var _varName:String;
		private var _subType:String;
		private var _propertyType:String;
		private var _id:uint;
		
		/** Name witch will appear on interfaces and etc. */
		public function get name():String { return _name; }
		public function set name(value:String):void { _name = value; }
		/** Internal ame witch is used to load textures and etc. */
		public function get varName():String { return _varName; }
		/** */
		public function get subType():String{ return _subType; }
		/** Static var name associated with this object */
		public function get objectBaseName():String { return _objectBaseName; }
		/** Type of Property */
		public function get propertyType():String { return _propertyType; }
		/**Item unique ID so can be tracked if player alrady take that item.*/
		public function get id():uint { return _id; }
		/**Store all game properties on a single list*/
		public static const GLOBAL_PROPERTIES_LIST:Vector.<ObjectProperties> = new Vector.<ObjectProperties>();
		public static const GLOBAL_PROPERTIES_BY_VARNAME:Dictionary = new Dictionary();
		
		public static const NONE:ObjectProperties = new ObjectProperties("None", "None", "NONE", "", "None", -1);
		
		public function ObjectProperties(name:String, objectBaseName:String, varName:String, subType:String, propertyType:String, id:uint) {
			this._name = name;
			this._objectBaseName = objectBaseName;
			this._varName = varName;
			this._subType = subType;
			this._propertyType = propertyType;
			this._id = id;
			
			GLOBAL_PROPERTIES_LIST.push(this);
			GLOBAL_PROPERTIES_BY_VARNAME[varName] = this;
		}
	}
}