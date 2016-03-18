module src.entities.knowledgeTree;

import src.entities.branch;
import std.format;
import std.typecons;
import std.traits;
import std.stdio;
import std.conv;

enum BranchName : string {
	Energy = "Energy",
	Food = "Food",
	Military = "Military",
	Science = "Science"
}

public class KnowledgeTree {
	private {
		Branch _energy, _food, _military, _science;
		BranchName[] _orders;
		double lambda = 0.1;
	}
	this(uint[4] points) {
		_energy = 	new Branch(BranchName.Energy,	points[0]);
		_food = 	new Branch(BranchName.Food, 	points[1]);
		_military = new Branch(BranchName.Military, points[2]);
		_science = 	new Branch(BranchName.Science,	points[3]);
		foreach(branch; branches){
			addDependencies(branch);
		}
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
	/** Returns branches in alphabetical naming order **/
	@property Branch[4] branches() {
		return [_energy, _food, _military, _science];
	}
	/** Returns development orders **/
	@property Tuple!(BranchName, int)[] orders(){
		Tuple!(BranchName, int)[] orderPairs;
		int[4] levels = [_energy.level, _food.level, _military.level, _science.level];
		foreach(order; _orders){
			switch(order){
				case BranchName.Energy:
					levels[0]++;
					orderPairs ~= tuple(order, levels[0]);
					break;
				case BranchName.Food:
					levels[1]++;
					orderPairs ~= tuple(order, levels[1]);
					break;
				case BranchName.Military:
					levels[2]++;
					orderPairs ~= tuple(order, levels[2]);
					break;
				case BranchName.Science:
					levels[3]++;
					orderPairs ~= tuple(order, levels[3]);
					break;
				default: break;
			}
		}
		return orderPairs;
	}
	/** Returns branches which haven't reached max level **/
	@property double totalEff(){
		double total = 0;
		foreach(bn; EnumMembers!BranchName) {
			total += branch(bn).effectiveness;
		}
		return total;
	}
	@property Branch[] undevelopedBranches() {
		Branch[] nfd;
		foreach(bn; EnumMembers!BranchName){
			if(!branch(bn).full){
				nfd ~= branch(bn);
			}
		}
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
	int develop(int population){
		uint points = to!uint(population * totalEff * lambda);
		version(debugTree) {
			writeln("--------------------------------------");
			writeln("Developing knowledge tree");
			writefln("Population total: %s", population);
			writefln("Points: %s", points);
		}
		while(points > 0 && _orders.length > 0) {
			version(debugTree) writefln("[Orders Iteration] Points: %s", points);
			BranchName head = _orders[0];
			int previousLevel = branch(head).level;
			points = branch(head).addPoints(points);
			if(previousLevel < branch(head).level) {
				//remove finished from queue
				_orders = _orders[1 .. $];
			}
		}
		version(debugTree) writeln("--------------------------------------");
		return points;
	}
	bool addOrder(BranchName toAdd){
		if(branch(toAdd).full)
			return false;
		int count = 0;
		foreach(bn; _orders) {
			if(bn == toAdd)
				count++;
		}
		if(count >= MAX_LEVEL - branch(toAdd).level)
			return false;
		_orders ~= toAdd;
		return true;
	}
	void clearOrders() {
		_orders = null;
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
	override size_t toHash() nothrow {
		double sum = 0;
		sum += _energy.points;
		sum += _food.points;
		sum += _military.points;
		sum += _science.points;
		sum += _orders.length;
		return super.toHash;
	}
}