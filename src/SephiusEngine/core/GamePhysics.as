package SephiusEngine.core 
{
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.levelObjects.GamePhysicalObject;
	import SephiusEngine.levelObjects.activators.EventTrigger;
	import SephiusEngine.levelObjects.activators.ReagentCollider;
	import SephiusEngine.levelObjects.interfaces.ILevelInteractor;
	import SephiusEngine.levelObjects.interfaces.IPhysicalObject;
	import SephiusEngine.levelObjects.interfaces.ISimpleLevelInteractor;
	import SephiusEngine.levelObjects.levelManager.ScreenViewSensor;
	import SephiusEngine.levelObjects.specialObjects.LevelCollision;

	import flash.display.BlendMode;

	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.callbacks.PreCallback;
	import nape.callbacks.PreFlag;
	import nape.callbacks.PreListener;
	import nape.dynamics.Arbiter;
	import nape.dynamics.CollisionArbiter;
	import nape.dynamics.InteractionFilter;
	import nape.geom.Vec2;
	import nape.phys.Interactor;
	import nape.shape.Edge;
	import nape.shape.Polygon;
	import nape.shape.Shape;
	import nape.space.Space;
	import nape.util.Debug;
	import nape.util.ShapeDebug;

	import starling.core.Starling;

	import tLotDClassic.gameObjects.activators.Pyra;
	import tLotDClassic.gameObjects.characters.Sephius;
	import tLotDClassic.gameObjects.pools.Pool;
	import tLotDClassic.gameObjects.rewards.Reward;
	import tLotDClassic.gameObjects.spells.Spell;
	import nape.geom.Ray;
	import nape.geom.RayResult;
	import nape.shape.ShapeList;
	
	/**
	 * Menage Physic on the GameState
	 * GamePhysics replaces Nape SephiusEngine class
	 * and the main diference its now is treated as a system, not as a GameObject
	 * Now physics can be easely accesses but its need to be explicity updated by GameState
	 * It also store its own visual representation object (Box2DDebugArt) in order it can be visualize in debug mode
	 * @author Fernando Rabello
	 */
	public class GamePhysics {
		/** -------------------------------------------------- */
		/** --------------physics constants ------------------ */
		/** -------------------------------------------------- */
		/** timeStep the amount of time to simulate, this should not vary. */
		public static const FIXED_TIMESTEP:Number = 1/(60);
		/** velocityIterations for the velocity constraint solver.*/
		public static const VELOCITY_ITERATIONS:uint = 10;
		/** positionIterations for the position constraint solver.*/
		public static const POSITION_ITERATIONS:uint = 8;
		
		/**No used anymore since Nape uses pixels as unity */
		public static const SCALE:Number = 1;
		
		/** Reduce or increase all forces applied to character. */
		public static const GLOBAL_FORCE_FACTOR:Number = 1.79;
		
		/** Reduce or increase all forces applied to character. */
		public static const GLOBAL_VELOCITY_FACTOR:Number = 1/(60);
		
		public function get gravity():Vec2 { return space.gravity }
		public function set gravity(value:Vec2):void { space.gravity = value }
		
		/** -------------------------------------------------- */
		/** --------------Interactions options --------------- */
		/** -------------------------------------------------- */
		//                                												   Group ID 		Interaction ID		Sensor Group ID		Interaction Sensor Group   Fluid Group  	Fluid Interaction
		
		public static var LEVEL_FILTER:				InteractionFilter = new InteractionFilter(1,  			~(1|16|32),			1,					~(1|16|32), 			   1, 				0);
		public static var HERO_FILTER:				InteractionFilter = new InteractionFilter(2,  			~(2|4|32),			2,					~(32),					   2, 				~(16|32));
		public static var BADGUYS_FILTER:			InteractionFilter = new InteractionFilter(4,  			~(2|4|32),			(4|32),				~(8|32), 				   4, 				~(16|32));
		public static var BADGUYS_NULL_FILTER:		InteractionFilter = new InteractionFilter(4,  			0,					(4|32),				0, 				   			4, 				0);
		public static var REWARD_FILTER:			InteractionFilter = new InteractionFilter(8,  			~(4|32|64),			(8|32),				~(4|32), 				   8, 				~(16|32));
		//public static var PYRA_FILTER:			InteractionFilter = new InteractionFilter(8,  			0,					(8|32),				~(4|32),		 		   8, 				~(16|32));
		public static var PYRA_FILTER:				InteractionFilter = new InteractionFilter(1,			0, 					1,					0,					   	   1, 				~(1));
		public static var SCREEN_SENSOR_FILTER:		InteractionFilter = new InteractionFilter(16,			0, 					16,					-1,						   16, 				0);
		public static var RESPAWNER_FILTER:			InteractionFilter = new InteractionFilter(32, 			0, 					32,					0,						   32, 				0);
		public static var SPELLS_FILTER:			InteractionFilter = new InteractionFilter(64,  			~(8|32),			64,					~(32), 					   64, 				~(16|32));
		public static var SPELLS_DYNAMIC_FILTER:	InteractionFilter = new InteractionFilter(64,  			~(2|4|32|64),		64,					~(32), 					   64, 				~(16|32));
		public static var LEVEL_DYNAMICS_FILTER:	InteractionFilter = new InteractionFilter(1,  			~(16|32),			64,					~(1|32), 				   1, 				0);
		public static var PROJECTILE_FILTER:        InteractionFilter = new InteractionFilter(1024,			1,					1,					~(1|16|32), 		 	   1, 				128);
		public static var LEVEL_FLUYD_FILTER:		InteractionFilter = new InteractionFilter(256, 			0, 					(256), 				~(32), 					   128,				~(16|32));
		public static var DAMAGER_ETHERIAL_FILTER:	InteractionFilter = new InteractionFilter(512, 			0, 					512, 				~(32), 					   256,				~(16|32));
		public static var DAMAGER_SOLID_FILTER:		InteractionFilter = new InteractionFilter(512, 			~(16|32), 			512, 				~(32), 					   256,				~(16|32));
		public static var PARTICLE_FILTER:			InteractionFilter = new InteractionFilter(128, 			1, 					128, 				1, 						   128,				1);
		
		public static var LEVEL_DYNAMICS_CBTYPE:CbType = new CbType();
		public static var LEVEL_CBTYPE:CbType = new CbType();
		public static var LEVEL_SIMPLE_COLLIDER_CBTYPE:CbType = new CbType();
		public static var LEVEL_INTERACTOR_CBTYPE:CbType = new CbType();
		
		public static var LEVEL_FLUYD_CBTYPE:CbType = new CbType();
		public static var DAMAGER_CBTYPE:CbType = new CbType();
		public static var SUFFER_CBTYPE:CbType = new CbType();
		
		public static var COLLECTABLE_CBTYPE:CbType = new CbType();
		public static var COLLECTOR_CBTYPE:CbType = new CbType();
		
		public static var SCREEN_SENSOR_ON_CBTYPE:CbType = new CbType();
		public static var SCREEN_SENSOR_OFF_CBTYPE:CbType = new CbType();
		public static var SCREEN_SENSORABLE_CBTYPE:CbType = new CbType();
		
		public static var SPELL_CBTYPE:CbType = new CbType();
		public static var SPELL_INTERACTOR_CBTYPE:CbType = new CbType();
		
		public static var PYRA_CBTYPE:CbType = new CbType();	
		public static var PYRA_INTERACTOR_CBTYPE:CbType = new CbType();	
		
		public static var REACT_CBTYPE:CbType = new CbType();	
		public static var HELP_INTERACTOR_CBTYPE:CbType = new CbType();	
		
		public static var PROJECTILE_CBTYPE:CbType = new CbType();	
		public static var PROJECTILE_INTERACTOR_CBTYPE:CbType = new CbType();			
		
		/** -------------------------------------------------- */
		/** ---------------------- Listners ------------------ */
		/** -------------------------------------------------- */
		
		//private var _bodyListener:BodyListener;
		
		/** Deal with one way platforms */
		private var _oneWayPlatformsListner:PreListener;
		/** deal witch onGround property on certain objects */
		private var _goundTouchListner:InteractionListener;
		/** deal witch onGround property on certain objects */
		private var _goundSeparationListner:InteractionListener;
		/** deal witch onGround property on certain objects */
		private var _goundContactListner:InteractionListener;
		/** deal witch onGround property on certain objects */
		private var _levelContactListner:InteractionListener;
		/** deal witch fluid intaractions */
		private var _pooLTouchListner:InteractionListener;
		/** deal witch fluid intaractions */
		private var _pooLSeparationListner:InteractionListener;
		/** deal witch fluid intaractions */
		private var _pooLInteractionListner:InteractionListener;
		/** deal witch rewards being collected by collectors */
		private var _rewardCollectionListner:InteractionListener;
		/** Deal witch objects witch has some logic related with they contact with the screen sensor */
		private var _viewSensorInListner:InteractionListener;
		/** Deal witch objects witch has some logic related with they contact with the screen sensor */
		private var _viewSensorOutListner:InteractionListener;
		/** Deal witch spells interction with level and hurters */
		private var _spellTouch:InteractionListener;
		/** Deal witch pyra interction with sephius */
		private var _pyraInteractionListener:InteractionListener;
		
		private var _tutorialInteractionListener:InteractionListener;
		
		/** Deal with objects witch collide with level and need to change ground to mach platform ground */
		private var _levelSimpleColliderListner:InteractionListener;
		
		/** -------------------------------------------------- */
		/** -------------- physics components ---------------- */
		/** -------------------------------------------------- */
		/** Physics visual representation. Used for debug. */
		public var view:Debug;
		
		/** The physic space, where physic simulation happens */
		public var space:Space;
		
		/** Determine if physics should be visible or not. Used for debug. */
		private var _visible:Boolean;
		public function get visible():Boolean { return _visible; }		
		public function set visible(value:Boolean):void {
			if (value && !view) {
				view = new ShapeDebug(Starling.current.nativeStage.stageWidth, Starling.current.nativeStage.stageHeight, 0x000000);
				view.display.blendMode = BlendMode.DIFFERENCE;
				view.display.alpha = .8;
				
				//view.cullingEnabled = true;
				//view.drawBodyDetail = true;
				//view.drawShapeDetail = true;

				(view as ShapeDebug).thickness = 5;
				view.drawConstraints = true;
				view.drawCollisionArbiters = true;
				view.drawFluidArbiters = true;
				view.drawSensorArbiters = true;
				view.drawShapeAngleIndicators = true;
				
				Starling.current.nativeStage.addChild(view.display);
			}
			
			else if (!value && view) {
				Starling.current.nativeStage.removeChild(view.display);
				view.flush();
				view.clear();
				view = null;
			}
			
			_visible = value;
		}
		
		public function GamePhysics() {
			trace("Nape Initializing");
			
			space = new Space(Vec2.weak(0, 760 * 2));
			//space = new Space(Vec2.weak(0, 0 * 2));
			//space.worldLinearDrag = 1;
			space.worldAngularDrag = 0.8;
			
			//Not used at this time
			//_bodyListener = new BodyListener(CbEvent.SLEEP, CbType.ANY_BODY, sleepObject);
			//Call specific functions when objects interact
			
			_oneWayPlatformsListner = new PreListener(InteractionType.COLLISION, LEVEL_CBTYPE, LEVEL_INTERACTOR_CBTYPE, handleGroundPreTouch, 0, true);
			_oneWayPlatformsListner.space = space;
			
			_goundTouchListner = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, LEVEL_CBTYPE, LEVEL_INTERACTOR_CBTYPE, handleGroundTouch);
			_goundTouchListner.space = space;
			_goundSeparationListner = new InteractionListener(CbEvent.END, InteractionType.COLLISION, LEVEL_CBTYPE, LEVEL_INTERACTOR_CBTYPE, handleGroundTouch);
			_goundSeparationListner.space = space;
			_goundContactListner = new InteractionListener(CbEvent.ONGOING, InteractionType.COLLISION, LEVEL_CBTYPE, LEVEL_INTERACTOR_CBTYPE, handleGroundContact);
			_goundContactListner.space = space;
			
			_pooLTouchListner = new InteractionListener(CbEvent.BEGIN, InteractionType.FLUID, LEVEL_FLUYD_CBTYPE, LEVEL_INTERACTOR_CBTYPE, handleFluidContact);
			_pooLTouchListner.space = space;
			_pooLSeparationListner = new InteractionListener(CbEvent.END, InteractionType.ANY, LEVEL_FLUYD_CBTYPE, LEVEL_INTERACTOR_CBTYPE, handleFluidContact);
			_pooLSeparationListner.space = space;
			_pooLInteractionListner = new InteractionListener(CbEvent.ONGOING, InteractionType.FLUID, LEVEL_FLUYD_CBTYPE, LEVEL_INTERACTOR_CBTYPE, handleFluidContact);
			_pooLInteractionListner.space = space;
			
			_rewardCollectionListner = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, COLLECTABLE_CBTYPE, COLLECTOR_CBTYPE, handleCollections);
			_rewardCollectionListner.space = space;
			
			_viewSensorInListner = new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR, SCREEN_SENSOR_ON_CBTYPE, SCREEN_SENSORABLE_CBTYPE, handleViewSensor);
			_viewSensorInListner.space = space;
			_viewSensorOutListner = new InteractionListener(CbEvent.END, InteractionType.SENSOR, SCREEN_SENSOR_OFF_CBTYPE, SCREEN_SENSORABLE_CBTYPE, handleViewSensor);
			_viewSensorOutListner.space = space;
			
			_levelSimpleColliderListner = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, LEVEL_CBTYPE, LEVEL_SIMPLE_COLLIDER_CBTYPE, handleSimpleGroundTouch);
			_levelSimpleColliderListner.space = space;
			
			_spellTouch = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, SPELL_CBTYPE, SPELL_INTERACTOR_CBTYPE, handleSpellTouch);
			_spellTouch.space = space;
			
			_pyraInteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.FLUID, PYRA_CBTYPE, PYRA_INTERACTOR_CBTYPE, handlePyraSensor);
			_pyraInteractionListener.space = space;
			
			_tutorialInteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.FLUID, REACT_CBTYPE, HELP_INTERACTOR_CBTYPE, handleTutorialSensor);
			_tutorialInteractionListener.space = space;
		}
		
		private var _currentInteractor1:Interactor;
		private var _currentInteractor2:Interactor;
		private var colArb:CollisionArbiter;
		private var collidingShape:Polygon;
		private var collidingEdge:Edge;
		private var collider:IPhysicalObject;
		/**  Make objects not collide with oneway platforms */
		private function handleGroundPreTouch(cb:PreCallback):PreFlag {
            colArb = cb.arbiter.collisionArbiter;
			collidingShape = !cb.swapped ? colArb.shape1 as Polygon : colArb.shape2 as Polygon;
			//collidingEdge = !cb.swapped ? colArb.referenceEdge1 as Polygon : colArb.referenceEdge2 as Polygon;
			collider = (cb.int2.castShape.body.userData.gameObject as IPhysicalObject);
			
			if (collidingShape.userData.oneWay)
				return (collidingShape.body.userData.gameObject as LevelCollision).handleOneWayContact(collider, cb);
			
			(collider as ILevelInteractor).handleGroundPreTouch(collidingShape, cb);
			return PreFlag.ACCEPT;
			
			//return (cb.int1.castShape.body as LevelCollision).handleOneWayContact((cb.int2.castShape.body.userData.gameObject as IPhysicsObject), cb);
		}
		
		protected var _currentArbiter:Arbiter; 
		protected var _caIndex:Number; 
		/** Used by game logic to retrive normal angle, impulses and other informations */
		private function handleGroundTouch(cb:InteractionCallback):void {
			if(cb.arbiters.length > 0 && ((cb.arbiters.at(0).state == PreFlag.IGNORE || cb.arbiters.at(0).state == PreFlag.IGNORE_ONCE)))
				return;

			if(!defineInteractors(cb))
				return;

			if(cb.event == CbEvent.BEGIN){
				cInteractorshape.userData.numberOfContacts++;

				for (_caIndex = 0; _caIndex < cb.arbiters.length; _caIndex++ ){
					_currentArbiter = cb.arbiters.at(_caIndex);

					if ((_currentArbiter && _currentArbiter.isCollisionArbiter()))
						cLevelInteractor.handleGroundTouch(true, cLevelCollision, _currentArbiter.collisionArbiter, cLevelshape, cSwapped);
				}
			}
			else{
				cInteractorshape.userData.numberOfContacts--;
				cLevelInteractor.handleGroundTouch(false, cLevelCollision, null, cLevelshape, cSwapped);
			}
			_currentArbiter = null;

			/**
			if (cb.event == CbEvent.BEGIN){
				for (_caIndex = 0; _caIndex < cb.arbiters.length; _caIndex++ ) {
					_currentArbiter = cb.arbiters.at(_caIndex);

				if (_currentArbiter.isCollisionArbiter())
					cLevelInteractor.handleGroundTouch(cb.event == CbEvent.BEGIN ? true: false, cLevelCollision, _currentArbiter.collisionArbiter, cLevelshape, cSwapped);
					
					if (_currentArbiter.isCollisionArbiter())
						(cb.int2.castShape.body.userData.gameObject as ILevelInteractor).handleGroundTouch(cb.event == CbEvent.BEGIN ? true: false, cb.int1.castShape.body.userData.gameObject as LevelCollision, _currentArbiter.collisionArbiter, cb.int1.castShape);
					else
						(cb.int1.castShape.body.userData.gameObject as ILevelInteractor).handleGroundTouch(cb.event == CbEvent.BEGIN ? true: false, cb.int2.castShape.body.userData.gameObject as LevelCollision, _currentArbiter.collisionArbiter, cb.int2.castShape);
				}
			}
			else if (cb.int2.castShape.body && cb.int1.castShape.body)
				(cb.int2.castShape.body.userData.gameObject as ILevelInteractor).handleGroundTouch(cb.event == CbEvent.BEGIN ? true: false, cb.int1.castShape.body.userData.gameObject as LevelCollision, null, cb.int1.castShape);
			*/
		}
		
		/** Used by game logic to retrive normal angle, impulses and other informations */
		private function handleGroundContact(cb:InteractionCallback):void {
			if(cb.arbiters.length > 0 && (cb.arbiters.at(0).state == PreFlag.IGNORE || cb.arbiters.at(0).state == PreFlag.IGNORE_ONCE))
				return;

			if(!defineInteractors(cb))
				return;

			for (_caIndex = 0; _caIndex < cb.arbiters.length; _caIndex++ ) {
				_currentArbiter = cb.arbiters.at(_caIndex);

				if (_currentArbiter.isCollisionArbiter())
					cLevelInteractor.handleGroundContact(cLevelCollision, _currentArbiter.collisionArbiter, cLevelshape, cSwapped);
			}
		}



		private var ray:Ray = new Ray(Vec2.get(), Vec2.get());
		private var rayResult:RayResult;
		private var reflectAngle:Number;
		private var occluded:Boolean;
		private var occlusionShapeList:ShapeList = new ShapeList();
		/* Perform a raycast to see if there is any shape between the path of 2 points.  */
		public function rayCast(posA:Vec2, posB:Vec2, filter:InteractionFilter=null, color:uint = 0xffff00):Boolean{
			if(!filter)
				filter = GamePhysics.PARTICLE_FILTER;

			ray.origin.x = posA.x;
			ray.origin.y = posA.y;
			ray.direction = posB;
			ray.maxDistance = ray.direction.length;

			if(ray.direction.length > 0.1){
				rayResult = space.rayCast(
					ray,
					false,
					filter
				);
			}

			occluded = rayResult;

			//When ray is already inside a shape it don't detect collision. 
			//So we verify if the origin of the ray is inside some shape. If it is. Occlusion also happened.
			if(!occluded)
				occluded = space.shapesUnderPoint(ray.origin, filter, occlusionShapeList).length > 0;

			//Debug for raycast
			if(view){
				view.drawLine(ray.origin, ray.origin.add(ray.direction, true), color);
				if (occluded){
					var hitLocation:Vec2;

					if(occlusionShapeList.length > 0)
						hitLocation = ray.origin;
					else
						hitLocation = ray.origin.sub(rayResult.normal.mul(rayResult.distance, true), true);

					view.drawCircle(hitLocation, 5, 0xff0000);
				}
			}

			if (rayResult)
				rayResult.dispose();

			occlusionShapeList.clear();

			rayResult = null;
			
			return occluded;
		}


		private var cLevelInteractor:ILevelInteractor;
		private var cLevelCollision:IPhysicalObject;
		private var cLevelshape:Shape;
		private var cInteractorshape:Shape;
		private var cSwapped:Boolean;
		private function defineInteractors(cb:InteractionCallback):Boolean{
			//Collision swapped handling. 
			if(cb.int1.castShape.body && cb.int1.castShape.body.userData.gameObject as ILevelInteractor){
				cLevelInteractor = cb.int1.castShape.body.userData.gameObject;
				cInteractorshape = cb.int1.castShape;

				cLevelCollision = cb.int2.castShape.body.userData.gameObject;
				cLevelshape = cb.int2.castShape;
				
				cSwapped = true;
				//trace("handleGroundContact: " + cSwapped);
				return true;	
			}
			else if(cb.int2.castShape.body && cb.int2.castShape.body.userData.gameObject as ILevelInteractor){
				cLevelInteractor = cb.int2.castShape.body.userData.gameObject;
				cInteractorshape = cb.int2.castShape;

				cLevelCollision = cb.int1.castShape.body.userData.gameObject;
				cLevelshape = cb.int1.castShape;
				cSwapped = false;
				//trace("handleGroundContact: " + cSwapped);
				return true;	
			}
			else
				return false;		
		}

		/** Handle logic related with simple objects touching the ground, like items changing group do match platform group */
		private function handleSimpleGroundTouch(cb:InteractionCallback):void {
			if(cb.arbiters.length > 0 && (cb.arbiters.at(0).state == PreFlag.IGNORE || cb.arbiters.at(0).state == PreFlag.IGNORE_ONCE))
				return;
			
			if (cb.event == CbEvent.BEGIN){
				for (_caIndex = 0; _caIndex < cb.arbiters.length; _caIndex++ ) {
					_currentArbiter = cb.arbiters.at(_caIndex);
					if (_currentArbiter.isCollisionArbiter()){
						if(cb.int1.castShape.body.userData.gameObject as ISimpleLevelInteractor)
							(cb.int1.castShape.body.userData.gameObject as ISimpleLevelInteractor).onSimpleGroundTouch(cb.int2.castShape.body.userData.gameObject as LevelCollision, cb.int1.castShape.userData.group);
						else if(cb.int2.castShape.body.userData.gameObject as ISimpleLevelInteractor)
							(cb.int2.castShape.body.userData.gameObject as ISimpleLevelInteractor).onSimpleGroundTouch(cb.int1.castShape.body.userData.gameObject as LevelCollision, cb.int1.castShape.userData.group);
						
						//(cb.int2.castShape.body.userData.gameObject as ISimpleLevelInteractor).group = cb.int1.castShape.userData.group;
						//(cb.int2.castShape.body.userData.gameObject).updateGroup = true;
						//(cb.int2.castShape.body.userData.gameObject as ISimpleLevelInteractor).parallax = AssetsConfigs["PARALLAX" + cb.int1.castShape.userData.group];
					}
				}
			}
		}


		/** Used by game logic to retrive normal angle, impulses and other informations */
		private function handleCollections(cb:InteractionCallback):void {
			(cb.int1.castShape.body.userData.gameObject as Reward).collect(cb.int2.castShape.body.userData.gameObject as Sephius);
		}
		
		/** Used by game logic to retrive normal angle, impulses and other informations */
		private function handleViewSensor(cb:InteractionCallback):void {
			(cb.int1.castShape.body.userData.gameObject as ScreenViewSensor).handleViewSensor(cb.event == CbEvent.BEGIN, cb.int2.castShape.body.userData.gameObject as IPhysicalObject);
		}
		
		/** Used by game logic to retrive normal angle, impulses and other informations */
		private function handleSpellTouch(cb:InteractionCallback):void {
			for (_caIndex = 0; _caIndex < cb.arbiters.length; _caIndex++ ) {
				_currentArbiter = cb.arbiters.at(_caIndex);
				if (_currentArbiter.isCollisionArbiter)
					(cb.int1.castShape.body.userData.gameObject as Spell).objectTouch(cb.int2.castShape.body.userData.gameObject as IPhysicalObject, _currentArbiter as CollisionArbiter);
			}
		}
		
		private function handlePyraSensor(cb:InteractionCallback):void {
			(cb.int1.castShape.body.userData.gameObject as Pyra).onInteractorSense(cb.int2.castShape.body.userData.gameObject as Sephius);
		}	
		
		private function handleTutorialSensor(cb:InteractionCallback):void {
			if((cb.int1.castShape.body.userData.gameObject as EventTrigger))	
				(cb.int1.castShape.body.userData.gameObject as EventTrigger).onInteractorSense(cb.int2.castShape.body.userData.gameObject as Sephius);
			if((cb.int1.castShape.body.userData.gameObject as ReagentCollider))	
				(cb.int1.castShape.body.userData.gameObject as ReagentCollider).onInteractorSense(cb.int2.castShape.body.userData.gameObject as Sephius);
		}
		
		/** Used by game logic to retrive normal angle, impulses and other informations */
		private function handleFluidContact(cb:InteractionCallback):void {
			if (cb.event == CbEvent.BEGIN || cb.event == CbEvent.ONGOING) {
				//if (cb.event == CbEvent.BEGIN)
					//trace("GAMEPHYSICS, go IN pool");
				//else if (cb.event == CbEvent.ONGOING)
					//trace("GAMEPHYSICS, ONGOING");
					
				for (_caIndex = 0; _caIndex < cb.arbiters.length; _caIndex++ ) {
					_currentArbiter = cb.arbiters.at(_caIndex);
					if (_currentArbiter.isFluidArbiter()){
						(cb.int2.castShape.body.userData.gameObject as ILevelInteractor).handleFluidContact(cb.event == CbEvent.BEGIN ? "begin" : cb.event == CbEvent.END ? "end" : "ongoing", cb.int1.castShape.body.userData.gameObject as Pool, _currentArbiter.fluidArbiter);
						(cb.int1.castShape.body.userData.gameObject as Pool).handleFluidContact(cb.event == CbEvent.BEGIN ? "begin" : cb.event == CbEvent.END ? "end" : "ongoing", cb.int2.castShape.body.userData.gameObject as IPhysicalObject, _currentArbiter.fluidArbiter);
					}
				}
			}
			else {
				//trace("GAMEPHYSICS, go OUT pool");
				if (cb.int2.castShape.body){
					(cb.int2.castShape.body.userData.gameObject as ILevelInteractor).handleFluidContact("end", cb.int1.castShape.body.userData.gameObject as Pool, null);
					(cb.int1.castShape.body.userData.gameObject as Pool).handleFluidContact("end", cb.int2.castShape.body.userData.gameObject as IPhysicalObject, null);
				}
					
			}
				
		}
		
		/** Used by game logic to retrive normal angle, impulses and other informations */
		private function handleDamagerContact(cb:InteractionCallback):void {}
		
		/** This is where the time step of the physics world occurs. */
		public function singleStep(timeStep:Number):void {
			space.step(timeStep, VELOCITY_ITERATIONS, POSITION_ITERATIONS);
							GameEngine.instance.timeMarks.debugCountCheck(true);
			// Update Debug
			if(GameEngine.instance.state.physics.visible){
				//GameEngine.instance.state.physics.view.clear();
				GameEngine.instance.state.physics.view.draw(GameEngine.instance.state.physics.space);
				GameEngine.instance.state.physics.view.flush();
			}
							GameEngine.instance.timeMarks.debugCountStepCheck();
		}
		
		public function destroy():void {	
			visible = false;
			space.clear();
			space = null;
			view = null;
		}
	}
}