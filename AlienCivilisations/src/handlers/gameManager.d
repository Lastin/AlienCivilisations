module handlers.gameManager;

import handlers.map;
import entities.player;

class GameManager {
	private Map map;
	private Player[] players = new Player[2];

	this(Map map){
		this.map = map;
	}

	public Map getMap(){
		return map;
	}

}