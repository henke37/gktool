package GKTool {
	
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import flash.net.FileReference;
	import flash.net.FileFilter;
	
	import Nitro.FileSystem.*;
	
	public class RomLoader extends EventDispatcher {
		
		private var fr:FileReference;
		
		private var menu:MainMenu;
		
		public function RomLoader(m:MainMenu) {
			menu=m;
			menu.loadRom_mc.addEventListener(MouseEvent.CLICK,clickLoad);
		}
		
		private function clickLoad(e:MouseEvent):void {
			
			fr=new FileReference();
			fr.addEventListener(Event.SELECT,fileSelected);
			fr.browse([new FileFilter("Nitro games","*.nds")]);
		}
		
		private function fileSelected(e:Event):void {
			menu.loadRom_mc.removeEventListener(MouseEvent.CLICK,clickLoad);
			
			fr.addEventListener(Event.COMPLETE,frLoaded);
			menu.status_txt.text="Loading data...";
			fr.load();
			
		}
		
		private function frLoaded(e:Event):void {
			var nds:NDS;
			try {
				nds=new NDS();
				nds.parse(fr.data);
				
				if(nds.gameCode!="BXOJ") {
					throw new Error("Wrong game loaded");
				}
				
			} catch(err:Error) {
				menu.status_txt.text="Loading failed:\n"+err.message;
				menu.loadRom_mc.addEventListener(MouseEvent.CLICK,clickLoad);
				return;
			}
			
			menu.status_txt.text="ROM Loaded.";
			
			gkTool.nds=nds;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function get gkTool():GKTool {
			return GKTool(menu.parent);
		}
	}
	
}
