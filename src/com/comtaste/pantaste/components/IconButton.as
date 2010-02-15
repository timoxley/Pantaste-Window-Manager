package com.comtaste.pantaste.components
{
	import flash.geom.ColorTransform;
	
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	
	import spark.components.Button;
	import spark.components.Group;
	
	public class IconButton extends Button
	{
		public function IconButton()
		{
			super();
		}
		
		private var _iconClass:Class;

		public function get iconClass():Class
		{
			return _iconClass;
		}

		public function set iconClass(value:Class):void
		{
			_iconClass = value;
			if (iconContainer) {
				iconContainer.removeAllElements();
				iconContainer.addElement(generateIcon());
			}
		}

		private function generateIcon():IVisualElement {
			var icon:IVisualElement
			icon = IVisualElement(new iconClass());
			icon.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:FlexEvent):void {
				icon.percentHeight = 100;
				icon.percentWidth = 100;
			});
			return icon;	
		}
		
		[SkinPart(required="false")]
		public var iconContainer:Group;
		
		override protected function partAdded(partName:String, instance:Object) : void {
			if (instance == iconContainer) {
				if (iconClass) {
					var icon:IVisualElement;
					iconContainer.addElement(generateIcon());
				
				} 
			}
			
			super.partAdded(partName, instance);
		}
	}
}