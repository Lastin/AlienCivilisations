/**
This module hold the game state.

It stores the references to the:
 -map
 -players
 -queue position

It is initialised by the GameManager class
It is used throughout the gameplay, ai decision making and saving of the state into JSON

Author: Maksym Makuch
 **/

module src.containers.gameState;

import src.containers.point2d;
import src.entities.map;
import src.entities.planet;
import src.entities.player;
import src.entities.ship;
import src.logic.ai;
import std.stdio;

/** Enum used to pass the type of the player(s) **/
enum PlayerEnum : ubyte {
	None,
	Human,
	AI,
	Both
}
/** Class contains current or hypothetical game state **/
class GameState {
	private {
		Map _map;
		Player[] _players;
		size_t _queuePosition;
		int _turnCount = 0;
	}
	
	this(Map map, Player[] players, size_t queuePosition) {
		_map = map;
		_players = players;
		_queuePosition = queuePosition;
	}
	/** Returns the map **/
	@property Map map() {
		return _map;
	}
	/** Returns all players **/
	@property Player[] players() {
		return _players;
	}
	/** Returns player in control (this turn) **/
	@property Player currentPlayer() {
		return _players[_queuePosition];
	}
	/** Returns player not in control (this turn) **/
	@property Player notCurrentPlayer() {
		return _players[(_queuePosition+1) % _players.length];
	}
	/** Returns unique identifier of player in control (this turn) **/
	@property int currentPlayerId() {
		return currentPlayer.uniqueId;
	}
	/** Returns enum of player in control (this turn) **/
	@property int currentPlayerEnum() {
		if(cast(AI)currentPlayer)
			return PlayerEnum.AI;
		return PlayerEnum.Human;
	}
	/** Returns human player **/
	@property Player human(){
		return _players[0];
	}
	/** Returns artificial player **/
	@property AI ai(){
		return cast(AI)_players[1];
	}
	/** Returns queue position **/
	@property size_t queuePosition() const {
		return _queuePosition;
	}
	/** Returns enum of which player is dead (this turn) **/
	@property PlayerEnum deadPlayer() {
		bool humanDead = human.dead(_map);
		bool aiDead = ai.dead(_map);
		if(!aiDead && !humanDead)
			return PlayerEnum.None;
		if(humanDead && !aiDead)
			return PlayerEnum.Human;
		if(aiDead && !humanDead)
			return PlayerEnum.AI;
		return PlayerEnum.Both;
	}
	/** Moves queue position to next available position **/
	void moveQPosition() {
		_queuePosition = ++_queuePosition % _players.length;
	}
	/** Completes turn of current player and moves queue position **/
	void shift() {
		currentPlayer.completeTurn(_map.planets);
		moveQPosition();
	}
	/** Returns duplicate of this state **/
	GameState dup() const  {
		Player[] playersDup = duplicatePlayers();
		Planet[] planetsDup = _map.duplicatePlanets(playersDup);//duplicatePlanets(playersDup);
		//duplicate map
		Map mapDup = new Map(_map.size, planetsDup);
		return new GameState(mapDup, playersDup, _queuePosition);
	}
	/** Returns duplicates of all players, with respect to their types**/
	private Player[] duplicatePlayers() const {
		Player[] duplicates;
		foreach(const Player origin; _players) {
			if(AI ai = cast(AI)origin){
				duplicates ~= new AI(origin.uniqueId, origin.knowledgeTree.dup, origin.ships);
			} else {
				duplicates ~= new Player(origin.uniqueId, origin.name, origin.knowledgeTree.dup, origin.ships);
			}
		}
		return duplicates;
	}
}