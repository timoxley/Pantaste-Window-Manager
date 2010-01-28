package com.comtaste.pantaste.renderers
{
	import com.comtaste.pantaste.common.DashConstants;
	import com.comtaste.pantaste.common.DashConstants;
	
	import mx.controls.Menu;
	import mx.controls.menuClasses.MenuItemRenderer;
	import mx.controls.menuClasses.MenuListData;

	public class DashDockMenuItemRenderer extends MenuItemRenderer
	{
		public function DashDockMenuItemRenderer()
		{
			super();
			
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			invalidateDisplayList();	
		}
		
		override protected function updateDisplayList(unscaledWidth:Number,
												  	  unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			
			if(this.listData && MenuListData(this.listData).icon)
	 		{
	 			this.icon.x = 6;	
	 			trace('icon set'+MenuListData(this.listData).label);
	 		}
			 
		}
	
		override protected function measure():void
		{
			super.measure();
			
			/*if(!this.menu)
			{
				this.menu = Menu(parent.parent);
			}
			measuredWidth = 200;
			var bool:Boolean = (this.listData && MenuListData(this.listData).icon);
			if(bool)
			{
				measuredHeight = DashConstants.DEFAULT_MENUITEM_HEIGHT;
				menu.rowHeight = DashConstants.DEFAULT_MENUITEM_HEIGHT;
			}
			else
			{
				menu.rowHeight = 21;
			}*/

		}
	}
}