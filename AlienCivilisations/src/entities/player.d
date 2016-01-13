module src.entities.player;

import src.entities.planet;
import src.entities.ship;
import src.entities.knowledgeTree;
import src.entities.branch;

class Player {
	private Planet[] _planets;
	private Ship[] _ships;
	private immutable string _name;
	private KnowledgeTree _knowledgeTree;
	private bool _locked = true;

	this(string name, KnowledgeTree knowledgeTree){
		_name = name;
		_knowledgeTree = knowledgeTree;
	}

	@property KnowledgeTree knowledgeTree(){
		return _knowledgeTree;
	}

	@property Planet[] planets(){
		return _planets;
	}

	@property string name(){
		return _name;
	}

	Player addPlanet(Planet p){
		_planets ~= p;
		return this;
	}

	Player finishTurn(){
		//int
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
		return new Player(name.dup, _knowledgeTree.dup);
	}
}