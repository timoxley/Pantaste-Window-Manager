package com.comtaste.pantaste.behaviours {
	import com.comtaste.pantaste.components.DashProxy;
	import com.comtaste.pantaste.components.skins.DashProxySkin;
	
	import flash.display.DisplayObject;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	
	import mx.core.FlexGlobals;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.managers.CursorManagerPriority;
	import mx.managers.DragManager;
	
	
	public class TransformBehaviourBase extends BehaviourBase {
		
		//----------------------------------------------------------
		//
		//   Constructor 
		//
		//----------------------------------------------------------
		
		public function TransformBehaviourBase(triggerEvent:String, target:UIComponent,
											   dispatcher:IEventDispatcher=null) {
			offset = new Point();
			
			super(triggerEvent, target, dispatcher);
		}
		
		//----------------------------------------------------------
		//
		//    Public Properties 
		//
		//----------------------------------------------------------
		
		public var proxy:DashProxy;
		
		public var proxyLayer:IVisualElementContainer =
			IVisualElementContainer(FlexGlobals.topLevelApplication);
		
		//----------------------------------------------------------
		//
		//    Protected Properties 
		//
		//----------------------------------------------------------
		
		protected var cursor:Class;
		protected var offset:Point;
		//----------------------------------------------------------
		//
		//   Protected Functions 
		//
		//----------------------------------------------------------
		
		protected function createProxy():void {
			proxy = new DashProxy();
			proxy.setStyle('skinClass', com.comtaste.pantaste.components.skins.DashProxySkin);
			proxy.targetElement = target;
			proxyLayer = IVisualElementContainer(target.parent);
		}
		
		protected function destroyProxy():void {
		
			proxyLayer.removeElement(proxy);
		
		}
		
		protected function hideCursor():void {
			return;
			// Special case to prevent cursor mess with drag manager
		
			if (DragManager.isDragging) {
				return;
			}
			if (cursor) {
				target.cursorManager.removeAllCursors();
			}
		}
		
		override protected function initialize():void {
			createProxy();
		}
		
		protected function showCursor():void {
			return;
			
			// Special case to prevent cursor mess with drag manager
			if (DragManager.isDragging) {
				return;
			}
			if (cursor) {
				target.cursorManager.removeAllCursors();
				target.cursorManager.setCursor(cursor, CursorManagerPriority.LOW, offset.x, offset.x);
			}
		
		}
		
		protected function toCoordinateSpace(x:Number, y:Number, to:DisplayObject, from:DisplayObject = null):Point {
			var point:Point = new Point(x, y);
			// if from provided, get global coords from it, 
			// otherwise assume x, y are global coords
			if (from) {
				point = from.localToGlobal(point);
			}
			point = to.globalToLocal(point);
			
			return point;
		}
	}
}