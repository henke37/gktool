package GKTool {
	
	import Nitro.GK2.*;
	
	import flash.utils.*;
	import flash.net.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.debugger.enterDebugger;
	
	public class FlowchartScreen extends ExtractBaseScreen {
		
		var archive:GKArchive;
		
		private var subFileNr:uint;
		private var subFile:SPT;
		private var sectionNr:uint;

		private var numberSize:uint;
		private var subNumberSize:uint;
		
		public static const archiveFileName:String="jpn/spt.bin";
		
		private var outFileStream:FileStream;

		public function FlowchartScreen() {
			
		}
		
		protected override function beginExtraction():uint {
			var archiveData:ByteArray=gkTool.nds.fileSystem.openFileByName(archiveFileName);
			
			archive=new GKArchive();
			archive.parse(archiveData);
			
			numberSize=archive.length.toString().length;
			
			XML.prettyPrinting=true;
			XML.prettyIndent=2;
			
			var outFile:flash.filesystem.File=new File(outDir.nativePath+File.separator+"flowchart.gv");
			
			outFileStream=new FileStream();
			outFileStream.open(outFile,FileMode.WRITE);
			
			outFileStream.writeUTFBytes("digraph { \n");
			
			addFarJumps();
			
			return archive.length;
		}
		
		protected override function endOperation():void {
			/*for(var index in SectionParser.unknownCommands) {
				trace(uint(index).toString(16),SectionParser.unknownCommands[index]);
			}*/
			
			outFileStream.writeUTFBytes("}");
			outFileStream.close();
			
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
				}
				
				subFileName=formatSectionId(subFileNr,sectionNr);
				
				try {
				
					var sectionData:XML=subFile.parseSection(sectionNr);
					
					processSection(sectionData);
					
					log("processed \""+subFileName+"\"");
				} catch(err:Error) {
					log("Parse error! \""+subFileName+"\"\n"+err.getStackTrace());
					++errors;
				}
				
				++sectionNr;
			} catch(err:ArgumentError) {
				log("Failed to process\""+subFileName+"\". It's not a SPT file.");
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

	
		private function processSection(section:XML):void {
			if(section.elements().length()<1) return;
			
			var subFileName:String=padNumber(subFileNr,numberSize)+"/"+padNumber(sectionNr,subNumberSize)+".xml";

			addNode(formatSectionId(subFileNr,sectionNr),{ URL: subFileName } );
			
			for each(var cmd:XML in section.elements()) {
				var type:String=cmd.localName();
				
				switch(type) {
					case "jumpToSection":
					case "investigationBranchTableEnt":
					case "talkMenuEntry":
					case "talkTopic":
						addEdge(formatSectionId(subFileNr,sectionNr),formatSectionId(subFileNr,int(cmd.@section)));
					break;
					
					case "jumpIfFlag":
						addEdge(formatSectionId(subFileNr,sectionNr),formatSectionId(subFileNr,int(cmd.@section)),{color:
							(cmd.@cond=="1"?"green":"red"),
							label: "0x"+int(cmd.@flag).toString(16)
						});
					break;
					case "jumpIfFlagsEqTo":
						jumpIfFlags(cmd);
					break;
					
					
					break;
					
					case "callSection":
						addEdge(formatSectionId(subFileNr,sectionNr),formatSectionId(subFileNr,int(cmd.@section)),{dirtype:"both",arrowhead:"odotnormal",arrowtail:"curve",color:"purple"});
					break;
					
					case "investigationBranchTableDefEnt":
					case "talkMenuBail":
						addEdge(formatSectionId(subFileNr,sectionNr),formatSectionId(subFileNr,int(cmd.@section)),{color: "gray"});
					break;
					
					case "unknownBranchSuccess":
					case "unknownCondJump":
						addEdge(formatSectionId(subFileNr,sectionNr),formatSectionId(subFileNr,int(cmd.@section)),{color: "green"});
					break;
						
					case "checkForPresent":
					case "presentBranchEntry":
					case "evidencePromptJump":
						addEdge(formatSectionId(subFileNr,sectionNr),formatSectionId(subFileNr,int(cmd.@section)),{color: "green", label: int(cmd.@evidence)});
					break;
					
					case "noHPBranch":
					case "unknownBranchFail":
					case "presentBranchDefEntry":
						addEdge(formatSectionId(subFileNr,sectionNr),formatSectionId(subFileNr,int(cmd.@section)),{color: "red"});
					break;
						
					case "unknownBranch":
						addEdge(formatSectionId(subFileNr,sectionNr),formatSectionId(subFileNr,int(cmd.@section)),{color: "brown"});
					break;
						
					
						
					case "randomBranch":
						rndBranch(cmd);
					break;
					
					case "longJump":
						longJump(cmd);
					break;
					
					case "ceStatement":
						addEdge(formatSectionId(subFileNr,sectionNr),formatSectionId(subFileNr,int(cmd.@statementSection)),{color: "dimgrey", arrowhead: "box"});
						addEdge(formatSectionId(subFileNr,int(cmd.@statementSection)),formatSectionId(subFileNr,int(cmd.@pressSection)),{color: "blue"});
						addEdge(formatSectionId(subFileNr,int(cmd.@statementSection)),formatSectionId(subFileNr,int(cmd.@presentSection)),{style: "bold"});
					break;
						
					case "ceAid":
						addEdge(formatSectionId(subFileNr,sectionNr),formatSectionId(subFileNr,int(cmd.@section)),{color: "gray"});
					break;
					
					case "unknownReturn":
						unknownReturn();
					break;
					
					case "gameOver":
						gameOver();
					break;
					
					case "logicChessTimeout":
						addEdge(formatSectionId(subFileNr,sectionNr),formatSectionId(subFileNr,int(cmd.@section)),{color: "red", style:"bold"});
					break;
						
					case "logicChessChoiseRest":
						addEdge(formatSectionId(subFileNr,sectionNr),formatSectionId(subFileNr,int(cmd.@section)));
					break;
					
					case "logicChessChoiseAttack":
						addEdge(formatSectionId(subFileNr,sectionNr),formatSectionId(subFileNr,int(cmd.@section)));
					break;
					
					case "logicChessTopic":
						addEdge(formatSectionId(subFileNr,sectionNr),formatSectionId(subFileNr,int(cmd.@section)));
					break;
					
					default:
						//log("skipped command of type"+type);
					break;
				}
			}
		}
		
		private function jumpIfFlags(cmd:XML):void {

			var flags:Array=[];
			for each(var flag:XML in cmd.flag) {
				flags.push("0x"+int(flag.@flag).toString(16));
			}
			
			addEdge(formatSectionId(subFileNr,sectionNr),formatSectionId(subFileNr,int(cmd.@section)),{
				color: (cmd.@cond=="1"?"green":"red"),
				label: flags.join("/")
			});
		}
		
		private function gameOver():void {
			var dst:String=formatSectionId(subFileNr,sectionNr)+"_OVER";
			addNode(dst,{shape: "box", label: "Game Over" });
			addEdge(formatSectionId(subFileNr,sectionNr),dst);
		}
		
		private function unknownReturn():void {
			var dst:String=formatSectionId(subFileNr,sectionNr)+"_RET";
			addNode(dst,{shape: "triangle", label: "RET" });
			addEdge(formatSectionId(subFileNr,sectionNr),dst);
		}
		
		private function longJump(cmd:XML):void {
			var dst:String=int(cmd.attribute("case"))+"_"+int(cmd.@part)+"_"+int(cmd.@index);
			addEdge(formatSectionId(subFileNr,sectionNr),dst);
		}
		
		private function rndBranch(cmd:XML):void {
			for each(var option:XML in cmd.destination) {
				if(option.@weight=="0") continue;
				addEdge(formatSectionId(subFileNr,sectionNr),formatSectionId(subFileNr,int(option.@section)));
			}
		}
		
		private function addEdge(from:String,to:String,opts:Object=null):void {
			var line:String="\t";
			line+="\""+from+"\"";
			line+=" -> ";
			line+="\""+to+"\"";
			line+=formatOpts(opts);			
			line+="\n";
			outFileStream.writeUTFBytes(line);
		}
		
		private function addNode(id:String,opts:Object=null):void {
			var line:String="\t";
			line+="\""+id+"\"";
			line+=formatOpts(opts);			
			line+="\n";
			outFileStream.writeUTFBytes(line);
		}
		
		private function formatOpts(opts:Object):String {
			var line:String="";
			
			if(opts) {
				line+=" [";
				var notFirstOpt:Boolean=false;
				for (var optKey:String in opts) {
					var optVal:String=opts[optKey];
					if(notFirstOpt) {
						line+=", ";
					} else {
						notFirstOpt=true;
					}
					line+=optKey;
					line+="=";
					line+="\""+optVal+"\"";
				}
				
				line+="]";
			}
			
			return line;
		}
		
		private function formatSectionId(subFile:uint,section:uint):String {
			return padNumber(subFile,numberSize)+"_"+padNumber(section,3);
		}
		
		private function addFarJumps():void {
			for each(var table:Array in JumpTables.tables) {
				for each(var ent:Array in table) {
					var casePart:uint=ent[0][1];
					var episode:uint=casePart>>4;
					var part:uint=casePart &0xF;
					var subpart:uint=ent[0][0];
					var spt:uint=ent[1];
					//trace(episode,part,subpart,spt);
					
					var src:String=episode+"_"+part+"_"+subpart;
					var dst:String=formatSectionId(spt,0);
					addNode(src,{ style: "dashed" });
					addEdge(src,dst);
				}
			}
		}
		
	}
}
