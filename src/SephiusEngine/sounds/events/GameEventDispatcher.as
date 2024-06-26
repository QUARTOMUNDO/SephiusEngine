package SephiusEngine.sounds.events 
{
	import flash.utils.Dictionary;

	/**
	 * experimental event dispatcher (wip)
	 * TODO: 
	 * - check consistency of bubbling/capturing
	 * - propagation stop ?
	 */
	
	public class GameEventDispatcher 
	{
		protected var listeners:Dictionary;
		
		protected var dispatchParent:GameEventDispatcher;
		protected var dispatchChildren:Vector.<GameEventDispatcher>;
		
		public function GameEventDispatcher() 
		{
			listeners = new Dictionary();
		}
		
		public function addDispatchChild(child:GameEventDispatcher):GameEventDispatcher
		{
			if (!dispatchChildren)
				dispatchChildren = new Vector.<GameEventDispatcher>();
				
			child.dispatchParent = this;
			dispatchChildren.push(child);
			return child;
		}
		
		public function removeDispatchChild(child:GameEventDispatcher):void
		{
			var index:int = -1;
			if(dispatchChildren)
				index = dispatchChildren.indexOf(child);
			if (index < 0)
				return;
			child.dispatchParent = null;
			dispatchChildren.splice(index, 1);
			
			if (dispatchChildren.length == 0)
				dispatchChildren = null;
		}
		
		public function removeDispatchChildren():void
		{
			var child:GameEventDispatcher;
			for each(child in dispatchChildren)
				removeDispatchChild(child);
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			if (type in listeners)
				listeners[type].push({func:listener,useCapture:useCapture});
			else
			{
				listeners[type] = new Vector.<Object>();
				listeners[type].push({func:listener,useCapture:useCapture});
			}
				
		}
		
		public function removeEventListener(type:String, listener:Function):void
		{
			if (type in listeners)
			{
				var index:String;
				var list:Vector.<Object> = listeners[type];
				for (index in list)
					if (list[index].func == listener)
						list.splice(int(index), 1)
			}
		}
		
		public function willTrigger(func:Function):Boolean
		{
			var i:String;
			var list:Vector.<Function>;
			var o:Object;
			for (i in listeners)
			{
				list = listeners[i];
				for each(o in list)
					if (o.func == func)
						return true;
			}
			return false;
		}
		
		public function dispatchEvent(event:GameEvent):void
		{
			if (!event._target)
				event._target = this;
				
			event._currentTarget = this;
			
			var phase:int = event._phase;
			var foundTarget:Boolean = false;
			
			if (this == event._target)
				event._phase = GameEvent.AT_TARGET;
			
			var o:Object;
			if (event._type in listeners)
			{
				var list:Vector.<Object> = listeners[event.type];
				for each(o in list)
				{
						event._currentListener = o.func;
						
							if (o.func.length == 0)
								o.func.apply();
							else
								o.func.apply(null, [event]);
								
							foundTarget = true;
				}
			}
			
			if (event._phase == GameEvent.AT_TARGET && event._bubbles)
				phase = event._phase = GameEvent.BUBBLE_PHASE;
				
			if (dispatchChildren && phase == GameEvent.CAPTURE_PHASE)
			{
				var child:GameEventDispatcher;
				for each(child in dispatchChildren)
				{
					child.dispatchEvent(event);
				}
			}
			
			if (dispatchParent && phase == GameEvent.BUBBLE_PHASE)
			{
				dispatchParent.dispatchEvent(event);
			}
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return type in listeners;
		}
		
		/**
		 * remove all listeners of event
		 */
		public function removeListenersOf(type:String):void
		{
			if (type in listeners)
				delete listeners[type];
		}
		
		/**
		 * remove listener from all events
		 */
		public function removeListener(listener:Function):void
		{
			var i:String;
			var j:String;
			var list:Vector.<Object>;
			for (i in listeners)
			{
				list = listeners[i];
				for (j in list)
					if (listener == list[j].func)
						list.splice(int(j), 1);
			}
		}
		
		/**
		 * remove all event listeners (clears lists)
		 */
		public function removeAllEventListeners():void
		{
			listeners = new Dictionary();
		}
		
	}

}