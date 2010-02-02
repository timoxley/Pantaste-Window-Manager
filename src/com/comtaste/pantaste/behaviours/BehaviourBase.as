package com.comtaste.pantaste.behaviours {
	import flash.events.IEventDispatcher;
	
	import mx.core.UIComponent;
	
	
	public class BehaviourBase {
		
		public var enabled:Boolean = true;
		
		//----------------------------------------------------------
		//
		//   Constructor 
		//
		//----------------------------------------------------------
		
		public function BehaviourBase(triggerEvent:String, target:UIComponent, dispatcher:IEventDispatcher=null) {
			this.triggerEvent = triggerEvent;
			this.target = target;
			
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
		//   Protected Functions 
		//
		//----------------------------------------------------------
		protected function initialize():void {
		
		}
	}
}