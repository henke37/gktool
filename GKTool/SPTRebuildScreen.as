package GKTool {
	import Nitro.GK.*;
	
	import flash.events.*;
	import flash.utils.*;
	import flash.net.*;
	import flash.filesystem.*;
	
	public class SPTRebuildScreen extends ExtractBaseScreen {
		
		private var archive:GKArchive;
		
		private var sptFiles:Vector.<SPTFileEntry>;
		
		private var table:Table;

		public function SPTRebuildScreen() {
			archive=new GKArchive();
			table=new Table();
			table.addEventListener(Event.COMPLETE,tableLoaded);
			table.loadFromFile(new URLRequest("AAI2Jpn.tbl"));
			
			realScreen.selectDir_mc.enabled=false;
		}
		
		private function tableLoaded(e:Event):void {
			realScreen.selectDir_mc.enabled=true;
		}
		
		protected override function selectDir(e:MouseEvent):void {
			outDir=new File();
			outDir.addEventListener(Event.SELECT,dirSelected);
			outDir.browseForDirectory("Input dir");
		}
		
		protected override function beginExtraction():uint {
			sptFiles=new Vector.<SPTFileEntry>();
			
			var files:Array=outDir.getDirectoryListing();
			
			checkpoints=new Vector.<uint>();
			
			var totalWork:uint=0;
			
			for each(var subFile:File in files) {
				var entry:SPTFileEntry=new SPTFileEntry();
				entry.id=parseInt(subFile.name.match(/^([0-9]+)/)[1]);
				entry.isSpt=subFile.isDirectory;
				
				if(entry.isSpt) {
					var sections:Array=subFile.getDirectoryListing();
					
					function numberFilesOnly(file:File, index:uint, array:Array):Boolean {
						//trace(file.name.match(/^([0-9]+)/));
						return Boolean(file.name.match(/^([0-9]+)/));
					}
					
					sections=sections.filter( numberFilesOnly );
					
					entry.headerFile=new File(subFile.nativePath+File.separator+"header.xml");
					
					entry.outFile=new File(subFile.nativePath+".spt");
					
					//trace(sections);
					
					entry.sections=sections;
					totalWork+=entry.sections.length;
				}
				++totalWork;
				sptFiles.push(entry);
				checkpoints.push(totalWork);
			}
			
			sptIndex=0;
			
			return totalWork;
		}
		
		
		private var spt:SPT;
		private var sptIndex:uint;
		private var sptSection:uint;
		
		protected override function processNext():Boolean {
			
			progress++;
			
			var entry:SPTFileEntry=sptFiles[sptIndex];
			
			if(!spt) {
				
				log("Started on file number "+sptIndex+".");
				
				if(!entry.isSpt) {
					sptIndex++
					return sptIndex<sptFiles.length;
				}
				
				sptSection=0;
				
				spt=new SPT();
				spt.loadHeader(loadXMLFile(entry.headerFile));
				
				log("Wrote headerfile for spt file number "+sptIndex+".");
				
			}
			
			if(sptSection>=spt.length) {
				spt.build();
				
				saveFileByRef(entry.outFile,spt.data);
				
				log("Saved rebuilt spt file number "+sptIndex+".");
				
				spt=null;
				sptIndex++;
				return sptIndex<sptFiles.length;
			}
			
			spt.loadSection(sptSection,loadXMLFile(entry.sections[sptSection]),table);
			
			log("Loaded section number "+sptSection+" for spt file number "+sptIndex+".");
			
			sptSection++;
			
			return true;
		}
		
		private function loadXMLFile(file:File):XML {
			var stream:FileStream=new FileStream();
			stream.open(file,FileMode.READ);
			var string:String=stream.readUTFBytes(stream.bytesAvailable);
			stream.close();
			
			return XML(string);
		}

	}
	
}

import flash.filesystem.File;

class SPTFileEntry {
	public var id:uint;
	public var isSpt:Boolean;
	public var sections:Array;
	public var headerFile:File;
	public var outFile:File;
}
