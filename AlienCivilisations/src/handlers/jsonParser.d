module src.handlers.jsonParser;

import std.json;
import std.file;
import std.stdio;
import src.entities.player;
import src.handlers.containers;
import src.entities.knowledgeTree;
import src.entities.branch;

class JsonParser {
	static bool saveState(GameState state) {
		JSONValue save = ["game" : "AlienCivilisations"];
		JSONValue[] players;
		foreach(player; state.players) {
			JSONValue p = ["name" : player.name];
			JSONValue[] branches;
			foreach(Branch branch; player.knowledgeTree.branches) {
				string branchName = branch.name;
				JSONValue points = JSONValue(branch.points);
				branches ~= JSONValue([branchName : points]);
			}

			JSONValue kt = ["branches" : ""];
			kt["branches"] = branches;// branches);
			p.object["knowledgeTree"] = kt;
			players ~= p;
		}
		save.object["players"] = JSONValue(players);
		writeln(save.toPrettyString());
		return true;
	}
}