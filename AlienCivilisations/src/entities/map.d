module src.entities.map;

import dlangui;
import src.handlers.containers;
import src.entities.planet;
import src.entities.player;
import std.random;
import std.stdio;

class Map : CanvasWidget {
	private immutable float _size;
	private immutable float _minDistance = 30;
	private Planet[] _planets;

	this(float size, int planetCount, Player[] players) {
		_size = size;
		foreach(Player player; players){
			auto p = new Planet(getFreeLocation(10), 10, true, player.name ~ "'s planet");
			addPlanet(p).setOwner(player);
		}
		for(size_t i=players.length; i<planetCount; i++){
			float radius = uniform(1, 20);
			addPlanet(new Planet(getFreeLocation(radius), radius, dice(0.5, 0.5)>0, "Planet "~ to!string(i)));
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
		return collides(p.position, p.radius);
	}

	bool collides(Vector2d vector, float radius) {
		foreach(Planet planet; _planets){
			auto distance = vector.getEuclideanDistance(planet.position) - radius - planet.radius;
			if(distance < _minDistance){
				return true;
			}
		}
		return false;
	}

	Vector2d getFreeLocation(float radius) {
		Vector2d vector;
		do {
			float x = uniform(0.0, _size-radius);
			float y = uniform(0.0, _size-radius);
			vector = new Vector2d(x, y);
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

	@property Planet[] planets() nothrow {
		return _planets;
	}
	
	@property float size() const {
		return _size;
	}

	public Map dup() {
		Planet[] planetsCopy;
		foreach(Planet p; planets){
			planetsCopy ~= p.dup;
		}
		return new Map(_size, planets.dup);
	}
}