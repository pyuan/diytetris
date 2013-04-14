package com.controllers
{
	import com.Constants;
	import com.Embeds;
	import com.factories.TetrisBlockGroupFactory;
	import com.models.Model;
	import com.utils.ColorUtil;
	import com.views.sprites.SensorPanel;
	import com.views.sprites.TetrisBlockGroup;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	
	public class DrawController
	{
		public static const SINGLETON : DrawController = new DrawController();
		
		private var tetrisContainer:Canvas;
				
		public function DrawController()
		{
			if(DrawController != null)
				throw new Error("This class is a singleton and already has a running instance.  Reference using DrawController.SINGLETON.");
		}
		
		public function init(tetrisContainer:Canvas):void
		{
			this.tetrisContainer = tetrisContainer;
		}
		
		public function startDrawing():void
		{
			var model:Model = Model.getInstance();
			model.isDrawing = true;
			model.drawnBlocks = [];
			if(!model.editMode){
				model.currentColor = ColorUtil.getNewColor();
				GameController.SINGLETON.updateUserMoveTime();
			}
			model.turnRowsCleared = 0;
			trace("Start drawing");
		}
		
		public function stopDrawing():void
		{
			var model:Model = Model.getInstance();
			if(model.isDrawing){
				if(!model.editMode){
					var isValid:Boolean = validateDrawing();
					if(isValid){
						model.prevDrawnBlocks = model.drawnBlocks;
						createTetrisBlockGroup();
						AudioController.SINGLETON.playSfx(Constants.AUDIO_BLOCK_CREATED);
					}
					else{
						AudioController.SINGLETON.playSfx(Constants.AUDIO_BLOCK_ERROR);
					}
					GameController.SINGLETON.resetSensorPanels();
				}
				else{
					createTetrisBlockGroup();
					AudioController.SINGLETON.playSfx(Constants.AUDIO_BLOCK_CREATED);
					LevelCreatorController.SINGLETON.resetSensorPanels();
				}
			}
			model.isDrawing = false;
			//trace("Stop drawing");
		}
		
		//add drawn block reference to queue
		public function addBlock(sensor:SensorPanel):Boolean
		{
			var model:Model = Model.getInstance();
			if(model.drawnBlocks.length < Constants.MAX_BLOCKS_NUM && model.isDrawing){
				var isDuplicate:Boolean = false;
				for(var i:int=0; i<model.drawnBlocks.length; i++){
					if(sensor == model.drawnBlocks[i]){
						isDuplicate = true;
						break;
					}
				}
				if(!isDuplicate){
					model.drawnBlocks.push(sensor);
					return true;
				}
				else{
					return false;
				}
			}
			else{
				return false;
			}
		}
		
		//create tetris block group and inserts into view
		private function createTetrisBlockGroup():void
		{
			var model:Model = Model.getInstance();
			var color:uint = model.currentColor;
			var blocks:TetrisBlockGroup = TetrisBlockGroupFactory.makeATetrisBlockGroup(new ArrayCollection(model.drawnBlocks), color);
			if(!model.editMode){
				tetrisContainer.addChild(blocks);
				GameController.SINGLETON.updateUserMoveTime();
			}
			else{
				LevelCreatorController.SINGLETON.addBlocksToPanel(new ArrayCollection(model.drawnBlocks), color);
			}
			trace("Tetris block created");
		}
		
		//check if the user's drawing satisfy the rules of the game
		private function validateDrawing():Boolean
		{
			var model:Model = Model.getInstance();
			var isValid:Boolean = false;
			var isFinalRow:Boolean = GameController.SINGLETON.isFinalRow();
			if((isFinalRow || (!isFinalRow && model.drawnBlocks.length == Constants.MAX_BLOCKS_NUM)) &&
				isDrawnAboveLine() && !isSameAsPrevShape())
			{
				isValid = true;
			}
			
			if(isValid){
				trace("Valid Drawing");
			}
			else{
				//TODO handle invalid drawing error msg
				if(!isDrawnAboveLine()){
					ApplicationController.SINGLETON.showAnimation(Embeds.SWF_ABOVE_LINE);
				}
				else if(isSameAsPrevShape()){
					ApplicationController.SINGLETON.showAnimation(Embeds.SWF_DIFF_SHAPE);
				}
				else{
					ApplicationController.SINGLETON.showAnimation(Embeds.SWF_5BLOCKS);
				}
				trace("Invalid drawing!");
			}
			return isValid;
		}
		
		private function isSameAsPrevShape():Boolean
		{
			var isSame:Boolean = true;
			var model:Model = Model.getInstance();
			//sort so the objects are in order for comparison
			var sortOnXY:Function = function sortOnPrice(a:SensorPanel, b:SensorPanel):Number {
			    var ax:int = a.x;
			    var ay:int = a.y;
			    var bx:int = b.x;
			    var by:int = b.y;
			    var result:Number = 0;
			    if(ax > bx){
			        result = 1;
			    } else if(ax < bx){
			        result = -1;
			    } else{
			        if(ay > by){
			        	result = 1;
			        }
			        else if(ay < by){
			        	result = -1;
			        }
			    }
			    return result;
			};
			model.drawnBlocks.sort(sortOnXY);
			model.prevDrawnBlocks.sort(sortOnXY);
			
			if(model.drawnBlocks.length != model.prevDrawnBlocks.length){
				isSame = false;
			}
			else{
				//get origin points so that the shapes can be compared even when they are drawn at separate locations
				var nx:int = Constants.VIEW_PANE_WIDTH;
				var ox:int = Constants.VIEW_PANE_WIDTH;
				var ny:int = Constants.VIEW_PANE_HEIGHT;
				var oy:int = Constants.VIEW_PANE_HEIGHT;
				for(var i:int=0; i<model.drawnBlocks.length; i++){
					var n:SensorPanel = model.drawnBlocks[i] as SensorPanel;
					var o:SensorPanel = model.prevDrawnBlocks[i] as SensorPanel;
					nx = nx < n.x ? nx : n.x;
					ny = ny < n.y ? ny : n.y;
					ox = ox < o.x ? ox : o.x;
					oy = oy < o.y ? oy : o.y;
				}
				for(i=0; i<model.drawnBlocks.length; i++){
					n = model.drawnBlocks[i] as SensorPanel;
					o = model.prevDrawnBlocks[i] as SensorPanel;
					if(n.x-nx != o.x-ox || n.y-ny != o.y-oy){
						isSame = false;
						break;
					}
				}
			}
			
			return isSame;
		}
		
		private function isDrawnAboveLine():Boolean
		{
			var model:Model = Model.getInstance();
			var isAbove:Boolean = false;
			for(var i:int=0; i<model.drawnBlocks.length; i++)
			{
				var sensor:SensorPanel = model.drawnBlocks[i];
				if(sensor.y < GameController.SINGLETON.getHighestBlockY())
				{
					isAbove = true;
					break;
				}
			}
			return isAbove;
		}
	}
}