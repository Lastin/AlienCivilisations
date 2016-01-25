module src.entities.ship;

import src.entities.knowledgeTree;
import src.entities.planet;
import std.conv;

enum int MULTIPLIER = 1000;

abstract class Ship {
	private {
		bool _completed;
		double _eneEff;
		double _sciEff;
	}

	this(bool completed = false, double eneEff = 1, double sciEff = 1){
		_completed = completed;
		_eneEff = eneEff;
		_sciEff = sciEff;
	}

	/** Sets _completed property to true **/
	void complete() {
		_completed = true;
	}
	/** Returns _completed variable **/
	@property bool completed() const {
		return _completed;
	}
	@property uint capacity() const {
		return to!int(MULTIPLIER * _eneEff * _sciEff);
	}
	Ship dup();
}

class MilitaryShip : Ship {
	private int _onboard;
	/** Takes number onboard  **/
	this(bool _completed = false, double eneEff = 1, double sciEff = 1, int onboard = 1) {
		super(completed, eneEff, sciEff);
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
		return new MilitaryShip(_completed, _eneEff, _sciEff, onboard);
	}
}

class InhabitationShip : Ship {
	this(bool _completed = false,  double eneEff = 1, double sciEff = 1) {
		super(completed, eneEff, sciEff);
	}
	InhabitationShip dup() const {
		return new InhabitationShip(_completed, _eneEff, _sciEff);
	}
}