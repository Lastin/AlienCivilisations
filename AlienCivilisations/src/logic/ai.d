module src.logic.ai;

import src.entities.knowledgeTree;
import src.entities.map;
import src.entities.planet;
import src.entities.player;
import src.entities.ship;
import std.stdio;
import core.thread;
import src.entities.branch;
import std.concurrency;
import std.parallelism;
import std.datetime;
import src.containers.gameState;

class AI : Player {
	/**THIS STATE IS ALWAYS REFERING TO REAL STATE OF THE GAME**/
	private GameState* _realState;
	private GameState[] duplicates;
	this(int uniqueId, GameState* realState, KnowledgeTree knowledgeTree, Ship[] ships = null) {
		super(uniqueId, "AI", knowledgeTree, ships);
		_realState = realState;
	}
	/** Function called when it's AI's move. AI makes decisions and moves here.
	Moves that are finialised on the end of turn are executed in completeTurn() from parent class **/
	void makeMove() {
		debug {
			writeln("AI making decisions");
			writefln("CPUs: %s", totalCPUs);
		}
		Branch[] ub = knowledgeTree.undevelopedBranches;
		//#1: undeveloped branches
		//#2: free planets > use inhabitation ships
		//#3: enemy planets > attack with military ships
		//#4: order inhabitation ship
		//#5: order miliaty ships
		GameState[] possibleMoves;
		//Make order for each undeveloped branch
		foreach(possibleDev; ub) {
			possibleMoves ~= _realState.dup;
			possibleMoves[$].ai.knowledgeTree.addOrder(possibleDev.name);
		}

	}
	/** returns planet least affected by producing military ship **/
	private Planet lfpM(Planet[] planets) {
		return null;
	}
	/** returns planet least affected by producing inhabitation ship **/
	private Planet lfpI(Planet[] planets) {
		return null;
	}

}