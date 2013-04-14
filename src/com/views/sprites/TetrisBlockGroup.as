package com.views.sprites
{
	import caurina.transitions.Tweener;
	
	import com.Constants;
	import com.controllers.CustomCursorManager;
	import com.controllers.GameController;
	
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.core.Application;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;

	public class TetrisBlockGroup extends Canvas
	{
		
		public var offX:int, offY:int = 0; //stores where the edges of the group for collision detection
		
		private var isDragged:Boolean, isDown:Boolean = false;
		
		private var originalPoint:Point;
		
		public function TetrisBlockGroup(x:int, y:int, blocks:ArrayCollection)
		{
			super();
			this.clipContent = false;
			this.x = x;
			this.y = y;

			for(var i:int=0; i<blocks.length; i++){
				var block:TetrisBlock = blocks[i] as TetrisBlock;
				this.addChild(block);
			}
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			this.addEventListener(ResizeEvent.RESIZE, onResize);
			//this.addEventListener(MouseEvent.CLICK, rotate);
			this.addEventListener(MouseEvent.MOUSE_DOWN, startMove);
			this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			
			Application.application.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		//move blocks so rotation anchor is at center
		private function onCreationComplete(e:FlexEvent):void
		{
			var offX:int = Math.floor(this.width/Constants.BLOCK_WIDTH/2) * Constants.BLOCK_WIDTH;
			var offY:int = Math.floor(this.height/Constants.BLOCK_HEIGHT/2) * Constants.BLOCK_HEIGHT;
			
			//account for when the group can be perfectly halved
			if((this.width/Constants.BLOCK_WIDTH)%2 != 0 && (this.height/Constants.BLOCK_HEIGHT)%2 != 0){
				offX = this.width/2;
				offY = this.height/2;
			}
			
			for(var i:int=0; i<this.numChildren; i++){
				var block:TetrisBlock = this.getChildAt(i) as TetrisBlock;
				block.x -= offX;
				block.y -= offY;
			}
			this.x += offX;
			this.y += offY;   
			this.offX = offX;
			this.offY = offY;
		}
		
		//this is to account for the time difference between creationComplete and resizing the container
		private function onResize(e:ResizeEvent):void
		{
			if(this.width > 0 && this.height > 0){
				//this.y = -this.height; //this makes the block fall from the top no matter where you draw it
				GameController.SINGLETON.startMove(this);
			}
		}
		
		//rotate group
		private function rotate(e:MouseEvent):void
		{
			if(isDown && !isDragged && !Tweener.isTweening(this)){
				var finalR:int = this.rotation + 90;
				if(finalR >= 360){
					finalR = 0;
				}
				trace("New angle: " + finalR);
				var bounds:Rectangle = TetrisBlockGroup.getCollisionBounds(this.x, this.y, this.width, this.height, finalR, this.offX, this.offY);
				var isColliding:Boolean = GameController.SINGLETON.checkCollision(bounds);
				if(!isColliding){
					//Tweener.addTween(this, {rotation: finalR, time: Constants.BLOCK_TWEENER_TIME, transition: 'easeOutQuad'});
					this.rotation = finalR;
				}
				else{
					trace("Cant rotate, colliding with object");
				}
			}
			endMove(e);
		}
		
		//register mouse location to determine move direction
		private function startMove(e:MouseEvent):void
		{
			//CustomCursorManager.SINGLETON.setMoveCursor();
			originalPoint = new Point(Application.application.mouseX, Application.application.mouseY);
			this.addEventListener(MouseEvent.MOUSE_MOVE, moveGroup);
			isDown = true;
		}
		
		//move the group if it does not collide with anything
		private function moveGroup(e:MouseEvent):void
		{
			isDragged = true;
			if(Application.application.mouseX > originalPoint.x){
				moveRight(e);
			}
			else if(Application.application.mouseX < originalPoint.x){
				moveLeft(e);
			}
			//Tweener.addTween(this, {x: destination, time: Constants.BLOCK_TWEENER_TIME, transition: 'easeOutQuad'});
		}
		
		private function moveRight(e:MouseEvent):void
		{
			var destination:int = this.x;
			var bounds:Rectangle = new Rectangle(this.x-offX+Constants.BLOCK_WIDTH, this.y-offY, this.width+offX, this.height+offY);
			var isColliding:Boolean = GameController.SINGLETON.checkCollision(bounds);
			if(!isColliding){
				destination += Constants.BLOCK_WIDTH;
			}
			this.x = destination;
			endMove(e);
		}
		
		private function moveLeft(e:MouseEvent):void
		{
			var destination:int = this.x;
			var bounds:Rectangle = new Rectangle(this.x-offX-Constants.BLOCK_WIDTH, this.y-offY, this.width+offX, this.height+offY);
			var isColliding:Boolean = GameController.SINGLETON.checkCollision(bounds);
			if(!isColliding){
				destination -= Constants.BLOCK_WIDTH;
			}
			this.x = destination;
			endMove(e);
		}
		
		//reset the block after moving it
		private function endMove(e:MouseEvent):void
		{
			GameController.SINGLETON.updateUserMoveTime();
			this.removeEventListener(MouseEvent.MOUSE_MOVE, moveGroup);
			//CustomCursorManager.SINGLETON.setRotateCursor();
			isDragged = false;
			isDown = false;
		}
		
		//called when the game drops the group
		public function drop(toY:int):void
		{
			//Tweener.addTween(this, {y: toY, time: Constants.BLOCK_TWEENER_TIME, transition: 'easeOutQuad'});
			this.y = toY;
		}
		
		private function onMouseOver(e:MouseEvent):void
		{
			//CustomCursorManager.SINGLETON.setRotateCursor();
			CustomCursorManager.SINGLETON.setMoveCursor();
		}
		
		private function onMouseOut(e:MouseEvent):void
		{
			endMove(e);
			CustomCursorManager.SINGLETON.setDefautlCursor();
		}
		
		//returns the collision bound of the group
		public static function getCollisionBounds(x:int, y:int, w:int, h:int, angle:int, offX:int, offY:int):Rectangle
		{
			var bx:int, by:int = 0;
			var bw:int, bh:int = 0;
			if(angle == 90 || angle == 270 || angle == -90){
				bx = x - offY;
				by = y - offX;
				bw = h + offY;
				bh = w + offX;
			}
			else{
				bx = x - offX;
				by = y - offY;
				bw = w + offX;
				bh = h + offY;
			}
			var bounds:Rectangle = new Rectangle(bx, by, bw, bh);
			return bounds;
		}
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			switch(e.keyCode){
				case Keyboard.RIGHT:
					moveRight(new MouseEvent(MouseEvent.MOUSE_UP));
					break;
				case Keyboard.LEFT:
					moveLeft(new MouseEvent(MouseEvent.MOUSE_UP));
					break;
				case Keyboard.DOWN:
					GameController.SINGLETON.dropToBottom();
					break;
			}
		}
		
	}
}