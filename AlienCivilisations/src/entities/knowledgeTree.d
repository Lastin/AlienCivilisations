module src.entities.knowledgeTree;

import src.entities.branch;
import std.container.dlist;
import std.conv;
import std.range;
import std.typecons;

enum BranchName : ubyte {
	Energy,
	Food,
	Military,
	Science
}

enum LEAF_NAMES : string[]{
	Energy = ["Fossil Fuels", "Hydro Power", "Nuclear", "Solar Power", "Wind"],
	Food = ["Agricultural Economics", "Agricultural Engineering", "Argonomy", "Animal Science", "Horticulture"],
	Military = ["Defence", "Offence", "Enervating", "Spying", "Intimidation"],
	Science = ["Automation", "Biology", "Chemistry", "Mathematics", "Physics"]
}


public class KnowledgeTree {
	private Branch _energy, _food, _military, _science;

	this(uint[][] points){
		_energy = 	new Branch(BranchName.Energy,	points[0]);
		_food = 	new Branch(BranchName.Food, 	points[1]);
		_military = new Branch(BranchName.Military, points[2]);
		_science = 	new Branch(BranchName.Science,	points[3]);
	}

	this(Branch[] branches){
		_energy =	branches[0];
		_food =		branches[1];
		_military = branches[2];
		_science = 	branches[3];
	}

	@property Branch branch(BranchName branch){
		switch(branch){
			case BranchName.Energy: 	return _energy;
			case BranchName.Food: 		return _food;
			case BranchName.Military: 	return _military;
			case BranchName.Science: 	return _science;
			default: 					throw new Exception("Unknown branch");
		}
	}

	@property Tuple!(Branch, int[])[] possibleDevelopments(){
		Tuple!(Branch, int[])[] possibilities;
		Tuple!(Branch, int[])[] temp;
		temp ~= tuple(_energy,	_energy.undevelopedLeafs);
		temp ~= tuple(_food,	_food.undevelopedLeafs);
		temp ~= tuple(_military,_military.undevelopedLeafs);
		temp ~= tuple(_science,	_science.undevelopedLeafs);
		foreach(Tuple!(Branch, int[]) each; temp){
			if(each[1].length > 0){
				possibilities ~= each;
			}
		}
		return possibilities;
	}

	//Returns duplicate of the current object, without references to original
	KnowledgeTree dup(){
		return new KnowledgeTree([_energy.dup, _food.dup, _military.dup, _science.dup]);
	}
}