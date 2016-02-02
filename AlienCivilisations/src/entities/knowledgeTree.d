module src.entities.knowledgeTree;

import src.entities.branch;
import std.format;
import std.typecons;
import std.traits;

enum BranchName : ubyte {
	Energy,
	Food,
	Military,
	Science
}

public class KnowledgeTree {
	private {
		Branch _energy, _food, _military, _science;
		BranchName[] _orders;
	}
	this(uint[4] points) {
		_energy = 	new Branch(BranchName.Energy,	points[0]);
		_food = 	new Branch(BranchName.Food, 	points[1]);
		_military = new Branch(BranchName.Military, points[2]);
		_science = 	new Branch(BranchName.Science,	points[3]);
		addDependencies(_energy);
		addDependencies(_food);
		addDependencies(_military);
		addDependencies(_science);
	}
	@property Branch branch(BranchName branch) {
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
	/** Returns branches which haven't reached max level **/
	@property Branch[] possibleDevs() {
		Branch[] nfd;
		/*foreach(bn; EnumMembers!BranchName){
			if(!branch(bn).full){
				nfd ~= branch(bn);
			}
		}*/
		return nfd;
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
	override string toString() {
		return format("energy: %s \nfood: %s \nmilitary: %s \nscience: %s",
			_energy, _food, _military, _science);
	}
	/** Develops branches in queue using given points **/
	int develop(int points){
		while(points > 0 && _orders.length > 0){
			BranchName head = _orders[0];
			int previousLevel = branch(head).level;
			points = branch(head).addPoints(points);
			if(previousLevel < branch(head).level) {
				//remove from queue
				_orders = _orders[1 .. $];
			}
		}
		return points;
	}
	void addOrder(BranchName toAdd){
		if(branch(toAdd).full)
			return;
		int count = 0;
		foreach(bn; _orders) {
			if(bn == toAdd)
				count++;
		}
		if(count >= MAX_LEVEL - branch(toAdd).level)
			return;
		_orders ~= toAdd;
	}
	//Returns duplicate of the current object, without references to original
	KnowledgeTree dup() const {
		uint[4] points = 
		[
			_energy.points,
			_food.points,
			_military.points,
			_science.points
		];
		return new KnowledgeTree(points);
	}
}