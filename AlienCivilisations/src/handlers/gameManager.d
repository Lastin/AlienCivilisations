module src.handlers.gameManager;

import src.entities.map;
import src.entities.player;
import src.logic.ai;
import std.random;
import std.conv;
import src.entities.knowledgeTree;
import std.stdio;
import src.containers.gameState;

class GameManager {
	//Constant values
	private immutable float _mapSize = 5000;
	private immutable int _planetsCount = 16;
	private immutable uint[4] _sp = [0,0,0,0];
	private GameState _gs;

	this() {
		Player[] players;
		players ~= new Player(0, "Human", new KnowledgeTree(_sp));
		players ~= new AI(1, &_gs, new KnowledgeTree(_sp));
		Map map = new Map(_mapSize, _planetsCount, players);
		size_t queuePosition = uniform(0, players.length);
		_gs = new GameState(map, players, queuePosition);
	}

	this(GameState gs) {
		_gs = gs;
	}

	@property GameState state(){
		return _gs;
	}

	void endTurn(){
		debug {
			writeln("=======================================================");
			writefln("Ending turn of player: %s", _gs.currentPlayer.name);
		}
		_gs.currentPlayer.completeTurn(_gs.map.planets);
		_gs.moveQPosition();
		debug writeln("=======================================================");
		if(AI ai = cast(AI)_gs.currentPlayer){
			debug {
				writeln("=======================================================");
				writeln("AI move");
			}
			ai.makeMove();
			_gs.currentPlayer.completeTurn(_gs.map.planets);
			_gs.moveQPosition();
			debug writeln("=======================================================");
		}
		debug writefln("Current player: %s", _gs.currentPlayer.name);
	}
}