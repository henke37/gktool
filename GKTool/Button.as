package GKTool {
	
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	
	public class Button extends Sprite {
		
		private var state:String;
		private var _label:TextField;
		
		private const _width:Number=140;
		private const _height:Number=26;
		
		public function Button() {
			state="idle";
			
			mouseChildren=false;
			
			enabled=true;
			
			_label=new TextField();
			_label.width=_width;
			_label.height=_height;
			addChild(_label);
			
			flagUpdate();
		}
		
		public function set enabled(e:Boolean):void {
			if(e) {
				if(state=="disabled") {
					if(stage && hitTestPoint(stage.mouseX,stage.mouseY,true)) {
						state="over";
					} else {
						state="idle";
					}
					flagUpdate();
				}
				addEventListener(MouseEvent.ROLL_OUT,out);
				addEventListener(MouseEvent.ROLL_OVER,over);
				addEventListener(MouseEvent.MOUSE_DOWN,down);
				removeEventListener(MouseEvent.CLICK,clickCancel);
				buttonMode=true;
			} else {
				state="disabled";
				flagUpdate();
				removeEventListener(MouseEvent.ROLL_OUT,out);
				removeEventListener(MouseEvent.ROLL_OVER,over);
				removeEventListener(MouseEvent.MOUSE_DOWN,down);
				addEventListener(MouseEvent.CLICK,clickCancel,false,50);
				buttonMode=false;
			}
		}
		
		private function clickCancel(e:MouseEvent):void {
			e.stopImmediatePropagation();
		}
		
		private function over(e:MouseEvent):void {
			if(state=="downOutside") {
				state="down";
			} else {
				state="over";
			}
			flagUpdate();
		}
		
		private function out(e:MouseEvent):void {
			if(state=="down") {
				state="downOutside";
			} else {
				state="idle";
			}
			flagUpdate();
		}
		
		private function down(e:MouseEvent):void {
			state="down";
			stage.addEventListener(MouseEvent.MOUSE_UP,up);
			flagUpdate();
		}
		
		private function up(e:MouseEvent):void {
			if(state=="down") {
				state="over";
			} else {
				state="idle";
			}
			stage.removeEventListener(MouseEvent.MOUSE_UP,up);
			flagUpdate();
		}
		
		public function set label(l:String) { _label.text=l; flagUpdate() }
		public function get label():String { return _label.text; }
		
		private function flagUpdate():void {
			if(stage) {
				addEventListener(Event.RENDER,render);
				stage.invalidate();
			} else {
				addEventListener(Event.ADDED_TO_STAGE,render);
			}
		}
		
		private function render(e:Event=null):void {
			
			removeEventListener(Event.RENDER,render);
			removeEventListener(Event.ADDED_TO_STAGE,render);
			
			graphics.clear();
			graphics.lineStyle(1);
			
			switch(state) {
				case "idle":
				case "downOutside":
					graphics.beginFill(0x999999);
				break;
				
				case "over":
					graphics.beginFill(0xCCCCCC);
				break;
				
				case "down":
					graphics.beginFill(0x666666);
				break;
				
				case "disabled":
					graphics.beginFill(0x333333);
				break;
			}
			
			graphics.drawRect(0,0,_width,_height);
			graphics.endFill();
			
			var tf:TextFormat=new TextFormat();
			tf.align=TextFormatAlign.CENTER;
			tf.color=(state=="disabled")?0xCCCCCC:0;
			tf.size=20;
			
			_label.defaultTextFormat=tf;
			_label.setTextFormat(tf);
		}
	}
	
}
