﻿module src.states.play;

import dlangui;
import src.entities.map;
import src.entities.planet;
import src.entities.player;
import src.gameFrame;
import src.logic.ai;
import src.logic.knowledgeTree;
import src.states.gameState;
import src.states.menu;
import src.states.play;
import std.conv;
import std.random;
import std.stdio;
import std.algorithm;

class Play : HorizontalLayout, GameState{
	private Map map;
	private Player[2] players;
	private int queuePosition;
	static GameFrame gameFrame;


	this(GameFrame gameFrame){
		this.gameFrame = gameFrame;
		startNewGame("HUMAN");
		Planet[] planets = map.getPlanets();
		VerticalLayout col1 = new VerticalLayout();
		col1.addChild(new TextWidget("currentPlayer", players[queuePosition].getName()));
		TableLayout table = new TableLayout();
		col1.padding = 10;
		table.padding = 10;
		Button inhabit = new Button("inhabit", "Inhabit"d);

		for(int i=0; i<planets.length; i++){
			Button btn = new Button(to!string(i), "Planet " ~ to!dstring(i));
			btn.click = delegate (Widget src){
				Planet selectedPlanet = planets[to!int(src.id)];
				table.childById("planet name").text = to!dstring(selectedPlanet.getName);
				table.childById("breathable").text = selectedPlanet.isBreathable ? "true" : "false";
				dstring capacity = to!dstring(selectedPlanet.getCapacity);
				table.childById("capacity").text = capacity;
				table.childById("population").text = to!dstring(selectedPlanet.getPopulationSum);
				writeln(to!dstring(selectedPlanet.getPopulationSum));
				dstring radius = to!dstring(selectedPlanet.getRadius);
				table.childById("radius").text = radius;
				Player owner = selectedPlanet.getOwner;
				table.childById("owner").text = owner ? to!dstring(owner.getName) : "No owner";
				if(!owner){
					inhabit.visibility = Visibility.Visible;
					inhabit.click = delegate (Widget src){
						//TODO: inhabit option
						if(selectedPlanet){
							uint[8] test_population = [100,100,100,100,100,100,100,100];
							selectedPlanet.setOwner(players[queuePosition], test_population);
						}
						return true;
					};
				} else {
					table.childById("inhabit").visibility = Visibility.Gone;
				}
				return true;
			};
			col1.addChild(btn);
		}

		table.colCount = 2;
		table.addChild(new TextWidget(null, "Planet name:"d).fontSize(16));
		table.addChild(new TextWidget("planet name", ""d).fontSize(16));
		table.addChild(new TextWidget(null, "Breathable:"d).fontSize(16));
		table.addChild(new TextWidget("breathable", ""d).fontSize(16));
		table.addChild(new TextWidget(null, "Capacity:"d).fontSize(16));
		table.addChild(new TextWidget("capacity", ""d).fontSize(16));
		table.addChild(new TextWidget(null, "Population:"d).fontSize(16));
		table.addChild(new TextWidget("population", ""d).fontSize(16));
		table.addChild(new TextWidget(null, "Radius:"d).fontSize(16));
		table.addChild(new TextWidget("radius", ""d).fontSize(16));
		table.addChild(new TextWidget(null, "Owner:"d).fontSize(16));
		table.addChild(new TextWidget("owner", ""d).fontSize(16));
		table.addChild(inhabit).visibility = Visibility.Gone;
		addChild(col1);
		addChild(table);
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
		uint[8] population = new uint[8];
		for(int i=0; i<population.length; i++){
			population[i] = to!int(start_pop/8);
		}
		players[0] = new Player(pname, new KnowledgeTree());
		players[0].addPlanet(map.getPlanets[0]);
		map.getPlanets[0].setOwner(players[0], population);
		players[1] = new AI(new KnowledgeTree);
		players[1].addPlanet(map.getPlanets[1]);
		map.getPlanets[1].setOwner(players[1], population);
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