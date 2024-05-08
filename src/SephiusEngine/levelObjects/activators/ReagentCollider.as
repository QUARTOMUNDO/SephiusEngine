package SephiusEngine.levelObjects.activators {
	import SephiusEngine.core.GamePhysics;
	import SephiusEngine.levelObjects.GamePhysicalObject;
	import tLotDClassic.gameObjects.characters.Sephius;
	import flash.utils.Dictionary;
	import nape.phys.BodyType;
	/**
	 * Makes Player react someshow it touchted
	 * @author Nilo Paiva & Fernando Rabello
	 */
	public class ReagentCollider extends GamePhysicalObject {
		
		public static const STATE_OFF:String = "off";
		public static const STATE_ON:String = "on";
		
		public var areaGlobalID:uint;
		
		public static const TYPE_STOP:String = "Stop";
		
		public var ID:String;
		public var messageType:String;
		
		public function ReagentCollider(name:String, params:Object=null) {
			super(name, params);
		}
		
		public function onInteractorSense(interactor:Sephius):void {
			if (messageType == TYPE_STOP) {
				interactor.characterAttributes.canAct = false;	
				canActTimer[interactor] = 0;
			}
			state = STATE_ON;
		}
		
		public var canActTimer:Dictionary = new Dictionary();
		public var canActMaxTimer:int = 60 * 3;
		private var currentInteractor:Sephius;
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			if (messageType == TYPE_STOP) {
				for (currentInteractor in canActTimer){
					if (canActTimer[currentInteractor] >= canActMaxTimer){
						canActTimer[currentInteractor] = 0;
						currentInteractor.characterAttributes.canAct = true;	
						state = STATE_OFF;
					}
					else
						canActTimer[currentInteractor]++;
				}
			}
		}
		
		override public function createPhysics():void {
			_radius = _width;
			//_shapeType = "Circle";
			
			_interactionFilter = GamePhysics.PYRA_FILTER;
			_cbTypes.add(GamePhysics.REACT_CBTYPE);
			
			super.createPhysics();
			
			_mainShape.fluidEnabled = true;
			_mainShape.fluidProperties.density = 0;
			_mainShape.fluidProperties.viscosity = 0;
		}
		override public function addPhysics():void {
			super.addPhysics();
			_mainShape.sensorEnabled = false;
			_body.type = BodyType.STATIC;
		}
		
		override public function removePhysics():void {
			if (!_physicAdded)
				return;
			super.removePhysics();
		}
		
		public function get state():String {return _state;}
		public function set state(value:String):void {
			if (_state == value)
				return;
			
			_state = value;
			
			updateCallEnabled = _state == STATE_ON;
		}
		private var _state:String = STATE_OFF;
		
		/* INTERFACE SephiusEngine.levelObjects.interfaces.IPhysicSoundEmitter */
	}
}