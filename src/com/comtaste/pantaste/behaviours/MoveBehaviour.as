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
		
		private static const DRAG_THRESHOLD:Number = 5;
		
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
		
		//--------------------------------------
		// isMoving 
		//--------------------------------------
		
		private var _isMoving:Boolean = false;
		
		private function get isMoving():Boolean {
			return _isMoving;
		}
		
		private function set isMoving(value:Boolean):void {
			_isMoving = value;
			
			if (_isMoving) {
				showCursor();
			}
		}
		private var preparingToDrag:Boolean = false;
		
		private var newPosition:Point = new Point();
		
		private var originalMousePosition:Point = new Point();
		
		private var originalPosition:Point = new Point();
		
		private var triggeringEvent:MouseEvent;
		
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
			target.x = x;
			target.y = y;
		
		}
		
		private function onMouseMove(event:MouseEvent):void {
			if (preparingToDrag) {
				newPosition.x = event.stageX;
				newPosition.y = event.stageY;
				// var transformedOriginalPosition:Point = UIComponent(moveTarget.parentSelectable).localToGlobal(originalPosition)
				var differenceX:Number = Math.abs(newPosition.x - originalMousePosition.x);
				var differenceY:Number = Math.abs(newPosition.y - originalMousePosition.y);
				var distance:Number =
					Math.sqrt(Math.pow(differenceX, 2) + Math.pow(differenceY, 2));

				if (distance > DRAG_THRESHOLD) {
					startDragging();
					
				}
			}
		
			step();
			trace('step');
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
			
			if (preparingToDrag) {
				preparingToDrag = false;
				return;
			}
			stopMoving();
		
		}
		
		private function onMoveTriggered(event:MouseEvent):void {
			if (!enabled) {
				return;
			}
			
			if (event.currentTarget != dispatcher) {
				return;
			}
			triggeringEvent = event;
			
			startMoving();
		
		}
		
		private function startDragging():void {
			start();
			if (proxy.initialized) {
				proxy.startDrag();
			} else {
				proxy.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:Event):void {
						proxy.removeEventListener(FlexEvent.CREATION_COMPLETE, arguments.callee);
						proxy.startDrag();
					});
			}
			preparingToDrag = false;
			
			
			proxyLayer.addElementAt(proxy, proxyLayer.numElements);
			proxy.depth = target.depth + 1;
		
		}
		
		private function startMoving():void {
			
			
			isMoving = true;
			proxy.mode = DashProxy.MODE_SNAPSHOT;
			//proxy.depth = target.depth + 1;
			
			var triggerPosition:Point = new Point(triggeringEvent.stageX, triggeringEvent.stageY);
			var targetPosition:Point = DisplayObject(proxyLayer).globalToLocal(triggerPosition);
			proxy.x = target.x;
			proxy.y = target.y;
			
			originalPosition = new Point(target.x, target.y);
			originalMousePosition = new Point(triggeringEvent.stageX, triggeringEvent.stageY);
			
			preparingToDrag = true;
			
			IVisualElement(FlexGlobals.topLevelApplication).addEventListener(MouseEvent.MOUSE_MOVE,
																			 onMouseMove);
			
			IVisualElement(FlexGlobals.topLevelApplication).addEventListener(MouseEvent.MOUSE_UP,
																			 onMouseUp)
		
		}
		
		private function stopMoving():void {
			
			isMoving = false;
			IVisualElement(FlexGlobals.topLevelApplication).removeEventListener(MouseEvent.MOUSE_MOVE,
				onMouseMove);
			proxy.stopDrag();
			hideCursor();
			var position:Point = proxy.localToGlobal(new Point(proxy.x, proxy.y));
			
			var newPosition:Point = target.globalToLocal(position);
			proxy.x = 0;
			proxy.y = 0;
			originalPosition = new Point();
			moveTarget(newPosition.x, newPosition.y);
			destroyProxy();
			
			
			stop();
		}
	}
}