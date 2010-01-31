
package com.comtaste.pantaste.components {
	import com.comtaste.pantaste.components.skins.TitleBarSkin;
	import mx.events.FlexEvent;
	import spark.components.Label;
	import spark.components.SkinnableContainer;
	
	
	/**
	 * The instances of this class are title bars for the DashPanel instance they refer to.
	 * @see com.comtaste.pantaste.components.DashPanel
	 */
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
			
		/* height = 25; */
		/*titleField = new Label();
		   titleField.truncateToFit = true;
		 titleField.percentWidth = 100;*/
		/* titleField.percentHeight = 100; */
			//titleField.styleName = "titleBarText"
		/*verticalScrollPolicy = ScrollPolicy.OFF;
		 horizontalScrollPolicy = ScrollPolicy.OFF; */
		/*
		   titleField.mouseEnabled = false;
		   titleField.mouseChildren = false;
		
		   controls = new DashPanelControls( panel );
		   controls.percentHeight = 100;
		   setStyle("verticalAlign", "middle");
		 setStyle("paddingRight", 5);*/
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
		
		[Bindable]
		public var panel:DashPanel;
		
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