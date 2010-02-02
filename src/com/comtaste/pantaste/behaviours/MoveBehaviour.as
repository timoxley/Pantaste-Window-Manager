package com.comtaste.pantaste.behaviours {
	import com.comtaste.pantaste.common.DashConstants;
	import com.comtaste.pantaste.components.DashProxy;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.FlexGlobals;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;

	public class MoveBehaviour extends TransformBehaviourBase {

		//----------------------------------------------------------
		//
		//   Static Properties 
		//
		//----------------------------------------------------------

		public static const TARGET_MOVED:String = "targetMoved";
		
		//----------------------------------------------------------
		//
		//   Constructor 
		//
		//----------------------------------------------------------

		public function MoveBehaviour(eventTrigger:String, target:UIComponent,
									  dispatcher:IEventDispatcher=null) {
			super(eventTrigger, target, dispatcher);
		}

		//----------------------------------------------------------
		//
		//   Private Properties 
		//
		//----------------------------------------------------------

		private var _isMoving:Boolean = false;

		private function get isMoving():Boolean
		{
			return _isMoving;
		}

		private function set isMoving(value:Boolean):void
		{
			_isMoving = value;
			if (_isMoving) {
				showCursor();
			}
		}

		//----------------------------------------------------------
		//
		//   Public Functions 
		//
		//----------------------------------------------------------

		public function cancel():void {
			proxy.stopDrag();
			destroyProxy();
		}

		//----------------------------------------------------------
		//
		//   Protected Functions 
		//
		//----------------------------------------------------------

		override protected function initialize():void {
			trace("initialize");
			cursor = DashConstants.moveCursor;
			super.dispatcher.addEventListener(triggerEvent, onMoveTriggered);
			super.dispatcher.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			super.dispatcher.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			
			super.initialize();
		}

		//----------------------------------------------------------
		//
		//    Private Functions 
		//
		//----------------------------------------------------------

		private function moveTarget(x:Number, y:Number):void {
			trace("x: " + x);
			trace("y: " + y);
			trace("x: " + x);
			trace("target.y: " + target.y);
			trace("target.x: " + target.x);
			target.x = x;
			target.y = y;
		
		}
		
		private function onMouseOut(event:MouseEvent):void {
			if (event.currentTarget != dispatcher) {
				return;
			}
			if (!isMoving) {
				hideCursor();
			}
		}
		
		private function onMouseOver(event:MouseEvent):void {
			if (event.currentTarget != dispatcher) {
				return;
			}
			showCursor();
		}
		
		private function onMouseUp(event:MouseEvent):void {
			IVisualElement(FlexGlobals.topLevelApplication).removeEventListener(MouseEvent.MOUSE_UP,
																				onMouseUp);
			
			stopMoving();
		
		}
		
		private function onMoveTriggered(event:MouseEvent):void {
			if (event.currentTarget != dispatcher) {
				return;
			}
			
			var triggerPosition:Point = new Point(event.stageX, event.stageY);
			var targetPosition:Point = DisplayObject(proxyLayer).globalToLocal(triggerPosition);
			proxy.x = target.x;
			proxy.y = target.y;
			
			startMoving();
		
		}
		
		private function startMoving():void {
			isMoving = true;
			proxy.mode = DashProxy.MODE_SNAPSHOT;
			
			if (proxy.initialized) {
				proxy.startDrag();
			} else {
				proxy.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:Event):void {
						proxy.removeEventListener(FlexEvent.CREATION_COMPLETE, arguments.callee);
						proxy.startDrag();
					});
			}
			
			IVisualElement(FlexGlobals.topLevelApplication).addEventListener(MouseEvent.MOUSE_UP,
																			 onMouseUp)
			
			proxyLayer.addElementAt(proxy, proxyLayer.getElementIndex(target) + 1);		
		}
		
		private function stopMoving():void {
			isMoving = false;
			proxy.stopDrag();
			hideCursor();
			moveTarget(proxy.x, proxy.y);
			destroyProxy();
		}
	}
}