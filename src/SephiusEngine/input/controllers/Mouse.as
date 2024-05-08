package SephiusEngine.input.controllers {

    import SephiusEngine.input.InputController;

    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.utils.Dictionary;
    import flash.utils.Timer;

    public class Mouse extends InputController {
        protected var _mouseActions:Dictionary;

        private var wheelTimer:Timer = new Timer(100, 1); // 100 milliseconds delay
        private var wheelUpActive:Boolean = false;
        private var wheelDownActive:Boolean = false;

        public static var MODIFICATION_ACTIVE:Boolean = false;

        public function Mouse(name:String, params:Object = null){
            super(name, params);

            _mouseActions = new Dictionary();

            // Add mouse event listeners
            _ge.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
            _ge.stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onMouseEvent);
            _ge.stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMouseEvent);

            _ge.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseEvent);
            _ge.stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onMouseEvent);
            _ge.stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMouseEvent);

            _ge.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
            
            // Initialize the timer
            wheelTimer.addEventListener(TimerEvent.TIMER, onWheelTimer);

            // Add other mouse event listeners if needed
        }    

        private function onMouseEvent(e:MouseEvent):void {
            var eventType:String = getButtomName(e);
            
            var a:Object;

            //trace("[Mouse] MouseEvent", eventType);

            if (_mouseActions[eventType]){
                for each (a in _mouseActions[eventType]){
                    if (e.type == MouseEvent.MOUSE_DOWN || e.type == MouseEvent.RIGHT_MOUSE_DOWN || e.type == MouseEvent.MIDDLE_MOUSE_DOWN) {
                        triggerON(a.name, 1, null, (a.channel < 0) ? defaultChannel : a.channel);
                    } 
                    else if (e.type == MouseEvent.MOUSE_UP || e.type == MouseEvent.RIGHT_MOUSE_UP || e.type == MouseEvent.MIDDLE_MOUSE_UP) {
                        triggerOFF(a.name, 0, null, (a.channel < 0) ? defaultChannel : a.channel);
                    }
                }
            }

            //Activates or deactivates Left and Right nouse's buttons. This allow to perform different actions depending on key modifications
            //if(e.type == MouseEvent.MIDDLE_MOUSE_DOWN)
                //MODIFICATION_ACTIVE = !MODIFICATION_ACTIVE;
        }
        
        private function getButtomName(e:MouseEvent):String{
            if(!MODIFICATION_ACTIVE){
                switch(e.type)
                {
                    case MouseEvent.MOUSE_DOWN:
                    case MouseEvent.MOUSE_UP:
                        return LEFT;
                        break;
                    case MouseEvent.RIGHT_MOUSE_DOWN:
                    case MouseEvent.RIGHT_MOUSE_UP:
                        return RIGHT;
                        break;
                    case MouseEvent.MIDDLE_MOUSE_DOWN:
                    case MouseEvent.MIDDLE_MOUSE_UP:
                        return MIDDLE;
                        break;
                
                    default:
                        return "null";
                        break;
                }
            }
            else{
                switch(e.type)
                {
                    case MouseEvent.MOUSE_DOWN:
                    case MouseEvent.MOUSE_UP:
                        return LEFT_MODIFIED;
                        break;
                    case MouseEvent.RIGHT_MOUSE_DOWN:
                    case MouseEvent.RIGHT_MOUSE_UP:
                        return RIGHT_MODIFIED;
                        break;
                    case MouseEvent.MIDDLE_MOUSE_DOWN:
                    case MouseEvent.MIDDLE_MOUSE_UP:
                        return MIDDLE;
                        break;
                
                    default:
                        return "null";
                        break;
                }
            }
        }

        private function determineButtonType(e:MouseEvent):String {
            if (e.buttonDown) return "LEFT";
            if (e.type == MouseEvent.RIGHT_CLICK) return e.type;

            // Extend this method for handling other buttons if necessary
            return "UNKNOWN";
        }

        /** Deals with mouse wheel up and down. Have a "release" kind of handing by using a timer
         * so is possible to verify a "onDoing" for wheel related actions as well.
         */
        private function onMouseWheel(e:MouseEvent):void {
            var eventKey:String = (e.delta > 0) ? "WHEEL_UP" : "WHEEL_DOWN";
            var a:Object;
            //trace("[Mouse] MouseWheelEvent", eventKey);
            // Check and disable the opposite wheel event if it was active
            if (eventKey == "WHEEL_UP" && wheelDownActive) {
                if (_mouseActions["WHEEL_DOWN"]){
                    for each (a in _mouseActions["WHEEL_DOWN"]){
                        triggerOFF(a.name, 0, null, (a.channel < 0) ? defaultChannel : a.channel);
                    }
                }
                wheelDownActive = false;
            } 
            else if (eventKey == "WHEEL_DOWN" && wheelUpActive) {
                if (_mouseActions["WHEEL_UP"]){
                    for each (a in _mouseActions["WHEEL_UP"]){
                        triggerOFF(a.name, 0, null, (a.channel < 0) ? defaultChannel : a.channel);
                    }
                }
                wheelUpActive = false;
            }

            // Set the current wheel event as active
            if (eventKey == "WHEEL_UP") wheelUpActive = true;
            if (eventKey == "WHEEL_DOWN") wheelDownActive = true;

            // Trigger the "on" action for the current wheel event
            if (_mouseActions[eventKey]){
                for each (a in _mouseActions[eventKey]){
                    triggerON(a.name, e.delta, null, (a.channel < 0) ? defaultChannel : a.channel);
                }
            }

            // Restart the timer every time the wheel event is triggered
            wheelTimer.reset();
            wheelTimer.start();
        }

        /** Timer used for on doing and has done phases for mouse wheel events */
        private function onWheelTimer(e:TimerEvent):void {
            var eventKey:String;
            
            if (wheelUpActive) {
                eventKey = WHEEL_UP;
                wheelUpActive = false;
            }

            if (wheelDownActive) {
                eventKey = WHEEL_DOWN;
                wheelDownActive = false;
            }

            if (_mouseActions[eventKey]){
                var a:Object;
                for each (a in _mouseActions[eventKey]){
                    triggerOFF(a.name, 0, null, (a.channel < 0) ? defaultChannel : a.channel);
                }
            }
        }


        public function addMouseAction(actionName:String, mouseEvent:String, channel:int = -1):void {
            if (!_mouseActions[mouseEvent])
                _mouseActions[mouseEvent] = new Vector.<Object>();
            else {
                var a:Object;
                for each (a in _mouseActions[mouseEvent])
                    if (a.name == actionName && a.channel == channel)
                        return;
            }

            _mouseActions[mouseEvent].push({name: actionName, channel: channel});
        }

        public function removeActionFromMouse(actionName:String, mouseEvent:String):void {
            if (_mouseActions[mouseEvent]) {
                var actions:Vector.<Object> = _mouseActions[mouseEvent];
                var i:String;
                for (i in actions)
                    if (actions[i].name == actionName) {
                        actions.splice(uint(i), 1);
                        return;
                    }
            }
        }

		/**
		 * Removes every actions by name, on every keys.
		 */
		public function removeAction(actionName:String):void{
			var actions:Vector.<Object>;
			var i:String;
			for each (actions in _mouseActions)
				for (i in actions)
					if (actions[uint(i)].name == actionName)
						actions.splice(uint(i), 1);
		}

		/**
		 * Deletes the entire registry of key actions.
		 */
		public function resetAllKeyActions():void{
			_mouseActions = new Dictionary();
		}

		/**
		 * Removes all actions on a key.
		 */
		public function removeKeyActions(keyCode:uint):void{
			delete _mouseActions[keyCode];
		}

		public static const LEFT:String = "LEFT";
		public static const RIGHT:String = "RIGHT";

		public static const LEFT_MODIFIED:String = "LEFTMODIFIED";
		public static const RIGHT_MODIFIED:String = "RIGHTMODIFIED";

		public static const MIDDLE:String = "MIDDLE";

		public static const WHEEL_UP:String = "WHEEL_UP";
		public static const WHEEL_DOWN:String = "WHEEL_DOWN";

    }
}