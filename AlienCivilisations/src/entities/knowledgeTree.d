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
		addDependencies(_energy);
		addDependencies(_food);
		addDependencies(_military);
		addDependencies(_science);
	}

	this(Branch[] branches){
		_energy =	branches[0];
		_food =		branches[1];
		_military = branches[2];
		_science = 	branches[3];
	}

	pure @property Branch branch(BranchName branch){
		switch(branch){
			case BranchName.Energy: 	return _energy;
			case BranchName.Food: 		return _food;
			case BranchName.Military: 	return _military;
			case BranchName.Science: 	return _science;
			default: 					throw new Exception("Unknown branch");
		}
	}

	@property Branch branch(string branchName){
		switch(branchName){
			case "Energy": 		return _energy;
			case "Food": 		return _food;
			case "Military": 	return _military;
			case "Science": 	return _science;
			default: 			throw new Exception("Unknown branch");
		}
	}

	//Returns array of tuples containing branch and indexes of
	//leaves which are below max development level
	@property Tuple!(Branch, int[])[] possibleDevelopments() {
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

	//Necessary way for adding dependencies to duplicate 
	pure void addDependencies(KnowledgeTree kt, Branch branch){
		if(branch.name == BranchName.Energy){

		}
		if(branch.name == BranchName.Food){
			branch.addDependency(kt.branch(BranchName.Energy));
			branch.addDependency(kt.branch(BranchName.Science));
		}
		if(branch.name == BranchName.Military){
			branch.addDependency(kt.branch(BranchName.Energy));
			branch.addDependency(kt.branch(BranchName.Science));
		}
		if(branch.name == BranchName.Science){
			branch.addDependency(kt.branch(BranchName.Energy));
		}
	}

	void addDependencies(Branch branch){
		if(branch.name == BranchName.Energy){
			
		}
		if(branch.name == BranchName.Food){
			branch.addDependency(_energy);
			branch.addDependency(_science);
		}
		if(branch.name == BranchName.Military){
			branch.addDependency(_energy);
			branch.addDependency(_science);
		}
		if(branch.name == BranchName.Science){
			branch.addDependency(_energy);
		}
	}

	//Returns duplicate of the current object, without references to original
	KnowledgeTree dup() {
		auto branches = [_energy.dup, _food.dup, _military.dup, _science.dup];
		auto copy = new KnowledgeTree(branches);
		foreach(Branch b; branches){
			addDependencies(copy, b);
		}
		return copy;
	}

	string toString(){
		return
			"energy:     " 	~ to!string(_energy.leafsLevels) ~
			"\nfood:     " 	~ to!string(_food.leafsLevels) ~
			"\nmilitary: "	~ to!string(_military.leafsLevels) ~
			"\nscience:  " 	~ to!string(_science.leafsLevels) ~
			"\npoints: "	~
			"\n" ~ to!string(_energy.leafsPoints) ~
			"\n" ~ to!string(_food.leafsPoints) ~
			"\n" ~ to!string(_military.leafsPoints) ~
			"\n" ~ to!string(_science.leafsPoints);
	}
}