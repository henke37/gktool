package GKTool {
	
	public class JumpTables {

		public function JumpTables() {
			// constructor code
		}
		
		public static function resolveFarJump(episode:int,part:int,subpart:int):int {
			const table:Array=tables[episode];
			
			const casePart:uint= episode<<4 | part;
			
			for each(var ent:Array in table) {
				if(ent[0][1]==casePart && ent[0][0]==subpart) {
					return ent[1];
				}
			}
			throw new Error("Unknown far jump!");
		}
		
		
		
		
		include "case1JumpTable.txt";
		
		include "case2JumpTable.txt";
		
		include "case3JumpTable.txt";

		public static const tables:Array=[case1,case2,case3];
	}
	
}
