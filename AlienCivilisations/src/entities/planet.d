module src.entities.planet;

import src.containers.vector2d;
import src.entities.branch;
import src.entities.knowledgeTree;
import src.entities.player;
import src.entities.ship;
import std.algorithm;
import std.conv;
import std.stdio;

class Planet {
	private immutable int _populationConstant = 10000;
	private immutable string _name;
	private Vector2d _position;
	private float _radius;
	private uint[8] _population = [0,0,0,0,0,0,0,0];
	private uint _food;
	private bool _breathableAtmosphere;
	private uint _militaryUnits = 0;
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

	Planet setOwner(Player player, uint[8] population = [1000,1000,1000,1000,1000,1000,1000,1000]){
		_owner = player;
		_population = population;
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
		//TODO
		//food supply at best increases at arythmetic rate
		//1 > 2 > 3 > 4 > 5
		_food -= populationSum;
		double foodB = _owner.knowledgeTree.branch(BranchName.Food).effectiveness;
		uint workingUnits = _population[2 .. 6].sum;//population[2] + population[3] + population[4] + population[5] + population[6];
		_food += to!int(workingUnits * foodB);
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

	uint militarise(int percent){
		uint p = min(percent, 100);
		uint g1 = to!int(p/100 * _population[2]);
		uint g2 = to!int(p/100 * _population[3]);
		_population[2] -= g1;
		_population[3] -= g2;
		_militaryUnits += g1 + g2;
		return g1 + g2;
	}

	void subtractPopulation(uint value){
		//TODO: check if function distributes the values as intended
		if(value > populationSum){
			_population = [0,0,0,0,0,0,0,0];
		}
		else {
			while(value >= 0){
				uint perGroup = to!uint(value / _population.length);
				if(perGroup == 0){
					perGroup = 1;
				}
				for(int i=0; i < _population.length; i++){
					if(_population[i] == 0)
						continue;
					if(_population[i] < perGroup){
						_population[i] = 0;
						value -= _population[i];
					}
					else {
						_population[i] -= perGroup;
						value -= perGroup;
					}
				}
			}
		}
	}

	Ship produceShip(ShipType type){

		if(type == ShipType.Military){

		}
		if(type == ShipType.Inhabitation){

		}
		return null;
	}
}


//https://books.google.co.uk/books?id=7GH0KZZthGoC&pg=PA378&lpg=PA378&dq=population+growth+food+curve&source=bl
//&ots=MgtXbY58zz&sig=B92VL4uN6WEadVu-VjU6c9OJyuk&hl=en&sa=X&ved=0ahUKEwi9sqjN68nJAhWDshQKHeyJCxMQ6AEIRDAI#v=onepage
//&q=population%20growth%20food%20curve&f=false


