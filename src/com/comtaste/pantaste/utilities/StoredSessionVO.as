
package com.comtaste.pantaste.utilities
{
	import flash.utils.Dictionary;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	[RemoteClass( alias="com.comtaste.pantaste.utilities.StoredSessionVO" )]
	/**
	 * Mantains the application session data.
	 * <p>
	 * This VO store an application session data
	 * it store the following data associated to an users:
	 * 		- active pantaste
	 * 		- panels last state (minimizate,normal,maximized)
	 * 		- singlecontrols state, only for maximized panel
	 * 		- data time interval
	 * 		- global compliance/uncompliance active value  
	 * </p>
	 */
	public class StoredSessionVO implements IExternalizable
	{
		/**
		 * Array of DashPanelAspects to read the stored DashPanel's saved properties of the resuming session. 
		 */ 
		public var storedAspects:Array = [];
		
		/**
		 * Array of configuration objects each relative to a DashContainer
		 */ 
		public var containerConfiguration:Array = [];

		/**
		 * Reads in an object from the IDataInput implementor
		 * @param input:IDataInput Implementor of the IDataInput interface to read data from.
		 */		
		public function readExternal( input:IDataInput ):void
		{
			storedAspects = input.readObject();
			containerConfiguration = input.readObject();
		}
		
		/**
		 * Writes out the object to the IDataOutput implementor
		 * @param output:IDataOutput Implementor of the IDataOutput interface  to write data in
		 */
		public function writeExternal( output:IDataOutput ):void
		{
			output.writeObject( storedAspects );
			output.writeObject( containerConfiguration );
		}
		
	}
}