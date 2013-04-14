package com.views.sprites
{
	import com.Constants;
	import com.controllers.CustomCursorManager;
	import com.controllers.LevelCreatorController;
	import com.models.Model;
	
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;

	public class TetrisBlock extends Canvas
	{
		[Bindable]
		private var color:uint = 0; 
		
		[Bindable]
		public var canFloat:Boolean = false;
		
		public function TetrisBlock(x:int, y:int, color:uint, name:String="", canFloat:Boolean=false, isActive:Boolean=false)
		{
			super();
			
			this.width = Constants.BLOCK_WIDTH;
			this.height = Constants.BLOCK_HEIGHT;
			this.x = x;
			this.y = y;
			this.color = color;
			this.canFloat = canFloat;
			this.name = name;

			this.graphics.clear();
			this.graphics.beginFill(color);
			var strokeColor:uint = isActive ? Constants.BLOCK_STROKE_COLOR_ACTIVE : Constants.BLOCK_STROKE_COLOR;
			this.graphics.lineStyle(2, strokeColor);
			this.graphics.drawRect(0, 0, Constants.BLOCK_WIDTH, Constants.BLOCK_HEIGHT);
			this.graphics.endFill();
			
			this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			this.addEventListener(MouseEvent.CLICK, onClickHandler);
		}
		
		private function onClickHandler(e:MouseEvent):void
		{
			trace(this.name + "|" + this.x + "|" + this.y);
			var model:Model = Model.getInstance();
			if(model.editMode){
				LevelCreatorController.SINGLETON.removeBlock(this);
			}
		}
		
		private function onMouseOver(e:MouseEvent):void
		{
			CustomCursorManager.SINGLETON.setBrushNoCursor();
		}
		
		public function getColor():uint
		{
			return this.color;
		}
	}
}