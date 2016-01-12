module src.entities.ship;

import src.entities.planet;
import src.entities.player;
import std.algorithm;

class Ship {
	private immutable uint _capacity;
	private Player _owner;

	this(Player owner, uint sciencel, uint energyl){
		_owner = owner;
		_capacity = 1000 * (sciencel + energyl);
	}

	@property bool empty(){
		return (onboard == 0);
	}
}

class MilitaryShip : Ship {
	private uint _onboard = 0;
	private immutable uint _militaryLevel;

	this(uint militaryLevel){
		_militaryLevel = militaryLevel;
	}

	void attack(Planet p){
		if(p.getOwner && p.getOwner != ship_owner){
			p.attack(military_level * onboard);
		}
	}

	int addUnits(uint units) {
		uint free_spaces = capacity - onboard;
		if(free_spaces >= units){
			onboard += units;
			return 0;
		}
		onboard = capacity;
		return units - free_spaces;
	}
}

class InhabitationShip : Ship {
	private uint[8] _onboard = [0,0,0,0,0,0,0,0];

	this(uint[8] population){
		_onboard = population;
	}

	void inhabit(Planet p){
		if(p.owner == _owner && !empty){
			p.setOwner(_owner, _onboard);
		}
	}
}