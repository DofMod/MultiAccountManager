package error
{
	/**
	 * This error is raised when you try to register an already registered
	 * function key.
	 *
	 * @author Relena
	 */
	public class FunctionKeyAlreadyRegisteredError extends Error
	{
		private var functionKey:String;
		
		/**
		 * Create and initialise a new instance.
		 *
		 * @param functionKey The already registered function key.
		 */
		public function FunctionKeyAlreadyRegisteredError(functionKey:String)
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
			return "The function key \"" + functionKey
					+ "\" is allready taken.";
		}
	}
}