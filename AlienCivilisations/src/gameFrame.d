module src.gameFrame;

import dlangui;
import src.entities.map;
import src.states.menu;
import src.states.play;
import std.stdio;

class GameFrame : AppFrame {
	private FrameLayout _fl;
	private VerticalLayout _console;
	private Widget _currentState;

	this(){
		layoutHeight(FILL_PARENT).layoutWidth(FILL_PARENT);
		_fl = new FrameLayout();
		_fl.layoutHeight(FILL_PARENT).layoutWidth(FILL_PARENT);
		_console = initialiseConsole();
		addChild(_fl);
		keyEvent = delegate (Widget source, KeyEvent event) => handleKeyInput(source, event);
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
		if(event.keyCode == KeyCode.F4 && event.action == KeyAction.KeyDown){
			if(_console.visible){
				_console.visibility = Visibility.Invisible;
			}
			else {
				_console.visibility = Visibility.Visible;
			}
			return true;
		}
		if(_console.visible){
			if(event.keyCode == KeyCode.RETURN && event.action == KeyAction.KeyDown){
				auto c_output = _console.childById("c_output");
				auto c_input = _console.childById("c_input");
				auto command = c_input.text;
				if(command.length > 0){
					c_output.text = c_output.text ~ "\n" ~ c_input.text;
					c_input.text = "";
				}

			}
			if(event.keyCode == KeyCode.ESCAPE && event.action == KeyAction.KeyDown){
				_console.visibility = Visibility.Invisible;
			}
			return true;
		}
		return _currentState.onKeyEvent(event);
	}

	public Widget setState(Widget widget){
		_fl.removeChild(_currentState);
		_currentState = widget;
		_fl.addChild(widget);
		_fl.addChild(_console);
		needDraw();
		_fl.needDraw();
		return widget;
	}
}