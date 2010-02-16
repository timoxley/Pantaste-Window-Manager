package com.comtaste.pantaste.components {
	import com.comtaste.pantaste.behaviours.MoveBehaviour;
	import com.comtaste.pantaste.behaviours.ResizeBehaviour;
	import com.comtaste.pantaste.behaviours.SelectBehaviour;
	import com.comtaste.pantaste.behaviours.modifiers.SelectModifier;
	import com.comtaste.pantaste.common.DashConstants;
	import com.comtaste.pantaste.components.skins.DashPanelSkin;
	import com.comtaste.pantaste.events.DashPanelEvent;
	import com.comtaste.pantaste.selection.SelectionController;
	
	import flash.events.ContextMenuEvent;
	import flash.events.MouseEvent;
	import flash.ui.ContextMenu;
	
	import mx.binding.utils.BindingUtils;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.managers.DragManager;
	
	import spark.components.Group;
	import spark.components.SkinnableContainer;
	
	
	[SkinState("hover")]
	[SkinState("selected")]
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	/**
	 *  Dispatched when the minimize button is clicked.
	 *
	 *  @eventType com.comtaste.pantaste.events.DashPanelEvent.MINIMIZE
	 */
	[Event(name="minimize", type="com.comtaste.pantaste.events.DashPanelEvent")]
	/**
	 *  If the window is minimized, this event is dispatched when the titleBar is clicked.
	 * 	If the window is maxmimized, this event is dispatched upon clicking the restore button
	 *  or double clicking the titleBar.
	 *
	 *  @eventType com.comtaste.pantaste.events.DashPanelEvent.RESTORE
	 */
	[Event(name="restore", type="com.comtaste.pantaste.events.DashPanelEvent")]
	/**
	 *  Dispatched when the maximize button is clicked or when the window is in a
	 *  normal state (not minimized or maximized) and the titleBar is double clicked.
	 *
	 *  @eventType com.comtaste.pantaste.events.DashPanelEvent.MAXIMIZE
	 */
	[Event(name="maximize", type="com.comtaste.pantaste.events.DashPanelEvent")]
	/**
	 * A DashPanel is a draggable, resizable container.
	 * <p>
	 * 	It lies inside a DashPanelContainer and has the same capabilities of a common
	 *  application window such as those in common OSes graphical interface, with a set of commands
	 * 	in the upper right corner (DashPanelControls) and a title bar (DashPanelTitleBar) that displays a title and allows
	 * 	dragging of the DashPanel.
	 * </p>
	 * @see com.comtaste.pantaste.components.DashPanelContainer
	 * @see com.comtaste.pantaste.components.DashPanelTitleBar
	 * @see com.comtaste.pantaste.components.DashPanelControls
	 * @see mx.container.Canvas
	 */
	public class DashPanel extends SkinnableContainer implements IDashPanel {

		//----------------------------------------------------------
		//
		//   Static Properties 
		//
		//----------------------------------------------------------

		[Inject]
		public var selectionManager:SelectionController;
		
		/**
		 * String constant for maximized state.
		 */
		public static const MAXIMIZED:String = "maximized";
		
		/**
		 * String constant for minimized state.
		 */
		public static const MINIMIZED:String = "minimized";
		
		/**
		 * String constant for restored state.
		 */
		public static const RESTORED:String = "restored";

		//----------------------------------------------------------
		//
		//   Constructor 
		//
		//----------------------------------------------------------

		/**
		 * Constructor.
		 */
		public function DashPanel() {
			super();
			addEventListener(FlexEvent.PREINITIALIZE, onPreInitialize);
			/*addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void{
				trace('dashPanel.width: ' + this.width);
				trace('dashPanel.height: ' + this.height);
				
				trace('content.width: ' + contentContainer.width);
				trace('content.height: ' + contentContainer.height);
				
				trace('content.explicitWidth: ' + contentContainer.explicitWidth);
				trace('content.explicitHeight: ' + contentContainer.explicitHeight);
				trace('content.measuredWidth: ' + contentContainer.measuredWidth);
				trace('content.measuredHeight: ' + contentContainer.measuredHeight);
				
			});*/
			saveRestoredSize();
			
		}

		//----------------------------------------------------------
		//
		//    Public Properties 
		//
		//----------------------------------------------------------
		
		/**
		 * If <code>true</code>, then the DashPanel is always displayed over the other DashPanels in the DashPanelContainer.
		 * @see com.comtaste.pantaste.components.DashPanelContainer
		 */
		[Bindable]
		public var alwaysInFront:Boolean = false;
		
		/**
		 * If <code>true</code>, it is possible to close the DashPanel. Otherwise, it is not possible.
		 * @see #maximizable
		 * @see #minimizable
		 */
		[Bindable]
		public var closable:Boolean = true;
		
		/**
		 * Context menu for this DashPanel.
		 */
		public var contMenu:ContextMenu = new ContextMenu();
		
		/**
		 * Canvas on which are displayed the contents of the DashPanel.
		 */
		[SkinPart(required="true")]
		public var contentContainer:Group;
		
		/**
		 * If <code>true</code>, it is possible to drag the DashPanel around. Otherwise, it is not possible.
		 */
		[Bindable]
		public var draggable:Boolean = true;
		
		/**
		 * If <code>true</code>, it is possible to maximize the DashPanel. Otherwise, it is not possible.
		 */
		[Bindable]
		public var maximizable:Boolean = true;
		
		/**
		 * If <code>true</code>, it is possible to minimize the DashPanel. Otherwise, it is not possible.
		 * @see #maximizable
		 */
		[Bindable]
		public var minimizable:Boolean = true;
		
		/**
		 * Drag to move behaviour 
		 */
		public var moveBehaviour:MoveBehaviour;
		
		/**
		 * If <code>true</code>, it is possible to resize the DashPanel. Otherwise, it is not possible.
		 * @see #maximizable
		 * @see #minimizable
		 * @see #closable
		 */
		[Bindable]
		public var resizable:Boolean = true;
		
		/**
		 * Resizing behaviour 
		 */
		public var resizeBehaviour:ResizeBehaviour;
		
		/**
		 * Canvas that listens to the resizing actions
		 * <p>
		 * 	It is located in the bottom-right corner of the DashPanel and allows the resizing of the DashPanel,
		 *  similarly to most OSes window based graphical interfaces.
		 * </p>
		 */
		[SkinPart(required="true")]
		public var resizeHandle:Group;
		
		/**
		 * Keeps track of the height of this DashPanel.
		 * <p>
		 *  Before a minimization or a maximization of this DashPanel, this.restoredHeight is given the value of the current this.height property,
		 *  in order to restore it.
		 * </p>
		 */
		public var restoredHeight:Number;
		
		/**
		 * Keeps track of the width of this DashPanel.
		 * <p>
		 *  Before a minimization or a maximization on this DashPanel, this.restoredWidth is given the value of the current this.width property,
		 *  in order to restore it.
		 * </p>
		 */
		public var restoredWidth:Number;
		
		/**
		 * Keeps track of the x position of this DashPanel.
		 * <p>
		 *  Before a minimization or a maximization of this DashPanel, this.restoredX is given the value of the current this.x property,
		 *  in order to restore it.
		 * </p>
		 */
		public var restoredX:Number;
		
		/**
		 * Keeps track of the y position of this DashPanel.
		 * <p>
		 *  Before a minimization or a maximization of this DashPanel, this.restoredY is given the value of the current this.x property,
		 *  in order to restore it.
		 * </p>
		 */
		public var restoredY:Number;


		//----------------------------------
		//  hovered
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the hovered property 
		 */
		private var _hovered:Boolean = false;    
		
		/**
		 *  Indicates whether the mouse pointer is over the button.
		 *  Used to determine the skin state.
		 */
		protected function get hovered():Boolean
		{
			return _hovered;
		}
		
		/**
		 *  @private
		 */ 
		protected function set hovered(value:Boolean):void
		{
			if (value == _hovered)
				return;
			
			_hovered = value;
			invalidateSkinState();
		}
		
		//--------------------------------------
		// status 
		//--------------------------------------

		
		/**
		 * Status string.
		 */
		private var _status:String = RESTORED;
		
		/**
		 * This DashPanel's status.
		 * <p>
		 * 	It can take one value in the set RESTORED,MINIMIZED,MAXIMIZED.
		 * </p>
		 */
		public function get status():String {
			return _status;
		}
		
		public function set status(value:String):void {
			if (value != RESTORED) {
				saveRestoredSize();
			} else {
				resetRestoredSize();
			}
			
			_status = value;
		}
		
		//--------------------------------------
		// title 
		//--------------------------------------
		
		/**
		 * Title of this DashPanel.
		 */
		
		private var _title:String;
		[Bindable]
		public function get title():String
		{
			return _title;
		}

		public function set title(value:String):void
		{
			_title = value;
		}

		
		/**
		 * The DashPanelTitleBar of this DashPanel.
		 * @see com.comtaste.pantaste.components.DashPanelTitleBar
		 */
		[SkinPart(required="true")]
		public var titleBar:DashPanelTitleBar;


		//----------------------------------------------------------
		//
		//   Protected Functions 
		//
		//----------------------------------------------------------

		/**
		 * Handles the event of selecting an item in the contextual menu.
		 * <p>
		 * 	For each entry of the menu, a different DashPanelEvent is dispatched.
		 * 	There are five options:
		 * 	<ul>
		 * 		<li><b>Close</b> - Closes this DashPanel.</li>
		 * 		<li><b>Restore</b> - If minimized or maximized, restores the previous size of this DashPanel.</li>
		 * 		<li><b>Maximize</b> - Maximizes this DashPanel.</li>
		 * 		<li><b>Minimize</b> - Minimizes this DashPanel.</li>
		 *  	<li><b>Always in Front</b> - Sets this DashPanel always over the other DashPanels in the DashPanelContainer.</li>
		 * 	</ul>
		 * </p>
		 * @see com.comtaste.pantaste.events.DashPanelEvent
		 */
		protected function onMenuSelect(event:ContextMenuEvent):void {
			switch (event.target.caption) {
				case "Close":
					dispatchEvent(new DashPanelEvent(DashPanelEvent.CLOSE, this));
					break;
				case "Restore":
					dispatchEvent(new DashPanelEvent(DashPanelEvent.RESTORE, this));
					break;
				case "Maximize":
					dispatchEvent(new DashPanelEvent(DashPanelEvent.MAXIMIZE, this));
					break;
				case "Minimize":
					dispatchEvent(new DashPanelEvent(DashPanelEvent.MINIMIZE, this));
					break;
				case "Always in Front":
					alwaysInFront = !alwaysInFront;
					break;
			}
		}
		
		[Inject]
		public var selectionController:SelectionController;
		
		public var selectBehaviour:SelectBehaviour;
		
		
		override protected function getCurrentSkinState() : String {
			if (!(resizeBehaviour.isResizing || moveBehaviour.isMoving)) {
				if (selectBehaviour.isSelected) {
					return 'selected';
				} else if (hovered) {
					return 'hover';
				}
			}
			
			return super.getCurrentSkinState();
		}
		
		override protected function partAdded(partName:String, instance:Object):void {
			if (instance == titleBar) {
				BindingUtils.bindProperty(titleBar.title, 'text', this, 'title');
			} else if (instance == contentContainer) {
				/*contentToCreate.percentHeight = 100;
				contentToCreate.percentWidth = 100;*/
				//this.width = contentToCreate.width;
				//this.height = contentToCreate.height;
				
				BindingUtils.bindProperty(contentContainer, 'height', contentToCreate, 'height');
				BindingUtils.bindProperty(contentContainer, 'width', contentToCreate, 'width');
				hasContentToCreate = false;
				addContent(contentToCreate);
				
				moveBehaviour.proxy.snapshotTarget = contentContainer;
			}
			
			if (contentContainer && resizeHandle) {
			//resizeBehaviour = new ResizeBehaviour(MouseEvent.MOUSE_DOWN, UIComponent(contentToCreate), resizeHandle);
				resizeBehaviour = new ResizeBehaviour(MouseEvent.MOUSE_DOWN, UIComponent(contentToCreate), resizeHandle);
				//resizeBehaviour.proxy.snapshotTarget = contentContainer;
			//	resizeBehaviour.proxyLayer = IVisualElementContainer(this.parentApplication);
				resizeBehaviour.startTriggered.add(onResizeTriggered);
				resizeBehaviour.stopTriggered.add(onResizeStopped);
				//resizeBehaviour.resizeMode = ResizeBehaviour.SCALE_MODE;
				BindingUtils.bindProperty(resizeBehaviour, 'enabled', this, 'resizable');
				
			}
		}
		
		private function onResizeTriggered():void {
			this.invalidateSkinState();
		}
		
		private function onResizeStopped():void {
			this.invalidateSkinState();
		}
		
		private var hasContentToCreate:Boolean = false;
		private var contentToCreate:IVisualElement;
		
		public function addContent(element:IVisualElement):void {
			
			if (element.width < DashConstants.DEFAULT_PANEL_WIDTH) {
				element.width = DashConstants.DEFAULT_PANEL_WIDTH;
			}
			
			if (element.height < DashConstants.DEFAULT_PANEL_HEIGHT) {
				element.height = DashConstants.DEFAULT_PANEL_HEIGHT;
			}
			
			if (contentContainer) {
				contentContainer.removeAllElements();
				contentContainer.addElement(element);
				hasContentToCreate = false;
			} else {
				hasContentToCreate = true
				contentToCreate = element;
			}
		}
		
		//----------------------------------------------------------
		//
		//    Private Functions 
		//
		//----------------------------------------------------------

		/**
		 * Initialization code for children of this DashPanelContainer
		 * @param event:FlexEvent the initialization FlexEvent
		 */
		private function onPreInitialize(event:FlexEvent):void {
			removeEventListener(FlexEvent.PREINITIALIZE, onPreInitialize);
			
			setStyle('skinClass', com.comtaste.pantaste.components.skins.DashPanelSkin);
			
			// Start a move when people mousedown
			moveBehaviour = new MoveBehaviour(MouseEvent.MOUSE_DOWN, this);
			
			// set up dummy selection behaviour that doesn't actually select anything
			selectBehaviour = new SelectBehaviour(MouseEvent.CLICK, this, this);
			selectBehaviour.selectionController = selectionController;
			selectBehaviour.selectData = null;
			selectBehaviour.enabled = false;
			
			// link the move behaviour to the selection behaviour
			moveBehaviour.addModifier(new SelectModifier(selectBehaviour));
			
			minWidth = DashConstants.DEFAULT_MINIMUM_PANEL_WIDTH;
			minHeight = DashConstants.DEFAULT_MINIMUM_PANEL_HEIGHT;

		}
		
		private function onRollOver(event:MouseEvent):void {
			if (DragManager.isDragging) {
				return;
			}
			hovered = true;
		}
		private function onRollOut(event:MouseEvent):void {
			if (DragManager.isDragging) {
				return;
			}
			hovered = false;
		}
		
		/**
		 * Dispatches a DashPanelEvent of type <code>RESTORED</code>.
		 * @see #RESTORE
		 * @see com.comtaste.pantaste.components.DashPanel
		 */
		private function resetRestoredSize():void {
			dispatchEvent(new DashPanelEvent(RESTORED, this));
		}
		
		/**
		 * Restores the cursor to the default cursor.
		 * @param event:MouseEvent the related MouseEvent
		 */
		private function restoreCursor(event:MouseEvent):void {
			cursorManager.removeAllCursors();
		}
		
		/**
		 * Records in the <code>this.restoredX, this.restoredY, this.restoredHeight, this.restoredWidth</code>, respectively, the
		 * values of the <code>this.x, this.y, this.height, this.width</code> properties.
		 */
		private function saveRestoredSize():void {
			if (status != MAXIMIZED) {
				restoredX = x;
				restoredY = y;
				restoredHeight = height;
				restoredWidth = width;
			}
		}
	}
}