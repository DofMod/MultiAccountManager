package error 
{
	/**
	 * ...
	 * @author Relena
	 */
	public class MaxAccountError extends Error 
	{
		private var maxAccounts:int;
		
		public function MaxAccountError(maxAccounts:int)
		{
			this.maxAccounts = maxAccounts;
		}
		
		public function toString() : String
		{
			return "This module don't suport more than " + maxAccounts + " account(s).";
		}
		
	}

}