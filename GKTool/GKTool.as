package GKTool {
	
	import flash.display.*;
	import flash.utils.*;
	
	import Nitro.FileSystem.*;
	import Nitro.GK.*;
	
	
	public class GKTool extends Sprite {
		
		internal var nds:NDS;
		
		private var _screen:Screen;
		private var _screenId:String;
		private var screens:Object;
		
		public static const version:String="v 3.5";

		public function GKTool() {			
			stage.align=StageAlign.TOP_LEFT;
			
			screens={};
			
			screen="MainMenu";
		}
		
		public function set screen(s:String):void {
			
			if(_screen) {
				removeChild(_screen);
			}
			
			_screenId=s;
			
			if(s in screens) {
				_screen=screens[s];
			} else {
				_screen=new (getDefinitionByName("GKTool."+s) as Class);
				screens[s]=_screen;
			}
			
			addChild(_screen);
			
		}
		
		private function screenList():void {
			throw new Error();
			FileExtractScreen;
			GraphicsExtractScreen;
			RepackScreen;
			SptExtractScreen;
			SPTRebuildScreen;
		}
		
		private var lastSubArchiveName:String,lastSubArchive:GKSubarchive;
		private var lastArchiveName:String,cachedArchive:GKArchive;
		private var lastFileName:String,cachedData:ByteArray;
		
		public function openGKPath(path:String):ByteArray {
			var file:File=File(nds.fileSystem.resolvePath(path,true));
			
			var fileName:String=nds.fileSystem.getFullNameForFile(file);
			
			var data:ByteArray;
			
			if(fileName!=lastFileName) {
				data=nds.fileSystem.openFileByReference(file);
				lastFileName=fileName;
				cachedData=data;
			} else {
				data=cachedData;
			}
			
			var archiveName:String=fileName;
			fileName=path.substr(fileName.length);
			
			var matches:Array=fileName.match(/^\/([0-9]+)(.*)/);
			if(matches) {
				var archive:GKArchive;
				
				if(archiveName!=lastArchiveName) {
					archive=new GKArchive();
					archive.parse(data);
					cachedArchive=archive;
					lastArchiveName=archiveName;
				} else {
					archive=cachedArchive;
				}
				
				data=archive.open(parseInt(matches[1]));
				fileName=matches[2];
				archiveName+="/"+matches[1];
			}
			
			matches=fileName.match(/^\/([0-9]+)(.*)/);
			if(matches) {
				var subArchive:GKSubarchive;
				if(lastSubArchiveName!=archiveName) {
					subArchive=new GKSubarchive();
					subArchive.parse(data);
					lastSubArchive=subArchive;
					lastSubArchiveName=archiveName;
				} else {
					subArchive=lastSubArchive;
				}
								
				data=subArchive.open(parseInt(matches[1]));
				fileName=matches[2];
			}
			
			return data;
		}

	}
	
}
