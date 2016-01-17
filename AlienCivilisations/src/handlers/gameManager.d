module src.handlers.gameManager;

import src.entities.map;
import src.entities.player;
import src.logic.hypotheticalWorld;
import src.entities.knowledgeTree;
import std.random;
import src.logic.ai;
import src.entities.ship;
import src.entities.planet;
import src.containers.vector2d;

class GameManager {
	//Constant values
	private immutable float _mapSize = 5000;
	private immutable int _planetsCount = 16;
	private immutable int[4][5] _startPoints =
	[
		[0,0,0,0,0],
		[0,0,0,0,0],
		[0,0,0,0,0],
		[0,0,0,0,0]
	];
	private State _realState;

	this(){
		Player[] players = initialisePlayers();
		Map map = Map(_mapSize, _planetsCount, players);
		int queuePosition = uniform(0, _players.length);
		_realState = new State(map, players, queuePosition);
	}
	
	Player[] initialisePlayers(){
		Player[] players;
		players ~= new Player("Human", new KnowledgeTree(_startPoints));
		players ~= new AI(&realState, new KnowledgeTree(_startPoints));
		return players;
	}

	State createDuplicate(){
		State duplicateState;
		Map mapDup;
		Player[] playersDup;
		Ship[] shipsDup;
		Planet[] planetsDup;
		//duplicate players
		foreach(Player origin; _realState.players){
			string name = origin.name;
			KnowledgeTree ktDup = origin.knowledgeTree.dup;
			if(cast(AI)origin){
				playersDup ~= new AI(&duplicateState, ktDup);
			}
			else {
				playersDup ~= new Player(name, ktDup);
			}
		}
		//duplicate planets
		foreach(Planet origin; _realState.map.planets){
			immutable string name = origin.name;
			immutable float radius = origin.radius;
			immutable bool bA = origin.breathableAtmosphere;
			uint food = origin.food;
			uint militaryUnits = origin.militaryUnits;
			Player owner = {
				auto ownerIndex = findOwnerIndex(origin, _realState.players);
				ownerIndex > -1 ? playersDup[ownerIndex] : null;
			};
			Vector2d position = origin.position.dup;
			uint[8] population = origin.population.dup;
			planetsDup ~= new Planet(bA, name, position, radius, food, militaryUnits, owner, population);
		}
		//duplicate ships
		foreach(Ship origin; _realState.ships){

		}
	}

	private size_t findOwnerIndex(Planet planet, Player[] players){
		foreach(size_t index, Player player; players){
			if(planet.owner && planet.owner == player){
				return index;
			}
		}
		return -1;
	}
}

/** Container for current, or hypothetical game state, holding references to all essential data **/
class State {
	private Map _map;
	private Player[] _players;
	private Ship[] _ships;
	private int _queuePosition;
	this(Map map, Player[] players, Ship[] ships, int queuePosition){
		_map = map;
		_players = players;
		_ships = ships;
		_queuePosition = queuePosition;
	}
	@property Map map(){
		return _map;
	}
	@property Player[] players(){
		return players;
	}
	@property Player currentPlayer(){
		return players[_queuePosition];
	}
	@property Ship ships(){
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
	void moveQPosition(){
		if(++_queuePosition == _players.length){
			_queuePosition = 0;
		}
	}
}