module src.states.gameFrame;

import std.stdio;
import src.handlers.gameManager;
import src.states.menu;
import dlangui;

class GameFrame : AppFrame {
	GameManager gm;
	FrameLayout fl;
	this(GameManager gm){
		this.gm = gm;
		backgroundColor("#004d4d");
		fl = new FrameLayout();
		fl.addChild(new Menu(gm, false));
		auto console = new TextWidget("console", "asdas"d);
		console.setIntProperty("minWidth", 300);
		console.setIntProperty("minHeight", 300);
		console.backgroundColor("#173636");
		console.textColor("#ffffff");
		fl.addChild(console);
		fl.childById("console").visibility = Visibility.Invisible;
		addChild(fl);
	}
	override public bool onKeyEvent(KeyEvent event) {
		if(event.keyCode == KeyCode.F4 && event.action == KeyAction.KeyDown){
			auto console = fl.childById("console");
			if(console.visible){
				fl.childById("console").visibility = Visibility.Invisible;
			}
			else {
				fl.childById("console").visibility = Visibility.Visible;
			}
			return true;
		}

		return super.onKeyEvent(event);
	}
}