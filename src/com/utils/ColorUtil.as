package com.utils
{
	import com.models.ColorModel;
	import com.models.Model;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class ColorUtil
	{
		
		//returns the average color of the bitmap image
		//source: http://blog.soulwire.co.uk/flash/actionscript-3/extract-average-colours-from-bitmapdata
		public static function averageColour(source:BitmapData):uint
		{
			var red:Number = 0;
			var green:Number = 0;
			var blue:Number = 0;
		
			var count:Number = 0;
			var pixel:Number;
		
			for (var x:int = 0; x < source.width; x++)
			{
				for (var y:int = 0; y < source.height; y++)
				{
					pixel = source.getPixel(x, y);
		
					red += pixel >> 16 & 0xFF;
					green += pixel >> 8 & 0xFF;
					blue += pixel & 0xFF;
		
					count++
				}
			}
		
			red /= count;
			green /= count;
			blue /= count;
		
			return red << 16 | green << 8 | blue;
		}
		
		public static function averageColours(source:BitmapData, colours:int):Array
		{
			var averages:Array = new Array();
			var columns:int = Math.round( Math.sqrt( colours ) );
		
			var row:int = 0;
			var col:int = 0;
		
			var x:int = 0;
			var y:int = 0;
		
			var w:int = Math.round( source.width / columns );
			var h:int = Math.round( source.height / columns );
		
			for (var i:int = 0; i < colours; i++)
			{
				var rect:Rectangle = new Rectangle( x, y, w, h );
		
				var box:BitmapData = new BitmapData( w, h, false );
				box.copyPixels(source, rect, new Point());
		
				averages.push( averageColour( box ) );
				box.dispose();
		
				col = i % columns;
		
				x = w * col;
				y = h * row;
		
				if ( col == columns - 1 ) row++;
			}
		
			return averages;
		}
		
		public static function getComplementaryColor(color:uint):uint
		{
			return 0xFFFFFF - color;
		}
		
		//returns the text color given its background color, returns either black or white
		public static function getTextOverColor(backgroundColor:uint):uint
		{
			var A:Number = backgroundColor >> 24 & 0xFF;
			var R:Number = backgroundColor >> 16 & 0xFF;
			var G:Number = backgroundColor >> 8 & 0xFF;
			var B:Number = backgroundColor & 0xFF;

			var avg:Number = (R + G + B)/3;
			var textColor:uint = avg>100 ? 0x000000 : 0xFFFFFF;
			return textColor;
		}
		
		public static function getBlockColor(colorIndex:int):uint
		{
			var color:uint = 0;
			var model:Model = Model.getInstance();
			if(colorIndex >= model.colors.length){
				colorIndex = colorIndex % (model.colors.length-1);
			}
			var colorModel:ColorModel = model.colors[colorIndex];
			color = colorModel.getValue();
			return color;
		}
		
		public static function getColorIndex(color:uint):int
		{
			var colorIndex:int = -1;
			var model:Model = Model.getInstance();
			for(var i:int=0; i<model.colors.length; i++){
				var cm:ColorModel = model.colors[i];
				if(color == cm.getValue()){
					colorIndex = i;
					break;
				}
			}
			return colorIndex;
		}
		
		public static function getNewColor():uint
		{
			var model:Model = Model.getInstance();
			var color:uint = model.currentColor;
			while(color == model.currentColor)
			{
				var random:int = Math.round(Math.random() * (model.colors.length-1));
				var colorModel:ColorModel = model.colors[random];
				color = colorModel.getValue();
			}
			model.currentColor = color;
			return color;
		}

	}
}