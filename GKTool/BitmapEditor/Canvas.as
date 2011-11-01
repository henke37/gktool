package GKTool.BitmapEditor {
	
	import flash.display.*;
	import flash.geom.*;
	
	public class Canvas extends Sprite {
		
		internal var pixels:Vector.<uint>;
		
		private var bitmapWidth:uint;
		private var bitmapHeight:uint;
		
		private var bmd:BitmapData;
		private var bitmap:Bitmap;
		
		private var transparent:Boolean=true;
		
		public function Canvas() {
			bitmap=new Bitmap();
			addChild(bitmap);
		}
		
		private function get editor():Editor { return Editor(parent); }
		
		internal function setSize(w:uint,h:uint):void {
			bmd=new BitmapData(w,h,true,0xFFFF00FF);
			
			bitmap.bitmapData=bmd;
			bitmapWidth=w;
			bitmapHeight=h;
		}
		
		internal function rend():void {
			
			bmd.lock();
			
			const palOffset:uint=16*editor.subPalette;
			
			for(var yPos:uint=0;yPos<bitmapHeight;++yPos) {
				for(var xPos:uint=0;xPos<bitmapWidth;++xPos) {
					var index:uint=xPos+bitmapWidth*yPos;
					
					var color:uint=pixels[index];
					
					if(color==0 && transparent) {
						color=0x00000000;
					} else {					
						color=editor.convertedPalette[color+palOffset];
						color|=0xFF000000;
					}
					
					bmd.setPixel32(xPos,yPos,color);
				}
			}
			
			bmd.unlock();
		}
	}
	
}
