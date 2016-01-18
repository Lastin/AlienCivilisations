﻿module src.states.menu;

import dlangui;
import std.stdio;

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
				layoutHeight: fill;
				VSpacer {}
				TextWidget {
					text: "Alien Civilisations"
					textColor: "white"
					fontSize: 400%
					fontWeight: 800
					fontFace: "Arial"
					padding: 40
				}
				HorizontalLayout {
					id: hl1
					alignment: center
					layoutWidth: fill
					HSpacer {}
					VerticalLayout {
					margins: 10
						Button {
							id: newGameButton
							text: "NEW GAME"
							padding: 10
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
			writeln("clicked");
			return true;
		};
		exit.click = delegate (Widget source) {
			window.close();
			return true;
		};
	}
}