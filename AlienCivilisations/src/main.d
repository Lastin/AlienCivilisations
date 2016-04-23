/**
This module is entry point for the program.

Author: Maksym Makuch
 **/

module src.main;

import dlangui;
import src.handlers.viewHanlder;
import src.screens.menu;
import src.screens.play;
import std.stdio;

mixin APP_ENTRY_POINT;

/** Main function **/
extern (C) int UIAppMain(string[] args) {
	embeddedResourceList.addResources(embedResourcesFromList!("menu_resources.list")());
	embeddedResourceList.addResources(embedResourcesFromList!("play_resources.list")());
	int width = 1920;
	int height = 1080;
	Window window = Platform.instance.createWindow("Alien Civilisations", 
													null,
													WindowFlag.Resizable,
													width, height);
	//Initialise view handler
	ViewHandler vh = new ViewHandler(window);
	//Set screen to main menu
	vh.setMainMenu();
	window.onClose = delegate () {
		releaseResourcesOnAppExit();
	};
	window.backgroundColor = 0;
	window.show();
	return Platform.instance.enterMessageLoop();
}