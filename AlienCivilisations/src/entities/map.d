/**
This module implements the map used in game.
It hold the size and references to the planets.

It offers two contructors:
-initialise planets and assign owners - this is when initialising new map
-takes already initialised list of planets and store it in the instance variable

When intialising new map, it places the planets randomly, at distance no closer than specified.
When initialising new map, identical planets are created for each player and assigned ownership to them, others have randomly generated properties.

Author: Maksym Makuch
 **/

module src.entities.map;

import src.containers.point2d;
import src.entities.planet;
import src.entities.player;
import src.entities.ship;
import std.conv;
import std.format;
import std.random;
import std.stdio;

class Map {

	private immutable float _size;
	private Planet[] _planets;

	/** Takes size, number of planets and players. Initialises new planets and assigns ownerships **/
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
	/** Takes the size and already initialised planets (stores planets in the instance array) **/
	this(float size, Planet[] planets) {
		_size = size;
		_planets = planets;
	}
	/** Adds planet to list of all planets, and returns same planet **/
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
	/** Returns planet which border is closer than minimum distance minus radius of vector.
	Default minimal distance in place, pass number as third argument to use custom value **/
	Planet collides(Point2D vector, float radius, float minDistance = 700) {
		foreach(Planet planet; _planets){
			auto distance = vector.getEuclideanDistance(planet.position) - radius - planet.radius;
			if(distance < minDistance){
				return planet;
			}
		}
		return null;
	}
	/** Returns location on the map which is not closer than minimum distance minus radius from other planets. **/
	Point2D getFreeLocation(float radius) {
		Point2D vector;
		do {
			float x = uniform(0.0, _size-radius);
			float y = uniform(0.0, _size-radius);
			vector = Point2D(x, y);
		} while(collides(vector, radius));
		return vector;
	}
	/** Returns planet which is located on given vector **/
	Planet planetAt(Point2D vector) {
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
	/** Returns duplicates of the planets. Assigns ownership to the player, from argument list, found by same unique identifier as current owner **/
	@property Planet[] duplicatePlanets(Player[] players) const {
		Planet[] duplicates;
		foreach(const Planet origin; _planets){
			Player newOwner = Player.findPlayerWithId(origin.ownerId, players);
			duplicates ~= origin.dup(newOwner);
		}
		return duplicates;
	}
	/** Returns size of the map **/
	@property float size() const {
		return _size;
	}
	/** Returns vacant planets **/
	@property Planet[] freePlanets() {
		Planet[] free;
		foreach(planet; _planets) {
			if(!planet.owner)
				free ~= planet;
		}
		return free;
	}
	/** Returns the player belonging to the player with given unique identifier **/
	Planet[] playerPlanets(int puid) {
		Planet[] pp;
		foreach(planet; planets) {
			if(planet.owner && planet.owner.uniqueId == puid) {
				pp ~= planet;
			}
		}
		return pp;
	}
	/** Returns the instance of the planet found by given unique identifier **/
	Planet planetWithId(int uniqueId) {
		foreach(planet; _planets) {
			if(planet.uniqueId == uniqueId)
				return planet;
		}
		writeln("Could not find planet with uid: %s", uniqueId);
		return null;
	}
}