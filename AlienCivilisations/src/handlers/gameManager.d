module src.handlers.gameManager;

import src.entities.map;
import src.entities.player;
import src.logic.hypotheticalWorld;
import src.entities.knowledgeTree;
import std.random;
import src.logic.ai;

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
		players ~= new Player(&realState, "Human", new KnowledgeTree(_startPoints));
		players ~= new AI(&realState, new KnowledgeTree(_startPoints));
		return players;
	}

	State createDuplicate(){
		
	}
}

/** Container for current, or hypothetical game state, holding references to all essential data **/
class State {
	private Map _map;
	private Player[] _players;
	private int _queuePosition;
	this(Map map, Player[] players, int queuePosition){
		_map = map;
		_players = players;
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
	/** Moves queue position to next available position **/
	void moveQPosition(){
		if(++_queuePosition == _players.length){
			_queuePosition = 0;
		}
	}
}