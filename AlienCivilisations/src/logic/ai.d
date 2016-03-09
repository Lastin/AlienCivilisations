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

struct Behaviour {
	bool attack = false;
	bool inhabit = false;
	bool orderMS = false;
	bool orderIS = false;
	GameState state;
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
		long[] scores;
		Branch[] ub = knowledgeTree.undevelopedBranches();
		if(ub.length > 0) {
			GameState[] combinations;
			foreach(branch; knowledgeTree.undevelopedBranches()){
				GameState gsWithOrder = realState.dup;
				gsWithOrder.currentPlayer.knowledgeTree.clearOrders();
				gsWithOrder.currentPlayer.knowledgeTree.addOrder(branch.name);
				combinations ~= behaviourCombinations(gsWithOrder);
				foreach(combination; combinations) {
					//scores ~= negaMax(combination, 1, -real.infinity, real.infinity, false);
				}
				long largestScore = long.min;
				long index = -1;
				foreach(int i, score; scores) {
					if(score >= largestScore) {
						largestScore = score;
						index = i;
					}
				}
			}
		} else {
			GameState[] combinations;
			combinations.reserve(20);
			combinations ~= behaviourCombinations(realState);
			foreach(combination; combinations) {
				//negaMax(combination, 1, -real.infinity, real.infinity, false);
			}
		}
	}
	/** Negamax algorithm **/
	/* Similar to Minimax but inverting alpha and beta and recursive result. */
	long negaMax(GameState gs, int depth, real alpha, real beta) const {
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
		if(depth > 0 && dead == PlayerEnum.None) {
			GameState[] combinations = possibleCombinations(gs);
			foreach(combination; combinations) {
				long score = -negaMax(combination, --depth, -beta, -alpha, !maximising);
				bestScore = max(bestScore, score);
				alpha = max(alpha, score);
				if(alpha >= beta)
					break;
			}
		}
		return bestScore;
	}
	/** Returns least affected by production planet belonging to current player **/
	private Planet leastAffectedPlanet(GameState testGS, ShipType type, int[] excluded) const {
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
	private double consEff(Planet planet, ShipType type) const {
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
	private Planet[] sortByEff(Planet[] planets, ShipType type) const {
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
		return calcPlayerVal(gs.currentPlayer, gs) - calcPlayerVal(gs.notCurrentPlayer, gs);
	}
	private long calcPlayerVal(Player player, GameState gs) const {
		long playerPoints = 0;
		int[8] playerPop = [0,0,0,0,0,0,0,0];
		int popSum = playerPop[].sum;
		Planet[] playerPlanets = gs.currentPlayer.planets(gs.map.planets);
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
		return playerPoints;
	}
	private long weightedPop(int[8] p) const {
		int g1 = 5;
		int g2 = 4;
		int g3 = 1;
		int result = (p[0..2].sum * 5 + p[2..7].sum * 4 + p[7..$].sum * 1) / g1+g2+g3;
		return result;
	}
	/** Returns possible game states which are effect of certain behaviours **/
	private GameState[] possibleCombinations(GameState original) const {
		GameState[] combinations;
		combinations.reserve(18);
		Branch[] ub = original.currentPlayer().knowledgeTree().undevelopedBranches();
		if(ub.length > 0) {
			foreach(branch; ub) {
				GameState gsWithOrder = original.dup();
				//add kt order
				gsWithOrder.currentPlayer.knowledgeTree.clearOrders();
				gsWithOrder.currentPlayer.knowledgeTree.addOrder(branch.name);
				combinations ~= gsWithOrder;
				combinations ~= behaviourCombinations(gsWithOrder);
			}
		} else {
			combinations ~= behaviourCombinations(original);
		}
		foreach(combination; combinations) {
			//end turn once decisions are made
			combination.currentPlayer.completeTurn(combination.map.planets);
			combination.moveQPosition();
		}
		return combinations;
	}
	/** Returns the combinations of possible behaviours such as attack and ship orders **/
	private GameState[] behaviourCombinations(GameState baseState) const {
		GameState[] combinations;
		combinations.reserve(16);
		/*
		 * naming code position (0 = false, 1 = true):
		 * n - just name beginning
		 * 1 - attack
		 * 2 - inhabit
		 * 3 - order military ship
		 * 4 - order inhabitation ship
		*/
		//Attack?
		//Bit: n1---
		GameState n0000 = baseState.dup();
		GameState n1000 = baseState.dup();
		performAttack(n1000);
		//Inhabit?
		//Bit: n-1--
		GameState n0100 = n0000.dup();
		GameState n1100 = n1000.dup();
		useInhabitShips(n0100);
		useInhabitShips(n1100);
		//Produce military ships?
		//Bit: n--1-
		GameState n0010 = n0000.dup();
		GameState n1010 = n1000.dup();
		GameState n0110 = n0100.dup();
		GameState n1110 = n1100.dup();
		addShipOrders(n0010, ShipType.Military);
		addShipOrders(n1010, ShipType.Military);
		addShipOrders(n0110, ShipType.Military);
		addShipOrders(n1110, ShipType.Military);
		//Order inhabit ships?
		//Bit: n---1
		GameState n0001 = n0000.dup();
		GameState n1001 = n1000.dup();
		GameState n0101 = n0100.dup();
		GameState n1101 = n1000.dup();
		GameState n0011 = n0010.dup();
		GameState n1011 = n1010.dup();
		GameState n0111 = n0110.dup();
		GameState n1111 = n1110.dup();
		addShipOrders(n0001, ShipType.Inhabitation);
		addShipOrders(n1001, ShipType.Inhabitation);
		addShipOrders(n0101, ShipType.Inhabitation);
		addShipOrders(n1101, ShipType.Inhabitation);
		addShipOrders(n0011, ShipType.Inhabitation);
		addShipOrders(n1011, ShipType.Inhabitation);
		addShipOrders(n0111, ShipType.Inhabitation);
		addShipOrders(n1111, ShipType.Inhabitation);
		//Add all hypothetical states to list
		//
		combinations ~= n0000;
		combinations ~= n1000;
		//
		combinations ~= n0100;
		combinations ~= n1100;
		//
		combinations ~= n0010;
		combinations ~= n1010;
		combinations ~= n0110;
		combinations ~= n1110;
		//
		combinations ~= n0001;
		combinations ~= n1001;
		combinations ~= n0101;
		combinations ~= n1101;
		combinations ~= n0011;
		combinations ~= n1011;
		combinations ~= n0111;
		combinations ~= n1111;
		return combinations;
	}
	void makeActions(Behaviour behaviour, GameState gs) {
		if(behaviour.attack) {
			performAttack(gs);
		}
		if(behaviour.inhabit) {
			useInhabitShips(gs);
		}
		if(behaviour.orderMS) {
			addShipOrders(gs, ShipType.Military);
		}
		if(behaviour.orderIS) {
			addShipOrders(gs, ShipType.Inhabitation);
		}
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
	private void addShipOrders(GameState testGS, ShipType type) const {
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