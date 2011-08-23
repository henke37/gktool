package GKTool.Editor {
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	
	import GKTool.*;
	
	public class OamProperties extends Sprite {
		
		public var xFlip_mc:ToggleButton;
		public var yFlip_mc:ToggleButton;
		
		public var x_txt:TextField;
		public var y_txt:TextField;
		public var palette_txt:TextField;
		public var tile_txt:TextField;
		public var width_txt:TextField;
		public var height_txt:TextField;
		public var oamNr_txt:TextField;
		
		public function OamProperties() {
			xFlip_mc.addEventListener(Event.CHANGE,setXFlip);
			yFlip_mc.addEventListener(Event.CHANGE,setYFlip);
			
			x_txt.addEventListener(Event.CHANGE,setX);
			x_txt.addEventListener(FocusEvent.FOCUS_OUT,numberFocusLost);
			y_txt.addEventListener(Event.CHANGE,setY);
			y_txt.addEventListener(FocusEvent.FOCUS_OUT,numberFocusLost);
			tile_txt.addEventListener(Event.CHANGE,setTile);
			tile_txt.addEventListener(FocusEvent.FOCUS_OUT,numberFocusLost);
			palette_txt.addEventListener(Event.CHANGE,setPalette);
			palette_txt.addEventListener(FocusEvent.FOCUS_OUT,numberFocusLost);
			width_txt.addEventListener(Event.CHANGE,setWidth);
			width_txt.addEventListener(FocusEvent.FOCUS_OUT,numberFocusLost);
			height_txt.addEventListener(Event.CHANGE,setHeight);
			height_txt.addEventListener(FocusEvent.FOCUS_OUT,numberFocusLost);
		}
		
		private function setXFlip(e:Event):void {
			var oam:EditorOam=editor._selectedOam;
			if(!oam) return;
			oam.xFlip=xFlip_mc.selected;
			editor.flagRender();
		}
		
		private function setYFlip(e:Event):void {
			var oam:EditorOam=editor._selectedOam;
			if(!oam) return;
			oam.yFlip=yFlip_mc.selected;
			editor.flagRender();
		}
		
		private function setX(e:Event):void {
			var oam:EditorOam=editor._selectedOam;
			if(!oam) return;
			oam.x=parseInt(x_txt.text);
			editor.flagRender();
		}
		
		private function setY(e:Event):void {
			var oam:EditorOam=editor._selectedOam;
			if(!oam) return;
			oam.y=parseInt(y_txt.text);
			editor.flagRender();
		}
		
		private function setTile(e:Event):void {
			var oam:EditorOam=editor._selectedOam;
			if(!oam) return;
			oam.tileIndex=parseInt(tile_txt.text);
			editor.flagRender();
		}
		
		private function setPalette(e:Event):void {
			var oam:EditorOam=editor._selectedOam;
			if(!oam) return;
			oam.paletteIndex=parseInt(palette_txt.text);
			editor.flagRender();
		}
		
		private function setHeight(e:Event):void {
			var oam:EditorOam=editor._selectedOam;
			if(!oam) return;
			oam.height=parseInt(height_txt.text);
			if(oam.height%8!=0) {
				height_txt.setTextFormat(new TextFormat(null,null,0xFF0000));
			} else {
				height_txt.setTextFormat(new TextFormat(null,null,0x000000));
			}
			editor.flagRender();
		}
		
		private function setWidth(e:Event):void {
			var oam:EditorOam=editor._selectedOam;
			if(!oam) return;
			oam.width=parseInt(width_txt.text);
			if(oam.width%8!=0) {
				width_txt.setTextFormat(new TextFormat(null,null,0xFF0000));
			} else {
				width_txt.setTextFormat(new TextFormat(null,null,0x000000));
			}
			editor.flagRender();
		}
		
		internal function update():void {
			
			var oam:EditorOam=editor._selectedOam;
			
			if(!oam) {
				mouseChildren=false;
				oam=new EditorOam();
			} else {
				mouseChildren=true;
			}			
			
			xFlip_mc.selected=oam.xFlip;
			yFlip_mc.selected=oam.yFlip;
			x_txt.text=String(oam.x);
			y_txt.text=String(oam.y);
			tile_txt.text=String(oam.tileIndex);
			palette_txt.text=String(oam.paletteIndex);
			width_txt.text=String(oam.width);
			height_txt.text=String(oam.height);
			oamNr_txt.text="Oam nr: "+oam.nr;
		}
		
		private function get editor():Editor { return Editor(parent); }
	}
	
}
