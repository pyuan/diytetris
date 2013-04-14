package com.controllers
{
	import caurina.transitions.Tweener;
	
	import com.Constants;
	import com.Embeds;
	import com.models.Model;
	import com.utils.ColorUtil;
	import com.utils.ConvertUtil;
	import com.views.sprites.SensorPanel;
	import com.views.sprites.TetrisBlock;
	import com.views.sprites.TetrisBlockGroup;
	import com.views.ui.ViewPane;
	
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	
	public class GameController
	{
		public static const SINGLETON : GameController = new GameController();
		
		public var isMovingTetrisGroup:Boolean = false;
		
		//flag to check if the game is curnetly in progress
		[Bindable]
		public var isPlaying:Boolean = false;
		
		private var viewPane:ViewPane;
		
		private var currentTetrisGroup:TetrisBlockGroup;
		
		//step timer for the dropping of the block
		private var dropTimer:Timer;
		
		//stores the current level index
		private var currentLevelIndex:int = -1;
		
		//stores the available level file names
		private var levelsCollection:ArrayCollection = new ArrayCollection();
		
		//keeps track of time elapsed this level
		private var levelTimer:Timer;
		
		//keeps track of the highest block in the viewPane
		private var highestBlockY:int = 0;
				
		public function GameController()
		{
			if(GameController != null)
				throw new Error("This class is a singleton and already has a running instance.  Reference using GameController.SINGLETON.");
		}
		
		public function init(viewPane:ViewPane):void
		{
			this.viewPane = viewPane;
		}
		
		//start playing the game from the begining
		public function startGame():void
		{
			var model:Model = Model.getInstance();
			model.level = 0;
			model.points = 0;
			model.levelRowsCleared = 0;
			
			levelTimer = new Timer(100);
			levelTimer.addEventListener(TimerEvent.TIMER, updateLevelTimer);
			
			if(model.createdLevelName == ""){
				getNewLevel();
			}
			else{
				playUserCreatedLevel();
			}
			trace("Starting a new game.");
		}
		
		//start playing the new level
		public function startLevel():void
		{
			resume();
			ApplicationController.SINGLETON.onLevelChange();
			levelTimer.start();
			isPlaying = true;
			
			//trigger update objective
			var model:Model = Model.getInstance();
			var l:int = model.level;
			model.level = 0;
			model.level = l;
			
			trace("Start new level");
		}
		
		private function updateLevelTimer(e:TimerEvent):void
		{
			var model:Model = Model.getInstance();
			model.levelTime++;
			
			//TODO show dosomething efx
			if(model.levelTime - model.prevMoveTime > Constants.IDLE_TIME){
				AudioController.SINGLETON.playSfx(Constants.AUDIO_DOSOMETHING);
				minusScore(Constants.POINTS_MINUS_PAUSE);
				updateUserMoveTime();
				ApplicationController.SINGLETON.showAnimation(Embeds.SWF_DOSOMETHING);
			}
		}
		
		//updates the user's prev move time marker
		public function updateUserMoveTime():void
		{
			var model:Model = Model.getInstance();
			model.prevMoveTime = model.levelTime;
		}
		
		public function quitGame():void
		{
			pause(false);
			ApplicationController.SINGLETON.showGamePopup(Constants.POPUP_ID_QUIT);
			trace("Quit game, back to main menu.");
		}
		
		private function playUserCreatedLevel():void
		{
			var model:Model = Model.getInstance();
			for(var i:int=0; i<levelsCollection.length; i++){
				if(String(levelsCollection[i]).indexOf(model.createdLevelName) != -1){
					currentLevelIndex = i;
					loadLevel(false);
					model.createdLevelName = "";
					break;
				}
			}
		}
		
		public function getNewLevel(skip:Boolean=false):void
		{
			var newLevelIndex:int = currentLevelIndex;
			while(newLevelIndex == currentLevelIndex){
				newLevelIndex = Math.random() * (levelsCollection.length-1);
			}
			currentLevelIndex = newLevelIndex;
			loadLevel(skip);
			
			if(!skip){
				AudioController.SINGLETON.playNewBackgroundMusic();
				BackgroundManager.SINGLETON.showNewBackgroundImg();
			}
		}
		
		private function loadLevel(skip:Boolean=false):void
		{
			trace("Loading level: " + levelsCollection[currentLevelIndex]);
			var url:URLLoader = new URLLoader(new URLRequest(levelsCollection[currentLevelIndex]));
			url.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void{trace("Level load error: " + e.text);});
			url.addEventListener(Event.COMPLETE, function(e:Event):void{setLevel(e, skip)});
		}
		
		private function setLevel(e:Event, skip:Boolean):void
		{
			var xml:XML = new XML(e.currentTarget.data);
			if(currentTetrisGroup != null){
				currentTetrisGroup = null;
			}
			isMovingTetrisGroup = false;
			viewPane.tetrisContainer.removeAllChildren();
			viewPane.rowsContainer.removeAllChildren();
			for(var i:int=0; i<xml.block.length(); i++){
				var x:int = xml.block[i].x * Constants.BLOCK_WIDTH;
				var y:int = viewPane.height - xml.block[i].y * Constants.BLOCK_HEIGHT;
				var color:uint = ColorUtil.getBlockColor(xml.block[i].color);
				var name:String = ConvertUtil.positionToName(new Point(x, y));
				var block:TetrisBlock = new TetrisBlock(x, y, color, name, true);
				if(x < viewPane.rowsContainer.width && y>=0 && y < viewPane.rowsContainer.height){
					viewPane.rowsContainer.addChild(block);
				}
			}
			setDrawingLine();
			advanceLevel(skip);
		}
		
		private function advanceLevel(skip:Boolean):void
		{
			var model:Model = Model.getInstance();
			if(!skip){
				model.level++;
				
				//increase drop speed only on even levels
				if(model.level%2 == 0){
					model.dropSpeed++;
					if(model.dropSpeed > Constants.MAX_DROP_SPEED){
						model.dropSpeed = Constants.MAX_DROP_SPEED;
					}
				}
			}
			else{
				minusScore(Constants.POINTS_MINUS_SKIP);
			}
			model.levelTime = 0;
			model.levelRowsCleared = 0;
			model.prevMoveTime = 0;
			
			//TODO move this so level starts after user closes level popup
			startLevel();
		}
		
		public function loadLevelsXML(resultHandler:Function=null):void
		{
			var nocache:String = "&date=" + new Date().getTime();
			var url:URLLoader = new URLLoader(new URLRequest(Constants.SERVICE_GETDIR_LEVELS + nocache));
			url.addEventListener(Event.COMPLETE, function(e:Event):void{
				onLevelsLoaded(e, resultHandler);
			});
			url.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void{trace("Error: " + e.text);}); 
		}
		
		private function onLevelsLoaded(e:Event, resultHandler:Function):void
		{
			levelsCollection.removeAll();
			var xml:XML = new XML(e.currentTarget.data);
			for(var i:int=0; i<xml.link.length(); i++){
				levelsCollection.addItem(xml.link[i]);
			}
			if(resultHandler != null){
				resultHandler();
			}
			trace("Levels list loaded");
		}
		
		public function startMove(tetrisGroup:TetrisBlockGroup):void
		{
			var model:Model = Model.getInstance();
			this.currentTetrisGroup = tetrisGroup;
			isMovingTetrisGroup = true;
			dropTimer = new Timer(ConvertUtil.dropSpeedToTime(model.dropSpeed), 1);
			dropTimer.addEventListener(TimerEvent.TIMER_COMPLETE, dropTetrisGroup);
			dropTimer.start();
			dropTimer.dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));
		}
		
		private function dropTetrisGroup(e:TimerEvent):void
		{
			if(currentTetrisGroup != null)
			{
				var py:int = currentTetrisGroup.y + Constants.BLOCK_DROP_AMOUNT;
				var bounds:Rectangle = TetrisBlockGroup.getCollisionBounds(currentTetrisGroup.x, 
					currentTetrisGroup.y+Constants.BLOCK_DROP_AMOUNT, 
					currentTetrisGroup.width, currentTetrisGroup.height, currentTetrisGroup.rotation, 
					currentTetrisGroup.offX, currentTetrisGroup.offY);
				var isColliding:Boolean = checkCollision(bounds);
				if(!isColliding){
					currentTetrisGroup.drop(py);
					dropTimer.start();
				}
				else{
					//give the user some time to move block after it hits the bottom
					Tweener.addTween(currentTetrisGroup, {time: 0.5, onComplete: function():void{onDropStop();}});
				}
			}
		}
		
		//when block group stops dropping, create static blocks in viewpane
		private function onDropStop():void
		{
			if(currentTetrisGroup != null){
				for(var i:int=0; i<currentTetrisGroup.numChildren; i++){
					var block:TetrisBlock = currentTetrisGroup.getChildAt(i) as TetrisBlock;
					var newPt:Point = currentTetrisGroup.transform.matrix.transformPoint(new Point(block.x, block.y));
					var x:int = newPt.x;
					var y:int = newPt.y;
					var name:String = ConvertUtil.positionToName(new Point(x, y));
					var b:TetrisBlock = new TetrisBlock(x, y, block.getColor(), name);
					
					viewPane.rowsContainer.addChild(b);
				}
			
				AudioController.SINGLETON.playSfx(Constants.AUDIO_BLOCK_COLLIDE);
				viewPane.tetrisContainer.removeChild(currentTetrisGroup);
				isMovingTetrisGroup = false;
				dropTimer.stop();
				dropTimer = null;
				currentTetrisGroup = null;
				trace("Drop is stopped");
				
				validateRows();
			}
		}
		
		//drop the current block to the bottom
		public function dropToBottom():void
		{
			if(currentTetrisGroup != null)
			{
				var model:Model = Model.getInstance();
				isMovingTetrisGroup = true;
				dropTimer = new Timer(100, 1);
				dropTimer.addEventListener(TimerEvent.TIMER_COMPLETE, dropTetrisGroup);
				dropTimer.start();
				dropTimer.dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));
			}
			trace("Drop to bottom");
		}
		
		//return true if it collides with something 
		public function checkCollision(bounds:Rectangle):Boolean
		{
			//TODO for debugging purposes
			viewPane.collision.graphics.clear();
			viewPane.collision.graphics.beginFill(0x000000, 0.25);
			viewPane.collision.graphics.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
			viewPane.collision.graphics.endFill();
				
			var isColliding:Boolean = false;
			if(bounds.x < 0 /* || bounds.y < 0 */ || (bounds.y+bounds.height) > viewPane.height || (bounds.x+bounds.width) > viewPane.width){
				isColliding = true;
				trace("Out of bounds");
			}
			if(!isColliding){
				base: for(var i:int=0; i<viewPane.rowsContainer.numChildren; i++)
				{
					var block:TetrisBlock = viewPane.rowsContainer.getChildAt(i) as TetrisBlock;
					if(currentTetrisGroup != null){
						for(var j:int=0; j<currentTetrisGroup.numChildren; j++)
						{
							var b:TetrisBlock = currentTetrisGroup.getChildAt(j) as TetrisBlock;
							if((bounds.x+b.x+currentTetrisGroup.offX)==block.x && 
								(bounds.y+b.y+currentTetrisGroup.offY)==block.y) 
							{
								trace("Collided with block: " + (bounds.x+b.x+currentTetrisGroup.offX)/Constants.BLOCK_WIDTH + "|" + (bounds.y+b.y+currentTetrisGroup.offY)/Constants.BLOCK_HEIGHT);
								isColliding = true;
								break base;
							}
						}
					}
				}
			}
			return isColliding;
		}
		
		//returns the block object reference by its position from left to right, top to bottom
		public function getBlockByPosition(point:Point):TetrisBlock
		{
			var name:String = ConvertUtil.positionToName(point);
			var block:TetrisBlock = null;
			try{
				block = viewPane.rowsContainer.getChildByName(name) as TetrisBlock;
			}catch(e:Error){return null}
			return block;
		}
		
		//returns the sensor panel object reference by its position from left to right, top to bottom
		public function getSensorByPosition(point:Point):SensorPanel
		{
			var name:String = ConvertUtil.positionToName(point);
			var sensor:SensorPanel = null;
			try{
				sensor = viewPane.sensorsContainer.getChildByName(name) as SensorPanel;
			}catch(e:Error){return null}
			return sensor;
		}
		
		//fade all sensor panels back on reset
		public function resetSensorPanels():void
		{
			for(var i:int=0; i<viewPane.sensorsContainer.numChildren; i++)
			{
				var sensor:SensorPanel = viewPane.sensorsContainer.getChildAt(i) as SensorPanel;
				sensor.reset();
			}
		}
		
		//check if row is completed
		private function validateRows():void
		{
			var model:Model = Model.getInstance();
			if(viewPane.rowsContainer.numChildren == 0 || 
				model.levelRowsCleared >= model.level * Constants.OBJECTIVE_ROWS_PER_LEVEL){
				onGameWon();
			}
			else{
				all: for(var y:int=viewPane.rowsContainer.height-Constants.BLOCK_HEIGHT; y>=0; y-=Constants.BLOCK_HEIGHT)
				{
					row: for(var x:int=0; x<viewPane.rowsContainer.width; x+=Constants.BLOCK_WIDTH)
					{
						var block:TetrisBlock = getBlockByPosition(new Point(x, y)) as TetrisBlock;
						if(block == null){
							break row;
						} 
						if(x == viewPane.rowsContainer.width - Constants.BLOCK_WIDTH){
							clearRow(y/Constants.BLOCK_HEIGHT);
							break all;
						}
					}
				}
			}
			setDrawingLine();
			isFinalRow();
			trace("Finished validation.");
		}
		
		//when row matches clear blocks of that row
		private function clearRow(rowIndex:int):void
		{
			var model:Model = Model.getInstance();
			model.levelRowsCleared++;
			model.turnRowsCleared++;
			
			trace("Clearing row: " + rowIndex);
			for(var x:int=0; x<viewPane.rowsContainer.width; x+=Constants.BLOCK_WIDTH){
				var block:TetrisBlock = getBlockByPosition(new Point(x, rowIndex*Constants.BLOCK_HEIGHT)) as TetrisBlock;
				if(block != null){
					viewPane.rowsContainer.removeChild(block);
				}
			}
			AudioController.SINGLETON.playSfx(Constants.AUDIO_CLEAR_ROW);
			plusScore(Constants.POINTS_PLUS_CLEAR_ROW);
			
			//multiple rows bonus
			if(model.turnRowsCleared > 1){
				plusScore(Constants.POINTS_PLUS_CLEAR_ROW_MULTIPLE_BONUS * model.turnRowsCleared);
				AudioController.SINGLETON.playSfx(Constants.AUDIO_AWESOME);
				ApplicationController.SINGLETON.showAnimation(Embeds.SWF_AWESOME);
			}
			
			blinkRow(rowIndex);
			applyGravity();
		}
		
		//show blink effect after clearing row
		private function blinkRow(rowIndex:int):void
		{
			for(var x:int=0; x<viewPane.rowsContainer.width; x+=Constants.BLOCK_WIDTH){
				var sensor:SensorPanel = getSensorByPosition(new Point(x, rowIndex*Constants.BLOCK_HEIGHT)) as SensorPanel;
				if(sensor != null){
					sensor.blink();
				}
			}
		}
		
		//allow all blocks to fall to bottom
		private function applyGravity():void
		{
			for(var y:int=viewPane.rowsContainer.height-Constants.BLOCK_HEIGHT; y>=0; y-=Constants.BLOCK_HEIGHT)
			{
				for(var x:int=0; x<viewPane.rowsContainer.width; x+=Constants.BLOCK_WIDTH)
				{
					var block:TetrisBlock = getBlockByPosition(new Point(x, y)) as TetrisBlock;
					if(block != null && !block.canFloat){
						dropBlockToBottom(block);
					}
				}
			}
			validateRows();
		}
		
		//drop a single block to the bottom
		private function dropBlockToBottom(block:TetrisBlock):void
		{
			if(block != null)
			{
				var yTo:int = block.y + Constants.BLOCK_HEIGHT;
				var bounds:Rectangle = new Rectangle(block.x, yTo, block.width, block.height);
				var isColliding:Boolean = checkBlockDropCollision(bounds);
				if(!isColliding){
					block.y = yTo;
					block.name = ConvertUtil.positionToName(new Point(block.x, block.y));
					//small pause before dropping block again
					Tweener.addTween(block, {time: 0.25, onComplete: function():void{dropBlockToBottom(block);}});
				}
			}
		}
		
		//collision detection for a single block
		private function checkBlockDropCollision(bounds:Rectangle):Boolean
		{
			var isColliding:Boolean = false;
			var block:TetrisBlock = getBlockByPosition(new Point(bounds.x, bounds.y));
			if(block != null || bounds.y > viewPane.rowsContainer.height-Constants.BLOCK_HEIGHT){
				isColliding = true;
			}
			return isColliding;
		}
		
		//pause the game
		public function pause(showPausePopup:Boolean=true):void
		{
			if(dropTimer){
				dropTimer.stop();
			}
			levelTimer.stop();
			isPlaying = false;
			
			if(showPausePopup){
				ApplicationController.SINGLETON.showGamePopup(Constants.POPUP_ID_PAUSE);
			}
		}
		
		//resume the game
		public function resume():void
		{
			if(dropTimer){
				dropTimer.start();
			}
			levelTimer.start();
			isPlaying = true;
			ApplicationController.SINGLETON.hideGamePopup();
		}
		
		public function plusScore(points:int):void
		{
			var model:Model = Model.getInstance();
			model.points += points;
			ApplicationController.SINGLETON.onScoreChange();
			//TODO add sfx?			
			trace("Points rewarded: " + points);
		}
		
		public function minusScore(points:int):void
		{
			var model:Model = Model.getInstance();
			model.points -= points;
			ApplicationController.SINGLETON.onScoreChange();
			//TODO add sfx?
			trace("Points penalized: " + points);
		}
		
		//loop through row container to find the highest block
		private function setHighestBlock():void
		{
			var blockY:int = viewPane.rowsContainer.height;
			var block:TetrisBlock;
			all: for(var y:int=0; y<viewPane.rowsContainer.height; y+=Constants.BLOCK_HEIGHT)
			{
				row: for(var x:int=0; x<viewPane.rowsContainer.width; x+=Constants.BLOCK_WIDTH)
				{
					block = getBlockByPosition(new Point(x, y)) as TetrisBlock;
					//only count block if it's not from the default pattern
					if(block != null /* && !block.canFloat */){
						blockY = y-Constants.BLOCK_HEIGHT; //one block above the highest block
						break all;
					}
				}
			}
			
			if(blockY <= 0){
				if(blockY < 0){
					//check row again to make sure all blocks at the top cannot float
					var canFloat:Boolean = true;
					for(x=0; x<viewPane.rowsContainer.width; x+=Constants.BLOCK_WIDTH){
						block = getBlockByPosition(new Point(x, 0)) as TetrisBlock;
						if(block != null && !block.canFloat){
							canFloat = false;
							break;
						}
					}
					if(!canFloat){
						onGameLost();
					}
				}
				blockY = Constants.BLOCK_HEIGHT;
			}
			
			highestBlockY = blockY;
		}
		
		//when the user loses the game
		public function onGameLost():void
		{
			pause(false);
			ApplicationController.SINGLETON.switchView(Constants.VIEW_GAMEOVER);
		}
		
		private function onGameWon():void
		{
			//process time bonues
			var model:Model = Model.getInstance();
			var diff:int = Constants.BASE_FINISH_TIME - model.levelTime;
			if(diff > 0){
				plusScore(Constants.POINTS_PLUS_TIME * diff);
			}
			
			//TODO show popup instead
			getNewLevel();
		}
		
		//set the drawing line
		public function setDrawingLine():void
		{
			var model:Model = Model.getInstance();
			setHighestBlock();
			viewPane.graphicsContainer.graphics.clear();
			viewPane.graphicsContainer.graphics.lineStyle(Constants.DRAWLINE_THICKNESS, ColorUtil.getComplementaryColor(model.bgAvgColor), 
				1, true, "normal", CapsStyle.NONE, JointStyle.BEVEL);
			for(var x:int=0; x<viewPane.graphicsContainer.width; x+=(Constants.DRAWLINE_DASHES_LENGTH+Constants.DRAWLINE_DASHES_GAP))
			{
				viewPane.graphicsContainer.graphics.moveTo(x, highestBlockY);
				viewPane.graphicsContainer.graphics.lineTo(x+Constants.DRAWLINE_DASHES_LENGTH, highestBlockY);
			}
			
			trace("Finished drawing the valid drawing line at row: " + this.highestBlockY/Constants.BLOCK_HEIGHT);
		}
		
		public function getHighestBlockY():int
		{
			return this.highestBlockY;
		}
		
		//check if there is only one row of blocks left
		public function isFinalRow():Boolean
		{
			var isFinalRow:Boolean = true;
			
			if(viewPane.rowsContainer.numChildren < Constants.VIEW_PANE_WIDTH / Constants.BLOCK_WIDTH)
			{
				all: for(var y:int=0; y<viewPane.rowsContainer.height-Constants.BLOCK_HEIGHT; y+=Constants.BLOCK_HEIGHT)
				{
					row: for(var x:int=0; x<viewPane.rowsContainer.width; x+=Constants.BLOCK_WIDTH)
					{
						var block:TetrisBlock = getBlockByPosition(new Point(x, y)) as TetrisBlock;
						if(block != null){
							isFinalRow = false;
							break all;
						}
					}
				}
			}
			else{
				isFinalRow = false;
			}
			
			if(isFinalRow){
				ApplicationController.SINGLETON.showAnimation(Embeds.SWF_LAST);
			}
			
			return isFinalRow;
		}
		
	}
}