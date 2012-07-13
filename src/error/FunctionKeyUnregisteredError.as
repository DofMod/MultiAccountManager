package error 
{
	/**
	 * ...
	 * @author Relena
	 */
	public class FunctionKeyUnregisteredError extends Error 
	{
		private var functionKey:String;
		
		public function FunctionKeyUnregisteredError(functionKey:String) 
		{
			this.functionKey = functionKey;
		}

		public function toString() : String
		{
			return "There is no function key \"" + functionKey + "\".";
		}
	}
}