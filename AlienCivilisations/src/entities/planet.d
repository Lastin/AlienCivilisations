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
enum double FOOD_CONSUMPTION_RATE = 1;
enum double CHILD_PER_PAID = 2.5;

class Planet {
	private {
		immutable string _name;
		immutable Vector2d _position;
		immutable float _radius;
		immutable bool _breathableAtmosphere;
		Player _owner;
		uint[8] _population = [0,0,0,0,0,0,0,0];
		double _food = 0;
		uint _militaryUnits = 0;
		Ship[] _shipOrders;
	}

	this(string name, Vector2d position, float radius, bool breathableAtmosphere) {
		_breathableAtmosphere = breathableAtmosphere;
		_name = name;
		_position = position;
		_radius = radius;
	}
	/** (Cloning) Constructor for creating planet from existing values **/
	this(string name, Vector2d position, float radius, bool breathableAtmosphere,
		uint[8] population, double food, uint militaryUnits, Ship[] shipOrders) {
		this(name, position, radius, breathableAtmosphere);
		_population = population;
		_food = food;
		_militaryUnits = militaryUnits;
		_shipOrders = shipOrders;
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
	@property double food() const {
		return _food;
	}
	@property uint militaryUnits() const {
		return _militaryUnits;
	}
	@property uint[8] population() {
		return _population;
	}

	@property Ship[] shipOrders() {
		return _shipOrders;
	}

	override public string toString() {
		return format(": %s \n Y:%s", );
	}

	/*uint attack(uint force) {
		if(force >= populationSum){
			_owner = null;
			return force - capacity;
		}
		subtractPopulation(force);
		return 0;
	}*/

	Planet setOwner(Player player) {
		_owner = player;
		_shipOrders = null;
		return this;
	}
	/**Sets new owner of the planet and sets units from inhabitation ship**/
	void inhabit(Player owner, InhabitationShip ship){
		if(owner)
			return;
		_owner = owner;
		int ppa = to!int(ship.unitsOnboard / 8);
		_population = [ppa,ppa,ppa,ppa,ppa,ppa,ppa,ppa];
	}
	/** Sets population to default value of 1/8th maximum capacity **/
	void resetPopulation() {
		int ppa = to!int(capacity / 8 / 8);
		_population = [ppa,ppa,ppa,ppa,ppa,ppa,ppa,ppa];
	}

	/** Returns workforce points based on number of units within certain age groups and knowledge boost **/
	double calculateWorkforce() {
		KnowledgeTree kt = _owner.knowledgeTree;
		double boost = kt.branch(BranchName.Energy).effectiveness * _owner.knowledgeTree.branch(BranchName.Science).effectiveness;
		double result = to!double(_population[2 .. 6].sum) * boost;
		debug writefln("Calulated workforce: %s", result);
		return result;
	}
	/** Function affects planet's attributes. Should be called after player finishes move **/
	void step() {
		double workforce = calculateWorkforce();
		workforce = produceShips(workforce);
		affectFood(workforce);
		growPopulation();
	}
	/** 
	 * Food supply at best increases at arythmetic rate
	 * 1 > 2 > 3 > 4 > 5
	**/
	private void affectFood(double workforce) {
		//Consume food
		_food -= populationSum * FOOD_CONSUMPTION_RATE;
		double fpe = _owner.knowledgeTree.branch(BranchName.Food).effectiveness;
		_food += workforce * fpe;
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
		int reproductivePairs = _population[2 .. 3].sum / 2;
		double foodFactor = populationSum * FOOD_CONSUMPTION_RATE / _food;
		//Threshold to stop foodFactoring from going negative
		if(foodFactor < 0){
			foodFactor = 0.001;
		}
		_population[0] = to!int(reproductivePairs * CHILD_PER_PAID * foodFactor / overPopulationFactor);
		debug writefln("Newborn number: %s", _population[0]);
		assert(_population[0] >= 0);
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
	void destroyPopulation(uint force) {
		//TODO: check if function distributes the values as intended
		if(force > populationSum) {
			_population = [0,0,0,0,0,0,0,0];
			_owner = null;
		} else {
			while(force > 0 && force <= populationSum) {
				debug writefln("Force: %s", force);
				int perG = to!int(force / 8);
				debug writefln("Per group: %s", perG);
				if(perG == 0)
					return;
				foreach(i, int ageGroup; _population) {
					if(ageGroup == 0)
						continue;
					if(perG > ageGroup) {
						_population[i] = 0;
						force -= ageGroup;
					} else {
						_population[i] -= perG;
						force -= perG;
					}
				}
			}
			debug writefln("Exit population: %s", _population);
		}
	}

	private double produceShips(double workforce) {
		//double productionCost = POPULATION_CONSTANT / 2;
		foreach(Ship s; _shipOrders) {
			if(workforce < shipProdCost) {
				return workforce;
			}
			workforce -= shipProdCost;
			_owner.addShip(s);
			_shipOrders = _shipOrders[1 .. $];
		}
		return workforce;
	}

	void addShipOrder(ShipType type, int units = 0) {
		double eneEff = _owner.knowledgeTree.branch(BranchName.Energy).effectiveness;
		double sciEff = _owner.knowledgeTree.branch(BranchName.Science).effectiveness;
		if(type == ShipType.Military) {
			debug {
				writefln("Added order for new military ship with %s units", units);
				if(units > _militaryUnits){
					throw new Exception("Number of requested units is larget than available on a planet");
				}
			}
			_militaryUnits -= units;
			_shipOrders ~= new MilitaryShip(eneEff, sciEff, 0, units);
		} else {
			debug writeln("Added new inhabitation ship to the queue");
			_shipOrders ~= new InhabitationShip(eneEff, sciEff, 0);
		}
	}

	@property double shipProdCost() const {
		//5 age groups contributing
		//5000 = minimum starting number in each group on smallest planet
		//40-81 radius / 10 * population constant
		return 5000 * 5/8 * 0.7;
	}

	int stepsToCompleteOrder(Ship ship) {
		int steps = 1;
		double workforce = calculateWorkforce();
		for(int i=0; i < _shipOrders.length; i++){
			if(workforce >= shipProdCost){
				workforce -= shipProdCost;
			} else {
				workforce = calculateWorkforce();
				steps++;
			}
			if(ship == _shipOrders[i]){
				return steps;
			}
		}
		return steps;
	}

	void cancelOrder(int index){
		debug writefln("Removing order %s", index);
		_shipOrders = _shipOrders.remove(index);
	}
}