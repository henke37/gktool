package GKTool {
	import flash.display.*;
	import flash.events.*;
	
	public class ToggleButton extends MovieClip {
		
		private var _selected:Boolean;

		public function ToggleButton() {
			buttonMode=true;
			selected=false;
			addEventListener(MouseEvent.CLICK,toggle);
		}
		
		private function toggle(e:MouseEvent):void {
			selected=!_selected;
		}
		
		public function get selected():Boolean {return _selected;}
		public function set selected(s:Boolean):void {
			_selected=s;
			gotoAndStop(_selected?"Selected":"Unselected");
			dispatchEvent(new Event(Event.CHANGE));
		}

	}
	
}
