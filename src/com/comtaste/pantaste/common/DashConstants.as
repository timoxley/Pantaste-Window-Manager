package com.comtaste.pantaste.common
{

	
	/**
	 * This class exposes some constants.
	 */ 
	public class DashConstants
	{
		/**
		 * Defines the default DashPanel width.
		 * @see com.comtaste.pantaste.components.pantaste
		 */ 
		public static const DEFAULT_PANEL_WIDTH:Number = 300;
		
		/**
		 * Defines the default DashPanel height.
		 * @see com.comtaste.pantaste.components.pantaste
		 */
		public static const DEFAULT_PANEL_HEIGHT:Number = 300;
		
		/**
		 * Defines the default dash cascade size.
		 * <p>
		 * 	When the DashPanels in the DashContainer are cascaded,
		 *  they are replaced in the following recursive fashion:
		 * 	<ul>
		 * 		<li> The first panel (w.r.t. some order) is placed with is upper left corner on the upper left corner of the DashContainer.</li>
		 * 		<li> The n-th panel (w.r.t. some order) is placed with an offset of DEFAULT_DASH_CASCADE_SIZE on both axes w.r.t. the n-1 th DashPanel.</li>
		 * 	</ul>
		 * </p>
		 */		
		public static const DEFAULT_DASH_CASCADE_SIZE:Number = 25;
		
		/**
		 * Defines the dimension of the dash snap squares. 
		 * <p>
		 * 	This reduces the positions in which a DashPanel can be snapped over the DashContainer
		 * to a set of square areas contained in the DashContainer.
		 * </p> 
		 */		
		public static const DEFAULT_DASH_SNAP_SIZE:Number = 50;
	
		/**
		 * Width and height of the resizer.
		 * @see com.comtaste.pantaste.components.DashPanel 
		 */
		public static const DEFAULT_DASH_RESIZER_SIZE:Number = 10;
		
		/**
		 * Minimum height of a dashpanel.
		 */ 
		public static const DEFAULT_MINIMUM_PANEL_HEIGHT:Number = 50;
		/**
		 * Minimum width of a dashpanel.
		 */ 
		public static const DEFAULT_MINIMUM_PANEL_WIDTH:Number = 50;
		/**
		 * Height of a menu item.
		 */ 
		public static const DEFAULT_MENUITEM_HEIGHT:Number = 21;
		/**
		 * Height of a menu item that has an icon.
		 */ 
		public static const DEFAULT_ICON_MENUITEM_HEIGHT:Number = 55;
		/**
		 * Default show start button value = True.
		 */ 
		public static const DEFAULT_SHOW_START_BUTON:Boolean = true;
	}
}