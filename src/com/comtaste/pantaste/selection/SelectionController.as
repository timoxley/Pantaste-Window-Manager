package com.comtaste.pantaste.selection {
	
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.core.FlexGlobals;
	
	import org.osflash.signals.Signal;
	
	public class SelectionController {
		
		//----------------------------------------------------------
		//
		//   Constructor 
		//
		//----------------------------------------------------------
		
		public function SelectionController() {
			selected = new Vector.<ISelectable>();
			itemSelected = new Signal(ISelectable);
			itemDeselected = new Signal(ISelectable);
			selectionChanged = new Signal();
		}
		
		public var itemSelected:Signal;
		public var itemDeselected:Signal;
		public var selectionChanged:Signal;
		
		public var ignoreNullSelections:Boolean = true;
		
		//----------------------------------------------------------
		//
		//    Public Properties 
		//
		//----------------------------------------------------------
		
		public function get hasSelection():Boolean {
			return (selected.length > 0);
		
		}
		
		private var _interactionDispatcher:IEventDispatcher;
		
		public function get interactionDispatcher():IEventDispatcher {
			return _interactionDispatcher;
		}
		
		public function set interactionDispatcher(value:IEventDispatcher):void {
			_interactionDispatcher = value;
			
			_interactionDispatcher.addEventListener(KeyboardEvent.KEY_DOWN,
													function(event:KeyboardEvent):void {
				
					switch (event.charCode) {
						
						case Keyboard.ESCAPE:
							deselectAll();
							break;
						
						case Keyboard.CONTROL:
							controlDown = true;
							break;
						default:
							trace(event.charCode);
					
					}
				});
			
			_interactionDispatcher.addEventListener(KeyboardEvent.KEY_UP,
													function(event:KeyboardEvent):void {
					switch (event.charCode) {
						case Keyboard.CONTROL:
							controlDown = false;
							break;
					}
				});
		}
		
		public var selected:Vector.<ISelectable>;
		
		public var defaultSelection:ISelectable;
		
		//----------------------------------------------------------
		//
		//   Private Properties 
		//
		//----------------------------------------------------------
		
		private var controlDown:Boolean = false;
		
		//----------------------------------------------------------
		//
		//   Public Functions 
		//
		//----------------------------------------------------------
		
		public function deselect(item:ISelectable):void {
			if (isSelected(item)) {
				selected.splice(selected.indexOf(item), 1);
				
				itemDeselected.dispatch(item);		
				selectionChanged.dispatch();
			}
		
		}
		
		public function deselectAll():void {
			if (selected.length > 0) {
				for each (var item:ISelectable in selected) {
					deselect(item);
				}
			}
		}
		
		[PostConstruct]
		public function init():void {
			interactionDispatcher = IEventDispatcher(FlexGlobals.topLevelApplication);
			selectDefault();
		}
		
		public function isSelected(item:ISelectable):Boolean {
			var index:int = selected.indexOf(item);
			return (!(index == -1));
		}
		
		public function select(item:ISelectable):void {		
			if (!isSelected(item)) {
				if (controlDown) {
					selectMulti(item);
				} else {
					selectOne(item);
				}
				itemSelected.dispatch(item);
				
				selectionChanged.dispatch();
			}
		}
		
		public function selectDefault():void {
			if (defaultSelection) {
				selectOne(defaultSelection);
			}
		}
		
		protected function selectMulti(item:ISelectable):void {
			selectItem(item);
		}
		
		protected function selectOne(item:ISelectable):void {
			
			deselectAll();
			
			selectItem(item);
		
		}
		
		//----------------------------------------------------------
		//
		//    Private Functions 
		//
		//----------------------------------------------------------
		
		protected function selectItem(item:ISelectable):void {
			if (!item) {
				if (ignoreNullSelections) {
					return;
				} else {
					throw new Error("Trying to select null!?");
				}
			}
			
			if (!isSelected(item)) {
				selected.push(item);
			}
		
		}
	}
}