package SephiusEngine.core.gameplay.attributes.holders 
{
	import SephiusEngine.core.GameEngine;
	import SephiusEngine.core.gameStates.LevelManager;
	import SephiusEngine.core.gameplay.properties.objectsInfos.InteractorsTypes;
	import SephiusEngine.levelObjects.interfaces.IInteractor;
	import SephiusEngine.levelObjects.interfaces.IInteragent;

	import nape.geom.Vec2;
	/**
	 * Describle attributes for objects witch interacts with IInteragents
	 * @author Fernando Rabello
	 */
	public class InteractorAttributes {
		
		/** 0 is missing requirements, -1 is false, 1 is true */
		public var readyToInteract:int = -1;
		
		public var canInteract:Boolean = true;
		public var currentInteragent:IInteragent;
		public var parent:IInteractor;
		private var _ge:GameEngine;
		
		public function InteractorAttributes(parent:IInteractor) {
			_ge = GameEngine.instance;
			this.parent = parent
		}
		
		public function verifyInteragents():void{
			var cInteragent:IInteragent;
			var interagens:Vector.<IInteragent> = (_ge.state as LevelManager).iteragents;
			var iLenght:int = interagens.length;
			var iIndex:int;
			var cDistance:Vec2 = Vec2.get();
			var closestDistance:Number = 1000000;
			currentInteragent = null;
			readyToInteract = -1;
			
			for (iIndex = 0; iIndex < iLenght; iIndex++){
				cInteragent = interagens[iIndex];
				
				cDistance.setxy(cInteragent.x - parent.x, cInteragent.y - parent.y);
				
				if (cInteragent.canInteract && cDistance.length < cInteragent.interactionDistance){
					if (cDistance.length < closestDistance){
						closestDistance = cDistance.length;
						currentInteragent = cInteragent;
					}
				}
			}
			
			if(currentInteragent){
				if (currentInteragent.interactionType == InteractorsTypes.TYPE_SOKET){
					if (parent.verifyInteractionRequirements(currentInteragent))
						readyToInteract = 1;
					else
						readyToInteract = 0;
				}
				else if(currentInteragent.interactionType == InteractorsTypes.TYPE_TALK){
					readyToInteract = 1;
				}
				else if(currentInteragent.interactionType == InteractorsTypes.TYPE_LEVER){
					readyToInteract = 1;
				}
			}
			else
				readyToInteract = -1;
		}
		
		public function dispose():void{
			currentInteragent = null;
			parent = null;
			_ge = null;
		}
	}
}