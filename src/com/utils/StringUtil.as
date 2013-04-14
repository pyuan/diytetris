package com.utils
{
	import com.Constants;
	import com.models.Model;
	
	import mx.formatters.NumberFormatter;
	
	public class StringUtil
	{
		
		public static function getObjectiveTxt(level:int):String
		{
			var model:Model = Model.getInstance();
			var objective:String = "";
			var num:int = level * Constants.OBJECTIVE_ROWS_PER_LEVEL - model.levelRowsCleared;
			var r:String = num > 1 ? "rows" : "row";
			if(level < Constants.LEVELS_MAX){
				objective = "Clear " + num + " more " + r + " or clear the panel to advance to the next level.";
			}
			else{
				objective = "Simple, clear the entire panel!";
			}
			return objective;
		}
		
		public static function formatNumber(number:int):String
		{
			var nf:NumberFormatter = new NumberFormatter();
			nf.useThousandsSeparator = true;
			var val:String = nf.format(number);
			return val;
		}

	}
}