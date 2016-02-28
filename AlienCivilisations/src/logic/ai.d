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
import std.math;

class AI : Player {
	this(int uniqueId, KnowledgeTree knowledgeTree, Ship[] ships = null) {
		super(uniqueId, "AI", knowledgeTree, ships);
	}
	/** Function called when it's AI's move. AI makes decisions and moves here.
	Moves that are finialised on the end of turn are executed in completeTurn() from parent class **/
	void makeMove(GameState realState) {
		debug {
			writeln("AI making decisions");
			writefln("CPUs: %s", totalCPUs);
		}
		//#1: free planets > use inhabitation ships
		Planet[] freePlanets = realState.map.freePlanets;
		sort!"a.capacity > b.capacity"(freePlanets);
		size_t ihc = inhabitationShips.length;
		foreach(planet; freePlanets) {
			if(ihc == 0)
				break;
			inhabitPlanet(planet);
			ihc--;
		}

		Planet[] pp = realState.map.playerPlanets(_uniqueId);
		double enemyAggression = 0;
		foreach(planet; pp) {
			enemyAggression += planet.attackedCount;
		}

		//#2: undeveloped branches
		void* action;
		long[] scores;
		foreach(branch; knowledgeTree.undevelopedBranches()){
			GameState dup = realState.dup;

		}
		//negamax(dup, 4, -inifinity, +infinity, false);
		//#3: enemy planets > attack with military ships
		//#4: order inhabitation ship
		//#5: order miliaty ships
	}

	long negaMax(GameState gs, int depth,real alpha, real beta, bool maximising) const {
		//Check if terminal node
		if(depth == 0)
			return evaluateState(gs);
		PlayerEnum dead = gs.deadPlayer;
		if(dead == PlayerEnum.Both) {
			//Both players dead, neither good nor bad
			return 0;
		}
		else if(dead == gs.currentPlayerEnum) {
			//Current player is dead, worst output
			return long.min;
		}
		else if(dead != PlayerEnum.None){
			//Oponent is dead, best output
			return long.max;
		}
		//Non-terminal node
		long bestScore = long.min;
		if(depth > 0 && dead == PlayerEnum.None) {
			GameState[] combinations = possibleCombinations(gs);
			foreach(combination; combinations) {
				long score = -negaMax(combination, ++depth, -beta, -alpha, !maximising);
				bestScore = max(bestScore, score);
				alpha = max(alpha, score);
				if(alpha >= beta)
					break;
			}
		}
		return bestScore;
	}
	/** Returns uniqueId of planet least affected by construction of ship of given type **/
	private int leastAffectedPlanet(GameState gs, ShipType st, int playerId) {
		immutable int moves = 5;
		//Planet[] playerPlanets = gs.map.playerPlanets(playerId);//gs.currentPlayer.planets(gs.map.planets);
		int id = -1;
		//The smaller the effect the better
		double smallestEffect = double.infinity;
		foreach(Planet planet; gs.map.planets) {
			if(planet.ownerId == playerId) {
				//Backup essential values
				const uint[8] pop = planet.population;
				const double food = planet.food;
				const uint mu = planet.militaryUnits;
				Ship[] so1 = planet.shipOrdersDups;
				Ship[] so2 = planet.shipOrdersDups;
				debug writefln("");
				//Population before x moves
				double sumBefore = to!double(planet.populationSum);
				for(int j=0; j<moves; j++) {
					planet.step(false);
				}
				//Population after x moves
				double sumUnaffected = to!double(planet.populationSum);
				//Restore values and place order
				planet.restore(pop, food, mu, so1);
				planet.addShipOrder(st, 0);
				//Make same number of moves with order
				for(int j=0; j<moves; j++) {
					planet.step(false);
				}
				double sumAffected = to!double(planet.populationSum);
				double ratio = sumBefore / sumAffected - sumBefore / sumUnaffected;
				if(ratio < smallestEffect) {
					smallestEffect = ratio;
					id = planet.uniqueId;
				}
				//Restore values
				planet.restore(pop, food, mu, so2);
			}
		}
		return id;
	}
	/** Adds kt development order for current player **/
	private void addKTOrder(GameState gs, BranchName bn) {
		gs.currentPlayer.knowledgeTree.addOrder(bn);
	}
	/** Return uniqueId of planet most affected by attacks **/
	private int mostAffectedPlanet(GameState gs) const {
		Planet[] aps = gs.notCurrentPlayer.planets(gs.map.planets);
		Player attacker = gs.currentPlayer();
		double greatestEffect = double.min_normal;
		int id = -1;
		foreach(ap; aps) {
			size_t planetBH = ap.toHash;
			size_t playerBH = attacker.toHash;
			Planet testField = ap.dup(ap.owner);
			foreach(ms; attacker.militaryShips) {
				attacker.attackPlanet(ms, testField, false);
				testField.step(false);
			}
			double effect = to!double(ap.populationSum);
			double divisor = to!double(testField.populationSum);
			if(divisor == 0) {
				divisor = 0.5;
			}
			effect /= divisor;
			if(effect > greatestEffect) {
				greatestEffect = effect;
				id = ap.uniqueId;
			}
			debug writefln("testfield hash: %s", testField.toHash);
			assert(ap.toHash == planetBH && attacker.toHash == playerBH);
		}
		debug writefln("Most affected planet id: %s with value: %s", id, greatestEffect);
		return id;
	}
	private long evaluateState(GameState gs) const {
		return 0;
	}
	private GameState[] possibleCombinations(GameState original) const {
		GameState[] combinations;
		Branch[] ub = original.currentPlayer().knowledgeTree().undevelopedBranches();
		if(ub.length > 0) {
			foreach(branch; ub) {
				GameState testGS = original.dup();
				testGS.currentPlayer.knowledgeTree.clearOrders();
				testGS.currentPlayer.knowledgeTree.addOrder(branch.name);
				//Attack most valuable enemy planet/s
				while(testGS.currentPlayer.militaryShips().length > 0 && testGS.notCurrentPlayer.planets(testGS.map.planets).length > 0) {
					Planet mvp = testGS.map.planetWithId(mostAffectedPlanet(testGS));
					MilitaryShip[] ms = testGS.currentPlayer.militaryShips();
					foreach(ship; ms) {
						testGS.currentPlayer.attackPlanet(ship, mvp, true);
						if(mvp.populationSum == 0)
							break;
					}
				}
				//end turn once decisions are made
				testGS.currentPlayer.completeTurn(testGS.map.planets);
				testGS.moveQPosition();
			}
		} else {

		}
		return combinations;
	}
	private void test(GameState gs) {


	}
	private int mostValuablePlanetId(Planet[] planets) const {
		int bestGrowth = int.min;
		Planet best;
		foreach(planet; planets) {
			Planet testField = planet.dup(planet.owner);
			for(int i=0; i<5; i++) {
				testField.step(false);
			}
			int diff = testField.populationSum - planet.populationSum;
			if(diff > bestGrowth) {
				best = planet;
				bestGrowth = diff;
			}
		}
		return best.uniqueId;
	}
	/** Returns number of ships required to destroy population on a planet **/
	private int shipsRequired(Player player, Planet planet) const {
		int toDestroy = planet.populationSum;
		double eneEff = player.knowledgeTree.branch(BranchName.Energy).effectiveness;
		double sciEff = player.knowledgeTree.branch(BranchName.Science).effectiveness;
		double milEff = player.knowledgeTree.branch(BranchName.Military).effectiveness;
		double unitsReq = planet.populationSum / (MilitaryShip.lambda * milEff);
		return to!int(ceil(unitsReq / Ship.capacity(eneEff, sciEff)));
	}
}