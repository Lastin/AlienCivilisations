module src.entities.player;

import src.entities.knowledgeTree;
import src.entities.planet;
import src.entities.ship;
import src.handlers.gameManager;
import src.entities.branch;

class Player {
	private immutable string _name;
	private KnowledgeTree _knowledgeTree;
	private Ship[] _ships;

	this(string name, KnowledgeTree knowledgeTree, Ship[] ships) {
		_name = name;
		_knowledgeTree = knowledgeTree;
		_ships = ships;
	}
	/** Returns player's knowledge tree **/
	@property KnowledgeTree knowledgeTree() {
		return _knowledgeTree;
	}
	/** Player's written name **/
	@property string name() const {
		return _name;
	}
	/** Returns planets which belong to the player **/
	@property Planet[] planets(Planet[] list){
		Planet[] owned;
		foreach(Planet p; list) {
			if(p.owner == this)
				owned ~= p;
		}
		return owned;
	}
	/** Returns all complete and not used ships which belong to p**/
	@property Ship[] availableShips() {
		Ship[] available;
		foreach(Ship s; _ships){
			if(s.complete && !s.used){
				available ~= s;
			}
		}
		return available;
	}
	/** Returns all ships **/
	@property Ship[] ships(){
		_ships;
	}
	/** Function executing actions on the end of the turn **/
	void completeTurn() {
		//1: Produce ships
		//2: 
		return this;
	}

	void orderInhabit(Planet planet) {
		return this;
	}

	void orderShip(ShipType type) {
		return this;
	}

	void orderDevelop(Branch branch, int leaf) {
		return this;
	}

	void inhabitPlanet(Planet planet){
		if(planet.owner)
			return;
		planet.setOwner(this);
		planet.resetPopulation();
	}
}