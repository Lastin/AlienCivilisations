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
		onDrawListener = delegate(CanvasWidget canvas, DrawBuf buf, Rect rc) {
			drawPlanets(canvas, buf, rc);
		};
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
		buf.fill(0xFFFFFF);
		int x = rc.left;
		int y = rc.top;
		buf.fillRect(Rect(x+20, y+20, x+150, y+200), 0x80FF80);
		buf.fillRect(Rect(x+90, y+80, x+250, y+250), 0x80FF80FF);
		font.drawText(buf, x + 40, y + 50, "fillRect()"d, 0xC080C0);
		buf.drawFrame(Rect(x + 400, y + 30, x + 550, y + 150), 0x204060, Rect(2,3,4,5), 0x80704020);
		font.drawText(buf, x + 400, y + 5, "drawFrame()"d, 0x208020);
		font.drawText(buf, x + 300, y + 100, "drawPixel()"d, 0x000080);
		for (int i = 0; i < 80; i++)
			buf.drawPixel(x+300 + i * 4, y+140 + i * 3 % 100, 0xFF0000 + i * 2);
		font.drawText(buf, x + 200, y + 250, "drawLine()"d, 0x800020);
		for (int i = 0; i < 40; i+=3)
			buf.drawLine(Point(x+200 + i * 4, y+290), Point(x+150 + i * 7, y+420 + i * 2), 0x008000 + i * 5);
	}
}