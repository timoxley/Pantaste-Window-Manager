package com.comtaste.pantaste.behaviours
{
	import com.comtaste.pantaste.components.DashProxy;
	import com.comtaste.pantaste.components.skins.DashProxySkin;
	
	import flash.events.IEventDispatcher;
	
	import mx.core.FlexGlobals;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	
	public class TransformBehaviourBase extends BehaviourBase
	{
		public var proxy:DashProxy;
		protected var cursor:Class;
		public var proxyLayer:IVisualElementContainer =
			IVisualElementContainer(FlexGlobals.topLevelApplication);
		
		public function TransformBehaviourBase(triggerEvent:String, target:UIComponent, dispatcher:IEventDispatcher=null)
		{
			super(triggerEvent, target, dispatcher);
		}
		
		override protected function initialize():void {
			createProxy();
		}
		
		protected function createProxy():void {
			proxy = new DashProxy();
			proxy.setStyle('skinClass', com.comtaste.pantaste.components.skins.DashProxySkin);
			proxy.targetElement = target;
			proxyLayer = IVisualElementContainer(target.parent);
		}
		
		protected function destroyProxy():void {
			
			proxyLayer.removeElement(proxy);
			
		}
		
		protected function showCursor():void {
			if (cursor) {
				target.cursorManager.removeAllCursors();
				target.cursorManager.setCursor(cursor);
			}
			
		}
		
		protected function hideCursor():void {
			if (cursor) {
				target.cursorManager.removeAllCursors();
			}
			
		}
		
	}
}