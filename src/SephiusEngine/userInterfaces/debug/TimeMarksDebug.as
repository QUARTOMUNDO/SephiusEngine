package SephiusEngine.userInterfaces.debug {
	import SephiusEngine.math.MathVector;
	import SephiusEngine.core.GameData;
	import SephiusEngine.core.GameEngine;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.extensions.brinkbit.fullscreenscreenextension.FullScreenExtension;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * Show Sephius info on screen
	 * @author Fernando Rabello
	 */
	public class TimeMarksDebug extends Sprite {
		
		public var times:TextField;
		public var starlingT:TextField;
		public var logic:TextField;
		public var view:TextField;
		public var physics:TextField;
		public var debugT:TextField;
		public var UIT:TextField;
		public var inputT:TextField;
		public var renderT:TextField;
		public var frameT:TextField;
		
		public var combination:TextField;
		
		public var bg:Image;
		
		public var allTexts:Array = new Array();
		
		public function TimeMarksDebug() {
			super();
			
			createArt();
		}
		
		public function update():void {
			var timeDelta:Number = 0;
			
			times.text = "TIMES: ";
			logic.text = "-Logic: " + GameEngine.instance.timeMarks.logicTime.toFixed(2) + "/" + GameEngine.instance.timeMarks.logicTimeSingle.toFixed(3) + "ms" + "(" + GameEngine.instance.timeMarks.numOfEngineSteps + ")";
			starlingT.text = "-Starling: " + GameEngine.instance.timeMarks.starlingTime.toFixed(2) + "/" + GameEngine.instance.timeMarks.starlingTimeSingle.toFixed(3) + "ms" + "(" + GameEngine.instance.timeMarks.numOfEngineSteps + ")";
			view.text =  " -View: " + GameEngine.instance.timeMarks.viewTime.toFixed(3) + "ms" + "/" + GameEngine.instance.timeMarks.viewTimeSingle.toFixed(3) + "ms" + "(" + GameEngine.instance.timeMarks.numOfEngineSteps + ")";
			physics.text = " -Physic: " + GameEngine.instance.timeMarks.physicTime.toFixed(3) + "ms" + "/" + GameEngine.instance.timeMarks.physicTimeSingle.toFixed(3) + "ms" + "(" + GameEngine.instance.timeMarks.numOfEngineSteps + ")";
			debugT.text =  "-DEBUG: " + GameEngine.instance.timeMarks.debugTime.toFixed(3) + "ms";
			UIT.text = "-UI: " + GameEngine.instance.timeMarks.uiTime.toFixed(3) + "ms" + "/" + GameEngine.instance.timeMarks.uiTimeSingle.toFixed(3) + "ms" + "(" + GameEngine.instance.timeMarks.numOfEngineSteps + ")";
			inputT.text = "-Input: " + GameEngine.instance.timeMarks.inputTime.toFixed(3) + "ms";
			renderT.text = "-Render: " + GameEngine.instance.timeMarks.renderTime.toFixed(3) + "ms";
			frameT.text = "-Frame: " + GameEngine.instance.frameTime.toFixed(1) + "ms" + " / " + (Math.round(1 / timeDelta) > 60 ? 60 : Math.round(1 / timeDelta)) + "fps";
			combination.text = "-Combination: " + (GameEngine.instance.timeMarks.logicTime +
													GameEngine.instance.timeMarks.starlingTime + 
													GameEngine.instance.timeMarks.viewTime + 
													GameEngine.instance.timeMarks.physicTime +
													GameEngine.instance.timeMarks.debugTime +
													GameEngine.instance.timeMarks.uiTime +
													GameEngine.instance.timeMarks.inputTime +
													GameEngine.instance.timeMarks.renderTime).toFixed(3);
			
			var initialPosition:MathVector = new MathVector ( 50, FullScreenExtension.stageHeight - 50);
			var lastText:TextField;
			for each (var text:TextField in allTexts) {
				if(lastText)
					initialPosition.y -= 35;
				
				text.x = initialPosition.x;
				text.y = initialPosition.y;
				text.scaleX = FullScreenExtension.stageWidth/1920;
				text.scaleY = 1;
				lastText = text;
			}
		}
		
		private function createArt():void {
			bg = new Image(GameEngine.assets.getTexture("Debug_circle"));
			bg.alignPivot();
			bg.color = 0x1B1B14;
			bg.alpha = .65;
			bg.x = -50;
			bg.y = FullScreenExtension.stageHeight - 150;
			bg.width = 700;
			bg.height = 700;
			addChild(bg);
			
			times = new TextField(1000, 50, "", "ChristianaWhite", 16, GameData.getInstance().worldSide == "Dark" ? 0xFFFFFF : 0xFFFFFF, true);
			starlingT = new TextField(1000, 50, "", "ChristianaWhite", 16, GameData.getInstance().worldSide == "Dark" ? 0xFFFFFF : 0xFFFFFF, true);
			logic = new TextField(1000, 50, "", "ChristianaWhite", 16, GameData.getInstance().worldSide == "Dark" ? 0xFFFFFF : 0xFFFFFF, true);
			view = new TextField(1000, 50, "", "ChristianaWhite", 16, GameData.getInstance().worldSide == "Dark" ? 0xFFFFFF : 0xFFFFFF, true);
			physics = new TextField(1000, 50, "", "ChristianaWhite", 16, GameData.getInstance().worldSide == "Dark" ? 0xFFFFFF : 0xFFFFFF, true);
			debugT = new TextField(1000, 50, "", "ChristianaWhite", 16, GameData.getInstance().worldSide == "Dark" ? 0xFFFFFF : 0xFFFFFF, true);
			inputT = new TextField(1000, 50, "", "ChristianaWhite", 16, GameData.getInstance().worldSide == "Dark" ? 0xFFFFFF : 0xFFFFFF, true);
			UIT = new TextField(1000, 50, "", "ChristianaWhite", 16, GameData.getInstance().worldSide == "Dark" ? 0xFFFFFF : 0xFFFFFF, true);
			frameT = new TextField(1000, 50, "", "ChristianaWhite", 16, GameData.getInstance().worldSide == "Dark" ? 0xFFFFFF : 0xFFFFFF, true);
			renderT = new TextField(1000, 50, "", "ChristianaWhite", 16, GameData.getInstance().worldSide == "Dark" ? 0xFFFFFF : 0xFFFFFF, true);
			combination = new TextField(1000, 50, "", "ChristianaWhite", 16, GameData.getInstance().worldSide == "Dark" ? 0xFFFFFF : 0xFFFFFF, true);
			
			var space:TextField = new TextField(50, 50, "");
			
			allTexts.push(frameT, combination, renderT, inputT, UIT, debugT, physics, view, logic, starlingT, space, times);
			
			for each (var text:TextField in allTexts){
				text.hAlign = HAlign.LEFT;
				text.vAlign = VAlign.BOTTOM;
				text.alignPivot(HAlign.LEFT, VAlign.BOTTOM);
				text.bold = true;
				
				addChild(text);
			}
		}
		
		override public function dispose():void {
			times.dispose();
			logic.dispose();
			starlingT.dispose();
			view.dispose();
			debugT.dispose();
			inputT.dispose();
			UIT.dispose();
			frameT.dispose();
			renderT.dispose();
			physics.dispose();
			
			times = null;
			logic = null;
			starlingT = null;
			view = null;
			debugT = null;
			inputT = null;
			UIT = null;
			frameT = null;
			renderT = null;
			physics = null;
			
			allTexts.length = 0;
			
			super.dispose();
		}
	}
	
}