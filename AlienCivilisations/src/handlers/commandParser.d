module src.handlers.commandParser;
import std.stdio;
class CommandParser {
	immutable string[][string] commands;
	this() {
		File f = File("commands.dat", "r");
		writeln(f.byLine);
		commands = ["": [""]];
	}
}

