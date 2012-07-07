package error 
{
	/**
	 * ...
	 * @author Relena
	 */
	public class CallbackKeyAllreadyTakenError extends Error 
	{
		private var callbackKey:String;
		
		public function CallbackKeyAllreadyTakenError(callbackKey:String) 
		{
			this.callbackKey = callbackKey;
		}
		
		public function toString() : String
		{
			return "The callback key " + callbackKey + " is allready taken.";
		}
		
	}

}