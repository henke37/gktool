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
					subFile=new SPT();
					subFile.parse(archive.open(subFileNr));
					subNumberSize=subFile.length.toString().length;
					
					subFileName=padNumber(subFileNr,numberSize)+"/header.xml";
					saveXMLFile(subFileName,subFile.headerToXML());
				}
				var sectionData:XML=subFile.parseSection(sectionNr);
				
				subFileName=padNumber(subFileNr,numberSize)+"/"+padNumber(sectionNr,subNumberSize)+".xml";				
				
				var data=new ByteArray();
				data.writeUTFBytes(sectionData.toXMLString());
				
				saveFile(subFileName,data);
				
				log("Extracted \""+subFileName+"\"");
				
				++sectionNr;
			} catch(err:ArgumentError) {
				log("Failed to extract\""+subFileName+"\". It's not a SPT file.");
				++errors;
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
