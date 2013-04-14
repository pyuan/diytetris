package com
{
	public class Constants
	{
		
		/**** App Constants ****/
		public static const DEBUG_MODE : Boolean = false;
		public static const VERSION_NUM : String = "Beta! V.0.1";
		public static const DIR_SOUND_SFX : String = "assets/audio/sfx/";
		public static const DIR_SOUND_BACKGROUNDS : String = "assets/audio/backgrounds/";
		public static const DIR_IMAGES_BACKGROUNDS : String = "assets/images/backgrounds/";
		public static const DIR_IMAGES_SCREENS : String = "assets/images/screens/";
		public static const DIR_FLAGS : String = "assets/images/flags/";
		public static const FILE_XML_COLORS : String = "data/colors.xml";
		public static const DEFAULT_COUNTRY : String = "CA";
		public static const DEFAULT_LEVELCREATOR_BLOCKS_NUM : int = 50;
		public static const IDLE_TIME : int = 50; //10=1sec
		
		/**** Footer Constants ****/
		public static const STATUS_LINK : String = "http://www.diytetris.com";
		public static const STATUS_MSG : String = "Hey check out this cool game at www.diytetris.com!";
		public static const FOOTER_TWITTER : int = 0;
		public static const FOOTER_FACEBOOK : int = 1;
		public static const FOOTER_MYSPACE : int = 2;
		public static const FOOTER_LINKEDIN : int = 3;
		public static const FOOTER_DELICIOUS : int = 4;
		public static const FOOTER_DIGG : int = 5;
		
		/*** Services Constants ****/
		private static const SERVICE_GETDIR : String = "services/getDirectory.php?dir=";
		public static const SERVICE_GETDIR_IMAGES_BACKGROUNDS : String = SERVICE_GETDIR + "/images/backgrounds";
		public static const SERVICE_GETDIR_IMAGES_FLAGS : String = SERVICE_GETDIR + "/images/flags";
		public static const SERVICE_GETDIR_SOUND_BACKGROUNDS : String = SERVICE_GETDIR + "/audio/backgrounds";
		public static const SERVICE_GETDIR_LEVELS : String = SERVICE_GETDIR + "/levels";
		public static const SERVICE_LEVEL_PERSIST : String = "services/levelPersist.php";
		public static const SERVICE_LEADERBOARD : String = "services/leaderboard.php";
		
		/**** Size Constants ****/
		public static const BLOCK_WIDTH : int = 35;
		public static const BLOCK_HEIGHT : int = 35;
		public static const VIEW_PANE_WIDTH : int = BLOCK_WIDTH * 15; 
		public static const VIEW_PANE_HEIGHT : int = BLOCK_HEIGHT * 18;
		
		/**** Game Constants ****/
		public static const MAX_BLOCKS_NUM : int = 5;
		public static const MAX_DROP_SPEED : int = 10;
		public static const BLOCK_TWEENER_TIME : Number = 0.25;
		public static const BLOCK_DROP_AMOUNT : int = BLOCK_HEIGHT * 1;
		public static const BASE_FINISH_TIME : int = 3 * 60 * 10;
		
		public static const POINTS_PLUS_CLEAR_ROW : int = 100;
		public static const POINTS_PLUS_CLEAR_ROW_MULTIPLE_BONUS : int = 50;
		public static const POINTS_PLUS_TIME : int = 1;
		public static const POINTS_MINUS_PAUSE : int = 50;
		public static const POINTS_MINUS_SKIP : int = 100;
		
		public static const OBJECTIVE_ROWS_PER_LEVEL : int = 5;
		public static const LEVELS_MAX : int = 10;
		
		/**** Visual Style Constants ****/
		public static const VIEW_PANE_COLOR_TOP : uint = 0x181818;
		public static const VIEW_PANE_COLOR_BOTTOM : uint = 0xCCCCCC;
		public static const BLOCK_STROKE_COLOR : uint = 0xFFFFFF;
		public static const BLOCK_STROKE_COLOR_ACTIVE : uint = 0xfff000;
		public static const SENSOR_PANE_COLOR : uint = 0xFFFFFF;
		public static const SENSOR_PANE_COLOR_BLINK : uint = 0xfff000;
		public static const SENSOR_PANE_COLOR_DRAWN : uint = 0x000000;
		public static const SENSOR_PANE_STROKE_COLOR : uint = 0xFFFFFF;
		public static const SENSOR_PANE_FILL_ALPHA : Number = 0.75;
		public static const SENSOR_PANE_STROKE_ALPHA : Number = 0.25;
		public static const SENSOR_PANE_ALPHA_UP : Number = 0.5;
		public static const SENSOR_PANE_ALPHA_OVER : Number = 1;
		public static const DRAWLINE_THICKNESS:int = 5;
		public static const DRAWLINE_DASHES_LENGTH : int = 5;
		public static const DRAWLINE_DASHES_GAP : int = 2;
		
		/**** View Constants ****/
		public static const VIEW_PLAY : String = "play";
		public static const VIEW_MAIN : String = "main";
		public static const VIEW_CREDITS : String = "credits";
		public static const VIEW_TUTORIAL : String = "tutorial";
		public static const VIEW_GAMEOVER : String = "gameover";
		public static const VIEW_LEADERBOARD : String = "leaderboard";
		public static const VIEW_LEVELCREATOR : String = "levelCreator";
		
		public static const POPUP_ID_PAUSE : String = "pause";
		public static const POPUP_ID_QUIT : String = "confirmQuit";
		public static const POPUP_ID_LEVELCREATOR : String = "levelCreator";
		
		/**** Sounds ****/
		public static const AUDIO_BACKGROUND_INTRO : String = DIR_SOUND_SFX + "opening.mp3";
		public static const AUDIO_BUTTON_OVER : String = DIR_SOUND_SFX + "block3.mp3";
		public static const AUDIO_BUTTON_DOWN : String = DIR_SOUND_SFX + "pop3.mp3";
		public static const AUDIO_BLOCK_CREATED : String = DIR_SOUND_SFX + "clearing7.mp3";
		public static const AUDIO_BLOCK_COLLIDE : String = DIR_SOUND_SFX + "block1.mp3";
		public static const AUDIO_BLOCK_ERROR : String = DIR_SOUND_SFX + "buzzer.mp3";
		public static const AUDIO_CLEAR_ROW : String = DIR_SOUND_SFX + "clearing3.mp3";
		public static const AUDIO_GAME_OVER: String = DIR_SOUND_SFX + "fail.mp3";
		public static const AUDIO_MACHINE : String = DIR_SOUND_SFX + "147725_SOUNDDOGS__mo.mp3";
		public static const AUDIO_AWESOME : String = DIR_SOUND_SFX + "awesome_high.mp3";
		public static const AUDIO_DOSOMETHING : String = DIR_SOUND_SFX + "dosomething_high.mp3";
		public static const AUDIO_BACKGROUND_ID_INTRO : int = 0;
		
		/**** Images ****/
		public static const IMAGE_BACKROUND_GAMEOVER : String = DIR_IMAGES_SCREENS + "screen_lose.jpg";
		public static const IMAGE_BACKGROUND_ID_GAMEOVER : int = 0;
		public static const IMAGE_LOGO_SMALL : String = "assets/images/logo_small.png";
		public static const EXTENSION_FLAGS : String = ".png";
		public static const IMAGE_FLAG_WIDTH : int = 40;
		public static const IMAGE_FLAG_HEIGHT : int = 24;
		
	}
}