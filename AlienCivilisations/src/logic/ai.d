module src.logic.ai;

import src.entities.knowledgeTree;
import src.entities.map;
import src.entities.planet;
import src.entities.player;
import src.handlers.containers;
import src.entities.ship;
import std.stdio;

class AI : Player{
	/**THIS STATE IS ALWAYS REFERING TO REAL STATE OF THE GAME**/
	private GameState* _realState;
	this(GameState* realState, KnowledgeTree knowledgeTree, Ship[] ships = null) {
		super("AI", knowledgeTree, ships);
		_realState = realState;
	}
	void makeMove(){
		debug writeln("AI making the move");
	}
}