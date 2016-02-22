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

		//#1: inhabit free planets

		Planet[] freePlanets = _realState.map.freePlanets;
		Planet[] playersPlanets = _realState.map.playerPlanets(_uniqueId);
		sort!"a.capacity > b.capacity"(freePlanets);
		foreach(planet; freePlanets) {
			if(inhabitationShips.length == 0)
				break;
			inhabitPlanet(planet);
		}
		if(freePlanets.length > 0) {
			int totalOrders = 0;
			foreach(planet; playersPlanets) {
				foreach(int index, order; planet.shipOrders) {
					if(cast(InhabitationShip)order) {
						totalOrders++;
						if(totalOrders > freePlanets.length){
							planet.cancelOrder(index);
						}
					} 
				}
			}
			if(totalOrders < freePlanets.length) {
				int planetIndex = leastAffectedPlanet(*_realState, ShipType.Inhabitation, _uniqueId);
				_realState.map.planets[planetIndex].addShipOrder(ShipType.Inhabitation);
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
	private int leastAffectedPlanet(GameState gs, ShipType st, int playerId) {
		immutable int moves = 5;
		//Planet[] playerPlanets = gs.map.playerPlanets(playerId);//gs.currentPlayer.planets(gs.map.planets);
		int index = -1;
		//The smaller the effect the better
		double smallestEffect = double.infinity;
		foreach(int i, Planet planet; gs.map.planets) {
			if(planet.ownerId == playerId) {
				//Backup essential values
				const uint[8] pop = planet.population;
				const double food = planet.food;
				const uint mu = planet.militaryUnits;
				Ship[] so1 = planet.shipOrdersDups;
				debug writefln("");
				//Population before x moves
				double sumBefore = to!double(planet.populationSum);
				for(int j=0; j<moves; j++) {
					planet.step(true);
				}
				//Population after x moves
				double sumUnaffected = to!double(planet.populationSum);
				//Restore values and place order
				planet.restore(pop, food, mu, so1);
				Ship[] so2 = planet.shipOrdersDups;
				planet.addShipOrder(st, 0);
				//Make same number of moves with order
				for(int j=0; j<moves; j++) {
					planet.step(true);
				}
				double sumAffected = to!double(planet.populationSum);
				double ratio = sumBefore / sumAffected - sumBefore / sumUnaffected;
				if(ratio < smallestEffect) {
					smallestEffect = ratio;
					index = i;
				}
				//important to restore values of planet again to one before
				planet.restore(pop, food, mu, so2);
			}
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