module src.entities.ship;

import src.entities.knowledgeTree;
import src.entities.planet;
import std.conv;
import std.stdio;
import src.entities.player;

enum int MULTIPLIER = 1000;

enum ShipType : ubyte {
	Military,
	Inhabitation
}

abstract class Ship {
	private {
		double _eneEff;
		double _sciEff;
		double _completion;
		int _onboard;
	}

	this(double eneEff, double sciEff, double completion){
		_eneEff = eneEff;
		_sciEff = sciEff;
		_completion = completion;
	}
	/**Return number of units that can fit onboard**/
	@property int capacity() const {
		return capacity(_eneEff, _sciEff);//to!int(MULTIPLIER * _eneEff * _sciEff);
	}
	static @property int capacity(double eneEff, double sciEff) {
		return to!int(MULTIPLIER * eneEff * sciEff);
	}
	/** Returns ship capacity for player with given knowledge tree levels**/
	static @property int capacity(Player player){
		double ene = player.knowledgeTree.branch(BranchName.Energy).effectiveness;
		double sci = player.knowledgeTree.branch(BranchName.Science).effectiveness;
		return to!int(MULTIPLIER * ene * sci);
	}
	/**Returns boolean whether the construction is completed**/
	@property bool completed(){
		return _completion >= buildCost();
	}
	/**Returns build cost of the ship**/
	@property double buildCost();
	/**Returns true when no units onboard**/
	@property bool empty() const {
		return _onboard <= 0;
	}
	/**Returns number of units onboard**/
	@property int unitsOnboard() const {
		return _onboard;
	}
	@property double eneEff() const {
		return _eneEff;
	}
	@property double sciEff() const {
		return _sciEff;
	}
	@property double completion() const {
		return _completion;
	}
	@property double onboard() const {
		return _onboard;
	}
	override size_t toHash() nothrow {
		return cast(size_t)(_onboard + _completion);
	}
	/**Adds workforce to completion, eventually completing the construction**/
	double build(double workforce){
		version(debugShip) writefln("MS: cost: %s | force: %s", buildCost, workforce);
		if(workforce >= buildCost - _completion){
			workforce = buildCost - _completion;
			_completion = buildCost;
		} else {
			_completion += workforce;
			workforce = 0;
		}
		return workforce;
	}
	Ship dup() const;
	/** Handy function for duplicating list of ships **/
	static Ship[] duplicateShips(const Ship[] originShips) {
		Ship[] duplicates;
		foreach(const Ship origin; originShips){
			duplicates ~= origin.dup();
		}
		return duplicates;
	}
}

class MilitaryShip : Ship {
	static double LAMBDA = 10.0;
	this(double eneEff, double sciEff, double completion) {
		super(eneEff, sciEff, completion);
	}
	void addUnits(int units){
		if(_onboard+units > capacity){
			throw new Exception("Units beyond capacity");
		}
		_onboard += units;
	}
	/** Perform attack on a given planet **/
	void attackPlanet(Planet planet, double milEff, bool affectShip){
		double force = force(milEff);
		double rest = planet.destroyPopulation(force);
		planet.setAttacked();
		if(affectShip)
			_onboard = to!int(rest / milEff / LAMBDA);
	}
	@property double force(double milEff) {
		return _onboard * milEff * LAMBDA;
	}
	override @property double buildCost() {
		return capacity * 3.5;
	}
	/** Return duplicate of the object **/
	override MilitaryShip dup() const {
		MilitaryShip ms = new MilitaryShip(_eneEff, _sciEff, _completion);
		ms.addUnits(_onboard);
		return ms;
	}
}

class InhabitationShip : Ship {
	this(double eneEff, double sciEff, double completion) {
		super(eneEff, sciEff, completion);
		_onboard = capacity;
	}
	override @property double buildCost() {
		return capacity * 1.5;
	}
	/** Return duplicate of the object **/
	override InhabitationShip dup() const {
		return new InhabitationShip(_eneEff, _sciEff, _completion);
	}
}