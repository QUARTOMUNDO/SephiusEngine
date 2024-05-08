package SephiusEngine.levelObjects {
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.gameStates.LevelManager;
	import SephiusEngine.core.levelManager.LevelArea;
	import SephiusEngine.levelObjects.interfaces.IPhysicSoundEmitter;
	import SephiusEngine.levelObjects.interfaces.IPhysicalObject;
	import SephiusEngine.levelObjects.interfaces.ISpriteSoundEmitter;
	import SephiusEngine.levelObjects.interfaces.ISpriteView;

	public class GameObject
	{
		public static var hideParamWarnings:Boolean = true;
		
		private var _name:String;
		/** A name to identify easily an objet. You may use duplicate name if you wish.*/
		public function get name():String {return _name;}
		public function set name(value:String):void { _name = value; }
		
		/** Tell if object was destroyed .*/
		public function get destroyed():Boolean {return _destroyed;}
		private var _destroyed:Boolean;
		
		/** Set it to true if you want to remove, clean and destroy the object. */
		public var kill:Boolean = false;
		
		/** Set it to true if you want to remove a object withou destoy it  */
		public var remove:Boolean = false;
		
		/** This property prevent the <code>update</code> method to be called by the enter frame, it will save performances. 
		 * Set it to true if you want to execute code in the <code>update</code> method.*/
		public var updateCallEnabled:Boolean = false;
		
		protected var _initialized:Boolean = false;
		protected var _ge:GameEngine;
		protected var _lm:LevelManager;
		
		public var addedToState:Boolean = false;
		
		/** If this object belong originally to a Level Area this property will store witch area is */
		public var parentArea:LevelArea;
		
		/** Store params witch come from level editor for be exported */
		public var paramsInfo:Object;
		
		/** Every Sephius Object needs a name. It helps if it's unique, but it won't blow up if it's not.
		 * Also, you can pass parameters into the constructor as well. Hopefully you'll commonly be
		 * creating SephiusObjects via an editor, which will parse your shit and create the params object for you. 
		 * @param name Name your object.
		 * @param params Any public properties or setters can be assigned values via this object.*/		
		public function GameObject(name:String, params:Object = null){
			_ge.state.storedObjects.push(this);
			
			this.name = name;
			
			paramsInfo = params;
			
			if (!paramsInfo)
				paramsInfo = { width:50, height:50, x:0, y:0 } 
			
			initialize();
		}
		
		private var cPO:IPhysicalObject;
		private var cIV:ISpriteView;
		private var cPSE:IPhysicSoundEmitter;
		private var cSSO:ISpriteSoundEmitter;
		
		/**
		 * Call in the constructor if the Object is added via the State and the add method.
		 * <p>If it's a pool object or an entity initialize it yourself.</p>
		 * <p>If it's a component, it should be call by the entity.</p>
		 */
		public function initialize():void {
			cPO = (this as IPhysicalObject);
			cIV = (this as ISpriteView);
			cPSE = (this as IPhysicSoundEmitter);
			cSSO = (this as ISpriteSoundEmitter);
			
			if (cPO)
				cPO.createPhysics();
			
			if (cIV)
				cIV.createView();
			
			if (cPSE)
				cPSE.createSound();
			
			else if(cSSO)
				cSSO.createSound();
			
			if (paramsInfo)
				setParams(this, paramsInfo);
		}
		
		/**Seriously, dont' forget to release your listeners, signals, and physics objects here. Either that or don't ever destroy anything.
		 * Your choice.*/		
		public function destroy():void { 
			if (cIV)
				cIV.destroyView();
			
			if (cPO)
				cPO.destroyPhysics();
			
			if (cPSE)
				cPSE.destroySound();
			
			else if(cSSO)
				cSSO.destroySound();
			
			if (parentArea) {
				var aIndex:uint = parentArea.objects.indexOf(this);
				parentArea.objects.splice(aIndex, 1);
				parentArea = null;
			}
			
			if(_ge)
				_ge.state.storedObjects.splice(_ge.state.storedObjects.indexOf(this), 1);
			
			_initialized = false; 
			_destroyed = true;
			
			cPO = null;
			cIV = null;
			cPSE = null;
			cSSO = null;
			
			_ge = null;
			_lm = null;
		}
		
		/**The current state calls update every tick. This is where all your per-frame logic should go. Set velocities, 
		 * determine animations, change properties, etc. 
		 * @param timeDelta This is a ratio explaining the amount of time that passed in relation to the amount of time that
		 * was supposed to pass. Multiply your stuff by this value to keep your speeds consistent no matter the frame rate. */		
		public function update(timeDelta:Number):void{}
		
		/**The initialize method usually calls this.*/
		public function setParams(object:Object, params:Object):void{
			for (var param:String in params){
				if (object.hasOwnProperty(param)){
					//trace("has param "	 + param);
					if (params[param] == "true")
						object[param] = true;
					else if (params[param] == "false")
						object[param] = false;
					else if (param == "view") {
						//CreateView() do this
						//viw.content = params[param];
					}
					else
						object[param] = params[param];
				}
				else{
					//trace("do not have param " + param);
					if (!hideParamWarnings)
						trace("Warning: The parameter " + param + " does not exist on " + this);
				}
			}
			_initialized = true;
		}
	}
}