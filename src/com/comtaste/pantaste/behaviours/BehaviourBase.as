package com.comtaste.pantaste.behaviours {
	import com.comtaste.pantaste.behaviours.modifiers.IBehaviourModifier;
	
	import flash.events.IEventDispatcher;
	
	import mx.core.UIComponent;
	
	
	public class BehaviourBase {
		
		//----------------------------------------------------------
		//
		//   Static Properties 
		//
		//----------------------------------------------------------
		
		public static const START:String = "startModifier";
		
		public static const STEP:String = "stepModifier";
		
		public static const STOP:String = "stopModifier";
		
		//----------------------------------------------------------
		//
		//   Constructor 
		//
		//----------------------------------------------------------
		
		public function BehaviourBase(triggerEvent:String, target:UIComponent,
									  dispatcher:IEventDispatcher=null) {
			this.triggerEvent = triggerEvent;
			this.target = target;
			modifiers = new Vector.<IBehaviourModifier>();
			
			if (dispatcher) {
				this.dispatcher = dispatcher;
			} else {
				this.dispatcher = target;
			}
			initialize();
		
		}
		
		//----------------------------------------------------------
		//
		//    Public Properties 
		//
		//----------------------------------------------------------
		
		//--------------------------------------
		// dispatcher 
		//--------------------------------------
		
		private var _dispatcher:IEventDispatcher;
		
		public function get dispatcher():IEventDispatcher {
			return _dispatcher;
		}
		
		public function set dispatcher(value:IEventDispatcher):void {
			_dispatcher = value;
		}
		
		public var enabled:Boolean = true;
		
		//--------------------------------------
		// target 
		//--------------------------------------
		
		private var _target:UIComponent;
		
		public function get target():UIComponent {
			return _target;
		}
		
		public function set target(value:UIComponent):void {
			_target = value;
		}
		
		//--------------------------------------
		// triggerEvent 
		//--------------------------------------
		
		private var _triggerEvent:String;
		
		public function get triggerEvent():String {
			return _triggerEvent;
		}
		
		public function set triggerEvent(value:String):void {
			_triggerEvent = value;
		}
		
		//----------------------------------------------------------
		//
		//   Private Properties 
		//
		//----------------------------------------------------------
		
		private var modifiers:Vector.<IBehaviourModifier>;
		
		//----------------------------------------------------------
		//
		//   Public Functions 
		//
		//----------------------------------------------------------
		
		public function addModifier(modifier:IBehaviourModifier):void {
			modifier.behaviour = this;
			modifiers[modifiers.length] = modifier;
		}
		
		public function hasModifier(modifier:IBehaviourModifier):Boolean {
			
			var index:uint = modifiers.indexOf(modifier);
			return (index >= 0);
		}
		
		public function removeModifier(modifier:IBehaviourModifier):void {
			modifier.behaviour = null;
			var index:uint = modifiers.indexOf(modifier);
			
			if (index < 0) {
				throw new Error("Modifier not found in collection: " + modifier);
			}
			modifiers.splice(index, 1);
		}
		
		//----------------------------------------------------------
		//
		//   Protected Functions 
		//
		//----------------------------------------------------------
		
		protected function initialize():void {
		
		}
		
		protected function start():void {
			for each (var modifier:IBehaviourModifier in modifiers) {
				modifier.start();
			}
		}
		
		protected function step():void {
			for each (var modifier:IBehaviourModifier in modifiers) {
				modifier.step();
			}
		}
		
		protected function stop():void {
			for each (var modifier:IBehaviourModifier in modifiers) {
				modifier.stop();
			}
		}
	}
}