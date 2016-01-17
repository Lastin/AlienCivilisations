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

class Ship : Owned {
	private immutable uint _capacity;
	private Player _owner;
	private bool _completed;
	private bool _used;

	this(Player owner, bool completed = false, bool used = false){
		_owner = owner;
		double energy = _owner.knowledgeTree.branch(BranchName.Energy).effectiveness;
		double science = _owner.knowledgeTree.branch(BranchName.Science).effectiveness;
		_capacity = cast(int)(MULTIPLIER * energy * science);
		_completed = completed;
		_used = used;
	}

	Ship completeShip(){
		_completed = true;
		return this;
	}

	@property bool complete() const {
		return _complete;
	}
	@property bool used() const {
		return _used;
	}
	override @property Player owner(){
		return _owner;
	}
}

class MilitaryShip : Ship {
	private uint _onboard = 0;

	this(Player player){
		super(player);
	}

	void attack(Planet p){
		if(p.owner && p.owner != _owner){
			double effectiveness = _owner.knowledgeTree.branch(BranchName.Military).effectiveness;
			uint attackPower = to!int(effectiveness * _onboard);
			if(double left = p.attack(attackPower) / effectiveness < 1){
				_onboard = 0;
				used = true;
			}
			else {
				_onboard = to!int(left);
			}
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

	@property bool empty() const {
		return _onboard <= 0;
	}
	@property uint onboard() const {
		return _onboard;
	}
}

class InhabitationShip : Ship {
	this(Player player, uint[8] population){
		super(player);
	}

	void inhabit(Planet p){
		if(p.owner == _owner){
			p.setOwner(_owner);
		}
	}
}