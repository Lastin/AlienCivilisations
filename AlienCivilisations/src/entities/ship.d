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
		_capacity = MULTIPLIER * (_owner.knowledgeTree.effectiveness(BranchName.Energy + _owner.knowledgeTree.effectiveness(BranchName.Science)));
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