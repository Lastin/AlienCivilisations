module src.states.play;

import dlangui;
import src.entities.knowledgeTree;
import src.entities.map;
import src.entities.planet;
import src.entities.player;
import src.gameFrame;
import src.logic.ai;
import src.states.gameState;
import src.states.menu;
import src.states.play;
import std.algorithm;
import std.conv;
import std.random;
import std.stdio;

class Play : VerticalLayout, GameState{
	private static GameFrame _gameFrame;
	private Map _map;
	private Player[] _players;
	private size_t _queuePosition;
	private ListWidget _planetsList;
	private WidgetListAdapter _planetsListAdapter;
	private HorizontalLayout _horizontalPanel;
	private TableLayout _planetInfo;

	this(GameFrame gameFrame){
		super("play");
		_gameFrame = gameFrame;
		startNewGame("HUMAN");
		backgroundColor(0x00254d7D);
		_planetsList = new ListWidget();
		_planetsListAdapter = new WidgetListAdapter();
		_horizontalPanel = new HorizontalLayout();
		_planetInfo = new TableLayout();
		auto inhabitBtn = new Button("inhabitButton", "Inhabit"d);
		//add elements
		addChild(new TextWidget("currentPlayer", "Current player: " ~ to!dstring(currentPlayer.name)).fontSize(25).fontWeight(FontWeight.Bold));
		addChild(_horizontalPanel);
		_horizontalPanel.addChild(_planetsList);
		_planetsList.adapter = _planetsListAdapter;
		_horizontalPanel.addChild(_planetInfo);
		addPlanetInfoElements();
		_planetInfo.addChild(inhabitBtn);
		//set properties
		layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
		padding = 10;
		_horizontalPanel.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
		_planetInfo.padding = 10;
		_planetInfo.colCount = 2;
		//add button for each planet
		Planet[] planets = _map.planets;
		for(int i=0; i<planets.length; i++){
			Button btn = new Button(to!string(i), "Planet " ~ to!dstring(i));
			_planetsListAdapter.add(btn);
		}
		_planetsList.itemSelected = delegate(Widget source, int index) => onPlanetSelect(source, index, inhabitBtn);
		keyEvent = delegate (Widget source, KeyEvent event) => handleKeyInput(source, event);
	}

	this(GameFrame gameFrame, Map map, Player[] players, int qpos){
		this(gameFrame);
		//TODO: constructor reading from json
		_map = map;
		_players = players;
		_queuePosition = qpos;
	}

	private void addPlanetInfoElements(){
		_planetInfo.addChild(new TextWidget(null, "Planet name:"d).fontSize(16));
		_planetInfo.addChild(new TextWidget("planet name", ""d).fontSize(16));
		_planetInfo.addChild(new TextWidget(null, "Breathable:"d).fontSize(16));
		_planetInfo.addChild(new TextWidget("breathable", ""d).fontSize(16));
		_planetInfo.addChild(new TextWidget(null, "Capacity:"d).fontSize(16));
		_planetInfo.addChild(new TextWidget("capacity", ""d).fontSize(16));
		_planetInfo.addChild(new TextWidget(null, "Population:"d).fontSize(16));
		_planetInfo.addChild(new TextWidget("population", ""d).fontSize(16));
		_planetInfo.addChild(new TextWidget(null, "Radius:"d).fontSize(16));
		_planetInfo.addChild(new TextWidget("radius", ""d).fontSize(16));
		_planetInfo.addChild(new TextWidget(null, "Owner:"d).fontSize(16));
		_planetInfo.addChild(new TextWidget("owner", ""d).fontSize(16));
	}
	
	@property Player currentPlayer(){
		return _players[_queuePosition];
	}
	
	void startNewGame(string pname){
		immutable uint[][] points = 
			[
				[0, 0, 0, 0, 0],
				[0, 0, 0, 0, 0],
				[0, 0, 0, 0, 0],
				[0, 0, 0, 0, 0],
				[0, 0, 0, 0, 0]
			];
		_players ~= new Player(pname, new KnowledgeTree(points.to!(uint[][])), _map);
		_players ~= new AI(new KnowledgeTree(points.to!(uint[][])), _map, _players);
		_queuePosition = uniform(0, _players.length);
		_map = new Map(2000, 16, _players);
	}

	bool handleKeyInput(Widget source, KeyEvent event){
		if(event.action == KeyAction.KeyDown && event.keyCode == KeyCode.ESCAPE){
			_gameFrame.setState(new Menu(_gameFrame, "pause_menu", this));
		}
		return true;
	}

	private bool onPlanetSelect(Widget src, int index, Button inhabitBtn){
		_planetInfo.removeChild("inhabitButton");
		Planet[] planets = _map.planets;
		Planet selectedPlanet = planets[index];
		writeln("delegate called");
		_planetInfo.childById("planet name").text = to!dstring(selectedPlanet.name);
		_planetInfo.childById("breathable").text = selectedPlanet.breathableAtmosphere ? "true" : "false";
		auto capacity = to!dstring(selectedPlanet.capacity);
		_planetInfo.childById("capacity").text = capacity;
		_planetInfo.childById("population").text = to!dstring(selectedPlanet.populationSum);
		auto radius = to!dstring(selectedPlanet.radius);
		_planetInfo.childById("radius").text = radius;
		auto owner = selectedPlanet.owner;
		_planetInfo.childById("owner").text = owner ? to!dstring(owner.name) : "No owner";
		if(!owner){
			_planetInfo.addChild(inhabitBtn);
			inhabitBtn.click = delegate (Widget src){
				//TODO: inhabit option
				if(selectedPlanet){
					//selectedPlanet.setOwner(_players[_queuePosition]);
					if(currentPlayer.availableShips.length > 0){
						currentPlayer.orderInhabit(selectedPlanet);
						_planetInfo.removeChild("inhabitButton");
					}
					else {
						debug writeln("No ships available");
					}
				}
				return true;
			};
		} else {
			_planetInfo.removeChild("inhabitButton");
		}
		return true;
	}

	void endTurn(){
		if(_queuePosition == _players.length){
			_queuePosition = 0;
		}
		else {
			_queuePosition++;
		}
	}

	@property Player[] players(){
		return _players;
	}
}