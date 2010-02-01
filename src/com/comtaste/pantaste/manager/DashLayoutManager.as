package com.comtaste.pantaste.manager {
	import com.comtaste.pantaste.components.*;
	import com.comtaste.pantaste.events.DashManagerEvent;
	import com.comtaste.pantaste.events.DashPanelEvent;
	import com.comtaste.pantaste.utilities.DashPanelAspectVO;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import mx.controls.Image;
	import mx.core.Application;
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.effects.Move;
	import mx.effects.Parallel;
	import mx.effects.Resize;
	import mx.events.FlexEvent;
	import mx.events.IndexChangedEvent;
	import mx.events.ResizeEvent;
	import mx.graphics.ImageSnapshot;
	import mx.managers.ISystemManager;
	import mx.managers.PopUpManager;
	
	import spark.events.ElementExistenceEvent;
	import spark.skins.SparkSkin;
	
	
	/**
	 * A DashLayoutManager manages the possible action of resizing, moving and minimizing in a DashPanelContainer object.
	 * <p>
	 * 	A DashLayoutManager is a multiton that mantains a dictionary of pairs &lt;Number:DashLayoutManager&gt; where
	 * 	the key is the id of the DashPanelContainer whose layout is managed by the corresponding DashLayoutManager object.
	 * </p>
	 *
	 */
	public class DashLayoutManager extends EventDispatcher {
		
		//----------------------------------------------------------
		//
		//   Static Properties 
		//
		//----------------------------------------------------------
		
		/**
		 * Mapping of DashPanelContainers to their relative DashLayoutManagers.
		 */
		private static var multiton:Dictionary = new Dictionary();
		
		//----------------------------------------------------------
		//
		//   Static Functions 
		//
		//----------------------------------------------------------
		
		/**
		 * Returns the DashLayoutManager that manages the Container identified by instanceKey.
		 * @return DashLayoutManager - the instance of DashLayoutManager that manages the Container identified by instanceKey.
		 */
		public static function getManager(instance:DashPanelContainer):DashLayoutManager {
			/*if (multiton.getValue(instanceKey) == null && instanceKey != null) {
			   //multiton.put( instanceKey, new DashLayoutManager( Application.application as DashPanelContainer, instanceKey ) );
			 }*/
			//return multiton.getValue(instanceKey) as DashLayoutManager;
			if (!multiton.hasOwnProperty(instance)) {
				multiton[instance] = new DashLayoutManager(instance);
			}
			return DashLayoutManager(multiton[instance]);
		}
		
		/**
		 * Gets the details of the DashPanel of the session of the container identified by <code>instanceKey</code>
		 * @param instanceKey:* Key of the instance.
		 * @return Array array of DashPanelAspectVO.
		 *
		 */
		public static function getManagerPanelsAspectDetails(instanceKey:*):Array {
			var panelDetails:Array;
			var lm:DashLayoutManager = DashLayoutManager.getManager(instanceKey);
			
			if (lm != null) {
				panelDetails = new Array();
				
				var detail:DashPanelAspectVO
				var counter:int = -1;
				var tPanel:DashPanel;
				
				for each (tPanel in lm.panelList) {
					counter++;
					
					detail = new DashPanelAspectVO();
					//detail.id = tPanel.id;
					detail.name = tPanel.name;
					detail.uid = tPanel.uid; // impostare il valore corretto come UID
					
					detail.dashOrder = counter;
					detail.status = tPanel.status;
					detail.alwaysInFront = tPanel.alwaysInFront;
					
					if (tPanel.status != DashPanel.MINIMIZED) {
						detail.restoredX = tPanel.x;
						detail.restoredY = tPanel.y;
						detail.restoredWidth = tPanel.width;
						detail.restoredHeight = tPanel.height;
					} else {
						detail.restoredX = tPanel.restoredX;
						detail.restoredY = tPanel.restoredY;
						detail.restoredWidth = tPanel.restoredWidth;
						detail.restoredHeight = tPanel.restoredHeight;
					}
					
					detail.visible = tPanel.visible;
					
					// add to panels  aspect list
					panelDetails.push(detail);
				}
			}
			return panelDetails;
		}
		
		//----------------------------------------------------------
		//
		//   Constructor 
		//
		//----------------------------------------------------------
		
		/**
		 * Constructor.
		 * <p>
		 * </p>
		 * @param container:DashPanelContainer The container to manage
		 * @param instanceKey:* The key associated to this container.
		 */
		public function DashLayoutManager(container:DashPanelContainer) {
			
			this.container = container;
			container.addEventListener(FlexEvent.CREATION_COMPLETE, onContainerComplete)
			
			container.addEventListener(ResizeEvent.RESIZE, onContainerResize);
			container.addEventListener(FlexEvent.SHOW, onContainerResize);
			container.addEventListener(IndexChangedEvent.CHILD_INDEX_CHANGE, onChildIndexChange);
		
			//getManager(container);
			//container.horizontalScrollPolicy = ScrollPolicy.OFF;
			//container.verticalScrollPolicy = ScrollPolicy.OFF;
			//multiton.put(container, this);
		
			//	systemManager.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown,   true );
			//	systemManager.addEventListener( KeyboardEvent.KEY_UP,   onKeyUp,     true );
			//systemManager.addEventListener( FocusEvent.FOCUS_OUT,   onmouseee,     true );
		
		}
		
		//----------------------------------------------------------
		//
		//    Public Properties 
		//
		//----------------------------------------------------------
		
		/**
		 * The managed DashPanelContainer.
		 */
		public var container:DashPanelContainer;
		
		/**
		 * Dictionary of the icon-DashPanel association.
		 */
		public var icons:Dictionary = new Dictionary();
		
		/**
		 *  The managed panels stack.
		 */
		[Bindable]
		public var panelList:Array = new Array();
		
		//----------------------------------------------------------
		//
		//    Protected Properties 
		//
		//----------------------------------------------------------
		
		/**
		 *
		 */
		protected var candidatePanel:DashPanel;
		
		/**
		 * The DashPanelHandler.
		 */
		protected var handler:DashPanelHandler;
		
		/**
		 * Indicates whether the handler has been moved (true) or not (false).
		 */
		protected var handlerMoved:Boolean = false;
		
		/**
		 * Indicates whether the handler has been resized (true) or not (false).
		 */
		protected var handlerResized:Boolean = false;
		
		/**
		 * The currently selected panel.
		 */
		protected var selectedPanel:DashPanel;
		
		/**
		 *
		 */
		protected var stopChIndex:Boolean = false;
		
		//----------------------------------------------------------
		//
		//   Private Properties 
		//
		//----------------------------------------------------------
		
		/**
		 * Indicates whether the ctrl keyboard key is pressed (true) or not (false).
		 */
		private var ctrlKeyPressed:Boolean = false;
		
		/**
		 * Indicates whether the panel is minimizing (true) or not (false).
		 */
		private var minimizing:Boolean = false;
		
		/**
		 *
		 */
		private var multiParallel:Parallel = new Parallel();
		
		/**
		 * Reference to the PanSwitcher for the container managed
		 */
		private var panSwitcher:PanSwitcher;
		
		/**
		 *
		 */
		private var singleParallel:Parallel = new Parallel();
		
		/**
		 * A systemManager reference
		 **/
		private var systemManager:ISystemManager;
		
		//----------------------------------------------------------
		//
		//   Public Functions 
		//
		//----------------------------------------------------------
		
		/**
		 * Plays the specified effects over the specified items.
		 * @param panel:DashPanel The DashPanel to which apply the parallel effect.
		 * @param xTo:Number The ending x coordinate for the move effect.
		 * @param yTo:Number The ending y coordinate for the move effect.
		 * @param widthTo:Number The ending width of the resize effect.
		 * @param heightTo:Number The ending height of the resize effect.
		 * @param effectItems:Array The set of effects that must be played on the panel
		 */
		public function applyEffect(panel:DashPanel, xTo:Number, yTo:Number, widthTo:Number,
									heightTo:Number, effectItems:Array=null):void {
			if (effectItems) {
				multiParallel.stop();
				multiParallel = new Parallel();
				
				for (var i:int = 0; i < effectItems.length; i++) {
					constructEffect(effectItems[i]["panel"], effectItems[i]["xTo"],
									effectItems[i]["yTo"], effectItems[i]["widthTo"],
									effectItems[i]["heightTo"], multiParallel)
					multiParallel.play();
				}
			} else {
				singleParallel = new Parallel();
				constructEffect(panel, xTo, yTo, widthTo, heightTo, singleParallel)
				singleParallel.play();
			}
		}
		
		/**
		 * Brings to front a component.
		 * @param element:UIComponent The component to be brought to front.
		 */
		public function bringToFront(element:UIComponent):void {
			trace("Bring to front:" + element);
			if (element && container.panels.contains(element)) {
				if (container.panels.getElementIndex(element) !=  container.numChildren - 1) {
					container.panels.setElementIndex(element, container.numChildren - 1);
				}
				
				//container.panels.
				/*if (element is DashPanel) {
					if (icons[element])
						bringToFront(icons[element]);
				}*/
			}
		}
		
		/**
		 *  Cascades all managed panel from top left to bottom right
		 *
		 */
		public function cascade():void {
			if (container.snapped || container.dashed)
				return;
			
			var openPanelList:Array = getOpenedPanelList();
			
			for (var i:int = 0; i < openPanelList.length; i++) {
				var panel:DashPanel = openPanelList[i] as DashPanel;
				panel.x = 0;
				panel.y = 0;
				
				panel.x += container.cascadeSize * i;
				panel.y += container.cascadeSize * i;
				
				bringToFront(panel);
				setIconPostion(panel);
			}
		}
		
		/**
		 * Returns a list of open panels that always stay in front
		 *
		 * @return Array list of open panels that always stay in front
		 */
		public function getAlwaysInFrontPanelList():Array {
			var array:Array = [];
			
			for (var i:int = 0; i < panelList.length; i++) {
				if (DashPanel(panelList[i]).alwaysInFront) {
					array.push(panelList[i]);
				}
			}
			return array;
		}
		
		/**
		 * Returns the list of currently open panels.
		 *
		 * @return Array list of the open panels
		 */
		public function getOpenedPanelList():Array {
			var array:Array = [];
			
			for (var i:int = 0; i < panelList.length; i++) {
				if (DashPanel(panelList[i]).status != DashPanel.MINIMIZED &&
					DashPanel(panelList[i]).visible) {
					array.push(panelList[i]);
				}
			}
			return array;
		}
		
		/**
		 *  Tiles the window across the screen
		 *
		 *  <p>By default, windows will be tiled to all the same size and use only the space they can accomodate.
		 *  If you set fillAvailableSpace = true, tile will use all the space available to tile the windows with
		 *  the windows being arranged by varying heights and widths.
		 *  </p>
		 *
		 *  @param fillAvailableSpace:Boolean Variable to determine whether to use the fill the entire available screen
		 *
		 */
		public function tile(pad:Number=10):void {
			if (container.snapped)
				return;
			
			var openPanelList:Array = getOpenedPanelList();
			var numPanels:int = openPanelList.length;
			
			if (numPanels >= 1) {
				var sqrt:int = Math.round(Math.sqrt(numPanels));
				var numCols:int = Math.ceil(numPanels / sqrt);
				var numRows:int = Math.ceil(numPanels / numCols);
				var col:int = 0;
				var row:int = 0;
				var availWidth:Number = this.container.width;
				var availHeight:Number = this.container.height - 30;
				
				var targetWidth:Number = availWidth / numCols - ((pad * (numCols + 1)) / numCols);
				var targetHeight:Number = availHeight / numRows - ((pad * (numRows + 1)) / numRows);
				
				var effectItems:Array = [];
				
				for (var i:int = 0; i < openPanelList.length; i++) {
					var win:DashPanel = openPanelList[i];
					
					if (win.status == DashPanel.MAXIMIZED) {
						win.x = 0;
						win.y = 0;
						win.width = container.width;
						win.height = container.height;
						return;
					}
					
					/* win.width = targetWidth;
					 win.height = targetHeight; */
					
					if (i % numCols == 0 && i > 0) {
						row++;
						col = 0;
					} else if (i > 0) {
						col++;
					}
					
					var targetX:int;
					var targetY:int;
					
					targetX = col * targetWidth + pad
					targetY = row * targetHeight + pad
					
					//pushing out by pad
					if (col > 0)
						targetX += pad * col;
					
					if (row > 0)
						targetY += pad * row;
					
					setIconPostion(win);
					
					var effectItem:Object = new Object();
					effectItem["panel"] = win;
					effectItem["widthTo"] = targetWidth;
					effectItem["heightTo"] = targetHeight;
					effectItem["xTo"] = targetX;
					effectItem["yTo"] = targetY;
					effectItems.push(effectItem);
					
				}
				
				applyEffect(win, targetX, targetY, targetWidth, targetHeight, effectItems);
				
				/* 				for(var i:int = 0; i < openPanelList.length; i++)
				   {
				   var win:DashPanel = openPanelList[i] as DashPanel;
				   if ( win.status == DashPanel.MAXIMIZED )
				   {
				   var maxEvent:DashPanelEvent = new DashPanelEvent( DashPanelEvent.MAXIMIZE, win );
				   win.dispatchEvent( maxEvent );
				   return;
				   }
				 } */
			}
		}
		
		//----------------------------------------------------------
		//
		//   Protected Functions 
		//
		//----------------------------------------------------------
		
		/**
		 * Executed whenever a user begins to move or resize a panel.
		 * <p>
		 * 	When a move or resize action has been taken, the handler - already visible although with no color -
		 *  is displayed to give an hint of the effect of the action, therefore appearing like a copy over the
		 *  DashPanel the user is modifying.
		 * </p>
		 * @param event:MouseEvent the related MouseEvent.MOUSE_OVER type event
		 */
		protected function activateHandler(event:MouseEvent):void {
			container.stage.addEventListener(MouseEvent.MOUSE_UP, finishWork);
			handler.removeEventListener(MouseEvent.MOUSE_OVER, activateHandler);
			handler.setStyle("backgroundColor", 0x000000);
			container.mouseChildren = false
			var imageSnap:ImageSnapshot = ImageSnapshot.captureImage(selectedPanel);
			var imageByteArray:ByteArray = imageSnap.data as ByteArray;
			
			container.mouseChildren = false;
			
			handler.setSnapshot(imageByteArray);
			
			handler.alpha = .3;
			handler.x = selectedPanel.x;
			handler.y = selectedPanel.y;
			handler.height = selectedPanel.height;
			handler.width = selectedPanel.width;
			bringToFront(selectedPanel);
			
			if (icons[selectedPanel])
				bringToFront(icons[selectedPanel]);
			
			bringToFront(handler);
		}
		
		/**
		 * Activates the PanSwitcher.
		 * @see com.comtaste.pantaste.components.PanSwitcher
		 */
		protected function activatePanSwitcher():void {
			Application.application.setStyle("modalTransparency", 0);
			
			if (!panSwitcher) {
				panSwitcher =
					PopUpManager.createPopUp(DisplayObject(Application.application), PanSwitcher,
														   true) as PanSwitcher;
			}
			var imageSnap:ImageSnapshot;
			var imageByteArray:ByteArray;
			
			for (var i:int; i < panelList.length; i++) {
				if (panelList[i].visible ||
					(!panelList[i].visible && panelList[i].status == DashPanel.MINIMIZED)) {
					if (icons[panelList[i]]) {
						imageSnap = ImageSnapshot.captureImage(icons[panelList[i]]);
						imageByteArray = imageSnap.data as ByteArray;
						
						panSwitcher.addPanelSnaphshot(imageByteArray, panelList[i].title, false);
					} else {
						imageSnap = ImageSnapshot.captureImage(panelList[i]);
						imageByteArray = imageSnap.data as ByteArray;
						
						panSwitcher.addPanelSnaphshot(imageByteArray, panelList[i].title);
					}
				}
			}
		}
		
		/**
		 * Adds the DashPanelHandler.
		 * @see com.comtaste.pantaste.components.DashLayoutHandler
		 */
		protected function addHandler():void {
			if (!handler) {
				handler = new DashPanelHandler();
				handler.visible = false;
				SparkSkin(container.skin).addElement(handler);
			}
			
			handler.addEventListener(DashManagerEvent.PANEL_HANDLER_MOVING, applyConstraintOnMove);
			handler.addEventListener(DashManagerEvent.PANEL_HANDLER_RESIZING,
									 applyConstraintOnResize);
			handler.addEventListener(MouseEvent.MOUSE_OVER, activateHandler);
			/* handler.addEventListener( MouseEvent.MOUSE_OUT, destroyHandler ); */
			handler.addEventListener(MouseEvent.MOUSE_UP, destroyHandler);
			bringToFront(handler);
		}
		
		/**
		 *  @private
		 *  Apply constraint after a dashPanelEvent to respect panel parameters
		 */
		protected function applyConstraint(moved:Boolean=false, resized:Boolean=false):void {
			if (container.dashed && !handler.resizer) {
				if (candidatePanel == null)
					return;
				
				candidatePanel.filters = [];
				
				var selectedPanelIndex:int = panelList.indexOf(selectedPanel);
				var candidatePanelIndex:int = panelList.indexOf(candidatePanel);
				
				panelList.splice(selectedPanelIndex, 1);
				
				var firstPanels:Array = panelList.slice(0, candidatePanelIndex);
				var lastPanels:Array = panelList.slice(candidatePanelIndex);
				
				firstPanels.push(selectedPanel);
				panelList = firstPanels.concat(lastPanels);
				
				tile();
				
				candidatePanel = null;
			} else if (container.snapped) {
				if (moved) {
					selectedPanel.y =
						Math.round(handler.y / container.snapSize) * container.snapSize;
					selectedPanel.x =
						Math.round(handler.x / container.snapSize) * container.snapSize;
				} else if (resized) {
					var desDiffHeight:Number =
						(Math.round(handler.y / container.snapSize) * container.snapSize) - handler.
						y;
					selectedPanel.height =
						(Math.round(handler.height / container.snapSize) * container.snapSize) +
						desDiffHeight;
					
					var desDiffWidth:Number =
						(Math.round(handler.x / container.snapSize) * container.snapSize) - handler.
						x;
					selectedPanel.width =
						(Math.round(handler.width / container.snapSize) * container.snapSize) +
						desDiffWidth;
				}
			} else {
				bringToFront(selectedPanel);
				selectedPanel.x = handler.x;
				selectedPanel.y = handler.y;
				
				if (handler.resizer) {
					selectedPanel.width = handler.width;
					selectedPanel.height = handler.height;
				}
			}
			
			setIconPostion(selectedPanel);
			
			// generate dash container event
			this.container.generatepantasteChangeEvent(DashPanelContainer.PANEL_MOVED,
													   selectedPanel);
		}
		
		/**
		 *  @private
		 *  Apply constraint after a dashPanelEvent to respect panel parameters
		 */
		protected function applyConstraintOnMove(event:DashManagerEvent):void {
			if (container.dashed) {
				var openPanelList:Array = getOpenedPanelList();
				candidatePanel = null;
				
				for (var i:int = 0; i < openPanelList.length; i++) {
					if ((event.handler as DashPanelHandler).hitTestPoint(container.x +
						(openPanelList[i] as DashPanel).x + (openPanelList[i] as DashPanel).width / 2,
																		 container.y +
						(openPanelList[i] as DashPanel).y + (openPanelList[i] as DashPanel).height /
						2)) {
						var glowEffect:GlowFilter = new GlowFilter();
						glowEffect.color = 0xAAAAAA;
						glowEffect.alpha = 1;
						glowEffect.blurX = 25;
						glowEffect.blurY = 25;
						
						(openPanelList[i] as DashPanel).filters = [glowEffect];
						
						this.candidatePanel = (openPanelList[i] as DashPanel);
					} else {
						(openPanelList[i] as DashPanel).filters = [];
					}
				}
			}
		}
		
		/**
		 *  @private
		 *  Apply constraint after a dashPanel resize Event to respect panel parameters
		 */
		protected function applyConstraintOnResize(event:DashManagerEvent):void {
		/*	var dh:DashPanelHandler = event.handler;
		   dh.width = 100;//dh.width<dh.minimumWidth?dh.minimumWidth:dh.width;
		   dh.height = 100;//dh.height<dh.minimumHeight?dh.minimumHeight:dh.height;
		 */
		}
		
		/**
		 * Configures the event listeners and the icon for the DashPanel passed as argument,
		 * @param panel:DashPanel the DashPanel to be configured
		 */
		protected function configurePanel(panel:DashPanel):void {
			
			/*if ( panel.icon )
			   {
			   createIcon( panel );
			 }*/
			
			panel.addEventListener("iconChanged", onIcon);
			
			panel.addEventListener(DashPanelEvent.PANEL_TITLE_OVER, prepareHandler);
			panel.addEventListener(DashPanelEvent.PANEL_RESIZER_OVER, prepareHandler);
			
			panel.addEventListener(FlexEvent.SHOW, onPanelShowHide);
			panel.addEventListener(FlexEvent.HIDE, onPanelShowHide);
			
			panel.addEventListener(DashPanelEvent.MAXIMIZE, onMaximize);
			panel.addEventListener(DashPanelEvent.MINIMIZE, onMinimize);
			panel.addEventListener(DashPanelEvent.RESTORE, onRestore);
			panel.addEventListener(DashPanelEvent.CLOSE, onClose);
			
			panel.addEventListener(MouseEvent.MOUSE_DOWN, onFocusPanel);
		}
		
		/**
		 * Creates and brings to front the icon for the <code>panel</code> object.
		 * @param panel:DashPanel the DashPanel whose icon has to be set
		 */
		protected function createIcon(panel:DashPanel):void {
		/*var icona:Image = new Image();
		   icona.source = panel.icon;
		   icona.mouseEnabled = false;
		   icona.mouseChildren = false;
		   container.addChild( icona );
		   icons[ panel ] = icona;
		   icona.visible = panel.visible;
		   setIconPostion( panel );
		 bringToFront( icona );*/
		}
		
		/**
		 * Deactivates the PanSwitcher.
		 * @see com.comtaste.pantaste.components.PanSwitcher
		 **/
		protected function deactivatePanSwitcher():void {
			if (panSwitcher) {
				PopUpManager.removePopUp(panSwitcher as IFlexDisplayObject);
				Application.application.setStyle("modalTransparency", 0.5);
				bringToFront(panelList[panSwitcher.currentThumb]);
				
				if (icons[panelList[panSwitcher.currentThumb]])
					bringToFront(icons[panelList[panSwitcher.currentThumb]]);
				panSwitcher = null;
			}
		}
		
		/**
		 * Hides the current panel's handler.
		 * @param event:MouseEvent The MouseEvent handled
		 */
		protected function destroyHandler(event:MouseEvent):void {
			if (event.buttonDown)
				return;
			
			if (handler.resizer) {
				dispatchEvent(new DashPanelEvent(DashPanelEvent.PANEL_RESIZE_STOP, selectedPanel));
			} else {
				dispatchEvent(new DashPanelEvent(DashPanelEvent.PANEL_MOVE_STOP, selectedPanel));
			}
			handler.resizer = false;
			handler.visible = false;
			handler.setStyle("backgroundColor", null);
			container.mouseChildren = true;
		}
		
		/**
		 * Ends the resizing/replacing routine, resetting the event listeners over the handler
		 * and applying the constraints imposed by the DashPanelContainer properties
		 * @param event:MouseEvent the related MouseEvent.MOUSE_UP type event
		 */
		protected function finishWork(event:MouseEvent):void {
			if (event.buttonDown) {
				return;
			}
			applyConstraint(handlerMoved, handlerResized);
			container.stage.removeEventListener(MouseEvent.MOUSE_UP, finishWork);
			destroyHandler(event);
			handler.addEventListener(MouseEvent.MOUSE_OVER, activateHandler);
		}
		
		/**
		 * Executed when the children order of the container is changed. It rearranges the indexes of the whole childrens' set.
		 * @param event:IndexChangedEvent The index change event
		 */
		protected function onChildIndexChange(event:IndexChangedEvent):void {
			if (stopChIndex || event.relatedObject is DashPanelHandler) {
				return;
			}
			
			var allFrArray:Array = getAlwaysInFrontPanelList();
			
			if (allFrArray.length > 0) {
				for (var i:int; i < allFrArray.length; i++) {
					stopChIndex = true;
					bringToFront(allFrArray[i]);
					stopChIndex = false;
				}
			}
			
			if (event.relatedObject is DashPanel && icons[event.relatedObject]) {
				stopChIndex = true;
				var index:int = container.panels.getChildIndex(event.relatedObject);
				container.setChildIndex(icons[event.relatedObject], index + 1);
				stopChIndex = false;
			}
		}
		
		/**
		 * Executed when a DashPanel closes.
		 * <p>
		 * If <code>dashed = true</code> then a retiling of the opened DashPanels is performed.
		 * </p>
		 * @param event:DashPanelEvent the DashPanel close event.
		 */
		protected function onClose(event:DashPanelEvent):void {
			container.removePanel(event.panel);
			
			/*if (icons[event.panel as DashPanel])
			 container.removeElement(icons[event.panel]);*/
			
			delete icons[event.panel];
			
			for (var i:int = 0; i < panelList.length; i++) {
				if (event.panel == panelList[i])
					panelList.splice(i, 1);
			}
			
			if (container.dashed) {
				tile();
			}
		}
		
		/**
		 * Handler of the completion of creation of the container.
		 * @param event:FlexEvent the event of completed creation.
		 *
		 */
		protected function onContainerComplete(event:FlexEvent):void {
			container.panels.addEventListener(ElementExistenceEvent.ELEMENT_ADD, onElementAdd);
			container.panels.addEventListener(ElementExistenceEvent.ELEMENT_REMOVE, function (event:ElementExistenceEvent){
				trace("Element Remove: " + event.element);
			});

			if (container.dashed)
				tile();
			else
				cascade();
		}
		
		/**
		 * Performed every time the container is resized, to relay the open panels.
		 * <p>
		 * If <code>dashed = true</code> then a retiling of the opened DashPanels is performed.
		 * </p>
		 * @param event:Event The resize event.
		 */
		protected function onContainerResize(event:Event):void {
			var openPanelList:Array = getOpenedPanelList();
			
			for (var i:int = 0; i < openPanelList.length; i++) {
				var win:DashPanel = openPanelList[i] as DashPanel;
				
				if (win.status == DashPanel.MAXIMIZED) {
					var maxEvent:DashPanelEvent = new DashPanelEvent(DashPanelEvent.MAXIMIZE, win);
					win.dispatchEvent(maxEvent);
					return;
				}
			}
			
			if (container.dashed)
				tile();
		
		}
		
		/**
		 * Handler of the addition of the container to the stage.
		 * @param event:ChildExistenceChangedEvent the event of changed existence of the container
		 */
		protected function onElementAdd(event:ElementExistenceEvent):void {
			if (!(event.element is DashPanel))
				return;
			
			var panel:DashPanel;
			panel = event.element as DashPanel;
			
			if (panelList.indexOf(panel) < 0) {
				this.panelList.push(panel);
				configurePanel(panel);
			}
			
			addHandler();
		}
		
		/**
		 * Executed whenever a target DashPanel gains focus.
		 * @param event:MouseEvent The MouseEvent over the target DashPanel
		 */
		protected function onFocusPanel(event:MouseEvent):void {
			trace("onFocusPanel");
			if (event.currentTarget is DashPanel) {
				bringToFront(event.currentTarget as DashPanel);
				/* bringToFront( handler ); */
			}
		}
		
		/**
		 *
		 */
		protected function onKeyDown(event:KeyboardEvent):void {
		
		}
		
		/**
		 * Handles the keyboard event that brings up the PanSwitcher
		 * @param event:KeyboardEvent
		 * @see com.comtaste.pantaste.components.PanSwitcher
		 */
		protected function onKeyUp(event:KeyboardEvent):void {
			if (event.ctrlKey) {
				if (event.keyCode == Keyboard.TAB) {
					event.stopImmediatePropagation();
					
					if (!ctrlKeyPressed) {
						ctrlKeyPressed = true;
						activatePanSwitcher();
					} else {
						if (panSwitcher)
							panSwitcher.selectNext();
					}
					/* } else if( event.keyCode == M_KEY ){
					
					   var pod:PodWindow = getPodWindowByFocusedComponent();
					
					   if( pod != null ){
					   if(
					   pod.enabled &&
					   !pod.isDragging() &&
					   !pod.isResizing() &&
					   pod.showNormalizeButton
					   ){
					   normalizePod( pod );
					   }
					   }
					 } */
				}
				
			} else if (event.keyCode == Keyboard.CONTROL) {
				ctrlKeyPressed = false;
				deactivatePanSwitcher();
			}
		}
		
		/**
		 * Applies the resize and move effect when the target DashPanel is maximized.
		 * @param event:DashPanelEvent The maximization event.
		 */
		protected function onMaximize(event:DashPanelEvent):void {
			var panel:DashPanel = event.panel as DashPanel;
			
			if (panel.status == DashPanel.MAXIMIZED)
				return;
			else if (panel.status == DashPanel.MINIMIZED) {
				panel.visible = true;
				panel.x = panel.restoredX;
				panel.y = panel.restoredY;
				panel.width = panel.restoredWidth;
				panel.height = panel.restoredHeight;
			}
			
			applyEffect(panel, 0, 0, container.width, container.height);
			
			/* panel.x = 0;
			   panel.y = 0;
			   panel.width = container.width;
			 panel.height = container.height; */
			
			bringToFront(panel);
			
			if (icons[panel])
				bringToFront(icons[panel]);
			
			setIconPostion(panel);
			
			panel.status = DashPanel.MAXIMIZED;
			
			// generate dash container event
			this.container.generatepantasteChangeEvent(DashPanelContainer.PANEL_MAXIMIZED, panel);
		}
		
		/**
		 * Applies the resize and move effect when the target DashPanel is minimized.
		 * <p>It furthermore adds it to the DashDock of the current DashPanelContainer.
		 * If <code>dashed = true</code> then a retiling of the opened DashPanels is performed.
		 * </p>
		 * @param event:DashPanelEvent The maximization event.
		 */
		protected function onMinimize(event:DashPanelEvent):void {
			var panel:DashPanel = event.panel as DashPanel;
			
			if (panel.status == DashPanel.MINIMIZED)
				return;
			
			minimizing = true;
			
			destroyHandler(new MouseEvent("dummy"));
			
			applyEffect(panel, panel.x, panel.y, 0, 0);
			
			setTimeout(function():void {
					panel.visible = false;
					
					if (icons[panel])
						icons[panel].visible = false;
				}, 250);
			
			if (container.dock) {
				container.dock.addPanel(panel);
			}
			panel.status = DashPanel.MINIMIZED;
			
			if (container.dashed)
				tile();
			
			// generate dash container event
			this.container.generatepantasteChangeEvent(DashPanelContainer.PANEL_MINIMIZED, panel);
		}
		
		/**
		 * Handler of the event of showing/hiding a target panel.
		 * @param event:FlexEvent The event of showing/hiding a panel.
		 */
		protected function onPanelShowHide(event:FlexEvent):void {
			var panel:DashPanel = event.target as DashPanel;
			
			if (icons[panel] != null && !minimizing)
				icons[panel].visible = panel.visible;
			
			if (container.dashed && !minimizing)
				tile();
			
			minimizing = false;
		}
		
		/**
		 * Restores the view of the DashPanel that dispatched the event.
		 * <p>
		 * If <code>dashed = true</code> then a retiling of the opened DashPanels is performed.
		 * </p>
		 * @param event:DashPanelEvent The restore event.
		 */
		protected function onRestore(event:DashPanelEvent):void {
			var panel:DashPanel = event.panel as DashPanel;
			
			if (panel.status != DashPanel.RESTORED) {
				minimizing = true;
				
				panel.visible = true;
				setTimeout(function():void {
						if (icons[panel])
							icons[panel].visible = true;
					}, 250);
				
				bringToFront(panel);
				setIconPostion(panel);
				
				panel.status = DashPanel.RESTORED;
				
				if (container.dock) {
					container.dock.removePanel(panel);
				}
				
				if (container.dashed)
					tile();
				else
					applyEffect(panel, panel.restoredX, panel.restoredY, panel.restoredWidth,
								panel.restoredHeight);
				
				// generate dash container event
				this.container.generatepantasteChangeEvent(DashPanelContainer.PANEL_RESTORED, panel);
			}
		}
		
		/**
		 * Handles the DashPanelEvent.
		 * <p>
		 *  It sets the DashPanelHandler visible and on the same coordinates of the DashPanel being moved, or on the bottom-right corner
		 * if being resized.
		 * </p>
		 * @param event:DashPanelEvent
		 */
		protected function prepareHandler(event:DashPanelEvent):void {
			var panel:DashPanel = event.panel as DashPanel;
			
			if (panel.status == DashPanel.MAXIMIZED ||
				(event.type == DashPanelEvent.PANEL_RESIZER_OVER && container.dashed))
				return;
			
			handler.visible = true;
			bringToFront(handler);
			selectedPanel = panel;
			
			if (event.type == DashPanelEvent.PANEL_TITLE_OVER) {
				dispatchEvent(new DashPanelEvent(DashPanelEvent.PANEL_MOVE_START, selectedPanel));
				handler.resizer = false;
				handler.width = panel.width;
				handler.height = 35;
				handler.x = panel.x;
				handler.y = panel.y;
				handlerMoved = true;
				handlerResized = false;
			} else if (event.type == DashPanelEvent.PANEL_RESIZER_OVER) {
				dispatchEvent(new DashPanelEvent(DashPanelEvent.PANEL_RESIZE_START, selectedPanel));
				handler.resizer = true;
				handler.width = 10;
				handler.height = 10;
				handler.x = panel.width + panel.x - 10;
				handler.y = panel.height + panel.y - 10;
				handlerMoved = false;
				handlerResized = true;
			}
		}
		
		/**
		 * Positions the icon over the DashPanel passed as argument.
		 * @param panel:DashPanel The panel whose icon has to be positioned
		 */
		protected function setIconPostion(panel:DashPanel):void {
			/*if (icons[panel] == null)
				return;
			
			var icona:Image = icons[panel];
			
			icona.x = panel.x + panel.iconXOffset;
			icona.y = panel.y + panel.iconYOffset;
			
			panel.titleXOffset = icona.contentWidth;
			
			bringToFront(icona);*/
		}
		
		//----------------------------------------------------------
		//
		//    Private Functions 
		//
		//----------------------------------------------------------
		
		/**
		 * Builds the composite parallel effect of resizing and moving of the DashPanel passed as argument.
		 * @param panel:DashPanel The DashPanel to which apply the parallel effect.
		 * @param xTo:Number The ending x coordinate for the move effect.
		 * @param yTo:Number The ending y coordinate for the move effect.
		 * @param widthTo:Number The ending width of the resize effect.
		 * @param heightTo:Number The ending height of the resize effect.
		 */
		private function constructEffect(panel:DashPanel, xTo:Number, yTo:Number, widthTo:Number,
										 heightTo:Number, parallel:Parallel):void {
			if (icons[panel] != null) {
				var iconMoveEffect:Move = new Move(icons[panel]);
				iconMoveEffect.xFrom = icons[panel].x;
				iconMoveEffect.yFrom = icons[panel].y;
				iconMoveEffect.xTo = xTo + panel.iconXOffset;
				iconMoveEffect.yTo = yTo + panel.iconYOffset;
				parallel.addChild(iconMoveEffect);
			}
			
			var moveEffect:Move = new Move(panel);
			moveEffect.xFrom = panel.x;
			moveEffect.yFrom = panel.y;
			moveEffect.xTo = xTo;
			moveEffect.yTo = yTo;
			
			var resizeEffect:Resize = new Resize(panel);
			resizeEffect.widthFrom = panel.width;
			resizeEffect.heightFrom = panel.height;
			resizeEffect.widthTo = widthTo;
			resizeEffect.heightTo = heightTo;
			
			parallel.addChild(moveEffect);
			parallel.addChild(resizeEffect);
			parallel.duration = 500;
		}
		
		/**
		 * Handles the change of the icon over the target panel
		 * @param event:Event the event of type <code>iconChanged</code>
		 */
		private function onIcon(event:Event):void {
			var panel:DashPanel = event.target as DashPanel;
			
			if (icons[panel]) {
				container.removeChild(icons[panel])
				delete icons[panel];
			}
		
		/*if ( panel.icon )
		   {
		   createIcon( panel );
		 }*/
		}
	}
}