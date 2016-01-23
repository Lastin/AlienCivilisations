module src.main;

import dlangui;
import std.stdio;
import src.screens.menu;
import src.screens.play;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
	embeddedResourceList.addResources(embedResourcesFromList!("menu_resources.list")());
	int width = 1920;
	int height = 1080;
	Window window = Platform.instance.createWindow("Alien Civilisations", 
													null,
													WindowFlag.Resizable,
													width,
													height);
	window.mainWidget = new Menu();
	window.backgroundColor = 0;
	window.show();
	return Platform.instance.enterMessageLoop();
}