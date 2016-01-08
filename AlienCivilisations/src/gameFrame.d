module src.gameFrame;

import std.stdio;
import src.states.menu;
import dlangui;
import src.entities.map;
import src.states.play;

class GameFrame : AppFrame {
	FrameLayout fl;
	VerticalLayout console;
	Widget currentState;
	Menu menu;

	this(){
		super();
		fl = new FrameLayout();
		layoutHeight = FILL_PARENT;
		fl.layoutHeight = FILL_PARENT;
		console = initialiseConsole();
		addChild(fl);
		keyEvent = delegate (Widget source, KeyEvent event) => handleKeyInput(source, event);
	}

	private VerticalLayout initialiseConsole(){
		VerticalLayout console = new VerticalLayout("console");
		console.backgroundColor(0x80173636);
		console.textColor("#ffffff");
		EditBox c_output = new EditBox("c_output", ">Alien Civilisations console<"d);
		c_output.showLineNumbers(true);
		c_output.enabled = false;
		c_output.layoutWeight = FILL_PARENT;
		EditLine c_input = new EditLine("c_input", ""d);
		console.addChild(c_output);
		console.addChild(c_input);
		console.visibility = Visibility.Invisible;
		c_input.keyEvent = delegate (Widget source, KeyEvent event) => handleKeyInput(source, event);
		return console;
	}

	bool handleKeyInput(Widget source, KeyEvent event){
		if(event.keyCode == KeyCode.F4 && event.action == KeyAction.KeyDown){
			if(console.visible){
				console.visibility = Visibility.Invisible;
			}
			else {
				console.visibility = Visibility.Visible;
			}
			return true;
		}
		if(console.visible){
			if(event.keyCode == KeyCode.RETURN && event.action == KeyAction.KeyDown){
				auto c_output = console.childById("c_output");
				auto c_input = console.childById("c_input");
				dstring command = c_input.text;
				if(command.length > 0){
					c_output.text = c_output.text ~ "\n" ~ c_input.text;
					c_input.text = "";
				}

			}
			if(event.keyCode == KeyCode.ESCAPE && event.action == KeyAction.KeyDown){
				console.visibility = Visibility.Invisible;
			}
			return true;
		}
		return currentState.onKeyEvent(event);
	}

	public Widget setState(Widget widget){
		currentState = widget;
		fl.removeAllChildren();
		fl.addChild(widget);
		console = initialiseConsole();
		fl.addChild(console);
		return widget;
	}

	public void showPauseMenu(){

	}
}