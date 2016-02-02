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
	private immutable uint[4] _sp = [0,0,0,0];
	private GameState _gs;

	this() {
		Player[] players;
		players ~= new Player("Human", new KnowledgeTree(_sp));
		players ~= new AI(&_gs, new KnowledgeTree(_sp));
		Map map = new Map(_mapSize, _planetsCount, players);
		size_t queuePosition = uniform(0, players.length);
		_gs = new GameState(map, players, queuePosition);
	}

	@property GameState state(){
		return _gs;
	}

	void endTurn(){
		debug writefln("Ending turn of player: %s", _gs.currentPlayer.name);
		_gs.currentPlayer.completeTurn(_gs.map.planets);
		_gs.moveQPosition();
		if(AI ai = cast(AI)_gs.currentPlayer){
			ai.makeMove();
			_gs.currentPlayer.completeTurn(_gs.map.planets);
			_gs.moveQPosition();
		}
		debug writefln("Current player: %s", _gs.currentPlayer.name);
	}
}