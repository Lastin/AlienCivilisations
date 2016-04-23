/**
This module implements the player.
It is base class for AI.
It hold:
-unique identifier
-name
-knowledge tree object
-array of ships owned by the player

Author: Maksym Makuch
 **/

module src.entities.player;

import src.entities.branch;
import src.entities.knowledgeTree;
import src.entities.map;
import src.entities.planet;
import src.entities.ship;
import src.handlers.gameManager;
import std.algorithm.mutation;
import std.conv;
import std.stdio;

class Player {
	private {
		protected string _name;
		KnowledgeTree _knowledgeTree;
		Ship[] _ships;
		protected int _uniqueId;
	}
	/** Constructor. Ships array is optional **/
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
	/** Returns the duplicate of the player's knowledge tree **/
	@property KnowledgeTree knowledgeTree() const {
		return _knowledgeTree.dup;
	}
	/** Returns player's name **/
	@property string name() const {
		return _name;
	}
	/** Returns the planets owned by the player. Found from the given list **/
	@property Planet[] planets(Planet[] list){
		Planet[] owned;
		foreach(Planet p; list) {
			if(p.owner && p.owner.uniqueId == _uniqueId)
				owned ~= p;
		}
		return owned;
	}
	/** Returns the array of population, combined from all planets owned by the player **/
	@property uint[8] population(Planet[] list) {
		Planet[] owned = planets(list);
		uint[8] total = [0,0,0,0,0,0,0,0];
		foreach(planet; owned) {
			total[] += planet.population[];
		}
		return total;
	}
	/** Returns all ships owned by the player **/
	@property Ship[] ships(){
		return _ships;
	}
	/** Returns duplicates of all ships owned by the player **/
	@property Ship[] ships() const {
		Ship[] duplicates;
		foreach(const Ship origin; _ships){
			duplicates ~= origin.dup();
		}
		return duplicates;
	}
	/** Returns sum of the population from all planets owned by this player **/
	@property uint populationSum(Planet[] planets) {
		uint sum = 0;
		foreach(planet; planets) {
			if(planet.ownerId == _uniqueId)
				sum += planet.populationSum;
		}
		return sum;
	}
	/** Returns true if player has no units and inhabitation ships left **/
	@property bool dead(Map map) {
		bool dead = populationSum(map.planets) == 0 && (inhabitationShips.length == 0 || map.freePlanets.length == 0);
		return dead; 
	}
	/** Returns all ships of military type, owned by this player **/
	@property MilitaryShip[] militaryShips() {
		MilitaryShip[] milShips;
		foreach(Ship ship; _ships){
			if(MilitaryShip casted = cast(MilitaryShip)ship){
				milShips ~= casted;
			}
		}
		return milShips;
	}
	/** Returns the sum of forces on all military ships owned by this player **/
	@property totalMilitaryForce() {
		double sum = 0;
		MilitaryShip[] ms = militaryShips();
		double milEff = _knowledgeTree.branch(BranchName.Military).effectiveness;
		foreach(ship; ms) {
			sum += ship.force(milEff);
		}
		return sum;
	}
	/** Returns all ships of inhabitation type, owned by this player **/
	@property InhabitationShip[] inhabitationShips(){
		InhabitationShip[] inhShips;
		foreach(Ship ship; _ships){
			if(auto casted = cast(InhabitationShip)ship){
				inhShips ~= casted;
			}
		}
		return inhShips;
	}
	/** Returns player's unique identifier**/
	@property int uniqueId() const {
		return _uniqueId;
	}
	/** Adds a ship to list of ships owned by this player **/
	void addShip(Ship ship){
		_ships ~= ship;
	}
	/** Function executes the actions on the end of turn. Calls function to update planets and develop knowledge tree. **/
	void completeTurn(Planet[] allPlanets) {
		Planet[] myPlanets = planets(allPlanets);
		int totalPopulation = 0;
		foreach(Planet planet; myPlanets) {
			totalPopulation += planet.populationSum;
			planet.step(true);
			planet.clearAttacked();
		}
		knowledgeTree.develop(totalPopulation);
	}
	/** Attacks given planet using given military ship with force based on player knowledge tree and units onboard that ship **/
	void attackPlanet(MilitaryShip attackingShip, Planet planet, bool affectShip = true){
		double milEff = _knowledgeTree.branch(BranchName.Military).effectiveness;
		attackingShip.attackPlanet(planet, milEff, affectShip);
		if(attackingShip.empty) {
			foreach(i, Ship ship; _ships){
				if(ship == attackingShip){
					writeln("ship empty removing");
					_ships = _ships.remove(i);
				}
			}
		}
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
	/** Returns the sum of military units from all planets **/
	@property uint totalMilitaryUnits (Planet[] allP) {
		uint total = 0;
		Planet[] owned = planets(allP);
		foreach(planet; owned) {
			total += planet.militaryUnits;
		}
		return total;
	}
	/** Returns player with given unique id, from given list of players. Null if id is -1.
	 * Throws exception or null if not found, depending on the compilation flag **/
	static Player findPlayerWithId(int ownerId, Player[] players) {
		if(ownerId == -1){
			return null;
		} else {
			foreach(p; players){
				if(p.uniqueId == ownerId)
					return p;
			}
			debug {
				throw new Exception("Cannot find planet owner");
			} else {
				return null;
			}
		}
	}
	/** Combines data from components of this object to produce hash value **/
	override size_t toHash() nothrow {
		double sum = 0;
		foreach(s; _ships) {
			sum += s.toHash;
		}
		sum += _uniqueId;
		sum += _knowledgeTree.toHash;
		return cast(size_t)sum;
	}
}