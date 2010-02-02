package com.comtaste.pantaste.events
{
	import com.comtaste.pantaste.components.DashPanel;
	
	import flash.events.Event;

	/*
	 * Event type dispatched by MDIManager. Majority of events based on/relayed from managed windows.
	 */
	/**
	 * Events dispatched from a DashPanel.
	 * <p>
	 * 	Each event that results from the interaction of the user over a DashPanel is represented by this class.
	 * 
	 * </p>
	 */ 
	public class DashPanelEvent extends Event
	{
		/**
		 * Defines the value of the type property of a beginning of a dragging event. 
		 */ 
		public static const PANEL_TITLE_ACTION:String = "panelTitleAction";

		/**
		 * Defines the value of the type property of a beginning of a dragging event. 
		 */
		public static const PANEL_RESIZER_ACTION:String = "panelResizerOver";
		
		/**
		 * Defines the value of the type property of a panel selection event.
		 */
		public static const PANEL_SELECTED:String = "panelSelected";
		
		/**
		 * Defines the value of the type property of a panel moving event.
		 */
		public static const PANEL_MOVE_START:String = "panelMoveStart";
		
		/**
		 * Defines the value of the type property of a panel moving event.
		 */
		public static const PANEL_MOVE_STOP:String = "panelMoveStop";
		
		/**
		 * Defines the value of the type property of a panel resizing event.
		 */
		public static const PANEL_RESIZE_START:String = "panelResizeStart";
		
		/**
		 * Defines the value of the type property of a panel resizing event.
		 */
		public static const PANEL_RESIZE_STOP:String = "panelResizeStop";
		
		/**
		 * Defines the value of the type property of a panel maximization event.
		 */
		public static const MAXIMIZE:String = "maximize";
		
		/**
		 * Defines the value of the type property of a panel minimization event.
		 */
		public static const MINIMIZE:String = "minimize";
		
		/**
		 * Defines the value of the type property of a panel restoring event.
		 */
		public static const RESTORE:String = "restore";
		
		/**
		 * Defines the value of the type property of a panel closing event.
		 */
		public static const CLOSE:String = "close";
		
		/**
		 * Defines the value of the type property of a the event of loading the contents of a DashPanel.
		 */
		public static const STARTLOAD:String = "startLoad";
		
		/**
		 * Defines the value of the type property of a the event of stopping the loading of the contents of a DashPanel. 
		 */
		public static const STOPLOAD:String = "stopLoad";
		
		/**
		 * The DashPanel related with the event.
		 */
		public var panel:DashPanel;
		
		/**
		 * Constructor.
		 * @param type:String the event's type
		 * @param panel:DashPanel the event's target
		 * @param bubbles:Boolean whether enable bubbling of this event
		 */
		public function DashPanelEvent( type:String, panel:DashPanel = null, bubbles:Boolean = false )
		{
			if ( type == STARTLOAD || type == STOPLOAD )
				bubbles = true;
				
			super(type, bubbles, true);
			this.panel = panel;
		}
		/**
		 * @inheritDocs
		 */ 
		override public function clone():Event
		{
			return new DashPanelEvent(type, panel, bubbles);
		}
	}
}