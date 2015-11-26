module main;

import std.stdio;
import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;
import handlers.gameManager;
import handlers.map;
import entities.planet;
import std.random;
import handlers.vector2d;
import std.process;
import core.thread;
import handlers.knowledgeTree;
import std.typecons;
import std.container.dlist;
import std.algorithm;
import std.range;
import handlers.branch;
import handlers.commandParser;
import handlers.window;




void main(string[] args) {

	//Map map = new Map(1000.0);
	//GameManager gameManager = new GameManager(map);
	//createPlanets(gameManager, map);
	Window window = new Window(1280, 720);
	window.start();
	//KnowledgeTree kt = new KnowledgeTree();
	//writeln(kt.pointsToLevel(2*50000));
	Branch b = new Branch("", [""], [0,0,0,0,0]);
	CommandParser cp = new CommandParser();
}


void createPlanets(GameManager gameManager, Map map){
	//GameManager gameManager, Vector2D vec2d, float radius, int capacity, bool breathable_atmosphere
	float radius = 2.0;
	int capacity = 100000;
	bool breathable_atmosphere = true;
	int counter = 0;
	Vector2D vecA = map.getFreeLocation(radius);
	Planet planetA = new Planet(gameManager, vecA, radius, capacity, true);
	map.addPlanet(planetA);
	Vector2D vecB = map.getFreeLocation(radius);
	Planet planetB = new Planet(gameManager, vecB, radius, capacity, true);
	writeln("planets created");
	writeln("distance: ", Vector2D.getEucliDist(vecA, vecB));
}

/*
 * Linker imports: -lDerelictUtil -lDerelictSDL2 -lDerelictGL3 -ldl
 * 
 */