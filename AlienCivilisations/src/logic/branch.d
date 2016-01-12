module src.logic.branch;

import std.algorithm;
import src.logic.knowledgeTree;

struct Dependency {
	Branch branch;
	int dependant;
	int prerequisite;
}

class Branch {

	enum int[5] MULTIPLIERS = [2,4,8,16,32];
	enum int POPULATION_CONSTANT = 50000;
	enum int MAX_LEVEL = 5;
	uint[5] _leafsPoints;
	Dependency[] dependencies;

	this(uint[5] leafsPoints){
		_leafsPoints = leafsPoints;
	}

	//Returns levels of the leafs of current branch
	@property int[5] leafsLevels(){
		int[5] levels = new int[5];
		foreach(size_t i, uint points; _leafsPoints){
			levels[i] = pointsToLevel(points);
		}
		return levels;
	}

	//Returns level of the branch
	@property int level(){
		return leafsLevels[].sum;
	}

	@property double effectiveness(){

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
	int develop(uint points, int leaf){
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

	Branch dup() {
		return new Branch(_leafsPoints.dup);
	}
}