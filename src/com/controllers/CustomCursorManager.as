package com.controllers
{
	import mx.managers.CursorManager;
	import com.Embeds;
	
	public class CustomCursorManager
	{
		public static const SINGLETON : CustomCursorManager = new CustomCursorManager();
		
		public function CustomCursorManager()
		{
			if(CustomCursorManager != null)
				throw new Error("This class is a singleton and already has a running instance.  Reference using CustomCursorManager.SINGLETON.");
		}
		
		public function setBrushCursor():void
		{
			CursorManager.removeAllCursors();
			CursorManager.setCursor(Embeds.ICON_BRUSH);
		}
		
		public function setBrushNoCursor():void
		{
			CursorManager.removeAllCursors();
			CursorManager.setCursor(Embeds.ICON_BRUSH_NO);
		}
		
		public function setDefautlCursor():void
		{
			CursorManager.removeAllCursors();
		}
		
		public function setRotateCursor():void
		{
			CursorManager.removeAllCursors();
			CursorManager.setCursor(Embeds.ICON_ROTATE, 2, -25, -25);
		}
		
		public function setMoveCursor():void
		{
			CursorManager.removeAllCursors();
			CursorManager.setCursor(Embeds.ICON_MOVE, 2, -25, -15);
		}

	}
}