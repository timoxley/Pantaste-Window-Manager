package com.comtaste.pantaste.components {
	import com.comtaste.pantaste.components.skins.DashProxySkin;
	
	import flash.system.Capabilities;
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
		
		private var _snapshotInvalidated:Boolean = true;
		
		public function invalidateSnapshot():void {
			_snapshotInvalidated = true;
		}
		
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
			//this.width = _targetElement.measuredWidth;
			//this.height = _targetElement.measuredHeight;
			//this.scaleX = _targetElement.scaleX;
			//this.scaleY = _targetElement.scaleY;
			
			_targetElement.addEventListener(FlexEvent.UPDATE_COMPLETE,
											onUpdateComplete);
			//this.x = _targetElement.x;
			// this.y = _targetElement.y;
			this.addEventListener(FlexEvent.CREATION_COMPLETE,
								  onCreationComplete);
			//this.depth = targetElement.depth + 1;
		}
		
		private var _snapshotTarget:UIComponent;
		
		public function get snapshotTarget():UIComponent {
			if (_snapshotTarget) {
				return _snapshotTarget;
			} else {
				return targetElement;
			}
		
		}
		
		public function set snapshotTarget(value:UIComponent):void {
			_snapshotTarget = value;
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
			/*	if (getCurrentSkinState() == 'snapshot' && snapshot) {
			   createSnapshot();
			 }*/
			super.invalidateSkinState();
		}
		
		public function onCreationComplete(event:FlexEvent):void {
			this.removeEventListener(FlexEvent.CREATION_COMPLETE,
				onCreationComplete);
			createSnapshot();
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
		

		public function createSnapshot():void {
			/*if (!_snapshotInvalidated) {
				return;
			}*/
			
			if (!swfLoader) {
				swfLoader = new SWFLoader();
				swfLoader.smoothBitmapContent = true;
				swfLoader.cacheAsBitmap = true;
			}

			
			if (_snapshotTarget && _snapshotTarget.visible &&
				_snapshotTarget.initialized) {
			//	try {
					var imageSnap:ImageSnapshot =
						ImageSnapshot.captureImage(_snapshotTarget, Capabilities.screenDPI, null, false);
					//Capabilities.
					var imageByteArray:ByteArray = ByteArray(imageSnap.data);
					
					swfLoader.load(imageByteArray);
					if (snapshot) {
						snapshot.removeAllElements();
						snapshot.addElement(swfLoader);
					}
					
					
					//snapshot.addElement(swfLoader);
					
				//} catch (error:Error) {
				//	trace("Error taking snapshot: " + error.message);
				//}
			}
			_snapshotInvalidated = false;
		
		}
		
		override protected function partAdded(partName:String, instance:Object) : void {
			if (instance == snapshot) {
				snapshot.addElement(swfLoader);
			}
		}
		
		private function onPreInitialize(event:FlexEvent):void {
			removeEventListener(FlexEvent.PREINITIALIZE, onPreInitialize);
			setStyle('skinClass',
					 com.comtaste.pantaste.components.skins.DashProxySkin);
			setStyle('proxyStrokeColor', 0xFFFFFF);
			setStyle('proxyStrokeAlpha', 0.6);
			setStyle('proxyStrokeWeight', 1);
			setStyle('proxyColor', 0xFFFFFF);
			setStyle('proxyAlpha', 0.3);
			setStyle('targetAlpha', 0.3);
		
		}
		
		private function onUpdateComplete(event:FlexEvent):void {
			createSnapshot();
		}
		
		override public function set x(value:Number):void {
			
			super.x = value;
		}
	}
}
