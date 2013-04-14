package com.views.ui
{
	import com.Constants;
	import com.Embeds;
	import com.controllers.AudioController;
	
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	
	import mx.controls.Button;
	import mx.effects.SoundEffect;

	public class IntroButton extends Button
	{
		public function IntroButton()
		{
			super();
			this.styleName = "introButton";
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			var shadow:DropShadowFilter = new DropShadowFilter();
			shadow.color = 0x000000;
			shadow.alpha = 0.5;
			shadow.angle = 60;
			shadow.blurX = shadow.blurY = 3;
			textField.filters = [shadow];
			 
			shadow.alpha = 0.25;
			shadow.blurX = shadow.blurY = 5;
			this.filters = [shadow];
		     
		    if(this.enabled){
				this.buttonMode = true;
			}
			else{
				this.buttonMode = false;
			}
		}
		
		override protected function rollOverHandler(event:MouseEvent):void
		{
			super.rollOverHandler(event);
			if(this.enabled){
				AudioController.SINGLETON.playSfx(Constants.AUDIO_BUTTON_OVER);
			}
		}
		
		override protected function clickHandler(event:MouseEvent):void
		{
			super.clickHandler(event);
			if(this.enabled){
				AudioController.SINGLETON.playSfx(Constants.AUDIO_BUTTON_DOWN);
			}
		}
		
	}
}