module src.main;

import dlangui;
import std.stdio;
import src.states.menu;
import src.states.play;
import src.gameFrame;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args){
	int width = 1024;
	int height = 768;
	Window window = Platform.instance.createWindow("Alien Civilisations", null, WindowFlag.Resizable, width, height);
	GameFrame gameframe = new GameFrame();
	gameframe.setState(new Menu(gameframe));
	window.mainWidget = gameframe;
	window.show();
	return Platform.instance.enterMessageLoop();
}