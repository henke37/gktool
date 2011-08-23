package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	
	import Nitro.GK.*;
	
	
	public class SPTTest2 extends MovieClip {
		
		var table:Table;
		var scriptLoader:URLLoader;
		
		public function SPTTest2() {
			table=new Table();
			table.addEventListener(Event.COMPLETE,tableLoaded);
			table.loadFromFile(new URLRequest("AAI2Jpn.tbl"));
			
			scriptLoader=new URLLoader();
			scriptLoader.dataFormat=URLLoaderDataFormat.TEXT;
			scriptLoader.addEventListener(Event.COMPLETE,scriptLoaded);
			scriptLoader.load(new URLRequest("C:\\Users\\Henrik\\Desktop\\spt\\jpn\\spt.bin\\002\\0.xml"));
		}
		
		private var loadedTable:Boolean=false;
		private var loadedScript:Boolean=false;
		
		private function scriptLoaded(e:Event):void { loadedScript=true; if(loadedTable) write(); }
		private function tableLoaded(e:Event):void { loadedTable=true; if(loadedScript) write(); }
		
		private function write():void {
			
			var section:XML=XML(scriptLoader.data);
			
			var spt:SPT=new SPT();
			
			spt.buildSection(section,table);
			
		}
	}
	
}
