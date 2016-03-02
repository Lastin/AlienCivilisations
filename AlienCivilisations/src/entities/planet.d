module src.entities.planet;

import std.algorithm;
import std.conv;
import src.entities.player;
import src.entities.ship;
import std.format;
import src.entities.knowledgeTree;
import std.stdio;
import std.math;
import src.containers.point2d;
import std.digest.md;

public enum int POPULATION_CONSTANT = 10000;
enum double FOOD_CONSUMPTION_RATE = 1;
enum double FOOD_PRODUCTION_RATE = 1.7;
enum double CHILD_PER_PAID = 2.5;

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
	/** Returns duplicate of the planet. Takes object to not pass wrong owner reference **/
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

	@property Point2D position() {
		return _position;
	}
	@property Point2D position() const {
		return _position.dup;
	}
	@property bool breathableAtmosphere() const {
		return _breathableAtmosphere;
	}
	@property int capacity() {
		return to!int(_radius / 10 * POPULATION_CONSTANT);
	}
	@trusted @property uint populationSum() const nothrow {
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
	@property uint[8] population() const {
		uint[8] na;
		foreach(i, number; _population) {
			na[i] = number;
		}
		return na;
	}
	@property int ownerId() const {
		if(!_owner)
			return -1;
		return _owner.uniqueId;
	}
	@property Ship[] shipOrders() {
		return _shipOrders;
	}
	@property Ship[] shipOrdersDups() const {
		return Ship.duplicateShips(_shipOrders);
	}
	@property int uniqueId() const {
		return _uniqueId;
	}

	override public string toString() {
		return format("Planet: %s Position X:%s Y:%s", _name, _position.x, _position.y);
	}
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
		if(!owner)
			return 0.0;
		KnowledgeTree kt = _owner.knowledgeTree;
		double boost = kt.branch(BranchName.Energy).effectiveness * _owner.knowledgeTree.branch(BranchName.Science).effectiveness;
		double result = to!double(_population[2 .. 7].sum) * boost;
		debug writefln("Calulated workforce: %s", result);
		return result;
	}
	/** Function affects planet's attributes. Should be called after player finishes move **/
	void step(bool affectOwner) {
		double workforce = calculateWorkforce();
		debug {
			writeln("-----------------------------------------");
			writefln("Finishing step on planet %s", _name);
			writefln("Population: %s", _population);
			writefln("Workforce: %s", workforce);
		}
		//Consume at most half of the workforce on production
		workforce = workforce/2 + produceShips(workforce/2, affectOwner);
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
		double opf = 1;
		if(populationSum > capacity){
			debug writeln("[ Overpopulation takes effect! ]");
			double overflow = populationSum - capacity;
			double lambda = 9.5;
			opf -= (overflow / capacity) * lambda;
			if(opf <= 0){
				opf = 0.1;
			}
		}
		//Age the population
		for(size_t i = _population.length - 1; i>0; i--){
			_population[i] = _population[i-1];
		}
		if(populationSum == 0){
			debug writeln("Population empty!");
			_owner = null;
			return;
		}

		double fpu = _food / (populationSum * FOOD_CONSUMPTION_RATE);
		double foodFactor = (fpu / (fpu + 1)) * 2;
		int reproductivePairs = _population[2 .. 4].sum / 2;
		debug {
			writefln("Reproductive pairs: %s", reproductivePairs);
			writefln("Food factor: %s", foodFactor);
			writefln("OPF = %s", opf);
		}
		double newBorns = reproductivePairs * CHILD_PER_PAID;
		_population[0] = to!int(newBorns * foodFactor * opf);
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
	int numberToPercent(int amount) const {
		int min = 0;
		int max = 100;
		int pos = 0;
		int tries = 0;
		while(min < max && tries <5) {
			pos = (max - min) / 2;
			uint result = percentToNumber(pos);
			if(amount == result)
				return pos;
			if(result < amount)
				min = pos;
			else if(result > amount)
				max = pos;
			tries++;
		}
		return pos;
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
		if(populationSum == 0) {
			_owner = null;
		}
		debug { 
			writefln("New population: %s",_population);
			writeln("-----------------------------------------");
		}
		return force;
	}
	/** Produces ships from the queue **/
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
	/** Adds order for ship to queue **/
	Ship addShipOrder(ShipType type, int units = 0) {
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
			return _shipOrders[$-1];
		} else {
			_shipOrders ~= new InhabitationShip(eneEff, sciEff, 0);
			debug writefln("Planet %s. Ordered inhabitation ship", _name);
			return _shipOrders[$-1];

		}
	}
	/** Returns number of steps needed to complete the ship **/
	int stepsToCompleteOrder(Ship ship) {
		int steps = 0;
		foreach(Ship s; _shipOrders) {
			steps += to!int(ceil(s.buildCost / (calculateWorkforce / 2)));
			if(ship == s)
				return steps;
		}
		return steps;
	}
	/** Removes order at index from queue **/
	void cancelOrder(int index){
		debug writefln("Removing order #%s", index);
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
	/** Sets object fields to given parameters **/
	void restore(uint[8] pop, double food, uint mu, Ship[] so) {
		_population = pop;
		_food = food;
		_militaryUnits = mu;
		_shipOrders = so;
	}
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
		return cast(size_t)(sum);//super.toHash;
	}
}