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
import std.algorithm;

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



		//#1: undeveloped branches
		//#2: free planets > use inhabitation ships
		//#3: enemy planets > attack with military ships
		//#4: order inhabitation ship
		//#5: order miliaty ships
		GameState[] possibleMoves;
		//Make order for each undeveloped branch
		Branch[] ub = knowledgeTree.undevelopedBranches;
		foreach(possibleDev; ub) {
			possibleMoves ~= _realState.dup;
			possibleMoves[$].ai.knowledgeTree.addOrder(possibleDev.name);
		}
		if(ub.length == 0) {
			//If all branches are developed
			Planet[] fp = _realState.map.freePlanets;
			if(fp.length > 0) {
				if(inhabitationShips.length == 0) {
					for(int i=0; i<fp.length; i++) {
						//try to produce different numbers of ships
					}
				} else {
					//Utilise all ships
					sort!q{a.capacity > b.capacity}(fp);
					foreach(ship; inhabitationShips) {
						
					}
				}
			}
		}
	}
	/** returns planet least affected by producing military ship **/
	private Planet lfpM(GameState gs) {
		//Planet[] planets
		return null;
	}
	/** returns planet least affected by producing inhabitation ship **/
	private Planet lfpI(GameState gs) {
		return null;
	}
	void negaMax(GameState gs, int depth, real beta, real alpha){
		/*
		//create list of possible moves
		Move bestMove = ?;
		foreach(move; possibleMoves) {
			//create duplicate
			GameState dup = gs.dup;
			//switch player
			gs.moveQPosition();
			//recurse and invert values get score
			real score = -negaMax(dup, --depth, -beta, -alpha).max;
			if(bestMove == null || score > bestMove.getMax()) {
				//if no move made or last move best so far
				bestMove = dup;
			}
			alpha = max(alpha, score);
			if(alpha >= beta)
				break;
		}
		return bestMove;
		*/
	}
}