module src.main;

public import dlangui;
public import std.stdio;
import src.states.menu;
import src.gameFrame;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args){
	int width = 1024;
	int height = 768;
	Window window = Platform.instance.createWindow("Alien Civilisations", null, WindowFlag.Resizable, width, height);
	GameFrame gameFrame = new GameFrame();
	gameFrame.setState(new Menu(gameFrame));
	window.mainWidget = gameFrame;
	window.show();
	return Platform.instance.enterMessageLoop();
}