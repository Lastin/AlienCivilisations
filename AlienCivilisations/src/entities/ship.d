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
		return to!int(MULTIPLIER * _eneEff * _sciEff);
	}

	/**Returns boolean whether the construction is completed**/
	@property bool completed(){
		return _completion >= buildCost();
	}
	/**Returns build cost of the ship**/
	@property double buildCost() const {
		return capacity * 0.5;
	}
	/**Returns number of units onboard**/
	@property int unitsOnboard() const {
		return _onboard;
	}
	/**Adds workforce to completion, eventually completing the construction**/
	double build(double workforce){
		if(workforce >= buildCost - _completion){
			workforce = buildCost - _completion;
			_completion = buildCost;
		} else {
			_completion += workforce;
			workforce = 0;
		}
		return workforce;
	}
	Ship dup();
}

class MilitaryShip : Ship {
	private int _onboard;
	this(double eneEff, double sciEff, double completion) {
		super(eneEff, sciEff, completion);
	}
	/**Returns true when no units onboard**/
	@property bool empty() const {
		return _onboard <= 0;
	}
	void addUnits(int units){
		if(_onboard+units > capacity){
			throw new Exception("Units beyond capacity");
		}
		_onboard += units;
	}

	void attackPlanet(Planet planet, double milEff){
		debug writefln("Onboard before: %s", _onboard);
		double force = _onboard * milEff;
		double rest = planet.destroyPopulation(force);
		_onboard = to!int(rest / milEff);
		debug writefln("Onboard after: %s", _onboard);
	}

	/*int kill(int amount){
		if(amount > _onboard){
			amount -= _onboard;
			_onboard = 0;
			return amount;
		}
		_onboard -= amount;
		return 0;
	}*/
	MilitaryShip dup() const {
		MilitaryShip ms = new MilitaryShip(_eneEff, _sciEff, _completion);
		ms.addUnits(_onboard);
		return ms;
	}
}

class InhabitationShip : Ship {
	private int _onboard;
	this(double eneEff, double sciEff, double completion) {
		super(eneEff, sciEff, completion);
		_onboard = to!int(capacity);
	}
	InhabitationShip dup() const {
		return new InhabitationShip(_eneEff, _sciEff, _completion);
	}
}