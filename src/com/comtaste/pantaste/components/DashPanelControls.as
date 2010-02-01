package com.comtaste.pantaste.components {
	import com.comtaste.pantaste.components.skins.DashPanelControlsSkin;
	import com.comtaste.pantaste.events.DashPanelEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.events.FlexEvent;
	
	import spark.components.Button;
	import spark.components.SkinnableContainer;
	
	
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
	
	[Style(name="buttonSkinClass",type="Class",format="Class",inherit="yes")]
	public class DashPanelControls extends SkinnableContainer implements IDashPanelElement {
		
		//----------------------------------------------------------
		//
		//   Constructor 
		//
		//----------------------------------------------------------
		
		/**
		 * Constructor.
		 * @param panel:DashPanel The relative DashPanel
		 * @see com.comtaste.pantaste.components.DashPanel DashPanel
		 */
		public function DashPanelControls() {
			super();

			addEventListener(FlexEvent.PREINITIALIZE, onPreInitialize);
		}
		
		//----------------------------------------------------------
		//
		//    Public Properties 
		//
		//----------------------------------------------------------
		
		/**
		 * Close button.
		 */
		[SkinPart(required="true")]
		public var closeButton:Button;
		
		/**
		 * Button to maximize/restore the size of the DashPanel.
		 * @see com.comtaste.pantaste.components.DashPanel DashPanel
		 */
		[SkinPart(required="true")]
		public var maximizeRestoreButton:Button;
		
		/**
		 * Button to minimize the relative DashPanel to the DashDock.
		 * @see com.comtaste.pantaste.components.DashDock DashDock
		 * @see com.comtaste.pantaste.components.DashPanel DashPanel
		 */
		[SkinPart(required="true")]
		public var minimizeButton:Button;
		
		/**
		 * Reference to the relative DashPanel
		 */
		
		private var _panel:DashPanel;
		
		[Bindable]
		public function get panel():DashPanel
		{
			return _panel;
		}

		public function set panel(value:DashPanel):void
		{
			_panel = value;
		}

		
		//----------------------------------------------------------
		//
		//   Protected Functions 
		//
		//----------------------------------------------------------
		
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
		protected function close(event:MouseEvent):void {
			panel.dispatchEvent(new DashPanelEvent(DashPanelEvent.CLOSE, panel));
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
		protected function maximizeRestore(event:Event=null):void {
			var restoredEvent:DashPanelEvent;
			
			if (panel.status == DashPanel.RESTORED) {
				//maximizeRestoreButton.styleName = "restoreButton";
				
				/* panel.status = DashPanel.MAXIMIZED; */
				
				panel.dispatchEvent(new DashPanelEvent(DashPanelEvent.MAXIMIZE, panel));
			} else if (panel.status == DashPanel.MAXIMIZED) {
				//maximizeRestoreButton.styleName = "maximizeButton";
				
				/* panel.status = DashPanel.RESTORED; */
				
				panel.dispatchEvent(new DashPanelEvent(DashPanelEvent.RESTORE, panel));
			} else if (panel.status == DashPanel.MINIMIZED) {
				//maximizeRestoreButton.styleName = "maximizeButton";
				
				/* panel.status = DashPanel.RESTORED; */
				
				panel.dispatchEvent(new DashPanelEvent(DashPanelEvent.RESTORE, panel));
			}
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
		protected function minimize(event:Event=null):void {
			panel.dispatchEvent(new DashPanelEvent(DashPanelEvent.MINIMIZE, panel));
		}
		
		
		/**
		 * Setup default component skin
		 * @param event:FlexEvent FlexEvent related to the initialization of this component.
		 */
		protected function onPreInitialize(event:FlexEvent):void {
			removeEventListener(FlexEvent.PREINITIALIZE, onPreInitialize);
			setStyle('skinClass', com.comtaste.pantaste.components.skins.DashPanelControlsSkin);
		}
		
		
		/**
		 * Add listeners to the control buttons & prevent mouse events from bubbling up to container components.
		 * @inheritDoc
		 * @see #minimizeButton
		 * @see #maximizeRestoreButton
		 * @see #closeButton
		 */
		override protected function partAdded(partName:String, instance:Object):void {
			if (!panel) {
				throw new Error("Dependency: 'panel' required.");
			}
			if (instance == minimizeButton) {
				BindingUtils.bindProperty(minimizeButton, "visible", panel, "minimizable");
				BindingUtils.bindProperty(minimizeButton, "includeInLayout", panel, "minimizable");
				minimizeButton.addEventListener(MouseEvent.CLICK, minimize);
				minimizeButton.addEventListener(MouseEvent.MOUSE_OVER, killEvent);
				minimizeButton.addEventListener(MouseEvent.MOUSE_DOWN, killEvent);
			}
			
			if (instance == maximizeRestoreButton) {
				BindingUtils.bindProperty(maximizeRestoreButton, "visible", panel, "maximizable");
				BindingUtils.bindProperty(maximizeRestoreButton, "includeInLayout", panel,
										  "maximizable");
				maximizeRestoreButton.addEventListener(MouseEvent.CLICK, maximizeRestore);
				maximizeRestoreButton.addEventListener(MouseEvent.MOUSE_OVER, killEvent);
				maximizeRestoreButton.addEventListener(MouseEvent.MOUSE_DOWN, killEvent);
				
			}
			
			if (instance == closeButton) {
				BindingUtils.bindProperty(closeButton, "visible", panel, "closable");
				BindingUtils.bindProperty(closeButton, "includeInLayout", panel, "closable");
				closeButton.addEventListener(MouseEvent.CLICK, close);
				closeButton.addEventListener(MouseEvent.MOUSE_OVER, killEvent);
				closeButton.addEventListener(MouseEvent.MOUSE_DOWN, killEvent);
				
			}
		}
		
		public function killEvent(event:MouseEvent):void {
			event.stopPropagation();
		}
	}
}