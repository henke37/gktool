package GKTool {
	
	import flash.display.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.events.*;
	import flash.text.*;
	
	import Nitro.*;
	import Nitro.Graphics.*;
	
	public class ImageConverter extends Screen {
		
		private var creator:NCGRCreator;
		
		private var fr:FileReference;
		
		private var loader:Loader;
		
		public var status_txt:TextField;
		public var load_mc:Button;
		public var palette_mc:Button;
		public var tiles_mc:Button;
		public var menu_mc:Button;
		
		private var output:Sprite;
		
		public function ImageConverter() {
			creator=new NCGRCreator();
			
			output=new Sprite();
			addChild(output);
			
			fr=new FileReference();
			load_mc.label="Load image";
			load_mc.addEventListener(MouseEvent.CLICK,selectPicture);
			palette_mc.label="Save nclr";
			palette_mc.enabled=false;
			palette_mc.addEventListener(MouseEvent.CLICK,savePalette);
			tiles_mc.label="Save ncgr";
			tiles_mc.enabled=false;
			tiles_mc.addEventListener(MouseEvent.CLICK,saveTiles);
			menu_mc.label="Back to menu";
			menu_mc.addEventListener(MouseEvent.CLICK,menuClick);
		}
		
		private function menuClick(e:MouseEvent):void {
			gkTool.screen="MainMenu";
		}
		
		private function savePalette(e:MouseEvent):void {
			var nclr:NCLR=new NCLR();
			nclr.bitDepth=creator.ncgr.bitDepth;
			nclr.colors=creator.palette;
			fr.save(nclr.save(),"p.nclr");
		}
		
		private function saveTiles(e:MouseEvent):void {
			
			fr.save(creator.ncgr.save(),"p.ncgr");
		}
		
		private function selectPicture(e:Event):void {
			fr.addEventListener(Event.SELECT,fileSelected);
			fr.browse([new FileFilter("Images","*.jpeg;*.png;*.gif;*.jpg")]);
		}
		
		private function fileSelected(e:Event):void {
			fr.removeEventListener(Event.SELECT,fileSelected);
			fr.addEventListener(Event.COMPLETE,fileLoaded);
			fr.load();
		}
		
		private function fileLoaded(e:Event):void {
			
			loader=new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,picLoaded);
			loader.loadBytes(fr.data);
		}
		
		private function picLoaded(e:Event):void {
			
			while(output.numChildren) output.removeChildAt(output.numChildren-1);
			
			palette_mc.enabled=false;
			tiles_mc.enabled=false;
			
			try {
				creator.pic=Bitmap(loader.content).bitmapData;
				creator.findPalette();
			
				palette_mc.enabled=true;
			
				var b:Bitmap=new Bitmap(drawPalette(creator.palette,true));
				b.scaleX=4;
				b.scaleY=b.scaleX;
				output.addChild(b);
				
				creator.buildTiles(true);
				
				var palette:Vector.<uint>=RGB555.paletteFromRGB555(creator.palette);
				
				tiles_mc.enabled=true;
				
				var render:DisplayObject=creator.ncgr.render(palette);
				render.x=b.width;
				output.addChild(render);
				
				status_txt.text="Image converted and ready to save.";
			} catch(err:Error) {
				status_txt.text=err.message;
			}
		}
	}
	
}
