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

version = playerDebug;

class AI : Player {
	this(int uniqueId, KnowledgeTree knowledgeTree, Ship[] ships = null) {
		super(uniqueId, "AI", knowledgeTree, ships);
	}
	void makeMove(GameState gs) {
		version(playerDebug) {
			writefln("MS: %s", militaryShips.length);
			writefln("IS: %s", inhabitationShips.length);
		}
		inhabit(gs);
		develop(gs);
		addISOrders(gs);
		convertUnits(gs);
		doAttack(gs);
	}
	/** Adds number of military ship orders needed to destroy planet's population **/
	static void addMSOrders(GameState gs, Planet planet) {
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
			}
		}
	}
	static void addISOrders(GameState gs) {
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
				if(!canFind(excluded, bp.uniqueId)) {
					bp.addShipOrder(ShipType.Inhabitation);
					if(bp.shipOrders.length >= limit) {
						excluded ~= bp.uniqueId;
					}
				}
			}
		}
		else if(needed < 0) {
			//cancel unneeded orders
			//TODO: add cancelation
			int canCancel = totalIS - complete;
			for(int i=0; i<canCancel; i++) {
				
			}
		}
	}
	static void inhabit(GameState gs) {
		Planet[] free = gs.map.freePlanets();
		InhabitationShip[] ships = gs.currentPlayer.inhabitationShips();
		sort!"a.capacity() > b.capacity()"(ships);
		sort!"a.capacity() > b.capacity()"(free);
		int i=0;
		foreach(ship; ships) {
			if(i<free.length) {
				gs.currentPlayer.inhabitPlanet(free[i]);
				i++;
			}
		}
	}
	/** Returns a planet which can produce the ship the fastest. Does not foresee changes to the entire world **/
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
	static void convertUnits(GameState gs) {
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
	static void doAttack(GameState gs) {
		int msc = to!int(gs.currentPlayer.militaryShips.length);
		if(msc == 0)
			return;
		Planet[] enemy = gs.notCurrentPlayer.planets(gs.map.planets);
		long[] scores;
		scores.reserve(20);
	}
	static long negaMax(GameState gs, int depth, long alpha, long beta) {
		//TERMINAL
		if(depth <= 0 || gs.currentPlayer.militaryShips.length == 0)
			return evaluate(gs);
		PlayerEnum dead = gs.deadPlayer;
		if(dead == PlayerEnum.Both) {
			//Both dead
			return 0;
		}
		else if(dead == gs.currentPlayerEnum) {
			//Current dead
			return long.min;
		}
		else if(dead != PlayerEnum.None){
			//Enemy dead
			return long.max;
		}
		//NON-TERMINAL
		long bestScore = long.min;
		Planet[] enemy = gs.notCurrentPlayer.planets(gs.map.planets);

		if(dead == PlayerEnum.None) {
			/*Behaviour[] combinations = allCombinations(gs);
			foreach(combination; combinations) {
				long score = -negaMax(combination.state, --depth, -beta, -alpha);
				bestScore = max(bestScore, score);
				alpha = max(alpha, score);
				if(alpha >= beta)
					break;
			}*/
		}
		return bestScore;
	}
	static long evaluate(GameState gs) {
		return 0;
	}
	static void develop(GameState gs) {

	}
}