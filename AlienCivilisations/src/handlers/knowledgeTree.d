module handlers.knowledgeTree;
import std.container.dlist;

class KnowledgeTree {
	private string[] branchNames = ["Food", "Science", "Military", "Energy"];
	private string[][] subBranchNames = [
		["Agricultural economics", "Agricultural Engineering", "Argonomy", "Animal Science"],
		["Automation", "Biology", "Chemistry", "Mathematics", "Physics"],
		["Defence", "Offence", "Enervating", "Spying", "Intimidation"],
		["Fossil fuels", "Hydro power", "Nuclear", "Solar power", "Wind"]];

	int[][string] branches;
	int accumulated = 0;

	private DList!(int[string]) queue = DList!(int[string])();

	this(){
		initializeArrays();
	}

	private void initializeArrays(){
		branches = [
			"Food" : [0,0,0,0,0],
			"Science" : [0,0,0,0,0],
			"Military" : [0,0,0,0,0],
			"Energy" : [0,0,0,0,0],
		];
	}

	public int[] getBranch(string branchName){
		return branches[branchName];
	}

	public void develop(int civil_units){
		accumulated += civil_units;
		do {

		} while(queue.empty || accumulated <= 0);
		//l1 = 2
		//l2 = 4
		//l3 = 8
		//l4 = 16
		//l5 = 32
		//steps = (multiplier * 50,000) / civil_units
	}

	public void addToQueue(string branch, int ){

	}

	public void removeFromQueue(){

	}
}