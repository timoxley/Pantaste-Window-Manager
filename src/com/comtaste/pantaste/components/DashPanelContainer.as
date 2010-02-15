package com.comtaste.pantaste.components {
	import com.comtaste.pantaste.behaviours.modifiers.SnapToGridModifier;
	import com.comtaste.pantaste.common.DashConstants;
	import com.comtaste.pantaste.components.skins.DashPanelContainerSkin;
	import com.comtaste.pantaste.events.DashPanelContainerEvent;
	import com.comtaste.pantaste.manager.DashLayoutManager;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import mx.binding.utils.BindingUtils;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	import spark.components.SkinnableContainer;
	import spark.events.ElementExistenceEvent;

	
	
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
	[Style(name="gridAlpha",type="Number",format="Number",inherit="yes")]
	[Style(name="panelCornerRadius",type="Number",format="Number",inherit="yes")]
	public class DashPanelContainer extends SkinnableContainer {

		//----------------------------------------------------------
		//
		//   Static Properties 
		//
		//----------------------------------------------------------

		
		/**
		 * Constant defining the type of change event of adding a DashPanel.
		 */
		public static const PANEL_ADDED:String = "pantastePanelAdded";
		
		/**
		 * Constant defining the type of change event of maximizing a DashPanel.
		 */
		public static const PANEL_MAXIMIZED:String = "pantastePanelMaximized";
		
		/**
		 * Constant defining the type of change event of minimizing a DashPanel.
		 */
		public static const PANEL_MINIMIZED:String = "pantastePanelMinimized";
		
		/**
		 * Constant defining the type of change event of moving a DashPanel.
		 */
		public static const PANEL_MOVED:String = "pantastePanelMoved";
		
		/**
		 * Constant defining the type of change event of removing a DashPanel.
		 */
		public static const PANEL_REMOVED:String = "pantastePanelRemoved";
		
		/**
		 * Constant defining the type of change event of restoring a DashPanel.
		 */
		public static const PANEL_RESTORED:String = "pantastePanelRestored";

		//----------------------------------------------------------
		//
		//   Constructor 
		//
		//----------------------------------------------------------

		
		/**
		 * Constructor.
		 */
		public function DashPanelContainer() {
			super();
			
			/*if (this.name == null || this.name == "")
			 throw new Error("A pantastePanelContainer must define an id name");*/
			
			addEventListener(FlexEvent.PREINITIALIZE, onPreInitialize);
			addEventListener(FlexEvent.INITIALIZE, onInitialize);
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		//	layoutManager = DashLayoutManager.getManager(this);
			
		}


		//----------------------------------------------------------
		//
		//    Public Properties 
		//
		//----------------------------------------------------------
		private var snapToGridModifier:SnapToGridModifier;
		/**
		 * The available height to place the DashPanels.
		 */
		public var availHeight:Number;
		
		/**
		 * The available width to place the DashPanels.
		 */
		public var availWidth:Number;

		//--------------------------------------
		// cascadeSize 
		//--------------------------------------

		
		/**
		 * Vertical and horizontal offset when cascading the DashPanels.
		 */
		private var _cascadeSize:Number = DashConstants.DEFAULT_DASH_SNAP_SIZE;
		
		/**
		 * Vertical and horizontal offset when cascading the DashPanels.
		 */
		[Bindable]
		public function get cascadeSize():Number {
			return _cascadeSize;
		}
		
		public function set cascadeSize(value:Number):void {
			_cascadeSize = value;
		}

		//--------------------------------------
		// dashed 
		//--------------------------------------

		
		/**
		 * Indicates whether the container area is dashed.
		 */
		private var _dashed:Boolean = false;
		
		/**
		 * Indicates whether the container area is dashed.
		 */
		[Bindable]
		public function get dashed():Boolean {
			return _dashed;
		}
		
		public function set dashed(value:Boolean):void {
			if (value) {
				/* _snapped = false; */
			//	layoutManager.tile();
			}
			_dashed = value;
		}

		//--------------------------------------
		// dock 
		//--------------------------------------

		
		/**
		 * Reference to this DashPanelContainer's DashDock bar.
		 * @see com.comtaste.pantaste.components.DashDock
		 */
		private var _dock:DashDock;
		
		/**
		 * Set the dock to use for the container.
		 */
		[Bindable]
		[SkinPart(required='true')]
		public function get dock():DashDock {
			return _dock;
		}
		
		public function set dock(value:DashDock):void {
			_dock = value;
			_dock.container = this;
		}
		
		[SkinPart(required='true')]
		public var grid:Sprite;
		
		/**
		 * Group that contains the actual DashPanels
		 */
		[SkinPart(required='true')]
		public var panels:Group;

		//--------------------------------------
		// showStartButton 
		//--------------------------------------

		
		/**
		 * Vertical and horizontal offset when cascading the DashPanels.
		 */
		private var _showStartButton:Boolean = DashConstants.DEFAULT_SHOW_START_BUTON;
		
		/**
		 * Hide or show the start button.
		 */
		[Bindable]
		public function get showStartButton():Boolean {
			return _showStartButton;
		}
		
		public function set showStartButton(value:Boolean):void {
			_showStartButton = value;
		}

		//--------------------------------------
		// snapSize 
		//--------------------------------------

		
		/**
		 * Side length of each square cell of the snap grid.
		 */
		private var _snapSize:Number = DashConstants.DEFAULT_DASH_CASCADE_SIZE;
		
		/**
		 * Side length of each square cell of the snap grid.
		 */
		[Bindable]
		public function get snapSize():Number {
			return _snapSize;
		}
		
		public function set snapSize(value:Number):void {
			_snapSize = value;
			updateDisplayList(unscaledWidth, unscaledHeight);
		}

		//--------------------------------------
		// snapped 
		//--------------------------------------

		
		/**
		 * Indicates whether there exists a snap grid in the container area.
		 */
		private var _snapped:Boolean = false;
		
		/**
		 * Indicates whether there exists a snap grid in the container area.
		 */
		[Bindable]
		public function get snapped():Boolean {
			return _snapped;
		}
		
		public function set snapped(value:Boolean):void {
			/* if ( value )
			 _dashed = false; */
			_snapped = value;
			updateDisplayList(unscaledWidth, unscaledHeight);
		}

		//----------------------------------------------------------
		//
		//    Protected Properties 
		//
		//----------------------------------------------------------

		
		/**
		 * Reference to this DashPanelContainer's DashLayoutManager.
		 * @see com.comtaste.pantaste.manager.DashLayoutManager
		 */
	//protected var layoutManager:DashLayoutManager;


		//----------------------------------------------------------
		//
		//   Public Functions 
		//
		//----------------------------------------------------------

		public function addPanel(panel:DashPanel):void {
			this.panels.addElement(panel);
		}
		
	
		
		/**
		 * Dispatches the DashPanelContainerEvent related to a change in the content of the DashPanelContainer
		 * @param changeType:String The string specifying the type of change occurred
		 * @see com.comtaste.pantaste.events.DashPanelContainerEvent
		 */
		public function generatepantasteChangeEvent(changeType:String, panel:DashPanel):void {
			dispatchEvent(new DashPanelContainerEvent(DashPanelContainerEvent.pantaste_CHANGED,
													  this, changeType, panel));
		}
		
		public function removePanel(panel:DashPanel):void{
			this.panels.removeElement(panel);
			
		}

		//----------------------------------------------------------
		//
		//   Protected Functions 
		//
		//----------------------------------------------------------

		override protected function partAdded(partName:String, instance:Object) : void {
		//	trace("skinPartAdded: container: " + partName);
			/*if (instance == dock) {
				dock.container = this;
			}*/
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function updateDisplayList(unscaledWidth:Number,
													  unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
		
			
			grid.graphics.clear();
			
			if (snapped) {
				var stepping:int = snapSize;
				var i:int = stepping;
				
				grid.graphics.lineStyle(1, 0xCCCCCC);
				
				while (i < unscaledWidth) {
					grid.graphics.moveTo(i, 0);
					grid.graphics.lineTo(i, unscaledHeight);
					i += stepping;
				}
				
				i = stepping;
				
				while (i < unscaledHeight) {
					grid.graphics.moveTo(0, i);
					grid.graphics.lineTo(unscaledWidth, i);
					i += stepping;
				}
			}
		}

		//----------------------------------------------------------
		//
		//    Private Functions 
		//
		//----------------------------------------------------------

		
		/**
		 * Initialization code for this DashPanelContainer
		 * @param event:FlexEvent the creationComplete FlexEvent
		 */
		private function onCreationComplete(event:FlexEvent):void {

			snapToGridModifier = new SnapToGridModifier();
			snapToGridModifier.enabled = false;
			BindingUtils.bindProperty(snapToGridModifier, 'snapSize', this, 'snapSize');
			BindingUtils.bindProperty(snapToGridModifier, 'enabled', this, 'snapped');
			//addElement(_dock);
			
			if (!snapSize)
				snapSize = DashConstants.DEFAULT_DASH_SNAP_SIZE;
			
			if (!cascadeSize)
				cascadeSize = DashConstants.DEFAULT_DASH_CASCADE_SIZE;
			
			// register restore event for all panel
			var item:Object;
			var panel:DashPanel;
			var numElements:uint = panels.numElements;
			
			for (var i:uint = 0; i < numElements; i++) {
				item = panels.getElementAt(i);
				
				if (item is DashPanel) {
					panel = item as DashPanel;
					panel.addEventListener(DashPanel.RESTORED, restorePanelSize);
				} else
					continue;
			}
			
			panels.addEventListener(ElementExistenceEvent.ELEMENT_ADD, panelAdded);
			panels.addEventListener(ElementExistenceEvent.ELEMENT_REMOVE, panelRemoved);
		}
		
		/**
		 * Initialization code for this DashPanelContainer
		 * @param event:FlexEvent the initialization FlexEvent
		 */
		private function onInitialize(event:FlexEvent):void {
			removeEventListener(FlexEvent.INITIALIZE, onInitialize);
			
		}
		
		/**
		 * Initialization code for children of this DashPanelContainer
		 * @param event:FlexEvent the initialization FlexEvent
		 */
		private function onPreInitialize(event:FlexEvent):void {
			removeEventListener(FlexEvent.PREINITIALIZE, onPreInitialize);
			setStyle('skinClass', com.comtaste.pantaste.components.skins.DashPanelContainerSkin);
			//MoveBehaviour.proxyLayer = this;
			
		}
		
		/**
		 * Handler of the addition of a DashPanel event
		 * @param evt:ChildExistenceChangedEvent the event related to the addition of a DashPanel
		 */
		private function panelAdded(event:ElementExistenceEvent):void {
			if (event.element is DashPanel) {
				var panel:DashPanel = DashPanel(event.element);
				panel.moveBehaviour.addModifier(snapToGridModifier);
				panel.resizeBehaviour.addModifier(snapToGridModifier);
				generatepantasteChangeEvent(DashPanelContainer.PANEL_ADDED,
					panel);
			}
		}
		
		/**
		 * Handler of the removing of a DashPanel event
		 * @param evt:ChildExistenceChangedEvent the event related to the removing of a DashPanel
		 */
		private function panelRemoved(event:ElementExistenceEvent):void {
			if (event.element is DashPanel) {
				var panel:DashPanel = DashPanel(event.element);
				panel.moveBehaviour.removeModifier(snapToGridModifier);
				panel.resizeBehaviour.removeModifier(snapToGridModifier);
				generatepantasteChangeEvent(DashPanelContainer.PANEL_REMOVED,
					panel);
			}
			
			
		}
		
		/**
		 * Handler of the restoring of a DashPanel event
		 * @param evt:Event the event related to the restoring of a DashPanel
		 */
		private function restorePanelSize(event:Event):void {
			var panel:DashPanel = event.target as DashPanel;
			
			/*setTimeout(function():void {
					layoutManager.applyEffect(arguments[0], arguments[1], arguments[2],
											  arguments[3], arguments[4]);
				}, 1, panel, panel.restoredX, panel.restoredY, panel.restoredWidth,
											  panel.restoredHeight);*/
		}
	}
}