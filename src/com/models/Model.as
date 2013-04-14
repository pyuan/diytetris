package com.models
{
	import com.controllers.ApplicationController;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class Model
	{
		//flags if the user is currently creating a level
		public var editMode:Boolean = false;
		
		//flag for if the user is current drawing a shape
		public var isDrawing:Boolean = false;
		
		//stores the users drawing
		public var drawnBlocks:Array = [];
		
		//stores the last user drawing to compare with new one
		public var prevDrawnBlocks:Array = [];
		
		//the drop speed of the tetris block
		public var dropSpeed:int = 0;
		
		//the current level for the game
		public var level:int = 0;
		
		//amount of points the user has accumulated
		public var points:int = 0;
		
		//amount of time elapse since current level has started
		public var levelTime:int = 0;
		
		//store the last time when the user did something
		public var prevMoveTime:int = 0;
		
		//stores the current avg color in bg image
		public var bgAvgColor:uint = 0;
		
		//stores all available colors loaded from xml
		public var colors:ArrayCollection;
		
		//stores current color so new color is always different
		public var currentColor:uint = 0;
		
		//keeps track the number of rows clear for the current level
		public var levelRowsCleared:int = 0;
		
		//tracks if multiple rows are cleared in one turn
		public var turnRowsCleared:int = 0;
		
		//stores flags
		public var flags:Array;
		
		//stores the leaderbord models
		public var leaders:ArrayCollection;
		
		//stores the user created level name
		public var createdLevelName:String = "";
		
		public function Model()
		{
			if(Model.getInstance() != null){
				throw new Error("Cannot instantiate a new model object, retrive existing model by calling the static method Model.getInstance();");
			}
		}
		
		public static function getInstance():Model
		{
			return ApplicationController.SINGLETON.model;
		}

	}
}