package GKTool {
	
	import Nitro.GK.*;
	
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
		
		private var table:Table;

		public function SptExtractScreen() {
			table=new Table();
			table.addEventListener(Event.COMPLETE,tableLoaded);
			table.loadFromFile(new URLRequest("AAI2Jpn.tbl"));
			
			realScreen.selectDir_mc.enabled=false;
		}
		
		private function tableLoaded(e:Event):void {
			realScreen.selectDir_mc.enabled=true;
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
				var sectionData:XML=subFile.parseSection(sectionNr,table);
				
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
