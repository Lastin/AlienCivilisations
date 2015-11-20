module handlers.knowledgeTree;
import std.container.dlist;
import std.typecons;
import std.range;
import std.algorithm.searching;
import handlers.branch;
import std.conv;

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

	private double branchEffect = 0.04;
	private double leafEffect = 0.1;

	private DList!(identifier) queue;
	private alias identifier = Tuple!(string, "branchName", int, "leafIndex");
	//dependencies
	private alias dependency = Tuple!();

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
		int points_left = civil_units;
		while(!queue.empty() || points_left <= 0){
			identifier b = queue.front;
			double bonus = getBonus(b);
			points_left = getBranch(b.branchName).develop(to!int(points_left * bonus), b.leafIndex);
			if(points_left >= 0){
				points_left = to!int(points_left/bonus);
				queue.removeFront;
			}
		}
	}

	private double getBonus(identifier i){
	/*
	 * Food < Science
	 * Food < Energy
	 * Food < Science[1]
	 * Food < Science[2]
	 * Food[3] < Science[3]
	 * Food[3] < Science[4]
	 * 
	 * Military < Energy
	 * Miliatry < Science[1]
	 * Military < Science[3]
	 * Miliatry[0] < Science[2]
	 * Military[0] < Science[4]
	 * Miliatry[1] < Science[2]
	 * Military[1] < Science[4]
	 * 
	 * Science < Energy
	 * 
	 * Energy < Science[3]
	 * Energy < Science[4]
	 * Energy[0] < Science[0]
	 * Energy[1] < Science[0]
	 */
		double total = 1.0;
		final switch(i.branchName){
			case "Food": 
				total += branchEffect * getBranch("Science").getBranchLevel();
				total += branchEffect * getBranch("Energy").getBranchLevel();
				total += leafEffect * getBranch("Science").getLevels[1];
				total += leafEffect * getBranch("Science").getLevels[2];
				if(i.leafIndex == 3){
					total += leafEffect * getBranch("Science").getLevels[3];
					total += leafEffect * getBranch("Science").getLevels[4];
				}
				break;
			case "Military":
				total += branchEffect * getBranch("Energy").getBranchLevel();
				total += leafEffect * getBranch("Science").getLevels[1];
				total += leafEffect * getBranch("Science").getLevels[3];
				if(i.leafIndex == 0 || i.leafIndex == 1){
					total += leafEffect * getBranch("Science").getLevels[2];
					total += leafEffect * getBranch("Science").getLevels[4];
				}
				break;
			case "Science":
				total += branchEffect * getBranch("Energy").getBranchLevel();
				break;
			case "Energy":
				total += leafEffect * getBranch("Science").getLevels[3];
				total += leafEffect * getBranch("Science").getLevels[4];
				if(i.leafIndex == 0 || i.leafIndex == 1){
					total += leafEffect * getBranch("Science").getLevels[0];
				}
		}
		return total;
	}

	public void addToQueue(string branchName, int leafIndex){
		identifier newOrder;
		newOrder.branchName = branchName;
		newOrder.leafIndex = leafIndex;
		int levels_left = 5;
		foreach(identifier order; queue){
			if(newOrder == order){
				--levels_left;
			}
		}
		if(levels_left > 0){
			identifier order;
			order.branchName = branchName;
			order.leafIndex = leafIndex;
			queue.insertBack(order);
		}
	}

	public void removeFromQueue(string branchName, int leafIndex){
		identifier newOrder;
		newOrder.branchName = branchName;
		newOrder.leafIndex = leafIndex;
		DList!identifier newQueue;
		int found = 0;
		foreach_reverse(identifier each; queue){
			if(each == newOrder && found==0){
				++found;
			} 
			else {
				newQueue.insertFront(each);
			}
			queue = newQueue;
		}
	}
}