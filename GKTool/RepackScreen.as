package GKTool {
	
	import flash.utils.*;
	import flash.filesystem.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.*;
	
	import Nitro.GK.*;
	
	public class RepackScreen extends Screen {
		
		public var selectDir_mc:Button;
		public var menu_mc:Button;
		public var status_txt:TextField;
		
		private var inDir:File;
		
		private var files:Array;
		private var fileData:Vector.<ByteArray>;
		private var archive:GKArchive;
		
		private var fileIndex:uint;

		public function RepackScreen() {
		}
		
		protected override function init():void {
			
			selectDir_mc.label="Select directory";
			selectDir_mc.addEventListener(MouseEvent.CLICK,selectClick);
			
			menu_mc.label="Back to menu";
			menu_mc.addEventListener(MouseEvent.CLICK,menuClick);
		}
		
		private function menuClick(e:MouseEvent):void {
			gkTool.screen="MainMenu";
		}
		
		private function selectClick(e:MouseEvent):void {
			inDir=new File();
			inDir.addEventListener(Event.SELECT,selected);
			inDir.browseForDirectory("Directory to pack");
		}
		
		private function selected(e:Event):void {
			trace(inDir.name);
			if(!inDir.name.match(/\.bin$/i)) {
				status_txt.text="Incorrect folder, it should belong to an extracted \"*.bin\" archive.";
				return;
			}
			
			buildArchive();
			
			saveArchive();
			
			status_txt.text="";
		}
		
		private function buildArchive():void {
			files=inDir.getDirectoryListing();
			
			archive=new GKArchive();
			
			fileData=new Vector.<ByteArray>();
			fileData.length=files.length;
			fileData.fixed=true;
			
			for(fileIndex=0;fileIndex<files.length;++fileIndex) {
				addFile(files[fileIndex]);
			}
			var startTime:uint=getTimer();
			archive.build(fileData);
			trace(getTimer()-startTime);
		}
		
		private function addFile(file:File):void {
			//trace(file.name,file.isDirectory);
			
			var data:ByteArray;
			
			if(file.isDirectory) {
				data=buildSubArchive(file);
			} else {
				var stream:FileStream=new FileStream();
				stream.open(file,FileMode.READ);
				data=new ByteArray();
				stream.readBytes(data);
			}
			fileData[fileIndex]=data;
		}
		
		private function buildSubArchive(file:File):ByteArray {
			var subFiles:Array=file.getDirectoryListing();
			
			var subData:Vector.<ByteArray>=new Vector.<ByteArray>();
			subData.length=subFiles.length;
			subData.fixed=true;
			
			var i:uint=0;
			for each(var subFile:File in subFiles) {
				var stream:FileStream=new FileStream();
				var data:ByteArray=new ByteArray();;
				stream.open(subFile,FileMode.READ);
				stream.readBytes(data);
				subData[i++]=data;
			}
			
			var subArchive:GKSubarchive=new GKSubarchive();
			subArchive.build(subData);
			
			return subArchive.data;
			
		}
		
		private function saveArchive():void {
			var fr:FileReference=new FileReference();
			fr.save(archive.data,inDir.name);
		}

	}
	
}
