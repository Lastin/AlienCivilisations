module src.entities.knowledgeTree;

import src.entities.branch;
import std.format;
import std.typecons;

enum BranchName : ubyte {
	Energy,
	Food,
	Military,
	Science
}

enum LEAF_NAMES : string[] {
	Energy = ["Fossil Fuels", "Hydro Power", "Nuclear", "Solar Power", "Wind"],
	Food = ["Agricultural Economics", "Agricultural Engineering", "Argonomy", "Animal Science", "Horticulture"],
	Military = ["Defence", "Offence", "Enervating", "Spying", "Intimidation"],
	Science = ["Automation", "Biology", "Chemistry", "Mathematics", "Physics"]
}

struct Order {
	BranchName branch;
	int leaf;
}


public class KnowledgeTree {
	private Branch _energy, _food, _military, _science;
	private Order[] _orders;

	this(int[][] points) {
		_energy = 	new Branch(BranchName.Energy,	points[0]);
		_food = 	new Branch(BranchName.Food, 	points[1]);
		_military = new Branch(BranchName.Military, points[2]);
		_science = 	new Branch(BranchName.Science,	points[3]);
		addDependencies(_energy);
		addDependencies(_food);
		addDependencies(_military);
		addDependencies(_science);
	}

	pure @property Branch branch(BranchName branch) {
		switch(branch){
			case BranchName.Energy: 	return _energy;
			case BranchName.Food: 		return _food;
			case BranchName.Military: 	return _military;
			case BranchName.Science: 	return _science;
			default: 					throw new Exception("Unknown branch");
		}
	}

	@property Branch branch(string branchName) {
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

	void addDependencies(Branch branch){
		if(branch.name == BranchName.Energy) {
			branch.addDependency(_science);
		}
		else if(branch.name == BranchName.Food) {
			branch.addDependency(_energy);
			branch.addDependency(_science);
		}
		else if(branch.name == BranchName.Military) {
			branch.addDependency(_energy);
			branch.addDependency(_science);
		}
		else if(branch.name == BranchName.Science) {
			branch.addDependency(_energy);
		}
	}

	//Returns duplicate of the current object, without references to original
	KnowledgeTree dup() const {
		auto points = 
		[
			_energy.leafsPoints,
			_food.leafsPoints,
			_military.leafsPoints,
			_science.leafsPoints
		];
		return new KnowledgeTree(points);
	}

	override const string toString() {
		return format("energy: %s \nfood: %s \nmilitary: %s \nscience: %s",
			_energy, _food, _military, _science);
	}

	void makeOrder(BranchName bn, int leaf){
		_orders ~= Order(bn, leaf);
	}

	int develop(int points){
		while(points > 0 && _orders.length > 0){
			Order head = _orders[0];
			points = branch(head.branch).addPoints(points, head.leaf);
			if(points > 0){
				_orders = _orders[1 .. $];
			}
		}
		return points;
	}
}