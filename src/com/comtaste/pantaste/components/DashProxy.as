package com.comtaste.pantaste.components {
	import com.comtaste.pantaste.components.skins.DashProxySkin;
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import mx.controls.SWFLoader;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.graphics.ImageSnapshot;
	
	import spark.components.Group;
	import spark.components.SkinnableContainer;
	
	[SkinState("snapshot")]
	[SkinState("bounds")]
	[Style(name="proxyStrokeColor", type="Number", format="Color")]
	[Style(name="proxyStrokeAlpha", type="Number", format="Number")]
	[Style(name="proxyColor", type="Number", format="Color")]
	[Style(name="proxyAlpha", type="Number", format="Number")]
	[Style(name="proxyStrokeWeight", type="Number", format="Number")]
	
	public class DashProxy extends SkinnableContainer {

		//----------------------------------------------------------
		//
		//   Static Properties 
		//
		//----------------------------------------------------------

		
		public static const MODE_BOUNDS:String = "boundsMode";
		
		public static const MODE_SNAPSHOT:String = "snapshotMode";

		//----------------------------------------------------------
		//
		//   Constructor 
		//
		//----------------------------------------------------------

		
		public function DashProxy() {
			addEventListener(FlexEvent.PREINITIALIZE, onPreInitialize);
			super();
		}


		//----------------------------------------------------------
		//
		//    Public Properties 
		//
		//----------------------------------------------------------

		
		[SkinPart(required="true")]
		public var bounds:Group;

		//--------------------------------------
		// mode 
		//--------------------------------------

		
		private var _mode:String;
		
		public function get mode():String {
			return _mode;
		}
		
		public function set mode(value:String):void {
			if (value == _mode) {
				return;
			}
			_mode = value;
			invalidateSkinState();
		}
		
		[SkinPart(required="true")]
		public var snapshot:Group;

		//--------------------------------------
		// targetElement 
		//--------------------------------------

		
		private var _targetElement:UIComponent;
		
		public function get targetElement():UIComponent {
			return _targetElement;
		}
		
		public function set targetElement(value:UIComponent):void {
			if (_targetElement == value) {
				return;
			}
			
			_targetElement = value;
			this.width = _targetElement.width;
			this.height = _targetElement.height;
			_targetElement.addEventListener(FlexEvent.UPDATE_COMPLETE, onUpdateComplete);
			/*this.x = _targetElement.x;
			 this.y = _targetElement.y;*/
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			//this.depth = targetElement.depth + 1;
			this.addEventListener(Event.ADDED, function(event:Event) {
				if (event.target == this.skin) {
					trace(Event.ADDED);
				}
			});
			this.addEventListener(Event.REMOVED, function(event:Event) {
				if (event.target == this.skin) {
					trace(Event.REMOVED);
				}
				
			});
		}

		//----------------------------------------------------------
		//
		//   Private Properties 
		//
		//----------------------------------------------------------

		
		private var swfLoader:SWFLoader;


		//----------------------------------------------------------
		//
		//   Public Functions 
		//
		//----------------------------------------------------------

		override public function invalidateSkinState():void {
			if (getCurrentSkinState() == 'snapshot' && snapshot) {
				createSnapshot();
			}
			super.invalidateSkinState();
		}
		
		public function onCreationComplete(event:FlexEvent):void {
			if (mode == MODE_SNAPSHOT) {
				createSnapshot();
			}
		}
		
		override public function setStyle(styleProp:String, newValue:*):void {
			
			super.setStyle(styleProp, newValue);
		}

		//----------------------------------------------------------
		//
		//   Protected Functions 
		//
		//----------------------------------------------------------

		
		override protected function getCurrentSkinState():String {
			if (mode == MODE_SNAPSHOT) {
				return 'snapshot';
			}
			
			if (mode == MODE_BOUNDS) {
				return 'bounds';
			}
			return super.getCurrentSkinState();
		
		}

		//----------------------------------------------------------
		//
		//    Private Functions 
		//
		//----------------------------------------------------------

		
		private function createSnapshot():void {
			if (mode == MODE_SNAPSHOT) {
				if (!swfLoader) {
					swfLoader = new SWFLoader();
				}
				
				if (targetElement && targetElement.visible && targetElement.initialized) {
					try {
						var imageSnap:ImageSnapshot = ImageSnapshot.captureImage(targetElement);
						
						var imageByteArray:ByteArray = ByteArray(imageSnap.data);
						
						swfLoader.load(imageByteArray);
						//swfLoader.smoothBitmapContent = true;
						snapshot.removeAllElements();
						snapshot.addElement(swfLoader);
					} catch (error:Error) {
						trace("Error taking snapshot!");
					}
					
					
				}
			}
		
		}
		
		private function onPreInitialize(event:FlexEvent):void {
			removeEventListener(FlexEvent.PREINITIALIZE, onPreInitialize);
			trace('adding skin: ' + com.comtaste.pantaste.components.skins.DashProxySkin);
			setStyle('skinClass', com.comtaste.pantaste.components.skins.DashProxySkin);
			setStyle('proxyStrokeColor', 0x000000);
			setStyle('proxyStrokeAlpha', 0.6);
			setStyle('proxyStrokeWeight', 1);
			setStyle('proxyColor', 0x000000);
			setStyle('proxyAlpha', 0.3);
			setStyle('targetAlpha', 0.3);
		
		}
		
		private function onUpdateComplete(event:FlexEvent):void {
			invalidateSkinState();
		}
	}
}