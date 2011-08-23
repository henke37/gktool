package GKTool.Editor {
	import flash.events.*;
	
	public function numberFocusLost(e:FocusEvent):void {
		if(e.currentTarget.text=="") {
			e.currentTarget.text="0";
		}
	}
}