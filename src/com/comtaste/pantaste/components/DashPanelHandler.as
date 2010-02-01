package com.comtaste.pantaste.components {
	import com.comtaste.pantaste.common.DashConstants;
	import com.comtaste.pantaste.events.DashManagerEvent;
	
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import mx.controls.SWFLoader;
	import mx.core.IVisualElementContainer;
	import mx.effects.Move;
	import mx.effects.Resize;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	
	
	/**
	 * <p>
	 * A DashPanelHandler is an object in charge of giving feedback to
	 * the user when resizing and/or moving a DashPanel, by appearing
	 * during these actions as a copy of the DashPanel the user is
	 * resizing/moving. It is therefore in charge of notifiying, via DashManagerEvent,
	 * the layout manager about the changes occurred (if any) on any DashPanel.
	 * A DashPanelHandler is instantiated as a child of a DashPanelContainer.
	 * </p>
	 * @see com.comtaste.pantaste.events.DashManagerEvent
	 * @see com.comtaste.pantaste.manager.DashLayoutManager
	 */
	public class DashPanelHandler extends Group {
		
		/**
		 * Indicates the current cursor used by the CursorManager.
		 */
		private var currentCursorID:int = -1;
		
		/**
		 * Move effect of this DashPanelHandler.
		 */
		protected var moveEffect:Move;
		
		/**
		 * Resize effect of this DashPanelHandler
		 */
		protected var resizeEffect:Resize;
		
		/**
		 * Indicates whether the user is in the middle of a moving action.
		 */
		protected var isMoving:Boolean = false;
		
		/**
		 * Indicates whether the user has performed a move operation, by moving the mouse with the left button pressed.
		 */
		protected var wasMoved:Boolean = false;
		
		/**
		 * Indicates whether the user is in the middle of a resizing action.
		 */
		protected var isResizing:Boolean = false;
		
		/**
		 * Indicates whether the user has performed a resize operation, by moving the mouse with the left button pressed.
		 */
		protected var wasResized:Boolean = false;
		
		/**
		 * Minimum resize in height allowed.
		 */
		public var minimumHeight:Number;
		
		/**
		 * Minimum resize in width allowed.
		 */
		public var minimumWidth:Number;
		
		/**
		 * Point object relative to the position where the user clicked, in local
		 * coordinates
		 */
		protected var localClickPoint:Point = new Point();
		
		/**
		 * The depth w.r.t. the DashContainer of the managed DashPanel, before any move/resize operation
		 */
		protected var originalDepth:int;
		
		/**
		 * If true, the action performed is a resize. Otherwise it is a move.
		 */
		public var resizer:Boolean = false;
		
		/**
		 * SWF Loader to load the skin appliable to this DashPanelHandler.
		 * @see #setSnapshot
		 */
		private var swfLoader:SWFLoader;
		
		/* private var currentCursorID:int = -1; */
		
		/* [Embed("/assets/cursors/resize-l.png")]
		   protected var resizerCur:Class;
		
		   [Embed("/assets/cursors/move.png")]
		 protected var moveCur:Class; */
		
		/**
		 * Constructor.
		 */
		public function DashPanelHandler() {
			super();
			
			//creationPolicy = "all";
			mouseChildren = true;
			mouseEnabled = true;
			mouseEnabledWhereTransparent = true;
			buttonMode = false;
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			//	horizontalScrollPolicy = ScrollPolicy.OFF;
			//verticalScrollPolicy = ScrollPolicy.OFF;
			minimumHeight = DashConstants.DEFAULT_MINIMUM_PANEL_HEIGHT;
			minimumWidth = DashConstants.DEFAULT_MINIMUM_PANEL_WIDTH;
			percentHeight = 100;
			percentWidth = 100;
		
		}
		
		//--------------------------------------
		//  Protected Methods
		//--------------------------------------
		
		/**
		 * Initialization code for this DashPanelHandler.
		 * <p>
		 * 	Adds event listeners and creates the effects.
		 * </p>
		 * @param event:FlexEvent the CREATION_COMPLETE event of this DashPanelHandler
		 */
		protected function onCreationComplete(event:FlexEvent):void {
			moveEffect = new Move();
			resizeEffect = new Resize();
			
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			/* addEventListener( MouseEvent.MOUSE_OUT, onMouseOut ); */
			
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		/**
		 * Handler of the MouseEvent.MOUSE_OVER type MouseEvent.
		 */
		protected function onMouseOver(event:MouseEvent):void {
			// Add a stage listener in case the mouse up comes out of the control.
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			switchToGlobalMouseListener();
			
			/* if ( resizer )
			   {
			   cursorManager.removeCursor(currentCursorID);
			   currentCursorID = cursorManager.setCursor( resizerCur, 2, -9, -6);
			   }
			   else
			   {
			   cursorManager.removeCursor(currentCursorID);
			   currentCursorID = cursorManager.setCursor( moveCur, 2, -11, -13);
			 } */
			
			var sp:Point = new Point(event.stageX, event.stageY);
			
			localClickPoint = globalToLocal(sp);
			
			if (resizer) {
				isResizing = true;
				isMoving = false;
			} else {
				isMoving = true;
				isResizing = false;
			}
			
			bringUp();
		}
		
		/**
		 * Handles the releasing of the mouse button.
		 * @param event:MouseEvent the related MouseEvent.MOUSE_UP type MouseEvent.
		 */
		protected function onMouseUp(event:MouseEvent):void {
			wasMoved = false;
			isMoving = false;
			
			if (stage)
				stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			switchToLocalMouseListener();
		
			//resetZOrder();
		}
		
		/* protected function onMouseOut( event:MouseEvent ) : void
		   {
		   if ( !event.buttonDown )
		   cursorManager.removeCursor( currentCursorID );
		 } */
		
		/**
		 * MouseEvent.MOUSE_MOVE type MouseEvent listener.
		 * <p>
		 * 	Dispatches the events to be received and handled by a LayoutManager in order to
		 * actually resize or move a DashPanel in the DashPanelContainer. Furthermore, effects of
		 * this DashPanelHandler are played.
		 * </p>
		 * @param event:MouseEvent the related MouseEvent.MOUSE_MOVE type MouseEvent.
		 */
		protected function onMouseMove(event:MouseEvent):void {
			if (parent == null) {
				return;
			}
			
			var dest:Point = parent.globalToLocal(new Point(event.stageX, event.stageY));
			
			var desiredPos:Point = new Point();
			var desiredSize:Point = new Point();
			
			/*if ( parent is Canvas )
			   {
			   var parentCanvas:Canvas = parent as Canvas;
			   dest.x += parentCanvas.horizontalScrollPosition;
			   dest.y += parentCanvas.verticalScrollPosition;
			   trace("x: " + this.x);
			   trace("y: " + this.y);
			   /*if ( event.localX < 0 ) {
			   dest.x = 0;
			   }
			   if ( event.localX + width > parentCanvas.width ) {
			   dest.x = parentCanvas.width - width;
			   }
			   if ( event.localY < 0 ){
			   dest.y = 0;
			   }
			   if ( event.localY + height > parentCanvas.height ) {
			   dest.y = parentCanvas.height - height;
			 }*/
			//}*/
			
			desiredSize.x = width < minimumWidth ? minimumWidth : width;
			desiredSize.y = height < minimumHeight ? minimumHeight : height;
			
			desiredPos.x = x;
			desiredPos.y = y;
			
			var bowAngle:Number = 0; //Math.PI / 180 * Math.abs(rotation);
			var theMatrix:Matrix;
			var rotatedPoint:Point;
			
			var xAlt:Number = localClickPoint.x;
			var yAlt:Number = localClickPoint.y;
			
			var tX:Number = 0;
			var tP:Point = new Point();
			
			bowAngle = Math.PI / 180 * rotation * -1;
			
			theMatrix =
				new Matrix(Math.cos(bowAngle), -Math.sin(bowAngle), Math.sin(bowAngle),
									Math.cos(bowAngle));
			rotatedPoint = theMatrix.transformPoint(new Point(xAlt, yAlt));
			
			var managerEvent:DashManagerEvent;
			
			if (isMoving && event.buttonDown) {
				desiredPos.y = dest.y - rotatedPoint.y;
				desiredPos.x = dest.x - rotatedPoint.x;
				
				wasMoved = true;
				
				managerEvent = new DashManagerEvent(DashManagerEvent.PANEL_HANDLER_MOVING, this);
				dispatchEvent(managerEvent);
				
			}
			
			if (isResizing && event.buttonDown) {
				
				var pt:Point = globalToLocal(new Point(event.stageX, event.stageY));
				var xsize:Number = pt.x;
				var ysize:Number = pt.y;
				desiredSize.x = xsize < minimumWidth ? minimumWidth : xsize;
				desiredSize.y = ysize < minimumHeight ? minimumHeight : ysize;
				
				wasResized = true;
				
				managerEvent = new DashManagerEvent(DashManagerEvent.PANEL_HANDLER_RESIZING, this);
				dispatchEvent(managerEvent);
			}
			
			if (wasMoved) {
				if (moveEffect.isPlaying) {
					moveEffect.end();
				}
				moveEffect = new Move();
				moveEffect.target = this;
				moveEffect.duration = 100;
				moveEffect.xTo = desiredPos.x;
				moveEffect.yTo = desiredPos.y;
				moveEffect.play();
				
			}
			
			if (wasResized) {
				if (resizeEffect.isPlaying) {
					resizeEffect.end();
				}
				resizeEffect = new Resize();
				resizeEffect.target = this;
				resizeEffect.duration = 100;
				resizeEffect.heightTo = desiredSize.y;
				resizeEffect.widthTo = desiredSize.x;
				resizeEffect.play();
				
			}
		
		}
		
		/**
		 * Switches the MouseEvent.MOUSE_MOVE type MouseEvent listener from the stage to this DashPanelHandler.
		 */
		protected function switchToLocalMouseListener():void {
			if (stage)
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		/**
		 * Switches the MouseEvent.MOUSE_MOVE type MouseEvent listener from this DashPanelHandler to the stage, in order
		 * to have a better dragging.
		 */
		protected function switchToGlobalMouseListener():void {
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		/**
		 * Brings over all his sibling components (w.r.t. the parent container) this DashPanelHandler
		 */
		protected function bringUp():void {
			try {
				originalDepth = IVisualElementContainer(parent).getElementIndex(this);
				
				if (originalDepth != parent.numChildren) {
					
					IVisualElementContainer(parent).setElementIndex(this, parent.numChildren - 1);
					
				}
			} catch (e:Error) {
				trace("WARNING: failed to bring the object forward.");
			}
		}
		
		/**
		 * Resets the original order (i.e. prior to any move/resize action)
		 * of the DashPanels of the parent DashContainer.
		 *
		 * @see com.comtaste.pantaste.components.DashPanelContainer
		 * @see com.comtaste.pantaste.components.DashPanel
		 */
		protected function resetZOrder():void {
			try {
				if (IVisualElementContainer(parent).getElementIndex(this) != originalDepth) {
					IVisualElementContainer(parent).setElementIndex(this, originalDepth);
				}
			} catch (e:Error) {
				trace("WARNING: failed to reset the Z order.");
			}
		}
		
		//--------------------------------------
		//  Public Methods
		//--------------------------------------
		
		/**
		 * Applies an appearance to this DashPanelHandler.
		 * <p>
		 * 	When moving, the DashPanelHandler shows himself until the user
		 * 	releases the mouse button, ending the action. This method can be used
		 * 	to load a particular appearance related to the action carried.
		 * </p>
		 * @param source:ByteArray The visual data used to skin the DashPanelHandler
		 */
		public function setSnapshot(source:ByteArray):void {
			
			if (!swfLoader) {
				swfLoader = new SWFLoader();
				addElement(swfLoader);
			}
			
			swfLoader.load(source);
		}
	
		//--------------------------------------
		//  Overrided Methods
		//--------------------------------------
	
	/* 		override public function set visible( value:Boolean ) : void
	   {
	   super.visible = value;
	   cursorManager.removeCursor( currentCursorID );
	 } */
	}
}