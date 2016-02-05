module src.entities.planet;

import src.handlers.containers;
import std.algorithm;
import std.conv;
import src.entities.player;
import src.entities.ship;
import std.format;
import src.entities.knowledgeTree;
import std.stdio;
import std.math;

public enum int POPULATION_CONSTANT = 10000;
enum double FOOD_CONSUMPTION_RATE = 1;
enum double FOOD_PRODUCTION_RATE = 1.7;
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
		return format("Position: %s \n Y:%s", _position.x, _position.y);
	}
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
		_food = ppa * 8;
	}
	/** Returns workforce points based on number of units within certain age groups and knowledge boost **/
	double calculateWorkforce() {
		KnowledgeTree kt = _owner.knowledgeTree;
		double boost = kt.branch(BranchName.Energy).effectiveness * _owner.knowledgeTree.branch(BranchName.Science).effectiveness;
		double result = to!double(_population[2 .. 7].sum) * boost;
		debug writefln("Calulated workforce: %s", result);
		return result;
	}
	/** Function affects planet's attributes. Should be called after player finishes move **/
	void step() {
		double workforce = calculateWorkforce();
		debug {
			writeln("-----------------------------------------");
			writefln("Finishing step on planet %s", _name);
			writefln("Population: %s", _population);
			writefln("Workforce: %s", workforce);
		}
		//Consume at most half of the workforce on production
		workforce = workforce/2 + produceShips(workforce/2);
		debug writefln("Workforce after ships production: %s", workforce);
		affectFood(workforce);
		growPopulation();
		debug {
			writefln("New population: %s", _population);
			writeln("-----------------------------------------");
		}
	}
	/** 
	 * Food supply at best increases at arythmetic rate
	 * 1 > 2 > 3 > 4 > 5
	**/
	private void affectFood(double workforce) {
		//Consume food
		double fpe = _owner.knowledgeTree.branch(BranchName.Food).effectiveness;
		debug {
			writefln("Food: %s", _food);
			writefln("Consumed: %s", populationSum * FOOD_CONSUMPTION_RATE);
			writefln("Produced: %s", workforce * FOOD_PRODUCTION_RATE * fpe);
		}
		_food -= populationSum * FOOD_CONSUMPTION_RATE;
		_food += workforce * FOOD_PRODUCTION_RATE * fpe;
		debug writefln("New food = %s", _food);
		_food = max(_food, 0);
	}
	/**
	 * Population grows at exponential rate
	 * 1 > 2 > 4 > 8 > 16
	**/
	private void growPopulation() {
		//Age the population
		for(size_t i = _population.length - 1; i>0; i--){
			_population[i] = _population[i-1];
		}
		if(populationSum == 0){
			debug writeln("Population empty!");
			_owner = null;
			return;
		}
		double opf = 1;
		if(populationSum > capacity){
			debug writeln("[ Overpopulation takes effect! ]");
			int overflow = populationSum - capacity;
			opf += overflow / capacity;
		}

		double fpu = _food / (populationSum * FOOD_CONSUMPTION_RATE);
		double foodFactor = fpu / (fpu + 1);
		int reproductivePairs = _population[2 .. 4].sum / 2;
		debug {
			writefln("Reproductive pairs: %s", reproductivePairs);
			writefln("Food factor: %s", foodFactor);
			writefln("OPF = %s", opf);
		}
		double newBorns = reproductivePairs * CHILD_PER_PAID;
		_population[0] = to!int(newBorns * foodFactor / opf);
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
			writefln("Subtructed age group 2: %s", g1);
			writefln("Subtructed age group 3: %s", g2);
			writefln("New military units: %s", _militaryUnits);
		}
		return g1 + g2;
	}
	/** Converts percentage to military callable units **/
	uint percentToNumber(int percent) const {
		uint p = max(0, min(percent, 100));
		uint g1 = to!int(_population[2] * p/100);
		uint g2 = to!int(_population[3] * p/100);
		return g1 + g2;
	}
	/** Subtract value, evenly distributing across all ages where possible **/
	double destroyPopulation(double force) {
		debug {
			writeln("-----------------------------------------");
			writefln("Destroying population using force: %s", force);
			writefln("Population: %s",_population);
		}
		if(force >= populationSum) {
			force -= populationSum;
			_population = [0,0,0,0,0,0,0,0];
			debug writeln(_population);
			return force;
		} else {
			while(force > 0 && force <= populationSum) {
				int perG = to!int(force / 8);
				if(perG == 0){
					debug writeln(_population);
					return force;
				}
				foreach(i, int ageGroup; _population) {
					if(ageGroup == 0)
						continue;
					if(perG > ageGroup) {
						force -= ageGroup;
						_population[i] = 0;
					} else {
						_population[i] -= perG;
						force -= perG;
					}
				}
			}
		}
		debug { 
			writefln("New population: %s",_population);
			writeln("-----------------------------------------");
		}
		return force;
	}
	/** Produces ships from the queue **/
	private double produceShips(double workforce) {
		foreach(Ship s; _shipOrders) {
			workforce = s.build(workforce);
			if(s.completed){
				_owner.addShip(s);
				_shipOrders = _shipOrders[1 .. $];
			}
		}
		return workforce;
	}

	void addShipOrder(ShipType type, int units = 0) {
		double eneEff = _owner.knowledgeTree.branch(BranchName.Energy).effectiveness;
		double sciEff = _owner.knowledgeTree.branch(BranchName.Science).effectiveness;
		if(type == ShipType.Military) {
			debug {
				writefln("Planet %s. Ordered military ship: %s units", _name, units);
				if(units > _militaryUnits){
					throw new Exception("Number of requested units is larget than available on a planet");
				}
			}
			MilitaryShip ns = new MilitaryShip(eneEff, sciEff, 0);
			if(ns.capacity < units){
				ns.addUnits(ns.capacity);
				_militaryUnits -= ns.capacity;
			} else {
				ns.addUnits(units);
				_militaryUnits -= units;
			}
			_shipOrders ~= ns;
		} else {
			_shipOrders ~= new InhabitationShip(eneEff, sciEff, 0);
			debug writefln("Planet %s. Ordered inhabitation ship", _name);
		}
	}

	int stepsToCompleteOrder(Ship ship) {
		int steps = 0;
		foreach(Ship s; _shipOrders) {
			steps += to!int(ceil(s.buildCost / (calculateWorkforce / 2)));
			if(ship == s)
				return steps;
		}
		return steps;
	}

	void cancelOrder(int index){
		debug writefln("Removing order #%s", index);
		_shipOrders = _shipOrders.remove(index);
	}
}