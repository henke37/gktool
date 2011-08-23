package GKTool {
	
	import flash.display.*;
	import flash.events.*;
	
	public class StaticButton extends MovieClip {
		
		public function StaticButton() {
			enabled=true;
		}
		
		public override function set enabled(e:Boolean):void {
			gotoAndStop(e?"Enabled":"Disabled");
			buttonMode=e;
			if(e) {
				removeEventListener(MouseEvent.CLICK,stopEvent);
			} else {
				addEventListener(MouseEvent.CLICK,stopEvent,false,90);
			}
		}
		
		private function stopEvent(e:Event):void {
			e.stopImmediatePropagation();
		}
		
		public override function get enabled():Boolean { return buttonMode; }
	}
	
}
