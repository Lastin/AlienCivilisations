module src.states.menu;

import dlangui;
import std.stdio;
import src.states.play;
import src.states.gameState;
import src.gameFrame;

class Menu : VerticalLayout
{
	this()
	{
		alignment(Align.Right | Align.Center);

	}
}