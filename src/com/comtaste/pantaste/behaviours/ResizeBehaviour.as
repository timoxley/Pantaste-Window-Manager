package com.comtaste.pantaste.behaviours {
	import com.comtaste.pantaste.common.DashConstants;
	import com.comtaste.pantaste.components.DashProxy;
	
	import flash.display.DisplayObject;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.FlexGlobals;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	
	public class ResizeBehaviour extends TransformBehaviourBase {
		
		public static const TOP_LEFT:String = "topLeft";
		
		public static const TOP_RIGHT:String = "topRight";
		
		public static const TOP_MID:String = "topMid";
		
		public static const BOTTOM_LEFT:String = "bottomLeft";
		
		public static const BOTTOM_RIGHT:String = "bottomLeft";
		
		public static const BOTTOM_MID:String = "bottomLeft";
		
		public static const LEFT_MID:String = "leftMid";
		
		public static const RIGHT_MID:String = "rightMid";
		
		
		public static const SCALE_MODE:String = "scaleMode";
		
		public static const RESIZE_MODE:String = "resizeMode";
		
		//----------------------------------------------------------
		//
		//   Constructor 
		//
		//----------------------------------------------------------
		
		
		public function ResizeBehaviour(eventTrigger:String, target:UIComponent,
										dispatcher:IEventDispatcher=null) {
			super(eventTrigger, target, dispatcher);
		}
		
		
		//----------------------------------------------------------
		//
		//   Private Properties 
		//
		//----------------------------------------------------------
		
		public var resizeMode:String = RESIZE_MODE;
		
		//--------------------------------------
		// isResizing 
		//--------------------------------------
		
		private static var _isResizing:Boolean = false;
		
		public function get isResizing():Boolean {
			return _isResizing;
		}
		
		public function set isResizing(value:Boolean):void {
			_isResizing = value;
			
			if (_isResizing) {
				showCursor();
			}
		}
		
		private var minimumHeight:Number =
			DashConstants.DEFAULT_MINIMUM_PANEL_HEIGHT;
		
		private var minimumWidth:Number =
			DashConstants.DEFAULT_MINIMUM_PANEL_WIDTH;
		
		private var originalSize:Point;
		
		//----------------------------------------------------------
		//
		//   Protected Functions 
		//
		//----------------------------------------------------------
		
		
		override protected function initialize():void {
			originalSize = new Point();
			offset = new Point(-4, -4);
			cursor = DashConstants.resizeCursor;
			super.dispatcher.addEventListener(triggerEvent, onResizeTriggered);
			super.dispatcher.addEventListener(MouseEvent.MOUSE_OVER,
											  onMouseOver);
			super.dispatcher.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			
			super.initialize();
		}
		
		//----------------------------------------------------------
		//
		//    Private Functions 
		//
		//----------------------------------------------------------
		
		
		private function onMouseMove(event:MouseEvent):void {
			
			
			var triggerPosition:Point = new Point(event.stageX, event.stageY);
			//	var proxyPosition:Point = new Point(proxy.x, proxy.y);
			//var triggerInProxySpace:Point = DisplayObject(proxyLayer).globalToLocal(triggerPosition)
			
			
			var localTriggerDimensions:Point =
				toCoordinateSpace(triggerPosition.x, triggerPosition.y,
								  DisplayObject(proxyLayer))
			proxy.width = localTriggerDimensions.x - proxy.x;
			proxy.height = localTriggerDimensions.y - proxy.y
			
		/*trace(" ---- onMouseMove");
		   trace("event.stageX: " + event.stageX);
		   trace("event.stageY: " + event.stageY);
		   trace("target.x: " + target.x);
		   trace("target.y: " + target.y);
		   trace("target.width: " + target.width);
		   trace("target.height: " + target.height);
		   trace("proxy.x: " + proxy.x);
		   trace("proxy.y: " + proxy.y);
		   var triggerPosition:Point = new Point(event.stageX, event.stageY);
		   var targetPosition:Point = DisplayObject(proxyLayer).globalToLocal(triggerPosition);
		   var anchoredPosition:Point = targetPosition.add(anchor);
		   - target.parent.localToGlobal(target).x;
		
		
		   var desiredWidth:Number = targetPosition.x
		   var desiredHeight:Number = targetPosition.y - target.y;
		
		
		
		
		   //proxy.x =
		   //proxy.y =
		   proxy.width = desiredWidth < minimumWidth ? minimumWidth : desiredWidth;
		   proxy.height = desiredHeight < minimumHeight ? minimumHeight : desiredHeight;
		   trace("proxy.width: " + proxy.width);
		   trace("proxy.height: " + proxy.height);
		   //step();
		 trace(" ---- onMouseMove end");*/
		
		}
		
		private var _anchor:Point
		
		public function get anchor():Point {
			if (!_anchor) {
				_anchor = new Point();
			}
			
			switch (anchorPosition) {
				case TOP_LEFT:
					_anchor.x = 0;
					_anchor.y = 0;
					break;
				case TOP_RIGHT:
					_anchor.x = this.target.width;
					_anchor.y = 0;
					break;
				case TOP_MID:
					_anchor.x = this.target.width / 2;
					break;
				
				case BOTTOM_LEFT:
					_anchor.x = 0;
					_anchor.y = this.target.height;
					break;
				case BOTTOM_RIGHT:
					_anchor.x = this.target.width;
					_anchor.y = this.target.height;
					break;
				case BOTTOM_MID:
					_anchor.x = this.target.width / 2;
					_anchor.y = this.target.height;
					break;
				
				case LEFT_MID:
					_anchor.x = 0;
					_anchor.y = this.target.height / 2;
					break;
				case RIGHT_MID:
					_anchor.x = this.target.width;
					_anchor.y = this.target.height / 2;
					break;
				default:
					throw new Error("Invalid Anchor Position!");
			}
			return _anchor;
		}
		
		public function set anchor(value:Point):void {
			_anchor = value;
		}
		
		
		public var anchorPosition:String = BOTTOM_LEFT;
		
		
		
		private function onMouseOut(event:MouseEvent):void {
			if (event.currentTarget != dispatcher) {
				return;
			}
			
			if (!isResizing) {
				hideCursor();
			}
		}
		
		private function onMouseOver(event:MouseEvent):void {
			if (event.currentTarget != dispatcher) {
				return;
			}
			
			showCursor();
			event.stopPropagation();
		}
		
		private function onMouseUp(event:MouseEvent):void {
			IVisualElement(FlexGlobals.topLevelApplication).
				removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stopResizing();
		}
		
		private function onResizeTriggered(event:MouseEvent):void {
			if (!enabled) {
				return;
			}
			
			if (event.currentTarget != dispatcher) {
				return;
			}
			
			//var triggerPosition:Point = target.parent.localToGlobal(new Point(target.x, target.y));
			
			//var targetPosition:Point = DisplayObject(proxyLayer).globalToLocal(triggerPosition);
			//var newPos:Point = 
			
			startResizing();
			event.stopPropagation();
		}
		
		private function resizeTarget(width:Number, height:Number):void {
			
			if (resizeMode == SCALE_MODE) {
				target.scaleX = width / target.width;
				target.scaleY = height / target.height;
			} else if (resizeMode == RESIZE_MODE) {
				target.width = width;
				target.height = height;
			} else {
				throw new Error("Invalid resizeMode: " + resizeMode);
			}
		}
		
		private function startResizing():void {
			start();
			isResizing = true;
			//if (resizeMode == SCALE_MODE) {
				proxy.mode = DashProxy.MODE_SNAPSHOT;
			//} else {
				proxy.mode = DashProxy.MODE_BOUNDS;
			//}
			
			
			var proxyPosition:Point =
				toCoordinateSpace(target.x, target.y, DisplayObject(proxyLayer),
								  target.parent);
			
			proxy.x = proxyPosition.x;
			proxy.y = proxyPosition.y;
			
			
			
			originalSize.x = target.getLayoutBoundsWidth();
			originalSize.y = target.getLayoutBoundsHeight();
			
			var proxyDimensions:Point =
				toCoordinateSpace(originalSize.x, originalSize.y,
								  DisplayObject(proxyLayer), target.parent);
			
			proxy.width = proxyDimensions.x;
			proxy.height = proxyDimensions.y;
			
			//proxy.scaleX = target.scaleX;
			//proxy.scaleY = target.scaleY;
			
			IVisualElement(FlexGlobals.topLevelApplication).
				addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			IVisualElement(FlexGlobals.topLevelApplication).
				addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			proxyLayer.addElementAt(proxy, proxyLayer.numElements);
			
		}
		
		private function stopResizing():void {
			originalSize = new Point();
			isResizing = false;
			IVisualElement(FlexGlobals.topLevelApplication).
				removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove)
			hideCursor();
			resizeTarget(proxy.width, proxy.height);
			destroyProxy();
			stop();
		}
	}
}