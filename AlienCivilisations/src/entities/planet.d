module src.entities.planet;

import std.math;
import src.containers.vector2d;
import std.conv;
import src.entities.player;
import src.logic.knowledgeTree;
import std.algorithm;
import src.logic.branch;
import std.stdio;

class Planet {
	private immutable int _populationConstant = 10000;
	private immutable string _name;
	private Vector2d _position;
	private float _radius;
	private uint[8] _population = [0,0,0,0,0,0,0,0];
	private uint _food;
	private bool _breathableAtmosphere;
	private Player _owner;

	this(Vector2d position, float radius, bool breathableAtmosphere, string name){
		_position = position;
		_radius = radius;
		_breathableAtmosphere = breathableAtmosphere;
		_name = name;
	}

	@property Vector2d position(){
		return _position;
	}

	@property bool breathableAtmosphere(){
		return _breathableAtmosphere;
	}

	@property int capacity(){
		return to!int(_radius * _populationConstant);
	}

	@property uint populationSum(){
		return _population[].sum;
	}

	@property float radius(){
		return _radius;
	}

	@property string name(){
		return _name;
	}

	@property Player owner(){
		return _owner;
	}

	override public string toString(){
		import std.format;
		return format("X: %s \n Y:%s", _position.x, _position.y);
	}

	uint attack(uint force){
		if(force >= populationSum){
			_owner = null;
			return force - capacity;
		}
		subtractPopulation(force);
		return 0;
	}

	Planet setOwner(Player player, uint[8] population){
		_owner = player;
		//auto x = to!int(capacity / _population.length / 10);
		_population = population;//[x,x,x,x,x,x,x,x];
		return this;
	}

	void step(){
		//this function ends turn of the player affecting planet attributes
		if(_owner !is null){
			growPopulation();
			affectFood();
		}
	}

	private void affectFood(){
		//don't hesitate to contact me if you think of a better name for this function
		//food supply at best increases at arythmetic rate
		//1 > 2 > 3 > 4 > 5
		_food -= populationSum;
		int foodBranchLevel = _owner.getKnowledgeTree().getBranch("Food").getBranchLevel();
		uint workingUnits = _population[2 .. 6].sum;//population[2] + population[3] + population[4] + population[5] + population[6];
		_food += to!int(workingUnits * foodBranchLevel / 0.5);
	}
	private void growPopulation(){
		double overPopulationFactor = 1;
		if(populationSum > capacity){
			int overflow =  populationSum - capacity;
			overPopulationFactor = overflow / capacity;
		}
		//population grows at exponential rate
		//1 > 2 > 4 > 8 > 16
		//but is also affected by the food
		for(size_t i = _population.length - 1; i>0; i--){
			//elder the population
			_population[i] = _population[i-1];
		}
		double reproductivePairs = (_population[2] + _population[3]) / 2;
		double childPerPair = 2.5;
		double foodFactor = populationSum / _food;
		_population[0] = to!int(reproductivePairs * childPerPair * foodFactor / overPopulationFactor);
	}

	int militarise(int percent){
		int p = min(percent, 100);
		int g1 = to!int(p/100 * _population[2]);
		int g2 = to!int(p/100 * _population[3]);
		_population[2] -= g1;
		_population[2] -= g2;
		return g1 + g2;
	}

	void subtractPopulation(uint value){
		//TODO: check if function distributes the values as intended
		if(value > populationSum){
			_population = [0,0,0,0,0,0,0,0];
		}
		else {
			while(value >= 1){
				auto x = value / _population.length;
				for(int i=0; i < _population.length; i++){
					if(_population[i] == 0)
						continue;
					if(_population[i] < x){
						_population[i] = 0;
						value -= _population[i];
					}
					else {
						_population[i] -= x;
						value -= x;
					}
				}
			}
		}
	}

	void produceShip(string type){
		if(type == "military"){

		}
		else if(type == "inhabitation"){

		}
	}
}


//https://books.google.co.uk/books?id=7GH0KZZthGoC&pg=PA378&lpg=PA378&dq=population+growth+food+curve&source=bl
//&ots=MgtXbY58zz&sig=B92VL4uN6WEadVu-VjU6c9OJyuk&hl=en&sa=X&ved=0ahUKEwi9sqjN68nJAhWDshQKHeyJCxMQ6AEIRDAI#v=onepage
//&q=population%20growth%20food%20curve&f=false


