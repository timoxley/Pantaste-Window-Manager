package com.comtaste.pantaste.behaviours.modifiers
{
	import com.comtaste.pantaste.behaviours.SelectBehaviour;
	
	public class SelectModifier extends BehaviourModifierBase implements IBehaviourModifier
	{
		public var targetSelectionBehaviour:SelectBehaviour;
		
		public function SelectModifier(targetSelectionBehaviour:SelectBehaviour)
		{
			this.targetSelectionBehaviour = targetSelectionBehaviour;
		}
		
		public function start():void
		{
			targetSelectionBehaviour.select();
		}
		
		public function step():void
		{
		}
		
		public function stop():void
		{
		}
	}
}