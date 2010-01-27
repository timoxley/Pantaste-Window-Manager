/*
 * 
 * definisce i controlli di un panel:
 * 		minimize
 * 		maximize
 * 		restore
 * 		close
 * 		fitAvailableSpace
 * 
 * espone metodi per nascondere e mostrare i controlli necesseri
 */
package com.comtaste.pantaste.components
{
	import com.comtaste.pantaste.events.DashPanelEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.containers.HBox;
	import mx.controls.Button;
	import mx.core.ScrollPolicy;
	import mx.events.FlexEvent;
	
	import spark.components.Group;

	/**
	 * Control buttons of a DashPanel.
	 * 
	 * <p>It contains the buttons to perform the following actions over the DashPanel component:
	 * <ul>
	 * <li><b>minimize</b> - Minimizes the relative DashPanel to the DashDock</li>
	 * <li><b>maximize</b> - Maximizes the relative DashPanel </li>
	 * <li><b>restore</b> - Restores the DashPanel to the previous size w.r.t. a minimize or maximize action </li>
	 * <li><b>close</b> - closes the relative DashPanel</li>
	 * </ul>
	 * </p>
	 * 
	 * @see com.comtaste.pantaste.components.DashDock DashDock
	 * @see com.comtaste.pantaste.components.DashPanel DashPanel
	 */ 
	public class DashPanelControls extends Group implements IDashPanelElement
	{
		/**
		 * Reference to the relative DashPanel
		 */ 
		private var panel:DashPanel;
		
		/**
		 * Button to minimize the relative DashPanel to the DashDock.
		 * @see com.comtaste.pantaste.components.DashDock DashDock
	 	 * @see com.comtaste.pantaste.components.DashPanel DashPanel
		 */ 
		private var minimizeButton:Button;
		
		/**
		 * Button to maximize/restore the size of the DashPanel.
		 * @see com.comtaste.pantaste.components.DashPanel DashPanel
		 */
		public var maximizeRestoreButton:Button;
		
		/**
		 * Close button.
		 */
		private var closeButton:Button;
		
		/**
		 * Constructor.
		 * @param panel:DashPanel The relative DashPanel
		 * @see com.comtaste.pantaste.components.DashPanel DashPanel 
		 */
		public function DashPanelControls( panel:DashPanel )
		{
			super();
			
			this.panel = panel;
		/*	verticalScrollPolicy = ScrollPolicy.OFF;
			horizontalScrollPolicy = ScrollPolicy.OFF;*/
			
			addEventListener( FlexEvent.CREATION_COMPLETE, init );
		}
		
		/**
		 * Handler of the initialization event.
		 * @param event:FlexEvent FlexEvent related to the initialization of this component. 
		 */ 
		protected function init( event:FlexEvent ) : void
		{
			var hboxContainer:HBox = new HBox();
			hboxContainer.percentHeight = 100;
			hboxContainer.verticalScrollPolicy = ScrollPolicy.OFF;
			hboxContainer.horizontalScrollPolicy = ScrollPolicy.OFF;
			hboxContainer.setStyle( "verticalAlign", "middle" );
			//hBoxContainer.styleName = "controls";
			
			/* if ( panel.minimizable )
			{ */
				minimizeButton = new Button();
				BindingUtils.bindProperty(minimizeButton, "visible", panel, "minimizable" );
				BindingUtils.bindProperty(minimizeButton, "includeInLayout", panel, "minimizable" );
				minimizeButton.styleName = "minimizeButton";
				hboxContainer.addElement( minimizeButton );
			/* } */
			
			/* if ( panel.maximizable )
			{ */
				maximizeRestoreButton = new Button();
				BindingUtils.bindProperty(maximizeRestoreButton, "visible", panel, "maximizable" );
				BindingUtils.bindProperty(maximizeRestoreButton, "includeInLayout", panel, "maximizable" );
				maximizeRestoreButton.styleName = "maximizeButton";
				hboxContainer.addElement( maximizeRestoreButton );
			/* } */
			
			/* if ( panel.closable )
			{ */
				closeButton = new Button();
				BindingUtils.bindProperty(closeButton, "visible", panel, "closable" );
				BindingUtils.bindProperty(closeButton, "includeInLayout", panel, "closable" );
				closeButton.styleName = "closeButton";
				hboxContainer.addElement( closeButton );
			/* } */

			addElement( hboxContainer );
			
			addListeners();
		}
		/**
		 * Adds listeners to the buttons of this DashPanelControls.
		 * @see #minimizeButton
		 * @see #maximizeRestoreButton
		 * @see #closeButton
		 */ 
		protected function addListeners( ) : void
		{
			if ( minimizeButton )
				minimizeButton.addEventListener( MouseEvent.CLICK, minimize );
			
			if ( maximizeRestoreButton )
				maximizeRestoreButton.addEventListener( MouseEvent.CLICK, maximizeRestore );
				
			if ( closeButton )
				closeButton.addEventListener( MouseEvent.CLICK, close );
		}
		/**
		 * Handler to the click event on the <code>minimizeButton</code> button.
		 * 
		 * <p>It dispatches a DashPanelEvent.MINIMIZED event.</p>
		 *  
		 * @param event:Event minimization event.
		 * @see #minimizeButton
		 * @see flash.events.Event Event
		 */ 
		protected function minimize( event:Event = null ) : void
		{
			if ( maximizeRestoreButton )
				maximizeRestoreButton.styleName = "maximizeButton";
			
			/* panel.status = DashPanel.MINIMIZED; */
			
			var minimizedEvent:DashPanelEvent = new DashPanelEvent( DashPanelEvent.MINIMIZE, panel );
			panel.dispatchEvent( minimizedEvent );
		}
		
		/**
		 * Handler to the click event on the <code>maximizeRestoreButton</code> button.
		 * 
		 * <p>It dispatches a DashPanelEvent.RESTORED event if the DashPanel is maximized or minimized, otherwise a DashPanelEvent.MAXIMIZE event.</p>
		 * @param event:Event maximization/restore event.
		 * @see #maximizeRestoreButton
		 * @see flash.events.Event Event
		 * @see com.comtaste.pantaste.events.DashPanelEvent
		 */ 
		protected function maximizeRestore( event:Event = null ) : void
		{
			var restoredEvent:DashPanelEvent;
			if ( panel.status == DashPanel.RESTORED )
			{
				maximizeRestoreButton.styleName = "restoreButton";
				
				/* panel.status = DashPanel.MAXIMIZED; */
				
				var maximizedEvent:DashPanelEvent = new DashPanelEvent( DashPanelEvent.MAXIMIZE, panel );
				panel.dispatchEvent( maximizedEvent );
			}
			else if ( panel.status == DashPanel.MAXIMIZED )
			{
				maximizeRestoreButton.styleName = "maximizeButton";
				
				/* panel.status = DashPanel.RESTORED; */
			
				restoredEvent = new DashPanelEvent( DashPanelEvent.RESTORE, panel );
				panel.dispatchEvent( restoredEvent );
			}
			else if ( panel.status == DashPanel.MINIMIZED )
			{
				maximizeRestoreButton.styleName = "maximizeButton";
				
				/* panel.status = DashPanel.RESTORED; */
				
				restoredEvent = new DashPanelEvent( DashPanelEvent.RESTORE, panel );
				panel.dispatchEvent( restoredEvent );
			}
		}
		/**
		 * Handler to the click event on the <code>closeButton</code> button.
		 * 
		 * <p>It dispatches a DashPanelEvent.CLOSE event.</p>
		 * 
		 * @param event:MouseEvent close event.
		 * @see #closeButton
		 * @see flash.events.Event Event
		 * @see com.comtaste.pantaste.events.DashPanelEvent
		 */ 
		protected function close( event:MouseEvent ) : void
		{
			var closeEvent:DashPanelEvent = new DashPanelEvent( DashPanelEvent.CLOSE, panel );
			panel.dispatchEvent( closeEvent );
		}
	}
}