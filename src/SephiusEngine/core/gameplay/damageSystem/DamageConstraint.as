package SephiusEngine.core.gameplay.damageSystem
{
	import com.greensock.TweenMax;

	import flash.utils.ByteArray;
	
	/**
	 * This class manages the number of hits per second for each hurter object in the game.
	 * For exemple, without any damage menange a simple attack will cause repeatly damage every single frame.
	 * On the other side, if a suffer object simple become invunerable for attacks for some frames, it will not be hurted by other hurters at that time.
	 * So this kind of sollution if very limited due a type of damage that has a long delay time will influence others damages will less dalay times.
	 * This class is intanciated by every hurt object (like: Sephius, Enemys, DamageObjects, Spells). Each object has it own DamageControl instance.
	 * When a hurt object hit some suffer object, this class will add it´s name to a list. 
	 * In the next possible hits, this class will verify the suffers names if they are in this list.
	 * If a particular suffer object is in the list, it´s mean it alrady suffer a damage and will tell the the InteractionTrigger class to ignore the hit.
	 * Once a name is added this class will remove the name automatically after a specified time (each type of damage will tell it delay time).
	 * Once the suffer name is removed from the list it can suffer damages from this hurter object again.
	 * So, with this class, it´s possible to create very complex simultaneous damage conditions without have interference problems.
	 * Note that every suffer object still have it´s own invunerable status but that status are used for other types os gameplay elements.
	 * @author Fernando Rabello
	 */
	
	public class DamageConstraint{
		/**
		 * Name of objects that the damager already cause damage.
		 */
		public var suffersNames: Vector.<String> = new Vector.<String>;
		public var definitiveSuffersNames: Vector.<String> = new Vector.<String>;
		/**
		 * for debug proposes. Show the name of the object that owns this damageControl
		 */
		public var damagerName:String;
		public static var verbose:Boolean = false;
		
		public function DamageConstraint (damagerName:String){
			this.damagerName = damagerName;
			//trace ("damageControl: " + damagerName)
		}
		
		public function dispose():void {
			suffersNames.length = 0;
			definitiveSuffersNames.length = 0;
			TweenMax.killTweensOf(removeSufferName);
		}
		
		/**
		 * Add the name of the object that is suffering the damage from the hurter to the SuffersNamesList
		 * Once the suffer is in this list, it could not take new damages from this hurter until it´s name is removed.
		 * @param name the name of the objet that is suffering the damage
		 * @param time amount of time (seconds) that suffer should stay in the SuffersNamesList.
		 * @param attackName optional param, add a attack name to the suffer name. Can be used to differentiate diferent attack types from the same attacker, so this attacks will not in conflict time with each other.
		 */			
		public function addSufferName(name:String, time:Number, attackName:String = null):void{
			//trace ("é pra adicionar " + attackName + " / time: " + time + " / attackName:" + attackName);
			if (time == 0)
				return;
			
			if (attackName){
				stringBuilder.writeUTFBytes(attackName);
				stringBuilder.writeUTFBytes(name);
				attName = stringBuilder.toString();
				stringBuilder.clear();			
				
				suffersNames.push(attName)
				TweenMax.delayedCall(time, removeSufferName, [attName]);
				//TweenMax.to(this, 0, {delay:time, onComplete:removeSufferName, onCompleteParams:[attackPlusSufferName], overwrite:false } );
				
				//log(damagerName + " - " + "name: " + attackName + "." + name + " added to damageControl for " + time + " seconds");
			}
			else{
				suffersNames.push(name);
				TweenMax.delayedCall(time, removeSufferName, [name]);
				//TweenMax.to(this, 0, {delay:time, onComplete:removeSufferName, onCompleteParams:[name], overwrite:false } );
			 	//log(damagerName + " - " + "name: " + name + " added to damageControl for " + time + " seconds");
			}
			
			//Use like a timeOut for call a function after some time. Unlike a timeOut, TweenMax remove itself after it finish.
			
		}
		
		/**
		 * Add the name of the object that is suffering the damage from the hurter to the SuffersNamesList definitivly.
		 * Once the suffer is in this list, it will never be removed unless the remove function is manually called.
		 * @param name the name of the objet that is suffering the damage
		 * @param attackName optional param, add a attack name to the suffer name. Can be used to differentiate diferent attack types from the same attacker, so this attacks will not in conflict time with each other.
		 */			
		public function addDefinitiveSufferName(name:String):void {
			definitiveSuffersNames.push(name);
		}

		public function clearDefinitiveSufferName():void {
			definitiveSuffersNames.length = 0;
		}
		
		/**
		 * Remove the name of the suffer from the SuffersNamesList, so this suffer can take damage from this hurter again.
		 * @param time amount of time (seconds) that suffer should stay in the SuffersNamesList.
		 * @param attackName optional param, will test the name of suffer preceded by attack name, in case suffer name was added this way before.
		 */			
		public function removeSufferName(name:String):void {
			var i: int = 0;
			var snLength:uint = suffersNames.length;
			
			for (i = 0; i < snLength; i++){
				if (suffersNames[i] == name){
					suffersNames.splice(i, 1);
					//log(damagerName + " - " + "name: " + name + " removed from damageControl");
					break;
				}
			}
		}
		
		public static var stringBuilder:ByteArray = new ByteArray();
		public static var attName:String;
		/**
		 * Verify if suffer´s name is in the SuffersNamesList. If it so, the function will return true, telling to the InteractionTrigger the hit should be ignored.
		 * If the function do not find the suffer´s name in the list, it will return false but will add the suffer´s name to the list.
		 * @param name the name of a suffer that is in the SuffersNamesList
		 * @param time amount of time (seconds) that suffer should stay in the SuffersNamesList.
		 */			
		public function verifySufferName(name:String, attackName:String = ""):Boolean{
			//if (!Main.getInstance().state.getObjectByName(name) as creature)
			//trace (damagerName + " NomeVerifica: " + name + " / " + getSufferNames() );
			if(attackName){
				stringBuilder.writeUTFBytes(attackName);
				stringBuilder.writeUTFBytes(name);
				attName = stringBuilder.toString();
				stringBuilder.clear();
			}
			
			//var attName:String = attackName + "." + name;
			var dsnLength:uint = definitiveSuffersNames.length;
			var snLength:uint = suffersNames.length;
			var i: int;
			//var attName:String;
			
			if (definitiveSuffersNames.length > 0){
				for (i = 0; i < dsnLength; i++) {
					if (definitiveSuffersNames[i] == name){
						return true;
						//log(damagerName + " - " + "name: " + name + " is on Definitive list, returning true");
					}
				}
			}
			
			if (suffersNames.length <= 0)
				return false;
				
			for (i = 0; i < snLength; i++) {
				if (suffersNames[i] == attName){
					return true;
					//log(damagerName + " - " + "name(Attack): " + attackName + "." + name + " is on suffer names list, returning true");
				}
				if (suffersNames[i] == name){
					return true;
					
					//log(damagerName + " - " + "name: " + attackName + "." + name + " is on suffer names list, returning true");
				}
			}
			
			//log(damagerName + " - " + "name: " + attackName + "." + name + " is not listed anyware on this damage constraint");
			return false;
		}
		
        private static function log(message:String):void {
            if (verbose) trace("[DAMAGE CONSTRAINT]:", message);
        }
        
		/**
		 * Get all names in sufferNameList
		 * @return String with the suffer names
		 */			
		public function getSufferNames():String{
			//var names:String = SuffersNamesList;
			return suffersNames.toString();
		}
	}
}