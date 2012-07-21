package error
{
	/**
	 * This error is raised when the passed module's index is negative or
	 * superior to the maximum number of accounts.
	 *
	 * @author Relena
	 */
	public class AccountIndexOutOfRangeError extends Error
	{
		private var accountIndex:int;
		private var minIndex:int;
		private var maxIndex:int;
		
		/**
		 * Create and initialise a new instance.
		 *
		 * @param accountIndex Index of the account.
		 * @param minIndex Minimum index accepted.
		 * @param maxIndex Maximum index accepted.
		 */
		public function AccountIndexOutOfRangeError(
			accountIndex:int, minIndex:int, maxIndex:int)
		{
			this.accountIndex = accountIndex;
			this.minIndex = minIndex;
			this.maxIndex = maxIndex;
		}
		
		/**
		 * Format and return a description string.
		 *
		 * @return A description string.
		 */
		public function toString():String
		{
			return "Account index " + accountIndex + " is out of range ["
					+ minIndex + " ... " + maxIndex + "].";
		}
	}
}