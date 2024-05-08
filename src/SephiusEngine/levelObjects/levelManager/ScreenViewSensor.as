package SephiusEngine.levelObjects.levelManager {
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.GamePhysics;
	import SephiusEngine.levelObjects.GamePhysicalObject;
	import tLotDClassic.gameObjects.barriers.Barriers;
	import tLotDClassic.gameObjects.characters.Characters;
	import tLotDClassic.gameObjects.characters.Creatures;
	import tLotDClassic.gameObjects.characters.Spawner;
	import SephiusEngine.levelObjects.damagers.DamageCollisions;
	import SephiusEngine.levelObjects.interfaces.IPhysicalObject;
	import tLotDClassic.gameObjects.pools.Pool;
	import tLotDClassic.gameObjects.spells.Spell;
	import nape.phys.BodyType;
	
	/**
	 * Sensor that active and desactive objects by touching.
	 * This folow sephius and make only the sings close to him to de active
	 * @author Fernando Rabello
	 */
	public class ScreenViewSensor extends GamePhysicalObject{
		public var on:Boolean;
		public var actionType:String;
		private var currentCollider:IPhysicalObject;
		
		public function ScreenViewSensor(name:String, params:Object=null, on:Boolean=true, actionType:String = ""){
			this.on = on;
			
			updateCallEnabled = true;
			
			super(name, params);
			
			GameEngine.instance.state.add(this);
		}
		
		override public function createPhysics():void {
			_interactionFilter = GamePhysics.SCREEN_SENSOR_FILTER;
			
			if(on)
				_cbTypes.add(GamePhysics.SCREEN_SENSOR_ON_CBTYPE);
			else
				_cbTypes.add(GamePhysics.SCREEN_SENSOR_OFF_CBTYPE);
				
			super.createPhysics();
			
			_mainShape.sensorEnabled = true;
			_body.type = BodyType.KINEMATIC;
			
			if(on)
				_body.rotation = Math.PI;
		}
		
		/** Override this method if you want to perform some actions after the collision.*/
		public function handleViewSensor(on:Boolean, activable:IPhysicalObject):void {
			if (on) {
				if (activable is Spawner)
					(activable as Spawner).on = true;
					
				else if (activable as Barriers)
					(activable as Barriers).enabled = true;
				
				else if (activable as Pool)
					(activable as Pool).enabled = true;
				
				else if (activable as DamageCollisions)
					(activable as DamageCollisions).enabled = true;
				
				else if (activable is Characters) {
					(activable as Characters).activate();
					(activable as Characters).kill = false;
				}
			}
			else {
				if (activable is Spawner)
					(activable as Spawner).on = false;
				
				else if (activable is Spell)
					(activable as Spell).dispose();
					
				else if (activable is Creatures) {
					(activable as Creatures).banCharacter("ScreenViewSensor");
				}
				
				else if (activable as Barriers)
					(activable as Barriers).enabled = false;
				
				else if (activable as Pool)
					(activable as Pool).enabled = false;
					
				else if (activable as DamageCollisions)
					(activable as DamageCollisions).enabled = false;
			}
		}
		
		override public function update(timeDelta:Number):void {
			this.x = GameEngine.instance.state.view.camera.realPosition.x;
			this.y = GameEngine.instance.state.view.camera.realPosition.y;
			this.rotationRad = -GameEngine.instance.state.view.camera.realRotation;
		}
	}
}