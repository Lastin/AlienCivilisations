module src.entities.branch;

import src.entities.knowledgeTree;
import std.algorithm;

class Branch {
	private enum double DEPENDENCY_EFFECT = 0.2;
	enum int[5] MULTIPLIERS = [2,4,8,16,32];
	enum int POPULATION_CONSTANT = 50000;
	enum int MAX_LEVEL = 5;
	private uint[] _leafsPoints;
	private immutable BranchName _name;
	private Branch[] _dependencies;

	this(BranchName name, uint[] leafsPoints){
		_name = name;
		_leafsPoints = leafsPoints;
	}

	//Returns levels of the leafs of current branch
	@property uint[] leafsLevels(){
		uint[] levels;
		foreach(size_t i, uint points; _leafsPoints){
			levels[i] = pointsToLevel(points);
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
		double level = level;
		foreach(Branch dependency; _dependencies){
			level *= dependency.level;
		}
		return level;
	}

	//Converts raw leaf points to leaf level
	int pointsToLevel(int points){
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
	int addPoints(uint points, int leaf){
		int leafLevel = leafsLevels[leaf];
		if(leafLevel >= MAX_LEVEL){
			return points;
		}
		int pointsNeeded = MULTIPLIERS[leafLevel + 1] * POPULATION_CONSTANT - _leafsPoints[leaf];
		if(points <= pointsNeeded){
			_leafsPoints[leaf] += points;
			return 0;
		}
		_leafsPoints[leaf] += pointsNeeded;
		return points -= pointsNeeded;
	}

	Branch addDependency(Branch dependency){
		_dependencies ~= dependency;
		return this;
	}

	Branch dup() {
		return new Branch(_name, _leafsPoints.dup[0 .. 5]);
	}
}