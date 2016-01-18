module src.handlers.gameManager;

import std.random;
import src.logic.ai;
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

	this() {
		Player[] players = initialisePlayers();
		Map map = Map(_mapSize, _planetsCount, players);
		int queuePosition = uniform(0, _players.length);
		_realState = new State(map, players, queuePosition);
	}
	
	Player[] initialisePlayers() {
		Player[] players;
		players ~= new Player("Human", new KnowledgeTree(_startPoints));
		players ~= new AI(&realState, new KnowledgeTree(_startPoints));
		return players;
	}
}