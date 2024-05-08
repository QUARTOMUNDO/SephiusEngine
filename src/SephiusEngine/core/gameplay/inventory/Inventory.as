package SephiusEngine.core.gameplay.inventory {
	import SephiusEngine.core.gameplay.attributes.subAttributes.NatureGauge;
	import SephiusEngine.core.gameplay.inventory.objects.Item;
	import SephiusEngine.core.gameplay.inventory.objects.Memo;
	import SephiusEngine.core.gameplay.inventory.objects.SpellKnowledge;
	import SephiusEngine.core.gameplay.inventory.objects.Weapon;
	import SephiusEngine.userInterfaces.UserInterfaces;

	import flash.utils.Dictionary;

	import org.osflash.signals.Signal;

	import tLotDClassic.GameData.Properties.HelpProperties;
	import tLotDClassic.GameData.Properties.ItemProperties;
	import tLotDClassic.GameData.Properties.MemoProperties;
	import tLotDClassic.GameData.Properties.SpellProperties;
	import tLotDClassic.GameData.Properties.WeaponProperties;
	import tLotDClassic.gameObjects.characters.Sephius;
	/**
	 * Stores items, memos, spells, weapons for a character
	 * Also has sorted list of this objects so they can be easly acessed
	 * @author Fernando Rabello
	 */
	public class Inventory {
		public static const TYPE_WEAPON:String = "Weapon";
		public static const TYPE_SPELL:String = "Spell";
		public static const TYPE_ITEM:String = "Item";
		public static const TYPE_MEMO:String = "Memo";
		
		public var onObjectAdded:Signal = new Signal(String, String);
		public var onSingleNatureAdded:Signal = new Signal(String, String);//Used to avoid events on compound spells
		public var onObjectAmount:Signal = new Signal(String, String, int);

		public var inventoryObjects:Vector.<InventoryObject> = new Vector.<InventoryObject>();

		public var weapons:Dictionary = new Dictionary();
		public var weaponsSorted:Array = new Array();
		   public var weaponsEquipedSorted:Array = new Array();
		public var weaponsIDsSorted:Array = new Array();
		   public var weaponsByID:Dictionary = new Dictionary();
		
		public var spells:Dictionary = new Dictionary();
		public var spellsSorted: Array = new Array();
		public var spellsIDsSorted: Array = new Array();
		   public var spellsByID: Dictionary = new Dictionary();
		
		public var naturesSorted: Array = new Array();
		
		public var items:Dictionary = new Dictionary();
		public var itemsSorted: Array = new Array();
		public var itemsEquipedSorted: Array = new Array();
		public var itemsIDsSorted: Array = new Array();
			public var itemsByID: Dictionary = new Dictionary();
		
		public var memos:Dictionary = new Dictionary();
		public var memosSorted: Array = new Array();
		public var memosIDsSorted: Array = new Array();
		   public var memosByID: Dictionary = new Dictionary();
		
		public var player:Sephius;
		
		public function Inventory(player:Sephius) {
			this.player = player;
		}
		
		/** add a weapon to sephius inventory if sephius not have areally */
		public function addObject(objectID:String, type:String, amount:uint, equip:Boolean, verbose:Boolean = true):void {
			var inventoryClass:Class = type == TYPE_ITEM ? Item : type == TYPE_MEMO ? Memo : type == TYPE_SPELL ? SpellKnowledge : type == TYPE_WEAPON ? Weapon : null;
			var propertyClass:Class = type == TYPE_ITEM ? ItemProperties : type == TYPE_MEMO ? MemoProperties : type == TYPE_SPELL ? SpellProperties : type == TYPE_WEAPON ? WeaponProperties : null;
			var property:Object = propertyClass["PROPERTY_BY_VAR_NAME"][objectID];
			var varPartName:String = type.toLowerCase() + "s";
			var typeLowerCase:String = type.toLowerCase();
			
			if (!this[varPartName][objectID]) {
				this[varPartName][objectID] = new inventoryClass(property, amount, inventoryClass);
				inventoryObjects.push(this[varPartName][objectID]);

				this[varPartName + "ByID"][property.varName] = this[varPartName][objectID];
				
				this[varPartName + "Sorted"].push(this[varPartName][objectID]);
				this[varPartName + "Sorted"].sortOn("id", Array.NUMERIC);
				
				if (type == TYPE_SPELL){
					if(!property.isCompound){
						naturesSorted.push(this[varPartName][objectID]);
						naturesSorted.sortOn("id", Array.NUMERIC);
					}
				}
				if (type == TYPE_ITEM){
					//Item permanent actiavtions
					if(property.colectedFunctionName)
						this[varPartName][objectID].collectionActivation(player);
				}
				if (type == TYPE_MEMO){
					if(property.targetMapLocation)
						this[varPartName][objectID].collectionActivation();
				}

				trace(type + objectID + " getted");

				if(verbose){
					if (type != TYPE_SPELL){
						onObjectAdded.dispatch(objectID, type);
					}
					else{
						if(!property.isCompound)
							onSingleNatureAdded.dispatch(objectID, type);
					}
				}

				if(property.autoEquip && equip)
					equipObject(objectID, type);
				
				this[varPartName + "IDsSorted"].length = 0;
				this[varPartName + "IDsSorted"] = this[varPartName + "Sorted"].map(toID);
				function toID(element:*, index:int, arr:Array):String {
					return element.property.varName;
				}
			}
			else {
				if(property.maxAmount > 1){
					this[varPartName][objectID].amount += Math.min(amount, this[varPartName][objectID].amount + amount);
					onObjectAmount.dispatch(type, objectID, int(this[varPartName][objectID].amount));

					if (verbose && (type == TYPE_ITEM || type == TYPE_SPELL || type == TYPE_WEAPON)){
						player.hud[varPartName + "RingAmountTexts"][objectID].text = this[varPartName].amount;
						player.hud[varPartName + "SlotsAmountTexts"][objectID].text = this[varPartName].amount;
					}
				}
				else
					trace("Sephius already have this" + type + " " + objectID);
			}
			
			if (player.hud && (type == TYPE_ITEM || type == TYPE_SPELL || type == TYPE_WEAPON || type == TYPE_MEMO)) {
				var noneVarName:String = type == TYPE_ITEM ? ItemProperties.NONE.varName :  
										type == TYPE_SPELL ? SpellProperties.NULL.varName : 
										type == TYPE_WEAPON ? WeaponProperties.NONE.varName : "";

				if (type == TYPE_SPELL) {
					//Autoselect if there is none equiped at first slot
					if(!property.isCompound){
						if(player.hud["selected" + type + "1"] == noneVarName)
							player[varPartName][typeLowerCase + "1"] = property;
						
						else if(player.hud["selected" + type + "2"] == noneVarName)
							player[varPartName][typeLowerCase + "2"] = property;
					}
				}
				if (type == TYPE_ITEM){
					//Autoselect if there is none equiped in item slot
					if (player.hud.selectedItem1 == noneVarName)
						player[varPartName][typeLowerCase + "1"] = this[varPartName][objectID];
				}
				else if (type == TYPE_WEAPON){
					//Autoselect if there is none equiped at first slot
					if(player.hud["selected" + type + "1"] == noneVarName)
						player[varPartName][typeLowerCase + "1"] = this[varPartName][objectID];
					
					//Autoselect if there is none equiped at second slot
					else if(player.hud["selected" + type + "2"] == noneVarName)
						player[varPartName][typeLowerCase + "2"] = this[varPartName][objectID];
				}
				
				if(type != TYPE_MEMO)
					player.hud["update" + type + "List"]();//Updates the list for the respective type of element (item, weapon or spell)
				
				if (verbose && type != TYPE_SPELL)
					player.hud.rewardCollected(property.varName, amount, type);
				
				if (type == TYPE_ITEM && this[varPartName + "Sorted"].length > 3)
					if(!UserInterfaces.instance.helpUI.helpMessageOnScreen && player.archivemnets.listenedHelps[HelpProperties.HELP_ITEM_RING_1.varName].listened)
						UserInterfaces.instance.helpUI.showIngameHelpMessage(HelpProperties.HELP_ITEM_RING_1);
				
				if (type == TYPE_MEMO && this[varPartName + "Sorted"].length > 0)
					if(!UserInterfaces.instance.helpUI.helpMessageOnScreen && !player.archivemnets.listenedHelps[HelpProperties.HELP_MEMO_1.varName].listened)
						UserInterfaces.instance.helpUI.showIngameHelpMessage(HelpProperties.HELP_MEMO_1);
			}
		}
		
		/** Remove a weapon from the inventory */
		public function removeObject(_objectName:String, type:String, verbose:Boolean = true):void {
			var propertyClass:Class = type == TYPE_ITEM ? ItemProperties : type == TYPE_MEMO ? MemoProperties : type == TYPE_SPELL ? SpellProperties : type == TYPE_WEAPON ? WeaponProperties : null;
			
			if (this[type][_objectName]) {
				this[type][_objectName].dispose();
				delete this[type][_objectName];
				delete this[type + "ByID"][propertyClass["PROPERTY_BY_NAME"][_objectName].varName];
				
				var index:String;
				for (index in this[type + "Sorted"]) {
					if (this[type + "Sorted"][index].property.varName == _objectName){
						this[type + "Sorted"].splice(Number(index), 1);
						this[type + "NamesSorted"].splice(Number(index), 1);
					}
				}
				
				player.hud["update" + type + "List"]();
			}
			else
				trace("Sephius does not have this" + type + " " + _objectName);
				//throw Error("[SEPHIUS WEAPONS]: Weapon name given does not mach with any game weapons names");
		}
		
		/** Equipe a object to the inventory. This mean, object appearing on rings or avaiable on HUD slots */
		public function equipObject(_objectName:String, type:String, verbose:Boolean = true):void{
			var inventoryClass:Class = type == TYPE_ITEM ? Item : type == TYPE_MEMO ? Memo : type == TYPE_SPELL ? SpellKnowledge : type == TYPE_WEAPON ? Weapon : null;
			var propertyClass:Class = type == TYPE_ITEM ? ItemProperties : type == TYPE_MEMO ? MemoProperties : type == TYPE_SPELL ? SpellProperties : type == TYPE_WEAPON ? WeaponProperties : null;
			var property:Object = propertyClass["PROPERTY_BY_NAME"][_objectName];
			var varPartName:String = type.toLowerCase() + "s";
			var typeLowerCase:String = type.toLowerCase();
			
			if (this[varPartName][_objectName] && (inventoryClass == Item ||  inventoryClass == Weapon)) {
				if (this[varPartName + "EquipedSorted"].indexOf(this[varPartName][_objectName]) == -1){	
					this[varPartName + "EquipedSorted"].push(this[varPartName][_objectName]);
					this[varPartName + "EquipedSorted"].sortOn("id", Array.NUMERIC);
					
					this[varPartName][_objectName].equiped = true;
					if(player.hud)
						player.hud["update" + type + "List"]();
				}
			}
		}
		
		/** Equipe a object to the inventory */
		public function unequipObject(_objectName:String, type:String, verbose:Boolean = true):void{
			var inventoryClass:Class = type == TYPE_ITEM ? Item : type == TYPE_MEMO ? Memo : type == TYPE_SPELL ? SpellKnowledge : type == TYPE_WEAPON ? Weapon : null;
			var propertyClass:Class = type == TYPE_ITEM ? ItemProperties : type == TYPE_MEMO ? MemoProperties : type == TYPE_SPELL ? SpellProperties : type == TYPE_WEAPON ? WeaponProperties : null;
			var property:Object = propertyClass["PROPERTY_BY_NAME"][_objectName];
			var varPartName:String = type.toLowerCase() + "s";
			var typeLowerCase:String = type.toLowerCase();
			
			if (this[varPartName][_objectName] && (inventoryClass == Item ||  inventoryClass == Weapon)) {
				if (this[varPartName + "EquipedSorted"].indexOf(this[varPartName][_objectName]) != -1){	
					this[varPartName + "EquipedSorted"].removeAt(this[varPartName + "EquipedSorted"].indexOf(this[varPartName][_objectName]));
					
					this[varPartName][_objectName].equiped = false;
					player.hud["update" + type + "List"]();
				}
			}
		}
		
		/** List of all items. All items used in the game should be presented here. */
		public static function newGameHeldtems():Array{
			var _itemList:Array = new Array();
			
			return _itemList;
		}
		
		/** List of all items. All items used in the game should be presented here. */
		public static function demoHeldtems():Array{
			var _itemList:Array = new Array();
			var item:ItemProperties;

			for each (item in ItemProperties.PROPERTY_LIST){
				if(item != ItemProperties.NONE){
					_itemList.push({varName:item.varName,	amount:item.maxAmount, 	remainingColdDownTime:-1, equiped:item.autoEquip});
				}
			}
			
			return _itemList;
		}
				
		/** Return a dictionary with information of witch weapons player has when start new game */
		public static function newGameHeldWeapons():Array {
			var initialHeldWeapons:Array = new Array();
			
			initialHeldWeapons.push( { varName:WeaponProperties.NONE.varName } );
			
			return initialHeldWeapons;
		}
		
		/** Return a dictionary with information of witch weapons player has when start new game */
		public static function demoHeldWeapons():Array {
			var initialHeldWeapons:Array = new Array();
			
			initialHeldWeapons.push( { varName:WeaponProperties.NONE.varName } );
			
			initialHeldWeapons.push({varName:WeaponProperties.FOLKEN.varName});
			
			initialHeldWeapons.push({varName:WeaponProperties.BELYONICU_LUMINU.varName});
			initialHeldWeapons.push({varName:WeaponProperties.GRENDA_OSKARIDUE_ASPADE.varName});
			initialHeldWeapons.push({varName:WeaponProperties.ASFERIDUE_LUMINU.varName});
			initialHeldWeapons.push({varName:WeaponProperties.ERED_PUMTHU.varName});
			initialHeldWeapons.push({varName:WeaponProperties.THAYLANTHINUS_ASPADES.varName});
			initialHeldWeapons.push({varName:WeaponProperties.PAHGNON.varName});
			initialHeldWeapons.push({varName:WeaponProperties.GRENDA_PRETAHTHESH_ASCURE.varName});
			//initialHeldWeapons.push({varName:WeaponProperties.GRENDAMORTELABYSANOCI.varName});
			
			return initialHeldWeapons;
		}
		
		/** Return a dictionary with information of witch weapons player has when start new game */
		public static function demo2HeldWeapons():Array {
			var initialHeldWeapons:Array = new Array();
			
			initialHeldWeapons.push( { varName:WeaponProperties.NONE.varName } );
			
			initialHeldWeapons.push({varName:WeaponProperties.FOLKEN.varName});
			initialHeldWeapons.push({varName:WeaponProperties.ERED_PUMTHU.varName});
			initialHeldWeapons.push({varName:WeaponProperties.THAYLANTHINUS_ASPADES.varName});
			initialHeldWeapons.push({varName:WeaponProperties.GRENDA_PRETAHTHESH_ASCURE.varName});
			
			return initialHeldWeapons;
		}
		
		/** Return a dictionary with information of witch weapons player has when start new game */
		public static function newGameHeldMemos():Array {
			var initialHeldMemos:Array = new Array();
			return initialHeldMemos;
		}
		
		/** Return a dictionary with information of witch weapons player has when start new game */
		public static function demoHeldMemos():Array {
			var initialHeldMemos:Array = new Array();
			var cMemo:MemoProperties;

			for each(cMemo in MemoProperties.PROPERTY_LIST){
				initialHeldMemos.push({varName:cMemo.varName});
			}
			
			return initialHeldMemos;
		}
		
		public static function startGameHeldSpells(amps:NatureGauge):Array {
			var nature:String;
			var nature2:String; 
			var spellProperty:SpellProperties;
			var _spellList:Array = new Array();
			var added:Boolean = false;
			var propertyList:Vector.<SpellProperties> = SpellProperties.PROPERTY_LIST;

			for each(spellProperty in propertyList) {
				added = false;
				for each (nature in spellProperty.natureApplications.aboveZero) {
					if(!added && spellProperty.natureApplications[nature] > -1){
						if (amps[nature] > 0) {
							if (!spellProperty.isCompound ) {
								_spellList.push( { varName:spellProperty.varName } );
								added = true;
							}
							else {
								for each (nature2 in spellProperty.natureApplications.aboveZero) {
									if (!added && nature2 != nature && spellProperty.natureApplications[nature2] > -1) {
										if (amps[nature2] > 0) {
											_spellList.push( { varName:spellProperty.varName } );
											added = true;
										}
									}
								}
							}
						}
					}
				}
			}
			return _spellList;
		}
		
		public function destroy():void {
			onObjectAdded.removeAll();
			onObjectAmount.removeAll();

			player = null;

			weapons = null;
			weaponsSorted.length = 0;
		   	weaponsEquipedSorted.length = 0;
			weaponsIDsSorted.length = 0;
		   	weaponsByID = null;
		
			spells = null;
			spellsSorted.length = 0;
			spellsIDsSorted.length = 0;
		   	spellsByID = null;
		
			naturesSorted.length = 0;
		
			items = null;
			itemsSorted.length = 0;
			itemsEquipedSorted.length = 0;
			itemsIDsSorted.length = 0;
			itemsByID = null;
		
			memos = null;
			memosSorted.length = 0;
			memosIDsSorted.length = 0;
		  	memosByID = null;

			var iObject:InventoryObject;
			for each(iObject in inventoryObjects){
				iObject.dispose();
			}

			inventoryObjects.length = 0;
		}
	}
}