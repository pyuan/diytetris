package com.models
{
	[Bindable]
	public class LeaderModel
	{
		public var name:String = "";
		public var score:int = -1;
		public var level:int = -1;
		public var country:String = "";
		
		public function LeaderModel(name:String, score:int, level:int, country:String)
		{
			this.name = name;
			this.score = score;
			this.level = level;
			this.country = country;
		}

	}
}