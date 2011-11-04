package GKTool.BitmapEditor {
	
	import flash.display.*;
	import flash.events.*;
	
	import GKTool.*;
	
	import Nitro.Graphics.*;
	
	public class Editor extends GKTool.Screen {
		
		public var canvas_mc:Canvas;
		public var colorPicker_mc:Colorpicker;
		
		public var hasSubPalettes:Boolean;
		private var _subPalette:uint;
		private var _palette:Vector.<uint>;
		internal var convertedPalette:Vector.<uint>;;
		
		public function Editor() {
			// constructor code
		}
		
		public function set subPalette(p:uint):void {
			_subPalette=p;
			triggerRedraw();
		}
		
		public function get subPalette():uint { return _subPalette; }
		
		public function set palette(p:Vector.<uint>):void {
			_palette=p;
			convertedPalette=RGB555.paletteFromRGB555(p);
			triggerRedraw();
		}
		
		public function loadPixels(pixels:Vector.<uint>,w:uint,h:uint):void {
			canvas_mc.pixels=pixels;
			canvas_mc.setSize(w,h);
			
			triggerRedraw();
		}
		
		public function triggerRedraw():void {
			if(stage) {
				stage.invalidate();
				addEventListener(Event.RENDER,rend);
			} else {
				addEventListener(Event.ADDED_TO_STAGE,rend);
			}
		}
		
		private function rend(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE,rend);
			removeEventListener(Event.RENDER,rend);
			
			canvas_mc.rend();
			colorPicker_mc.rend();
		}
	}
	
}
