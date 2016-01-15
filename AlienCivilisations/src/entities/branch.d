module src.entities.branch;

import src.entities.knowledgeTree;
import src.entities.planet;
import std.algorithm;
import std.stdio;
import std.conv;

class Branch {
	private enum double DEPENDENCY_EFFECT = 0.2;
	enum int[5] MULTIPLIERS = [2,4,8,16,32];
	//enum int POPULATION_CONSTANT = 10000;
	enum int MAX_LEVEL = 5;
	private uint[] _leafsPoints;
	private immutable BranchName _name;
	private Branch[] _dependencies;

	this(BranchName name, uint[] leafsPoints){
		_name = name;
		_leafsPoints = leafsPoints;
	}

	//Returns levels of the leafs of current branch
	@property uint[] leafsLevels() {
		uint[] levels;
		foreach(uint points; _leafsPoints){
			levels ~= pointsToLevel(points);
		}
		return levels;
	}

	//Returns level of the branch
	@property int level(){
		return leafsLevels[].sum;
	}

	@property uint[] leafsPoints(){
		return _leafsPoints;
	}

	@property double effectiveness(){
		double branchLevel = level + 1;
		foreach(Branch dependency; _dependencies){
			branchLevel += dependency.level * DEPENDENCY_EFFECT;
		}
		return branchLevel;
	}

	@property int[] undevelopedLeafs() {
		auto ll = leafsLevels;
		int[] undeveloped;
		for(int i=0; i<ll.length; i++){
			if(ll[i] < 5){
				undeveloped ~= i;
			}
		}
		return undeveloped;
	}

	pure @property BranchName name(){
		return _name;
	}

	//Converts raw leaf points to leaf level
	int pointsToLevel(uint points) nothrow {
		int level = MAX_LEVEL;
		foreach_reverse(int multiplier; MULTIPLIERS){
			if(points >= multiplier * POPULATION_CONSTANT){
				return level;
			}
			level--;
		}
		return level;
	}

	//Increases the number of points within selected leaf
	int addPoints(int points, int leaf){
		int leafLevel = leafsLevels[leaf];
		if(leafLevel >= MAX_LEVEL){
			return points;
		}
		int pointsNeeded = MULTIPLIERS[leafLevel] * POPULATION_CONSTANT - _leafsPoints[leaf];
		debug writeln("Points needed " ~ to!string(pointsNeeded));
		if(points <= pointsNeeded){
			_leafsPoints[leaf] += points;
			return 0;
		}
		_leafsPoints[leaf] += pointsNeeded;
		return points -= pointsNeeded;
	}

	pure Branch addDependency(Branch dependency){
		_dependencies ~= dependency;
		return this;
	}

	Branch dup() {
		return new Branch(_name, _leafsPoints.dup);
	}
}