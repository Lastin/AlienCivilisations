module src.main;

public import dlangui;
public import std.stdio;
import src.states.menu;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
	embeddedResourceList.addResources(embedResourcesFromList!("resources.list")());
	int width = 1920;
	int height = 1080;
	Window window = Platform.instance.createWindow("Alien Civilisations", 
													null,
													WindowFlag.Resizable,
													width,
													height);

	window.mainWidget = new Menu();
	window.show();
	return Platform.instance.enterMessageLoop();
}