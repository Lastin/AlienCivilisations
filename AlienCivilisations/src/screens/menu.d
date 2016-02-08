module src.screens.menu;

import dlangui;
import std.stdio;
import src.screens.play;
import core.thread;
import src.handlers.jsonParser;
import std.file;
import std.path;
import std.algorithm;
import std.array;

class Menu : HorizontalLayout {
	this(Play play = null) {
		backgroundImageId = "background";
		setLayout();
		Rect padding = Rect(100, 15, 100, 15);
		Button exitButton;
		if(play) {
			Button contButton = new Button(null, "CONTINUE"d);
			Button saveButton = new Button(null, "SAVE"d);
			Button menuButton = new Button(null, "BACK TO MENU"d);
			contButton.padding(padding).margins(10).fontSize(20);
			saveButton.padding(padding).margins(10).fontSize(20);
			menuButton.padding(padding).margins(10).fontSize(20);
			childById("vl1").childById("hl1").childById("vr1").addChild(contButton);
			childById("vl1").childById("hl1").childById("vr1").addChild(saveButton);
			childById("vl1").childById("hl1").childById("vr1").addChild(menuButton);
			contButton.click = delegate (Widget source) {
				window.mainWidget = play;
				return true;
			};
			menuButton.click = delegate (Widget source) {
				window.mainWidget = new Menu();
				return true;
			};
			saveButton.click = delegate (Widget source) {
				contButton.visibility(Visibility.Gone);
				saveButton.visibility(Visibility.Gone);
				menuButton.visibility(Visibility.Gone);
				return true;
			};
		} else {
			Button playButton = new Button(null, "START GAME"d);
			Button loadButton = new Button(null, "LOAD"d);
			playButton.padding(padding).margins(10).fontSize(20);
			loadButton.padding(padding).margins(10).fontSize(20);
			playButton.click = delegate (Widget source) {
				//Thread play = new Thread(&loadPlay).start();
				//nplay.initialiseObjects();
				window.mainWidget = new Play();
				return true;
			};
			childById("vl1").childById("hl1").childById("vr1").addChild(playButton);
			childById("vl1").childById("hl1").childById("vr1").addChild(loadButton);
		}
		exitButton = new Button(null, "EXIT"d);
		exitButton.padding(padding).margins(10).fontSize(20);
		exitButton.click = delegate (Widget source) {
			window.close();
			return true;
		};
		childById("vl1").childById("hl1").childById("vr1").addChild(exitButton);
		childById("vl1").childById("hl1").childById("vr1").addChild(new VSpacer());
		//testing
		readSlots();
	}

	private void setLayout() {
		layoutWidth(FILL_PARENT);
		layoutHeight(FILL_PARENT);
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
				VerticalLayout {
					id: "saveWidget"
					backgroundColor: 0x80969696
					margins: 20
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

	private void showSaveWidget(){
		Widget sw = childById("vl1").childById("saveWidget");
		ListWidget lw = new ListWidget();
		WidgetListAdapter wla = new WidgetListAdapter();
		lw.adapter = wla;
		sw.visibility(Visibility.Visible);
	}

	private File[] readSlots() {
		string saveLocation = expandTilde("~/Documents/ACSaves");
		if(!exists(saveLocation))
			mkdirRecurse(saveLocation);
		auto files = dirEntries(saveLocation, SpanMode.shallow).filter!(f => f.name.endsWith(".save"));
		File[] slots;
		foreach(f; files)
			writeln(f.name);
		return slots;
	}
}