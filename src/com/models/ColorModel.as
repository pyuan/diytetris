package com.models
{
	[Bindable]
	public class ColorModel
	{
		
		private var name:String = "";
		
		private var value:uint = 0;
		
		public function ColorModel(name:String, value:uint)
		{
			this.name = name;
			this.value = value;
		}
		
		public function getName():String{
			return this.name;
		}
		
		public function getValue():uint{
			return this.value;
		}

	}
}