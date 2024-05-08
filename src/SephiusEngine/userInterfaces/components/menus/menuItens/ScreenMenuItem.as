package SephiusEngine.userInterfaces.components.menus.menuItens {
	import SephiusEngine.Languages.LanguageManager;
	import SephiusEngine.core.GameEngine;

	import com.greensock.TweenMax;

	import starling.display.Image;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * Single Menu Item (for screen menu)
	 * @author Fernando Rabello
	 */
	public class ScreenMenuItem extends MenuItem {
		public var states:Vector.<String> = new Vector.<String>();
		private var _skin:String = "Light";
		private var halfSelectionHighlightTextures:Array = [];

		/** Subselectable itens witch this item will contain */
		public var selectedTextField:TextField;
		public var leftArrow:Image = new Image(GameEngine.assets.getTexture("OptionsMenu_PreviousIndicator"));
		public var rightArrow:Image = new Image(GameEngine.assets.getTexture("OptionsMenu_NextIndicator"));

		public var defaultState:String;

		public function get numOfStates():int{
			return states.length;
		}

		public function get lastState():int{
			return states.length - 1;
		}

		public function ScreenMenuItem(id:String, langCategory:String, skinNames:Array, hightLights:Array, hightLightsHaf:Array, blendModes:Array, states:Array, alignMode:String="center"){
			super(id, langCategory, skinNames, hightLights, blendModes, .5, false, 30, alignMode);

			this.langCategory = langCategory;

			selectedTextField = new TextField(50, 50, "", "ChristianaWhite", textSize, 0xffffff, true);
			selectedTextField.autoSize = TextFieldAutoSize.HORIZONTAL;
			selectedTextField.alignPivot(HAlign.LEFT);
			
 			if(states.length > 0){
				setStates(states);
				addChild(selectedTextField);
				selectedTextField.x = 25;
				this.text.textFiled.alignPivot(HAlign.RIGHT);

				leftArrow.alignPivot();
				rightArrow.alignPivot();

				addChild(leftArrow);
				addChild(rightArrow);

				leftArrow.x = 30; 
				rightArrow.x = selectedTextField.width + 40; 
			}
			else{
				selectedTextField.x = 0;
				this.text.textFiled.alignPivot(HAlign.CENTER);
			}
			
			selectedTextField.y = 0;
			
			var i:int = 0;
			for (i = 0; i < hightLights.length; i++){
				halfSelectionHighlightTextures.push(GameEngine.assets.getTexture(hightLightsHaf[i]));
				selectionHighlightTextures.push(GameEngine.assets.getTexture(hightLights[i]));
			}
			
			//selectionHighlightTextures = hightLights;
			//halfSelectionHighlightTextures = hightLightsHaf;
			selectionHighlightBlendModes = blendModes;
			
			setHighlightArt(hightLights);
		}
		
		override public function setHighlightArt(textureNames:Array):void {
			if(states.length == 0) {
				selectionHighlight = new Image(selectionHighlightTextures[0]);
				selectionHighlight.alignPivot(HAlign.CENTER, VAlign.CENTER);
			}
			else {
				selectionHighlight = new Image(halfSelectionHighlightTextures[0]);
				selectionHighlight.alignPivot(HAlign.CENTER, VAlign.CENTER);
			}
			
			selectionHighlight.x = selectionHighlight.y = 0;
			//selectionHighlight.alignPivot();
			selectionHighlight.width = this.text.width * 2 + 100;
			selectionHighlight.blendMode = selectionHighlightBlendModes[0];
			selectionHighlight.alpha = 0;
			selectionHighlight.touchable = false;
			addChildAt(selectionHighlight, 0);
		}
		
		override public function set skin(value:String):void {
			super.skin = value;
			
			if(states.length > 0){
				var skinIndex:int = skinNames.indexOf(value);
				selectionHighlight.texture = halfSelectionHighlightTextures[skinIndex];
			}
		}
		
		public function setStates(states:Array):void {
			this.states = Vector.<String>(states);
			defaultState = states[0];
			currentState = 0;
		}
		
		override public function set selected(value:Boolean):void {
			if (_selected == value)
				return;
				
			if(value)
				TweenMax.to(selectionHighlight, .3, { alpha:highlightAlpha } );
			else
				TweenMax.to(selectionHighlight, .3, { alpha:0 } );
				
			_selected = value;
		}
		
		override public function updateLang(langID:String=""):void{
			super.updateLang(langID);

			if(states.length > 0){
				var selectFieldText:String;
				if(langCategory == "")//Should not translate.
					selectFieldText = states[_currentState];
				else
					selectFieldText = LanguageManager.getSimpleLang(langCategory, states[_currentState]).name;
				selectedTextField.text = selectFieldText;
				rightArrow.x = selectedTextField.width + 40; 
			}
		}

		public function nextState():int{
			if(currentState < lastState)
				currentState++;

			return currentState;
		}

		public function previousState():int{
			if(currentState > 0)
				currentState--;

			return currentState;
		}

		public function get currentStateID():String{return states[currentState];}

		private var changeBias:int = 0;
		public function get currentState():int{return _currentState;}
		public function set currentState(value:int):void{
			if (_currentState == value)
				return;
				
			changeBias = (value > _currentState) ? 1 : -1;

			if(_currentState != -1 || value == -1)	
				selectedTextField.text = defaultState;
			
			if(value != -1){
				var selectFieldText:String;
				if(langCategory == "")//Should not translate.
					selectFieldText = states[value];
				else
					selectFieldText = LanguageManager.getSimpleLang(langCategory, states[value]).name;

				selectedTextField.text = selectFieldText;
				selectedTextField.alignPivot(HAlign.LEFT);
				selectedTextField.alpha = 0;
				
				leftArrow.alpha = value == 0 ? 0 : 1;
				rightArrow.alpha = value == lastState ? 0 : 1;
				rightArrow.x = selectedTextField.width + 40; 

				TweenMax.to(rightArrow, .3, { startAt:{ alpha:0 }, alpha:rightArrow.alpha } );
				TweenMax.to(leftArrow, .3, { startAt:{ alpha:0 }, alpha:leftArrow.alpha } );
				
				var finalPosition:Number = 35;
				TweenMax.to(selectedTextField, .3, { startAt:{ x:(finalPosition + (200 * changeBias)), alpha:0 }, x:(finalPosition), alpha:1 } );
			}
			
			_currentState = value;
		}
		private var _currentState:int = -1;
	}
}