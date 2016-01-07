module src.main;

import dlangui;
import std.stdio;
import src.states.menu;
import src.states.play;
import src.states.gameFrame;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args){
	Window window = Platform.instance.createWindow("Alien Civilisations", null, WindowFlag.Resizable, 1024, 768);
	GameFrame gameframe = new GameFrame();
	gameframe.setState(new Menu(false, gameframe));
	window.mainWidget = gameframe;
	window.show();
	return Platform.instance.enterMessageLoop();
}