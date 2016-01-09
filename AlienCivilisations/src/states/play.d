module src.states.play;

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

class Play : VerticalLayout, GameState{
	private Map map;
	private Player[2] players;
	private int queuePosition;
	static GameFrame gameFrame;
	private ListWidget planetsList;
	private WidgetListAdapter planetsListAdapter;
	private HorizontalLayout horizontalPanel;
	private TableLayout planetInfo;

	this(GameFrame gameFrame){
		super("play");
		this.gameFrame = gameFrame;
		startNewGame("HUMAN");
		backgroundColor(0x00254d7D);
		//planetsList =  new ListWidget("planetsButtons", Orientation.Vertical);
		//planetsButtonsAdapter = new WidgetListAdapter();
		//planetsList.ownAdapter = planetsButtonsAdapter;
		//
		planetsList = new ListWidget();
		planetsListAdapter = new WidgetListAdapter();
		horizontalPanel = new HorizontalLayout();
		planetInfo = new TableLayout();
		Button inhabitBtn = new Button("inhabit", "Inhabit"d);
		//add elements
		addChild(new TextWidget("currentPlayer", "Current player: " ~ to!dstring(players[queuePosition].getName())).fontSize(25).fontWeight(FontWeight.Bold));
		addChild(horizontalPanel);
		horizontalPanel.addChild(planetsList);
		planetsList.adapter = planetsListAdapter;
		horizontalPanel.addChild(planetInfo);
		addPlanetInfoElements();
		planetInfo.addChild(inhabitBtn);
		//set properties
		layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
		horizontalPanel.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
		planetInfo.padding = 10;
		padding = 10;
		inhabitBtn.visibility = Visibility.Gone;
		planetInfo.colCount = 2;
		//add button for each planet
		Planet[] planets = map.getPlanets();
		for(int i=0; i<planets.length; i++){
			Button btn = new Button(to!string(i), "Planet " ~ to!dstring(i));
			planetsListAdapter.add(btn);
		}
		planetsList.itemSelected = delegate(Widget source, int index) => onPlanetSelect(source, index, inhabitBtn);
		keyEvent = delegate (Widget source, KeyEvent event) => handleKeyInput(source, event);
	}

	this(GameFrame gameFrame, Map map, Player[] players, int qpos){
		this(gameFrame);
		//TODO: constructor reading from json
		this.map = map;
		this.players = players;
		this.queuePosition = qpos;
	}

	private void addPlanetInfoElements(){
		planetInfo.addChild(new TextWidget(null, "Planet name:"d).fontSize(16));
		planetInfo.addChild(new TextWidget("planet name", ""d).fontSize(16));
		planetInfo.addChild(new TextWidget(null, "Breathable:"d).fontSize(16));
		planetInfo.addChild(new TextWidget("breathable", ""d).fontSize(16));
		planetInfo.addChild(new TextWidget(null, "Capacity:"d).fontSize(16));
		planetInfo.addChild(new TextWidget("capacity", ""d).fontSize(16));
		planetInfo.addChild(new TextWidget(null, "Population:"d).fontSize(16));
		planetInfo.addChild(new TextWidget("population", ""d).fontSize(16));
		planetInfo.addChild(new TextWidget(null, "Radius:"d).fontSize(16));
		planetInfo.addChild(new TextWidget("radius", ""d).fontSize(16));
		planetInfo.addChild(new TextWidget(null, "Owner:"d).fontSize(16));
		planetInfo.addChild(new TextWidget("owner", ""d).fontSize(16));
	}

	public Map getMap(){
		return map;
	}
	
	public Player getCurrentPlayer(){
		return players[queuePosition];
	}
	
	public void startNewGame(string pname){
		map = new Map(2000, 16);
		players[0] = new Player(pname, new KnowledgeTree());
		players[0].addPlanet(map.getPlanets[0]);
		map.getPlanets[0].setOwner(players[0]);
		players[1] = new AI(new KnowledgeTree(), map);
		players[1].addPlanet(map.getPlanets[1]);
		map.getPlanets[1].setOwner(players[1]);
		queuePosition = to!int(dice(0.5, 0.5));
	}

	public bool handleKeyInput(Widget source, KeyEvent event){
		if(event.action == KeyAction.KeyDown && event.keyCode == KeyCode.ESCAPE){
			//gameFrame.setState(new Menu(gameFrame, this));

		}
		return true;
	}

	private bool onPlanetSelect(Widget src, int index, Button inhabitBtn){
		Planet[] planets = map.getPlanets();
		Planet selectedPlanet = planets[index];
		writeln("delegate called");
		planetInfo.childById("planet name").text = to!dstring(selectedPlanet.getName);
		planetInfo.childById("breathable").text = selectedPlanet.isBreathable ? "true" : "false";
		dstring capacity = to!dstring(selectedPlanet.getCapacity);
		planetInfo.childById("capacity").text = capacity;
		planetInfo.childById("population").text = to!dstring(selectedPlanet.getPopulationSum);
		dstring radius = to!dstring(selectedPlanet.getRadius);
		planetInfo.childById("radius").text = radius;
		Player owner = selectedPlanet.getOwner;
		planetInfo.childById("owner").text = owner ? to!dstring(owner.getName) : "No owner";
		if(!owner){
			inhabitBtn.visibility = Visibility.Visible;
			inhabitBtn.click = delegate (Widget src){
				//TODO: inhabit option
				if(selectedPlanet){
					selectedPlanet.setOwner(players[queuePosition]);
					inhabitBtn.visibility = Visibility.Gone;
					gameFrame.needDraw();
				}
				return true;
			};
		} else {
			planetInfo.childById("inhabit").visibility = Visibility.Gone;
		}
		return true;
	}
}