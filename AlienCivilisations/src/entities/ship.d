module src.entities.ship;

import std.algorithm;
import src.entities.planet;

class Ship {
	private uint onboard = 0;
	private immutable uint capacity;
	private immutable uint mF;

	this(uint sciencel, uint energyl, uint mF){
		capacity = 1000 * (sciencel + energyl);
		this.mF = mF;
	}
	public int addUnits(out uint units) {
		onboard = min(capacity, units);
		return units - onboard;
	}

	public void attack(Planet p){

	}

	public bool empty(){
		return (onboard == 0);
	}

	unittest{

	}
}