package com.controllers
{
	import com.Constants;
	import com.models.Model;
	import com.utils.ColorUtil;
	import com.utils.ConvertUtil;
	import com.views.sprites.SensorPanel;
	import com.views.sprites.TetrisBlock;
	import com.views.ui.LevelCreator;
	
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	
	public class LevelCreatorController
	{
		public static const SINGLETON : LevelCreatorController = new LevelCreatorController();
		
		private var levelCreator:LevelCreator;
				
		public function LevelCreatorController()
		{
			if(LevelCreatorController != null)
				throw new Error("This class is a singleton and already has a running instance.  Reference using LevelCreatorController.SINGLETON.");
		}
		
		public function init(levelCreator:LevelCreator):void
		{
			this.levelCreator = levelCreator;
		}
		
		//only add if it's not already in the queue
		public function addBlock(sensor:SensorPanel):Boolean
		{
			var model:Model = Model.getInstance();
			if(model.isDrawing){
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
		
		public function resetSensorPanels():void
		{
			for(var i:int=0; i<levelCreator.viewPane.sensorsContainer.numChildren; i++)
			{
				var sensor:SensorPanel = levelCreator.viewPane.sensorsContainer.getChildAt(i) as SensorPanel;
				sensor.reset();
			}
		}
		
		public function addBlocksToPanel(sensors:ArrayCollection, color:uint):void
		{
			for(var i:int=0; i<sensors.length; i++){
				var sensor:SensorPanel = sensors.getItemAt(i) as SensorPanel;
				var name:String = ConvertUtil.positionToName(new Point(sensor.x, sensor.y));
				var block:TetrisBlock = new TetrisBlock(sensor.x, sensor.y, color, name);
				levelCreator.viewPane.rowsContainer.addChild(block);
			}
		}
		
		public function removeBlock(block:TetrisBlock):void
		{
			levelCreator.viewPane.rowsContainer.removeChild(block);
			trace("Remove block: " + block.name);
			trace(levelCreator.viewPane.rowsContainer.numChildren);
		}
		
		public function saveLevel():void
		{
			if(levelCreator.viewPane.rowsContainer.numChildren >= Constants.DEFAULT_LEVELCREATOR_BLOCKS_NUM){
				var data:String = "<?xml version='1.0' encoding='utf-8'?>";
				data += "\n<level>";
				for(var i:int=0; i<levelCreator.viewPane.rowsContainer.numChildren; i++){
					var block:TetrisBlock = levelCreator.viewPane.rowsContainer.getChildAt(i) as TetrisBlock;
					var col:int = Math.floor(block.x/Constants.BLOCK_WIDTH);
					var row:int = Constants.VIEW_PANE_HEIGHT/Constants.BLOCK_HEIGHT - Math.floor(block.y/Constants.BLOCK_HEIGHT);
					data += "\n\t<block>";
					data += "\n\t\t<x>" + col + "</x>";
					data += "\n\t\t<y>" + row + "</y>";
					data += "\n\t\t<color>" + ColorUtil.getColorIndex(block.getColor()) + "</color>";
					data += "\n\t</block>";
				}
				data += "\n</level>";
				ApplicationController.SINGLETON.persistLevel(data, function():void{
					ApplicationController.SINGLETON.switchView(Constants.VIEW_PLAY);
					GameController.SINGLETON.loadLevelsXML(function():void{
						GameController.SINGLETON.startGame();
					});
				});
			}
			else{
				showPopup();
			}
		}
		
		public function clearAll():void
		{
			levelCreator.viewPane.rowsContainer.removeAllChildren();
		}
		
		public function showPopup():void
		{
			levelCreator.showPopup(Constants.POPUP_ID_LEVELCREATOR);
		}
		
		public function hidePopup():void
		{
			levelCreator.hidePopup();
		}
		
	}
}