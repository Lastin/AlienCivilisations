﻿module src.states.play;

import std.stdio;
import derelict.glfw3.glfw3;
import src.states.state;

class Play : State{
	public void render(){

	}
	public void interact(GLFWwindow* window, int key, int scancode, int action, int mods) {
		writeln("state play");
	}
}