package GKTool.BitmapEditor {
	
	import flash.display.*;
	import flash.events.*;
	
	public class Colorpicker extends Sprite {
		
		private var bmd:BitmapData;
		private var bitmap:Bitmap;
		
		
		public var indicators_mc:MovieClip;
		private var selectionIndex:uint=0;
		
		public function Colorpicker() {
			bmd=new BitmapData(16,16,true,0x00000000);
			bitmap=new Bitmap(bmd);
			addChild(bitmap);
			addChild(indicators_mc);
			
			addEventListener(MouseEvent.CLICK,clicked);
		}
		
		internal function rend():void {
			bmd.lock();
			
			var index:uint=editor.convertedPalette.length-1;
			do {
				var xPos:uint=index%16;
				var yPos:uint=index/16;
				var color:uint=index;
						
				color=editor.convertedPalette[color];
				color|=0xFF000000;
				
				bmd.setPixel32(xPos,yPos,color);
			} while(index-->0);
			
			bmd.unlock();
			
			updateSelection();
		}
		
		public function get selectedColor():uint {
			return selectionIndex;
		}
		
		private function get editor():Editor { return Editor(parent); }
		
		private function clicked(e:MouseEvent):void {
			var candidateIndex:uint=uint(e.localX)+uint(e.localY)*16;
			if(candidateIndex>=editor.convertedPalette.length) return;
			
			if(editor.hasSubPalettes) {
				editor.subPalette=candidateIndex/16;
				selectionIndex=candidateIndex%16;
			} else {			
				selectionIndex=candidateIndex;
			}
			
			updateSelection();
		}
		
		private function updateSelection():void {
			var xPos:uint=selectionIndex%16;
			var yPos:uint=selectionIndex/16+editor.subPalette;
			
			indicators_mc.selectionIndicator_mc.x=xPos;
			indicators_mc.selectionIndicator_mc.y=yPos;
			
			indicators_mc.paletteIndicator_mc.visible=editor.hasSubPalettes;
			indicators_mc.paletteIndicator_mc.y=editor.subPalette;
		}
	}
	
}
