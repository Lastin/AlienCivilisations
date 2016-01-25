module src.entities.planet;

import src.handlers.containers;
import std.algorithm;
import std.conv;
import src.entities.player;
import src.entities.ship;
import std.format;
import src.entities.knowledgeTree;
import std.stdio;

public enum int POPULATION_CONSTANT = 10000;

class Planet {
	private {
		immutable string _name;
		immutable Vector2d _position;
		immutable float _radius;
		immutable bool _breathableAtmosphere;
		Player _owner;
		uint[8] _population = [0,0,0,0,0,0,0,0];
		uint _food = 0;
		uint _workForce = 0;
		uint _militaryUnits = 0;
	}

	this(string name, Vector2d position, float radius, bool breathableAtmosphere) {
		_breathableAtmosphere = breathableAtmosphere;
		_name = name;
		_position = position;
		_radius = radius;
	}
	/** (Cloning) Constructor for creating planet from existing values **/
	this(string name, Vector2d position, float radius, bool breathableAtmosphere,
		uint[8] population, uint food, uint militaryUnits) {
		this(name, position, radius, breathableAtmosphere);
		_population = population;
		_food = food;
		_militaryUnits = militaryUnits;
	}

	@property Vector2d position() {
		return _position;
	}
	@property bool breathableAtmosphere() {
		return _breathableAtmosphere;
	}

	@property int capacity() {
		return to!int(_radius / 10 * POPULATION_CONSTANT);
	}
	@property uint populationSum() const {
		return _population[].sum;
	}
	@property float radius() const {
		return _radius;
	}
	@property string name() const {
		return _name;
	}
	@property Player owner() {
		return _owner;
	}
	@property uint food() const {
		return _food;
	}
	@property uint militaryUnits() const {
		return _militaryUnits;
	}
	@property uint[8] population() {
		return _population;
	} 
	@property uint workForce() {
		return _workForce;
	}

	override public string toString() {
		return format(": %s \n Y:%s", );
	}

	uint attack(uint force) {
		if(force >= populationSum){
			_owner = null;
			resetPopulation();
			return force - capacity;
		}
		subtractPopulation(force);
		return 0;
	}

	Planet setOwner(Player player) {
		_owner = player;
		return this;
	}
	/** Sets population to default value of 1/8th maximum capacity **/
	void resetPopulation() {
		int ppa = to!int(capacity / 8 / 8);
		_population = [ppa,ppa,ppa,ppa,ppa,ppa,ppa,ppa];
	}
	/** Function affects planet's attributes. Should be called after player finishes move **/
	void step() {
		_workForce = to!uint(_population[2 .. 6].sum * _owner.knowledgeTree.branch(BranchName.Energy).effectiveness);
		affectFood();
		growPopulation();
	}
	/** 
	 * Food supply at best increases at arythmetic rate
	 * 1 > 2 > 3 > 4 > 5
	**/
	private void affectFood() {
		_food -= populationSum;
		//fpe - food production effectiveness
		double fpe = _owner.knowledgeTree.branch(BranchName.Food).effectiveness;
		_food += to!int(_workForce * fpe);
		_workForce = 0;
	}
	/**
	 * Population grows at exponential rate
	 * 1 > 2 > 4 > 8 > 16
	**/
	private void growPopulation() {
		double overPopulationFactor = 1;
		if(populationSum > capacity){
			int overflow =  populationSum - capacity;
			overPopulationFactor = overflow / capacity;
		}
		//Age the population
		for(size_t i = _population.length - 1; i>0; i--){
			_population[i] = _population[i-1];
		}
		double reproductivePairs = (_population[2] + _population[3]) / 2;
		double childPerPair = 2.5;
		double foodFactor = populationSum / _food;
		_population[0] = to!int(reproductivePairs * childPerPair * foodFactor / overPopulationFactor);
	}

	/** Converts civil units into military units **/
	uint convertUnits(int percent) {
		uint p = max(0, min(percent, 100));
		uint g1 = to!int(_population[2] * p/100);
		uint g2 = to!int(_population[3] * p/100);
		_population[2] -= g1;
		_population[3] -= g2;
		_militaryUnits += g1 + g2;
		debug {
			writefln("Substructed age group 2: %s", g1);
			writefln("Substructed age group 3: %s", g2);
			writefln("New military units: %s", _militaryUnits);
		}
		return g1 + g2;
	}

	uint percentToNumber(int percent) const {
		uint p = max(0, min(percent, 100));
		uint g1 = to!int(_population[2] * p/100);
		uint g2 = to!int(_population[3] * p/100);
		return g1 + g2;
	}

	/** Subtract value, evenly distributing across all ages where possible **/
	void subtractPopulation(uint value) {
		//TODO: check if function distributes the values as intended
		if(value > populationSum) {
			_population = [0,0,0,0,0,0,0,0];
		}
		else {
			while(value >= 0 && value <= populationSum) {
				uint perGroup = to!uint(value / _population.length);
				if(perGroup == 0) {
					perGroup = 1;
				}
				for(int i=0; i < _population.length && value > 0; i++) {
					if(_population[i] == 0)
						continue;
					if(_population[i] < perGroup) {
						value -= _population[i];
						_population[i] = 0;
					} else {
						value -= perGroup;
						_population[i] -= perGroup;
					}
				}
			}
		}
	}

	private void produceShips(Ship ship) {
		double productionCost = POPULATION_CONSTANT / 4;
		if(_workForce >= productionCost){
			_workForce -= to!int(productionCost);
			ship.complete;
		}
	}
}