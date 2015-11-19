module entities.planet;

import handlers.vector2d;
import std.conv;
import handlers.gameManager;
import entities.player;
import handlers.knowledgeTree;
import std.algorithm;
import handlers.branch;

class Planet {
	private GameManager gameManager;
	private Vector2D vec2d;
	private float radius;
	private int capacity;
	private int population = 0;
	private bool breathable_atmosphere;
	private Player owner;

	/*this(GameManager gameManager){
		import std.random;
		float x = uniform(0.0, gameManager.getMap().getEndX());
		float y = uniform(0.0, gameManager.getMap().getEndY()); 
		Vector2D v = new Vector2D(x, y);
		float r = uniform(0.05, 2.0);
		int c = cast(int)(uniform(1, 10) * radius) * 10000;
		bool b = uniform(0,2) == 1;
		this(gameManager, v, r, c, b);
	}*/

	this(GameManager gameManager, Vector2D vec2d, float radius, int capacity, bool breathable_atmosphere){
		this.gameManager = gameManager;
		this.vec2d = vec2d;
		this.radius = radius;
		this.capacity = capacity;
		this.breathable_atmosphere = breathable_atmosphere;
	}

	public Vector2D getVec2d(){
		return vec2d;
	}

	public bool isBreathable(){
		return breathable_atmosphere;
	}

	public int getCapacity(){
		return capacity;
	}

	public int getPopulation(){
		return population;
	}

	public float getRadius(){
		return radius;
	}

	override public string toString(){
		import std.format;
		return format("X: %s \n Y:%s", vec2d.getX(), vec2d.getY());
	}

	public void setOwnership(Player player, int population){
		this.owner = player;
	}

	public void growPopulation(){
		if(!owner){
			Branch foodBranch = owner.getKnowledgeTree().getBranch("Food");
			population += to!int(population * foodBranch.getBranchLevel() * (2 ? breathable_atmosphere : 1.5));
		}
	}
}




