﻿module src.entities.map;

import src.entities.planet;
import src.entities.player;
import std.conv;
import std.random;
import std.stdio;
import src.containers.vector2d;

class Map {
	private immutable float _size;
	private Planet[] _planets;

	this(float size, int planetCount, Player[] players) {
		_size = size;
		int idCount = 0;
		foreach(Player player; players){
			auto p = new Planet(idCount, player.name ~ "'s planet", getFreeLocation(10), 60, true);
			addPlanet(p).setOwner(player);
			p.resetPopulation();
			idCount++;
		}
		for(size_t i=players.length; i<planetCount; i++, idCount++){
			float radius = uniform(40, 81);
			bool breathableAtmosphere = dice(0.5, 0.5)>0;
			addPlanet(new Planet(idCount, "Planet "~ to!string(i), getFreeLocation(radius), radius, breathableAtmosphere));
		}
		debug {
			foreach(Planet p; _planets){
				writefln("X: %s Y: %s Radius: %s", p.position.x, p.position.y, p.radius);
			}
		}
	}

	this(float size, Planet[] planets) {
		_size = size;
		_planets = planets;
	}
	/** Adds planet to list and returns same planet **/
	Planet addPlanet(Planet planet) {
		_planets ~= planet;
		return planet;
	}
	/** Concatinates current list of planets with argument **/
	void addPlanets(Planet[] newPlanets) {
		_planets ~= newPlanets;
	}
	/** Returns true if planet border is below limit to nearest planets **/
	bool collides(Planet p) {
		if(collides(p.position, p.radius)) {
			return true;
		}
		return false;
	}
	/** Returns planet which border is closer than minimum distance minus radius of vector **/
	Planet collides(Vector2d vector, float radius, float minDistance = 700) {
		foreach(Planet planet; _planets){
			auto distance = vector.getEuclideanDistance(planet.position) - radius - planet.radius;
			if(distance < minDistance){
				return planet;
			}
		}
		return null;
	}
	/** Returns location on the map which is not closer than minimum distance minus radius from other planets. **/
	Vector2d getFreeLocation(float radius) {
		Vector2d vector;
		do {
			float x = uniform(0.0, _size-radius);
			float y = uniform(0.0, _size-radius);
			vector = Vector2d(x, y);
		} while(collides(vector, radius));
		return vector;
	}
	/** Returns planet which is located on given vector **/
	Planet planetAt(Vector2d vector) {
		foreach(Planet planet; _planets){
			if(vector.getEuclideanDistance(planet.position) <= planet.radius){
				return planet;
			}
		}
		return null;
	}
	/** Returns all planets **/
	@property Planet[] planets() {
		return _planets;
	}
	/** Returns size of the map **/
	@property float size() const {
		return _size;
	}
	/**  **/
	@property Planet[] freePlanets() {
		Planet[] free;
		foreach(planet; _planets) {
			if(!planet.owner)
				free ~= planet;
		}
		return free;
	}
	Planet planetWithId(int uniqueId) {
		foreach(planet; _planets) {
			if(planet.uniqueId == uniqueId)
				return planet;
		}
		debug writefln("Could not find planet with uid: %s", uniqueId);
		return null;
	}
}