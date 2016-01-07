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

class Play : TableLayout, GameState{
	private Map map;
	private Player[2] players;
	private int queuePosition;
	static GameFrame gameFrame;

	this(GameFrame gameFrame){
		this.gameFrame = gameFrame;
		auto btn = new Button(null, "Test Button");
		btn.click = delegate(Widget src){
			writeln("test");
			return true;
		};
		VerticalLayout vl = new VerticalLayout();
		//vl.addChild(btn);
		//addChild(vl);
		startNewGame("HUMAN");

		CanvasWidget canvas = new CanvasWidget("canvas");
		canvas.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
		canvas.onDrawListener = delegate(CanvasWidget canvas, DrawBuf buf, Rect rc) {
			buf.fill(0xFFFFFF);
			int x = rc.left;
			int y = rc.top;
			buf.fillRect(Rect(x+20, y+20, x+150, y+200), 0x80FF80);
			buf.fillRect(Rect(x+90, y+80, x+250, y+250), 0x80FF80FF);
			canvas.font.drawText(buf, x + 40, y + 50, "fillRect()"d, 0xC080C0);
			buf.drawFrame(Rect(x + 400, y + 30, x + 550, y + 150), 0x204060, Rect(2,3,4,5), 0x80704020);
			canvas.font.drawText(buf, x + 400, y + 5, "drawFrame()"d, 0x208020);
			canvas.font.drawText(buf, x + 300, y + 100, "drawPixel()"d, 0x000080);
			for (int i = 0; i < 80; i++)
				buf.drawPixel(x+300 + i * 4, y+140 + i * 3 % 100, 0xFF0000 + i * 2);
			canvas.font.drawText(buf, x + 200, y + 250, "drawLine()"d, 0x800020);
			for (int i = 0; i < 40; i+=3)
				buf.drawLine(Point(x+200 + i * 4, y+290), Point(x+150 + i * 7, y+420 + i * 2), 0x008000 + i * 5);
		};
		//addChild(canvas);
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