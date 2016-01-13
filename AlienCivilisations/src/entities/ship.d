module src.entities.ship;

import src.entities.knowledgeTree;
import src.entities.planet;
import src.entities.player;
import std.conv;

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
		double energy = _owner.knowledgeTree.branch(BranchName.Energy).effectiveness;
		double science = _owner.knowledgeTree.branch(BranchName.Science).effectiveness;
		_capacity = cast(int)(MULTIPLIER * energy * science);
	}

	abstract @property bool empty();
}

class MilitaryShip : Ship {
	private uint _onboard = 0;

	this(Player player){
		super(player);
	}

	void attack(Planet p){
		if(p.owner && p.owner != _owner){
			p.attack(to!int(_owner.knowledgeTree.branch(BranchName.Military).effectiveness * _onboard));
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