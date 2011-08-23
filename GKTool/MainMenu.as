package GKTool {
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	
	public class MainMenu extends Screen {
		
		public var header_txt:TextField;
		
		public var loadRom_mc:Button;
		public var extractFiles_mc:Button;
		public var extractChars_mc:Button;
		public var rebuild_mc:Button;
		public var convertImg_mc:Button;
		public var editor_mc:Button;
		public var spt_mc:Button;
		public var sptBuild_mc:Button;
		
		public var icon_mc:Sprite;
		
		public var status_txt:TextField;
		
		private var romLoader:RomLoader;
		
		public function MainMenu() {
			
		}
		
		protected override function init():void {
			
			romLoader=new RomLoader(this);
			romLoader.addEventListener(Event.COMPLETE,loaded);
			
			header_txt.text=header_txt.text.replace("$v",GKTool.GKTool.version)
			
			loadRom_mc.label="Load ROM";
			extractFiles_mc.label="Extract Files";
			extractFiles_mc.addEventListener(MouseEvent.CLICK,fileExtract);
			extractFiles_mc.enabled=false;
			extractChars_mc.label="Extract Graphics";
			extractChars_mc.addEventListener(MouseEvent.CLICK,graphicsExtract);
			extractChars_mc.enabled=false;
			rebuild_mc.label="Rebuild archive";
			rebuild_mc.addEventListener(MouseEvent.CLICK,rebuild);
			convertImg_mc.label="Convert image";
			convertImg_mc.addEventListener(MouseEvent.CLICK,convert);
			editor_mc.label="NCER Editor";
			editor_mc.addEventListener(MouseEvent.CLICK,editor);
			editor_mc.enabled=false;
			spt_mc.enabled=false;
			spt_mc.label="Decode SPT files";
			spt_mc.addEventListener(MouseEvent.CLICK,sptExtract);
			sptBuild_mc.label="Rebuild SPT files";
			sptBuild_mc.addEventListener(MouseEvent.CLICK,sptBuild);
			//sptBuild_mc.enabled=false;
		}
		
		private function sptBuild(e:MouseEvent):void {
			gkTool.screen="SPTRebuildScreen";
		}
		
		private function sptExtract(e:MouseEvent):void {
			gkTool.screen="SptExtractScreen";
		}
		
		private function fileExtract(e:MouseEvent):void {
			gkTool.screen="FileExtractScreen";
		}
		
		private function graphicsExtract(e:MouseEvent):void {
			gkTool.screen="GraphicsExtractScreen";
		}
		
		private function rebuild(e:MouseEvent):void {
			gkTool.screen="RepackScreen";
		}
		
		private function convert(e:MouseEvent):void {
			gkTool.screen="ImageConverter";
		}
		
		private function editor(e:MouseEvent):void {
			gkTool.screen="Editor.Editor";
		}
		
		private function loaded(e:Event):void {
			icon_mc.addChild(new Bitmap(gkTool.nds.banner.icon));
			loadRom_mc.enabled=false;
			extractFiles_mc.enabled=true;
			extractChars_mc.enabled=true;
			editor_mc.enabled=true;
			spt_mc.enabled=true;
		}
	}
	
}
