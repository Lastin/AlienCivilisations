module src.entities.player;

import src.entities.knowledgeTree;
import src.entities.planet;
import src.entities.ship;
import src.handlers.gameManager;
import src.entities.branch;
import std.conv;

class Player {
	private immutable string _name;
	private KnowledgeTree _knowledgeTree;
	private Ship[] _ships;

	this(string name, KnowledgeTree knowledgeTree, Ship[] ships = null) {
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
	/** Returns all ships **/
	@property Ship[] ships(){
		return _ships;
	}

	@property MilitaryShip[] militaryShips(){
		MilitaryShip[] milShips;
		foreach(Ship ship; _ships){
			if(auto casted = cast(MilitaryShip)ship){
				milShips ~= casted;
			}
		}
		return milShips;
	}
	@property InhabitationShip[] inhabitationShips(){
		InhabitationShip[] inhShips;
		foreach(Ship ship; _ships){
			if(auto casted = cast(InhabitationShip)ship){
				inhShips ~= casted;
			}
		}
		return inhShips;
	}

	void addShip(Ship ship){
		_ships ~= ship;
	}
	/** Function executing actions on the end of the turn **/
	void completeTurn() {
		//1: Produce ships
		//2: 
	}

	void attackPlanet(MilitaryShip ship, Planet planet){
		//TODO: add attacking option
		uint force = to!uint(ship.onboard * _knowledgeTree.branch(BranchName.Military).effectiveness);
		planet.attack(force);
	}

	void orderInhabit(Planet planet) {

	}

	void orderDevelop(Branch branch, int leaf) {
	}

	void inhabitPlanet(Planet planet){
		if(planet.owner)
			return;
		planet.setOwner(this);
		planet.resetPopulation();
	}
}