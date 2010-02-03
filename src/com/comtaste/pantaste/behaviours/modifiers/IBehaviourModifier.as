package com.comtaste.pantaste.behaviours.modifiers
{
	import com.comtaste.pantaste.behaviours.BehaviourBase;

	public interface IBehaviourModifier
	{

		//--------------------------------------
		// active 
		//--------------------------------------

		function get enabled():Boolean;
		function set enabled(value:Boolean):void;

		//--------------------------------------
		// behaviour 
		//--------------------------------------

		function get behaviour():BehaviourBase;
		function set behaviour(value:BehaviourBase):void;

		function start(): void;
		function step(): void;
		function stop(): void;
	}
}