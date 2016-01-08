module src.entities.ship;

import src.entities.planet;
import src.entities.player;
import std.algorithm;

class Ship {
	private uint onboard = 0;
	private immutable uint capacity;
	private immutable uint military_level;
	private Player ship_owner;

	this(Player ship_owner, uint sciencel, uint energyl, uint military_level){
		this.ship_owner = ship_owner;
		capacity = 1000 * (sciencel + energyl);
		this.military_level = military_level;
	}
	public int addUnits(uint units) {
		uint free_spaces = capacity - onboard;
		if(free_spaces >= units){
			onboard += units;
			return 0;
		}
		onboard = capacity;
		return units - free_spaces;
	}

	public void attack(Planet p){
		if(p.getOwner && p.getOwner != ship_owner){
			p.attack(military_level * onboard);
		}
	}

	public bool empty(){
		return (onboard == 0);
	}

	unittest{

	}
}