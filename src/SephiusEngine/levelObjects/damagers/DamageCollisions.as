package SephiusEngine.levelObjects.damagers 
{
	import SephiusEngine.core.GamePhysics;
	import SephiusEngine.core.gameplay.attributes.AttributeHolder;
	import SephiusEngine.core.gameplay.attributes.holders.HarmfullObjectAttributes;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.IDamagerAttributes;
	import SephiusEngine.core.gameplay.attributes.subAttributes.DamagerAttibutes;
	import SephiusEngine.core.gameplay.damageSystem.DamageCollisionsManager;
	import SephiusEngine.core.gameplay.damageSystem.DamageConstraint;
	import SephiusEngine.core.gameplay.damageSystem.DamageManager;
	import SephiusEngine.levelObjects.GamePhysicalObject;
	import SephiusEngine.levelObjects.interfaces.IDamagerObject;
	import SephiusEngine.levelObjects.interfaces.ILevelInteractor;
	import SephiusEngine.math.MathUtils;

	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.FluidProperties;
	import nape.shape.Shape;
	import nape.shape.ShapeList;

	import tLotDClassic.GameData.Properties.DamageCollisionProperties;
	import tLotDClassic.GameData.Properties.objectsInfos.GameObjectGroups;
	
	/**
	 * Base class for spikes. Spikes are damager objects witch cause damage when a object touch the damager
	 * @author Fernando Rabello
	 */
	public class DamageCollisions extends GamePhysicalObject implements IDamagerObject {
		private var _enabled:Boolean;
		
		//private static var useOwnArt:Boolean = false;
		
		private var _shapes:ShapeList;
		
		public static var DAMAGE_COLLISIONS:Vector.<DamageCollisions> = new Vector.<DamageCollisions>();

		public function DamageCollisions(name:String, shapes:ShapeList, params:Object = null) {
			_shapes = shapes;
			super(name, params);
			
			updateCallEnabled = false;
			
			_attributes = new HarmfullObjectAttributes(this) as AttributeHolder;
			harmfullAttributes.enabled = true;
			
			var i:int = 0;
			var sLenght:int = shapes.length;
			var dAttParamName:String;
			var dsubAttParamName:String;
			var cDaAttributes:DamagerAttibutes;

			for (i = 0; i < sLenght; i++) {
				shapes.at(i);
				
				cDaAttributes = new DamagerAttibutes(harmfullAttributes);

				harmfullAttributes.damagerAttributes.push(cDaAttributes);
				cDaAttributes.currentID = shapes.at(i).userData.type + "-" + MathUtils.randomInt(1, 1000);
				cDaAttributes.hurtTime = 0;
				cDaAttributes.repeateTime = 1.0;
				cDaAttributes.damageConstraint = new DamageConstraint(harmfullAttributes.damagerAttributes[0].name);
				cDaAttributes.damageConstraint.addDefinitiveSufferName(harmfullAttributes.damagerAttributes[0].name);
				cDaAttributes.amplification = 1.0;
				cDaAttributes.weight = 10;
				cDaAttributes.pullDirection = -90;
				cDaAttributes.pullTypeID = 2;
				cDaAttributes.enabled = true;
				cDaAttributes.showZeroDamage = false;
				cDaAttributes.contact = _body;
				cDaAttributes.contactShape = shapes.at(i);

				cDaAttributes.targetGroups = new Vector.<GameObjectGroups>();
				cDaAttributes.targetGroups.push(GameObjectGroups.ALL);
				cDaAttributes.targetGroupFlag = GameObjectGroups.ALL.bitFlag;

				//cDaAttributes.targetGroups = new Vector.<GameObjectGroups>();
				var item:Class;

				updateDamagers();
			}
			
			_enabled = true;
			DAMAGE_COLLISIONS.push(this);
		}

		public static function getProperties(name:String):DamageCollisionProperties{
			switch(name)
			{
				case "SPIKE_TYPE_NORMAL_ROCK":
					name = DamageCollisionProperties.SPIKE_NORMAL_ROCK.varName;
					break;
			
				case "SPIKE_TYPE_DARK_ROCK":
					name = DamageCollisionProperties.SPIKE_DARK_ROCK.varName;
					break;
			
				case "SPIKE_TYPE_FROZEN_ROCK":
					name = DamageCollisionProperties.SPIKE_FROZEN_ROCK.varName;
					break;
			
				case "SPIKE_TYPE_ANCIENT_ROCK":
					name = DamageCollisionProperties.SPIKE_ANCIENT_ROCK.varName;
					break;
			
				case "SPIKE_TYPE_ICE":
					name = DamageCollisionProperties.SPIKE_ICY.varName;
					break;
			
				case "TYPE_EXTREME_HEAT":
					name = DamageCollisionProperties.EXTREME_HEAT.varName;
					break;
						
				case "TYPE_INTENSE_HEAT":
					name = DamageCollisionProperties.INTENSE_HEAT.varName;
					break;
			
				case "TYPE_HIGH_HEAT":
					name = DamageCollisionProperties.HIGH_HEAT.varName;
					break;
			
				default:
					break;
			}

			return DamageCollisionProperties[name];
		}

		public function get enabled():Boolean {return _enabled;}
		public function set enabled(value:Boolean):void {
			_enabled = value;
		}
		
		public function get damageConstraint():DamageConstraint {return _damageConstraint;}
		public function set damageConstraint(value:DamageConstraint):void {
			_damageConstraint = value;
		}
		private var _damageConstraint:DamageConstraint;
		
		public function damagerReaction(damage:DamageManager):void { 
		}
		
		/**
		 * Determine a secundary reaction wicth happens independly if damage.damager WillReact return true;
		 * @param	damage Infos about the damage calculations like, damage amount number, critical, overDamage.
		 */
		public function damagerSecundaryReaction(damage:DamageManager):void { 
		}
		
		/** Update damagers values and contacts.*/
		public function updateDamagers():void {
			var properties:DamageCollisionProperties;
			var dAttParamName:Object;
			var cDaAttributes:DamagerAttibutes;
			var index:int;
			var len:int = harmfullAttributes.damagerAttributes.length;

			for(index = 0; index < len; index++){
				cDaAttributes = harmfullAttributes.damagerAttributes[index];

				properties = getProperties(cDaAttributes.contactShape.userData.type);

				for (dAttParamName in properties.damagerAttributes){
					cDaAttributes[dAttParamName] = properties.damagerAttributes[dAttParamName];
				}
				
				cDaAttributes.natures = properties.natures;
				
				cDaAttributes.corruptionStatus = properties.corruptionStatus;
			}
		}
		
		override public function createPhysics():void {
			_cbTypes.add(GamePhysics.SPELL_INTERACTOR_CBTYPE);
			_cbTypes.add(GamePhysics.DAMAGER_CBTYPE);
			
			_interactionFilter = GamePhysics.DAMAGER_ETHERIAL_FILTER;
			
			var i:int = 0;
			var sLenght:int = _shapes.length;
			
			for (i = 0; i < sLenght; i++) {
				_shapes.at(i).cbTypes.merge(_cbTypes); 
				_shapes.at(i).filter = _interactionFilter;
				_shapes.at(i).fluidEnabled = true;
				_shapes.at(i).fluidProperties = new FluidProperties(0, 0);
				//_shapes.at(i).userData.numberOfContacts = 0;
			}
			
			_body = new Body(BodyType.STATIC);
			_body.shapes.merge(_shapes);
			_body.setShapeFluidProperties(new FluidProperties(0, 0));
			
			super.createPhysics();
		}
		
		override public function addPhysics():void {
			DamageCollisionsManager.DAMAGERS.push(this);
			super.addPhysics();
		}
		
		override public function removePhysics():void {
			if (!_physicAdded)
				return;
			DamageCollisionsManager.DAMAGERS.splice(DamageCollisionsManager.DAMAGERS.indexOf(this), 1);
			super.removePhysics();
		}
		
		public function shouldCorrupt(suffer:ILevelInteractor):Boolean {
			return true;
		}
		
		override public function destroy():void{
			super.destroy();
			if(DamageCollisions.DAMAGE_COLLISIONS.indexOf(this) != -1)
				DamageCollisions.DAMAGE_COLLISIONS.splice(DamageCollisions.DAMAGE_COLLISIONS.indexOf(this), 1);
		}
		
		/* INTERFACE SephiusEngine.levelObjects.interfaces.IDamagerObject */
		
		public function get inverted():Boolean {return false;}
		
		public function get attributes():AttributeHolder {return _attributes;}
		public function set attributes(value:AttributeHolder):void {_attributes = value;}
		private var _attributes:AttributeHolder;
		public function get damagerAttributes():IDamagerAttributes { return _attributes as IDamagerAttributes; }
		public function get harmfullAttributes():HarmfullObjectAttributes { return _attributes as HarmfullObjectAttributes; }
	}
}