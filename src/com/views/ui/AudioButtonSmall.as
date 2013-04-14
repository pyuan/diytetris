package com.views.ui
{
	import com.Embeds;
	import com.controllers.AudioController;
	
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	
	public class AudioButtonSmall extends SmallIconButton
	{
		public function AudioButtonSmall()
		{
			super();
			BindingUtils.bindSetter(setIcon, AudioController.SINGLETON, "isMute");
		}
		
		private function setIcon(isMute:Boolean):void
		{
			if(isMute){
				this.setStyle('icon', Embeds.ICON_SMALL_MUSIC_OFF);
			}
			else{
				this.setStyle('icon', Embeds.ICON_SMALL_MUSIC_ON);
			}
		}
		
		override protected function clickHandler(event:MouseEvent):void
		{
			AudioController.SINGLETON.toggleMute(2);
		}
	}
}