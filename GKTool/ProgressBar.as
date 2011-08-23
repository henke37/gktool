package GKTool {
	
	import flash.display.*;
	
	
	public class ProgressBar extends Sprite {
		
		public var checkpoints:Vector.<uint>;
		private var _progress:uint;
		
		public var total:uint;
		
		public function ProgressBar() {
			// constructor code
		}
		
		public function get progress():uint { return _progress; }
		public function set progress(p:uint):void {
			
			_progress=p;
			
			var g:Graphics=graphics;
			
			g.clear();
			
			var pc:Number=Number(p)/total;
			
			const w:Number=540;
			const h:Number=40;
			
			g.lineStyle(1);
			
			g.beginFill(0x0040FF);
			g.drawRect(0,0,w*pc,h);
			g.endFill();
			
			if(checkpoints) {
				
				for each(var checkpoint:uint in checkpoints) {
					
					if(checkpoint<p) {
						g.lineStyle(1,0x00FFFF);
					} else {
						g.lineStyle(1,0x006060);
					}
					
					var xPos:Number=Number(checkpoint)/total*w;
					g.moveTo(xPos,0);
					g.lineTo(xPos,h);
				}
			}
			
			g.lineStyle(1);
			
			g.drawRect(0,0,w,h);
		}
	}
	
}
