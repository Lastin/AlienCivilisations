/**
This module implements the planets used in game.
It offers to constructors:
-taking 5 arguments, other values of the planet are set to 0 or null
-taking all parameters, used to duplicate the planet, or create object from the values read from JSON

Name, position, radius, breathable atmosphere and unique identifier are immutable.

Function with member function attribute "const" are to be used to inform the
compiler explicitly, that an object on which the function is called should not modify that object

Author: Maksym Makuch
 **/

module src.entities.planet;

import src.containers.point2d;
import src.entities.knowledgeTree;
import src.entities.player;
import src.entities.ship;
import std.algorithm;
import std.conv;
import std.digest.md;
import std.format;
import std.math;
import std.stdio;

public enum int POPULATION_CONSTANT = 10000;
enum double FOOD_CONSUMPTION_RATE = 1;
enum double FOOD_PRODUCTION_RATE = 1.7;
enum double CHILD_PER_PAID = 2.5;

//version = planetDebug;

class Planet {
	private {
		immutable string _name;
		immutable Point2D _position;
		immutable float _radius;
		immutable bool _breathableAtmosphere;
		immutable int _uniqueId;
		Player _owner = null;
		uint[8] _population = [0,0,0,0,0,0,0,0];
		double _food = 0;
		uint _militaryUnits = 0;
		Ship[] _shipOrders;
		int _attackedCount = 0;
	}
	/** Constructor for creating new planet with 0 or null values **/
	this(int uniqueId, string name, Point2D position, float radius, bool breathableAtmosphere) {
		_uniqueId = uniqueId;
		_breathableAtmosphere = breathableAtmosphere;
		_name = name;
		_position = position;
		_radius = radius;
	}
	/** (Cloning) Constructor for creating planet from existing values **/
	this(int uniqueId, string name, Point2D position, float radius, bool breathableAtmosphere,
		uint[8] population, double food, uint militaryUnits, Ship[] shipOrders) {
		this(uniqueId, name, position, radius, breathableAtmosphere);
		_population = population;
		_food = food;
		_militaryUnits = militaryUnits;
		_shipOrders = shipOrders;
	}
	/** Returns duplicate of the planet. Ownership is assigned to the player in argument **/
	Planet dup(Player newOwner) const {
		string name = name();
		int uniqueId = uniqueId();
		Point2D pos = position();
		float r = radius();
		bool ba = breathableAtmosphere();
		uint[8] pop = population();
		double food = food();
		uint mu = militaryUnits();
		Ship[] so = shipOrdersDups();
		Planet pDup = new Planet(uniqueId, name, pos, r, ba, pop, food, mu, so);
		pDup.setOwner(newOwner);
		return pDup;
	}
	/** Returns the position of the planet **/
	@property Point2D position() {
		return _position;
	}
	/** Returns the position of the planet **/
	@property Point2D position() const {
		return _position.dup;
	}
	/** Returns the breathable atmosphere property **/
	@property bool breathableAtmosphere() const {
		return _breathableAtmosphere;
	}
	/** Returns the capacity of the planet, calculated using radius **/
	@property int capacity() {
		return to!int(_radius / 10 * POPULATION_CONSTANT);
	}
	/** Returns the total of the population array **/
	@trusted @property uint populationSum() const nothrow {
		return _population[].sum;
	}
	/** Returns the radius **/
	@property float radius() const {
		return _radius;
	}
	/** Returns the name **/
	@property string name() const {
		return _name;
	}
	/** Returns the reference of the owner **/
	@property Player owner() {
		return _owner;
	}
	/** Returns the food property **/
	@property double food() const {
		return _food;
	}
	/** Returns the military units on this planet **/
	@property uint militaryUnits() const {
		return _militaryUnits;
	}
	/** Returns the population array of this planet **/
	@property uint[8] population() {
		return _population;
	}
	/** Returns the population array of this planet **/
	@property uint[8] population() const {
		uint[8] na;
		foreach(i, number; _population) {
			na[i] = number;
		}
		return na;
	}
	/** Returns the unique identifier of the planet owner, or -1 if owner is null **/
	@property int ownerId() const {
		if(!_owner)
			return -1;
		return _owner.uniqueId;
	}
	/** Returns the array of ships ordered to produce **/
	@property Ship[] shipOrders() {
		return _shipOrders;
	}
	/** Returns the duplicate of the ship orders array. All object inside are duplicated **/
	@property Ship[] shipOrdersDups() const {
		return Ship.duplicateShips(_shipOrders);
	}
	/** Returns the unique identifier of this planet **/
	@property int uniqueId() const {
		return _uniqueId;
	}
	/** Returns the name and position of this planet as string **/
	override public string toString() {
		return format("Planet: %s Position X:%s Y:%s", _name, _position.x, _position.y);
	}
	/** Sets new owner **/
	Planet setOwner(Player player) {
		_owner = player;
		if(!_owner)
			_shipOrders = null;
		return this;
	}
	/** Increases attacks on the planet counter or sets to value **/
	void setAttacked(int attackedCount = 0) {
		if(attackedCount > 0) {
			_attackedCount = attackedCount;
		} else {
			_attackedCount++;
		}
	}
	/** Sets count of attacks on planet to 0 **/
	void clearAttacked() {
		_attackedCount = 0;
	}
	/** Returns the count of attacks on the planet **/
	@property int attackedCount() {
		return _attackedCount;
	}
	/** Sets new owner of the planet and distributes units onboard across population array **/
	void inhabit(Player owner, InhabitationShip ship){
		if(owner)
			return;
		_owner = owner;
		int ppa = to!int(ship.onboard / 8);
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
		if(!owner)
			return 0.0;
		KnowledgeTree kt = _owner.knowledgeTree;
		double boost = kt.branch(BranchName.Energy).effectiveness * _owner.knowledgeTree.branch(BranchName.Science).effectiveness;
		double result = to!double(_population[2 .. 7].sum) * boost;
		version(planetDebug) writefln("Calulated workforce: %s", result);
		return result;
	}
	/** Function called on the end of player's turn.
	 * Function affects planet's attributes.
	 * Function calculates workforce, produces ships and modifies food value and population
	 **/
	void step(bool affectOwner) {
		double workforce = calculateWorkforce();
		version(planetDebug) {
			writeln("-----------------------------------------");
			writefln("Finishing step on planet %s", _name);
			writefln("Population: %s", _population);
			writefln("Workforce: %s", workforce);
		}
		//Consume at most half of the workforce on production
		workforce = workforce/2 + produceShips(workforce/2, affectOwner);
		version(planetDebug) writefln("Workforce after ships production: %s", workforce);
		affectFood(workforce);
		growPopulation();
		version(planetDebug) {
			writefln("New population: %s", _population);
			writeln("-----------------------------------------");
		}
		_food = 0;
	}
	/** Function modifies the food value depending on the given workforce and population **/
	private void affectFood(double workforce) {
		/** Food supply at best increases at arythmetic rate
		 * 1 > 2 > 3 > 4 > 5 **/
		//Consume food
		double fpe = _owner.knowledgeTree.branch(BranchName.Food).effectiveness;
		version(planetDebug) {
			writefln("Food: %s", _food);
			writefln("Consumed: %s", populationSum * FOOD_CONSUMPTION_RATE);
			writefln("Produced: %s", workforce * FOOD_PRODUCTION_RATE * fpe);
		}
		_food -= populationSum * FOOD_CONSUMPTION_RATE;
		_food += workforce * FOOD_PRODUCTION_RATE * fpe;
		version(planetDebug) writefln("New food = %s", _food);
		_food = max(_food, 0);
	}
	/** Function modifies the population, using multiple properties **/
	private void growPopulation() {
		/** Population grows at exponential rate
		 * 1 > 2 > 4 > 8 > 16 **/
		//set overpopulation to 1
		double opf = 1;
		//Ff population overflows, then calculate opf
		if(populationSum > capacity){
			version (planetDebug) writeln("[ Overpopulation takes effect! ]");
			double overflow = populationSum - capacity;
			opf -= (overflow / capacity);
			opf = max(opf, 0.01);
		}
		// Remove ownership if population extincted
		if(populationSum == 0){
			version(planetDebug) writeln("Population empty!");
			_owner = null;
			return;
		}
		//Calculate food per unit and food factor 
		double fpu = _food / (populationSum * FOOD_CONSUMPTION_RATE);
		double foodFactor = (fpu / (fpu + 1)) * 2;
		foodFactor = min(1.5, max(foodFactor, 0.01));
		//Age the population
		for(size_t i = _population.length - 1; i>0; i--){
			_population[i] = _population[i-1];
		}
		int reproductivePairs = _population[2 .. 5].sum / 2;
		double birthFactor = CHILD_PER_PAID * foodFactor * opf;
		birthFactor = min(7, max(birthFactor, 0.01));
		double newBorns = reproductivePairs * birthFactor;
		version(planetDebug) {
			writefln("Reproductive pairs: %s", reproductivePairs);
			writefln("Food factor: %s", foodFactor);
			writefln("OPF = %s", opf);
			writefln("Birth factor = %s", birthFactor);
		}
		//Add newborns to the head of the array
		_population[0] = to!int(newBorns);
		assert(_population[0] >= 0);
	}
	/** Converts given percent of the civil units (from certain groups)  into military **/
	uint convertUnits(int percent) {
		uint p = max(0, min(percent, 100));
		uint g1 = to!int(_population[2] * p/100);
		uint g2 = to!int(_population[3] * p/100);
		_population[2] -= g1;
		_population[3] -= g2;
		_militaryUnits += g1 + g2;
		version(planetDebug) {
			writefln("Subtructed age group 2: %s", g1);
			writefln("Subtructed age group 3: %s", g2);
			writefln("New military units: %s", _militaryUnits);
		}
		return g1 + g2;
	}
	/** Converts percentage to military convertible units **/
	uint percentToNumber(int percent) const {
		uint p = max(0, min(percent, 100));
		uint g1 = to!int(_population[2] * p/100);
		uint g2 = to!int(_population[3] * p/100);
		return g1 + g2;
	}
	/** Converts given number to percent of the convertible units (0 to 100)**/
	int numberToPercent(int amount) const {
		int target = amount * 100 / _population[2..4].sum;
		return min(100, max(target, 0));
	}
	/** Subtract value, evenly distributing across all ages where possible **/
	double destroyPopulation(double force) {
		version(planetDebug) {
			writeln("-----------------------------------------");
			writefln("Destroying population using force: %s", force);
			writefln("Population: %s",_population);
		}
		if(!owner)
			return force;
		if(force >= populationSum) {
			force -= populationSum;
			_population = [0,0,0,0,0,0,0,0];
		} else {
			while(force > 0 && force <= populationSum) {
				int perG = to!int(force / 8);
				if(perG == 0){
					version(planetDebug) writeln(_population);
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
		if(populationSum == 0) {
			setOwner(null);
		}
		version(planetDebug) { 
			writefln("New population: %s",_population);
			writeln("-----------------------------------------");
		}
		return force;
	}
	/** Produces ships from the queue, removes from queue if finished **/
	private double produceShips(double workforce, bool addToOwner) {
		foreach(Ship s; _shipOrders) {
			workforce = s.build(workforce);
			if(s.completed){
				if(addToOwner) {
					_owner.addShip(s);
				}
				_shipOrders = _shipOrders[1 .. $];
			}
		}
		return workforce;
	}
	/** Adds order for ship production to the end of the queue **/
	void addShipOrder(ShipType type, int units = 0) {
		double eneEff = _owner.knowledgeTree.branch(BranchName.Energy).effectiveness;
		double sciEff = _owner.knowledgeTree.branch(BranchName.Science).effectiveness;
		if(type == ShipType.Military) {
			units = min(_militaryUnits, units);
			if(units < 1)
				return;
			MilitaryShip ns = new MilitaryShip(eneEff, sciEff, 0);
			int toLoad = min(ns.capacity, units);
			ns.addUnits(toLoad);
			_militaryUnits -= toLoad;
			_shipOrders ~= ns;
			debug writeln(toLoad);
		} else {
			_shipOrders ~= new InhabitationShip(eneEff, sciEff, 0);
		}
	}
	/** Returns number of steps needed to complete the ship. Number may change with every turn **/
	int stepsToCompleteOrder(Ship ship) {
		int steps = 0;
		foreach(Ship s; _shipOrders) {
			steps += to!int(ceil(s.buildCost / (calculateWorkforce() / 2)));
			if(ship == s)
				return steps;
		}
		return steps;
	}
	/** Removes order at index from the queue **/
	void cancelOrder(int index){
		version(planetDebug) writefln("Removing order #%s", index);
		_shipOrders = _shipOrders.remove(index);
	}
	/** Cancels all orders and destroys objects **/
	void cancelAllOrders() {
		for(int i=0; i<_shipOrders.length; i++) {
			_shipOrders[i].destroy();
			_shipOrders[i] = null;
		}
		_shipOrders = null;
	}
	/** Returns length of ship queue in steps. Calculated using current production rate. Number may change with every turn **/
	int queueInSteps(){
		double neededDev = 0;
		foreach(ship; _shipOrders) {
			double needed = ship.buildCost - ship.completion;
			neededDev += needed;
		}
		double prodRate = calculateWorkforce() / 2;
		prodRate = max(prodRate, 1);
		return to!int(neededDev / prodRate);
	}
	/** Sets object fields to given parameters **/
	void restore(uint[8] pop, double food, uint mu, Ship[] so) {
		_population = pop;
		_food = food;
		_militaryUnits = mu;
		_shipOrders = so;
	}
	/** Combines data from components of this object to produce hash value **/
	override size_t toHash() nothrow {
		double sum = 0;
		sum += populationSum;
		sum += _food;
		sum += _militaryUnits;
		sum += _owner.toHash;
		foreach(so; _shipOrders) {
			sum += so.toHash;
		}
		sum += _attackedCount;
		return cast(size_t)(sum);
	}
}