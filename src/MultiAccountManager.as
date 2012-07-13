package {
	import d2actions.ChatTextOutput;
	import d2actions.PartyInvitation;
	import d2api.PlayedCharacterApi;
	import d2api.SystemApi;
	import d2enums.ChatChannelsMultiEnum;
	import d2hooks.ChatError;
	import d2hooks.ChatSendPreInit;
	import error.AccountIndexOutOfRangeError;
	import error.FunctionKeyAllreadyRegisterError;
	import error.FunctionKeyUnregisteredError;
	import error.MaxAccountError;
	import flash.display.Sprite;
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;
	import flash.utils.Dictionary;

	public class MultiAccountManager extends Sprite
	{
		//::///////////////////////////////////////////////////////////
		//::// Properties
		//::///////////////////////////////////////////////////////////
		
		// APIs
		public var sysApi:SystemApi; // Hooks, Actions
		
		public var lc:LocalConnection;
		
		private const maxAccounts:int = 8;
		private const lcPrefix:String = "lcDofus_";
		private var accountIndex:int;
		
		public var callbacks:Dictionary;

		//::///////////////////////////////////////////////////////////
		//::// Public methods
		//::///////////////////////////////////////////////////////////

		public function main() : void
		{
			try
			{
				initLocalConnection();
			}
			catch (error:MaxAccountError) // Too many accounts.
			{
				return;
			}
			
			callbacks = new Dictionary();
		}
		
		// Send functions
		public function sendAll(...args) : void
		{
			traceDofus("sendAll");
			args.unshift("call");
			
			var ii:int;
			var argsCopy:Array;
			for (ii = 0; ii < maxAccounts; ii++)
			{
				argsCopy = args.concat();
				argsCopy.unshift(getLcName(ii));
				
				lc.send.apply(null, argsCopy);
			}
		}
		
		public function sendOther(...args) : void
		{
			traceDofus("sendOther");
			args.unshift("call");
			
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
		
		public function send(accountIndex:int, ...args) : void
		{
			traceDofus("send(" + accountIndex + ")");
			
			if (accountIndex < 0 || accountIndex >= maxAccounts)
				throw new AccountIndexOutOfRangeError(accountIndex, 0, maxAccounts);
			
			args.unshift(getLcName(accountIndex), "call");
			lc.send.apply(null, args);
		}
		
		// Register functions
		public function register(functionKey:String, functionPtr:Function) : void
		{
			if (callbacks.hasOwnProperty(functionKey))
				throw new FunctionKeyAllreadyRegisterError(functionKey);
			
			callbacks[functionKey] = functionPtr;
		}
		
		public function unregister(functionKey:String) : void
		{
			if (!callbacks.hasOwnProperty(functionKey))
				throw new FunctionKeyUnregisteredError(functionKey);
			
			delete callbacks[functionKey];
		}
		
		// Call functions
		public function call(functionKey:String, ...args) : void
		{
			if (!callbacks.hasOwnProperty(functionKey))
				throw new Error(functionKey);
			
			callbacks[functionKey].apply(null, args);
		}
		
		// Utils
		public function getIndex() : int
		{
			return accountIndex;
		}
		
		//::///////////////////////////////////////////////////////////
		//::// Private methods
		//::///////////////////////////////////////////////////////////

		private function getLcName(accountIndex:int) : String
		{
			return lcPrefix + accountIndex;
		}
		
		private function initLocalConnection() : void
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
			
			if (accountIndex == maxAccounts) throw new MaxAccountError(maxAccounts);
		}
			
		//::///////////////////////////////////////////////////////////
		//::// Events
		//::///////////////////////////////////////////////////////////
		
		private function statusEventHandler(status:StatusEvent) : void
		{
			return;
		}
		
		//::///////////////////////////////////////////////////////////
		//::// Debug
		//::///////////////////////////////////////////////////////////
		
		private function traceDofus(str:String) : void
		{
			sysApi.log(2, str);
		}
		
		public function logdebug() : void
		{
			traceDofus("debug!!!!!!!!!!!!!!!!!");
		}
	}
}
