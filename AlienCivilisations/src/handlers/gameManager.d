module src.handlers.gameManager;

import src.entities.map;
import src.entities.player;
import src.handlers.containers;
import src.logic.ai;
import std.random;
import std.conv;
import src.entities.knowledgeTree;
import std.stdio;

class GameManager {
	//Constant values
	private immutable float _mapSize = 5000;
	private immutable int _planetsCount = 16;
	private immutable int[][] _startPoints =
	[
		[0,0,0,0,0],
		[0,0,0,0,0],
		[0,0,0,0,0],
		[0,0,0,0,0]
	];
	private GameState _realState;

	this() {
		Player[] players;
		players ~= new Player("Human", new KnowledgeTree(_startPoints.to!(int[][])));
		players ~= new AI(&_realState, new KnowledgeTree(_startPoints.to!(int[][])));
		Map map = new Map(_mapSize, _planetsCount, players);
		size_t queuePosition = uniform(0, players.length);
		_realState = new GameState(map, players, queuePosition);
	}

	@property GameState state(){
		return _realState;
	}

	void endTurn(){
		_realState.currentPlayer.completeTurn();
		_realState.moveQPosition;
		if(AI ai = cast(AI)_realState.currentPlayer){
			ai.makeMove();
		}
		_realState.moveQPosition();
	}
}