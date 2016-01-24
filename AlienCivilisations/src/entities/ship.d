module src.entities.ship;

import src.entities.knowledgeTree;
import src.entities.planet;
import std.conv;

enum ShipType : ubyte {
	Military,
	Inhabitation
}

enum int MULTIPLIER = 1000;

abstract class Ship {
	private {
		immutable uint _capacity;
		bool _completed;
	}

	this(bool completed = false, double eneEff = 1, double sciEff = 1){
		_capacity = to!int(MULTIPLIER * eneEff * sciEff);
		_completed = completed;
	}

	/** Sets _completed property to true **/
	void complete() {
		_completed = true;
		return this;
	}
	/** Returns _completed variable **/
	@property bool completed() const {
		return _completed;
	}
	Ship dup();
}

class MilitaryShip : Ship {
	private int _onboard;
	/** Takes number onboard  **/
	this(int onboard, bool _completed = false) {
		super(completed);
		_onboard = onboard;
	}
	@property bool empty() const {
		return _onboard <= 0;
	}
	@property int onboard() const {
		return _onboard;
	}
	int kill(int amount){
		if(amount > _onboard){
			amount -= _onboard;
			_onboard = 0;
			return amount;
		}
		_onboard -= amount;
		return 0;
	}
	MilitaryShip dup() const {
		return new Ship(_onboard, _completed);
	}
}

class InhabitationShip : Ship {
	this(bool completed = false) {
		super(completed);
	}
	InhabitationShip dup() const {

	}
}