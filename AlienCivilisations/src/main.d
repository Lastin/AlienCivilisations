module src.main;

import dlangui;
import std.stdio;
import src.screens.menu;
import src.screens.play;
import src.handlers.viewHanlder;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
	embeddedResourceList.addResources(embedResourcesFromList!("menu_resources.list")());
	embeddedResourceList.addResources(embedResourcesFromList!("play_resources.list")());
	int width = 1920;
	int height = 1080;
	Window window = Platform.instance.createWindow("Alien Civilisations", 
													null,
													WindowFlag.Resizable,
													width,
													height);
	ViewHandler vh = new ViewHandler(window);
	vh.setMainMenu();
	window.onClose = delegate () {
		vh.destroy();
	};
	window.backgroundColor = 0;
	window.show();
	return Platform.instance.enterMessageLoop();
}