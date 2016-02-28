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
			//writefln("CPUs: %s", totalCPUs);
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
	/** Negamax algorithm **/
	/* Similar to Minimax but inverting alpha and beta and recursive result. */
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
	/** Returns least affected by production planet belonging to player **/
	private Planet leastAffectedPlanet(GameState testGS, ShipType type) const {
		Planet[] pp = testGS.currentPlayer.planets(testGS.map.planets);
		Planet best;
		double smallestEffect = double.infinity;
		foreach(planet; pp){
			Planet unaffected = planet.dup(planet.owner);
			Planet affected = planet.dup(planet.owner);
			affected.addShipOrder(type);
			for(int i=0; i<6; i++) {
				unaffected.step(false);
				affected.step(false);
			}
			double before = to!double(planet.populationSum());
			double affPop = to!double(affected.populationSum());
			double ratio =  (before / affPop) - (before / unaffected.populationSum());
			if(ratio < smallestEffect) {
				smallestEffect = ratio;
				best = planet;
			}
		}
		return best;
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
				divisor = 0.2;
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
	/** Returns long representing the value of the gamestate for current player **/
	private long evaluateState(GameState gs) const {
		return 0;
	}
	/** Returns possible game states which are effect of certain behaviours **/
	private GameState[] possibleCombinations(GameState original) const {
		GameState[] combinations;
		Branch[] ub = original.currentPlayer().knowledgeTree().undevelopedBranches();
		if(ub.length > 0) {
			foreach(branch; ub) {
				GameState gsWithOrder = original.dup();
				//add kt order
				gsWithOrder.currentPlayer.knowledgeTree.clearOrders();
				gsWithOrder.currentPlayer.knowledgeTree.addOrder(branch.name);
				//attck or don't
				GameState noAttack = gsWithOrder.dup();
				GameState doAttack = gsWithOrder.dup();
				performAttack(doAttack);
				//inhabit
				GameState noAttackInhabit = noAttack.dup();
				GameState doAttackInhabit = doAttack.dup();
				useInhabitShips(noAttackInhabit);
				useInhabitShips(doAttackInhabit);
				//produce military ships
				GameState noAttackOrdMil = noAttack.dup();
				GameState doAttackOrdMil = doAttack.dup();
				GameState noAttackInhabitOrdMil = noAttackInhabit.dup();
				GameState doAttackInhabitOrdMil = doAttackInhabit.dup();
				orderMilitaryShips(noAttackOrdMil);
				orderMilitaryShips(doAttackOrdMil);
				orderMilitaryShips(noAttackInhabitOrdMil);
				orderMilitaryShips(doAttackInhabitOrdMil);
				//order inhabit ships
				GameState noAttackOrdInh = noAttack.dup();
				GameState doAttackProdInh = doAttack.dup();
				GameState noAttackInhabitProdInh = noAttackInhabit.dup();
				GameState doAttackInhabitProdInh = doAttackInhabit.dup();

				//add all above to list
				combinations ~= noAttack;
				combinations ~= doAttack;
				combinations ~= noAttackInhabit;
				combinations ~= doAttackInhabit;
			}
		} else {

		}
		foreach(combination; combinations) {
			//end turn once decisions are made
			combination.currentPlayer.completeTurn(combination.map.planets);
			combination.moveQPosition();
		}
		return combinations;
	}
	/** Uses inhabitation ships of the current player **/
	private void useInhabitShips(GameState testGS) const {
		Planet[] freePlanets = testGS.map.freePlanets;
		sort!"a.capacity > b.capacity"(freePlanets);
		size_t ihc = testGS.currentPlayer.inhabitationShips.length;
		foreach(planet; freePlanets) {
			if(ihc == 0)
				break;
			testGS.currentPlayer.inhabitPlanet(planet);
			ihc--;
		}
	}
	/** Adds best number of inhabitation ships orders on least affected planets **/
	private void orderInhabitShips(GameState testGS) const {
		Planet[] freePlanets = testGS.map.freePlanets;
		Planet[] playersPlanets = testGS.currentPlayer.planets(testGS.map.planets);
		int maxOrders = to!int(playersPlanets.length+1);
		//sort!"a.calculateWorkforce() > b.calculateWorkforce()"(playersPlanets);
		for(int i=0; i<maxOrders; i++) {
			leastAffectedPlanet(testGS, ShipType.Inhabitation);
		}
	}
	/** Adds best number of military ships orders on least affected planets **/
	private void orderMilitaryShips(GameState testGS) const {

	}
	/** Performs attack with all military ships on enemy planets **/
	private void performAttack(GameState testGS) const {
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
	}
	/** Returns uniqueId of the planet with potentially best value for player **/
	private int mostValuablePlanetId(Planet[] planets) const {
		double bestGain = double.min_normal;
		Planet bestPlanet;
		foreach(planet; planets) {
			Planet testField = planet.dup(planet.owner);
			for(int i=0; i<5; i++) {
				testField.step(false);
			}
			int popDiff = testField.populationSum - planet.populationSum;
			double prodDiff = testField.calculateWorkforce() - planet.calculateWorkforce();
			double gain = 0.4 * prodDiff + 0.6 * popDiff;
			if(gain > bestGain) {
				bestGain = gain;
				bestPlanet = planet;
			}
		}
		return bestPlanet.uniqueId;
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