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

	this(uint[][] points = [
			[0,0,0,0,0],
			[0,0,0,0,0],
			[0,0,0,0,0],
			[0,0,0,0,0]])
	{
		_energy = 	new Branch(BranchName.Energy,	points[0]);
		_food = 	new Branch(BranchName.Food, 	points[1]);
		_military = new Branch(BranchName.Military, points[2]);
		_science = 	new Branch(BranchName.Science,	points[3]);
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

	//Returns duplicate of the current object, without references to original
	KnowledgeTree dup(){
		uint[][] pointsCopy = [
			_energy.leafsPoints.dup,
			_food.leafsPoints.dup,
			_military.leafsPoints.dup,
			_science.leafsPoints.dup
		];
		return new KnowledgeTree(pointsCopy);
	}
}