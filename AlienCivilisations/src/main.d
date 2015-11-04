module main;

import std.stdio;
import derelict.opengl3.gl3;

void main(string[] args) {
	DerelictGL3.load();
	readln();
	writeln("test");
}

/*
 * Linker imports: -lDerelictUtil -lDerelictSDL2 -lDerelictGL3 -ldl
 * 
 */