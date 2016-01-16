module src.handlers.gameManager;

import src.entities.map;
import src.entities.player;
import src.logic.hypotheticalWorld;
import src.entities.knowledgeTree;
import std.random;

class GameManager {
	//Constant values
	private immutable int _planetsCount = 16;
	private immutable int[][] _startPoints =
	[
		[0,0,0,0,0],
		[0,0,0,0,0],
		[0,0,0,0,0],
		[0,0,0,0,0],
		[0,0,0,0,0]
	];
	//
	private int _queuePosition;
	private Map _map;
	private Player[] _players;

	this(){
		initialisePlayers();
		initialiseMap();
		_queuePosition = uniform(0, _players.length);
	}
	
	void initialisePlayers(){
		_players ~= new Player("Human", new KnowledgeTree(_startPoints));
		_players ~= new AI(this);
	}

	void initialiseMap(){

	}

	HypotheticalWorld createDuplicate(){
		
	}


}

