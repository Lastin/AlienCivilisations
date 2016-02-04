module src.entities.branch;

import src.entities.knowledgeTree;
import std.algorithm.iteration;
import src.entities.planet;
import std.stdio;
import std.conv;

public enum int MAX_LEVEL = 5;
class Branch {
	private {
		enum double DEPENDENCY_EFFECT = 0.3;
		enum int[5] MULTIPLIERS = [2,4,8,16,32];
		BranchName _name;
	} 

	private uint _points;
	private Branch[] _dependencies;

	this(BranchName name, int points) {
		_name = name;
		_points = points;
	}
	/** Returns name of the branch **/
	@property BranchName name() const {
		return _name;
	}
	/** Returns level of the branch **/
	@property int level() const {
		int level = MAX_LEVEL;
		foreach_reverse(int multiplier; MULTIPLIERS){
			if(_points >= multiplier * POPULATION_CONSTANT){
				return level;
			}
			level--;
		}
		return level;
	}
	/** Returns effectiveness of the branch **/
	@property double effectiveness() const {
		double effness = 1 + level();
		foreach(const Branch dependency; _dependencies){
			effness += dependency.level * DEPENDENCY_EFFECT;
		}
		return effness;
	}
	/** Returns points within current branch **/
	@property uint points() const {
		return _points;
	}
	/** Returns true if branch reached max level **/
	@property bool full() const {
		return level() >= MAX_LEVEL;
	}
	/** Adds parameter as dependency of called object **/
	void addDependency(Branch dependency) {
		_dependencies ~= dependency;
	}
	/** Adds points to branch, until it reaches next level.
	 Left over points are returned. **/
	int addPoints(uint points) {
		if(level() >= MAX_LEVEL) return points;
		uint nlp = MULTIPLIERS[level()] * POPULATION_CONSTANT;
		uint pointsNeeded = nlp - _points;
		if(pointsNeeded < points) {
			_points += pointsNeeded;
			points -= pointsNeeded;
			return points;
		}
		_points += points;
		return 0;
	}
	/** Returns number of experience points to next level **/
	uint nextExp(){
		if(full)
			return 0;
		return MULTIPLIERS[level+1] * POPULATION_CONSTANT - _points;
	}
	override string toString() {
		return to!string(level());
	}
}