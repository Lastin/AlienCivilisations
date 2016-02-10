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
import src.handlers.viewHanlder;
import std.format;
import std.json;

enum MenuView : ubyte {
	Main,
	Pause
}

class Menu : HorizontalLayout {
	private {
		ViewHandler _vh;
		Widget _btnsContainer;
		Widget _saveWidget;
		Button _newBtn;
		Button _loadBtn;
		Button _contBtn;
		Button _saveBtn;
		Button _menuBtn;
		Button _exitBtn;
	}
	this(ViewHandler vh) {
		_vh = vh;
		backgroundImageId = "background";
		setLayout();
		//Fetch objects from layout
		_btnsContainer = childById("vl1").childById("hl1").childById("btnsContainer");
		_saveWidget = childById("vl1").childById("saveWidget");
		_saveWidget.visibility(Visibility.Gone);
		_newBtn = cast(Button)_btnsContainer.childById("newBtn");
		_loadBtn = cast(Button)_btnsContainer.childById("loadBtn");
		_contBtn = cast(Button)_btnsContainer.childById("contBtn");
		_saveBtn = cast(Button)_btnsContainer.childById("saveBtn");
		_menuBtn = cast(Button)_btnsContainer.childById("menuBtn");
		_exitBtn = cast(Button)_btnsContainer.childById("exitBtn");
		//Set button actions
		_newBtn.click = delegate (Widget source) {
			vh.setNewPlay();
			return true;
		};
		_loadBtn.click = delegate (Widget source) {
			showSaveWidget();
			return true;
		};
		_contBtn.click = delegate (Widget source) {
			vh.setPlay();
			return true;
		};
		_saveBtn.click = delegate (Widget source) {
			showSaveWidget(true);
			return true;
		};
		_menuBtn.click = delegate (Widget source) {
			switchMenuView(MenuView.Main);
			return true;
		};
		_exitBtn.click = delegate (Widget source) {
			window.close();
			return true;
		};
		switchMenuView(MenuView.Main);
	}
	~this(){
		_saveWidget.destroy();
		super.destroy();
	}
	/** Changes the visibility of buttons based on the desired look of menu **/
	void switchMenuView(MenuView view) {
		if(view == MenuView.Main){
			_newBtn.visibility(Visibility.Visible);
			_loadBtn.visibility(Visibility.Visible);
			_contBtn.visibility(Visibility.Gone);
			_saveBtn.visibility(Visibility.Gone);
			_menuBtn.visibility(Visibility.Gone);
		} else {
			_newBtn.visibility(Visibility.Gone);
			_loadBtn.visibility(Visibility.Gone);
			_contBtn.visibility(Visibility.Visible);
			_saveBtn.visibility(Visibility.Visible);
			_menuBtn.visibility(Visibility.Visible);
		}
	}
	/** Sets the layout of the main widget in window to menu **/
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
					fontSize: 400%
					fontWeight: 800
					padding: 40
				}
				VerticalLayout {
					id: "saveWidget"
					backgroundColor: 0x80969696
					margins: 20
					ListWidget {
						id: "slotsList"
					}
					HorizontalLayout {
						layoutWidth: fill
						Button {
							id: loadSlot
							text: "Load save"
						}
						HSpacer {}
						Button {
							id: deleteSlot
							text: "Delete save"
						}
						HSpacer {}
						Button {
							id: saveToSlot
							text: "Write to slot"
						}
						Button {
							id: saveLoadCancel
							text: "Cancel"
						}
					}
				}
				HorizontalLayout {
					id: hl1
					alignment: center
					layoutWidth: fill
					HSpacer {}
					VerticalLayout {
						id: btnsContainer
						Button {
							id: newBtn
							text: "NEW GAME"
							margins: 10
							fontSize: 150%
							padding: Rect {100, 15, 100, 15}
						}
						Button {
							id: loadBtn
							text: "LOAD SAVE"
							margins: 10
							fontSize: 150%
							padding: Rect {100, 15, 100, 15}
						}
						Button {
							id: contBtn
							text: "CONTINUE"
							margins: 10
							fontSize: 150%
							padding: Rect {100, 15, 100, 15}
						}
						Button {
							id: saveBtn
							text: "SAVE"
							margins: 10
							fontSize: 150%
							padding: Rect {100, 15, 100, 15}
						}
						Button {
							id: menuBtn
							text: "MAIN MENU"
							margins: 10
							fontSize: 150%
							padding: Rect {100, 15, 100, 15}
						}
						Button {
							id: exitBtn
							text: "EXIT GAME"
							margins: 10
							fontSize: 150%
							padding: Rect {100, 15, 100, 15}
						}
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
	/** Reads the save files and shows the widget to save/read files **/
	private void showSaveWidget(bool saving = false) {
		string saveLocation = expandTilde("~/Documents/ACSaves");
		Button loadSlot = cast(Button)_saveWidget.childById("loadSlot");
		Button deleteSlot = cast(Button)_saveWidget.childById("deleteSlot");
		Button saveToSlot = cast(Button)_saveWidget.childById("saveToSlot");
		Button saveLoadCancel = cast(Button)_saveWidget.childById("saveLoadCancel");
		loadSlot.visibility(Visibility.Invisible);
		deleteSlot.visibility(Visibility.Invisible);
		saveToSlot.visibility(Visibility.Invisible);
		_btnsContainer.visibility(Visibility.Gone);
		saveLoadCancel.click = delegate (Widget source) {
			_saveWidget.visibility(Visibility.Gone);
			_btnsContainer.visibility(Visibility.Visible);
			return true;
		};
		ListWidget lw = cast(ListWidget)_saveWidget.childById("slotsList");
		WidgetListAdapter wla = new WidgetListAdapter();
		lw.adapter = wla;
		int previousSelected = -1;
		bool[] usedSlots;
		lw.itemSelected  = delegate (Widget source, int itemIndex) {
			if(saving){
				saveToSlot.visibility(Visibility.Visible);
				saveToSlot.click = delegate (Widget source) {
					if(_vh.play){
						JSONValue json = JsonParser.parsePlay(_vh.play);
						std.file.write(saveLocation ~ format("/slot%s.acsave", itemIndex), json.toPrettyString());
						usedSlots[itemIndex] = true;
						wla.itemWidget(itemIndex).childById("details").text = to!dstring(json["date"].toString);
					}
					return true;
				};
			}
			if(previousSelected > -1){
				lw.itemWidget(previousSelected).backgroundColor(0x737373);
			}
			wla.itemWidget(itemIndex).backgroundColor(0x999999);
			if(usedSlots[itemIndex]) {
				loadSlot.visibility(Visibility.Visible);
				deleteSlot.visibility(Visibility.Visible);
				loadSlot.click = delegate (Widget source) {
					//TODO: load from file
					return true;
				};
				deleteSlot.click = delegate (Widget source) {
					//TODO: load from file
					return true;
				};
			} else {
				loadSlot.visibility(Visibility.Invisible);
				deleteSlot.visibility(Visibility.Invisible);
			}
			previousSelected = itemIndex;
			return true;
		};
		for(int i=0; i<15; i++){
			HorizontalLayout listElement = new HorizontalLayout();
			listElement.backgroundColor(0x737373);
			listElement.layoutWidth(FILL_PARENT);
			listElement.padding(2);
			listElement.margins(2);
			listElement.addChild(new TextWidget(null, to!dstring(format("Slot %s", i))).textColor(0xFFFFFF));
			listElement.addChild(new HSpacer());

			string fileName = format("/slot%s.acsave", i);
			if(exists(saveLocation ~ fileName)){
				try {
					auto slot = new File(saveLocation ~ fileName);
					JSONValue json = JsonParser.parseFile(slot);
					listElement.addChild(new TextWidget(null, to!dstring(json["date"].toString)).textColor(0xFFFFFF));
					usedSlots ~= true;
				} catch(JSONException exception) {
					debug writefln(exception.toString);
					listElement.addChild(new TextWidget(null, "Read error"d).textColor(0xFFFFFF));
				}
			} else {
				listElement.addChild(new TextWidget("details", "Empty"d).textColor(0xFFFFFF));
				usedSlots ~= false;
			}
			wla.add(listElement);
		}
		_saveWidget.visibility(Visibility.Visible);
	}
	private size_t slotIndex(string name, File[] slots) {
		foreach(i, slot; slots){
			if(slot.name == name)
				return i;
		}
		return -1;
	}
	/** Reads files from save directory **/
	/*private File[] readSlots() {
		string saveLocation = expandTilde("~/Documents/ACSaves");
		if(!exists(saveLocation))
			mkdirRecurse(saveLocation);
		auto files = dirEntries(saveLocation, SpanMode.shallow).filter!(f => f.name.endsWith(".acsave"));
		return files;
	}*/
}