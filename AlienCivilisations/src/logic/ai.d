module src.logic.ai;

import src.entities.knowledgeTree;
import src.entities.map;
import src.entities.planet;
import src.entities.player;
import src.handlers.containers;
import src.entities.ship;
import std.stdio;
import core.thread;
import src.entities.branch;
import std.concurrency;

class AI : Player {
	/**THIS STATE IS ALWAYS REFERING TO REAL STATE OF THE GAME**/
	private GameState* _realState;
	this(int uniqueId, GameState* realState, KnowledgeTree knowledgeTree, Ship[] ships = null) {
		super(uniqueId, "AI", knowledgeTree, ships);
		_realState = realState;
	}
	/** Function called when it's AI's move. AI makes decisions and moves here.
	Moves that are finialised on the end of turn are executed in completeTurn() from parent class **/
	void makeMove() {
		debug writeln("AI making the move");
		Branch[] ub = knowledgeTree.undevelopedBranches;

		if(ub.length > 0) {
			foreach(branch; ub){
				GameState hyp = _realState.dup;
				hyp.ai.knowledgeTree.addOrder(branch.name);
				
			}
		}
	}
}

class Evaluator : Thread {
	GameState _stateDup;
	this(GameState realState) {
		super(&run);
		_stateDup = realState.dup();
	}
	private void run() {
	}
	void bestMove() {
	}
	void evaluateState(){

	}
}