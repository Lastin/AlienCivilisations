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
import src.containers.gameState;
import std.algorithm;
import std.conv;

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
		long[20] scores;
		scores[] = long.min;
		//Make order for each undeveloped branch
		Branch[] ub = knowledgeTree.undevelopedBranches;
		if(ub.length > 0) {
			foreach(possibleDev; ub) {
				GameState hyp = _realState.dup;
				addKTOrder(hyp, possibleDev.name);
			}
		} else {
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

	long negaMax(GameState gs, int depth, real beta, real alpha, PlayerEnum currentPlayer){
		PlayerEnum dead = gs.deadPlayer;
		long bestScore = 0;
		//Non-terminal node
		if(depth > 0 && dead == PlayerEnum.None) {

		}
		//Terminal node
		if(depth == 0)
			return evaluateState(gs);
		if(dead == PlayerEnum.Both)
			return 0;
		if(dead == currentPlayer)
			return long.max;
		if(dead == currentPlayer)
			return long.min;
		return bestScore;
	}
	/** returns index of planet least affected by construction of ship of given type **/
	private int leastAffectedPlanet(GameState gs, ShipType st) {
		immutable int moves = 5;
		Planet[] playerPlanets = gs.currentPlayer.planets(gs.map.planets);
		int index = -1;
		//The smaller the effect the better
		double effect = double.infinity;
		foreach(int i, planet; playerPlanets) {
			//Backup essential values
			uint[8] pop = planet.population.dup;
			double food = planet.food;
			uint mu = planet.militaryUnits;
			Ship[] so = planet.shipOrders.dup;
			//Population before x moves
			double sumBefore = to!double(planet.populationSum);
			for(int j=0; j<moves; j++) {
				planet.step();
			}
			//Population after x moves
			double sumUnaffected = to!double(planet.populationSum);
			//Restore values and place order
			planet.restore(pop, food, mu, so);
			planet.addShipOrder(st, 0);
			//Make same number of moves with order
			for(int j=0; j<moves; j++) {
				planet.step();
			}
			double sumAffected = to!double(planet.populationSum);
			double ratio = sumBefore / sumAffected - sumBefore / sumUnaffected;
			if(ratio < effect) {
				effect = ratio;
				index = i;
			}
			//important to restore values of planet again to one before
			planet.restore(pop, food, mu, so);
		}
		return index;
	}
	/** Adds kt development order for current player **/
	private void addKTOrder(GameState gs, BranchName bn) {
		gs.currentPlayer.knowledgeTree.addOrder(bn);
	}
	private long evaluateState(GameState gs) {
		return 0;
	}
}