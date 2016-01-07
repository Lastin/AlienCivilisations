module src.entities.map;

import std.container: SList;
import src.entities.planet;
import src.containers.vector2d;
import std.stdio;
import std.random;
import dlangui;

class Map : CanvasWidget{
	private immutable float endX;
	private immutable float endY;
	private immutable float size;
	private immutable float minDistance = 30;
	private Planet[] planets;

	this(float size){
		this.size = endX = endY = size;
	}

	this(float size, int planetCount){
		this(size);
		planets ~= new Planet(getFreeLocation(10), 10, true);
		planets ~= new Planet(getFreeLocation(10), 10, true);
	}

	this(float size, Planet[] planets){
		this(size);
		this.planets = planets;
	}

	public void addPlanet(Planet planet){
		planets ~= planet;
	}

	public void addPlanets(Planet[] newPlanets){
		planets ~= newPlanets;
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

	public Planet[] getPlanets(){
		return planets;
	}

	public Planet getPlanetAt(Vector2D vec2d){
		foreach(Planet planet; planets){
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

	public Map dup(){
		return new Map(size, planets);
	}

	public void render(){

	}

	public void drawPlanets(CanvasWidget canvas, DrawBuf buf, Rect rc){

	}
}