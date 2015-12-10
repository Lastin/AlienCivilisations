module src.logic.knowledgeTree;

import std.typecons;
import std.range;
import std.algorithm.searching;
import src.logic.branch;
import std.conv;

private struct Order {
	Branch branch;
	int leaf;
}


public class KnowledgeTree {

	enum leafNames : string[]{
		Food = ["Agricultural Economics", "Agricultural Engineering", "Argonomy", "Animal Science", "Horticulture"],
		Science = ["Automation", "Biology", "Chemistry", "Mathematics", "Physics"],
		Military = ["Defence", "Offence", "Enervating", "Spying", "Intimidation"],
		Energy = ["Fossil Fuels", "Hydro Power", "Nuclear", "Solar Power", "Wind"]
	}
	private Branch food, science, military, energy;
	private double branchEffect = 0.04;
	private double leafEffect = 0.1;
	Order[] queue;

	this(){
		int[5] points = [0,0,0,0,0];
		food = new Branch("Food", leafNames.Food, points);
		science = new Branch("Science", leafNames.Science, points);
		military = new Branch("Military", leafNames.Military, points);
		energy = new Branch("Energy", leafNames.Energy, points);
	}

	this(Branch[4] branches, Order[] queue){
		food = branches[0];
		science = branches[1];
		military = branches[2];
		energy = branches[3];
		this.queue = queue;
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
			Order frnt = queue.front;
			double bonus = getBonus(frnt);
			points_left = frnt.branch.develop(to!int(points_left * bonus), frnt.leaf);
			if(points_left >= 0){
				points_left = to!int(points_left/bonus);
				queue = queue[1..$];
			}
		}
	}

	private double getBonus(Order i){
	/*
	 * Food <- Science
	 * Food <- Energy
	 * Food <- Science[1]
	 * Food <- Science[2]
	 * Food[3] <- Science[3]
	 * Food[3] <- Science[4]
	 * 
	 * Military <- Energy
	 * Miliatry <- Science[1]
	 * Military <- Science[3]
	 * Miliatry[0] <- Science[2]
	 * Military[0] <- Science[4]
	 * Miliatry[1] <- Science[2]
	 * Military[1] <- Science[4]
	 * 
	 * Science <- Energy
	 * 
	 * Energy <- Science[3]
	 * Energy <- Science[4]
	 * Energy[0] <- Science[0]
	 * Energy[1] <- Science[0]
	 */
		double total = 1.0;
		if(i.branch == food){
			total += branchEffect * getBranch("Science").getBranchLevel();
			total += branchEffect * getBranch("Energy").getBranchLevel();
			total += leafEffect * getBranch("Science").getLevels[1];
			total += leafEffect * getBranch("Science").getLevels[2];
			if(i.leaf == 3){
				total += leafEffect * getBranch("Science").getLevels[3];
				total += leafEffect * getBranch("Science").getLevels[4];
			}
		}
		else if(i.branch == military){
			total += branchEffect * getBranch("Energy").getBranchLevel();
			total += leafEffect * getBranch("Science").getLevels[1];
			total += leafEffect * getBranch("Science").getLevels[3];
			if(i.leaf == 0 || i.leaf == 1){
				total += leafEffect * getBranch("Science").getLevels[2];
				total += leafEffect * getBranch("Science").getLevels[4];
			}
		}
		else if(i.branch == science){
			total += branchEffect * getBranch("Energy").getBranchLevel();
		}
		else if(i.branch == energy){
			total += leafEffect * getBranch("Science").getLevels[3];
			total += leafEffect * getBranch("Science").getLevels[4];
			if(i.leaf == 0 || i.leaf == 1){
				total += leafEffect * getBranch("Science").getLevels[0];
			}
		}
		return total;
	}

	public KnowledgeTree dup(){
		//creates duplicate of the object
		Branch[4] bclone = [food.dup(), science.dup(), military.dup(), energy.dup()];
		return new KnowledgeTree(bclone, queue.dup());
	}

	//QUEUE FUNCTIONS
	void addToQueue(Branch branch, int leaf){
		Order newOrder;
		newOrder.branch = branch;
		newOrder.leaf = leaf;
		int levels_left = 5;
		synchronized {
			foreach(Order order; queue){
				if(newOrder == order){
					--levels_left;
				}
			}
			if(levels_left > 0){
				queue ~= newOrder;
			}
		}
	}

	void removeFromQueue(Branch branch, int leaf){
		Order tbr;
		tbr.branch = branch;
		tbr.leaf = leaf;
		Order[] newQueue;
		newQueue.reserve(queue.capacity); //reserve to avoid reallocation
		int found = 0;
		synchronized {
			foreach_reverse(Order order; queue){
				if(found==0 && order == tbr){
					++found;
				} 
				else {
					newQueue = order ~ newQueue;
				}
			}
			queue = newQueue;
		}
	}
}