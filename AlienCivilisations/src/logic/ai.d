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
import std.algorithm;
import src.screens.play;

//version = aiDebug;

class AI : Player {
	private bool aiDisabled = false;
	this(int uniqueId, KnowledgeTree knowledgeTree, Ship[] ships = null) {
		super(uniqueId, "AI", knowledgeTree, ships);
	}
	void makeMove(GameState gs, Play play) {
		if(aiDisabled) return;
		//sense
		//plan
		//run
		version(aiDebug) {
			writefln("MS: %s", militaryShips.length);
			writefln("IS: %s", inhabitationShips.length);
			writefln("Military force: %s", totalMilitaryForce);
			writefln("Military units: %s", totalMilitaryUnits(gs.map.planets));
		}
		attack(gs, play);
		inhabit(gs, play);
		convertOverpopulation(gs);
		decideProduction(gs);
		develop(gs);
	}

	static void decideProduction(GameState gs) {
		Planet[] owned = gs.currentPlayer.planets(gs.map.planets);
		sort!"a.calculateWorkforce() > b.calculateWorkforce()"(owned);
		int[] availables;
		foreach(planet; owned) {
			if(planet.queueInSteps > 1)
				continue;
			availables ~= planet.uniqueId;
		}
		double milEff = gs.currentPlayer.knowledgeTree.branch(BranchName.Military).effectiveness;
		double sciEff = gs.currentPlayer.knowledgeTree.branch(BranchName.Science).effectiveness;
		int capacity = Ship.capacity(milEff, sciEff);
		bool produceIS = produceIS(gs);
		foreach(a; availables) {
			GameState[] hypGS;
			hypGS ~= gs.dup();//neither
			hypGS ~= gs.dup();//military
			//Add military order
			addMilitaryOrder(hypGS[1], a, capacity);
			if(produceIS) {
				hypGS ~= gs.dup();//inhabitation
				hypGS[2].map.planetWithId(a).addShipOrder(ShipType.Inhabitation);
			}
			//Measure differences
			size_t best = -1;
			long bestScore = -long.max;
			foreach(i, state; hypGS) {
				long score = measure(state);
				if(score > bestScore) {
					best = i;
					bestScore = score;
				}
			}
			if(best == 1) {
				addMilitaryOrder(gs, a, capacity);
				version(aiDebug) writeln("AI adds MS order");
			}
			else if(best == 2) {
				gs.map.planetWithId(a).addShipOrder(ShipType.Inhabitation);
				debug writeln("AI adds IS order");
			}
		}
	}
	/** Adds military ship order to planet with id **/
	static void addMilitaryOrder(GameState gs, int planetId, int capacity) {
		//takes capacity as an argument to not recalculate it multiple times in a loop that calls this function
		Planet p = gs.map.planetWithId(planetId);
		//convert units to obtain maximum force
		if(p.militaryUnits < capacity) {
			int neededPercent = p.numberToPercent(capacity - p.militaryUnits);
			p.convertUnits(neededPercent);
		}
		p.addShipOrder(ShipType.Military, capacity);
	}
	/** Returns true if production of inhabitation ships makes sense **/
	static bool produceIS(GameState gs) {
		int optimal = to!int(gs.map.freePlanets.length) + 1;
		int complete = to!int(gs.currentPlayer.inhabitationShips.length);
		int totalIS = complete;
		//add ships in production
		foreach(planet; gs.currentPlayer.planets(gs.map.planets)) {
			int count = 0;
			foreach(order; planet.shipOrders) {
				if(cast(InhabitationShip)order)
					count++;
			}
			totalIS += count;
		}
		int needed = optimal - complete;
		return needed > 0;
	}
	/** Moves game queue twice and performs attack and inhabitation moves. Returns evaluation of state **/
	static long measure(GameState gs) {
		gs.shift();//enemy turn (dont make any moves)
		gs.shift();//back to AI
		gs.shift();//enemy turn (dont make any moves)
		gs.shift();//back to AI
		AI.attack(gs, null);
		AI.inhabit(gs, null);
		return evaluate(gs);
	}
	/** Adds military ships orders to destroy smallest planets **/
	/*static void addMSOrders(GameState gs) {
		Planet[] enemy = gs.notCurrentPlayer.planets(gs.map.planets);
		sort!"a.populationSum < b.populationSum"(enemy);
		int i=0;
		int limit = 2;
		int added = 0;
		do {
			added += addMSOrdersToDestroy(gs, enemy[i]);
			i++;
			//enemy = gs.notCurrentPlayer.planets(gs.map.planets);
		} while(i<enemy.length && i<limit && added == 0);
	}*/
	/** Adds number of military ship orders needed to destroy planet's population **/
	/*static int addMSOrdersToDestroy(GameState gs, Planet planet) {
		int totalAdded = 0;
		int utd = planet.populationSum;
		double totalForce = 0;
		double mEff = gs.currentPlayer.knowledgeTree.branch(BranchName.Military).effectiveness;
		foreach(ms; gs.currentPlayer.militaryShips) {
			totalForce += ms.force(mEff);
		}
		double needForce = utd - totalForce;
		if(needForce > 0) {
			int nmu = to!int(needForce / (MilitaryShip.LAMBDA * mEff));
			double sciEff = gs.currentPlayer.knowledgeTree.branch(BranchName.Science).effectiveness;
			double eneEff = gs.currentPlayer.knowledgeTree.branch(BranchName.Energy).effectiveness;
			int cap = MilitaryShip.capacity(eneEff, sciEff);
			int shipsNeeded = nmu / cap;
			for(int i=0; i<shipsNeeded; i++) {
				Planet fp = fastestProduction(gs);
				int units = min(cap, fp.militaryUnits);
				fp.addShipOrder(ShipType.Military, units);
				++totalAdded;
			}
		}
		return totalAdded;
	}*/
	/** Adds number of inhabitation ships not exceeding available planets **/
	/*static void addISOrders(GameState gs) {
		int optimal = to!int(gs.map.freePlanets.length) + 1;
		int complete = to!int(gs.currentPlayer.inhabitationShips.length);
		int totalIS = complete;
		Planet[] ownedP = gs.currentPlayer.planets(gs.map.planets);
		foreach(planet; ownedP) {
			int count = 0;
			foreach(order; planet.shipOrders) {
				if(cast(InhabitationShip)order)
					count++;
			}
			totalIS += count;
		}
		int needed = optimal - complete;
		if(needed > 0) {
			int limit = 2;
			int[] excluded;
			for(int i=0; i<needed; i++) {
				Planet bp = fastestProduction(gs);
				if(!bp)
					return;
				if(!canFind(excluded, bp.uniqueId)) {
					bp.addShipOrder(ShipType.Inhabitation);
					if(bp.shipOrders.length >= limit) {
						excluded ~= bp.uniqueId;
					}
				}
			}
		}
		else if(needed < 0) {
			//cancel exceeding orders, but probaly would not be ever executed.
			//TODO:  add cancelation
			int canCancel = totalIS - complete;
			for(int i=0; i<canCancel; i++) {
				
			}
		}
	}*/
	/** Uses inhabitation ships on best planets **/
	static void inhabit(GameState gs, Play play) {
		Planet[] free = gs.map.freePlanets();
		InhabitationShip[] ships = gs.currentPlayer.inhabitationShips();
		sort!"a.capacity() > b.capacity()"(ships);
		sort!"a.capacity() > b.capacity()"(free);
		int i=0;
		foreach(ship; ships) {
			if(i<free.length) {
				gs.currentPlayer.inhabitPlanet(free[i]);
				if(play) {
					play.addAIAction(format("AI inhabited " ~ free[i].name), 0x339933);
				}
				i++;
			}
		}
	}
	/** Returns a planet which can produce the ship the fastest **/
	static Planet fastestProduction(GameState gs) {
		Planet[] allPlanets = gs.map.planets;
		Planet[] owned = gs.currentPlayer.planets(allPlanets);
		sort!"a.calculateWorkforce() > b.calculateWorkforce()"(owned);
		Planet best;
		size_t leastOrders = int.max;
		foreach(planet; owned) {
			if(leastOrders > planet.shipOrders.length) {
				leastOrders = planet.shipOrders.length;
				best = planet;
			}
		}
		return best;
	}
	/** Converts civil units to military **/
	static void convertOverpopulation(GameState gs) {
		Planet[] allPlanets = gs.map.planets;
		Planet[] owned = gs.currentPlayer.planets(allPlanets);
		foreach(planet; owned) {
			if(planet.populationSum > planet.capacity) {
				int overflow = planet.populationSum - planet.capacity;
				int reduction = planet.population[2..4].sum;
				reduction = min(reduction, overflow);
				int perc = planet.numberToPercent(reduction);
				perc = min(90, perc);
				planet.convertUnits(perc);
			}
		}
	}
	/** Finds best planet to be attacked and attacks **/
	static void attack(GameState gs, Play play) {
		MilitaryShip[] ms = gs.currentPlayer.militaryShips;
		if(ms.length == 0) {
			return;
		}
		double milEff = gs.currentPlayer.knowledgeTree.branch(BranchName.Military).effectiveness;
		Planet[] enemy = gs.notCurrentPlayer.planets(gs.map.planets);
		//Rank planets
		int[] rankedIds = planetAttackRank(gs);
		version (aiDebug) writeln(rankedIds);
		int i=0;
		while(ms.length > 0 && i<rankedIds.length) {
			Planet attacked = gs.map.planetWithId(rankedIds[i]);
			if(!attacked)
				return;
			foreach(ship; ms) {
				gs.currentPlayer.attackPlanet(ship, attacked, true);
				if(!attacked.owner) {
					i++;
					break;
				}
			}
			if(play) {
				play.addAIAction("AI attacked " ~ attacked.name, 0xff0000);
			}
			//update array
			ms = gs.currentPlayer.militaryShips;
		}
	}
	/** Returns ranking of planets to be attacked. Best first **/
	static int[] planetAttackRank(GameState gs) {
		Planet[] enemy = gs.notCurrentPlayer.planets(gs.map.planets);
		Tuple!(int, long)[] scores;
		scores.reserve(enemy.length + 1);
		//Planet attacked
		foreach(planet; enemy) {
			GameState duplicate = gs.dup();
			attackAndShift(duplicate, planet.uniqueId);
			long score = -negaMaxA(duplicate, 2, -long.max, long.max);
			synchronized {
				scores ~= tuple(planet.uniqueId, score);
			}
			duplicate.destroy();
		}
		sort!"a[1] > b[1]"(scores);
		//Convert tuple to single array
		int[] ids;
		ids.reserve(scores.length);
		foreach(score; scores) {
			ids ~= score[0];
		}
		return ids;
	}
	// Attacks planet with given id, and moves queue
	static void attackAndShift(GameState gs, int planetId) {
		if(planetId >= 0){
			Planet attacked = gs.map.planetWithId(planetId);
			double milEff = gs.currentPlayer.knowledgeTree.branch(BranchName.Military).effectiveness;
			MilitaryShip[] ms = gs.currentPlayer.militaryShips;
			foreach(ship; ms) {
				ship.attackPlanet(attacked, milEff, true);
			}
		}
		gs.currentPlayer.completeTurn(gs.map.planets);
		gs.moveQPosition();
	}
	static long negaMaxA(GameState gs, int depth, long alpha, long beta) {
		//TERMINAL
		if(depth <= 0) // || gs.currentPlayer.militaryShips.length == 0
			return evaluate(gs);
		PlayerEnum dead = gs.deadPlayer;
		if(dead == PlayerEnum.Both) {
			//Both dead
			return 0;
		}
		else if(dead == gs.currentPlayerEnum) {
			//Current dead
			//using -max instead of min because of overflow
			return -long.max;
		}
		else if(dead != PlayerEnum.None){
			//Enemy dead
			return long.max;
		}
		//NON-TERMINAL
		long bestScore = -long.max;
		Planet[] enemy = gs.notCurrentPlayer.planets(gs.map.planets);
		foreach(planet; enemy) {
			GameState duplicate = gs.dup();
			attackAndShift(duplicate, planet.uniqueId);
			long score = -negaMaxA(duplicate, depth -1, -beta, -alpha);
			duplicate.destroy();
			synchronized {
				bestScore = max(score, bestScore);
				alpha = max(alpha, score);
				if(alpha >= beta)
					break;
			}
		}
		return bestScore;
	}
	/** Returns score for game state. The larger, the better for current player**/
	static long evaluate(GameState gs) {
		Planet[] allP = gs.map.planets;
		long mePoints = evaluatePlayer(gs, gs.currentPlayer);
		long enemyPoints = evaluatePlayer(gs, gs.notCurrentPlayer);
		return mePoints - enemyPoints;
	}
	/** Returns score for player **/
	static long evaluatePlayer(GameState gs, Player player) {
		/* Evaluated elements:
		 * population > weighted
		 * inhabitation ships > capacity
		 * military ships > force
		 * planets > capacity, number
		 */
		long total = 0;
		total += weightPop(player.population(gs.map.planets));
		/*double milEff = gs.currentPlayer.knowledgeTree.branch(BranchName.Military).effectiveness;
		foreach(ship; gs.currentPlayer.militaryShips) {
			total += to!long(ship.force(milEff));
		}
		foreach(ship; gs.currentPlayer.inhabitationShips) {
			total += to!long(ship.onboard);
		}*/
		total += to!long(gs.currentPlayer.knowledgeTree.totalEff);
		return total;
	}
	/** Returns points for population using weighted average **/
	static long weightPop(uint[8] p) {
		int g1 = 5;
		int g2 = 4;
		int g3 = 1;
		int result = (p[0..2].sum * g1 + p[2..7].sum * g2 + p[7..$].sum * g3) / g1+g2+g3;
		return result;
	}
	/** Finds and develops best branch **/
	static void develop(GameState gs) {
		if(stepsToDevelop(gs) > 1)
			return;
		Branch[] undev = gs.currentPlayer.knowledgeTree.undevelopedBranches;
		BranchName bestBranch;
		long bestScore = -long.max;
		foreach(branch; undev) {
			GameState dup = gs.dup;
			dup.currentPlayer.knowledgeTree.addOrder(branch.name);
			long score = -negaMaxK(dup, 3, -long.max, long.max);
			if(bestScore <= score) {
				bestScore = score;
				bestBranch = branch.name;
			}
		}
		writefln("AI develops %s", bestBranch);
		gs.currentPlayer.knowledgeTree.addOrder(bestBranch);
	}
	/** Returns score for best knowledge to develop, from given state **/
	static long negaMaxK(GameState gs, int depth, long alpha, long beta) {
		if(depth == 0)
			return evaluateK(gs);
		long bestScore = -long.max;
		foreach(branch; gs.currentPlayer.knowledgeTree.undevelopedBranches) {
			GameState dup = gs.dup;
			long score = negaMaxK(dup, depth -1, -beta, -alpha);
			bestScore = max(score, bestScore);
			alpha = max(alpha, score);
			if(alpha >= beta)
				break;
		}
		return bestScore;
	}
	/** Evaluates current gamestate considering only one player, but all attributes **/
	static long evaluateK(GameState gs) {
		Player me = gs.currentPlayer;
		double milEff = me.knowledgeTree.branch(BranchName.Military).effectiveness;
		long score = evaluatePlayer(gs, me);
		foreach(ship; me.inhabitationShips) {
			score += to!long(ship.onboard);
		}
		foreach(ship; me.militaryShips) {
			score += to!long(ship.force(milEff));
		}
		return score;
	}
	/** Returns number of steps in which queue would be emptied. Does not modify taken argument, tests on duplicate **/
	static int stepsToDevelop(const GameState gs) {
		GameState duplicate = gs.dup;
		KnowledgeTree kt = duplicate.currentPlayer.knowledgeTree;
		int steps = 0;
		while(kt.orders.length > 0) {
			duplicate.currentPlayer.completeTurn(duplicate.map.planets);
			steps++;
		}
		writefln("Queue empty in %s", steps);
		return steps;
	}
}