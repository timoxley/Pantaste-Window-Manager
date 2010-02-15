package com.comtaste.pantaste.behaviours {
	import com.comtaste.pantaste.selection.ISelectable;
	import com.comtaste.pantaste.selection.SelectionController;
	
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	
	public class SelectBehaviour extends BehaviourBase {
		
		//----------------------------------------------------------
		//
		//   Constructor 
		//
		//----------------------------------------------------------
		
		public function get isSelected():Boolean
		{
			if (selectionController) {
				return selectionController.isSelected(this.selectData);
			} else {
				return false;
			}
		}

		public function SelectBehaviour(triggerEvent:String, target:UIComponent,
										dispatcher:IEventDispatcher=null) {
			super(triggerEvent, target, dispatcher);
		}
		
		//----------------------------------------------------------
		//
		//    Public Properties 
		//
		//----------------------------------------------------------
		
		public var selectData:ISelectable;
		
		[Inject]
		private var _selectionController:SelectionController;

		public function get selectionController():SelectionController
		{
			return _selectionController;
		}

		public function set selectionController(value:SelectionController):void
		{
			_selectionController = value;
			
		}
		
		private function invalidateDisplay():void {
			if (target is SkinnableComponent) {
				SkinnableComponent(target).invalidateSkinState();
			} else {
				target.invalidateDisplayList();
			}
		}
		
		public function onItemDeselected(item:ISelectable):void {
			if (item == selectData) {
				selectionController.itemDeselected.remove(onItemDeselected);
				invalidateDisplay();
				
			}
		}
		
		//----------------------------------------------------------
		//
		//   Protected Functions 
		//
		//----------------------------------------------------------
		
		override protected function initialize():void {
			super.dispatcher.addEventListener(triggerEvent, onSelectTriggered);
			super.initialize();
		}
		
		public function select():void {
			
			selectionController.select(selectData);
			selectionController.itemDeselected.add(onItemDeselected);
			invalidateDisplay();
		}
		
		//----------------------------------------------------------
		//
		//    Private Functions 
		//
		//----------------------------------------------------------
		
		private function onSelectTriggered(event:MouseEvent):void {
			select();
			invalidateDisplay();
			event.stopPropagation();
		}
	}
}