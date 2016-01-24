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
		size_t _queuePosition;
	}

	this(Map map, Player[] players, size_t queuePosition) {
		_map = map;
		_players = players;
		_queuePosition = queuePosition;
	}
	@property Map map() {
		return _map;
	}
	@property Player[] players() {
		return _players;
	}
	@property Player currentPlayer() {
		return _players[_queuePosition];
	}
	/** Moves queue position to next available position **/
	void moveQPosition() {
		if(++_queuePosition == _players.length){
			_queuePosition = 0;
		}
	}
	
	GameState dup() {
		GameState duplicateState;
		Player[] playersDup = duplicatePlayers();
		Planet[] planetsDup = duplicatePlanets(playersDup);
		//duplicate map
		mapDup = new Map(_map.size, planetsDup);
		duplicateState = new GameState(mapDup, playersDup, _queuePosition);
		return duplicateState;
	}

	/** Function used by duplicatePlayers function **/
	private Ship[] duplicateShips(Ship[] originShips) {
		Ship[] duplicates;
		foreach(Ship origin; originShips){
			duplicates ~= origin.dup();
		}
		return duplicates;
	}

	private Player[] duplicatePlayers() {
		Player[] duplicates;
		foreach(Player origin; _players) {
			duplicates ~= new Player(
				origin.name,
				origin.knowledgeTree.dup,
				duplicateShips(origin.ships)
				);
		}
		return duplicates;
	}

	private Planet[] duplicatePlanets(Player[] playersDup){
		Planet[] duplicates;
		foreach(Planet origin; map.planets){
			string name = origin.name;
			Vector2d pos = origin.position;
			float r = origin.radius;
			bool ba = origin.breathableAtmosphere;
			uint[8] pop = origin.population.dup;
			uint food = origin.food;
			uint mu = origin.militaryUnits;
			duplicates ~= new Planet(name, pos, r, ba, pop, food, mu);
			duplicates[$].owner = newOwner(origin, playersDup);
		}
		return duplicates;
	}

	private Player newOwner(Planet planet, Player[] playersDup) {
		if(!planet.owner){
		} else {
			foreach(i, Player p; playersDup){
				if(p == planet.owner)
					return playersDup[i];
			}
			throw new Exception("Cannot find planet owner");
		}
	}
}