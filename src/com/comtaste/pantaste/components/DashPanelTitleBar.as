
package com.comtaste.pantaste.components {
	import com.comtaste.pantaste.components.skins.TitleBarSkin;
	import mx.events.FlexEvent;
	import spark.components.Label;
	import spark.components.SkinnableContainer;
	
	
	/**
	 * The instances of this class are title bars for the DashPanel instance they refer to.
	 * @see com.comtaste.pantaste.components.DashPanel
	 */
	[Style(name="panelCornerRadius",type="Number",format="Number",inherit="yes")]
	public class DashPanelTitleBar extends SkinnableContainer implements IDashPanelElement {
		
		//----------------------------------------------------------
		//
		//   Constructor 
		//
		//----------------------------------------------------------
		
		/**
		 * Constructor.
		 * @param panel:DashPanel The DashPanel relative to this DashPanelTitleBar
		 * @see com.comtaste.pantaste.components.DashPanel DashPanel
		 */
		public function DashPanelTitleBar() {
			super();
			mouseEnabled = true;
			this.addEventListener(FlexEvent.PREINITIALIZE, onPreInitialize);
		}
		
		//----------------------------------------------------------
		//
		//    Public Properties 
		//
		//----------------------------------------------------------
		
		/**
		 * DashPanelControls of this DashPanelTitleBar.
		 * @see com.comtaste.pantaste.components.DashPanelControls DashPanelControls
		 */
		[SkinPart(required="true")]
		public var controls:DashPanelControls;
		
		
		private var _panel:DashPanel;
		[Bindable]
		public function get panel():DashPanel
		{
			return _panel;
		}

		public function set panel(value:DashPanel):void
		{
			_panel = value;
		}

		
		/**
		 * Label showing the title of the related DashPanel.
		 */
		[SkinPart(required="true")]
		public var title:Label;
		
		//----------------------------------------------------------
		//
		//   Protected Functions 
		//
		//----------------------------------------------------------
		
		protected function onPreInitialize(event:FlexEvent):void {
			removeEventListener(FlexEvent.PREINITIALIZE, onPreInitialize);
			setStyle('skinClass', com.comtaste.pantaste.components.skins.TitleBarSkin);
		}
		
		override protected function partAdded(partName:String, instance:Object):void {
			if (instance == title) {
				title.mouseChildren = false;
				title.mouseEnabled = false;
			}
		}
	}
}