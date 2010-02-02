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
		public function ResizeBehaviour(eventTrigger:String, target:UIComponent,
										dispatcher:IEventDispatcher=null) {
			super(eventTrigger, target, dispatcher);
		}
		
		private var _isResizing:Boolean = false;
		
		private var minimumHeight:Number = DashConstants.DEFAULT_MINIMUM_PANEL_HEIGHT;
		private var minimumWidth:Number = DashConstants.DEFAULT_MINIMUM_PANEL_WIDTH;
		
		private function get isResizing():Boolean {
			return _isResizing;
		}
		
		private function set isResizing(value:Boolean):void {
			_isResizing = value;
			
			if (_isResizing) {
				showCursor();
			}
		}
		
		override protected function initialize():void {
			trace("initialize");
			cursor = DashConstants.resizeCursor;
			super.dispatcher.addEventListener(triggerEvent, onResizeTriggered);
			super.dispatcher.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			super.dispatcher.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			
			super.initialize();
		}
		
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
		}
		
		private function onResizeTriggered(event:MouseEvent):void {
			
			if (event.currentTarget != dispatcher) {
				return;
			}
			
			var triggerPosition:Point = new Point(event.stageX, event.stageY);
			var targetPosition:Point = DisplayObject(proxyLayer).globalToLocal(triggerPosition);
			proxy.x = target.x;
			proxy.y = target.y;
			
			startResizing();
		
		}
		
		private function onMouseMove(event:MouseEvent):void {
			var triggerPosition:Point = new Point(event.stageX, event.stageY);
			var targetPosition:Point = DisplayObject(proxyLayer).globalToLocal(triggerPosition);
			var desiredWidth:Number = targetPosition.x - target.x;
			var desiredHeight:Number = targetPosition.y - target.y;
			
			proxy.width = desiredWidth < minimumWidth ? minimumWidth : desiredWidth;
			proxy.height = desiredHeight < minimumHeight ? minimumHeight : desiredHeight;
		
		}
		
		private function onMouseUp(event:MouseEvent):void {
			IVisualElement(FlexGlobals.topLevelApplication).removeEventListener(MouseEvent.MOUSE_UP,
																				onMouseUp);
			stopResizing();
		}
		
		private function stopResizing():void {
			isResizing = false;
			IVisualElement(FlexGlobals.topLevelApplication).removeEventListener(MouseEvent.MOUSE_MOVE,
																				onMouseMove)
			hideCursor();
			resizeTarget(proxy.width, proxy.height);
			destroyProxy();
		}
		
		private function startResizing():void {
			isResizing = true;
			proxy.mode = DashProxy.MODE_BOUNDS;
			
			
			IVisualElement(FlexGlobals.topLevelApplication).addEventListener(MouseEvent.MOUSE_UP,
																			 onMouseUp)
			
			IVisualElement(FlexGlobals.topLevelApplication).addEventListener(MouseEvent.MOUSE_MOVE,
																			 onMouseMove);
			
			proxyLayer.addElement(proxy);
		}
		
		private function resizeTarget(width:Number, height:Number):void {
			target.width = width;
			target.height = height;
		
		}
	
	}
}