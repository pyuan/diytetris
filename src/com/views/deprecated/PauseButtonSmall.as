package com.views.ui
{
	import com.Embeds;
	import com.controllers.GameController;
	
	import flash.events.MouseEvent;
	
	public class PauseButtonSmall extends SmallIconButton
	{
		public function PauseButtonSmall()
		{
			super();
			setIcon(true);
		}
		
		private function setIcon(isPlaying:Boolean):void
		{
			if(isPlaying){
				this.setStyle('icon', Embeds.ICON_SMALL_PAUSE);
			}
			else{
				this.setStyle('icon', Embeds.ICON_SMALL_RESUME);
			}
		}
		
		override protected function clickHandler(event:MouseEvent):void
		{
			if(GameController.SINGLETON.isPlaying){
				GameController.SINGLETON.pause();
			}
			else{
				GameController.SINGLETON.resume();
			}
			setIcon(GameController.SINGLETON.isPlaying);
		}
	}
}