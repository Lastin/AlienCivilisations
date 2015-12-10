module src.graphics.window;

import core.thread;
import std.stdio;
import std.exception;
import derelict.opengl3.gl3;
import derelict.opengl3.gl;
import derelict.glfw3.glfw3;
import src.handlers.gameManager;

class Window {
	private GLFWmonitor* primaryMonitor;
	private const GLFWvidmode* mode;
	private GLFWwindow* window;
	private int width;
	private int height;
	private static GameManager gm;

	shared static this(){
		DerelictGL.load();
		DerelictGL3.load();
		DerelictGLFW3.load();
	}

	this(int width, int height) {
		//super(&run);
		this.width = width;
		this.height = height;
		//
		enforce(glfwInit());
		//create context
		primaryMonitor = glfwGetPrimaryMonitor();
		mode = glfwGetVideoMode(primaryMonitor);
		window = glfwCreateWindow(width, height, "Alien Civilisations v0.001", null, null);
		//set listeners
		glfwSetErrorCallback(&error_callback);
		glfwSetKeyCallback(window, &key_callback);
		glfwSetMouseButtonCallback(window, &mouse_callback);
		glfwSetCharCallback(window, &character_callback);
		//
		gm = new GameManager();
		run();
	}

	private void run(){
		//check if window was created before
		if(!window){
			glfwTerminate();
			return;
		}
		//set context
		glfwMakeContextCurrent(window);
		glfwSwapInterval(1);
		glfwWindowHint(GLFW_REFRESH_RATE, mode.refreshRate);
		//drawing loop
		while(!glfwWindowShouldClose(window)){
			float ratio;
			glfwGetFramebufferSize(window, &width, &height);
			ratio = width / height;
			glViewport(0, 0, width, height);
			glClear(GL_COLOR_BUFFER_BIT);
			glMatrixMode(GL_MODELVIEW);
			glLoadIdentity();
			glOrtho(-ratio, ratio, -1.0f, 1.0f, 1.0f, -1.0f);
			glMatrixMode(GL_PROJECTION_MATRIX);
			glLoadIdentity();
			glRotatef(glfwGetTime() * 50.0f, 0.0f, 0.0f, 1.0f);
			glBegin(GL_TRIANGLES);
			glColor3f(1.0f, 0.0f, 0.0f);
			glVertex3f(-0.6f, -0.4f, 0.0f);
			glColor3f(0.0f, 1.0f, 0.0f);
			glVertex3f(0.6f, -0.4f, 0.0f);
			glColor3f(0.0f, 0.0f, 1.0f);
			glVertex3f(0.0f, 0.6f, 0.0f);
			glEnd();
			glfwSwapBuffers(window);
			glfwPollEvents();
		}
		glfwDestroyWindow(window);
		glfwTerminate();
		DerelictGL3.unload();
	}

	extern(C) static {
		void key_callback(GLFWwindow* window, int key, int scancode, int action, int mods) nothrow{
			try{
				this.gm.getState().defaultKeyCallback(key, action);
			}
			catch(Exception e){

			}

		}
		void character_callback(GLFWwindow* window, uint codepoints) nothrow {
			try{
				this.gm.getState().defaultCharCallback(codepoints);
			}
			catch(Exception e){
				
			}
		}
		void mouse_callback(GLFWwindow* window, int button, int action, int mods) nothrow {
			try{
				this.gm.getState().mouseInteract(window, button, action, mods);
			}
			catch(Exception e){
				
			}
		}
		void error_callback(int error, const(char)* description) nothrow {
			printf("%s %s", error, description);
		}
	}
}

