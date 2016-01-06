module src.states.gameState;

import std.stdio;
import std.range;
import std.conv;
import src.handlers.gameManager;
import dlangui;

class GameState : VerticalLayout {
	GameManager gm;
	bool consoleEnabled = false;
	uint[] accChars;
	this(GameManager gm){
		this.gm = gm;
	}
}

