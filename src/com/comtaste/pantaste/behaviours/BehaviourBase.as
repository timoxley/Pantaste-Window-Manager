package com.comtaste.pantaste.behaviours {
	import com.comtaste.pantaste.behaviours.modifiers.IBehaviourModifier;
	
	import flash.events.IEventDispatcher;
	
	import mx.core.UIComponent;
	
	import org.osflash.signals.Signal;
	
	
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
			startTriggered = new Signal();
			stepTriggered = new Signal();
			stopTriggered = new Signal();
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
			
			var index:uint = modifiers.indexOf(modifier);
			
			if (index < 0) {
				throw new Error("Modifier not found in collection: " + modifier);
			}
			modifiers.splice(index, 1);
			modifier.enabled = false;
			modifier.behaviour = null;
		}
		
		//----------------------------------------------------------
		//
		//   Protected Functions 
		//
		//----------------------------------------------------------
		
		protected function initialize():void {
		
		}
		
		public var startTriggered:Signal;
		public var stepTriggered:Signal;
		public var stopTriggered:Signal;
		
		protected function start():void {
			startTriggered.dispatch();
			if (modifiers.length == 0) {
				return;
			}
			for each (var modifier:IBehaviourModifier in modifiers) {
				modifier.start();
			}
			
		}
		
		protected function step():void {
			stepTriggered.dispatch();
			if (modifiers.length == 0) {
				return;
			}
			for each (var modifier:IBehaviourModifier in modifiers) {
				modifier.step();
			}
		}
		
		protected function stop():void {
			
			if (modifiers.length == 0) {
				return;
			}
			for each (var modifier:IBehaviourModifier in modifiers) {
				modifier.stop();
			}
			stopTriggered.dispatch()
		}
	}
}