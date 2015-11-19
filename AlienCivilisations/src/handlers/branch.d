module handlers.branch;
import handlers.gameManager;
import std.algorithm;
import handlers.knowledgeTree;

class Branch {
	private string name;
	private string[] leafsNames;
	private int[] points;
	private int[] multipliers = [2,4,8,16,32];
	private int pop_const = 50000;
	private int maxLevel = 5;

	this(string name, string[] leafsNames, int[] points){
		this.name = name;
		this.leafsNames = leafsNames;
		this.points = points;
	}

	public int[] getLevels(){
		int[] levels = new int[points.length];
		foreach(int i, int each; points){
			levels[i] = pointsToLevel(points[i]);
		}
		return levels;
	}

	public int getBranchLevel(){
		return sum(getLevels());
	}

	public int pointsToLevel(int points){
		int level = maxLevel;
		foreach_reverse(int multiplier; multipliers){
			if(points >= multiplier*pop_const){
				return level;
			}
			level--;
		}
		return level;
	}

	public void develop(int leafId, double bonus){

	}
}