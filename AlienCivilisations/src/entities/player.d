module src.entities.player;

import src.entities.knowledgeTree;
import src.entities.planet;
import src.entities.ship;
import src.handlers.gameManager;
import src.entities.branch;
import std.conv;
import std.algorithm.mutation;

class Player {
	private {
		immutable string _name;
		KnowledgeTree _knowledgeTree;
		Ship[] _ships;
		immutable int _uniqueId;
	}

	this(int uniqueId, string name, KnowledgeTree knowledgeTree, Ship[] ships = null) {
		_uniqueId = uniqueId;
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
	@property int uniqueId() {
		return _uniqueId;
	}
	/** Adds a ship to list of player'savailable ships **/
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
	}
	/** Attacks given planet using given military ship with force based on player knowledge tree and ship units **/
	void attackPlanet(MilitaryShip ship, Planet planet){
		double milEff = _knowledgeTree.branch(BranchName.Military).effectiveness;
		ship.attackPlanet(planet, milEff);
		//TODO: remove ship after attacking if empty
	}
	/** Inhabits given planet using first available inhabitation ship **/
	void inhabitPlanet(Planet planet) {
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
	/** Returns player with given unique id, or null if none found **/
	static Player findPlayerWithId(int id, Player[] players) {
		foreach(player; players) {
			if(id == player.uniqueId)
				return player;
		}
		return null;
	}
}