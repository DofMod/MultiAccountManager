package
{
	import d2api.SystemApi;
	import error.AccountIndexOutOfRangeError;
	import error.FunctionKeyAlreadyRegisteredError;
	import error.FunctionKeyNotRegisteredError;
	import error.MaxAccountReachedError;
	import flash.display.Sprite;
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;
	import flash.utils.Dictionary;
	
	/**
	 * The main class of the module. Its manage the differents connections.
	 *
	 * @author	Relena
	 */
	public class MultiAccountManager extends Sprite
	{
		//::///////////////////////////////////////////////////////////
		//::// Properties
		//::///////////////////////////////////////////////////////////
		
		// APIs
		/**
		 * @private
		 */
		public var sysApi:SystemApi; // Hooks, Actions
		
		private var lc:LocalConnection;
		
		private const maxAccounts:int = 8;
		private const lcPrefix:String = "lcDofus_";
		private var accountIndex:int;
		
		private var callbacks:Dictionary;
		
		//::///////////////////////////////////////////////////////////
		//::// Methods
		//::///////////////////////////////////////////////////////////
		
		/**
		 * Initialise the module.
		 */
		public function main():void
		{
			try
			{
				initLocalConnection();
			}
			catch (error:MaxAccountReachedError) // Too many accounts.
			{
				return;
			}
			
			callbacks = new Dictionary();
		}
		
		/**
		 * Call the remote function associate to <code>functionKey</code> with
		 * <code>...args</code> arguments on all the accounts (include itself).
		 *
		 * @param	functionKey	The function key of the remote function to call.
		 * @param	...args	The arguments who will be passed to the remote
		 * 			function.
		 *
		 * @see	#register()
		 */
		public function sendAll(functionKey:String, ... args):void
		{
			args.unshift("callee", functionKey);
			
			var ii:int;
			var argsCopy:Array;
			for (ii = 0; ii < maxAccounts; ii++)
			{
				argsCopy = args.concat();
				argsCopy.unshift(getLcName(ii));
				
				lc.send.apply(null, argsCopy);
			}
		}
		
		/**
		 * Call the remote function associate to <code>functionKey</code> with
		 * <code>...args</code> arguments on all the sibling accounts.
		 *
		 * @param	functionKey	The function key of the remote function to call.
		 * @param	...args	The arguments who will be passed to the remote
		 * 			function.
		 *
		 * @see	#register()
		 */
		public function sendOther(functionKey:String, ... args):void
		{
			args.unshift("callee", functionKey);
			
			var ii:int;
			var argsCopy:Array;
			for (ii = 0; ii < maxAccounts; ii++)
			{
				if (ii == accountIndex)
					continue;
				
				argsCopy = args.concat();
				argsCopy.unshift(getLcName(ii));
				
				lc.send.apply(null, argsCopy);
			}
		}
		
		/**
		 * Call the remote function associate to <code>functionKey</code> with
		 * <code>...args</code> arguments on the account with
		 * <code>accountIndex</code> index.
		 *
		 * @param	accountIndex	Index of the destination account.
		 * @param	functionKey	The function key of the remote function to call.
		 * @param	...args	The arguments who will be passed to the remote
		 * 			function.
		 *
		 * @throws	error.AccountIndexOutOfRangeError
		 *
		 * @see	#register()
		 * @see	error.AccountIndexOutOfRangeError
		 */
		public function send(
			accountIndex:int, functionKey:String, ... args):void
		{
			if (accountIndex < 0 || accountIndex >= maxAccounts)
				throw new AccountIndexOutOfRangeError(
					accountIndex, 0, maxAccounts);
			
			// TODO: Check Index availability.
			
			args.unshift(getLcName(accountIndex), "callee", functionKey);
			
			lc.send.apply(null, args);
		}
		
		/**
		 * This is the callee function called bye send, sendOther and sendAll.
		 *
		 * @param	functionKey	The function key of the remote function to call.
		 * @param	...args	The arguments who will be passed to the remote
		 * 			function.
		 *
		 * @throws	error.FunctionKeyNotRegisteredError
		 *
		 * @see	error.FunctionKeyNotRegisteredError
		 *
		 * @private
		 */
		public function callee(functionKey:String, ... args):void
		{
			if (!callbacks.hasOwnProperty(functionKey))
				throw new FunctionKeyNotRegisteredError(functionKey);
			
			callbacks[functionKey].apply(null, args);
		}
		
		/**
		 * Register a function key with a remote function to call.
		 *
		 * @param	functionKey	An arbitrary string to accociate with the remote
		 * 			call of the <code>functionPtr</code> function.
		 * @param	functionPtr The function who will be called on the remote
		 * 			account
		 *
		 * @throws	error.FunctionKeyAlreadyRegisteredError
		 *
		 * @see	#unregister()
		 * @see	error.FunctionKeyAlreadyRegisteredError
		 */
		public function register(functionKey:String, functionPtr:Function):void
		{
			if (callbacks.hasOwnProperty(functionKey))
				throw new FunctionKeyAlreadyRegisteredError(functionKey);
			
			callbacks[functionKey] = functionPtr;
		}
		
		/**
		 * Unregister a function key.
		 *
		 * @param	functionKey The function key to unregister.
		 *
		 * @throws	error.FunctionKeyNotRegisteredError
		 *
		 * @see	#register()
		 * @see	error.FunctionKeyNotRegisteredError
		 */
		public function unregister(functionKey:String):void
		{
			if (!callbacks.hasOwnProperty(functionKey))
				throw new FunctionKeyNotRegisteredError(functionKey);
			
			delete callbacks[functionKey];
		}
		
		/**
		 * Return the index of the account.
		 *
		 * @return	The index of the account.
		 */
		public function getIndex():int
		{
			return accountIndex;
		}
		
		/**
		 * Return the local connection name associate to the
		 * <code>accountIndex</code> index.
		 *
		 * @param	accountIndex	Index of the destination account.
		 *
		 * @return	The local connection name.
		 */
		private function getLcName(accountIndex:int):String
		{
			return lcPrefix + accountIndex;
		}
		
		/**
		 * Try to open a new local connection.
		 */
		private function initLocalConnection():void
		{
			lc = new LocalConnection();
			lc.client = this;
			lc.addEventListener(StatusEvent.STATUS, statusEventHandler);
			
			for (accountIndex = 0; accountIndex < maxAccounts; accountIndex++)
			{
				try
				{
					lc.connect(getLcName(accountIndex));
					
					break;
				}
				catch (error:ArgumentError) // Connection name already used.
				{
					continue;
				}
			}
			
			if (accountIndex == maxAccounts)
				throw new MaxAccountReachedError(maxAccounts);
		}
		
		//::///////////////////////////////////////////////////////////
		//::// Events
		//::///////////////////////////////////////////////////////////
		
		/**
		 * Handle status event.
		 *
		 * @param	status ...
		 */
		private function statusEventHandler(status:StatusEvent):void
		{
			return;
		}
		
		//::///////////////////////////////////////////////////////////
		//::// Debug
		//::///////////////////////////////////////////////////////////
		
		/**
		 * Log message.
		 *
		 * @param	str	The string to display.
		 */
		private function traceDofus(str:String):void
		{
			sysApi.log(2, str);
		}
	}
}