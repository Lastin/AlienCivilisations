module src.logic.knowledgeTree;

import std.typecons;
import std.range;
import std.algorithm.searching;
import src.logic.branch;
import std.conv;
import std.container.dlist;

struct Order {
	Branch branch;
	int leaf;
}

enum BranchName : ubyte {
	Energy,
	Food,
	Military,
	Science
}

enum LEAF_NAMES : string[]{
	Food = ["Agricultural Economics", "Agricultural Engineering", "Argonomy", "Animal Science", "Horticulture"],
	Science = ["Automation", "Biology", "Chemistry", "Mathematics", "Physics"],
	Military = ["Defence", "Offence", "Enervating", "Spying", "Intimidation"],
	Energy = ["Fossil Fuels", "Hydro Power", "Nuclear", "Solar Power", "Wind"]
}


public class KnowledgeTree {

	private Branch _food, _science, _military, _energy;
	private enum double _branchEffect = 0.04;
	private enum double _leafEffect = 0.1;
	DList!Order _queue;

	this(int[5] points = [0,0,0,0,0], DList!Order queue = make!(DList!Order)()){
		_food = new Branch(points);
		_science = new Branch(points);
		_military = new Branch(points);
		_energy = new Branch(points);
		_queue = queue;
	}

	@property Branch branch(BranchName branch){
		switch(branch){
			case BranchName.Energy: return _energy;
			case BranchName.Food: return _food;
			case BranchName.Military: return _military;
			case BranchName.Science: return _science;
			default: throw new Exception("Unknown branch");
		}
	}

	@property double effectiveness(BranchName branch){
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


	public uint develop(uint civil_units){
	}

	//Returns duplicate of the current object, without references to original
	KnowledgeTree dup(){
		return new KnowledgeTree([food.dup, science.dup, military.dup, energy.dup], _queue.dup);
	}
}