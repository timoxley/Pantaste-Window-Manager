package com.comtaste.pantaste.behaviours.modifiers
{
	import com.comtaste.pantaste.behaviours.BehaviourBase;
	
	public class MaintainAspectRatioModifier implements IBehaviourModifier
	{
		
		public var initialWidth:Number;
		public var initialHeight:Number;
		public function MaintainAspectRatioModifier(initialWidth:Number, initialHeight:Number)
		{
			this.initialWidth = initialWidth;
			this.initialHeight = initialHeight;
		}
		
		
		private var _enabled = true;
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
		}
		
		private var _behaviour:BehaviourBase;
		
		public function get behaviour():BehaviourBase
		{
			return _behaviour;
		}
		
		public function set behaviour(value:BehaviourBase):void
		{
			_behaviour = value;
		}
		
		public function start():void
		{
		}
		
		public function step():void
		{
		}
		
		public function stop():void
		{
		}
		
		protected function maintainAspectRatio() {
			/*widthRatio = initialWidth / initialHeight;
			heightRatio = initialHeight / initialWidth;
			behaviour.target.width / behaviour.target.height */
		}
	}
}