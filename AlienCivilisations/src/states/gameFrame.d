module src.states.gameFrame;

import std.stdio;
import src.handlers.gameManager;
import src.states.menu;
import dlangui;

class GameFrame : AppFrame {
	GameManager gm;
	FrameLayout fl;
	VerticalLayout console;
	this(GameManager gm){
		this.gm = gm;
		backgroundColor("#004d4d");
		fl = new FrameLayout();
		fl.addChild(new Menu(gm, false));
		initialiseConsole();
		addChild(fl);
		keyEvent = delegate (Widget source, KeyEvent event) => showConsole(source, event);
	}

	private void initialiseConsole(){
		console = new VerticalLayout();
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
		fl.addChild(console);
		c_input.keyEvent = delegate (Widget source, KeyEvent event) => handleCommand(source, event);
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
}