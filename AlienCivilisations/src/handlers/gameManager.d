module src.handlers.gameManager;

import std.conv;
import std.random;
import std.json;
import src.entities.map;
import src.entities.player;
import src.logic.knowledgeTree;
import src.logic.ai;
import src.states.state;
import src.states.menu;
import src.states.play;

class GameManager {
	private Map map;
	private Player[2] players;
	private int queuePosition;
	private State state;

	public Map getMap(){
		return map;
	}

	public State getState(){
		return state;
	}
	public void setState(State state){
		this.state = state;
	}

	public Player getCurrentPlayer(){
		return players[queuePosition];
	}

	public void startNewGame(string pname){
		map = new Map(2000, 16);
		uint start_pop = to!int(map.getPlanets[0].getCapacity() / 4);
		players[0] = new Player(this, pname, new KnowledgeTree());
		players[0].addPlanet(map.getPlanets[0]);
		map.getPlanets[0].setOwner(players[0], start_pop);
		players[1] = new AI(this, new KnowledgeTree);
		players[1].addPlanet(map.getPlanets[1]);
		map.getPlanets[0].setOwner(players[1], start_pop);
		queuePosition = to!int(dice(0.5, 0.5));
	}
}