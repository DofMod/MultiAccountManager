package error
{
	/**
	 * This error is raised when you try to loggin more than
	 * <code>maxAccounts</code> accounts.
	 *
	 * @author Relena
	 */
	public class MaxAccountReachedError extends Error
	{
		private var maxAccounts:int;
		
		/**
		 * Create and initialise a new instance.
		 *
		 * @param maxAccounts The function key who is already registered.
		 */
		public function MaxAccountReachedError(maxAccounts:int)
		{
			this.maxAccounts = maxAccounts;
		}
		
		/**
		 * Format and return a description string.
		 *
		 * @return A description string.
		 */
		public function toString():String
		{
			return "This module don't suport more than " + maxAccounts
					+ " account(s).";
		}
	}
}