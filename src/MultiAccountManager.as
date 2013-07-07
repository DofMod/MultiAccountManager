package
{
	import d2api.SystemApi;
	import enums.HooksEnum;
	import error.AccountIndexOutOfRangeError;
	import error.FunctionKeyAlreadyRegisteredError;
	import error.FunctionKeyNotRegisteredError;
	import error.MaxAccountReachedError;
	import flash.display.Sprite;
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;
	import flash.utils.Dictionary;
	import hooks.ModuleMultiAccountManagerLoaded;
	
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
		
		// Some constants
		private static const MAX_ACCOUNTS:int = 8;
		private static const LC_PREFIX:String = "lcDofus_";
		private static const CALLEE_FUNCTION:String = "callee";
		
		// APIs
		/**
		 * @private
		 */
		public var sysApi:SystemApi; // Hooks, Actions
		
		// Some globals
		private var _lc:LocalConnection;
		private var _callbacks:Dictionary;
		private var _accountIndex:int;
		
		//::///////////////////////////////////////////////////////////
		//::// Methods
		//::///////////////////////////////////////////////////////////
		
		/**
		 * Initialise the module.
		 */
		public function main():void
		{
			sysApi.createHook(HooksEnum.MODULE_MULTI_ACCOUNT_MANAGER_LOADED);
			
			try
			{
				initLocalConnection();
			}
			catch (error:MaxAccountReachedError) // Too many accounts.
			{
				return;
			}
			
			_callbacks = new Dictionary();
			
			sysApi.dispatchHook(ModuleMultiAccountManagerLoaded);
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
			args.unshift(CALLEE_FUNCTION, functionKey);
			
			var ii:int;
			var argsCopy:Array;
			for (ii = 0; ii < MAX_ACCOUNTS; ii++)
			{
				argsCopy = args.concat();
				argsCopy.unshift(getLcName(ii));
				
				_lc.send.apply(null, argsCopy);
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
			args.unshift(CALLEE_FUNCTION, functionKey);
			
			var ii:int;
			var argsCopy:Array;
			for (ii = 0; ii < MAX_ACCOUNTS; ii++)
			{
				if (ii == _accountIndex)
					continue;
				
				argsCopy = args.concat();
				argsCopy.unshift(getLcName(ii));
				
				_lc.send.apply(null, argsCopy);
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
			if (accountIndex < 0 || accountIndex >= MAX_ACCOUNTS)
				throw new AccountIndexOutOfRangeError(
					accountIndex, 0, MAX_ACCOUNTS);
			
			// TODO: Check Index availability.
			
			args.unshift(getLcName(accountIndex), CALLEE_FUNCTION, functionKey);
			
			_lc.send.apply(null, args);
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
			if (!_callbacks.hasOwnProperty(functionKey))
				throw new FunctionKeyNotRegisteredError(functionKey);
			
			_callbacks[functionKey].apply(null, args);
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
			if (_callbacks.hasOwnProperty(functionKey))
				throw new FunctionKeyAlreadyRegisteredError(functionKey);
			
			_callbacks[functionKey] = functionPtr;
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
			if (!_callbacks.hasOwnProperty(functionKey))
				throw new FunctionKeyNotRegisteredError(functionKey);
			
			delete _callbacks[functionKey];
		}
		
		/**
		 * Return the index of the account.
		 *
		 * @return	The index of the account.
		 */
		public function getIndex():int
		{
			return _accountIndex;
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
			return LC_PREFIX + accountIndex;
		}
		
		/**
		 * Try to open a new local connection.
		 */
		private function initLocalConnection():void
		{
			_lc = new LocalConnection();
			_lc.client = this;
			_lc.addEventListener(StatusEvent.STATUS, statusEventHandler);
			
			for (_accountIndex = 0; _accountIndex < MAX_ACCOUNTS; _accountIndex++)
			{
				try
				{
					_lc.connect(getLcName(_accountIndex));
					
					break;
				}
				catch (error:ArgumentError) // Connection name already used.
				{
					continue;
				}
			}
			
			if (_accountIndex == MAX_ACCOUNTS)
			{
				throw new MaxAccountReachedError(MAX_ACCOUNTS);
			}
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
	}
}