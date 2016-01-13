module src.logic.branch;

import std.algorithm;
import src.logic.knowledgeTree;

class Branch {

	enum int[5] MULTIPLIERS = [2,4,8,16,32];
	enum int POPULATION_CONSTANT = 50000;
	enum int MAX_LEVEL = 5;
	uint[5] _leafsPoints;

	this(uint[5] leafsPoints){
		_leafsPoints = leafsPoints;
	}

	//Returns levels of the leafs of current branch
	@property uint[5] leafsLevels(){
		uint[5] levels;
		foreach(size_t i, uint points; _leafsPoints){
			levels[i] = pointsToLevel(points);
		}
		return levels;
	}

	//Returns level of the branch
	@property int level(){
		return leafsLevels[].sum;
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

	Branch dup() {
		return new Branch(_leafsPoints.dup[0 .. 5]);
	}
}