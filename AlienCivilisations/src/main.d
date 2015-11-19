﻿module main;

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

void main(string[] args) {
	//Map map = new Map(1000.0);
	//GameManager gameManager = new GameManager(map);
	//createPlanets(gameManager, map);
	//createWindow();
	KnowledgeTree kt = new KnowledgeTree();
	//writeln(kt.pointsToLevel(2*50000));
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

void createWindow(){
	DerelictGL3.load();
	DerelictGLFW3.load();
	//create context
	GLFWwindow* window;
	if(!glfwInit()){
		return;
	}
	window = glfwCreateWindow(640, 480, "Hello world", null, null);
	if(!window){
		glfwTerminate();
		return;
	}
	glfwMakeContextCurrent(window);
	DerelictGL3.reload();
	while(!glfwWindowShouldClose(window)){
		glfwSwapBuffers(window);
		glfwPollEvents();
		Thread.sleep(dur!("msecs")(50));
	}
	glfwTerminate();
	DerelictGL3.reload();
}

/*
 * Linker imports: -lDerelictUtil -lDerelictSDL2 -lDerelictGL3 -ldl
 * 
 */