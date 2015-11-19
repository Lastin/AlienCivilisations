module handlers.knowledgeTree;
import std.container.dlist;
import std.typecons;
import std.range;
import std.algorithm.searching;
import handlers.branch;

public class KnowledgeTree {
	public enum BranchName {
		Food = "Food",
		Science = "Science",
		Military = "Military",
		Energy = "Energy"
	}
	string[][] leafsNames = [
		["Agricultural Economics", "Agricultural Engineering", "Argonomy", "Animal Science"],
		["Automation", "Biology", "Chemistry", "Mathematics", "Physics"],
		["Defence", "Offence", "Enervating", "Spying", "Intimidation"],
		["Fossil Fuels", "Hydro Power", "Nuclear", "Solar Power", "Wind"]
	];

	private Branch food;
	private Branch science;
	private Branch military;
	private Branch energy;

	private double branchEffect = 0.02;
	private double leafEffect = 0.1;

	private DList!(kOrder) queue;
	private alias kOrder = Tuple!(BranchName, "branchName", int, "subBranch");

	/*
	 * Energy > Food
	 * Energy > Military
	 * Energy > Science
	 * 
	 * Science[1] > Energy[1]
	 * Science[1] > Energy[2]
	 * Science[2] > Food
	 * Science[2] > Miliatry
	 * Science[3] > Food
	 * Science[3] > Miliatry[1]
	 * Science[3] > Miliatry[2]
	 * Science[4] > Food[3]
	 * Science[4] > Energy
	 * Science[4] > Military
	 * Science[5] > Food[3]
	 * Science[5] > Energy
	 * Science[5] > Military[1]
	 * Science[5] > Military[2]
	 * 
	 */


	this(){
		int[5] points;
		food = new Branch(BranchName.Food, leafsNames[0], points);
		science = new Branch(BranchName.Science, leafsNames[1], points);
		military = new Branch(BranchName.Military, leafsNames[2], points);
		energy = new Branch(BranchName.Energy, leafsNames[3], points);
	}

	public Branch getBranch(string branchName){
		switch(branchName){
			case "Food": return food;
			case "Science": return science;
			case "Military": return military;
			case "Energy": return energy;
			default: throw new Exception("Unknown branch name");
		}
	}

	public void develop(int civil_units){
	}

	public void addToQueue(string branch, int subBranch){
	}

	public void removeFromQueue(string branch, int subBranch){
	}
}