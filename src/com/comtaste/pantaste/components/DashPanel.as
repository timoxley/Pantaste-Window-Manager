package com.comtaste.pantaste.components
{
	import com.comtaste.pantaste.common.DashConstants;
	import com.comtaste.pantaste.events.DashPanelEvent;
	
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import mx.containers.VBox;
	import mx.skins.Border;
	
	import spark.components.Group;
	import spark.events.ElementExistenceEvent;
	
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
	
	public class DashPanel extends Group implements IDashPanel
	{
		/**
		 * String constant for maximized state.
		 */ 
		public static const MAXIMIZED:String = "maximized";
		
		/**
		 * String constant for restored state.
		 */
		public static const RESTORED:String = "restored";
		
		/**
		 * String constant for minimized state. 
		 */
		public static const MINIMIZED:String = "minimized";
		
 
		[Embed("/assets/loading.swf")]
		/**
		 * Animation shown when loading.
		 */
		protected var loading:Class;
		
		/**
		 * Box containing the assets shown when loading.
		 */ 
		private var imageLoading:VBox;
		
		/**
		 * Status string.
		 */		
		private var _status:String;
		
		/**
		 * The DashPanelTitleBar of this DashPanel.
		 * @see com.comtaste.pantaste.components.DashPanelTitleBar  
		 */
		//[SkinPart(required="true")]
		public var titleBar:DashPanelTitleBar;
		
		/**
		 * Title of this DashPanel.
		 */
		private var _title:String;
		
		/**
		 * Horizontal offset from the leftmost border of this DashPanel.
		 */
		private var _titleXOffset:Number = 0;
		
		/**
		 * Container of the icons related to the items of the sub menus.
		 */
		private var iconContainer:Group;
		
		/**
		 * Canvas that listens to the resizing actions
		 * <p>
		 * 	It is located in the bottom-right corner of the DashPanel and allows the resizing of the DashPanel,
		 *  similarly to most OSes window based graphical interfaces. 
		 * </p> 
		 */
		//[SkinPart(required="true")]
		public var resizer:Group;
		
		/* private var controls:DashPanelControls; */
		
		/**
		 * Canvas on which are displayed the contents of the DashPanel.
		 */
		//[SkinPart(required="true")]
		public var content:Group;

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
		 * If <code>true</code>, it is possible to close the DashPanel. Otherwise, it is not possible.
		 * @see #maximizable
		 * @see #minimizable 
		 */
		[Bindable]
		public var closable:Boolean = true;
		
		/**
		 * If <code>true</code>, it is possible to drag the DashPanel around the DashPanelContainer. Otherwise, it is not possible.
		 * @see #maximizable
		 * @see #minimizable 
		 * @see #closable 
		 * @see com.comtaste.pantaste.components.DashPanelContainer 
		 */
		[Bindable]
		public var draggable:Boolean = true;
		
		/**
		 * If <code>true</code>, it is possible to resize the DashPanel. Otherwise, it is not possible.
		 * @see #maximizable
		 * @see #minimizable 
		 * @see #closable 
		 */
		[Bindable]
		public var resizable:Boolean = true;
		
		/**
		 * If <code>true</code>, then the DashPanel is always displayed over the other DashPanels in the DashPanelContainer.
		 * @see com.comtaste.pantaste.components.DashPanelContainer 
		 */
		[Bindable]
		public var alwaysInFront:Boolean = false;
		
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
		 * X offset of this DashPanel icon. The icon is placed in the upper left corner of the DashPanel.
		 */
		public var iconXOffset:int = 2;
		
		/**
		 * Y offset of this DashPanel icon. The icon is placed in the upper left corner of the DashPanel.
		 */
		public var iconYOffset:int = 2;
		
		/**
		 * Indicates the current cursor used by the CursorManager.
		 */
		private var currentCursorID:int = -1;
		
		
		/**
		 * Resize cursor.
		 */
		[Embed("/assets/cursors/resize-l.png")]
		protected var resizerCur:Class;
		
		/**
		 * Move cursor. 
		 */
		[Embed("/assets/cursors/move.png")]
		protected var moveCur:Class;
		
		/**
		 * Context menu for this DashPanel.
		 */
		public var contMenu:ContextMenu = new ContextMenu();
		
		/**
		 * Constructor.
		 */
		public function DashPanel()
		{
			super();
			
			/*imageLoading = new VBox( );
			imageLoading.setStyle( "verticalAlign", "middle" );
			imageLoading.setStyle( "horizontalAlign", "center" );
			imageLoading.percentHeight = 100;
			imageLoading.percentWidth = 100;*/
			
			/*var label:Label = new Label( );
				label.text = "Loading";
				label.setStyle( "fontWeight", "bold" );
				label.setStyle( "fontSize", 14 );
			imageLoading.addChild( label );
				
			var imgLoading:Image = new Image( );
				imgLoading.source = loading;
			imageLoading.addChild( imgLoading );*/
			
			
			if ( !width ) width = DashConstants.DEFAULT_PANEL_WIDTH;
			if ( !height ) height = DashConstants.DEFAULT_PANEL_HEIGHT;
			
			resizer = new Group();
			
			titleBar = new DashPanelTitleBar();
			titleBar.panel = this;
            var menuItemAlwaysInFront:ContextMenuItem = new ContextMenuItem("Always in Front");
            var menuItemRestore:ContextMenuItem = new ContextMenuItem("Restore");
            var menuItemMaximize:ContextMenuItem = new ContextMenuItem("Maximize");
            var menuItemMinimize:ContextMenuItem = new ContextMenuItem("Minimize");
            var menuItemClose:ContextMenuItem = new ContextMenuItem("Close");
            
            menuItemClose.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onMenuSelect );
            menuItemRestore.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onMenuSelect );
            menuItemMaximize.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onMenuSelect );
            menuItemMinimize.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onMenuSelect );
            menuItemAlwaysInFront.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onMenuSelect );
            
			contMenu.customItems.push( menuItemAlwaysInFront );
            contMenu.customItems.push( menuItemRestore );
            contMenu.customItems.push( menuItemMaximize );
            contMenu.customItems.push( menuItemMinimize );
            contMenu.customItems.push( menuItemClose );
            contMenu.hideBuiltInItems();
            titleBar.contextMenu = contMenu;
                
			content = new Group( );
			content.percentHeight = 100;
			content.percentWidth = 100;
/*			content.horizontalScrollPolicy = ScrollPolicy.OFF;
			content.verticalScrollPolicy = ScrollPolicy.OFF;*/
			
			_status = RESTORED;
			
/*			horizontalScrollPolicy = ScrollPolicy.OFF;
			verticalScrollPolicy = ScrollPolicy.OFF;*/
			
			addEventListener( ElementExistenceEvent.ELEMENT_ADD, onElementAdd );
			
			addEventListener( DashPanelEvent.STARTLOAD, startLoad );
			addEventListener( DashPanelEvent.STOPLOAD, stopLoad );
			
			saveRestoredSize();
		}
		
		//--------------------------------------
		//  Public Methods
		//--------------------------------------
		
		/**
		 * Handler of the DashPanelEvent.STARTLOAD type event.
		 * <p>
		 * 	It displays the image message that the application is loading.
		 * </p>
		 */
		public function startLoad( event:Event = null ) : void
		{
			content.enabled = false;
			
			if ( !contains( imageLoading ) )
				addChild( imageLoading );
		}
		
		/**
		 * Handler of the DashPanelEvent.STARTLOAD type event. 
		 */
		public function stopLoad( event:Event = null ) : void
		{
			content.enabled = true;
			if ( contains( imageLoading ) )
				removeChild( imageLoading );
		}
		
		//--------------------------------------
		//  Protected Methods
		//--------------------------------------
		
		/**
		 * Adds the listeners on the mouse events over the title bar, in order to move the DashPanel.
		 * @see #titleBar 
		 */
		protected function addTitleBarListeners( ) : void
		{
			titleBar.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDownTitleBar );
			titleBar.addEventListener( MouseEvent.MOUSE_OVER, onMouseOverTitleBar );
			titleBar.addEventListener( MouseEvent.MOUSE_OVER, onMouseOverTitleBar );
			titleBar.addEventListener( MouseEvent.MOUSE_OUT, restoreCursor );
		}
		
		/**
		 * Adds the listeners on the resizer canvas, in order to intercept and handle the resize events.
		 * @see #resizer 
		 */
		protected function configureResizer( ) : void
		{
			resizer.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDownResizer );
			resizer.addEventListener( MouseEvent.MOUSE_OVER, onMouseOverResizer );
			resizer.addEventListener( MouseEvent.MOUSE_OUT, restoreCursor );
		}
		
		/**
		 * Handler of the ElementExistenceEvent.ELEMENT_ADD event.
		 */
		protected function onElementAdd( event:ElementExistenceEvent) : void
		{
			if ( !contains( content ) )
			{
				addElement( content );
			}
			
			if ( ! ( event.element is Border || 
						 event.element is DashPanelTitleBar || 
						 /* event.relatedObject is DashPanelControls || */
						 event.element === resizer ||
						 event.element === content ||
						 event.element === imageLoading ) )
				{
					content.addElement( event.element );
				}
		}
		
		//--------------------------------------
		//  Private Methods
		//--------------------------------------
		
		/**
		 * Records in the <code>this.restoredX, this.restoredY, this.restoredHeight, this.restoredWidth</code>, respectively, the 
		 * values of the <code>this.x, this.y, this.height, this.width</code> properties.
		 */
		private function saveRestoredSize( ) : void
		{
			if ( status != MAXIMIZED )
			{
				restoredX = x;
				restoredY = y;
				restoredHeight = height;
				restoredWidth = width;
			}
			/* else
			{
				controls.maximizeRestoreButton.styleName = "restoreButton";
			} */
		}
		
		/**
		 * Dispatches a DashPanelEvent of type <code>RESTORED</code>.
		 * @see #RESTORE
		 * @see com.comtaste.pantaste.components.DashPanel
		 */
		private function resetRestoredSize( ) : void
		{
			dispatchEvent( new DashPanelEvent( RESTORED, this ) );
		}
		
		//--------------------------------------
		//  Listeners
		//--------------------------------------
		
		/**
		 * Changes the icon when the cursor is over this DashPanel's DashPanelTitleBar
		 * @param event:MouseEvent The related MouseEvent
		 * @see #titleBar 
		 */
		private function onMouseOverTitleBar( event:MouseEvent ) : void
		{
			trace("onMouseOverTitleBar" + event.currentTarget);

			if ((!(event.currentTarget is DashPanelTitleBar)) || status == MAXIMIZED) {
				return;	
			}
			cursorManager.removeCursor( currentCursorID );
			currentCursorID = cursorManager.setCursor( moveCur, 2, -11, -13);
		}
		
		/**
		 * Changes the icon when the cursor is over this DashPanel's resizer.
		 * @param event:MouseEvent The related MouseEvent 
		 * @see #resizer
		 */
		private function onMouseOverResizer( event:MouseEvent ) : void
		{
			if ((!(event.currentTarget is DashPanelTitleBar)) || status == MAXIMIZED) {
				return;	
			}
			
			cursorManager.removeCursor( currentCursorID );
			currentCursorID = cursorManager.setCursor( resizerCur, 2, -9, -6);
		}
		
		/**
		 * Restores the cursor to the default cursor.
		 * @param event:MouseEvent the related MouseEvent 
		 */
		private function restoreCursor( event:MouseEvent ) : void
		{
			cursorManager.removeCursor( currentCursorID );
		}
		
		/**
		 * If draggable, it dispatches the event of this DashPanel being dragged. Otherwise it has no effect. 
		 * @param event:MouseEvent the related MouseEvent
		 * @see com.comtaste.pantaste.events.DashPanelEvent
		 * @see #draggable
		 */
		private function onMouseDownTitleBar( event:MouseEvent ) : void
		{
			/* if ( event.buttonDown ) return; */
			
			/*if ( event.target.name != "contentPane" && event.target != event.currentTarget ) {
				return;
			} */
			
			if (!(event.currentTarget is DashPanelTitleBar)) {
				return;
			}
			
			if ( draggable )
			{
				var panelEvent:DashPanelEvent = new DashPanelEvent( DashPanelEvent.PANEL_TITLE_OVER, this );
				dispatchEvent( panelEvent );
			}
		}
		
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
		protected function onMenuSelect( event:ContextMenuEvent ) : void
		{
			switch ( event.target.caption )
			{
				case "Close":
					dispatchEvent( new DashPanelEvent( DashPanelEvent.CLOSE, this ));
					break;
				case "Restore":
					dispatchEvent( new DashPanelEvent( DashPanelEvent.RESTORE, this ));
					break;
				case "Maximize":
					dispatchEvent( new DashPanelEvent( DashPanelEvent.MAXIMIZE, this ));
					break;
				case "Minimize":
					dispatchEvent( new DashPanelEvent( DashPanelEvent.MINIMIZE, this ));
					break;
				case "Always in Front":
					alwaysInFront = !alwaysInFront;
					break;
			}
		}
		
		/**
		 * If resizable, it dispatches the event of this DashPanel being resized. Otherwise it has no effect. 
		 * @param event:MouseEvent the related MouseEvent
		 * @see com.comtaste.pantaste.events.DashPanelEvent
		 * @see #resizable
		 */
		private function onMouseDownResizer( event:MouseEvent ) : void
		{
			/* if ( event.buttonDown ) return; */
			
			if ( event.target != event.currentTarget ) return;
			
			if ( resizable )
			{
				var panelEvent:DashPanelEvent = new DashPanelEvent( DashPanelEvent.PANEL_RESIZER_OVER, this );
				dispatchEvent( panelEvent );
			}
		}
		
		/**
		 * Configures the icon container in the title bar.
		 * @see com.comtaste.pantaste.components.DashPanelTitleBar
		 */
		private function configureIconContainer( ) : void
		{
			/*if ( !iconContainer )
			{
				iconContainer = new Group( );
				iconContainer.mouseChildren = false;
				iconContainer.mouseEnabled = false; 
				iconContainer.verticalScrollPolicy = ScrollPolicy.OFF
				iconContainer.horizontalScrollPolicy = ScrollPolicy.OFF; 
			}
			
			if ( !contains( iconContainer ) )
				titleBar.addChildAt( iconContainer, 0 );
			
			iconContainer.width = _titleXOffset;
			iconContainer.percentHeight = 100;*/
		}
		
		//--------------------------------------
		//  Setter & Getter
		//--------------------------------------
		
		/**
		 * This DashPanel's status.
		 * <p>
		 * 	It can take one value in the set RESTORED,MINIMIZED,MAXIMIZED.
		 * </p>
		 */
		public function get status():String
		{
			return _status;
		}
		
		public function set status( value:String ):void
		{
			if ( value != RESTORED )
				saveRestoredSize();
			else
				resetRestoredSize();
				
			_status = value;
		}
		
		/**
		 * This DashPanel's title.
		 */
		[Bindable]
		public function get title():String
		{
			return _title;
		}
		
		public function set title( value:String ):void
		{
			titleBar.title.text = value;
			_title = value;
			
			configureIconContainer( );
		}
		
		/**
		 * Horizontal offset from the left border of the DashPanel of the title label. 
		 */
		[Bindable]
		public function get titleXOffset():Number
		{
			return _titleXOffset;
		}
		
		public function set titleXOffset( value:Number ):void
		{
			_titleXOffset = value;
			configureIconContainer( );
		}
		
		/**
		 * Font color of the title text.
		 */
		[Bindable]
		public function get titleColor():uint
		{
			return titleBar.title.getStyle( "color" );
		}
		public function set titleColor( value:uint ):void
		{
			titleBar.title.setStyle( "color", value );
		}
		

		[Bindable]
		/** 
		 * Indicates whether the title text of this DashPanel has to be shown.
		 * <p>
		 * 	When <code>true</code>, the title text on this DashPanel's title bar is shown. Otherwise, it is not shown.
		 * </p>
		 * @see com.comtaste.pantaste.components.DashPanelTitleBar
		 */
		public function get showTitleText():Boolean
		{
			return titleBar.title.visible;
		}
		
		public function set showTitleText( value:Boolean ):void
		{
			titleBar.title.visible = value;
		}
		
		
		[Bindable]
		/**
		 * This DashPanel's DashPanelTitleBar's height.
		 * @see com.comtaste.pantaste.components.DashPanelTitleBar
		 */ 
		public function get titleBarHeight():Number
		{
			return titleBar.height;
		}
		
		public function set titleBarHeight( value:Number ):void
		{
			titleBar.height = value;
			content.y = titleBar.height;
		}
		
		//--------------------------------------
		//  Overridden Methods
		//--------------------------------------
		
		/**
		 * @inheritDoc
	/*	override public function set icon(value:Class):void
		{
			super.icon = value;
			configureIconContainer( );
		}
		*/
		/**
		 * @inheritDoc
		 */
		override protected function createChildren( ) : void
		{
			super.createChildren();
			
			if ( !contains( titleBar ) )
			{
				addElement( titleBar );
				titleBar.styleName = "controlsSkin";
				addTitleBarListeners( );
			}
			
			/* if ( !controls )
			{
				controls = new DashPanelControls( this );
				controls.styleName = "controlsSkin";
				addChild( controls );
			} */
			
			if ( !contains( content ) )
			{
				addElement( content );
			}
			
			if ( !contains( resizer ) )
			{
				addElement( resizer );
				configureResizer( );
			}
			
			content.y = titleBar.height + 12;
			content.x = 12;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			if ( titleBar )
			{
				titleBar.width = width;
			}
			
			/* if ( controls )
			{
				titleBar.width -= controls.width;
				controls.x = titleBar.width - 10;
			} */
			
			if ( content )
			{
				content.height = height - titleBar.height - 24;
				content.width = width - 24;
			}
			
			if ( resizer )
			{
				resizer.x = width - DashConstants.DEFAULT_DASH_RESIZER_SIZE;
				resizer.y = height - DashConstants.DEFAULT_DASH_RESIZER_SIZE;
				resizer.width = DashConstants.DEFAULT_DASH_RESIZER_SIZE;
				resizer.height = DashConstants.DEFAULT_DASH_RESIZER_SIZE;
				
				setElementIndex( resizer, numChildren - 1 );
			}
		}
	}
}