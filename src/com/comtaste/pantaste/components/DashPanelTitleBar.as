
package com.comtaste.pantaste.components
{
	import mx.containers.HBox;
	import mx.controls.Label;
	import mx.core.ScrollPolicy;
	import mx.core.UIComponent;
	/**
	 * The instances of this class are title bars for the DashPanel instance they refer to.
	 * @see com.comtaste.pantaste.components.DashPanel
	 */
	public class DashPanelTitleBar extends HBox implements IDashPanelElement
	{
		/**
		 * Label showing the title of the related DashPanel.
		 */ 
		public var titleField:Label;
		/**
		 * DashPanelControls of this DashPanelTitleBar.
		 * @see com.comtaste.pantaste.components.DashPanelControls DashPanelControls
		 */ 
		public var controls:DashPanelControls;
		/**
		 * Constructor.
		 * @param panel:DashPanel The DashPanel relative to this DashPanelTitleBar
		 * @see com.comtaste.pantaste.components.DashPanel DashPanel
		 */ 
		public function DashPanelTitleBar( panel:DashPanel )
		{
			super();
			/* height = 25; */
			titleField = new Label();
			titleField.truncateToFit = true;
			titleField.percentWidth = 100;
			/* titleField.percentHeight = 100; */
			titleField.styleName = "titleBarText"
			verticalScrollPolicy = ScrollPolicy.OFF;
			horizontalScrollPolicy = ScrollPolicy.OFF; 
			
			titleField.mouseEnabled = false;
			titleField.mouseChildren = false;
			
			controls = new DashPanelControls( panel );
			controls.percentHeight = 100;
			setStyle("verticalAlign", "middle");
			setStyle("paddingRight", 5);
		}
		/**
		 * @inheritDoc
		 * 
		 */ 
		override protected function createChildren():void
		{
			super.createChildren();
			
			if ( titleField && !contains( titleField ) )
			{
				addChild( titleField );
			}
			
			if ( controls && !contains( controls ) )
			{
				addChild( controls )
			}
		}
	}
}