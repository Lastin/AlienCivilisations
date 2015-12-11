module src.states.state;

import std.stdio;
import std.range;
import std.conv;
import derelict.glfw3.glfw3;
import src.handlers.gameManager;

class State {
	GameManager gm;
	bool consoleEnabled = false;
	uint[] accChars;
	this(GameManager gm){
		this.gm = gm;
	}
	public abstract void keyInteract(GLFWwindow* window, int key, int scancode, int action, int mods);
	public abstract void mouseInteract(GLFWwindow* window, int button, int action, int mods);
	public abstract void render();
	public void defaultKeyCallback(int key, int action){
		if(key == GLFW_KEY_GRAVE_ACCENT && action == GLFW_PRESS){
			consoleEnabled = !consoleEnabled;
			writeln("console: ", (consoleEnabled ? "enabled" : "disabled"));
		}
		else if(consoleEnabled && action == GLFW_PRESS){
			if(key == GLFW_KEY_ENTER && accChars.length > 0){
				writeln();
				writeln("you wrote: ", cast(string)accChars);
				accChars.destroy();
			}
			else if(key == GLFW_KEY_BACKSPACE && accChars.length > 0){
				write(repeat('\b', accChars.length));
				accChars = accChars[0 .. $-1];
				write(cast(string)accChars, " \b");
				stdout.flush();
			}
			//else here call custom option for each state
		}
	}
	public void defaultCharCallback(uint codepoint){
		if(consoleEnabled && codepoint != GLFW_KEY_GRAVE_ACCENT){
			write(to!char(codepoint));
			stdout.flush();
			accChars ~= codepoint;
		}
	}
}

