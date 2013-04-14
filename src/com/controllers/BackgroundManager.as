package com.controllers
{
	import com.Constants;
	import com.models.Model;
	import com.utils.ColorUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Image;
	import mx.core.Application;
	import mx.events.ResizeEvent;
	
	public class BackgroundManager
	{
		public static const SINGLETON : BackgroundManager = new BackgroundManager();
		
		//stores the current background music
		private var currentBgIndex:int = -1;
		
		//stores the available background music file names
		private var backgroundImgsCollection:ArrayCollection = new ArrayCollection();
		
		private var backgroundImage:Image;
		
		public function BackgroundManager()
		{
			if(BackgroundManager != null)
				throw new Error("This class is a singleton and already has a running instance.  Reference using BackgroundManager.SINGLETON.");
		}
		
		public function init(image:Image):void
		{
			this.backgroundImage = image;
			getBackgroundImgs();
			
			backgroundImage.addEventListener(ResizeEvent.RESIZE, resizeImage);
			Application.application.addEventListener(ResizeEvent.RESIZE, resizeImage);
		}
		
		//sends urlrequest to get the background images xml
		private function getBackgroundImgs():void
		{
			var nocache:String = "&date=" + new Date().getTime();
			var url:URLLoader = new URLLoader(new URLRequest(Constants.SERVICE_GETDIR_IMAGES_BACKGROUNDS + nocache));
			url.addEventListener(Event.COMPLETE, setBackgroundImgs);
			url.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void{trace("Error: " + e.text);}); 
		}
		
		private function setBackgroundImgs(e:Event):void
		{
			backgroundImgsCollection.removeAll();
			
			var xml:XML = new XML(e.currentTarget.data);
			for(var i:int=0; i<xml.link.length(); i++){
				backgroundImgsCollection.addItem(xml.link[i]);
			}
			
			//add non-random background
			backgroundImgsCollection.addItemAt(Constants.IMAGE_BACKROUND_GAMEOVER, Constants.IMAGE_BACKGROUND_ID_GAMEOVER);
			
			trace("Background images list loaded");
			showNewBackgroundImg();
		}
		
		public function showSpecificBackground(backgroundId:int):void
		{
			currentBgIndex = backgroundId;
			showBackgroundImg();
		}
		
		public function showNewBackgroundImg():void
		{
			var newBgIndex:int = currentBgIndex;
			while(newBgIndex < 0 || newBgIndex == currentBgIndex || newBgIndex == 0)
			{
				newBgIndex = Math.random() * (backgroundImgsCollection.length-1);
			}
			currentBgIndex = newBgIndex;
			showBackgroundImg();
		}
		
		private function showBackgroundImg():void
		{
			var l:Loader = new Loader();
			l.load(new URLRequest(backgroundImgsCollection[currentBgIndex]));
			l.contentLoaderInfo.addEventListener(Event.COMPLETE, function():void{onImageLoaded(l);});
			l.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, updateLoader);
			l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void{trace("Background load error: " + e.text);});
			ApplicationController.SINGLETON.onLoading();
		}
		
		private function updateLoader(e:ProgressEvent):void
		{
			ApplicationController.SINGLETON.setLoader(e.bytesLoaded, e.bytesTotal);
		}
		
		private function onImageLoaded(loader:Loader):void
		{
			var bitmap:Bitmap = loader.content as Bitmap;
			var bd:BitmapData = bitmap.bitmapData;
			var avgColor:uint = ColorUtil.averageColour(bd);
			var model:Model = Model.getInstance();
			model.bgAvgColor = avgColor;
			backgroundImage.source = bitmap;
			ApplicationController.SINGLETON.onLoaded();
			
			//draw line after iamge has loaded so the line can take the color of the image
			if(GameController.SINGLETON.isPlaying){
				GameController.SINGLETON.setDrawingLine();
			}
		}
		
		private function resizeImage(e:ResizeEvent):void
		{
			var longerSide:String = Application.application.width > Application.application.height ? "w" : "h";
			var aspectRatio:Number = backgroundImage.measuredWidth / backgroundImage.measuredHeight;
			if(longerSide == "h"){
				backgroundImage.height = Application.application.height;
				backgroundImage.width = backgroundImage.height * aspectRatio;
			}
			else if(longerSide == "w"){
				backgroundImage.width = Application.application.width;
				backgroundImage.height = backgroundImage.width / aspectRatio;
			}
			backgroundImage.x = (Application.application.width - backgroundImage.width)/2;
			backgroundImage.y = (Application.application.height - backgroundImage.height)/2;
			//trace("Image resized to fit");
		}
		
	}
}