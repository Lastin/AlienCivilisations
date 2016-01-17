module src.handlers.commandParser;

import dlangui;
import src.entities.branch;
import src.entities.player;
import src.states.play;
import std.array;
import std.conv;
import std.stdio;
import std.string;

class CommandParser : VerticalLayout
{
	private
	{
		auto _commands =
		[
			"commands",
			"players",
			"stats player_id",
			"addPoints player_id branch leaf amount"
		];
		Play _play;
		EditLine input = new EditLine();
		EditBox output = new EditBox();
	}

	this(Play play)
	{
		super("commandParser");
		_play = play;
		keyEvent.connect(delegate (Widget source, KeyEvent event) => handleKeyInput(source, event));
	}

	bool handleKeyInput(Widget source, KeyEvent event)
	{
		if(event.action == KeyAction.KeyDown)
		{
			if(event.keyCode == KeyCode.RETURN)
			{
				auto command = input.text;
				if(command.length < 1)
				{
					input.text = "";
					dstring result = "";
					foreach(string line; runCommand(command))
					{
						result ~= line ~ "\n";
					}
					output.text = format("%s\n%s\n%s", output.text, command, result);
				}
			}
		}
		return true;
	}

	string[] runCommand(dstring raw)
	{
		string[] message;
		try
		{
			auto commandParts = raw.split(" ");
			string command = commandParts[0];
			if(command == "commands")
				return _commands;
			if(command == "players")
			{
				foreach(int i, Player p; _play.players)
				{
					message ~= format("[%s]: %s", i, p.name);
				}
			}
			else if(command == "stats")
			{
				int id = to!int(commandParts[1]);
				Player player = _play.players[id];
				message ~= player.knowledgeTree.toString;
			}
			else if(command == "addPoints")
			{
				if(commandParts.length < 5)
				{
					throw new Exception("Insufficient parameters");
				}
				int id = to!int(commandParts[1]);
				Player player = _play.players[id];
				Branch branch = player.knowledgeTree.branch(commandParts[2]);
				int leaf = to!int(commandParts[3]);
				if(leaf < 0 || leaf > 5)
				{
					throw new Exception("Leaf out of bounds value: " ~ to!string(leaf));
				}
				int points = to!int(commandParts[4]);
				branch.addPoints(points, leaf);
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

