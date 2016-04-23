/**
This module implements the command parser.
It parsed strings into commands and parameters

It has was a temporary solution for testing without compelte GUI.

It is deprecated.

Author: Maksym Makuch
 **/

module src.handlers.commandParser;

import dlangui;
import src.containers.gameState;
import src.entities.branch;
import src.entities.player;
import src.handlers.gameManager;
import std.format;

deprecated class CommandParser : VerticalLayout {
	private {
		string[] _commands =
		[
			"commands",
			"players",
			"stats player_id",
			"addPoints player_id branch leaf amount"
		];
		GameState _currentState;
		EditLine input;
		EditBox output;
	}

	this(GameState currentState) {
		super("commandParser");
		_currentState = currentState;
		input = new EditLine();
		output = new EditBox();
		keyEvent.connect(delegate (Widget source, KeyEvent event) => handleKeyInput(source, event));
	}
	/** Overrides input function. Executes function with ENTER and prints result on custom widget **/
	bool handleKeyInput(Widget source, KeyEvent event) {
		if(event.action == KeyAction.KeyDown) {
			if(event.keyCode == KeyCode.RETURN) {
				auto command = input.text;
				if(command.length < 1) {
					input.text = "";
					string result = "";
					foreach(string line; runCommand(command))
					{
						result ~= line ~ "\n";
					}
					output.text = to!dstring(format("%s\n%s\n%s", output.text, command, result));
				}
			}
		}
		return true;
	}
	/** Takes string and parses it into command. Returns result **/
	string[] runCommand(dstring raw) {
		string[] message;
		try {
			auto commandParts = to!string(raw).split(" ");
			string command = commandParts[0];
			if(command == "commands")
				return _commands;
			if(command == "players") {
				foreach(int i, Player p; _currentState.players)
					message ~= format("[%s]: %s", i, p.name);
			}
			else if(command == "stats") {
				int id = to!int(commandParts[1]);
				Player player = _currentState.players[id];
				message ~= player.knowledgeTree.toString;
			}
			else if(command == "addPoints") {
				if(commandParts.length < 5)
					throw new Exception("Insufficient parameters");
				int id = to!int(commandParts[1]);
				Player player = _currentState.players[id];
				Branch branch = player.knowledgeTree.branch(commandParts[2]);
				int leaf = to!int(commandParts[3]);
				if(leaf < 0 || leaf > 5)
					throw new Exception("Leaf out of bounds value: " ~ to!string(leaf));
				int points = to!int(commandParts[4]);
				branch.addPoints(points);
				message ~=  format("Added %s points to player: %s", points, player.name);
			}
		}
		catch(Exception e)
			message ~= e.msg;
		catch(Error e)
			message ~= e.msg;
		return message;
	}
}

