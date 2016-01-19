module src.handlers.containers;

import std.math;
import src.entities.map;
import src.entities.player;
import src.entities.ship;
import src.entities.planet;
import src.entities.knowledgeTree;
import src.logic.ai;

struct Vector2d {
	float x;
	float y;
	this(float x_param, float y_param) {
		x = x_param;
		y = y_param;
	}

	float getEuclideanDistance(Vector2d vecA) {
		auto xdiff = vecA.x - x;
		auto ydiff = vecA.y - y;
		return sqrt(xdiff^^2 + ydiff^^2);
	}

	Vector2d dup() const {
		return Vector2d(x, y);
	}
}

/** Container for current, or hypothetical game state, holding references to all essential data **/
class GameState {
	private {
		Map _map;
		Player[] _players;
		Ship[] _ships;
		size_t _queuePosition;
	}

	this(Map map, Player[] players, Ship[] ships, size_t queuePosition) {
		_map = map;
		_players = players;
		_ships = ships;
		_queuePosition = queuePosition;
	}
	@property Map map() {
		return _map;
	}
	@property Player[] players() {
		return players;
	}
	@property Player currentPlayer() {
		return players[_queuePosition];
	}
	@property Ship[] ships() {
		return _ships;
	}
	/** Returns all complete and not used ships which belong to p**/
	@property Ship[] availableShips(Player p) {
		Ship[] available;
		foreach(Ship s; _ships){
			if(s.owner == p && s.complete && !s.used){
				available ~= s;
			}
		}
		return available;
	}
	/** Moves queue position to next available position **/
	void moveQPosition() {
		if(++_queuePosition == _players.length){
			_queuePosition = 0;
		}
	}
	
	GameState dup() {
		GameState duplicateState;
		Map mapDup;
		Player[] playersDup;
		Planet[] planetsDup;
		Ship[] shipsDup;
		//duplicate players
		foreach(Player origin; _players) {
			string name = origin.name;
			KnowledgeTree ktDup = origin.knowledgeTree.dup;
			if(cast(AI)origin){
				playersDup ~= new AI(&duplicateState, ktDup);
			} else {
				playersDup ~= new Player(name, ktDup);
			}
		}
		//duplicate planets
		foreach(Planet origin; _map.planets) {
			string name = origin.name;
			Vector2d position = origin.position;
			float radius = origin.radius;
			bool ba = origin.breathableAtmosphere;
			uint[8] population = origin.population.dup;
			uint food = origin.food;
			uint militaryUnits = origin.militaryUnits;
			uint workForce = origin.workForce;
			Planet cpy = new Planet(name, position, radius, ba, population, food, workForce, militaryUnits);
			cpy.setOwner(findOwnerIndex(origin, _players, playersDup));
			planetsDup ~= cpy;
		}
		//duplicate map
		mapDup = new Map(_map.size, planetsDup);
		//duplicate ships
		foreach(Ship origin; _ships) {
			Player owner = findOwnerIndex(origin, _players, playersDup);
			shipsDup ~= new Ship(owner, origin.complete, origin.used);
		}
		duplicateState = new GameState(mapDup, playersDup, shipsDup, _queuePosition);
		return duplicateState;
	}
	
	private Player findOwnerIndex(Owned obj, Player[] origins, Player[] dups) const {
		foreach(size_t index, const Player player; _players){
			if(obj.owner && obj.owner == player)
				return dups[index];
		}
		return null;
	}
}