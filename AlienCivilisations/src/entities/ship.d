/**
This module implements the ship.

Ship is abstract base class for the military and inhabitation ship.

Abstract class contains 4 properties.
Energy effectiveness and science effectiveness are also stored,
to avoid storing reference to the owner, which leads to complications
when duplicating and manipulating data.

Author: Maksym Makuch
 **/

module src.entities.ship;

import src.entities.knowledgeTree;
import src.entities.planet;
import src.entities.player;
import std.conv;
import std.stdio;

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
	/**Return maximum number of units that can held onboard**/
	@property int capacity() const {
		return capacity(_eneEff, _sciEff);
	}
	static @property int capacity(double eneEff, double sciEff) {
		return to!int(MULTIPLIER * eneEff * sciEff);
	}
	/** Returns ship capacity, calculated using player's knowledge tree properties **/
	static @property int capacity(Player player){
		double ene = player.knowledgeTree.branch(BranchName.Energy).effectiveness;
		double sci = player.knowledgeTree.branch(BranchName.Science).effectiveness;
		return to!int(MULTIPLIER * ene * sci);
	}
	/** Returns true if ship construction is completed **/
	@property bool completed(){
		return _completion >= buildCost();
	}
	/** Returns cost of building the ship **/
	@property double buildCost();
	/** Returns true when no units are left onboard **/
	@property bool empty() const {
		return _onboard <= 0;
	}
	/** Returns the effectiveness of energy branch, set at initialisation **/
	@property double eneEff() const {
		return _eneEff;
	}
	/** Returns the effectiveness of science branch, set at initialisation **/
	@property double sciEff() const {
		return _sciEff;
	}
	/** Returns the completion property of the ship **/
	@property double completion() const {
		return _completion;
	}
	/** Returns number of units onboard **/
	@property double onboard() const {
		return _onboard;
	}
	/** Combines units onboard and completion and returns the hash value **/
	override size_t toHash() nothrow {
		return cast(size_t)(_onboard + _completion);
	}
	/** Adds workforce to completion. Returns the value by which workforce overflows build cost**/
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
	/** Enforces implementation of duplication function **/
	Ship dup() const;
	/** Duplicates given ships and returns in a new array **/
	static Ship[] duplicateShips(const Ship[] originShips) {
		Ship[] duplicates;
		foreach(const Ship origin; originShips){
			duplicates ~= origin.dup();
		}
		return duplicates;
	}
}

/**
This is extension of class Ship
It implements extra functionalities to the base class
 **/
class MilitaryShip : Ship {
	static double LAMBDA = 20.0;
	this(double eneEff, double sciEff, double completion) {
		super(eneEff, sciEff, completion);
	}
	/** Adds argument to units onboard. Throw exception if total is more than maximum capacity **/
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
	/** Returns the force of the ship **/
	@property double force(double milEff) {
		return _onboard * milEff * LAMBDA;
	}
	/** Returns the construction cost of the ship, custom for military type **/
	override @property double buildCost() {
		return capacity * 3.5;
	}
	/** Return duplicate of this object **/
	override MilitaryShip dup() const {
		MilitaryShip ms = new MilitaryShip(_eneEff, _sciEff, _completion);
		ms.addUnits(_onboard);
		return ms;
	}
}

/** This is extension of class Ship **/
class InhabitationShip : Ship {
	this(double eneEff, double sciEff, double completion) {
		super(eneEff, sciEff, completion);
		_onboard = capacity;
	}
	/** Returns the construction cost of the ship, custom for inhabitation type **/
	override @property double buildCost() {
		return capacity * 1.5;
	}
	/** Return duplicate of this object **/
	override InhabitationShip dup() const {
		return new InhabitationShip(_eneEff, _sciEff, _completion);
	}
}