package com.utils
{
	import com.Constants;
	
	import flash.geom.Point;
	
	public class ConvertUtil
	{
		
		public static function dropSpeedToTime(dropSpeed:int):int
		{
			var time:int = 50 + 50 * (Constants.MAX_DROP_SPEED - dropSpeed);
			return time;
		}
		
		public static function deg2rad(degree:Number):Number
		{
		     return degree * (Math.PI / 180);
		}
		
		public static function positionToName(point:Point):String
		{
			var name:String = point.x + "_" + point.y;
			return name;
		}
		
		public static function nameToPosition(name:String):Point
		{
			var split:Array = name.split("_");
			var point:Point = new Point(split[0], split[1]);
			return point;
		}

	}
}