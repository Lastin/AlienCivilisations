module src.logic.hypotheticalWorld;

import src.entities.branch;
import src.entities.knowledgeTree;
import src.entities.map;
import src.entities.planet;
import src.entities.player;

class HypotheticalWorld {
	private Map _map;
	private Player[] _players;

	this(Map map, Player[] players){
		_map = map;
		_players = players;
	}
}

