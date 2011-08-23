package GKTool {
	
	import flash.display.*;
	import flash.events.*;
	
	public class BoxModeSelector extends MovieClip {
		
		private var _value:uint=0;
		
		public function BoxModeSelector() {
			stop();
			buttonMode=true;
			addEventListener(MouseEvent.CLICK,clicked);
		}
		
		private function clicked(e:MouseEvent) {
			value=(_value+1)%3;
			
		}
		
		public function get value():uint { return _value; }
		
		public function set value(v:uint):void {
			_value=v;
			gotoAndStop(_value+1);
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
	
}
