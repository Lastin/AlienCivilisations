/**
This module implements artificial player.
It is extension to the Player class.

Upon calling makeMove(), the AI uses game state to make decisions.
Play class taken as an argument, is used to update AI action list widget in the play screen.

Constructor is only used to pass the name as "AI" to parent class constructor

Author: Maksym Makuch
 **/

module src.logic.ai;

import core.thread;
import src.containers.gameState;
import src.entities.branch;
import src.entities.knowledgeTree;
import src.entities.map;
import src.entities.planet;
import src.entities.player;
import src.entities.ship;
import src.screens.play;
import std.algorithm;
import std.algorithm;
import std.algorithm.iteration;
import std.concurrency;
import std.conv;
import std.format;
import std.math;
import std.parallelism;
import std.stdio;
import std.typecons;

//version = aiDebug;

class AI : Player {
	private bool aiDisabled = false;
	this(int uniqueId, KnowledgeTree knowledgeTree, Ship[] ships = null) {
		super(uniqueId, "AI", knowledgeTree, ships);
	}
	/** This function, when called, makes decisions in game **/
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
	/** Finds the best production decisions for each of the planets owned by the current player **/
	static void decideProduction(GameState gs) {
		Planet[] owned = gs.currentPlayer.planets(gs.map.planets);
		sort!"a.calculateWorkforce() > b.calculateWorkforce()"(owned);
		//Compose the list of planet's ids with orders completed within 1 step
		int[] availables;
		foreach(planet; owned) {
			if(planet.queueInSteps > 1)
				continue;
			availables ~= planet.uniqueId;
		}
		//Store values to avoid recalculating them multiple times in loop
		double milEff = gs.currentPlayer.knowledgeTree.branch(BranchName.Military).effectiveness;
		double sciEff = gs.currentPlayer.knowledgeTree.branch(BranchName.Science).effectiveness;
		int capacity = Ship.capacity(milEff, sciEff);
		//Check if inhabitation ships should be produced
		bool produceIS = produceIS(gs);
		//For each owned planet, decide on production
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
				version(aiDebug) writeln("AI adds IS order");
			}
		}
	}
	/** Adds military ship order to planet with given unique identifier **/
	static void addMilitaryOrder(GameState gs, int planetId, int capacity) {
		/** Takes capacity as an argument to not recalculate it multiple times in a loop that calls this function **/
		Planet p = gs.map.planetWithId(planetId);
		//Convert units to obtain maximum ship force
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
		//Add ships in production
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
	/** Finishes turn on the game state few times, then performs attack and inhabitation moves. Returns evaluation of state **/
	static long measure(GameState gs) {
		gs.shift();//enemy turn (dont make any moves)
		gs.shift();//back to AI
		gs.shift();//enemy turn (dont make any moves)
		gs.shift();//back to AI
		AI.attack(gs, null);
		AI.inhabit(gs, null);
		return evaluate(gs);
	}
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
	/** Converts civil units to military, to avoid overpopulation factor taking effect **/
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
	/** Create ranking of best planets to attack and performs the attacks **/
	static void attack(GameState gs, Play play) {
		MilitaryShip[] ms = gs.currentPlayer.militaryShips;
		if(ms.length == 0) {
			//If no military ships owned
			return;
		}
		double milEff = gs.currentPlayer.knowledgeTree.branch(BranchName.Military).effectiveness;
		Planet[] enemy = gs.notCurrentPlayer.planets(gs.map.planets);
		//Rank planets
		int[] rankedIds = planetAttackRank(gs);
		version (aiDebug) writeln(rankedIds);
		int i=0;
		//Attack until there are no planets left to attack, or player runs out of military ships
		while(ms.length > 0 && i<rankedIds.length) {
			Planet attacked = gs.map.planetWithId(rankedIds[i]);
			if(!attacked)
				return;
			foreach(ship; ms) {
				gs.currentPlayer.attackPlanet(ship, attacked, true);
				if(!attacked.owner) {
					//If planet population destroyed completly, then move to the next planet in the ranking
					i++;
					break;
				}
			}
			if(play) {
				play.addAIAction("AI attacked " ~ attacked.name, 0xff0000);
			}
			//Update military ship array
			ms = gs.currentPlayer.militaryShips;
		}
	}
	/** Returns ranking of planets to be attacked. Best first **/
	static int[] planetAttackRank(GameState gs) {
		Planet[] enemy = gs.notCurrentPlayer.planets(gs.map.planets);
		Tuple!(int, long)[] scores;
		scores.reserve(enemy.length + 1);
		foreach(planet; enemy) {
			//For each enemy planet, create duplicate and experiment on it
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
	/** Attacks planet with given id, and moves queue **/
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
	/** NegaMax algorithm, created decision tree of planets attacks. Returns best score, derived from given game state **/
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
	/** Finds and develops best knowledge tree branch **/
	static void develop(GameState gs) {
		if(stepsToDevelop(gs) > 1)
			return;
		Branch[] undev = gs.currentPlayer.knowledgeTree.undevelopedBranches;
		BranchName bestBranch;
		long bestScore = -long.max;
		//Test each branch which has not yet reached maximum level
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
	/** This version of negamax returns the best score for the game state,
	derived from current game state by making knowledge tree developments **/
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
	/** Evaluates current gamestate considering only one player, but all attributes.
	Used by the negaMaxK, for evaluation of knowledge tree development decisions **/
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
		version (aiDebug) writefln("Queue empty in %s", steps);
		return steps;
	}
}