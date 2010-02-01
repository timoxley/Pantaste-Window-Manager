/*
 * 
 * Rappresenta l'application bar del dash container
 * 
 */
package com.comtaste.pantaste.components
{
	import com.comtaste.pantaste.common.DashConstants;
	import com.comtaste.pantaste.components.skins.DashDockSkin;
	import com.comtaste.pantaste.events.DashPanelEvent;
	import com.comtaste.pantaste.manager.DashLayoutManager;
	import com.comtaste.pantaste.utilities.DashPanelAspectVO;
	import com.comtaste.pantaste.utilities.StoredSessionVO;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	import flash.utils.Dictionary;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Menu;
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	import mx.events.MenuEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.SkinnableContainer;

	/**
	 * A DashDock object is the application bar of the related DashPanelContainer.
	 * <p>
	 * 		The DashPanelContainer can show several DashPanels. However, if minimized, 
	 * 		they can be resumed interacting with the DashContainer's DashDock.
	 * 		Each minimized DashPanel is represented on the DashDock as a Button.
	 * </p>
	 * @see com.comtaste.pantaste.components.DashPanel
	 * @see com.comtaste.pantaste.components.DashPanelContainer
	 */ 
	public class DashDock extends SkinnableContainer
	{
		/**
		 * The DashPanelContainer which this DashDock refers to.
		 */ 
		public var container:DashPanelContainer;
		
		/**
		 * Data structure to keep track of the minimized DashPanels.
		 * <p>
		 * 	Each minimized DashPanel is indexed by its representation on the DashDock, i.e. <code>dockedPanel</code> contains pairs
		 * <blockquote>
		 * 		Button : DashPanel
		 * </blockquote>
		 * which maps the Button components to the DashPanels
		 * </p>
		 * @see mx.controls.Button 
		 * @see com.comtaste.pantaste.components.DashPanel
		 */ 
		private var minimizedDashPanels:Dictionary;
		
		/**
		 * Horizontal box containing the Buttons representing the minimized DashPanels.
		 */ 
		[SkinPart(required='true')]
		public var minimisedPanelsBar:Group;
		
		/**
		 * Start button
		 * 
		 * <p>
		 * 	The start button provides functionalities such as saving the status of the DashPanelContainer. 
		 * </p>
		 */
		[SkinPart(required='false')]
		public var startButton:Button;
		
		/**
		 * Start menu. It appears once pressed the Start Button.
		 */ 
		[SkinPart(required='false')]
		public var menu:Menu;
		

		
		/**
		 * Shared object to save the status of the opened DashPanels in the DashPanelContainer.
		 * <p>
		 * The user can take advantage of this object to save his/her current configuration and retrieve it later.
		 * </p>
		 * @see flash.net.SharedObject
		 * 
		 */ 
		private var remeberSO:SharedObject;
		
		/**
		 * Menu entries of the minimized DashPanels.
		 * @see #menu
		 * @see #workspaceMenu 
		 */ 
		[Bindable]
		private var minimizedMenuPanels:Array = [];
		
		/**
		 * Menu entries of the started DashPanels.
		 * @see #menu
		 * @see #workspaceMenu 
		 */ 
		[Bindable]
		private var startedMenuPanels:Array = [];
		
		/**
		 * Menu entries of the not started DashPanels.
		 * @see #menu
		 * @see #workspaceMenu
		 */ 
		[Bindable]
		private var notStartedMenuPanels:Array = [];
		
		/**
		 * Main entries of the start menu.
		 * @see #menu 
		 */ 
		[Bindable]
		private var workspaceMenu:Array = [];
		
		/**
		 * Value object containing the status of the stored session.
		 */ 
		private var storedSession:StoredSessionVO;
		
		/**
		 * Dialog that prompts the user for the name of the session he/she is going to save.
		 * @see com.comtaste.pantaste.components.SaveWorkspacePopup
		 */ 
		private var savePop:SaveWorkspacePopup;
		
		/**
		 * Default menuItem height.
		 * @see com.comtaste.pantaste.common.DashConstants
		 */ 
		private var defaultItemHeight:Number = DashConstants.DEFAULT_MENUITEM_HEIGHT;
        
        /**
		 * Default menuItem height when the menuitem has an icon.
		 * @see com.comtaste.pantaste.common.DashConstants
		 */ 
		private var defaultIconItemHeight:Number = DashConstants.DEFAULT_ICON_MENUITEM_HEIGHT;
        
        // The Array data provider
        /**
        * Entries of the start menu.
        * @see #menu 
        */
        [Bindable] 
        public var menuData:Array = [
            {label: "Minimized panels", children: minimizedMenuPanels},//0
            {label: "Started panels", children: startedMenuPanels},//1
            {label: "Not Started", children: notStartedMenuPanels},//2
            {type: "separator"},//3
            {label: "Workspace", children://4 
            	[   {label: "Save Workspace"},
            		{label: "Load Workspace", children: workspaceMenu, enabled: workspaceMenu.length!=0},
            	]
            	}
            	
            ];

		/**
		 * Constructor.
		 * @param container:DashPanelContainer The DashPanelContainer this DashDock refers to.
		 */ 
		public function DashDock()
		{
			super();
			this.addEventListener(FlexEvent.PREINITIALIZE, onPreInitialize);
			
						
			/*
			minimisedPanelsBar = new HGroup();
			minimisedPanelsBar.x = 10;
			addElement( minimisedPanelsBar )*/;
		/*	
			startButton = new Button( );
			startButton.addEventListener( MouseEvent.CLICK , onStartClick );
			startButton.label = "Start";
			minimisedPanelsBar.addElement( startButton );*/
			
			
			
			minimizedDashPanels = new Dictionary();
			/*
			menu = Menu.createMenu( this, null );
			
			
			menu.variableRowHeight=true;
			//menu.rowHeight = DashConstants.DEFAULT_MENUITEM_HEIGHT;
			menu.itemRenderer = new ClassFactory(DashDockMenuItemRenderer);*/
			
			
			remeberSO = SharedObject.getLocal("comComtastepantaste");
			storedSession = new StoredSessionVO( );
			if ( remeberSO && remeberSO.data && remeberSO.data["storedSession"] )
			{
				storedSession = remeberSO.data["storedSession"] as StoredSessionVO;
				createMenuLoadWorkspace();
			}
		}
		
		protected function onPreInitialize(event:FlexEvent):void {
			removeEventListener(FlexEvent.PREINITIALIZE, onPreInitialize);
			setStyle('skinClass', com.comtaste.pantaste.components.skins.DashDockSkin);
		}
		
		override protected function partAdded(partName:String, instance:Object) : void {
			trace("skinPartAdded: dock: " + partName);
			if (instance == menu) {
				menu.addEventListener( MenuEvent.ITEM_CLICK, onMenuClick );
				menu.addEventListener( MenuEvent.MENU_SHOW, onMenuShow);
			} else if (instance == startButton) {
				startButton.addEventListener( MouseEvent.CLICK , onStartClick );
				BindingUtils.bindProperty( startButton, "visible", container, "showStartButton" );
				BindingUtils.bindProperty( startButton, "includeInLayout", container, "showStartButton" );
			}
		}
		
		/**
		 * Handler of the click event over the Button representing a minimized DashPanel.
		 * <p>
		 * 		The DashPanel corresponding to the clicked button is retrieved, then the DashPanelEvent.RESTORE event is dispatched. 
		 * </p>
		 * @param event:MouseEvent the MouseEvent on the minimized DashPanel. 
		 * @see flash.events.MouseEvent
		 * @see com.comtaste.pantaste.events.DashPanelEvent
		 */ 
		protected function restore( event:MouseEvent ) : void
		{
			//( dockedPanel[ event.target ] as DashPanel ).maximizeRestore( );
			var panel:DashPanel = minimizedDashPanels[ event.target ] as DashPanel;
			
			var restoredEvent:DashPanelEvent = new DashPanelEvent( DashPanelEvent.RESTORE, panel );
				panel.dispatchEvent( restoredEvent );
			
			/* panel.status = DashPanel.RESTORED; */
			
			/* dockedPanel[ theButton ] = null;
			hbox.removeChild( event.target as Button ); */
		}
		
		/**
		 * Adds a DashPanel to the DashDock.
		 * <p>
		 * 		Whenever a panel is minimized, a button is added to <code>this.hbox</code>. 
		 * 		Furthermore it becomes the DashPanel's key in the <code>dockedPanel</code> dictionary.
		 * </p>
		 * @param panel:DashPanel The DashPanel to add.
		 */ 
		public function addPanel( panel:DashPanel ) : void
		{
			for ( var key:Object in minimizedDashPanels )
			{
				if ( minimizedDashPanels[ key ] == panel )
				{
					return;
				}
			}
			
			var theButton:Button = new Button();
				theButton.height = 25;
				theButton.width = 140;
			theButton.styleName = "dockedButton";
			theButton.label = panel.title;
			minimizedDashPanels[ theButton ] = panel;
			theButton.addEventListener( MouseEvent.CLICK, restore );
			minimisedPanelsBar.addElement( theButton );
		}
		
		/**
		 * Removes a DashPanel from the DashDock.
		 * <p>
		 * 	Whenever a Panel has to be removed from the DashPanelContainer, it must be removed from the <code>dockedPanel</code> dictionary.
		 * </p>
		 * @param panel:DashPanel The DashPanel to remove.
		 */ 
		public function removePanel( panel:DashPanel ) : void
		{
			for ( var key:Object in minimizedDashPanels )
			{
				if ( minimizedDashPanels[ key ] == panel )
				{
					minimisedPanelsBar.removeElement( key as Button );
					delete minimizedDashPanels[ key ];
				}
			}
		}
		/**
		 * Handler of the click event over the startButton Button.
		 * @param event:MouseEvent The MouseEvent this method handles.
		 * @see #startButton
		 */ 
		protected function onStartClick( event:MouseEvent ) : void
		{
			createMenuPanel();
			menu.show();
		}
		/**
		 * Handler to the menu events on the menu Menu.
		 * 
		 * <p>
		 * 	Depending on the chosen item, one can restore a panel, save the current workspace, 
		 * 	or load a previously saved workspace.
		 * </p>
		 * @param event:MouseEvent The MenuEvent to handle.
		 * @see #menu
		 */ 
		protected function onMenuClick( event:MenuEvent ) : void
		{
			var panel:DashPanel = event.item.panel;
			if ( panel )
			{
				panel.dispatchEvent( new DashPanelEvent( DashPanelEvent.RESTORE, panel ));
				DashLayoutManager.getManager( container ).bringToFront( event.item.panel );
			}
			
			if ( event.item.label == "Save Workspace" )
			{
				savePop = new SaveWorkspacePopup( );
				PopUpManager.addPopUp( savePop, FlexGlobals.topLevelApplication as DisplayObject );
				PopUpManager.centerPopUp( savePop );
				savePop.saveBtn.addEventListener( MouseEvent.CLICK, onSaveClick );
				savePop.cancelBtn.addEventListener( MouseEvent.CLICK, onSaveClick );
			}
			
			if ( event.item.storedAspect )
			{
				setSavedAspect( event.item.label );
			}
			
		}
		/**
		 * @private
		 * Handles the different row heights for each submenu, when it is popped up.
		 * @param me:MenuEvent The related MenuEvent.
		 */ 
		protected function onMenuShow(me:MenuEvent):void
		{
			
			if(me.menu!=menu)
			{
				if(me.menu.dataProvider && 
					me.menu.dataProvider.source != menuData[4].children &&
					me.menu.dataProvider.source != workspaceMenu
				  )
				{	
					me.menu.rowHeight = defaultIconItemHeight;
				}
				else
				{
					me.menu.rowHeight = defaultItemHeight;
				}
				me.menu.validateNow();
			}
		}
		
		/**
		 * Loads and resumes a previously saved status of the DashContainer.
		 *
		 * @param chiave:String the name of the previously saved status.
		 * @see #savePop
		 */ 
		protected function setSavedAspect( chiave:String ) : void
		{
			// aggiorna stato e posizione
           	var detail:DashPanelAspectVO;
       		var panelRef:DashPanel;
       		
       		var lm:DashLayoutManager = DashLayoutManager.getManager( container );
       		
       		var maxPanel:DashPanel;
       		
           	for each( detail in storedSession.storedAspects[ chiave ] )
           	{
           
           		for ( var i:int = 0; i < container.numChildren; i++ )
           		{
           			if ( container.getChildAt( i ).name == detail.name )
           				panelRef = container.getChildAt( i ) as DashPanel;
           		}
           		
           		if (panelRef )
           		{	
	           		lm.panelList[ detail.dashOrder ] = panelRef;
	           		
	           		container.setElementIndex( panelRef, detail.dashOrder );
	           		
	           		panelRef.restoredHeight = detail.restoredHeight;
	           		panelRef.restoredWidth = detail.restoredWidth;
	           		panelRef.restoredX = detail.restoredX;
	           		panelRef.restoredY = detail.restoredY;
	           			
	           		panelRef.alwaysInFront = detail.alwaysInFront;
	           		
	           		if ( detail.status == DashPanel.MINIMIZED )
	           		{
	           			if ( panelRef.status != DashPanel.MINIMIZED )
	           			{
		           			var minimizeEvent:DashPanelEvent = new DashPanelEvent( DashPanelEvent.MINIMIZE, panelRef );
		           			panelRef.dispatchEvent( minimizeEvent );
	           			}
	           		}
	           		else if ( detail.status == DashPanel.RESTORED )
	           		{
	           			var restoreEvent:DashPanelEvent = new DashPanelEvent( DashPanelEvent.RESTORE, panelRef );
	           			panelRef.dispatchEvent( restoreEvent );
	           			
	           			panelRef.status = detail.status;
	           		}
           		}
           	}
           	
           	container.dashed = storedSession.containerConfiguration[ chiave + "dashed" ];
           	container.snapped = storedSession.containerConfiguration[ chiave + "snapped" ];
           	container.snapSize = storedSession.containerConfiguration[ chiave + "snapSize" ];
		}
		
		/**
		 * Event handler for the buttons in the savePop dialog.
		 * <p>
		 * 	This method saves the current workspace configuration, saving the opened windows and storing them in the storedSession instance variable.
		 * </p> 
		 * @see #savePop
		 * @see #setSavedAspect
		 */ 
		protected function onSaveClick( event:MouseEvent ) : void
		{
			if ( event.target === savePop.saveBtn )
			{
				storedSession.storedAspects[ savePop.workspaceName.text ] = DashLayoutManager.getManagerPanelsAspectDetails( container.id );
				storedSession.containerConfiguration[ savePop.workspaceName.text + "dashed" ] = container.dashed;
				storedSession.containerConfiguration[ savePop.workspaceName.text + "snapped" ] = container.snapped;
				storedSession.containerConfiguration[ savePop.workspaceName.text + "snapSize" ] = container.snapSize;
				remeberSO.data["storedSession"] = storedSession;
				var status:String = remeberSO.flush( );
				createMenuLoadWorkspace( )
			}
			
			PopUpManager.removePopUp( savePop );
		}
		/**
		 * Populates the menu related to the minimized and started panels of the current session.
		 * @see #minimizedMenuPanels
		 * @see #startedMenuPanels
		 * @see #menu
		 * @see #menuData
		 */ 
		protected function createMenuPanel( ) : void
		{
			var iTot:int = minimizedMenuPanels.length
			for ( var i:int = 0; i < iTot; i++ )
			{
				minimizedMenuPanels.pop();
			}
			menuData[0].enabled = false;
			for ( var key:Object in minimizedDashPanels )
			{
				minimizedMenuPanels.push( { 
											label : minimizedDashPanels[ key ].title, 
											icon : minimizedDashPanels[ key ].icon, 
											panel: minimizedDashPanels[ key ]
											 
											
										} );
				menuData[0].enabled = true;
			}
			
			
			var xTot:int = startedMenuPanels.length;
			for ( var x:int = 0; x < xTot; x++ )
			{
				startedMenuPanels.pop();
			}
			
			var startedPanels:Array = DashLayoutManager.getManager( container ).getOpenedPanelList();
			menuData[1].enabled = false;
			for ( var y:int = 0; y < startedPanels.length; y++ )
			{
				menuData[1].enabled = true;
				startedMenuPanels.push( {label : startedPanels[ y ].title,icon  : startedPanels[ y ].icon,panel : startedPanels[ y ]} );
			}
			//menu.rowHeight = defaultIconItemHeight;
			menu.dataProvider = menuData;
		}
		/**
		 * Populates the menu related (<code>workspaceMenu</code>) to the saved and loadable sessions.
		 * @see #workspaceMenu
		 * @see #menu
		 * @see #menuData
		 */ 		
		protected function createMenuLoadWorkspace( ) : void
		{
			var xTot:int = workspaceMenu.length;
			for ( var x:int = 0; x < xTot; x++ )
			{
				workspaceMenu.pop();
			}
			menuData[4].children[1].enabled=false;
			for ( var key:Object in storedSession.storedAspects )
			{
				menuData[4].children[1].enabled=true;
				workspaceMenu.push( { label : key, storedAspect : storedSession.storedAspects[ key ] } );
			}
			menu.dataProvider = menuData;
		}
	}
}