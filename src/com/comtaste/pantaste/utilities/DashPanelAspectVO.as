package com.comtaste.pantaste.utilities
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	[RemoteClass( alias="com.comtaste.pantaste.utilities.DashPanelAspectVO" )]
	/**
	 * Mantains the aspect status of a DashPanel.
	 * <p>
	 * 	In order to save the aspect of a DashPanel, the relevant information about its status must
	 * 	be saved and serialized.
	 * </p>
	 */ 
	public class DashPanelAspectVO implements IExternalizable
	{
		//public var id:String = "";
		/**
		 * Name 
		 */ 
		public var name:String;
		/**
		 * Identifier of the related DashPanel object
		 */ 
		public var uid:String;
		
		/**
		 * State of the related DashPanel object
		 */ 
		public var status:String;
		
		/**
		 * Level of the related DashPanel in his DashPanelContainer
		 */
		public var dashOrder:Number = -1;
		
		/**
		 * <code>true</code> if the related DashPanel is set as alwaysInFront; false otherwise
		 */ 
		public var alwaysInFront:Boolean;
		
		/**
		 * The height of the DashPanel before maximization/minimization
		 */ 
		public var restoredHeight:Number;
		
		/**
		 * The width of the DashPanel before maximization/minimization
		 */ 
		public var restoredWidth:Number;
		
		/**
		 * The x coordinate of the DashPanel before maximization/minimization
		 */ 
		public var restoredX:Number;
				
		/**
		 * The y coordinate of the DashPanel before maximization/minimization
		 */
		public var restoredY:Number;
				
		/**
		 * Indicates whether the DashPanel is visible or not.
		 */
		public var visible:Boolean;
				
		/**
		 * Reads in an object from the IDataInput implementor
		 * @param input:IDataInput Implementor of the IDataInput interface to read data from.
		 */
		public function readExternal( input:IDataInput ):void
		{

			//id = input.readUTF();
			name = input.readUTF();
			uid = input.readUTF();
		
			status = input.readUTF();
			dashOrder = input.readDouble();
			alwaysInFront = input.readBoolean();
		
			restoredHeight = input.readDouble();
			restoredWidth = input.readDouble();
			restoredX = input.readDouble();
			restoredY = input.readDouble();
		
			visible = input.readBoolean();
		}
				
		/**
		 * Writes out the object to the IDataOutput implementor
		 * @param output:IDataOutput Implementor of the IDataOutput interface  to write data in
		 */
		public function writeExternal( output:IDataOutput ):void
		{

			//output.writeUTF(id);
			output.writeUTF(name);
			output.writeUTF(uid);
			output.writeUTF(status);
			output.writeDouble(dashOrder);
			output.writeBoolean(alwaysInFront);
			
			output.writeDouble(restoredHeight);
			output.writeDouble(restoredWidth);
			output.writeDouble(restoredX);
			output.writeDouble(restoredY);
			
			output.writeBoolean(visible);

		}
	}
}