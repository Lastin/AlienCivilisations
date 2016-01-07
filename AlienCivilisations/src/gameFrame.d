﻿module src.gameFrame;

import std.stdio;
import src.states.menu;
import dlangui;
import src.entities.map;
import src.states.play;

class GameFrame : AppFrame {
	FrameLayout fl;
	VerticalLayout console;

	this(){
		super();
		fl = new FrameLayout();
		layoutHeight = FILL_PARENT;
		fl.layoutHeight = FILL_PARENT;
		//console = initialiseConsole();
		//fl.addChild(console);
		addChild(fl);
		keyEvent = delegate (Widget source, KeyEvent event) => showConsole(source, event);
	}

	private VerticalLayout initialiseConsole(){
		VerticalLayout console = new VerticalLayout();
		console.backgroundColor(0x80173636);
		console.textColor("#ffffff");
		EditBox c_output = new EditBox("c_output", ">Alien Civilisations console<"d);
		c_output.showLineNumbers(true);
		c_output.enabled = false;
		EditLine c_input = new EditLine("c_input", ""d);
		console.addChild(c_output);
		console.addChild(c_input);
		console.visibility = Visibility.Invisible;
		c_input.keyEvent = delegate (Widget source, KeyEvent event) => handleKeyInput(source, event);
		return console;
	}

	private bool showConsole(Widget source, KeyEvent event){
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

	bool handleKeyInput(Widget source, KeyEvent event){
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
		else {
		}
		return false;
	}

	public void setState(Widget widget){
		fl.removeAllChildren();
		fl.addChild(widget);
		console = initialiseConsole();
		fl.addChild(console);
	}
}