package com.comtaste.pantaste.behaviours.modifiers
{
	import com.comtaste.pantaste.behaviours.BehaviourBase;
	public class BehaviourModifierBase
	{

		//----------------------------------------------------------
		//
		//   Constructor 
		//
		//----------------------------------------------------------

		public function BehaviourModifierBase()
		{
		}


		//----------------------------------------------------------
		//
		//    Public Properties 
		//
		//----------------------------------------------------------

		//--------------------------------------
		// behaviour 
		//--------------------------------------

		private var _behaviour:BehaviourBase;
		
		public function get behaviour():BehaviourBase
		{
			return _behaviour;
		}
		
		public function set behaviour(value:BehaviourBase):void
		{
			_behaviour = value;
		}

		//--------------------------------------
		// enabled 
		//--------------------------------------

		private var _enabled:Boolean = true;
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
		}
	}
}