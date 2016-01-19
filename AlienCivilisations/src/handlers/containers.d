module src.handlers.containers;

import std.math;

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
class State {
	private {
		Map _map;
		Player[] _players;
		Ship[] _ships;
		int _queuePosition;
	}

	this(Map map, Player[] players, Ship[] ships, int queuePosition) {
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
	@property Ship ships() {
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
	
	State dup() const {
		State duplicateState;
		Map mapDup;
		Player[] playersDup;
		Planet[] planetsDup;
		Ship[] shipsDup;
		//duplicate players
		foreach(Player origin; players_) {
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
			immutable string name = origin.name;
			immutable float radius = origin.radius;
			immutable bool bA = origin.breathableAtmosphere;
			uint food = origin.food;
			uint militaryUnits = origin.militaryUnits;
			Player owner = findOwnerIndex(origin, _players, playersDup);
			Vector2d position = origin.position.dup;
			uint[8] population = origin.population.dup;
			uint workForce = origin.workForce;
			planetsDup ~= new Planet(bA, name, position, radius, food, militaryUnits, owner, population, workForce);
		}
		//duplicate map
		mapDup = new Map(_map.size, planetsDup);
		//duplicate ships
		foreach(Ship origin; _realState.ships) {
			Player owner = findOwnerIndex(origin, _players, playersDup);
			shipsDup ~= new Ship(owner, origin.completed, origin.used);
		}
		duplicateState = new State(mapDup, playersDup, shipsDup, _queuePosition);
	}
	
	private size_t findOwnerIndex(Owned obj, Player[] origins, Player[] dups) {
		foreach(size_t index, Player player; players){
			if(obj.owner && obj.owner == player)
				return dups[index];
		}
		return null;
	}
}