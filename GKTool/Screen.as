package GKTool {
	import flash.display.*;
	import flash.events.*;
	
	public class Screen extends Sprite {

		public function Screen() {
			addEventListener(Event.ADDED_TO_STAGE,added);
		}
		
		protected function get gkTool():GKTool {
			return GKTool(parent);
		}
		
		private function added(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE,added);
			init();
		}
		
		protected function init():void {
			
		}

	}
	
}
