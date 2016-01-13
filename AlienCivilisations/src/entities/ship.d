module src.entities.ship;

import src.entities.planet;
import src.entities.player;
import src.logic.knowledgeTree;
import std.algorithm;

enum ShipType : ubyte {
	Military,
	Inhabitation
}

enum int MULTIPLIER = 1000;

class Ship {

	private immutable uint _capacity;
	private Player _owner;


	this(Player owner){
		_owner = owner;
		_capacity = 
		//TODO: add capacity initialiser
	}

	abstract @property bool empty();
}

class MilitaryShip : Ship {
	private uint _onboard = 0;
	private immutable uint _militaryLevel;

	this(Player player, uint militaryLevel){
		super(player);
		_militaryLevel = militaryLevel;
	}

	void attack(Planet p){
		if(p.owner && p.owner != _owner){
			p.attack(_militaryLevel * _onboard);
		}
	}

	int addUnits(uint units) {
		uint freeSpaces = _capacity - _onboard;
		if(freeSpaces >= units){
			_onboard += units;
			return 0;
		}
		_onboard = _capacity;
		return units - freeSpaces;
	}
}

class InhabitationShip : Ship {
	private uint[8] _onboard = [0,0,0,0,0,0,0,0];

	this(Player player, uint[8] population){
		super(player);
		_onboard = population;
	}

	void inhabit(Planet p){
		if(p.owner == _owner && !empty){
			p.setOwner(_owner, _onboard);
		}
	}
}