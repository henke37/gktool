package GKTool {
	
	import flash.display.*;
	import flash.text.*;
	
	public class ExtractScreen extends Sprite {
		
		public var selectDir_mc:Button;
		public var status_txt:TextField;
		public var progress_mc:ProgressBar;
		public var abort_mc:Button;
		public var menu_mc:Button;
		
		public function ExtractScreen() {
			selectDir_mc.label="Select directory";
			abort_mc.label="Abort";
			menu_mc.label="Back to menu";
		}
	}
	
}
