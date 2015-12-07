module src.entities.map;

import std.container: SList;
import src.entities.planet;
import src.containers.vector2d;
import std.stdio;
import std.random;

class Map {
	private float endX;
	private float endY;
	private SList!Planet planets;
	private immutable float minDistance = 30;

	this(float size){
		endX = endY = size;
	}

	public void addPlanet(Planet planet){
		planets.insert(planet);
	}

	public void addPlanets(SList!Planet newPlanets){
		foreach(planet; newPlanets.opSlice){
			planets.insert(planet);
		}
	}

	public bool collides(Planet planetA){
		Vector2D vecA = planetA.getVec2d();
		float radA = planetA.getRadius();
		return collides(vecA, radA);
	}

	public bool collides(Vector2D vector, float radius){
		foreach(Planet planet; planets){
			float distance = Vector2D.getEucliDist(vector, planet.getVec2d()) - radius - planet.getRadius();
			if(distance < minDistance){
				return true;
			}
		}
		return false;
	}

	public Vector2D getFreeLocation(float radius){
		Vector2D vector;
		do {
			float x = uniform(0.0, endX);
			float y = uniform(0.0, endY);
			vector = new Vector2D(x, y);
		} while(collides(vector, radius));
		return vector;
	}

	public SList!(Planet) getPlanets(){
		return planets;
	}

	public Planet getPlanetAt(Vector2D vec2d){
		foreach(Planet planet; planets.opSlice()){
			if(vec2d == planet.getVec2d()){
				return planet;
			}
		}
		return null;
	}

	public float getEndX(){
		return endX;
	}

	public float getEndY(){
		return endY;
	}
}