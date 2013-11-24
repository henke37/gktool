package GKTool {
	
	import Nitro.GK2.*;
	
	import flash.utils.*;
	import flash.net.*;
	import flash.events.*;
	
	public class SptExtractScreen extends ExtractBaseScreen {
		
		var archive:GKArchive;
		
		private var subFileNr:uint;
		private var subFile:SPT;
		private var sectionNr:uint;

		private var numberSize:uint;
		private var subNumberSize:uint;
		
		public static const archiveFileName:String="jpn/spt.bin";

		public function SptExtractScreen() {
			
		}
		
		protected override function beginExtraction():uint {
			var archiveData:ByteArray=gkTool.nds.fileSystem.openFileByName(archiveFileName);
			
			archive=new GKArchive();
			archive.parse(archiveData);
			
			numberSize=archive.length.toString().length;
			
			XML.prettyPrinting=true;
			XML.prettyIndent=2;
			
			return archive.length;
		}
		
		protected override function endOperation():void {
			for(var index in SectionParser.unknownCommands) {
				trace(uint(index).toString(16),SectionParser.unknownCommands[index]);
			}
			super.endOperation();
		}
		
		protected override function processNext():Boolean {
			
			try {
				
				var subFileName:String;
				
				if(!subFile) {
					++progress;
					
					var sptData:ByteArray=archive.open(subFileNr);
					
					subFile=new SPT();
					subFile.parse(sptData);
					subNumberSize=subFile.length.toString().length;
					
					subFileName=padNumber(subFileNr,numberSize)+"/header.xml";
					saveXMLFile(subFileName,subFile.headerToXML());
				}
				
				try {
					var sectionData:XML=subFile.parseSection(sectionNr);
					
					subFileName=padNumber(subFileNr,numberSize)+"/"+padNumber(sectionNr,subNumberSize)+".xml";			
					
					if(sectionData.children().length()) {
						
						var data=new ByteArray();
						data.writeUTFBytes(sectionData.toXMLString());
						
						saveFile(subFileName,data);
						
						log("Extracted \""+subFileName+"\"");
					} else {
						log("Skipped empty section \""+subFileName+"\"");
					}
				} catch (err:Error) {
					log("Parse error! \""+subFileName+"\"\n"+err.getStackTrace());
					++errors;
				}
				
				++sectionNr;
			} catch(err:ArgumentError) {
				log("Failed to extract\""+subFileName+"\". It's not a SPT file.");
				//++errors;
				subFile=null;
			}
			
			if(!subFile || sectionNr>=subFile.length) {
				sectionNr=0;
				++subFileNr;
				subFile=null;
			}
			if(subFileNr>=archive.length) return false;
			return true;
		}

	}
	
}
