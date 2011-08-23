package GKTool {
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.utils.*;
	
	public class ExtractBaseScreen extends Screen {
		
		protected var outDir:File;
		
		public var errors:uint;
		
		protected var realScreen:ExtractScreen;
		
		protected var fileCount:uint;
		
		private var startTime:uint;
		
		

		public function ExtractBaseScreen() {
			realScreen=new ExtractScreen();
			addChild(realScreen);
		}
		
		protected final override function init():void {
			realScreen.selectDir_mc.addEventListener(MouseEvent.CLICK,selectDir);
			realScreen.abort_mc.visible=false;
			realScreen.abort_mc.addEventListener(MouseEvent.CLICK,abort);
			realScreen.menu_mc.addEventListener(MouseEvent.CLICK,menu);
		}
		
		protected function selectDir(e:MouseEvent):void {
			outDir=new File();
			outDir.addEventListener(Event.SELECT,dirSelected);
			outDir.browseForDirectory("Output dir");
		}
		
		protected final function dirSelected(e:Event):void {
			realScreen.selectDir_mc.visible=false;
			initExtraction();
		}
		
		private function initExtraction():void {
			
			realScreen.abort_mc.visible=true;
			realScreen.menu_mc.visible=false;
			
			startTime=getTimer();
			
			realScreen.progress_mc.total=beginExtraction();
			
			realScreen.status_txt.text="";
			
			if(extractSomeFiles()) {
				addEventListener(Event.ENTER_FRAME,extractMoreFiles);
			}
		}
		
		private function abort(e:MouseEvent):void {
			endOperation();
			log("Operation aborted!");
		}
		
		private function menu(e:MouseEvent):void {
			gkTool.screen="MainMenu";
		}
		
		private function endOperation():void {
			removeEventListener(Event.ENTER_FRAME,extractMoreFiles);
			realScreen.abort_mc.visible=false;
			realScreen.menu_mc.visible=true;
		}
		
		protected function beginExtraction():uint { return 0}
		
		protected function processNext():Boolean {
			return false;
		}
		
		private function extractMoreFiles(e:Event):void {
			if(!extractSomeFiles()) {
				endOperation();
			}
		}
		
		private function extractSomeFiles():Boolean {
			var stopTime:uint=getTimer()+20;
			do {
				if(!processNext()) {
					log("Done, had "+errors+" errors and took "+Math.ceil((getTimer()-startTime)/1000)+" seconds.");
					return false;
				}
			} while(getTimer()<stopTime);
			return true;
		}
		
		protected final function log(t:String):void {
			realScreen.status_txt.appendText(t+"\n");
			realScreen.status_txt.scrollV=realScreen.status_txt.maxScrollV;
		}
		
		protected final function saveFile(name:String,data:ByteArray):void {
			name=name.replace("/",File.separator);
			var outFile:flash.filesystem.File=new File(outDir.nativePath+File.separator+name);
			saveFileByRef(outFile,data);
		}
		
		protected final function saveFileByRef(outFile:File,data:ByteArray):void {
			var fileStream:FileStream=new FileStream();
			fileStream.open(outFile,FileMode.WRITE);
			fileStream.writeBytes(data,0);
		}
		
		protected final function saveXMLFile(name:String,data:XML):void {
			var o:ByteArray=new ByteArray();
			o.writeUTFBytes(data.toXMLString());
			saveFile(name,o);
		}
		
		protected static function padNumber(number:uint,size:uint):String {
			var o:String=number.toString();
			while(o.length<size) {
				o="0"+o;
			}
			return o;
		}
		
		protected function get progress():uint { return realScreen.progress_mc.progress; }
		protected function set progress(p:uint):void { realScreen.progress_mc.progress=p; }
		protected function get checkpoints():Vector.<uint> { return realScreen.progress_mc.checkpoints; }
		protected function set checkpoints(c:Vector.<uint>):void { realScreen.progress_mc.checkpoints=c; }
	}
	
}
