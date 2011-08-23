package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	import Nitro.*;
	import Nitro.FileSystem.*;
	import Nitro.GK.*;	
	
	public class SPTTest extends MovieClip {
		
		private var nds:NDS;
		
		private var loader:URLLoader;
		
		private var table:Table;
		
		public function SPTTest() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,sptLoaded);
			loader.load(new URLRequest("game.nds"));
			
			table=new Table();
			table.addEventListener(Event.COMPLETE,tableLoaded);
			table.loadFromFile(new URLRequest("C:\\Users\\Henrik\\Desktop\\ds reverse engineering\\jjjewel_AAI2Jpn.tbl"));
			
			stage.align=StageAlign.TOP_LEFT;
		}
		
		private var loadedTable:Boolean=false;
		private var loadedSPT:Boolean=false;
		
		private function sptLoaded(e:Event):void { loadedSPT=true; if(loadedTable) parse(); }
		private function tableLoaded(e:Event):void { loadedTable=true; if(loadedSPT) parse(); }
		
		private function parse():void {
			nds=new NDS();
			nds.parse(loader.data);
			
			var archive:GKArchive=new GKArchive();
			archive.parse(nds.fileSystem.openFileByName("jpn/spt.bin"));
			
			var scripts:XML=<scripts file="spt.bin"/>
			
			var frequences:Object={};
			
			for(var i:uint=0;i<archive.length;++i) {
				
				try {
			
					var spt:SPT=new SPT();
					spt.parse(archive.open(i));
					
					var scriptFile:XML=<scriptFile id={i} />;
					
					/*for each(var ent in spt.sections)  {
						trace(ent.offset,ent.size,ent.flag1,ent.flag2);
					}*/
					
					for(var j:uint=0;j<spt.length;++j) {
						var section:XML=spt.parseSection(j,table);
						scriptFile.appendChild(section);
						
						/*
						for each(var command:XML in section.children()) {
							var name:String=command.toXMLString();
							//if(name=="unknownCommand") name=command.@commandType;
							if(name in frequences) {
								frequences[name]++;
							} else {
								frequences[name]=1;
							}
						}*/
					}
					scripts.appendChild(scriptFile);
				} catch (err:ArgumentError) {
					scripts.appendChild(<unknownFile id={i} />);
				}
			}
			
			var o:ByteArray=new ByteArray();
			o.writeUTFBytes(scripts.toXMLString());
			var fr:FileReference=new FileReference();
			fr.save(o,"scripts.xml");
			
			/*
			var toBeSorted:Vector.<String>=new Vector.<String>();
			for (name in frequences) {
				toBeSorted.push(name);
			}
			
			function compareFrequences(a:String,b:String) {
				return b.localeCompare(a);
				//return frequences[b]-frequences[a];
			}
			
			toBeSorted.sort(compareFrequences);
			
			for each(name in toBeSorted) {
				trace(name,frequences[name]);
			}*/
		}
	}
}