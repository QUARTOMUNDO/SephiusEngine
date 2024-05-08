package SephiusEngine.levelObjects {
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.GamePhysics;
	import SephiusEngine.core.gameStates.LevelManager;
	import SephiusEngine.levelObjects.GameObject;
	import SephiusEngine.levelObjects.interfaces.IPhysicalObject;

	import com.greensock.TweenMax;

	import nape.callbacks.CbTypeList;
	import nape.dynamics.InteractionFilter;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Circle;
	import nape.shape.EdgeList;
	import nape.shape.Polygon;
	import nape.shape.Shape;
	import nape.shape.ShapeList;

	import org.osflash.signals.Signal;
	/**
	 * A object with physics but no view representation
	 * @author Fernando Rabello
	 */
	public class GamePhysicalObject extends GameObject implements IPhysicalObject{
		protected var _physics:GamePhysics;
		
		public function get physicAdded():Boolean{ return _physicAdded; };
		protected var _physicAdded:Boolean = false;
		
		public function GamePhysicalObject(name:String, params:Object=null) {
			_ge = GameEngine.instance;
			_lm = LevelManager.getInstance();
			_physics = GameEngine.instance.state.physics;
			_cbTypes = new CbTypeList();
			
			addedToState
			super(name, params);
		}
		
		public function createPhysics():void {
			if(!GameEngine.instance.state.physics)
				return;
			
			if (!_physics)
				throw new Error("Cannot create a GamePhysicsObject when a object has not been added to the state.");
			
			if(!_body)
				_body = new Body(BodyType.DYNAMIC);
			
			if(_body.shapes.length == 0) {
				if (_shapeType == "Circle")
					_body.shapes.add(new Circle(_radius));
				else if (_shapeType == "Box")
					_body.shapes.add(new Polygon(Polygon.box((paramsInfo.width) / GamePhysics.SCALE, (paramsInfo.height) / GamePhysics.SCALE, true)));
				else
					_body.shapes.add(new Polygon(Polygon.box((paramsInfo.width) / GamePhysics.SCALE, (paramsInfo.height) / GamePhysics.SCALE, true)));
			}
			
			_mainShape = _body.shapes.at(0);
			_mainShape.cbTypes.merge(_cbTypes);
			_mainShape.userData.numberOfContacts = 0;

			if(_interactionFilter)
				_mainShape.filter = _interactionFilter;
			
			_body.userData.name = name;
			_body.userData.gameObject = this as GameObject;
		}
		
		private function resetShape(obj:Shape):void{
			obj.userData.gameObject = null;
			obj.userData.sufferAttribute = null;
			obj.cbTypes.clear();
			obj.material = null;
			obj.body.shapes.remove(obj);
		}
		
		public function destroyPhysics():void {
			if (destroyed)
				return;
			
			if(physicAdded){
				removePhysics();
				//We need to delay the destruction of the shapes cause body need to propely end contact with other bodies in next step
				TweenMax.delayedCall(4, clearShapes, null, true);
			}
			else
				clearShapes()
			//trace("destoyed physics from: " + name);
		}

		public function clearShapes():void{
			//Avoid to destruct body before all contacts are removed
			if(!_body.arbiters.empty()){
				TweenMax.delayedCall(1, clearShapes, null, true);
				return;
			}
				
			_mainShape.cbTypes.clear();
			_mainShape = null;
			
			_ignoredShapes.clear();
			
			_body.cbTypes.clear();
			_body.userData.gameObject = null;
			
			_body.shapes.foreach(resetShape);
			_body.shapes.clear();
			
			_body = null;
		}

		/** All your init physics code must be added in this method, no physics code into the constructor. It's automatically called when the object is added to the state.
		 * <p>You'll notice that the GamePhysicsObject's initialize method calls a bunch of functions that start with "define" and "create".
		 * This is how the Box2D objects are created. You should override these methods in your own GamePhysicsObject implementation
		 * if you need additional Box2D functionality. Please see provided examples of classes that have overridden
		 * the GamePhysicsObject.</p>*/
		public function addPhysics():void {
			if(destroyed)
				return;
				
			//trace("added physics to: " + name);
			_body.space = _physics.space;
			_physicAdded = true;	
		}
		
		public function removePhysics():void {
			if (!_physicAdded)
				return;
			//trace("removed physics from: " + name);
			if(_body.space)
				_body.space.bodies.remove(_body);
			//_body.space = null;
			_physicAdded = false;
		}
		
		public function get onDestroyed():Signal {return _onDestroyed;}
		public function set onDestroyed(value:Signal):void {_onDestroyed = value;}
		private var _onDestroyed:Signal = new Signal(GamePhysicalObject);
		
		override public function destroy():void {
			super.destroy();
			_velocityScalled = null;
			_onDestroyed.dispatch(this);
			_onDestroyed.removeAll();
		}
		
		public function applyImpulse(impulse:Vec2, pos:Vec2 = null):void {
			//if (this as Creatures)
				//trace("GPO1 " + impulse.x.toFixed(3) + " / " +  impulse.y.toFixed(3))
			//trace("GAMEPHYSOBJECT impulse! " + name + " / x:" + impulse.x + " y:" + impulse.y);
			_body.applyImpulse(impulse.mul(GamePhysics.GLOBAL_FORCE_FACTOR, true), pos);
			//if (this as Creatures)
				//trace("GPO2 " + impulse.x.toFixed(3) + " / " +  impulse.y.toFixed(3))
		}
		
		public function applyConstrainedImpulse(impulse:Vec2, pos:Vec2 = null, contraintIntensityg99:Number =-1):void {
			if (contraintIntensity == -1)
				contraintIntensity = (this.contraintIntensity * (mass / 70));
			
			var impulseBias:Boolean = impulse.angle;
			
			var reductionAngle:Number = impulse.angle - velocity.angle;
			var reductionImpulse:Number = Math.cos(reductionAngle) * velocityScaled.length;
			
			//trace("reductionAngle:" + reductionAngle + " / reductionImpulse:" + reductionImpulse * contraintIntensity + " / cos(reductionAngle)" +  Math.cos(reductionAngle));
			//trace("GAMEPHYSOBJECT Constrained impulse! " + name + " / x:" + impulse.x + " y:" + impulse.y);
			if((reductionImpulse * contraintIntensity) < impulse.length)
				impulse.length -= reductionImpulse * contraintIntensity;
			else
				impulse.length = 0;
			
			//trace("sufferForce:" + impulse.length + " / sufferForce angle:" + impulse.angle);
			
			_body.applyImpulse(impulse.mul(GamePhysics.GLOBAL_FORCE_FACTOR, true), pos);
		}
		private var contraintIntensity:Number = 2000;
		
		/** For some unknow reason forces witch is applied several frames does not scales as impulses witch applies just 1 frame.
		 * Until this reason remains unraveled this impulses should not be multiplied by GLOBAL_FORCE_FACTOR */
		public function applyConstantImpulse(impulse:Vec2, pos:Vec2 = null):void {
			_body.applyImpulse(impulse, pos);
		}
		
		public function applyAngularImpulse(impulse:Number):void {
			_body.applyAngularImpulse(impulse * GamePhysics.GLOBAL_FORCE_FACTOR);
		}
		
		public function applyAngularVelocity(velocity:Number):void {
			_body.angularVel = velocity;
		}
		
		public function get x():Number {
			return _body.position.x * GamePhysics.SCALE;
		}
		
		public function set x(value:Number):void {
			_body.position.x = value;
		}
		//protected var _x:Number = 0;
		
		public function get y():Number{
			return _body.position.y * GamePhysics.SCALE;
		}
		
		public function set y(value:Number):void{
			_body.position.y = value;
		}
		//protected var _y:Number = 0;
		
		public function get z():Number {return 0;}
		
		public function get rotation():Number {
			return _body.rotation * 180 / Math.PI;
		}
		
		public function set rotation(value:Number):void {
			if(body.type != BodyType.STATIC)
				_body.rotation = value * Math.PI / 180;
		}
		
		public function get rotationRad():Number {
			return _body.rotation;
		}
		
		public function set rotationRad(value:Number):void {
			if(body.type != BodyType.STATIC)
				_body.rotation = value;
		}	
		//protected var _rotation:Number = 0;
		
		/**This can only be set in the constructor parameters. */		
		public function get width():Number{return _width * GamePhysics.SCALE;}
		public function set width(value:Number):void { _width = value / GamePhysics.SCALE; }
		protected var _width:Number = 30;
		
		
		/**This can only be set in the constructor parameters. */	
		public function get height():Number{return _height * GamePhysics.SCALE;}
		public function set height(value:Number):void { _height = value / GamePhysics.SCALE;}
		protected var _height:Number = 30;
		
		/** No depth in a 2D Physics world.*/
		public function get depth():Number {return 0;}
		
		/** This can only be set in the constructor parameters. */	
		public function get radius():Number { return _radius * GamePhysics.SCALE; }
		public function set radius(value:Number):void { _radius = value / GamePhysics.SCALE; }
		protected var _radius:Number;
		
		public function get body():Body {return _body;}
		protected var _body:Body;
		
		public function get shapes():ShapeList {return _body.shapes;}
		
		public function get material():Material { return _mainShape.material; }
		
		public function get ignoredShapes():ShapeList {return _ignoredShapes;}
		protected var _ignoredShapes:ShapeList = new ShapeList();
		
		public function get groundContacts():EdgeList {return _groundContacts;}
		protected var _groundContacts:EdgeList = new EdgeList();
		
		public function get groundContactsAngles():Vector.<Number> {return _groundContactsAngles;}
		protected var _groundContactsAngles:Vector.<Number> = new Vector.<Number>();
		
		public function get shapeType():String { return _shapeType;  }
		public function set shapeType(value:String):void {  _shapeType = value; }
		protected var _shapeType:String = "Box";
		
		public function get interactionFilter():InteractionFilter { return _interactionFilter; }
		protected var _interactionFilter:InteractionFilter;
		
		public function get cbTypes():CbTypeList { return _cbTypes; }
		protected var _cbTypes:CbTypeList;
		
		public function get mainShape():Shape { return _mainShape; }
		protected var _mainShape:Shape;
		
		public function get velocityScaled():Vec2 { return _velocityScalled.setxy(_body.velocity.x * GamePhysics.GLOBAL_VELOCITY_FACTOR, _body.velocity.y * GamePhysics.GLOBAL_VELOCITY_FACTOR); }
		private var _velocityScalled:Vec2 = new Vec2();
		
		public function get velocity():Vec2 { return _body.velocity; }
		public function set velocity(value:Vec2):void { _body.velocity = value; }
		
		//public function get velocityScaled():Vec2 { return _body.velocity * GamePhysics.GLOBAL_VELOCITY_FACTOR; }
		
		public function get angularVel():Number { return _body.angularVel; }
		public function set angularVel(value:Number):void { _body.angularVel = value; }
		
		public function get allowRotation():Boolean { return _body.allowRotation; }
		public function set allowRotation(value:Boolean):void { _body.allowRotation = value; }
		
		public function get allowMovement():Boolean { return _body.allowMovement; }
		public function set allowMovement(value:Boolean):void { _body.allowMovement = value; }
		
		/** We calculate mass manually cause nape give inconsistent mass values for some reason */
		public function get altMass():Number { return _altMass < 0 ? _body.mass : _altMass; }
		protected var _altMass:Number = -1;
		
		public function get mass():Number { return _body.mass; }
		
		public function get gravityIntensity():Number { return _body.gravMassScale; }
		public function set gravityIntensity(value:Number):void { _body.gravMassScale = value; }
		
		/** return the contact angle in deggrees by a given angle in radians */
		protected function getCollisionAngle(radAngle:Number):Number { return ((radAngle * (180 / Math.PI)) + 180) % 360; }
		
	}
}