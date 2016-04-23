/**
This module implements the game manager.
Main task of this function is to call appropriate functions on the end of the turn.
The reference to this object is passed between objects in-game, to avoid referencing issues.

It hold the immutable values, which specify initialisation properties of a new gameplay.
Those values can be modified, and old save files would still be functional.

Author: Maksym Makuch
 **/

module src.handlers.gameManager;

import src.containers.gameState;
import src.entities.knowledgeTree;
import src.entities.map;
import src.entities.player;
import src.logic.ai;
import src.screens.play;
import std.conv;
import std.format;
import std.random;
import std.stdio;

class GameManager {
	//Constant values
	private immutable float _mapSize = 5000;
	private immutable int _planetsCount = 16;
	private immutable uint[4] _sp = [0,0,0,0];
	private GameState _gs;

	/** Initialises players, map and sets the queue position, then initialises new game state **/
	this() {
		Player[] players;
		players ~= new Player(0, "Human", new KnowledgeTree(_sp));
		players ~= new AI(1, new KnowledgeTree(_sp));
		Map map = new Map(_mapSize, _planetsCount, players);
		size_t queuePosition = uniform(0, players.length);
		_gs = new GameState(map, players, queuePosition);
	}
	/** Does not intialise players and map, only uses given game state **/
	this(GameState gs) {
		_gs = gs;
	}
	/** Returns the current, real game state **/
	@property GameState state(){
		return _gs;
	}
	/** Calls functions of the player to complete the turn. If AI, first calls makeMove() then updates AI action list widget **/
	void endTurn(Play play){
		_gs.currentPlayer.completeTurn(_gs.map.planets);
		_gs.moveQPosition();
		debug {
			writeln("=======================================================");
			writefln("Moving player %s", _gs.currentPlayer.name);
		}
		if(AI ai = cast(AI)_gs.currentPlayer){
			ai.makeMove(_gs, play);
			_gs.currentPlayer.completeTurn(_gs.map.planets);
			play.addAIAction(format("AI owns %s miliary ships", _gs.currentPlayer.militaryShips.length));
			play.addAIAction(format("AI owns %s inhabitation ships", _gs.currentPlayer.inhabitationShips.length));
			_gs.moveQPosition();
		}
		debug {
			writeln("=======================================================");
		}
	}
}