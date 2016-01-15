module src.handlers.commandParser;

import std.stdio;
import std.array;
import std.string;
import src.states.play;
import src.entities.player;
import std.conv;
import src.entities.branch;

class CommandParser {
	private Play _play;
	private string[] _commands = [
		"commands",
		"players",
		"stats player_id",
		"addPoints player_id branch leaf amount"
	];
	this() {
	}

	void setPlay(Play play){
		_play = play;
	}

	string[] runCommand(string raw){
		string[] message;
		try {
			auto commandParts = raw.split(" ");
			string command = commandParts[0];
			if(command == "commands"){
				return _commands;
			}
			if(!_play){
				return ["play not initialised"];
			}
			else if(command == "players"){
				foreach(int i, Player p; _play.players){
					message ~= format("[%s]: %s", i, p.name);
				}
			}
			else if(command == "stats"){
				int id = to!int(commandParts[1]);
				Player player = _play.players[id];
				message ~= player.knowledgeTree.toString;
			}
			else if(command == "addPoints"){
				if(commandParts.length < 5){
					throw new Exception("Insufficient parameters");
				}
				int id = to!int(commandParts[1]);
				Player player = _play.players[id];
				Branch branch = player.knowledgeTree.branch(commandParts[2]);
				int leaf = to!int(commandParts[3]);
				if(leaf < 0 || leaf > 5){
					throw new Exception("Leaf out of bounds value: " ~ to!string(leaf));
				}
				int points = to!int(commandParts[4]);
				branch.addPoints(points, leaf);
				message ~=  format("Added %s points to player: %s", points, player.name);
			}
		}
		catch(Exception e){
			return message ~ e.msg;
		}
		catch(Error e){
			return message ~ e.msg;
		}
		return message;
	}
}

