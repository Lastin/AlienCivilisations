module src.entities.player;

import src.entities.planet;
import src.entities.ship;
import src.entities.knowledgeTree;
import src.entities.branch;
import src.entities.map;

class Player {
	private immutable string _name;
	private GameManager _gm;
	private KnowledgeTree _knowledgeTree;
	private Ship[] _ships;
	private bool _locked = true;

	this(string name, KnowledgeTree knowledgeTree){
		_name = name;
		_knowledgeTree = knowledgeTree;
		_map = map;
	}

	@property KnowledgeTree knowledgeTree(){
		return _knowledgeTree;
	}
	@property string name(){
		return _name;
	}
	@property bool locked() const {
		return _locked;
	}
	@property Planet[] planets() {
		Planet[] playerPlanets;
		foreach(Planet p; _map.planets){
			if(p.owner && p.owner == this){
				playerPlanets ~= p;
			}
		}
		return playerPlanets;
	}
	@property Ship[] availableShips() {
		Ship[] available;
		foreach(Ship s; _ships){
			if(s.complete && !s.used){
				available ~= s;
			}
		}
		return available;
	}

	void unlock(){
		_locked = false;
	}

	Player finishTurn(){
		//int
		_locked = true;
		return this;
	}

	Player orderInhabit(Planet planet){
		if(!_locked){

		}
		return this;
	}

	Player orderShip(ShipType type){
		if(!_locked){

		}
		return this;
	}

	Player orderDevelop(Branch branch, int leaf){
		if(!_locked){

		}
		return this;
	}

	//created deep copy of variable
	Player dup(){
		return new Player(name.dup, _knowledgeTree.dup, _map.dup);
	}
}