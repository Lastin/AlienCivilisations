module main;

import std.stdio;
import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;

void main(string[] args) {
	DerelictGL3.load();
	DerelictGLFW3.load();
	//create context
	GLFWwindow* window;
	if(!glfwInit()){
		return;
	}
	window = glfwCreateWindow(640, 480, "Hello world", null, null);
	if(!window){
		glfwTerminate();
		return;
	}
	glfwMakeContextCurrent(window);
	DerelictGL3.reload();
	while(!glfwWindowShouldClose(window)){
		glfwSwapBuffers(window);
		glfwPollEvents();
	}
	glfwTerminate();
}

/*
 * Linker imports: -lDerelictUtil -lDerelictSDL2 -lDerelictGL3 -ldl
 * 
 */