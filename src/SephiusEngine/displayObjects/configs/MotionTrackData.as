package SephiusEngine.displayObjects.configs
{

	
	/**
	 * Motion Track Data is a class to store motion tracking information
	 * Motion tacking information could be uses do other classes to animate objects using motion traking.
	 * A good program to perform motion tracking is After Effects witch motion tracking data could be just copy (cntr+c) and used here.
	 * @author Fernando Rabello
	 */
	public class MotionTrackData{
		/** A name to identify this tracking data. If you want to match a texture animation with a tracking animation just use same names o tracking and texture animation */
		//public var animations:Dictionary = new Dictionary();
		
		public var width:Number;
		public var height:Number;
		
		public var offsetX:Number;
		public var offsetY:Number;
		
		public var objectWidth:Number;
		public var objectHeight:Number;
		
		public var centerlize:Boolean;
		
		/** ----------------------------------------------------- */
		/** ------------------- Creatures ----------------------- */
		/** ----------------------------------------------------- */
		
		/** Properties with names like game animation uses. Avoiding use dictionary witch is dynamic and heavy to acess */
		public var StayingLoop:Vector.<ViewData>;
		public var WalkingFrontLoop:Vector.<ViewData>;
		public var Walking2FrontLoop:Vector.<ViewData>;
		public var WalkingBackLoop:Vector.<ViewData>;
		public var Walking2BackLoop:Vector.<ViewData>;
		public var FlyingLoop:Vector.<ViewData>;
		public var Landing:Vector.<ViewData>;
		public var FallingStart:Vector.<ViewData>;
		public var FallingLoop:Vector.<ViewData>;
		
		public var Jumping:Vector.<ViewData>;
		
		public var Defence:Vector.<ViewData>;
		public var DefenceHit:Vector.<ViewData>;
		
		public var ChangingToPose1:Vector.<ViewData>;
		public var ChangingToPose2:Vector.<ViewData>;
		public var ChangingToPose3:Vector.<ViewData>;
		
		public var Attack1:Vector.<ViewData>;
		public var Attack2:Vector.<ViewData>;
		public var Attack3:Vector.<ViewData>;
		public var Attack4:Vector.<ViewData>;
		public var Attack5:Vector.<ViewData>;
		
		public var AirAttack1:Vector.<ViewData>;
		public var AirAttack2:Vector.<ViewData>;
		public var AirAttack3:Vector.<ViewData>;
		public var AirAttack4:Vector.<ViewData>;
		public var AirAttack5:Vector.<ViewData>;
		
		public var Damage:Vector.<ViewData>;
		public var Death:Vector.<ViewData>;
		public var Risen:Vector.<ViewData>;
		public var DyingStart:Vector.<ViewData>;
		public var DyingLoop:Vector.<ViewData>;
		public var LosingEssenceStart:Vector.<ViewData>;
		public var LosingEssenceLoop:Vector.<ViewData>;
		
		public var Action1:Vector.<ViewData>;
		public var Action2:Vector.<ViewData>;
		public var Action3:Vector.<ViewData>;
		public var Action4:Vector.<ViewData>;
		public var Action5:Vector.<ViewData>;
		
		public var Spell1:Vector.<ViewData>;
		public var Spell2:Vector.<ViewData>;
		public var Spell3:Vector.<ViewData>;
		public var Spell4:Vector.<ViewData>;
		public var Spell5:Vector.<ViewData>;
		
		/** ----------------------------------------------------- */
		/** ------------------- Alkatho ------------------------- */
		/** ----------------------------------------------------- */
		
		public var EssenceLoop:Vector.<ViewData>;     
		public var EssenceStart:Vector.<ViewData>;     
		public var Jump:Vector.<ViewData>;     
		public var Walking1Loop:Vector.<ViewData>;     
		public var Walking1BackLoop:Vector.<ViewData>;     
		public var AirJumping:Vector.<ViewData>;     
		
		/** ----------------------------------------------------- */
		/** ------------------- Alkamo ------------------------- */
		/** ----------------------------------------------------- */
		
		public var ChangeToPose1:Vector.<ViewData>;     
		public var ChangeToPose2:Vector.<ViewData>;
		public var ShieldEnd:Vector.<ViewData>;
		public var ShieldHit:Vector.<ViewData>;
		public var ShieldStart:Vector.<ViewData>;
		public var ShieldStayingLoop:Vector.<ViewData>;
		public var SpearReady:Vector.<ViewData>;
		public var WalkingLoop:Vector.<ViewData>;
		
		/** ----------------------------------------------------- */
		/** ------------------- Bosses ------------------------- */
		/** ----------------------------------------------------- */
		
		public var AbsorbingLoop:Vector.<ViewData>;     
		public var AbsorbingStart:Vector.<ViewData>;     
		public var AbsorbingEnd:Vector.<ViewData>;     
		public var JumpingAir:Vector.<ViewData>;     
		public var StandingLoop :Vector.<ViewData>;     
		public var ClawAttack1 :Vector.<ViewData>;     
		public var ClawAttack2 :Vector.<ViewData>;     
		public var ClawAttack3 :Vector.<ViewData>;     
		public var LandingAttack :Vector.<ViewData>;     
		public var RunningAttack :Vector.<ViewData>;     
		public var RunningStart :Vector.<ViewData>;     
		public var RunningLoop :Vector.<ViewData>;     
		public var Screaming :Vector.<ViewData>;     
		public var Dodge :Vector.<ViewData>;     
		
		/** ----------------------------------------------------- */
		/** ------------------- Sephius ------------------------- */
		/** ----------------------------------------------------- */
		
		public var standingLoop:Vector.<ViewData>;       					
		public var walkingLoop:Vector.<ViewData>;
		public var pushingLoop:Vector.<ViewData>;
		public var runningLoop:Vector.<ViewData>;
		public var runningStart:Vector.<ViewData>;
		public var stopRunning:Vector.<ViewData>;
		public var turning:Vector.<ViewData>;
		public var stoping:Vector.<ViewData>;            					
		public var skidLoop:Vector.<ViewData>;           					
		public var duckingLoop:Vector.<ViewData>;
		public var duckingStart:Vector.<ViewData>;       					
		public var jump:Vector.<ViewData>;               					
		public var glidingLoop:Vector.<ViewData>;	   	  					
		public var glidingStart:Vector.<ViewData>;	   	  					
		public var landing:Vector.<ViewData>;		  	  					
		public var fallingLoop:Vector.<ViewData>;	   	  					
		public var fallingStart:Vector.<ViewData>;	   	  					
		public var hurtLand:Vector.<ViewData>;        	  					
		public var hurtFront:Vector.<ViewData>;          					
		public var hurtBack:Vector.<ViewData>;        	  					
		public var flyingLoop:Vector.<ViewData>;         					
		public var flyingEnd:Vector.<ViewData>;      	  					
		public var flyingStart:Vector.<ViewData>;     	  					
		public var flyingFlapWings:Vector.<ViewData>;    					
		public var dodge:Vector.<ViewData>;    	   	  					
		public var death:Vector.<ViewData>;    	  	  					
		public var absorptionEnd:Vector.<ViewData>;   	  					
		public var absorptionLoop:Vector.<ViewData>;     					
		public var absorptionStart:Vector.<ViewData>;    					
		
		public var castingLoop:Vector.<ViewData>;             				
		public var startCast:Vector.<ViewData>;             	 			
		public var weakSpellNormal:Vector.<ViewData>;    		 			
		public var weakSpellUp:Vector.<ViewData>;    			 			
		public var weakSpellDown:Vector.<ViewData>;    		 			
		public var weakSpellAirNormal:Vector.<ViewData>;    	 			
		public var weakSpellAirUp:Vector.<ViewData>;    		 			
		public var weakSpellAirDown:Vector.<ViewData>;    		 			
		public var strongAtackSpellNormal:Vector.<ViewData>;  	 			
		public var strongAtackSpellUp:Vector.<ViewData>;   	 			
		public var strongAtackSpellDown:Vector.<ViewData>;   	 			
		public var strongAtackSpellAirNormal:Vector.<ViewData>; 			
		public var strongAtackSpellAirUp:Vector.<ViewData>;   	  			
		public var strongAtackSpellAirDown:Vector.<ViewData>;   			
		public var strongDefenceSpell:Vector.<ViewData>; 		  			
		
		public var usingItemGround:Vector.<ViewData>;						
		public var usingItemAir:Vector.<ViewData>;   						
		
		public var lightAttackRight:Vector.<ViewData>;      				
		public var lightAttackLeft:Vector.<ViewData>;       				
		public var heavyGroundAttack:Vector.<ViewData>;     				
		public var mediumAttack:Vector.<ViewData>;           				
		public var lightAirAttackRight:Vector.<ViewData>;  	 			
		public var lightAirAttackLeft:Vector.<ViewData>;   	 			
		public var heavyAirAttack:Vector.<ViewData>;        				
		public var duckAttack:Vector.<ViewData>;      		 	 			
		public var hammerFall:Vector.<ViewData>;         					
		public var hammerAttack:Vector.<ViewData>;        	 	 			
		public var hammerJump:Vector.<ViewData>;         					
		public var longShorriuken:Vector.<ViewData>;     	 	 			
		public var shortShorriuken:Vector.<ViewData>;   	  	 			
		public var chargeAttack:Vector.<ViewData>;   	  					
		
		public var percingAirAttackRight:Vector.<ViewData>;   				
		public var percingGroundAttackRight:Vector.<ViewData>; 			
		public var percingAirAttackLeft:Vector.<ViewData>;   				
		public var percingGroundAttackLeft:Vector.<ViewData>;  			
		
		public var razanteAttack:Vector.<ViewData>;						
		
		public var shieldLoop:Vector.<ViewData>;          	 				
		public var shieldIn:Vector.<ViewData>;            	 				
		public var shieldWalkFrontLoop:Vector.<ViewData>; 	 				
		public var shieldWalkBackLoop:Vector.<ViewData>;  	 				
		public var shieldOut:Vector.<ViewData>;          	 				
		public var shieldDamage:Vector.<ViewData>;       	 				
		
		public var animatonsUsed:Vector.<String> = new Vector.<String>();
		
		public var objectBaseName:String;
		
		public function MotionTrackData(objectBaseName:String) {
			this.objectBaseName = objectBaseName;
		}
		
		public function addMotionTrackData(animationName:String, motionTrackingData:Array, width:Number = 0, height:Number = 0, centerlize:Boolean = true, offsetX:Number = 0 , offsetY:Number = 0, objectWidth:Number=1, objectHeight:Number=1):Boolean {
			this.width = width;
			this.height = height;
			this.centerlize = centerlize;
			
			var position:ViewData;
			var frame:int = 0;
			this.offsetX = offsetX;
			this.offsetY = offsetY;
			
			this.objectWidth = objectWidth;
			this.objectHeight = objectHeight;
			
			for each (position in motionTrackingData) {
				if (centerlize) {
					//position.x -= offsetX;
					//position.y -= offsetY;
					position.x -= (width * .5);
					position.y -= (height * .5);
					position.frame = frame;
					frame++;
				}
			}
			
			if (!this[animationName]) {
				animatonsUsed.push(animationName);
				this[animationName] = Vector.<ViewData>(motionTrackingData);
				return true;
			}
			else{
				throw Error("MOTION TRACK: animation already exist in this motion track data");
			}
			
			return false;
		}
		
		/** Create a Motion Track Data by transforming a copy of another Motion Track Data. Usefull to reuse MTD with other object that is the same but is on anothter resolution */
		public static function getTransformedMTD(objectBaseName:String, motionTracking:MotionTrackData, newWidth:Number = 1, newHeight:Number = 1, centerlize:Boolean = true, newFactor:Number = 1):MotionTrackData {
			var newMTD:MotionTrackData = new MotionTrackData(objectBaseName);
			
			newMTD.animatonsUsed = motionTracking.animatonsUsed.concat();
			var animationName:String;
			var oldPosition:ViewData;
			var newPosition:ViewData;
			var factor:Number = newWidth / motionTracking.width;
			
			for each (animationName in newMTD.animatonsUsed) {
				newMTD[animationName] = new Vector.<ViewData>();
				newMTD[animationName].length = motionTracking[animationName].length;
				
				for each (oldPosition in motionTracking[animationName]) {
					newPosition = new ViewData(oldPosition.name, oldPosition.x, oldPosition.y, oldPosition.z, oldPosition.rotation, oldPosition.zoom, oldPosition.scaleX, oldPosition.scaleY, oldPosition.scaleZ, oldPosition.frame);
					
					if (motionTracking.centerlize) {
						newPosition.x += motionTracking.width * .5;
						newPosition.y += motionTracking.height * .5;
					}
					
					newPosition.x *= newFactor * factor;
					newPosition.y *= newFactor * factor;
					newPosition.z *= newFactor * factor;
					
					if (centerlize) {
						newPosition.x -= newWidth * .5;
						newPosition.y -= newHeight * .5;
					}
					
					newMTD[animationName][oldPosition.frame] = newPosition;
				}
			}
			
			newMTD.centerlize = centerlize;
			newMTD.width = newWidth;
			newMTD.height = newHeight;
			newMTD.offsetX = motionTracking.offsetX;
			newMTD.offsetY = motionTracking.offsetY;
			newMTD.objectWidth = motionTracking.objectWidth;
			newMTD.objectHeight = motionTracking.objectHeight;
			
			return newMTD;
		}
	}
}