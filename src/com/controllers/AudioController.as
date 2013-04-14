package com.controllers
{
	import com.Constants;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	
	public class AudioController
	{
		public static const SINGLETON : AudioController = new AudioController();
		
		//stores the current background music
		private var currentBgIndex:int = -1;
		
		//stores the available background music file names
		private var backgroundMusicCollection:ArrayCollection = new ArrayCollection();
		
		private var backgroundSound:Sound = new Sound();
		private var backgroundSoundChannel:SoundChannel = new SoundChannel();
		
		private var sfxSound:Sound = new Sound();
		private var sfxSoundChannel:SoundChannel = new SoundChannel();
		
		//for both sfx and background
		private var volume:Number = 1;
		
		[Bindable]
		public var isMute:Boolean = false;
				
		public function AudioController()
		{
			if(AudioController != null)
				throw new Error("This class is a singleton and already has a running instance.  Reference using AudioController.SINGLETON.");
		}
		
		public function init():void
		{
			getBackgroundSounds();
		}
		
		//sends urlrequest to get the background sounds xml
		private function getBackgroundSounds():void
		{
			var nocache:String = "&date=" + new Date().getTime();
			var url:URLLoader = new URLLoader(new URLRequest(Constants.SERVICE_GETDIR_SOUND_BACKGROUNDS + nocache));
			url.addEventListener(Event.COMPLETE, setBackgroundSounds);
			url.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void{trace("Error: " + e.text);}); 
		}
		
		private function setBackgroundSounds(e:Event):void
		{
			backgroundMusicCollection.removeAll();
			
			var xml:XML = new XML(e.currentTarget.data);
			for(var i:int=0; i<xml.link.length(); i++){
				backgroundMusicCollection.addItem(xml.link[i]);
			}
			
			//add non-random audio
			backgroundMusicCollection.addItemAt(Constants.AUDIO_BACKGROUND_INTRO, Constants.AUDIO_BACKGROUND_ID_INTRO);
			
			trace("Background music list loaded");
			playSpecificBackgroundMusic(Constants.AUDIO_BACKGROUND_ID_INTRO);
		}
		
		public function playSpecificBackgroundMusic(musicId:int):void
		{
			if(currentBgIndex != musicId){
				currentBgIndex = musicId;
				playBgMusic();
			}
		}
		
		public function playNewBackgroundMusic():void
		{
			var newBgIndex:int = currentBgIndex;
			while(newBgIndex < 0 || newBgIndex == currentBgIndex || newBgIndex == 0)
			{
				newBgIndex = Math.random() * (backgroundMusicCollection.length-1);
			}
			currentBgIndex = newBgIndex;
			playBgMusic();
		}
		
		public function stopBackgroundMusic():void
		{
			backgroundSoundChannel.stop();
		}
		
		private function playBgMusic():void
		{
			if(backgroundSoundChannel.position != 0){
				backgroundSoundChannel.stop();
			}
			backgroundSound = new Sound(new URLRequest(backgroundMusicCollection[currentBgIndex]));
			backgroundSound.addEventListener(Event.COMPLETE, onBgSoundLoaded);
			backgroundSoundChannel = backgroundSound.play(0, 9999);
			var transform:SoundTransform = backgroundSoundChannel.soundTransform;
            transform.volume = volume;
            backgroundSoundChannel.soundTransform = transform;
			backgroundSoundChannel.addEventListener(Event.SOUND_COMPLETE, onBgSoundComplete);
		}
		
		public function playSfx(soundFile:String):void
		{
			if(sfxSoundChannel.position != 0){
				sfxSoundChannel.stop();
			}
			sfxSound = new Sound(new URLRequest(soundFile));
			sfxSound.addEventListener(Event.COMPLETE, onBgSoundLoaded);
			sfxSoundChannel = sfxSound.play();
			var transform:SoundTransform = sfxSoundChannel.soundTransform;
            transform.volume = volume;
            sfxSoundChannel.soundTransform = transform;
			sfxSoundChannel.addEventListener(Event.SOUND_COMPLETE, onBgSoundComplete);
		}
		
		private function onBgSoundLoaded(e:Event):void
		{
			trace("Sound loaded: " + Sound(e.currentTarget).url);
		}
		
		private function onBgSoundComplete(e:Event):void
		{
			//trace("No more loops, sound done.");
		}
		
		//0=mute, 1=unmute, 2=toggle
		public function toggleMute(level:int):void
		{
			if(level == 2){
				if(volume > 0){
					volume = 0;
				}
				else if(volume < 1){
					volume = 1;
				}
			}
			else{
				volume = level;
			}
			
			if(volume == 0){
				isMute = true;
			}
			else{
				isMute = false;
			}
			
			var transform:SoundTransform = backgroundSoundChannel.soundTransform;
            transform.volume = volume;
            backgroundSoundChannel.soundTransform = transform;
            
            transform = sfxSoundChannel.soundTransform;
            transform.volume = volume;
            sfxSoundChannel.soundTransform = transform;
			trace("Changing volume: " + volume);
		}
	}
}