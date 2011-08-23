package GKTool.Editor {
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.ui.*;
	
	public class FileSelector extends Sprite {
		
		public var nclr_txt:TextField;
		public var ncgr_txt:TextField;
		public var ncer_txt:TextField;
		public var frame_txt:TextField;
		
		public var framePlus_mc:MovieClip;
		public var frameMinus_mc:MovieClip;
		
		public var saveNCER_btn:SimpleButton;
		
		public function FileSelector() {
			nclr_txt.addEventListener(KeyboardEvent.KEY_DOWN,checkEnter);
			ncgr_txt.addEventListener(KeyboardEvent.KEY_DOWN,checkEnter);
			ncer_txt.addEventListener(KeyboardEvent.KEY_DOWN,checkEnter);
			frame_txt.addEventListener(KeyboardEvent.KEY_DOWN,checkEnter);
			frame_txt.addEventListener(FocusEvent.FOCUS_OUT,numberFocusLost);
			
			framePlus_mc.addEventListener(MouseEvent.CLICK,nextFrame);
			frameMinus_mc.addEventListener(MouseEvent.CLICK,prevFrame);
			
			saveNCER_btn.addEventListener(MouseEvent.CLICK,saveClick);
		}
		
		public function updateCellNr():void {
			
			framePlus_mc.enabled=editor.currentCell+1<editor.ncer.length;			
			frameMinus_mc.enabled=editor.currentCell!=0;
			
			frame_txt.text=String(editor.currentCell);
		}
		
		private function nextFrame(e:MouseEvent):void {
			editor.loadCell(editor.currentCell+1);
		}
		
		private function prevFrame(e:MouseEvent):void {
			editor.loadCell(editor.currentCell-1);
		}
		
		private function checkEnter(e:KeyboardEvent):void {
			if(e.keyCode==Keyboard.ENTER) {
				load();
			}
		}
		
		public function load(e:Event=null):void {
			editor.loadFiles(nclr_txt.text,ncgr_txt.text,ncer_txt.text);
			editor.loadCell(parseInt(frame_txt.text));
		}
		
		private function saveClick(e:Event=null):void {
			editor.saveNCER();
		}
		
		private function get editor():Editor { return Editor(parent); }
	}
	
}
