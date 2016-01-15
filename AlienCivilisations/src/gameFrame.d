module src.gameFrame;

import dlangui;
import src.entities.map;
import src.handlers.commandParser;
import src.states.menu;
import src.states.play;
import std.stdio;

class GameFrame : AppFrame {
	private FrameLayout _fl;
	private VerticalLayout _console;
	private Widget _currentState;
	private CommandParser _commandParser;

	this(){
		layoutHeight(FILL_PARENT).layoutWidth(FILL_PARENT);
		_fl = new FrameLayout();
		_fl.layoutHeight(FILL_PARENT).layoutWidth(FILL_PARENT);
		_console = initialiseConsole();
		_fl.addChild(_console);
		addChild(_fl);
		keyEvent = delegate (Widget source, KeyEvent event) => handleKeyInput(source, event);
		_commandParser = new CommandParser();
	}

	private VerticalLayout initialiseConsole(){
		VerticalLayout console = new VerticalLayout("console");
		console.backgroundColor(0x80173636);
		console.textColor("#ffffff");
		EditBox c_output = new EditBox("c_output", "Console"d);
		c_output.showLineNumbers(true);
		c_output.enabled(false);
		c_output.layoutWeight = FILL_PARENT;
		EditLine c_input = new EditLine("c_input", ""d);
		console.addChild(c_output);
		console.addChild(c_input);
		console.visibility = Visibility.Invisible;
		c_input.keyEvent = delegate (Widget source, KeyEvent event) => handleKeyInput(source, event);
		return console;
	}

	bool handleKeyInput(Widget source, KeyEvent event){
		if(event.action == KeyAction.KeyDown){
			if(event.keyCode == KeyCode.F4){
				writeln(_console ? "not null" : "null");
				if(_console.visible){
					_console.visibility = Visibility.Invisible;
				}
				else {
					_console.visibility = Visibility.Visible;
				}
				return true;
			}
			else if(_console.visible){
				auto c_output = _console.childById("c_output");
				auto c_input = _console.childById("c_input");
				if(event.keyCode == KeyCode.RETURN){
					auto command = c_input.text;
					if(command.length > 0){
						c_output.text = c_output.text ~ "\n" ~ c_input.text;
						c_input.text = "";
						auto answer = _commandParser.runCommand(to!string(command));
						foreach(string line; answer){
							c_output.text = c_output.text ~ "\n" ~ to!dstring(line);
						}
					}
				}
				else if(event.keyCode == KeyCode.BACK){
					if(c_input.text.length > 0){
						c_input.text = c_input.text[0..$-1];
					}
				}
				if(event.keyCode == KeyCode.ESCAPE && event.action){
					_console.visibility = Visibility.Invisible;
				}
				return true;
			}
		}
		return _currentState.onKeyEvent(event);
	}

	Widget setState(Widget widget){
		_fl.removeChild(_currentState);
		_fl.removeChild(_console);
		//_currentState.destroy;
		_currentState = widget;
		if(widget.id == "play"){
			_commandParser.setPlay(cast(Play)widget);
		}
		_fl.addChild(widget);
		_fl.addChild(_console);
		return widget;
	}
}