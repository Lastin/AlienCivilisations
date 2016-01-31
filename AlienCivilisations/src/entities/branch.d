module src.entities.branch;

import src.entities.knowledgeTree;
import std.algorithm.iteration;
import src.entities.planet;
import std.stdio;
import std.conv;

class Branch {
	private enum double DEPENDENCY_EFFECT = 0.3;
	enum int[5] MULTIPLIERS = [2,4,8,16,32];
	enum int MAX_LEVEL = 5;
	private int[] _leafsPoints;
	private immutable BranchName _name;
	private Branch[] _dependencies;

	this(BranchName name, int[] leafsPoints) {
		_name = name;
		_leafsPoints = leafsPoints;
	}

	//Returns levels of the leafs of current branch
	@property int[] leafsLevels() const {
		int[] levels;
		foreach(int points; _leafsPoints){
			levels ~= pointsToLevel(points);
		}
		return levels;
	}

	//Returns level of the branch
	@property int level() const {
		return leafsLevels[].sum;
	}

	@property int[] leafsPoints() const {
		return _leafsPoints.dup;
	}

	@property double effectiveness() const {
		double effness = level + 1;
		foreach(const Branch dependency; _dependencies){
			effness += dependency.level * DEPENDENCY_EFFECT;
		}
		return effness;
	}

	@property int[] undevelopedLeafs() const {
		auto ll = leafsLevels;
		int[] undeveloped;
		for(int i=0; i<ll.length; i++){
			if(ll[i] < 5){
				undeveloped ~= i;
			}
		}
		return undeveloped;
	}

	@property BranchName name() const {
		return _name;
	}

	//Converts raw leaf points to leaf level
	pure int pointsToLevel(uint points) const {
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
	int addPoints(int points, int leaf) {
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

	Branch addDependency(Branch dependency) {
		_dependencies ~= dependency;
		return this;
	}

	override string toString() const {
		return to!string(_leafsPoints);
	}
}