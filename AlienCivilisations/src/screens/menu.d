﻿module src.screens.menu;

import dlangui;
import std.stdio;
import src.screens.play;
import core.thread;

class Menu : HorizontalLayout {
	this(Play play = null) {
		backgroundImageId = "background";
		setLayout();
		Rect padding = Rect(100, 15, 100, 15);
		if(play) {
			Button contButton = new Button(null, "CONTINUE"d);
			Button saveButton = new Button(null, "SAVE"d);
			Button menuButton = new Button(null, "BACK TO MENU"d);
			contButton.padding(padding).margins(10).fontSize(27);
			saveButton.padding(padding).margins(10).fontSize(27);
			menuButton.padding(padding).margins(10).fontSize(27);
			childById("vl1").childById("hl1").childById("vr1").addChild(contButton);
			childById("vl1").childById("hl1").childById("vr1").addChild(saveButton);
			childById("vl1").childById("hl1").childById("vr1").addChild(menuButton);
			contButton.click = delegate (Widget source) {
				window.mainWidget = play;
				super.destroy();
				return true;
			};
			menuButton.click = delegate (Widget source) {
				window.mainWidget = new Menu();
				return true;
			};
		} else {
			Button playButton = new Button(null, "START GAME"d);
			Button loadButton = new Button(null, "LOAD"d);
			playButton.padding(padding).margins(10).fontSize(27);
			loadButton.padding(padding).margins(10).fontSize(27);
			playButton.click = delegate (Widget source) {
				//Thread play = new Thread(&loadPlay).start();
				loadPlay();
				return true;
			};
			childById("vl1").childById("hl1").childById("vr1").addChild(playButton);
			childById("vl1").childById("hl1").childById("vr1").addChild(loadButton);
		}
		Button exitButton = new Button(null, "EXIT"d);
		exitButton.padding(padding).margins(10).fontSize(27);
		exitButton.click = delegate (Widget source) {
			window.close();
			return true;
		};
		childById("vl1").childById("hl1").childById("vr1").addChild(exitButton);
		childById("vl1").childById("hl1").childById("vr1").addChild(new VSpacer());
	}

	private void setLayout() {
		layoutWidth = FILL_PARENT;
		layoutHeight = FILL_PARENT;
		alignment = Align.Center;
		addChild(new HSpacer());
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
					fontSize: 500%
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
					}
					HSpacer {}
				}
				VSpacer {}
			}
		};
		addChild(parseML(layout));
		addChild(new HSpacer());
	}

	void loadPlay(){
		embeddedResourceList.addResources(embedResourcesFromList!("play_resources.list")());
		window.mainWidget = new Play();
	}

	void writeSomething(){
		writeln("works");
	}
}