package com.comtaste.pantaste.events
{
	import com.comtaste.pantaste.components.DashPanel;
	import com.comtaste.pantaste.components.DashPanelContainer;
	
	import flash.events.Event;

	/**
	 * Event type dispatched by DashPanelContainer when some change occours
	 */
	public class DashPanelContainerEvent extends Event
	{
		/**
		 * Defines the value of the type property of a pantaste change event. 
		 */ 
		public static const pantaste_CHANGED:String = "pantasteChanged";
		
		/**
		 * The container related with this event.
		 */ 
		public var pantaste:DashPanelContainer;
		
		/**
		 * The panel related with this event.
		 */ 
		public var panel:DashPanel;
		
		/**
		 * the kind of change occurred in this event.
		 */ 
		public var changeType:String;
		/**
		 * Constructor.
		 * @param type:String the event's type
		 * @param pantaste:DashPanelContainer the event's target
		 * @param changeType:String the type of change occurred
		 * @param bubbles:Boolean whether enable bubbling of this event
		 */
		public function DashPanelContainerEvent( type:String, pantaste:DashPanelContainer, changeType:String, panel:DashPanel, bubbles:Boolean = false )
		{
			super(type, bubbles, true);
			this.pantaste = pantaste;
			this.changeType = changeType;
			this.panel = panel;
		}
		/**
		 * @inheritDocs
		 */ 
		override public function clone():Event
		{
			return new DashPanelContainerEvent(type, pantaste, changeType, panel, bubbles);
		}
	}
}