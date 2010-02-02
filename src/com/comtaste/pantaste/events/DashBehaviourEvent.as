package com.comtaste.pantaste.events
{
	import flash.events.Event;
	
	public class DashBehaviourEvent extends Event
	{
		static public const TRIGGER_MOVE_BEHAVIOUR:String = "triggerMoveBehaviour";
		public var x:Number;
		public var y:Number;
		public function DashBehaviourEvent(type:String, x:Number, y:Number)
		{
			this.x = x;
			this.y = y;
			super(type, true, false);
		}
	}
}