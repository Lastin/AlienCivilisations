module main;

import std.stdio;
import derelict.opengl3.gl3;
import derelict.sdl2.sdl;

void main(string[] args) {
	const int SCREEN_WIDTH = 640;
	const int SCREEN_HEIGHT = 480;
	SDL_Window* window = null;
	
	//The surface contained by the window
	SDL_Surface* screenSurface = null;
	writeln("1");
	//Initialize SDL
	if( SDL_Init( SDL_INIT_VIDEO ) < 0 )
	{
		writeln("2");
		writef( "SDL could not initialize! SDL_Error: %s\n", SDL_GetError() );
	}
	else
	{
		writeln("3");
		//Create window
		window = SDL_CreateWindow( "SDL Tutorial", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, SCREEN_WIDTH, SCREEN_HEIGHT, SDL_WINDOW_SHOWN );
		if( window == null)
		{
			writeln("4");
			printf( "Window could not be created! SDL_Error: %s\n", SDL_GetError() );
		}
		else
		{
			writeln("5");
			//Get window surface
			screenSurface = SDL_GetWindowSurface( window );
			
			//Fill the surface white
			SDL_FillRect( screenSurface, null, SDL_MapRGB( screenSurface.format, 0xFF, 0xFF, 0xFF ) );
			
			//Update the surface
			SDL_UpdateWindowSurface( window );
			
			//Wait two seconds
			SDL_Delay( 2000 );
		}
	}
	return;
}

/*
 * Linker imports: -lDerelictUtil -lDerelictSDL2 -lDerelictGL3 -ldl
 * 
 */