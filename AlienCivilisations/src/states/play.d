module src.states.play;

import dlangui;
import std.stdio;
import std.conv;
import std.random;
import std.json;
import src.entities.map;
import src.entities.player;
import src.logic.knowledgeTree;
import src.logic.ai;
import src.states.menu;
import src.states.play;
import src.states.gameState;
import src.gameFrame;

class Play : DockHost, GameState{
	private Map map;
	private Player[2] players;
	private int queuePosition;
	static GameFrame gameFrame;

	this(GameFrame gameFrame){
		this.gameFrame = gameFrame;
		layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);

		auto btn = new Button(null, "Test Button");
		btn.click = delegate(Widget src){
			writeln("test");
			return true;
		};
		VerticalLayout vl = new VerticalLayout();
		//vl.addChild(btn);
		//addChild(vl);
		startNewGame("HUMAN");
		addChild(map);
		addChild(new Button(null, "test"));
	}
	this(GameFrame gameFrame, Map map, Player[] players, int qpos){
		this(gameFrame);
		//TODO: constructor reading from json
		this.map = map;
		this.players = players;
		this.queuePosition = qpos;
	}

	public Map getMap(){
		return map;
	}
	
	public Player getCurrentPlayer(){
		return players[queuePosition];
	}
	
	public void startNewGame(string pname){
		map = new Map(2000, 16);
		uint start_pop = to!int(map.getPlanets[0].getCapacity() / 4);
		players[0] = new Player(pname, new KnowledgeTree());
		players[0].addPlanet(map.getPlanets[0]);
		map.getPlanets[0].setOwner(players[0], start_pop);
		players[1] = new AI(new KnowledgeTree);
		players[1].addPlanet(map.getPlanets[1]);
		map.getPlanets[0].setOwner(players[1], start_pop);
		queuePosition = to!int(dice(0.5, 0.5));
	}

	public bool handleKeyInput(Widget source, KeyEvent event){
		writeln("action");
		if(event.action == KeyAction.KeyDown && event.keyCode == KeyCode.ESCAPE){
			gameFrame.setState(new Menu(gameFrame, this));
		}
		return true;
	}
}