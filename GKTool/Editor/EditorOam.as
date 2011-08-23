package GKTool.Editor {
	import Nitro.Graphics.*;
	
	import flash.display.*;
	
	public class EditorOam extends CellOam {
		
		internal var rendering:EditorRendering;
		internal var nr:uint;

		public function EditorOam() {
			rendering=new EditorRendering(this);
		}
		
		public static function spawnFromTemplate(simpleTile:OamTile,nr:uint):EditorOam {
			var o:EditorOam=new EditorOam();
			
			o.width=simpleTile.width;
			o.height=simpleTile.height;
			o.tileIndex=simpleTile.tileIndex;
			o.paletteIndex=simpleTile.paletteIndex;
			o.colorDepth=simpleTile.colorDepth;
			
			var complexTile:CellOam= simpleTile as CellOam;
			
			if(complexTile) {
				o.doubleSize=complexTile.doubleSize;
				o.hide=complexTile.hide;
				o.x=complexTile.x;
				o.y=complexTile.y;
				o.xFlip=complexTile.xFlip;
				o.yFlip=complexTile.yFlip;
			}
			
			o.nr=nr;
			
			return o;
		}

	}
	
}
