module src.entities.planet;

import src.handlers.containers;
import std.algorithm;
import std.conv;
import src.entities.player;
import src.entities.ship;
import std.format;
import src.entities.knowledgeTree;

public enum int POPULATION_CONSTANT = 10000;

class Planet : Owned {
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
		uint[8] population, uint food, uint workForce, uint militaryUnits) {
		this(name, position, radius, breathableAtmosphere);
		_population = population;
		_food = food;
		_workForce = workForce;
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
	@property uint populationSum() {
		return _population[].sum;
	}
	@property float radius() {
		return _radius;
	}
	@property string name() {
		return _name;
	}
	override @property Player owner() {
		return _owner;
	}
	@property uint food() {
		return _food;
	}
	@property uint militaryUnits() {
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

	private void affectFood() {
		//TODO
		//food supply at best increases at arythmetic rate
		//1 > 2 > 3 > 4 > 5
		_food -= populationSum;
		//fpe - food production effectiveness
		double fpe = _owner.knowledgeTree.branch(BranchName.Food).effectiveness;
		_food += to!int(_workForce * fpe);
		_workForce = 0;
	}
	private void growPopulation() {
		double overPopulationFactor = 1;
		if(populationSum > capacity){
			int overflow =  populationSum - capacity;
			overPopulationFactor = overflow / capacity;
		}
		//population grows at exponential rate
		//1 > 2 > 4 > 8 > 16
		//but is also affected by the food
		for(size_t i = _population.length - 1; i>0; i--){
			//elder the population
			_population[i] = _population[i-1];
		}
		double reproductivePairs = (_population[2] + _population[3]) / 2;
		double childPerPair = 2.5;
		double foodFactor = populationSum / _food;
		_population[0] = to!int(reproductivePairs * childPerPair * foodFactor / overPopulationFactor);
	}

	uint militarise(int percent) {
		uint p = min(percent, 100);
		uint g1 = to!int(p/100 * _population[2]);
		uint g2 = to!int(p/100 * _population[3]);
		_population[2] -= g1;
		_population[3] -= g2;
		_militaryUnits += g1 + g2;
		return g1 + g2;
	}

	void subtractPopulation(uint value) {
		//TODO: check if function distributes the values as intended
		if(value > populationSum){
			_population = [0,0,0,0,0,0,0,0];
		}
		else {
			while(value >= 0){
				uint perGroup = to!uint(value / _population.length);
				if(perGroup == 0){
					perGroup = 1;
				}
				for(int i=0; i < _population.length; i++){
					if(_population[i] == 0)
						continue;
					if(_population[i] < perGroup){
						_population[i] = 0;
						value -= _population[i];
					}
					else {
						_population[i] -= perGroup;
						value -= perGroup;
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