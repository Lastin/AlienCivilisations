module entities.player;

import std.container.slist;
import entities.planet;

class Player {
	private SList!Planet planets;
	private string name;

	this(SList!Planet planets, string name){

	}
}