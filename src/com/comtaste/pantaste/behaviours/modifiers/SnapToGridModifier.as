package com.comtaste.pantaste.behaviours.modifiers {
	import com.comtaste.pantaste.behaviours.BehaviourBase;
	import com.comtaste.pantaste.behaviours.TransformBehaviourBase;
	
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	
	public class SnapToGridModifier implements IBehaviourModifier {
		
		//----------------------------------------------------------
		//
		//   Constructor 
		//
		//----------------------------------------------------------
		
		public function SnapToGridModifier() {
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
		
		public function get behaviour():BehaviourBase {
			return _behaviour;
		}
		
		public function set behaviour(value:BehaviourBase):void {
			_behaviour = value;
		}
		
		[Bindable]
		public var snapSize:Number;
		
		//----------------------------------------------------------
		//
		//   Private Properties 
		//
		//----------------------------------------------------------
		private var _active:Boolean = true;
		
		[Bindable]
		public function get enabled():Boolean {
			return _active;
		}
		public function set enabled(value:Boolean):void {
			_active = value;
		}

		
		private var target:UIComponent;
		
		//----------------------------------------------------------
		//
		//   Public Functions 
		//
		//----------------------------------------------------------
		
		public function start():void {
			if (!enabled) {
				return;
			}
		}
		
		public function step():void {
			if (!enabled) {
				return;
			}
			if (behaviour is TransformBehaviourBase) {
				snapToGrid(TransformBehaviourBase(behaviour).proxy);
			}
		}
		
		public function stop():void {
			if (!enabled) {
				return;
			}
			snapToGrid(behaviour.target);
		}
		
		//----------------------------------------------------------
		//
		//    Private Functions 
		//
		//----------------------------------------------------------
		
		private function snapToGrid(target:UIComponent):void {
		
			var position:Point = target.localToGlobal(new Point(target.x, target.y));
			var newPosition:Point = behaviour.target.globalToLocal(position);
			
			target.y = Math.round(newPosition.y / snapSize) * snapSize;
			target.x = Math.round(newPosition.x / snapSize) * snapSize;
			
			var diffHeight:Number = (Math.round(target.y / snapSize) * snapSize) - target.y;
			target.height = (Math.round(target.height / snapSize) * snapSize) + diffHeight;
			
			var diffWidth:Number = (Math.round(target.x / snapSize) * snapSize) - target.x;
			target.width = (Math.round(target.width / snapSize) * snapSize) + diffWidth;
		}
	}
}