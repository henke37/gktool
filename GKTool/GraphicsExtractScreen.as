package GKTool {
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.*;
	import flash.filesystem.*;
	
	import com.adobe.images.*;
	
	import Nitro.GK.*;
	import Nitro.FileSystem.*;
	import Nitro.Graphics.*;
	
	public class GraphicsExtractScreen extends ExtractBaseScreen {
		
		private var fileList:XML;
		private var itemList:XMLList;
		
		public function GraphicsExtractScreen() {
			
			var path:String=flash.filesystem.File.applicationDirectory.nativePath+flash.filesystem.File.separator+"fileList.xml";
			trace(path);
			
			var listFile:flash.filesystem.File=new flash.filesystem.File(path);
			var listStream:FileStream=new FileStream();
			listStream.open(listFile,FileMode.READ);
			
			var listString:String=listStream.readUTFBytes(listFile.size);
			
			listStream.close();
			
			fileList=XML(listString);
			itemList=fileList.children();
			
		}
		
		private var palette:NCLR;
		private var convertedPalette:Vector.<uint>;
		private var cells:NCER;
		private var tiles:NCGR;
		private var screen:NSCR;
		
		private var cellItr:uint;
		private var itemItr:uint;
		
		private var ncgrName:String;
		private var nclrName:String;
		private var ncerName:String;
		private var nscrName:String;
		
		protected override function beginExtraction():uint {
			cellItr=0;
			return itemList.length();
		}
			
		protected override function processNext():Boolean {
			
			if(cellItr) {
				if(processCell()) return true;
				if(itemItr>=itemList.length()) return false;
			}
			
			var item:XML=itemList[itemItr];
			
			if(item.palette!=nclrName) {
				nclrName=item.palette;
				loadPalette(gkTool.easyFS.openFile(nclrName));
				
				log("Loaded palette: "+nclrName);
			}
			
			if(item.graphics.length()>0 && item.graphics!=ncgrName) {
				ncgrName=item.graphics;
				tiles=new NCGR();
				tiles.parse(gkTool.easyFS.openFile(ncgrName));
				
				log("Loaded tiles: "+ncgrName);
			}
			
			if(item.cells.length()>0 && item.cells!=ncerName) {
				ncerName=item.cells;
				cells=new NCER();
				cells.parse(gkTool.easyFS.openFile(ncerName));
				
				log("Loaded cells: "+ncerName);
			}
			
			if(item.screen.length()>0 && item.screen!=nscrName) {
				nscrName=item.screen;
				screen=new NSCR();
				screen.parse(gkTool.easyFS.openFile(nscrName));
				log("Loaded screen: "+nscrName);
			}
			
			var itemType:String=item.name();
			switch(itemType) {
				case "cellBank":
					cellItr=0;
					
					if(cells.labels && cells.labels.length>0) {
						saveLabels();
					}
					
					if(processCell()) return true;
				break;
				
				case "picture":
					saveBitmap(ncgrName,tiles.render(convertedPalette,0,false));
				break;
				
				case "screen":
					saveBitmap(nscrName,screen.render(tiles,convertedPalette));
				break;
				
				default:
					throw new Error("Unknown element found in fileList.xml "+item.toXMLString());
				break;
			}
			
			//trace(item);
			
			itemItr++;
			
			return itemItr<itemList.length();
		}
		
		private function saveLabels():void {
			var o:String="";
			for each(var label:String in cells.labels) {
				o+=label+"\n";
			}
			saveTextFile(ncerName+"/labels.txt",o);
		}
		
		private function processCell():Boolean {
			
			var cellR:DisplayObject=cells.rend(cellItr,convertedPalette,tiles);
			
			if(cellR.width==0 || cellR.height==0) {
				log("Skipping cell # "+cellItr+" since it is empty");
			} else {
				saveBitmap(ncerName+"/"+cellItr,cellR);
				
				log("Extracted cell # "+cellItr);
			}
			
			cellItr++;
			
			if(cellItr>=cells.length) {
				cellItr=0;
				itemItr++;
				return false;
			}
			
			return true;
		}
		
		private function loadPalette(contents:ByteArray):void {
			palette=new NCLR();
			palette.parse(contents);
			convertedPalette=RGB555.paletteFromRGB555(palette.colors);
		}
		
		private function saveBitmap(name:String,obj:DisplayObject):void {			
			var bounds:Rectangle=obj.getBounds(obj);
			
			var rendMatrix:Matrix=new Matrix();
			rendMatrix.identity();
			rendMatrix.translate(bounds.left,bounds.top);
			rendMatrix.invert();
			
			var bmd:BitmapData=new BitmapData(bounds.width,bounds.height,true,0x00FF4000);
			bmd.lock();
			
			bmd.draw(obj,rendMatrix);
			
			var png:ByteArray=PNGEncoder.encode(bmd);
			
			saveFile(name+".png",png);
		}

	}
	
}
