package com.factories
{
	import com.views.sprites.SensorPanel;
	import com.views.sprites.TetrisBlock;
	import com.views.sprites.TetrisBlockGroup;
	import com.Constants;
	
	import mx.collections.ArrayCollection;
	
	public class TetrisBlockGroupFactory
	{
		
		public static function makeATetrisBlockGroup(sensors:ArrayCollection, color:uint):TetrisBlockGroup
		{
			var minX:int = Constants.VIEW_PANE_WIDTH;
			var minY:int = Constants.VIEW_PANE_HEIGHT;
			for(var i:int=0; i<sensors.length; i++){
				var sensor:SensorPanel = sensors[i] as SensorPanel;
				minX = sensor.x < minX ? sensor.x : minX;
				minY = sensor.y < minY ? sensor.y : minY;
			}
			
			var blocks:ArrayCollection = new ArrayCollection();
			for(i=0; i<sensors.length; i++){
				sensor = sensors[i] as SensorPanel;
				var x:int = sensor.x - minX;
				var y:int = sensor.y - minY;
				var block:TetrisBlock = new TetrisBlock(x, y, color, "", false, true);
				blocks.addItem(block);
			}
			
			var group:TetrisBlockGroup = new TetrisBlockGroup(minX, minY, blocks);
			return group;
		}

	}
}