package com.comtaste.pantaste.events
{
	import com.comtaste.pantaste.components.DashPanelHandler;
	
	import flash.events.Event;

	/**
	 * Event type dispatched by DashLayoutManager. Majority of events based on/relayed from managed panels.
	 */
	public class DashManagerEvent extends Event
	{

		/**
		 * 
		 */ 
		public var handler:DashPanelHandler;
		
		/**
		 * 
		 */ 
		public static const PANEL_HANDLER_MOVING:String = "panelHandlerMoving";
		
		/**
		 * 
		 */ 
		public static const PANEL_HANDLER_RESIZING:String = "panelHandlerResizing";
		
		/**
		 * 
		 */ 
		public function DashManagerEvent( type:String, handler:DashPanelHandler = null, bubbles:Boolean = false )
		{
			super(type, bubbles, true);
			this.handler = handler;
		}
		
		/**
		 * @inheritDocs
		 */ 
		override public function clone():Event
		{
			return new DashManagerEvent(type, handler, bubbles);
		}
	}
}