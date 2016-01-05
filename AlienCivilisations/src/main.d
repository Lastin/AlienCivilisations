module src.main;

import dlangui;
import src.states.menu;
import src.states.play;
import src.states.state;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args){
	Window window = Platform.instance.createWindow("Alien Civilisations", null, WindowFlag.Resizable, 1024, 768);
	auto btn = new Button();
	// change some properties
	btn.text = "Hello, world!"d;
	btn.margins = Rect(20,20,20,20);

	auto layout = parseML(q{
			VerticalLayout {
				margins: 20; padding: 10
				backgroundColor: "#FFFFE0"
				TextWidget { text: "Alien Civilisations" }
				Button {
					text: "Start new game"
				}
				Button { text: "Load save" }
				Button { text: "Exit" }
			}
		});
	window.mainWidget = layout;
	window.show();
	return Platform.instance.enterMessageLoop();
}