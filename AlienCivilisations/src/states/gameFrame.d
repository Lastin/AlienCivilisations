module src.states.gameFrame;

import std.stdio;
import src.states.menu;
import dlangui;

class GameFrame : AppFrame {
	FrameLayout fl;
	VerticalLayout console;
	Menu menu;
	this(){
		backgroundColor("#004d4d");
		fl = new FrameLayout();
		console = initialiseConsole();
		fl.addChild(console);
		addChild(fl);
		keyEvent = delegate (Widget source, KeyEvent event) => showConsole(source, event);
	}

	private VerticalLayout initialiseConsole(){
		VerticalLayout console = new VerticalLayout();
		console.backgroundColor("#173636");
		console.textColor("#ffffff");
		EditBox c_output = new EditBox("c_output", "asdas"d);
		c_output.showLineNumbers();
		c_output.layoutHeight = FILL_PARENT;
		c_output.enabled = false;
		EditLine c_input = new EditLine("c_input", "aaa"d);
		c_input.alignment = Align.Left | Align.Bottom;
		console.addChild(c_output);
		console.addChild(c_input);
		console.visibility = Visibility.Invisible;
		c_input.keyEvent = delegate (Widget source, KeyEvent event) => handleCommand(source, event);
		return console;
	}

	bool showConsole(Widget source, KeyEvent event){
		if(event.keyCode == KeyCode.F4 && event.action == KeyAction.KeyDown){
			if(console.visible){
				console.visibility = Visibility.Invisible;
			}
			else {
				console.visibility = Visibility.Visible;
			}
			return true;
		}
		return false;
	}

	bool handleCommand(Widget source, KeyEvent event){
		if(event.keyCode == KeyCode.RETURN && event.action == KeyAction.KeyDown){
			auto c_output = console.childById("c_output");
			auto c_input = console.childById("c_input");
			dstring command = c_input.text;
			if(command.length > 0){
				c_output.text = c_output.text ~ "\n" ~ c_input.text;
				c_input.text = "";
			}
			return true;
		}
		return false;
	}

	public void setState(Widget widget){
		//fl.removeAllChildren();
		fl.addChild(console);
		fl.addChild(widget);
	}
}