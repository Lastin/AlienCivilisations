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
import std.typecons;
import std.algorithm.iteration;
import std.format;

struct Behaviour {
	bool attack = false;
	bool inhabit = false;
	bool orderMil = false;
	bool orderInh = false;
	BranchName developed;
	GameState state;
	this(bool att, bool inh, bool ordMil, bool ordInh, Behaviour bhvr) {
		state = bhvr.state.dup();
		developed = bhvr.developed;
		attack = att;
		inhabit = inh;
		orderMil = ordMil;
		orderInh = ordInh;
		if(attack && !bhvr.attack)
			AI.performAttack(state);
		if(inhabit && !bhvr.inhabit)
			AI.useInhabitShips(state);
		if(orderMil && !bhvr.orderMil)
			AI.addShipOrders(state, ShipType.Military);
		if(orderInh && !bhvr.orderInh)
			AI.addShipOrders(state, ShipType.Inhabitation);
	}
	this(bool att, bool inh, bool ordMil, bool ordInh, BranchName dev, GameState gs) {
		state = gs.dup();
		developed = dev;
		attack = att;
		inhabit = inh;
		orderMil = ordMil;
		orderInh = ordInh;
		if(dev) {
			gs.currentPlayer.knowledgeTree.clearOrders();
			gs.currentPlayer.knowledgeTree.addOrder(dev);
		}
		if(attack)
			AI.performAttack(state);
		if(inhabit)
			AI.useInhabitShips(state);
		if(orderMil)
			AI.addShipOrders(state, ShipType.Military);
		if(orderInh)
			AI.addShipOrders(state, ShipType.Inhabitation);
	}
	string toString() {
		return format("%s %s %s %s %s", attack, inhabit, orderMil, orderInh, developed);
	}
}
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
		/*Planet[] pp = realState.map.playerPlanets(_uniqueId);
		double enemyAggression = 0;
		foreach(planet; pp) {
			enemyAggression += planet.attackedCount;
		}*/
		Behaviour[] combinations = allCombinations(realState);
		Tuple!(Behaviour, long) best;// = tuple(null, long.min);
		foreach(combination; parallel(combinations)) {
			long score = negaMax(combination.state, 0, long.min, long.max);
			if(best[1] < score)
				best = tuple(combination, score);
		}
		writefln("Best score: %s", best[1]);
		writefln("Move: %s", best[0].toString());
		executeMoves(best[0], realState);
	}

	/** Performs the moves on the given state, as in the given behaviour **/
	static void executeMoves(Behaviour behaviour, GameState realState) {
		if(behaviour.developed) {
			realState.currentPlayer.knowledgeTree.clearOrders();
			realState.currentPlayer.knowledgeTree.addOrder(behaviour.developed);
		}
		if(behaviour.attack)
			performAttack(realState);
		if(behaviour.inhabit)
			useInhabitShips(realState);
		if(behaviour.orderMil)
			addShipOrders(realState, ShipType.Military);
		if(behaviour.orderInh)
			addShipOrders(realState, ShipType.Inhabitation);
	}
	/** Negamax algorithm **/
	static long negaMax(GameState gs, int depth, long alpha, long beta) {
		//Check if terminal node
		if(depth <= 0)
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
		if(dead == PlayerEnum.None) {
			Behaviour[] combinations = allCombinations(gs);
			foreach(combination; combinations) {
				long score = -negaMax(combination.state, --depth, -beta, -alpha);
				bestScore = max(bestScore, score);
				alpha = max(alpha, score);
				if(alpha >= beta)
					break;
			}
		}
		return bestScore;
	}

	/** Returns possible moves **/
	static Behaviour[] allCombinations(GameState original) {
		Behaviour[] combinations;
		combinations.reserve(90);
		Behaviour bhvr0 = Behaviour(false, false, false, false, null, original);
		combinations ~= behaviourCombinations(bhvr0);
		foreach(possDev; original.currentPlayer().knowledgeTree().undevelopedBranches()) {
			Behaviour bhvr1 = Behaviour(false, false, false, false, possDev.name, original);
			combinations ~= behaviourCombinations(bhvr1);
		}
		foreach(combination; combinations) {
			//End turn for each combination
			combination.state.currentPlayer.completeTurn(combination.state.map.planets);
			combination.state.moveQPosition();
		}
		return combinations;
	}
	/** Returns the combinations of possible actions **/
	static Behaviour[] behaviourCombinations(Behaviour bhvr) {
		Behaviour[] behaviours;
		behaviours.reserve(16);
		//Create all combinations of moves
		behaviours ~= Behaviour(false, false, false, false, bhvr);
		behaviours ~= Behaviour(true,  false, false, false, bhvr);
		behaviours ~= Behaviour(false, true,  false, false, behaviours[0]);
		behaviours ~= Behaviour(true,  true,  false, false, behaviours[1]);
		behaviours ~= Behaviour(false, false, true,  false, bhvr);
		behaviours ~= Behaviour(true,  false, true,  false, behaviours[1]);
		behaviours ~= Behaviour(false, true,  true,  false, behaviours[2]);
		behaviours ~= Behaviour(true,  true,  true,  false, behaviours[3]);
		//
		behaviours ~= Behaviour(false, false, false, true, bhvr);
		behaviours ~= Behaviour(true,  false, false, true, behaviours[1]);
		behaviours ~= Behaviour(false, true,  false, true, behaviours[2]);
		behaviours ~= Behaviour(true,  true,  false, true, behaviours[3]);
		behaviours ~= Behaviour(false, false, true,  true, behaviours[4]);
		behaviours ~= Behaviour(true,  false, true,  true, behaviours[5]);
		behaviours ~= Behaviour(false, true,  true,  true, behaviours[6]);
		behaviours ~= Behaviour(true,  true,  true,  true, behaviours[7]);
		return behaviours;
	}

	/** Returns least affected by production planet belonging to current player **/
	static Planet leastAffectedPlanet(GameState testGS, ShipType type, int[] excluded) {
		Planet[] pp = testGS.currentPlayer.planets(testGS.map.planets);
		Planet best;
		double smallestEffect = double.infinity;
		foreach(planet; pp){
			if(canFind(excluded, planet.uniqueId))
				continue;
			double ratio = consEff(planet, type);
			if(ratio < smallestEffect) {
				smallestEffect = ratio;
				best = planet;
			}
		}
		return best;
	}
	/**  Returns the double representing the effect of construction on planet **/
	static double consEff(Planet planet, ShipType type) {
		Planet unaffected = planet.dup(planet.owner);
		Planet affected = planet.dup(planet.owner);
		affected.addShipOrder(type);
		for(int i=0; i<6; i++) {
			unaffected.step(false);
			affected.step(false);
		}
		double before = to!double(planet.populationSum());
		double affPop = to!double(affected.populationSum());
		return (before / affPop) - (before / unaffected.populationSum());
	}
	/** Sort by effect of construction, least affected first **/
	static Planet[] sortByEff(Planet[] planets, ShipType type) {
		Tuple!(Planet, double)[] scores;
		foreach(planet; planets) {
			scores ~= tuple(planet, consEff(planet, type));
		}
		sort!"a[1] < b[1]"(scores);
		Planet[] result;
		foreach(score; scores) {
			result ~= score[0];
		}
		return result;
	}
	/** Adds kt development order for current player **/
	static void addKTOrder(GameState gs, BranchName bn) {
		gs.currentPlayer.knowledgeTree.addOrder(bn);
	}
	/** Return uniqueId of planet most affected by attacks **/
	static int mostAffectedPlanet(GameState gs) {
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
			//assert(ap.toHash == planetBH && attacker.toHash == playerBH);
		}
		debug writefln("Most affected planet id: %s with value: %s", id, greatestEffect);
		return id;
	}
	/** Returns the value of the gamestate for the current player **/
	static long evaluateState(GameState gs) {
		return calcPlayerVal(gs.currentPlayer, gs) - calcPlayerVal(gs.notCurrentPlayer, gs);
	}
	/** Returns the value of the player **/
	static long calcPlayerVal(Player player, GameState gs) {
		long playerPoints = 0;
		int[8] playerPop = [0,0,0,0,0,0,0,0];
		int popSum = playerPop[].sum;
		Planet[] playerPlanets = player.planets(gs.map.planets);
		foreach(planet; playerPlanets) {
			foreach(i, each; planet.population) {
				playerPop[i] += each;
			}
		}
		playerPoints += weightedPop(playerPop);
		ulong fpc = gs.map.freePlanets.length;
		playerPoints += min(fpc, player.inhabitationShips.length) * popSum / 20;
		foreach(ship; player.militaryShips) {
			playerPoints += to!long(ship.force(player.knowledgeTree.branch(BranchName.Military).effectiveness) *  popSum / 15);
		}
		playerPoints += to!long(player.knowledgeTree.totalEff * popSum / 10);
		writefln("Player points: %s", playerPoints);
		return playerPoints;
	}
	/** Returns the value of the given population **/
	static long weightedPop(int[8] p) {
		int g1 = 5;
		int g2 = 4;
		int g3 = 1;
		int result = (p[0..2].sum * g1 + p[2..7].sum * g2 + p[7..$].sum * g3) / g1+g2+g3;
		return result;
	}
	/** Uses inhabitation ships of the current player **/
	static void useInhabitShips(GameState testGS) {
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
	static void addShipOrders(GameState testGS, ShipType type) {
		//TODO: remove breaking when ordering the production of the military ship
		int totalAdded = 0;
		Planet[] freePlanets = testGS.map.freePlanets;
		Planet[] playerPlanets = testGS.currentPlayer.planets(testGS.map.planets);
		int ordersLeft = to!int(freePlanets.length - testGS.currentPlayer.inhabitationShips.length);
		//sort!"a.calculateWorkforce() > b.calculateWorkforce()"(playersPlanets);
		playerPlanets = sortByEff(playerPlanets, type);
		int[] excluded;
		foreach(planet; playerPlanets) {
			if(ordersLeft <= 0)
				break;
			Ship order = planet.addShipOrder(type);
			planet.convertUnits(planet.numberToPercent(order.capacity));
			--ordersLeft;
			totalAdded++;
			if(planet.stepsToCompleteOrder(order) > 1) {
				excluded ~= planet.uniqueId;
			}
		}
		debug writefln("Total added ship orders: %s", totalAdded);
	}
	/** Performs attack with all military ships on enemy planets **/
	static void performAttack(GameState testGS) {
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
	static int mostValuablePlanetId(Planet[] planets) {
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
	static int shipsRequired(Player player, Planet planet) {
		int toDestroy = planet.populationSum;
		double eneEff = player.knowledgeTree.branch(BranchName.Energy).effectiveness;
		double sciEff = player.knowledgeTree.branch(BranchName.Science).effectiveness;
		double milEff = player.knowledgeTree.branch(BranchName.Military).effectiveness;
		double unitsReq = planet.populationSum / (MilitaryShip.lambda * milEff);
		return to!int(ceil(unitsReq / Ship.capacity(eneEff, sciEff)));
	}

}