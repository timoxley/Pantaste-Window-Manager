/*
 * 
 * canvas in cui è possibile visualizzare componentii dashpanel
 * si occupa di layouting e gestione stati pannelli con ausilio di DashLayoutManager
 * 
 */
package com.comtaste.pantaste.components
{
	import com.comtaste.pantaste.common.DashConstants;
	import com.comtaste.pantaste.events.DashPanelContainerEvent;
	import com.comtaste.pantaste.manager.DashLayoutManager;
	
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import mx.events.ChildExistenceChangedEvent;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	
	/**
	 * Dispatched when some change occours in sub panels
	 * moved
	 * minimized
	 * maximized
	 * restored
	 * added
	 * removed
	 *
	 *  @eventType com.comtaste.pantaste.events.DashPanelContainerEvent.pantaste_CHANGED
	 */
	[Event(name="pantasteChanged", type="com.comtaste.pantaste.events.DashPanelContainerEvent")]
	
	
	/**
	 * A DashPanelContainer is the component containing the DashPanels of an application.
	 * <p>
	 * 	Each DashPanelContainer references a DashLayoutManager to place the DashPanels it shows.
	 *  It furthermore has a DashDock in which are displayed the minimized DashPanels in a fashion similar to 
	 *  most window-based OS user interfaces.
	 * 
	 * </p>
	 */
	public class DashPanelContainer extends Group
	{
		/**
		 * Constant defining the type of change event of moving a DashPanel. 
		 */ 
		public static const PANEL_MOVED:String = "pantastePanelMoved";
		
		/**
		 * Constant defining the type of change event of maximizing a DashPanel.
		 */
		public static const PANEL_MAXIMIZED:String = "pantastePanelMaximized";
		
		/**
		 * Constant defining the type of change event of minimizing a DashPanel.
		 */ 
		public static const PANEL_MINIMIZED:String = "pantastePanelMinimized";
		
		/**
		 * Constant defining the type of change event of restoring a DashPanel. 
		 */
		public static const PANEL_RESTORED:String = "pantastePanelRestored";
		
		/**
		 * Constant defining the type of change event of adding a DashPanel.
		 */
		public static const PANEL_ADDED:String = "pantastePanelAdded";

		/**
		 * Constant defining the type of change event of removing a DashPanel.
		 */
		public static const PANEL_REMOVED:String = "pantastePanelRemoved";

		/**
		 * Reference to this DashPanelContainer's DashLayoutManager.
		 * @see com.comtaste.pantaste.manager.DashLayoutManager 
		 */		
		protected var layoutManager:DashLayoutManager;
		
		/**
		 * Reference to this DashPanelContainer's DashDock bar.
		 * @see com.comtaste.pantaste.components.DashDock
		 */
		private var _dock:DashDock;
		
		/**
		 * The available height to place the DashPanels.
		 */
		public var availHeight:Number;
		
		/**
		 * The available width to place the DashPanels.
		 */
		public var availWidth:Number;
		
		/**
		 * Indicates whether the container area is dashed.
		 */
		private var _dashed:Boolean = false;
		
		/**
		 * Indicates whether there exists a snap grid in the container area.
		 */
		private var _snapped:Boolean = false;
		
		/**
		 * Side length of each square cell of the snap grid.
		 */
		private var _snapSize:Number = DashConstants.DEFAULT_DASH_CASCADE_SIZE;
		
		/**
		 * Vertical and horizontal offset when cascading the DashPanels.
		 */
		private var _cascadeSize:Number = DashConstants.DEFAULT_DASH_SNAP_SIZE;
		
		/**
		 * Vertical and horizontal offset when cascading the DashPanels.
		 */
		private var _showStartButton:Boolean = DashConstants.DEFAULT_SHOW_START_BUTON;
		
		/**
		 * Constructor.
		 */
		public function DashPanelContainer( )
		{
			super( );
			if( this.name == null || this.name == "" )
				throw new Error( "A pantastePanelContainer must define an id name" );
				
			layoutManager = new DashLayoutManager( this, this.name );
			this.addEventListener( FlexEvent.INITIALIZE, initializePanel );
			this.addEventListener( FlexEvent.CREATION_COMPLETE, init );
		}
		
		//--------------------------------------
		//  Public Methods
		//--------------------------------------
		
		/**
		 * Dispatches the DashPanelContainerEvent related to a change in the content of the DashPanelContainer
		 * @param changeType:String The string specifying the type of change occurred
		 * @see com.comtaste.pantaste.events.DashPanelContainerEvent
		 */
		public function generatepantasteChangeEvent( changeType:String, panel:DashPanel ):void
		{
			dispatchEvent( new DashPanelContainerEvent( DashPanelContainerEvent.pantaste_CHANGED, this, changeType, panel ) ); 
		}
		
		//--------------------------------------
		//  Private Methods
		//--------------------------------------
		
		/**
		 * Initialization code for this DashPanelContainer
		 * @param event:FlexEvent the initialization FlexEvent
		 */
		private function initializePanel( event:FlexEvent ) : void
		{
			/*
			 * WORKAROUND da fixare
			 * necessario per permettere all'utente di usare l'id del nodo come 
			 * chiave x il multiton
			 * 
			 **/
			DashLayoutManager.updateInstanceKey( layoutManager, this.id );
			 
			this.removeEventListener( FlexEvent.INITIALIZE, initializePanel );
		}
		
		/**
		 * Initialization code for this DashPanelContainer
		 * @param event:FlexEvent the creationComplete FlexEvent
		 */
		private function init( event:FlexEvent ) : void
		{
			if ( !_dock )
			{
				_dock = new DashDock( this );
				_dock.percentWidth = 100;
				_dock.height = 35;
			}
			
			addElement( _dock );
			
			if ( !snapSize )
				snapSize = DashConstants.DEFAULT_DASH_SNAP_SIZE;
				
			if ( !cascadeSize )
				cascadeSize = DashConstants.DEFAULT_DASH_CASCADE_SIZE;
			
			// register restore event for all panel
			var item:Object;
			var panel:DashPanel;
			var numElements:uint = this.numElements;
			
			for(var i:uint = 0; i < numElements; i++) {
				item = this.getElementAt(i);
			
				if( item is DashPanel )
				{
					panel = item as DashPanel;
					panel.addEventListener( DashPanel.RESTORED, restorePanelSize );
				}
				else
					continue;
			
			}

			
			this.addEventListener( ChildExistenceChangedEvent.CHILD_ADD, panelAdded );
			this.addEventListener( ChildExistenceChangedEvent.CHILD_REMOVE, panelRemoved );
		}
		
		/**
		 * Handler of the addition of a DashPanel event
		 * @param evt:ChildExistenceChangedEvent the event related to the addition of a DashPanel
		 */
		private function panelAdded( evt:ChildExistenceChangedEvent ) : void
		{
			generatepantasteChangeEvent( DashPanelContainer.PANEL_ADDED, evt.relatedObject as DashPanel );
		}
		
		/**
		 * Handler of the removing of a DashPanel event
		 * @param evt:ChildExistenceChangedEvent the event related to the removing of a DashPanel
		 */
		private function panelRemoved( evt:ChildExistenceChangedEvent ) : void
		{
			generatepantasteChangeEvent( DashPanelContainer.PANEL_REMOVED, evt.relatedObject as DashPanel );
		}
		
		/**
		 * Handler of the restoring of a DashPanel event
		 * @param evt:Event the event related to the restoring of a DashPanel
		 */
		private function restorePanelSize( evt:Event ) : void
		{
			var panel:DashPanel = evt.target as DashPanel;
			
			setTimeout( function():void {
				layoutManager.applyEffect( arguments[0], arguments[1], arguments[2], arguments[3], arguments[4] );
			}, 1, panel, panel.restoredX, panel.restoredY, panel.restoredWidth, panel.restoredHeight );
		}
		
		//--------------------------------------
		//  Setter & Getter
		//--------------------------------------
		
		
		public function set dashed( value:Boolean ) : void
		{
			if ( value )
			{
				/* _snapped = false; */
				layoutManager.tile( );
			}
			_dashed = value;
		}
		
		/**
		 * Indicates whether the container area is dashed.
		 */
		[Bindable]
		public function get dashed( ) : Boolean
		{
			return _dashed;
		}
		

		public function set snapped( value:Boolean ) : void
		{
			/* if ( value )
				_dashed = false; */
			_snapped = value;
			updateDisplayList( unscaledWidth, unscaledHeight );
		}

		/**
		 * Indicates whether there exists a snap grid in the container area.
		 */
		[Bindable]
		public function get snapped( ) : Boolean
		{
			return _snapped;
		}
		
		public function set snapSize( value:Number ) : void
		{
			_snapSize = value;
			updateDisplayList( unscaledWidth, unscaledHeight );
		}
		
		/**
		 * Set the dock to use for the container.
		 */
		[Bindable]
		public function get dock( ) : DashDock
		{
			return _dock;
		}
		
		public function set dock( value:DashDock ) : void
		{
			_dock = value;
		}
		
		/**
		 * Side length of each square cell of the snap grid.
		 */
		[Bindable]
		public function get snapSize( ) : Number
		{
			return _snapSize;	
		}
		
		
		public function set cascadeSize( value:Number ) : void
		{
			_cascadeSize = value;
		}
		
		/**
		 * Vertical and horizontal offset when cascading the DashPanels.
		 */
		[Bindable]
		public function get cascadeSize( ) : Number
		{
			return _cascadeSize;	
		}
		
		
		public function set showStartButton( value:Boolean ) : void
		{
			_showStartButton = value;
		}
		
		/**
		 * Hide or show the start button.
		 */
		[Bindable]
		public function get showStartButton( ) : Boolean
		{
			return _showStartButton;	
		}
		 
		
		//--------------------------------------
		//  Overrided Methods
		//--------------------------------------
		/**
		 * @inheritDoc
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number) : void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			if ( dock )
			{
				dock.y = height - dock.height;
			}
			
			graphics.clear();
			
			if ( snapped )
			{	
				var stepping:int = snapSize;
				var i:int = stepping;
				
				graphics.lineStyle(1, 0xCCCCCC);
				
				while(i < unscaledWidth) {
					graphics.moveTo(i, 0);
					graphics.lineTo(i, unscaledHeight);
					i += stepping;
				}
				
				i = stepping;
				
				while(i < unscaledHeight) {
					graphics.moveTo(0, i);
					graphics.lineTo(unscaledWidth, i);
					i += stepping;
				}
			}
		}
	}
}