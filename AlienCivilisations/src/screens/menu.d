module src.screens.menu;

import dlangui;
import std.stdio;
import src.screens.play;
import core.thread;

class Menu : HorizontalLayout {
	this() {
		layoutWidth = FILL_PARENT;
		layoutHeight = FILL_PARENT;
		alignment = Align.Center;
		auto layout =
		q{
			VerticalLayout {
				id: vl1
				alignment: center
				layoutHeight: fill
				VSpacer {}
				TextWidget {
					text: "Alien Civilisations"
					textColor: "white"
					fontSize: 400%
					fontWeight: 800
					padding: 40
				}
				HorizontalLayout {
					id: hl1
					alignment: center
					layoutWidth: fill
					HSpacer {}
					VerticalLayout {
						id: vr1
						margins: 10
						Button {
							id: newGameButton
							text: "NEW GAME"
							padding: Rect { 100 10 100 10 }
							margins: 10
						}
						Button { 
							id: loadButton
							text: "LOAD SAVE"
							padding: 10
							margins: 10
						}
						Button { 
							id: exitButton
							text: "EXIT"
							padding: 10
							margins: 10
						}
						VSpacer {}
					}
					HSpacer {}
				}
				VSpacer {}
			}
		};
		addChild(new HSpacer());
		addChild(parseML(layout));
		addChild(new HSpacer());
		backgroundImageId = "background";
		auto play = childById("vl1").childById("hl1").childById("newGameButton");
		auto load = childById("vl1").childById("hl1").childById("loadButton");
		auto exit = childById("vl1").childById("hl1").childById("exitButton");
		play.click = delegate (Widget source) {
			Thread play = new Thread(&loadPlay).start();
			//loadPlay();
			return true;
		};
		exit.click = delegate (Widget source) {
			window.close();
			return true;
		};
	}

	this(Play play){
		Button continueButton = new Button(null, "Continue");
		continueButton.padding(10).margins(10);
		Button saveButton = new Button(null, "Save");
		saveButton.padding(10).margins(10);
		Widget container = childById("vl1").childById("hl1").childById("vr1");
		container.addChild(continueButton);
		container.addChild(saveButton);
	}

	void loadPlay(){
		synchronized {
			embeddedResourceList.addResources(embedResourcesFromList!("play_resources.list")());
		}
		window.mainWidget = new Play();
		super.destroy();
	}

	void writeSomething(){
		writeln("works");
	}
}