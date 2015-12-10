module src.states.menu;

import std.stdio;
import derelict.glfw3.glfw3;
import src.states.state;

class Menu : State{
	public void render(){

	}
	public void interact(GLFWwindow* window, int key, int scancode, int action, int mods){
		writeln("state menu");
		return;
	}
}