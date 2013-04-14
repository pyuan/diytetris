package com.views.sprites
{
	import caurina.transitions.Tweener;
	
	import com.Constants;
	import com.Embeds;
	import com.controllers.CustomCursorManager;
	import com.controllers.DrawController;
	import com.controllers.GameController;
	import com.controllers.LevelCreatorController;
	import com.models.Model;
	import com.utils.ColorUtil;
	
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.events.FlexEvent;
	
	public class SensorPanel extends Canvas
	{
		
		private var editMode:Boolean = false;
		
		private var animation:Image;
		
		private var numLabel:Label;
		
		public function SensorPanel(editMode:Boolean=false)
		{
			super();
			this.width = Constants.BLOCK_WIDTH;
			this.height = Constants.BLOCK_HEIGHT;
			this.alpha = Constants.SENSOR_PANE_ALPHA_UP;
			this.horizontalScrollPolicy = this.verticalScrollPolicy = 'off';
			this.editMode = editMode;
			
			paint(Constants.SENSOR_PANE_COLOR);
			this.addEventListener(FlexEvent.CREATION_COMPLETE, init);
			this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private function init(e:FlexEvent):void
		{
			var model:Model = Model.getInstance();
			if(!model.editMode){
				animation = new Image();
				animation.name = "animation";
				animation.source = Embeds.SWF_BLOCK_CLEAR;
				animation.width = this.width;
				animation.height = this.height;
				animation.maintainAspectRatio = false;
				animation.smoothBitmapContent = true;
				animation.x = animation.y = 0;
				animation.visible = false;
				
				numLabel = new Label();
				numLabel.name = "numLabel";
				numLabel.width = this.width;
				numLabel.y = this.height/2 - 11;
				numLabel.styleName = "infoBoxHeader";
				numLabel.setStyle('textAlign', 'center');
				numLabel.setStyle('fontSize', 20);
			}
		}
		
		private function paint(fillColor:uint, fillAlpha:Number=Constants.SENSOR_PANE_FILL_ALPHA):void
		{
			this.graphics.clear();
			this.graphics.beginFill(fillColor, fillAlpha);
			this.graphics.lineStyle(1, Constants.SENSOR_PANE_STROKE_COLOR, Constants.SENSOR_PANE_STROKE_ALPHA);
			this.graphics.drawRect(0, 0, this.width, this.height);
			this.graphics.endFill();
		}
		
		private function onMouseMove(e:MouseEvent):void
		{
			var model:Model = Model.getInstance();
			if(!editMode){
				if(GameController.SINGLETON.isMovingTetrisGroup ||
					this.y > GameController.SINGLETON.getHighestBlockY() - Constants.BLOCK_HEIGHT)
				{
					CustomCursorManager.SINGLETON.setBrushNoCursor();
				}
				else{
					CustomCursorManager.SINGLETON.setBrushCursor();
				}
				
				var isAdded:Boolean = DrawController.SINGLETON.addBlock(this);
				if(isAdded && !GameController.SINGLETON.isMovingTetrisGroup)
				{
					paint(model.currentColor);
					this.alpha = Constants.SENSOR_PANE_ALPHA_OVER;
					if(this.getChildByName("numLabel") == null){
						this.addChild(numLabel);
					}
					numLabel.text = model.drawnBlocks.length.toString();
					numLabel.setStyle('color', ColorUtil.getTextOverColor(model.currentColor));
					numLabel.visible = true;
				}
			}
			else{
				CustomCursorManager.SINGLETON.setBrushCursor();
				isAdded = LevelCreatorController.SINGLETON.addBlock(this);
				if(isAdded)
				{
					paint(model.currentColor);
					this.alpha = Constants.SENSOR_PANE_ALPHA_OVER;
				}
			}
		}
		
		public function reset():void
		{
			this.alpha = Constants.SENSOR_PANE_ALPHA_UP;
			paint(Constants.SENSOR_PANE_COLOR);
			
			var model:Model = Model.getInstance();
			if(!model.editMode){
				numLabel.visible = false;
			}
		}
		
		public function blink():void
		{
			var time:Number = 0.5;
			paint(Constants.SENSOR_PANE_COLOR, Constants.SENSOR_PANE_ALPHA_UP);
			
			if(this.getChildByName("animation") == null){
				this.addChild(animation);
			}
			animation.visible = true;
			
			Tweener.addTween(this, {alpha: Constants.SENSOR_PANE_ALPHA_OVER, time: time/2, transition: 'easeOutQuad',
				onComplete: function():void{
					Tweener.addTween(this, {alpha: Constants.SENSOR_PANE_ALPHA_UP, time: time*2, delay: 1, transition:' easeOutQuad',
						onComplete: function():void{
							paint(Constants.SENSOR_PANE_COLOR);
							animation.visible = false;
						}
					});
				}
			});
		}

	}
}