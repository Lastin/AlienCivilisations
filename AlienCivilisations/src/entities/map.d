module src.entities.map;

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
		foreach(Player player; players){
			auto p = new Planet(player.name ~ "'s planet", getFreeLocation(10), 60, true);
			addPlanet(p).setOwner(player);
			p.resetPopulation();
		}
		for(size_t i=players.length; i<planetCount; i++){
			float radius = uniform(40, 81);
			bool breathableAtmosphere = dice(0.5, 0.5)>0;
			addPlanet(new Planet("Planet "~ to!string(i), getFreeLocation(radius), radius, breathableAtmosphere));
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

	Planet addPlanet(Planet planet) {
		_planets ~= planet;
		return planet;
	}

	void addPlanets(Planet[] newPlanets) {
		_planets ~= newPlanets;
	}

	bool collides(Planet p) {
		if(collides(p.position, p.radius)) {
			return true;
		}
		return false;
	}

	Planet collides(Vector2d vector, float radius, float minDistance = 700) {
		foreach(Planet planet; _planets){
			auto distance = vector.getEuclideanDistance(planet.position) - radius - planet.radius;
			if(distance < minDistance){
				return planet;
			}
		}
		return null;
	}

	Vector2d getFreeLocation(float radius) {
		Vector2d vector;
		do {
			float x = uniform(0.0, _size-radius);
			float y = uniform(0.0, _size-radius);
			vector = Vector2d(x, y);
		} while(collides(vector, radius));
		return vector;
	}

	Planet planetAt(Vector2d vector) {
		foreach(Planet planet; _planets){
			if(vector.getEuclideanDistance(planet.position) <= planet.radius){
				return planet;
			}
		}
		return null;
	}

	@property Planet[] planets() {
		return _planets;
	}
	
	@property float size() const {
		return _size;
	}
}