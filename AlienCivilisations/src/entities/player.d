module src.entities.player;

import src.entities.knowledgeTree;
import src.entities.planet;
import src.entities.ship;
import src.handlers.gameManager;
import src.entities.branch;
import std.conv;
import std.algorithm.mutation;

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
	void completeTurn(Planet[] allPlanets) {
		Planet[] myPlanets = planets(allPlanets);
		int totalPopulation = 0;
		foreach(Planet planet; myPlanets) {
			totalPopulation += planet.populationSum;
			planet.step();
		}
		knowledgeTree.develop(totalPopulation);
		//TODO: add development of the knowledge tree
	}

	void attackPlanet(MilitaryShip ship, Planet planet){
		//TODO: add attacking option
		double milEff = _knowledgeTree.branch(BranchName.Military).effectiveness;
		ship.attackPlanet(planet, milEff);
	}

	void inhabitPlanet(Planet planet){
		InhabitationShip[] ihabits = inhabitationShips();
		if(planet.owner || ihabits.length < 1)
			return;
		planet.setOwner(this);
		planet.resetPopulation();
		foreach(i, Ship ship; _ships){
			if(ship == ihabits[0]){
				_ships = _ships.remove(i);
				return;
			}
		}
	}
}