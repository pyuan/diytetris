package com.controllers
{
	import caurina.transitions.Tweener;
	
	import com.Constants;
	import com.models.ColorModel;
	import com.models.LeaderModel;
	import com.models.Model;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class ApplicationController
	{
		public static const SINGLETON : ApplicationController = new ApplicationController();
		
		private var app:DIYTetris;
		
		public var model:Model;
		
		public function ApplicationController()
		{
			if(ApplicationController != null)
				throw new Error("This class is a singleton and already has a running instance.  Reference using ApplicationController.SINGLETON.");
		}
		
		public function init(app:DIYTetris):void
		{
			this.app = app;
			model = new Model();
			
			AudioController.SINGLETON.init();
			BackgroundManager.SINGLETON.init(app.ui.backgroundImage);
			GameController.SINGLETON.loadLevelsXML();
			getFlags();
			getColors();
		}
		
		public function initControllers():void
		{
			DrawController.SINGLETON.init(app.ui.play.viewPane.tetrisContainer);
			GameController.SINGLETON.init(app.ui.play.viewPane);
		}
		
		public function switchView(viewId:String):void
		{
			app.ui.switchView(viewId);
		}
		
		//get all the colors from xml
		private function getColors():void
		{
			var nocache:String = "?date=" + new Date().getTime();
			var url:URLLoader = new URLLoader(new URLRequest(Constants.FILE_XML_COLORS + nocache));
			url.addEventListener(Event.COMPLETE, setColors);
			url.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void{trace("Error: " + e.text);}); 
		}
		
		private function setColors(e:Event):void
		{
			model.colors = new ArrayCollection();
			var xml:XML = new XML(e.currentTarget.data);
			for(var i:int=0; i<xml.color.length(); i++){
				var name:String = xml.color[i].name;
				var value:uint = xml.color[i].value;
				var color:ColorModel = new ColorModel(name, value);
				model.colors.addItem(color);
			}
			trace("Colors set: " + model.colors.length);
		}
		
		//get all the flags from the flag images directory
		public function getFlags():void
		{
			var nocache:String = "&date=" + new Date().getTime();
			var url:URLLoader = new URLLoader(new URLRequest(Constants.SERVICE_GETDIR_IMAGES_FLAGS + nocache));
			url.addEventListener(Event.COMPLETE, setFlags);
			url.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void{trace("Error: " + e.text);}); 
		}
		
		private function setFlags(e:Event):void
		{
			var flags:Array = new Array();
			var xml:XML = new XML(e.currentTarget.data);
			for(var i:int=0; i<xml.link.length(); i++){
				var link:String = xml.link[i];
				link = link.replace(Constants.DIR_FLAGS, "");
				link = link.replace(Constants.EXTENSION_FLAGS, "");
				link = link.toUpperCase();
				flags.push(link);
			}
			model.flags = flags;
			trace("Flags loaded: " + flags.length); 
		}
		
		//save the level data into an xml file
		public function persistLevel(levelData:String, resultHandler:Function=null):void
		{
			var name:String = new Date().getTime().toString();
			model.createdLevelName = name;
			var httpService:HTTPService = new HTTPService();
			httpService.url = Constants.SERVICE_LEVEL_PERSIST;
			httpService.method = "POST";
			httpService.contentType = "application/x-www-form-urlencoded";
			var params:Object = {name: name, data: levelData};
			httpService.addEventListener(ResultEvent.RESULT, function(e:ResultEvent):void{
				onLevelPersisted(e);
				if(resultHandler != null){
					resultHandler(e);
				}
			});
			httpService.send(params);
		}
		
		private function onLevelPersisted(e:ResultEvent):void
		{
			trace("Level persisted: " + e.message.body);
		}
		
		//check if the score is enough to qualify for the leaderboard
		public function checkLeaderboard(score:int, onResultHandler:Function):void
		{
			var httpService:HTTPService = new HTTPService();
			httpService.url = Constants.SERVICE_LEADERBOARD;
			httpService.method = "POST";
			httpService.contentType = "application/x-www-form-urlencoded";
			var params:Object = {command: "check", score: score};
			httpService.addEventListener(ResultEvent.RESULT, function(e:ResultEvent):void{
				onLeaderboardCheck(e, score, onResultHandler);
			});
			httpService.send(params);
		}
		
		private function onLeaderboardCheck(e:ResultEvent, score:int, onResultHandler:Function):void
		{
			onResultHandler(e.message.body);
			trace("Score: " + score + " qualifies for leaderboard: " + e.message.body);
		}
		
		//get the leaderboard
		public function getLeaderboard():void
		{
			var httpService:HTTPService = new HTTPService();
			httpService.url = Constants.SERVICE_LEADERBOARD;
			httpService.method = "POST";
			httpService.contentType = "application/x-www-form-urlencoded";
			var params:Object = {command: "get"};
			httpService.addEventListener(ResultEvent.RESULT, setLeaderboard);
			httpService.send(params);
		}
		
		private function setLeaderboard(e:ResultEvent):void
		{
			var xml:XML = new XML(e.message.body); 
			model.leaders = new ArrayCollection();
			if(xml.leader){
				for(var i:int=0; i<xml.leader.length(); i++){
					var name:String = xml.leader[i].name;
					var score:int = xml.leader[i].score;
					var level:int = xml.leader[i].level;
					var country:String = xml.leader[i].country;
					var leader:LeaderModel = new LeaderModel(name, score, level, country);
					model.leaders.addItem(leader);
				}
			}
			
			var dataSortField:SortField = new SortField();
            dataSortField.name = "score";
            dataSortField.numeric = true;
            dataSortField.reverse();
            var numericDataSort:Sort = new Sort();
            numericDataSort.fields = [dataSortField];
            model.leaders.sort = numericDataSort;
            model.leaders.refresh();
			
			switchView(Constants.VIEW_LEADERBOARD);
			trace("Leaderboard set: " + model.leaders.length);
		}
		
		//add a user's score to leaderboard
		public function addLeader(name:String, score:int, level:int, country:String):void
		{
			var httpService:HTTPService = new HTTPService();
			httpService.url = Constants.SERVICE_LEADERBOARD;
			httpService.method = "POST";
			httpService.contentType = "application/x-www-form-urlencoded";
			var params:Object = {command: "set", name: name, score: score, level: level, country: country};
			httpService.addEventListener(ResultEvent.RESULT, setLeaderboard);
			httpService.send(params);
		}
		
		//set current loading data
		public function setLoader(bytesLoaded:int, bytesTotal:int):void
		{
			app.loader.setData(bytesLoaded, bytesTotal);
			if(bytesLoaded < bytesTotal){
				onLoading();
			}
			else{
				onLoaded();
			}
			trace("Setting loader data: " + bytesLoaded + " / " + bytesTotal);
		}
		
		public function onLoading():void
		{
			Tweener.addTween(app.ui, {alpha: 0.25, time: 1, transition: 'easeOutQuad'});
		}
		
		public function onLoaded():void
		{
			Tweener.addTween(app.ui, {alpha: 1, time: 1, transition: 'easeOutQuad'});
			app.ui.footer.updateColor(model.bgAvgColor);
		}
		
		//called when user's score changes
		public function onScoreChange():void
		{
			app.ui.play.animateScore();
		}
		
		//called when the user passes a level
		public function onLevelChange():void
		{
			app.ui.play.animate();
		}
		
		//show popup in game view
		public function showGamePopup(popupId:String):void
		{
			app.ui.play.showPopup(popupId);
		}
		
		public function hideGamePopup():void
		{
			app.ui.play.hidePopup();
		}
		
		public function showAnimation(source:Class):void
		{
			app.ui.play.viewPane.showAnimation(source);	
		}

		public function enterEditMode(enterMode:Boolean):void
		{
			model.editMode = enterMode;
		}
		
	}
}