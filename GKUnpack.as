package  {
	
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.text.*;
	import flash.utils.*;
	import flash.filesystem.*;
	
	import Nitro.Compression.*;
	import Nitro.FileSystem.*;	
	import Nitro.*;
	import Nitro.GK.*;
	
	public class GKUnpack extends MovieClip {
		
		private var loader:URLLoader;
		
		private var nds:NDS;
		
		public var status_txt:TextField;
		
		private static const iconZoom:Number=10;
		private static const titleHeight:Number=40;
		
		public function GKUnpack() {			
			
			if(loaderInfo.url.match(/^file:/) && false) {
				status_txt.text="Loading data";
				loader=new URLLoader();
				loader.addEventListener(Event.COMPLETE,loaded);
				loader.dataFormat=URLLoaderDataFormat.BINARY;
				loader.load(new URLRequest("game.nds"));
			} else {
				status_txt.text="Click to load game from disk";
				stage.addEventListener(MouseEvent.CLICK,stageClick);
			}
		}
		
		var fr:FileReference;
		
		private function stageClick(e:MouseEvent):void {
			
			fr=new FileReference();
			fr.addEventListener(Event.SELECT,fileSelected);
			fr.browse([new FileFilter("Nitro games","*.nds")]);
		}
		
		private function fileSelected(e:Event):void {
			stage.removeEventListener(MouseEvent.CLICK,stageClick);
			
			fr.addEventListener(Event.COMPLETE,frLoaded);
			status_txt.text="Loading data";
			fr.load();
			
		}
		
		private function frLoaded(e:Event):void {	
			nds=new NDS();
			nds.parse(fr.data);
			setup();
		}
		
		private function loaded(e:Event):void {
			nds=new NDS();
			nds.parse(loader.data);
			setup();
		}
		
		private function setup():void {
			
			//testOne();
			//listAll();
			extractAll();
			//countSubFiles();
		}
		
		private function testOne():void {
			var archiveData:ByteArray=nds.fileSystem.openFileByName("com/save.bin");
			var archive:GKArchive=new GKArchive();
			archive.parse(archiveData);
			
			archive.open(0);
			
			status_txt.text="Loaded "+archive.length+" files.";
		}
		
		private function blackList(item:AbstractFile, index:int, vector:Vector.<AbstractFile>):Boolean {
			switch(item.name) {
				case "movie.bin":
				case "font.bin":
				case "serial.bin":
					return false;
				break;
				
				default:
					return true;
				break;
			}
		}

		
		private function listAll():void {
			var binFiles:Vector.<AbstractFile>=nds.fileSystem.searchForFile(nds.fileSystem.rootDir,/\.bin$/i,true);
			
			var list:XML=<fileList />;
			
			var fileCount:uint;
			
			for each(var archiveFile:Nitro.FileSystem.File in binFiles) {
				var archive:GKArchive=new GKArchive();
				archive.parse(nds.fileSystem.openFileByReference(archiveFile));
				var archiveXML:XML=<archive fileCount={archive.length} name={nds.fileSystem.getFullNameForFile(archiveFile)} />;
				
				for(var subid in archive.fileList) {
					var subFile=archive.fileList[subid];
					archiveXML.appendChild(<subFile id={subid} compressed={subFile.compressed?"Yes":"No"} size={subFile.size} />);
				}
				
				list.appendChild(archiveXML);
			}
			
			trace(list);
		}
		
		private function countSubFiles():void {
			var binFiles:Vector.<AbstractFile>=nds.fileSystem.searchForFile(nds.fileSystem.rootDir,/\.bin$/i,true);
			
			var fileCount:uint;
			
			for each(var archiveFile:Nitro.FileSystem.File in binFiles) {
				var archive:GKArchive=new GKArchive();
				archive.parse(nds.fileSystem.openFileByReference(archiveFile));
				fileCount+=archive.length;
			}
			
			trace(fileCount);
		}
		
		var outDir:flash.filesystem.File;
		
		private function extractAll():void {
			outDir=new flash.filesystem.File();
			outDir.addEventListener(Event.SELECT,dirSelected);
			outDir.browseForDirectory("Output dir");
		}
		
		private function dirSelected(e:Event):void {
			initExtraction();
		}
			
		private function initExtraction():void {
			
			binFiles=nds.fileSystem.searchForFile(nds.fileSystem.rootDir,/\.bin$/i,true);
			
			binFiles=binFiles.filter(blackList);
			
			status_txt.text="Unpacking "+binFiles.length+" files...\n";
			
			if(extractSomeFiles()) {
				addEventListener(Event.ENTER_FRAME,extractMoreFiles);
			}
		}
		
		private function extractMoreFiles(e:Event):void {
			if(!extractSomeFiles()) {
				removeEventListener(Event.ENTER_FRAME,extractMoreFiles);
			}
		}
		
		private function extractSomeFiles():Boolean {
			var stopTime:uint=getTimer()+20;
			do {
				if(!extractNextFile()) {
					status_txt.appendText("Done, had "+errors+" errors");
					status_txt.scrollV=status_txt.maxScrollV;
					return false;
				}
			} while(getTimer()<stopTime);
			return true;
		}
		
		var binFiles:Vector.<AbstractFile>;
		var archiveFileName:String;
		var archiveFileIndex:uint;
		var archive:GKArchive;
		var subId:uint=0;
		var errors:uint;
		var numberSize:uint;
		
		private function extractNextFile():Boolean {
			
			if(!archive) {
				var archiveFile:Nitro.FileSystem.File=Nitro.FileSystem.File(binFiles[archiveFileIndex]);
				archiveFileName=nds.fileSystem.getFullNameForFile(archiveFile);
				
				archive=new GKArchive();
				archive.parse(nds.fileSystem.openFileByReference(archiveFile));
				
				numberSize=archive.length.toString().length;
				
				subId=0;
			}
			
			var subFileName:String=archiveFileName+"/"+padNumber(subId,numberSize);
			
			try {
				var subFile:ByteArray=archive.open(subId);
								
				subFile.position=0;
				var type:String=sniffExtension(subFile,subFileName);
				
				subFile.position=0;
				
				if(type=="subarchive") {
					unpackSubArchive(subFileName,subFile);
				} else {
					subFileName+="."+type;
					saveFile(subFileName,subFile);
					status_txt.appendText("Extracted \""+subFileName+"\"\n");
				}
			} catch (e:Error) {
				status_txt.appendText("Failed to extract \""+subFileName+"\"!\n");
				++errors;
			}
			status_txt.scrollV=status_txt.maxScrollV;
			
			++subId;
			
			if(subId>=archive.length) {
				archive=null;
				++archiveFileIndex;
			}
			
			if(archiveFileIndex>=binFiles.length) {
				return false;
			}
			return true;
		}
		
		private function unpackSubArchive(fileName:String,fileData):void {
			
			status_txt.appendText("File \""+fileName+"\" is a subarchive, unpacking...\n");
			var subArchive:GKSubarchive=new GKSubarchive();
			subArchive.parse(fileData);
			
			for(var i:uint=0;i<subArchive.length;++i) {
				var subData:ByteArray=subArchive.open(i);
				var subFileName:String=fileName+"/"+i;
				
				subData.position=0;
				var type:String=sniffExtension(subData,subFileName);
				subFileName+="."+type;
				
				subData.position=0;
				saveFile(subFileName,subData);
				status_txt.appendText("Extracted \""+subFileName+"\"\n");
			}
			
			status_txt.appendText("Subarchive unpacked successfully.\n");
		}
		
		private function sniffExtension(data:ByteArray,name:String):String {
			
			//false positives
			//if(name.indexOf("anmseq_chr.bin/")!=-1) return "bin";
			//if(name.indexOf("bustanmseq_chr.bin/")!=-1 return "bin";
			
			if(data.length<4) return "bin";
			
			data.endian=Endian.LITTLE_ENDIAN;
			
			var id:String=data.readUTFBytes(4);
			
			if(!id.match(/[ a-z0-9]{4}/i)) {
				
				data.position=0;
				var firstInt:uint=data.readUnsignedInt();
				if((firstInt%4)==0 && (firstInt/4) == 3) {
					return "subarchive";
				}
				
				return "bin";
			}
			
			id=id.replace(" ","").toLowerCase();
			
			switch(id) {
				case "bmd0":
					return "nsbmd";
				break;
				
				case "btx0":
					return "nsbtx";
				break;
				
				case "bca0":
					return "nsbca";
				break;
				
				default:
					return (id.charAt(3)+id.charAt(2)+id.charAt(1)+id.charAt(0));
				break;
			}
			
			
		}
		
		private function saveFile(name:String,data:ByteArray):void {
			name=name.replace("/",flash.filesystem.File.separator);
			var outFile:flash.filesystem.File=new flash.filesystem.File(outDir.nativePath+flash.filesystem.File.separator+name);
			var fileStream:FileStream=new FileStream();
			fileStream.open(outFile,FileMode.WRITE);
			fileStream.writeBytes(data,0);
		}
		
		private function padNumber(number:uint,size:uint):String {
			var o:String=number.toString();
			while(o.length<size) {
				o="0"+o;
			}
			return o;
		}
	}
	
}
