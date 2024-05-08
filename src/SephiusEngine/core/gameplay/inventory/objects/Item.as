package SephiusEngine.core.gameplay.inventory.objects {
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.gameplay.attributes.subAttributes.EssenceLootAttributes;
	import SephiusEngine.core.gameplay.inventory.InventoryObject;
	import SephiusEngine.core.gameplay.properties.objectsInfos.BarrierState;
	import SephiusEngine.displayObjects.particles.EssenceBleedPoint;
	import SephiusEngine.displayObjects.particles.EssenceCloud;
	import SephiusEngine.levelObjects.interfaces.IEssenceBleeder;
	import SephiusEngine.levelObjects.interfaces.IInteractor;
	import SephiusEngine.levelObjects.interfaces.IProjectileLauncher;
	import SephiusEngine.userInterfaces.UserInterfaces;
	import SephiusEngine.utils.pools.ELootAPool;

	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;

	import starling.display.BlendMode;

	import tLotDClassic.GameData.Properties.EssenceProperties;
	import tLotDClassic.GameData.Properties.ItemProperties;
	import tLotDClassic.GameData.Properties.ProjectileProperty;
	import tLotDClassic.GameData.Properties.naturesInfos.Natures;
	import tLotDClassic.attributes.AttributesConstants;
	import tLotDClassic.gameObjects.barriers.Barriers;
	import tLotDClassic.gameObjects.characters.Characters;
	import tLotDClassic.gameObjects.characters.Sephius;
	import tLotDClassic.gameObjects.damagers.Projectile;
	/**
	 * Store a item
	 * @author Fernando Rabello
	 */
	public class Item extends InventoryObject{
		public var remainingColdDownTime:Number = 0;
		private var useFunction:Function;
		private var colectedFunctionName:Function;
		public var property:ItemProperties;

		public function Item(property:ItemProperties, amount:int, inventoryClass:Class) {
			super(property, amount, inventoryClass);
			this.property = property;
			if (property.useFunctionName != "null" && property.useFunctionName != "")
				this.useFunction = Item[property.useFunctionName];

			if (property.colectedFunctionName != "null" && property.colectedFunctionName != "")
				this.colectedFunctionName = Item[property.colectedFunctionName];
		}
		
		/**--------------------------------------------------------
		 *               Itens Functions
		 ----------------------------------------------------------*/
		/**
		 * Verify the existence of the item, selects him and send to the function "consume"
		 * @return The item that "item.consume" should use, or false information to block the process
		 */
		public function useIt(user:Object, params:Object=null) : Boolean{
			trace("Item:", this.property.varName, " used");
			if (useFunction){
				if ((property as ItemProperties).consumable)
					return tryToConsume(user, params, 1, true);
				else
					return useFunction(this, user, params);
			}
			return false; 
		}
		
		/**
		 * Activates function related to item creation. Tend to be permanent buffs
		 */
		public function collectionActivation(user:Object) : Boolean{
			trace("Item Function:", this.colectedFunctionName, " actiated");
			if (colectedFunctionName){
				return colectedFunctionName(this, user);
			}
			return false; 
		}
		
		
		
		/**
		 * When calling this function checks if there is a barrier to be opened with the key with which the player used.
		 * KEY ID SEAMS NOT BEING VERIFIED!! IF PLAYER USED ITEM MANYALLY?
		 * @param	item The key used by the player
		 * @return If the function ordered to open the door or not
		 */
		public static function actionKey(item:Item, user:Object = null, params:Object=null) : Boolean {
			if(!user)
				return false;

			var interactor:IInteractor = (user as IInteractor);
			var barrier:Barriers = interactor.interactorAttributes.currentInteragent as Barriers;

			if(interactor && (barrier && barrier.enabled)){
				if (barrier.state == BarrierState.CLOSED) {
					barrier.open();
					return true;
				}
				if (barrier.state == BarrierState.OPENED) {
					barrier.close();
					return true;
				}
			}

			return false;
		}
		
		public static function actionNercanteKnife(item:Item, user:Object, params:Object=null):Boolean{
			new Projectile("Projectile", ProjectileProperty.NERCANTE_KNIFE, user as IProjectileLauncher, -0.0, {x:user.x + (user.inverted ? -100 : 100), y:user.y-25});
			return true;
		}
		public static function actionThreeNercanteKnife(item:Item, user:Object, params:Object=null):Boolean{
			new Projectile("Projectile", ProjectileProperty.NERCANTE_KNIFE, user as IProjectileLauncher, -0.0, {x:user.x + (user.inverted ? -90 : 90), y:user.y-25});

			TweenMax.delayedCall(2, nercanteKnifeEvent, [item, user, 0, params], true);
			TweenMax.delayedCall(4, nercanteKnifeEvent, [item, user, 1, params], true);
			
			return true;
		}
			public static function nercanteKnifeEvent(item:Item, user:Object, pieceNumber:uint, params:Object=null):Boolean{
				if(pieceNumber == 0)
					new Projectile("Projectile", ProjectileProperty.NERCANTE_KNIFE, user as IProjectileLauncher, 0.05, {x:user.x + (user.inverted ? -100 : 100), y:user.y-25});
				if(pieceNumber == 1)
					new Projectile("Projectile", ProjectileProperty.NERCANTE_KNIFE, user as IProjectileLauncher, 0.10, {x:user.x + (user.inverted ? -110 : 110), y:user.y-15});
				return true;
			}
		
		public static function actionAlkamoSpear1(item:Item, user:Object, params:Object=null):Boolean{
			new Projectile("Projectile", ProjectileProperty.ALKAMO_SPIKE, user as IProjectileLauncher, -0.0, {x:user.x + (user.inverted ? -160 : 160), y:user.y-50});
			return true;
		}	
		
		public static function actionDekaDard(item:Item, user:Object, params:Object=null):Boolean{
			new Projectile("Projectile", ProjectileProperty.DELKA_DARD, user as IProjectileLauncher, -0.0, {x:user.x + (user.inverted ? -100 : 100), y:user.y-25});
			return true;
		}

		public static function actionThreeDekaDards(item:Item, user:Object, params:Object=null):Boolean{
			new Projectile("Projectile", ProjectileProperty.DELKA_DARD, user as IProjectileLauncher, -0.3, {x:user.x + (user.inverted ? -90 : 90), y:user.y-25});

			TweenMax.delayedCall(1, dekaDardsEvent, [item, user, 0, params], true);
			TweenMax.delayedCall(2, dekaDardsEvent, [item, user, 1, params], true);

			return true;
		}

		public static function actionFiveDekaDards(item:Item, user:Object, params:Object=null):Boolean{
			new Projectile("Projectile", ProjectileProperty.DELKA_DARD, user as IProjectileLauncher, -0.3, {x:user.x + (user.inverted ? -90 : 90), y:user.y-25});

			TweenMax.delayedCall(1, dekaDardsEvent, [item, user, 0, params], true);
			TweenMax.delayedCall(2, dekaDardsEvent, [item, user, 1, params], true);
			TweenMax.delayedCall(3, dekaDardsEvent, [item, user, 3, params], true);
			TweenMax.delayedCall(4, dekaDardsEvent, [item, user, 4, params], true);

			return true;
		}

			public static function dekaDardsEvent(item:Item, user:Object, pieceNumber:uint, params:Object=null):Boolean{
				if(pieceNumber == 0)
					new Projectile("Projectile", ProjectileProperty.DELKA_DARD, user as IProjectileLauncher, -0.0, {x:user.x + (user.inverted ? -100 : 100), y:user.y-25});
				if(pieceNumber == 1)
					new Projectile("Projectile", ProjectileProperty.DELKA_DARD, user as IProjectileLauncher, 0.3, {x:user.x + (user.inverted ? -90 : 90), y:user.y-15});
				if(pieceNumber == 3)
					new Projectile("Projectile", ProjectileProperty.DELKA_DARD, user as IProjectileLauncher, 0.15, {x:user.x + (user.inverted ? -95 : 95), y:user.y-15});
				if(pieceNumber == 4)
					new Projectile("Projectile", ProjectileProperty.DELKA_DARD, user as IProjectileLauncher, -0.15, {x:user.x + (user.inverted ? -95 : 95), y:user.y-15});
				return true;
			}

		public static function actionPrimalFireStone(item:Item, user:Object, params:Object=null):Boolean{
			new Projectile("Projectile", ProjectileProperty.PRIMAL_STONE_FIRE, user as IProjectileLauncher, -0.0, {x:user.x + (user.inverted ? -100 : 100), y:user.y-25});
			return true;
		}

		public static function actionThreePrimalFireStones(item:Item, user:Object, params:Object=null):Boolean{
			new Projectile("Projectile", ProjectileProperty.PRIMAL_STONE_FIRE, user as IProjectileLauncher, -0.0, {x:user.x + (user.inverted ? -100 : 100), y:user.y-25});
			TweenMax.delayedCall(1, primalFiireStonesEvent, [item, user, 0, params], true);
			TweenMax.delayedCall(2, primalFiireStonesEvent, [item, user, 1, params], true);
			return true;
		}
			public static function primalFiireStonesEvent(item:Item, user:Object, pieceNumber:uint, params:Object=null):Boolean{
				if(pieceNumber == 0)
					new Projectile("Projectile", ProjectileProperty.PRIMAL_STONE_FIRE, user as IProjectileLauncher, -0.2, {x:user.x + (user.inverted ? -90 : 90), y:user.y-25});
				if(pieceNumber == 1)
					new Projectile("Projectile", ProjectileProperty.PRIMAL_STONE_FIRE, user as IProjectileLauncher, 0.2, {x:user.x + (user.inverted ? -90 : 90), y:user.y-15});
				return true;
			}

		public static function actionPrimalIceStone(item:Item, user:Object, params:Object=null):Boolean{
			new Projectile("Projectile", ProjectileProperty.PRIMAL_STONE_ICE, user as IProjectileLauncher, -0.0, {x:user.x + (user.inverted ? -100 : 100), y:user.y-25});
			return true;
		}

		public static function actionThreePrimalIceStones(item:Item, user:Object, params:Object=null):Boolean{
			new Projectile("Projectile", ProjectileProperty.PRIMAL_STONE_ICE, user as IProjectileLauncher, -0.0, {x:user.x + (user.inverted ? -100 : 100), y:user.y-25});
			TweenMax.delayedCall(1, primalIceStoneEvent, [item, user, 0, params], true);
			TweenMax.delayedCall(2, primalIceStoneEvent, [item, user, 1, params], true);
			return true;
		}
			public static function primalIceStoneEvent(item:Item, user:Object, pieceNumber:uint, params:Object=null):Boolean{
				if(pieceNumber == 0)
					new Projectile("Projectile", ProjectileProperty.PRIMAL_STONE_ICE, user as IProjectileLauncher, -0.2, {x:user.x + (user.inverted ? -90 : 90), y:user.y-25});
				if(pieceNumber == 1)
					new Projectile("Projectile", ProjectileProperty.PRIMAL_STONE_ICE, user as IProjectileLauncher, 0.2, {x:user.x + (user.inverted ? -90 : 90), y:user.y-15});
				return true;
			}

		public static function actionBigRock(item:Item, user:Object, params:Object=null):Boolean{
			new Projectile("Projectile", ProjectileProperty.BIG_ROCK, user as IProjectileLauncher, -0.0, {x:user.x + (user.inverted ? -100 : 100), y:user.y-25});
			return true;
		}
		
		public static function actionSmallRock(item:Item, user:Object, params:Object=null):Boolean{
			new Projectile("Projectile", ProjectileProperty.SMALL_ROCK, user as IProjectileLauncher, -0.0, {x:user.x + (user.inverted ? -100 : 100), y:user.y-25});
			return true;
		}
		
		/** Gives 25% of level 10 essencika */
		public static function actionGiveDeep50Light(item:Item, user:Characters) : Boolean{
			return actionGiveDeep(item, user, .40, Natures.Light);
		}
		
		/** Gives 25% of level 10 essencika */
		public static function actionGiveDeep50Dark(item:Item, user:Characters) : Boolean{
			return actionGiveDeep(item, user, .40, Natures.Darkness);
		}
		
		/** Gives 25% of level 10 essencika */
		public static function actionGiveDeep25Light(item:Item, user:Characters) : Boolean{
			return actionGiveDeep(item, user, .25, Natures.Light);
		}
		
		/** Gives 25% of level 10 essencika */
		public static function actionGiveDeep25Dark(item:Item, user:Characters) : Boolean{
			return actionGiveDeep(item, user, .25, Natures.Darkness);
		}
		
		/** Gives 25% of level 10 essencika */
		public static function actionGiveDeep15Light(item:Item, user:Characters) : Boolean{
			return actionGiveDeep(item, user, .13, Natures.Light);
		}
		
		/** Gives 25% of level 10 essencika */
		public static function actionGiveDeep15Dark(item:Item, user:Characters) : Boolean{
			return actionGiveDeep(item, user, .13, Natures.Darkness);
		}
		
		/** Gives 25% of level 10 essencika */
		public static function actionGiveDeep(item:Item, user:Characters, amount:Number, nature:String) : Boolean{
			
			//user.characterAttributes.absorbDeepEssence(deepGain, nature);
			
			GameEngine.instance.state.globalEffects.splashByDamand(nature + "EssenceGain", user, { x:user.x, y:user.y, group:user.group, scaleOffsetX:1.0, scaleOffsetY:1.0, blendMode:user.presence.placeNature == "Light" ? BlendMode.NORMAL : BlendMode.SCREEN }, "normal", true);
			//GameEngine.instance.state.globalEffects.customSplashTextsByDemand((-deepGain), user);

			addEssences(user, nature, amount);

			return true;
		}

		private static var essenceLootAttributes:EssenceLootAttributes;
		public static var essences:Vector.<EssenceCloud> = new Vector.<EssenceCloud>();
		public static var essenceBleedPoints:Vector.<EssenceBleedPoint> = new Vector.<EssenceBleedPoint>();
		private static var elIndex:uint;
	
		/** Add a partice effect */
		public static function addEssences(character:Characters, nature:String, amount:Number):void {
			var propertySizeName:String = amount < .5 ? "SMALL_" :  amount > 1 ? "HUGE_" : "BIG_"
			var propertyNatureName:String = nature == Natures.Light ? "LIGHT_" :  nature == Natures.Darkness ? "DARK_" : "MESTIZO_"
			var essenceProperty:EssenceProperties = EssenceProperties[propertyNatureName + propertySizeName + "DEEP"];
			var essence:EssenceCloud;

			var essencika:Number;
			var deepGain:Number;

			essencika = AttributesConstants.getEssencikaAtLevel(AttributesConstants.baseLevel);
			deepGain = essencika * amount;
			
			essenceLootAttributes = ELootAPool.getObject(essenceProperty, null, deepGain);

			character.bleederAttributes.bleedSpeed = AttributesConstants.item_EssenceBleedSpeed;
			character.bleedOffsetX = character.inverted ? -AttributesConstants.item_EssenceEmiitingOffsetX : AttributesConstants.item_EssenceEmiitingOffsetX;
			character.bleedOffsetY = -AttributesConstants.item_EssenceEmiitingOffsetY;

			//essenceBleedPoints.push(new essenceBleedPoints());
			essence = GameEngine.instance.state.globalEffects.particles.createEssence(character as IEssenceBleeder, essenceLootAttributes);
			essence.selfAbsorption = true;//Nedded for the character be able to aborb essence he dropped using the item
			essences.push(essence);

			essences[essences.length - 1].onComplete.add(removeEssence);

			essenceLootAttributes = null;
		}

		/** Remove a partice effect */
		public static function removeEssence(essence:EssenceCloud):void {
			elIndex = essences.indexOf(essence);
			essences[elIndex].onComplete.removeAll();
			ELootAPool.returnObject(essences[elIndex].essenceLootAttributes);
			essences.splice(elIndex, 1);
			
			GameEngine.instance.state.globalEffects.particles.destroyEssence(essence);
		}

		public static function actionRestore1(item:Item, user:Characters) : Boolean{
			return actionGiveMystical(item, user, .15) && actionCure1(item, user, .15);
		}
		
		public static function actionRestore2(item:Item, user:Characters) : Boolean{
			return actionGiveMystical(item, user, .60) && actionCure1(item, user, .60);
		}
		
		public static function actionRestoreMax(item:Item, user:Characters) : Boolean{
			return actionGiveMystical(item, user, 1) && actionCure1(item, user, 1);
		}
		
		public static function actionRestoreMystical1(item:Item, user:Characters) : Boolean{
			return actionGiveMystical(item, user, .15);
		}

		public static function actionRestoreMystical2(item:Item, user:Characters) : Boolean{
			return actionGiveMystical(item, user, .60);
		}

		public static function actionGiveMystical(item:Item, user:Characters, amount:Number) : Boolean{
			var essencika:Number;
			var mysticalGain:Number;

			essencika = AttributesConstants.getEssencikaAtLevel(AttributesConstants.baseLevel);
			mysticalGain = Number((essencika * AttributesConstants.mysticalInvigoration) * amount);
			
			var mysticalRestored:Boolean = user.characterAttributes.restoreMysticalEssence(mysticalGain);

			if(mysticalRestored){
				var offsetX:Number = (user.inverted ? -AttributesConstants.item_EssenceEmiitingOffsetX : AttributesConstants.item_EssenceEmiitingOffsetX);
				var offsetY:Number = AttributesConstants.item_EssenceEmiitingOffsetY;
			
				GameEngine.instance.state.globalEffects.splashByDamand(user.presence.placeNature + "EssenceGain", user, { displacementX:offsetX, displacementY:offsetY, group:user.group, scaleOffsetX:2.0, scaleOffsetY:2.0, blendMode:user.presence.placeNature == "Light" ? BlendMode.NORMAL : BlendMode.SCREEN }, "normal", true);
				GameEngine.instance.state.globalEffects.customSplashTextsByDemand((-mysticalGain), user, false, offsetX, offsetY);
				return false;
			}
			return true;
		}

		public static function actionCure1(item:Item, user:Characters, amount:Number) : Boolean{
			return actionCure(item, user, amount);
		}

		public static function actionCure2(item:Item, user:Characters, amount:Number) : Boolean{
			return actionCure(item, user, amount);
		}

		public static function actionCure(item:Item, user:Characters, amount:Number) : Boolean{
			var essencika:Number;
			var peripheralGain:Number;
			
			essencika = AttributesConstants.getEssencikaAtLevel(AttributesConstants.baseLevel);
			peripheralGain = Number((essencika * AttributesConstants.peripheralInvigoration) * amount);
			
			var peripheralRestored:Boolean = user.characterAttributes.restorePeripheralEssence(peripheralGain);

			if(peripheralRestored){
				GameEngine.instance.state.globalEffects.splashByDamand("MestizoEssenceGain", user, { x:user.x, y:user.y, group:user.group, scaleOffsetX:0.5, scaleOffsetY:1.3, blendMode:user.presence.placeNature == "Light" ? BlendMode.NORMAL : BlendMode.SCREEN }, "normal", true);
				GameEngine.instance.state.globalEffects.customSplashTextsByDemand((-peripheralGain), user);
				return false;
			}
			return true;
		}
				
		public static function actionMaxCure(item:Item, user:Characters, params:Object=null) : Boolean{
			var essencika:Number;
			var peripheralGain:Number;
			
			
			user.characterAttributes.restorePeripheralEssence(user.characterAttributes.maxPeripheralEssence);
			
			return true;
		}		
		
		/**
		 * Restores 2/3 of sephius mystical essence. Only work in dark world
		 * @param	item
		 * @return if in the dark world, return true, else false.
		 */
		public static function actionDarkEmpower(item:Item, user:Object = null, params:Object=null) : Boolean
		{
			return false;
		}
		
		/**
		 * Restores 2/3 of sephius mystical essence. Only work in Light world
		 * @param	item
		 * @return if in the Light world, return true, else false.
		 */
		public static function actionLightEmpower(item:Item, user:Object = null, params:Object=null) : Boolean
		{
			return false;
		}
		
		/**
		 * Warp Sephius to que Light World
		 * @param	item 
		 * @return nothing to verify, allways true.
		 */
		public static function actionToTheLight(item:Item, user:Object = null, params:Object=null) : Boolean
		{
			return true;
		}
		
		/**
		 * Warp Sephius to que Dark World
		 * @param	item 
		 * @return nothing to verify, allways true.
		 */
		public static function actionToTheDarkness(item:Item, user:Object = null, params:Object=null) : Boolean
		{
			return true;
		}
		
		public static function doubleStamina(item:Item, user:Characters) : Boolean{
			user.characterAttributes.staminaBuff += user.characterAttributes.stamina;

			return true;
		}
		
		public static function doubleItemEfficency(item:Item, user:Characters) : Boolean{
			user.characterAttributes.restoreEfficiency += 1;

			return true;
		}
		
		/**
		 * This function is not being used, but it works trying to spend the item
		 * @param	n The amount of items that should be consumed in order to the function of item be called
		 * @param	effectOnce This parameter is used for restricting the number of times that the function of the item is rotated, work in situations where more than one item and expense, an effect occurs only
		 * @return If the item is able to use or not
		 */
		public function tryToConsume(user:Object, params:Object=null, n:int = 1,  effectOnce:Boolean = false) : Boolean{
			return Consume(user, n < 1 ? 1 : n < amount ? n : amount, effectOnce);
		}
		
		/**
		 * This function work on spend the itens
		 * @param	n The amount of items that should be consumed in order to the function of item be called
		 * @param	effectOnce This parameter is used for restricting the number of times that the function of the item is rotated, work in situations where more than one item and expense, an effect occurs only
		 * @return  Return a true or false to indicates if the item was spent or not
		 */
		public function Consume(user:Object, n:int = 1, effectOnce:Boolean = false) : Boolean{
			n = n > 1 ? n : 1;
			
			if (disabled || (n > amount))
				return false;
				
			if (useFunction == null){
				if ((property as ItemProperties).consumable)
					amount -= n;
				trace ("no function");	
			}
			else{
				if (effectOnce){
					if (useFunction(this, user) == false)
						return false;
					if ((property as ItemProperties).consumable)
						amount -= n;
				}
				else{
					for (var i : int = 0; i < n; i++)
					{
						if (useFunction(this, user) == false)
							return false;
						if ((property as ItemProperties).consumable)
							amount--;
					}
				}
			}
			
			if ((property as ItemProperties).coldDown > 0)
				desableWithTimeOut((property as ItemProperties).coldDown);
			
			var mainPlayer:Sephius;
			if (user as Sephius ){
				mainPlayer = user as Sephius;
				
				mainPlayer.hud.itemsRingAmountTexts[property.varName].text = amount;
				mainPlayer.hud.itemsSlotsAmountTexts[property.varName].text = amount;
			}
			
			return true;
		}
		
		/**
		 * Enable the item allowing it to be used
		 * @return Permissiveness to use the item
		 */
		public function enable():Boolean 
		{
			//if (Level.hud)
				//Level.hud.itemSlotEnable(this.property.varName)
			disabled = false;
			return disabled;
		}
		
		/**
		 * Desable the item for an specific(you specify) time until the item be reconnected
		 * @param	timeOut The time that the item is out of use, cooldown
		 * @return If the item is able to use or not
		 */
		public function desableWithTimeOut(coldDown_:int):Boolean{
			trace ("desabilitar");
			UserInterfaces.instance.hud.itemSlotDisable(property.varName);
			disabled = true;
			remainingColdDownTime = coldDown_;
			TweenMax.to(this, coldDown_, { remainingColdDownTime:0, onComplete:enable, ease:Linear.easeNone } );
			
			return disabled;
		}
		
		public function traceColdDown():void{
			trace("coldDown: ", remainingColdDownTime);
		}
		
		override public function dispose():void {
			super.dispose();
			property = null;
		}
	}
}