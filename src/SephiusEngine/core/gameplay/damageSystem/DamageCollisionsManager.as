package SephiusEngine.core.gameplay.damageSystem 
{
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.GamePhysics;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.IDamagerAttributes;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.IStatusAttributes;
	import SephiusEngine.core.gameplay.attributes.holders.interfaces.ISufferAttributes;
	import SephiusEngine.core.gameplay.attributes.subAttributes.DamagerAttibutes;
	import SephiusEngine.core.gameplay.attributes.subAttributes.SufferAttributes;
	import SephiusEngine.core.gameplay.damageSystem.DamageManager;
	import SephiusEngine.displayObjects.AnimationPack;
	import SephiusEngine.levelObjects.interfaces.IDamagerObject;
	import SephiusEngine.levelObjects.interfaces.ISufferObject;
	import SephiusEngine.math.MathVector;
	import SephiusEngine.utils.pools.RectanglePool;

	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	import nape.dynamics.Arbiter;
	import nape.geom.Ray;
	import nape.geom.RayResult;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.space.Space;

	import org.osflash.signals.Signal;

	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;

	import tLotDClassic.GameData.Properties.objectsInfos.GameObjectGroups;
	import tLotDClassic.attributes.AttributesConstants;
	import starling.utils.MatrixUtil;
	import SephiusEngine.core.gameStates.LevelManager;
	/**
	 * ...
	 * @author Fernando Rabello
	 * This class has logic that determine in witch cases system should verify collisions between objects collision boxes (combat, nor physic)
	 * Collision verification is greatter reduced.
	 * This class also call damage methods when collisions happens, and control witch informations should be sent tho this methods. 
	 */
	public class DamageCollisionsManager {
		public static var disableCollisions:Boolean = false;
		public static var disableDamages:Boolean = false;
		public static var usePhysicOcclusion:Boolean = true;
		
		public static var DAMAGERS:Vector.<IDamagerObject> = new Vector.<IDamagerObject>();
		public static var SUFFERS:Vector.<ISufferObject> = new Vector.<ISufferObject>();
		// ---------- Colliding objects at a particular frame/loop ----- //
		
		// ---------- Loop vars ----- //
		private static var index:int;
		private static var index2:int;
		private static var index3:int;
		private static var index4:int;
		private static var index5:int;
		
		// ---------- Colliding rectangles at a particular frame/loop ----- //
		private static var bodyCollision1Rect:Rectangle;
		private static var bodyCollision2Rect:Rectangle;
		private static var damageableCollisionRect:Rectangle;
		
		private static var damagerCollisionRect:Rectangle;
		private static var sufferCollisionRect:Rectangle;
		
		// ------ Colliding results at a particular frame/loop ----- //
		private static var collisionHappened:Boolean;
		public static var damageContactHappened:Signal = new Signal(Rectangle);
		
		/** Area where a damage happen. Normally the intersection of 2 rectagles */
		private static var collisionArea:Rectangle;
		/** Location where a damage happen (the center of the damage area) */
		private static var collisionLocation:MathVector = new MathVector();
		
		private static var verbose:Boolean = false;
		private static var missedVerbose:Boolean = false;
		
		private static var helperDamagerRect:Rectangle = new Rectangle();
		private static var helperSufferRect:Rectangle = new Rectangle();
		
		private static var helperHurterRect1:Rectangle = new Rectangle();
		private static var helperHurterRect2:Rectangle = new Rectangle();
		private static var rootObject:Sprite;
		private static var stateProperties:Object = {};
		private static var helperLocalPoint:Point = new Point();
		private static var helperGlobalPoint:Point = new Point();
		private	static var hDamagerArbiter:Arbiter;

		private static var hCurrentDamagerA:DamagerAttibutes;
		private static var hDamagerContactClass:Class;
		private static var hDamagerContactIsBody:Boolean;

		private static var hCurrentSufferA:SufferAttributes;
		private static var hSufferContactClass:Class;
		
		private static var dbDRect:Rectangle = new Rectangle();
		private static var dbSRect:Rectangle = new Rectangle();
		
		private static var damager:IDamagerObject;
		private static var suffer:ISufferObject;
		private static var cDamagerA:IDamagerAttributes;
		private static var cSufferA:ISufferAttributes;
		
		private static var sufferInAvertGroup:Boolean;		
		private static var sufferInAvertList:Boolean;		
		private static var sufferIsTargetGroup:Boolean;		

		private static var DCHasSufferHolder:Boolean;		
		private static var DCHasSuffer:Boolean;
		
		private static var tooFar:Boolean;
		/**
		 * Checks interactions collision 
		 */
		public static function update(timePassed:Number):void {
			if (!damageContactHappened)
				damageContactHappened = new Signal(Rectangle);
			
			rootObject = GameEngine.instance.state.view.originDysplayObject;
			
			if (!disableCollisions) {
				verifyDamageContacts();
			}
		}
		
		private static var suffersLength:int = 0
		private static var sufferAttributesLength:int = 0
		private static var origin:String = "";
		private static var contacts:Dictionary = new Dictionary();
		private static function verifyDamageContacts():void {
			var cRectToPool:Rectangle;
			for each (cRectToPool in contacts){
				RectanglePool.returnRectangle(cRectToPool);
			}
				
			contacts = new Dictionary();

			if (DAMAGERS.length > 0) {
				for (index = 0; index < DAMAGERS.length; index++){
					damager = DAMAGERS[index] as IDamagerObject;
					cDamagerA = damager.attributes as IDamagerAttributes;
					
					if (damager.enabled && damager.damagerAttributes.enabled && damager.damagerAttributes.collisionEnabled) {
						for (index2 = 0; index2 < cDamagerA.damagerAttributes.length; index2++ ) {
							hCurrentDamagerA = cDamagerA.damagerAttributes[index2];
							if (hCurrentDamagerA.enabled && hCurrentDamagerA.contact) {
								hDamagerContactClass = hCurrentDamagerA.contactClass;
								hDamagerContactIsBody = hDamagerContactClass == Body;

								suffersLength = hDamagerContactIsBody ? (hCurrentDamagerA.contact as Body).arbiters.length : SUFFERS.length;
								
								for (index3 = 0; index3 < suffersLength; index3++) {
									if (hDamagerContactIsBody) {
										if(index3 < (hCurrentDamagerA.contact as Body).arbiters.length){
											hDamagerArbiter = (hCurrentDamagerA.contact as Body).arbiters.at(index3);
											hCurrentSufferA = hDamagerArbiter.shape2.userData.sufferAttribute as SufferAttributes;
										}
										
										if((hCurrentSufferA && hDamagerArbiter) && hDamagerArbiter.shape1 == hCurrentDamagerA.contactShape){
											suffer = hCurrentSufferA.holder.sufferParent;
											cSufferA = suffer.attributes as ISufferAttributes;
										}
									}
									else {
										suffer = SUFFERS[index3];
										cSufferA = suffer.attributes as ISufferAttributes;
									}
									
									if (suffer && suffer != damager && suffer.enabled && suffer.sufferAttributes.enabled && suffer.sufferAttributes.collisionEnabled) {
										//Optimization: avoid collisions from objects too far from eachother
										tooFar = (Math.abs(damager.x - suffer.x) > AttributesConstants.maxDamageCollisionDistance ||
												Math.abs(damager.y - suffer.y) > AttributesConstants.maxDamageCollisionDistance);
										
										if(!tooFar || hDamagerContactIsBody){
											if (!(cSufferA as IStatusAttributes) || ((cSufferA as IStatusAttributes) && (hDamagerContactIsBody || (cSufferA as IStatusAttributes).status.statusConditions.damageInvunerable == false))) {
												
												sufferAttributesLength = hDamagerContactIsBody ? 1 : cSufferA.sufferAttributes.length;
												
												for (index4 = 0; index4 < sufferAttributesLength; index4++) {
													if (hDamagerContactClass != Body)
														hCurrentSufferA = cSufferA.sufferAttributes[index4]
													
													if(hCurrentSufferA && hCurrentSufferA.enabled && hCurrentSufferA.contact){
														sufferInAvertGroup = GameObjectGroups.hasGroup(hCurrentDamagerA.avertGroupFlag, hCurrentSufferA.groupFlag);
														sufferInAvertList = cDamagerA.avertSuffers.length && cDamagerA.avertSuffers.indexOf(suffer) != -1;

														if (!sufferInAvertList && hCurrentDamagerA.avert != suffer && !(sufferInAvertGroup && hCurrentDamagerA.target != suffer)) {
															
															sufferIsTargetGroup = GameObjectGroups.hasGroup(hCurrentDamagerA.targetGroupFlag, hCurrentSufferA.groupFlag);
															
															if ((hCurrentDamagerA.target == suffer || (!hCurrentDamagerA.targetExclusive && sufferIsTargetGroup))) {
																
																DCHasSufferHolder = hCurrentDamagerA.damageConstraint.verifySufferName(hCurrentSufferA.holder.sufferParent.name, hCurrentDamagerA.currentID);
																DCHasSuffer =       hCurrentDamagerA.damageConstraint.verifySufferName(hCurrentSufferA.currentID, hCurrentDamagerA.currentID);
																
																if (!DCHasSufferHolder && !DCHasSuffer) {
																	hSufferContactClass = hCurrentSufferA.contactClass;

																	//This if is a optimization, make bound calculation only once per tick.	
																	if(!contacts[hCurrentSufferA]){
																		//Calculate suffer boundss
																		if (hDamagerContactIsBody || hSufferContactClass == Number)
																			sufferCollisionRect = null;
																		if (hSufferContactClass == Quad || hSufferContactClass == Image)
																			sufferCollisionRect = hCurrentSufferA.contact.getBounds( rootObject, RectanglePool.getRectangle() );	
																		else if(hSufferContactClass == AnimationPack)
																			sufferCollisionRect = (hCurrentSufferA.contact as AnimationPack).getFrameBounds(rootObject, RectanglePool.getRectangle(), hCurrentSufferA.cropBoundLeft, hCurrentSufferA.cropBoundRight, hCurrentSufferA.cropBoundTop, hCurrentSufferA.cropBoundButtom )
																		else if (hSufferContactClass == Rectangle){
																			sufferCollisionRect = RectanglePool.getRectangleFromOther(hCurrentSufferA.contact as Rectangle);//And the matrix transformation???
																		}
																		
																		contacts[hCurrentSufferA] = sufferCollisionRect;
																	}
																	else
																		sufferCollisionRect = contacts[hCurrentSufferA];//If rectangle already exist, just use preexising rect

																	//This if is a optimization, make bound calculation only once per tick.
																	if(!contacts[hCurrentDamagerA]){
																		//damagerContacts[index] = RectanglePool.getRectangle();//Retrive new rectangle from the pool.

																		//Calculate damager's bounds
																		if(hDamagerContactClass == Quad || hDamagerContactClass == Image)
																			damagerCollisionRect = hCurrentDamagerA.contact.getBounds( rootObject, RectanglePool.getRectangle() );
																		else if(hDamagerContactClass == AnimationPack)
																			damagerCollisionRect = (hCurrentDamagerA.contact as AnimationPack).getFrameBounds(rootObject, RectanglePool.getRectangle(), hCurrentDamagerA.cropBoundLeft, hCurrentDamagerA.cropBoundRight, hCurrentDamagerA.cropBoundTop, hCurrentDamagerA.cropBoundButtom );
																		else if (hDamagerContactClass == Rectangle){
																			damagerCollisionRect = RectanglePool.getRectangleFromOther(hCurrentDamagerA.contact as Rectangle);//And the matrix transformation???
																			damagerCollisionRect.x += hCurrentDamagerA.cropBoundLeft;
																			damagerCollisionRect.y += hCurrentDamagerA.cropBoundTop
																			damagerCollisionRect.width -= hCurrentDamagerA.cropBoundLeft + hCurrentDamagerA.cropBoundRight;
																			damagerCollisionRect.height -= hCurrentDamagerA.cropBoundTop + hCurrentDamagerA.cropBoundButtom;
																			damagerCollisionRect.height -= hCurrentDamagerA.cropBoundTop + hCurrentDamagerA.cropBoundButtom;
																		}
																		else
																			damagerCollisionRect = null;

																		contacts[hCurrentDamagerA] = damagerCollisionRect;
																	}
																	else	
																		damagerCollisionRect = contacts[hCurrentDamagerA];

																	//Body contact for damager we alrady know collision happened so its true
																	if (hDamagerContactIsBody){
																		collisionHappened = true;
																		origin = "Physic Body Collision";
																	}
																	else if (hDamagerContactClass == Number) {
																		//Distance contact for both Damager and Suffer = Distance between + suffer radius ? damager radius
																		if (hSufferContactClass == Number) {
																			collisionHappened = (pointPointDist(damager.x, damager.y, suffer.x, suffer.y) + (hCurrentSufferA.contact as Number)) >  (hDamagerContactClass == Number);
																			origin = "Distance Point to Point Collision";
																		}
																		//Distance contact for damager and rect for suffer = Distance between point to the rect > damager radius
																		else {
																			iDistance.x = damager.x - suffer.x;
																			iDistance.y = damager.y - suffer.y;
																			iDistance.length = pointRectDist(damager.x, damager.y, sufferCollisionRect.x, sufferCollisionRect.y, sufferCollisionRect.width, sufferCollisionRect.height);
																			collisionHappened = iDistance.length < (hCurrentDamagerA.contact as Number);
																			origin = "Distance Point to Rect Collision";
																		}															
																	}
																	//Both rect contact for both damager and suffer = intersection between both rects
																	else {
																		collisionArea = damagerCollisionRect.intersection(sufferCollisionRect);
																		collisionHappened = collisionArea.height > 0 ? true : false;
																		origin = "Rect Intersection Collision";
																	}
																	
																	if (collisionHappened) {
																		defineContactPosition(hDamagerContactClass, hSufferContactClass);
																		
																		if (verbose)
																			log("[DCM]-- attack collision happen --" + " agressor:" + hCurrentDamagerA.currentID + " suffer:" + hCurrentSufferA.currentID);
																		
																		if(!disableDamages)	
																			DamageManager.getDamageManager().processDamage(hCurrentDamagerA, hCurrentSufferA, origin, collisionLocation);
																		hCurrentDamagerA.damageConstraint.addSufferName(hCurrentSufferA.currentID, hCurrentDamagerA.repeateTime, hCurrentDamagerA.currentID);

																		collisionArea = null;
																	}
																	else {
																		if (verbose && missedVerbose)
																			log("[DCM]-- attack collision missed --" + " agressor:" + hCurrentDamagerA.currentID + " suffer:" + hCurrentSufferA.currentID);
																	}
																}
																else if (verbose && missedVerbose)
																	log("[DCM] Suffer " + suffer.name + " is on Damager "  + damager.name + " Constraint list " + (DCHasSuffer && !DCHasSufferHolder));
															}
															else if (verbose && missedVerbose)
																log("[DCM] Damager " + damager.name + " is Target exclusive and suffer " + suffer.name + " is not target (" + (hCurrentDamagerA.target != suffer && hCurrentDamagerA.targetExclusive) + ")");
														}
														else if (verbose && missedVerbose)
															log("[DCM] Suffer " + suffer.name + " is Avert for Damager " + damager.name + " (" + (hCurrentDamagerA.avert == suffer) + ") or is from Avert Group: (" + (sufferInAvertGroup) + ")");
													}
													else if (verbose && missedVerbose)
														log("[DCM] hCurrentSufferA is null");
												}
											}
											else if (verbose && missedVerbose)
												log("[DCM] Suffer " + suffer.name + "can´t be damaged because a status DI(" + (suffer.attributes as IStatusAttributes).status.statusConditions.damageInvunerable + ") DAM(" + (suffer.attributes as IStatusAttributes).status.statusConditions.damaged + ") DeFDAM (" + (suffer.attributes as IStatusAttributes).status.statusConditions.defenceDamaged + ")");
										}
									}
									//else if (verbose && missedVerbose)
										//log("[DCM] Suffer " + suffer.name + " is Damager " + damager.name + " " + (suffer != damager) + " or Suffer is disabled + " + (!suffer.enabled) + " or has collisiion disabled: " + suffer.sufferAttributes.collisionEnabled);
									
									//suffersLength = hDamagerContactIsBody ? (hCurrentDamagerA.contact as Body).arbiters.length : SUFFERS.length;
									
									cSufferA = null;
									suffer = null;
								}
							}
							//else if (verbose && missedVerbose)
								//log("[DCM] damager Attribured " + damager.name + " is disalbed: " + hCurrentDamagerA.enabled);
						}
					}
					else if (verbose && missedVerbose)
						log("[DCM] damager " + damager.name + "is not enabled or has collisions disabled (" + damager.enabled + " / " + damager.damagerAttributes.collisionEnabled + ")");
				}
			}
			else if (verbose && missedVerbose)
				log("[DCM]there is no Damager added. Nothing to calculate");
		}
		
		private static var iDistance:Vec2;
		
		private static var cx:Number;
		private static var cy:Number;
		private static function pointRectDist (px:Number, py:Number, rx:Number, ry:Number, rwidth:Number, rheight:Number):Number{
			cx = Math.max(Math.min(px, rx + rwidth ), rx);
			cy = Math.max(Math.min(py, ry + rheight), ry);
			return Math.sqrt( (px - cx) * (px - cx) + (py - cy) * (py - cy) );
		}
		
		private static var distance:Vec2 = new Vec2();
		private static function pointPointDist(px:Number, py:Number, rx:Number, ry:Number):Number{
			distance.x = px - rx;
			distance.y = py - ry;
			
			return distance.length;
		}
		
		private var ray:Ray = new Ray(Vec2.weak(), Vec2.weak());
		private var rayResult:RayResult;
		private var reflectAngle:Number;
		private var space:Space;
		private var damageOccluded:Boolean;
		/* This is not fully implemented yet, could prevent damagers from deal damage if there ia platform between them */
		private function veryfyPhysicOcclusion(damager:IDamagerObject, suffer:ISufferObject):Boolean{
			distance.x = damager.x - suffer.x;
			distance.y = damager.y - suffer.y;
			
			damageOccluded = LevelManager.getInstance().physics.rayCast(Vec2.weak(damager.x, damager.y), Vec2.weak(distance.x, distance.y));

			return damageOccluded;

			/*
			ray.origin.x = damager.x;
			ray.origin.y = damager.y;
			ray.direction = distance;
			ray.maxDistance = distance.length;
			
			if(ray.direction.length > 0.1){
				rayResult = space.rayCast(
					ray,
					false,
					GamePhysics.PARTICLE_FILTER
				);
			}

			if (rayResult)
				return true;
			else
				return false;*/
		}
		
		private static function defineContactPosition(damagerContactClass:Class, sufferContactClass:Class):void {
			damageContactHappened.dispatch(collisionArea);
			if ((damagerContactClass == Rectangle || damagerContactClass == Quad || damagerContactClass == Image || damagerContactClass == AnimationPack) && 
			(sufferContactClass == Rectangle || damagerContactClass == Quad || damagerContactClass == Image || damagerContactClass == AnimationPack)){
				//Define collision location on starling screen coordinate
				collisionLocation.x = collisionArea.x + collisionArea.width * .5;
				collisionLocation.y = collisionArea.y + collisionArea.height * .5;
			}
			else if (damagerContactClass == Body) {
				if(hDamagerArbiter.isCollisionArbiter()){
					collisionLocation.x = hDamagerArbiter.collisionArbiter.contacts.at(0).position.x;
					collisionLocation.y = hDamagerArbiter.collisionArbiter.contacts.at(0).position.y;
				}
				else if(hDamagerArbiter.isFluidArbiter()){
					collisionLocation.x = hDamagerArbiter.fluidArbiter.position.x;
					collisionLocation.y = hDamagerArbiter.fluidArbiter.position.y;
				}
				else {
					throw Error ("DCM - can only define contact position for collision arbiters and fluid arbiters, collision type is neither");
					//collisionLocation.x = hDamagerArbiter.fluidArbiter.position.x;
					//collisionLocation.y = hDamagerArbiter.fluidArbiter.position.y;
				}
				hDamagerArbiter = null;
			}
			else if (damagerContactClass == Number) {
				collisionLocation.x = damager.x + iDistance.x;
				collisionLocation.y = damager.y + iDistance.y;
			}
			else
				throw Error ("Incorrect combination of contact classes, can´t define contact position");
		}
		
        private static function log(message:String):void {
            if (verbose) trace("[DCM]:", message);
        }
        
	}
}

class PrivateClass{}