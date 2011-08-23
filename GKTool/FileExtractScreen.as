package GKTool {
	
	import Nitro.Compression.*;
	import Nitro.FileSystem.*;	
	import Nitro.*;
	import Nitro.GK.*;
	
	import flash.utils.*;
	import flash.net.*;
	
	public class FileExtractScreen extends ExtractBaseScreen {
		
		var archives:Vector.<GKArchive>;
		var archiveFileNames:Vector.<String>;
		
		var archiveFileIndex:uint;
		var archive:GKArchive;
		var archiveFileName:String;
		var subId:uint=0;
		var numberSize:uint;

		var table:Table;

		public function FileExtractScreen() {
			table=new Table();
			table.loadFromFile(new URLRequest("AAI2Jpn.tbl"));
		}
		
		protected override function beginExtraction():uint {
			var binFiles:Vector.<AbstractFile>=gkTool.nds.fileSystem.searchForFile(gkTool.nds.fileSystem.rootDir,/\.bin$/i,true);
			
			binFiles=binFiles.filter(blackList);
			
			var estimate:uint=0;
			
			archives=new Vector.<GKArchive>();
			archives.length=binFiles.length;
			archives.fixed=true;
			
			archiveFileNames=new Vector.<String>();
			archiveFileNames.length=binFiles.length;
			archiveFileNames.fixed=true;
			
			checkpoints=new Vector.<uint>();
			checkpoints.length=binFiles.length;
			checkpoints.fixed=true;
			
			var i:uint=0;
			
			for each(var archiveFile:File in binFiles) {
				archive=new GKArchive();
				archive.parse(gkTool.nds.fileSystem.openFileByReference(archiveFile));
				archiveFileName=gkTool.nds.fileSystem.getFullNameForFile(archiveFile);
				
				archives[i]=archive;
				archiveFileNames[i]=archiveFileName;
				
				estimate+=archive.length;
				checkpoints[i]=estimate;
				++i;
			}
			
			archiveFileIndex=0;
			archive=null;
			
			return estimate;
		}
		
		protected override function processNext():Boolean {
			
			++progress;
			
			if(!archive) {
				archive=archives[archiveFileIndex];
				archiveFileName=archiveFileNames[archiveFileIndex];
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
					log("Extracted \""+subFileName+"\"");
				}
			} catch (e:Error) {
				log("Failed to extract \""+subFileName+"\"!");
				++errors;
			}
			
			++subId;
			
			if(subId>=archive.length) {
				archive=null;
				++archiveFileIndex;
			}
			
			if(archiveFileIndex>=archives.length) {
				return false;
			}
			return true;
		}
		
		private function unpackSubArchive(fileName:String,fileData):void {
			
			log("File \""+fileName+"\" is a subarchive, unpacking...");
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
				log("Extracted \""+subFileName+"\"");
			}
			
			log("Subarchive unpacked successfully.");
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

	}
	
}
