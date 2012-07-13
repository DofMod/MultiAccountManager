package error 
{
	/**
	 * ...
	 * @author Relena
	 */
	public class FunctionKeyAllreadyRegisterError extends Error 
	{
		private var functionKey:String;
		
		public function FunctionKeyAllreadyRegisterError(functionKey:String) 
		{
			this.functionKey = functionKey;
		}
		
		public function toString() : String
		{
			return "The function key \"" + functionKey + "\" is allready taken.";
		}
		
	}

}