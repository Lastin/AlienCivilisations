module src.entities.planet;

import src.containers.vector2d;
import std.conv;
import src.entities.player;
import src.logic.knowledgeTree;
import std.algorithm;
import src.logic.branch;

class Planet {
	private Vector2D vec2d;
	private float radius;
	private int capacity;
	private int[] population = new int[8];
	private int food;
	private bool breathable_atmosphere;
	private Player owner;

	this(Vector2D vec2d, float radius, bool breathable_atmosphere){
		this.vec2d = vec2d;
		this.radius = radius;
		this.capacity = to!int(radius * 10000);
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

	public int getPopulationSum(){
		return sum(population);
	}

	public float getRadius(){
		return radius;
	}

	override public string toString(){
		import std.format;
		return format("X: %s \n Y:%s", vec2d.getX(), vec2d.getY());
	}

	public void setOwner(Player player, int population){
		this.owner = player;
	}

	public Player getOwner(){
		return owner;
	}

	public void step(){
		//this function ends turn of the player affecting planet attributes
		if(owner !is null){
			affectFood();
			growPopulation();
		}
	}
	//https://books.google.co.uk/books?id=7GH0KZZthGoC&pg=PA378&lpg=PA378&dq=population+growth+food+curve&source=bl
	//&ots=MgtXbY58zz&sig=B92VL4uN6WEadVu-VjU6c9OJyuk&hl=en&sa=X&ved=0ahUKEwi9sqjN68nJAhWDshQKHeyJCxMQ6AEIRDAI#v=onepage
	//&q=population%20growth%20food%20curve&f=false

	private void affectFood(){
		//don't hesitate to contact me if you think of a better name for this function
		//food supply at best increases at arythmetic rate
		//1 > 2 > 3 > 4 > 5
		food -= getPopulationSum();
		Branch foodBranch = owner.getKnowledgeTree().getBranch("Food");
		int contributing_units = population[2] + population[3] + population[4] + population[5] + population[6];
		food += to!int(contributing_units * foodBranch.getBranchLevel() / 0.5);
	}
	private void growPopulation(){
		double opf = 1;
		int totalPop = getPopulationSum();
		if(totalPop > capacity){
			int overflow =  totalPop - capacity;
			opf = overflow * 10 / capacity;
		}
		//population grows at exponential rate
		//1 > 2 > 4 > 8 > 16
		//but is also affected by the food
		for(ulong i=population.length-1; i>0; i--){
			//elder the population
			population[i] = population[i-1];
		}
		int reproductive_units = population[2] + population[3];
		population[0] = to!int(reproductive_units / 2 * 2.5 * getPopulationSum / food * opf);
	}

	public int militarise(uint percent){
		int p = min(percent, 100);
		int g1 = to!int(p/100 * population[2]);
		int g2 = to!int(p/100 * population[3]);
		population[2] -= g1;
		population[2] -= g2;
		return g1 + g2;
	}
}




