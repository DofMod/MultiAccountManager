package error 
{
	/**
	 * ...
	 * @author Relena
	 */
	public class AccountIndexOutOfRangeError extends Error 
	{
		private var accountIndex:int;
		private var minIndex:int;
		private var maxIndex:int;
		
		public function AccountIndexOutOfRangeError(accountIndex:int, minIndex:int, maxIndex:int)
		{
			this.accountIndex = accountIndex;
			this.minIndex = minIndex;
			this.maxIndex = maxIndex;
		}
		
		public function toString() : String
		{
			return "Account index " + accountIndex + " is out of range [" + minIndex + " ... " + maxIndex + "].";
		}
		
	}

}