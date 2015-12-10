module src.main;

import std.stdio;
import src.handlers.gameManager;
import src.entities.map;
import src.containers.vector2d;
import src.entities.planet;
import src.graphics.window;
import src.states.menu;
import src.states.play;

void main(string[] args) {
	//Map map = new Map(1000.0);
	//GameManager gameManager = new GameManager(map);
	//createPlanets(gameManager, map);
	Window window = new Window(1280, 720);
	//window.join();

	//window.setState(new Menu());

	//KnowledgeTree kt = new KnowledgeTree();
	//writeln(kt.pointsToLevel(2*50000));
	//CommandParser cp = new CommandParser();
	GameManager gm = new GameManager();

}

/*
 * Linker imports: -lDerelictUtil -lDerelictSDL2 -lDerelictGL3 -ldl
 * 
 */