module src.states.state;

import std.stdio;
import std.range;
import std.conv;
import src.handlers.gameManager;

class State {
	GameManager gm;
	bool consoleEnabled = false;
	uint[] accChars;
	this(GameManager gm){
		this.gm = gm;
	}
}

