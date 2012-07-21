package error
{
	/**
	 * This error is raised when you try to unregisted an unregistered function
	 * key.
	 *
	 * @author Relena
	 */
	public class FunctionKeyNotRegisteredError extends Error
	{
		private var functionKey:String;
		
		/**
		 * Create and initialise a new instance.
		 *
		 * @param functionKey The unregistered function key.
		 */
		public function FunctionKeyNotRegisteredError(functionKey:String)
		{
			this.functionKey = functionKey;
		}
		
		/**
		 * Format and return a description string.
		 *
		 * @return A description string.
		 */
		public function toString():String
		{
			return "There is no function key \"" + functionKey + "\".";
		}
	}
}