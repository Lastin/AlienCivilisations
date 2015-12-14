module src.graphics.fontRenderer;

import derelict.freetype.ft;
import derelict.opengl3.gl3;
import derelict.opengl3.gl;
import std.stdio;

class FontRenderer {
	private FT_Library library;
	private FT_Face face;
	this(int h_dpi, int v_dpi, int font_size){
		auto error = FT_Init_FreeType(&library);
		if(error){}
		error = FT_New_Face(library, "/etc/alternatives/fonts-japanese-gothic.ttf", 0, &face);
		if(error == FT_Err_Unknown_File_Format){
			writeln("Unknown font file format");
		}
		else if(error){
			writeln("Font file not found");
		}
		error = FT_Set_Char_Size(
					face,  //handle to face obj
					0,	   //char width in 1/64th of points
					font_size*64, //char_height in 1/64th of points
					h_dpi,   //horizontal device resolution
					v_dpi  //vertical device resolution
				);
		error = FT_Select_Charmap(
				face,
				FT_ENCODING_UNICODE
				);
	}
	public void render_text(int x, int y, uint[] text){
		/*FT_GlyphSlot slot = face.glyph;
		for(int i; i<text.length; i++){
			auto glyph_index = FT_Get_Char_Index(face, text[i]);
			auto error = FT_Load_Glyph(face, glyph_index, FT_LOAD_DEFAULT);
			if(error) continue;
			error = FT_Render_Glyph(face.glyph, FT_RENDER_MODE_NORMAL);
			if(error) continue;
			draw_bitmap(&slot.bitmap, x + slot.bitmap_left, y + slot.bitmap_top);
			x += slot.advance.x >> 6;
		}*/
	}

	public void render_text2(const string str, float x, float y, float sx, float sy){
		glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
		const FT_GlyphSlot g = face.glyph;
		foreach(char c; str) {
			if(FT_Load_Char(face, c, FT_LOAD_RENDER))
				continue;
			glTexImage2D(GL_TEXTURE_2D, 0, GL_R8,
				g.bitmap.width, g.bitmap.rows,
				0, GL_RED, GL_UNSIGNED_BYTE, g.bitmap.buffer);
		}
		const float vx = x + g.bitmap_left * sx;
		const float vy = y + g.bitmap_top * sy;
		const float w = g.bitmap.width * sx;
		const float h = g.bitmap.rows * sy;
		
		GLvoid[6] data = [
			(vx    , vy    , 0, 0),
			(vx    , vy - h, 0, 1),
			(vx + w, vy    , 1, 0),
			(vx + w, vy    , 1, 0),
			(vx    , vy - h, 0, 1),
			(vx + w, vy - h, 1, 1)
		];
		glBufferData(GL_ARRAY_BUFFER, 24*float.sizeof, &data, GL_DYNAMIC_DRAW);
		glDrawArrays(GL_TRIANGLES, 0, 6);
		x += (g.advance.x << 6) * sx;
		y += (g.advance.y << 6) * sy;
		glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
	}

	public void draw_bitmap(FT_Bitmap* bitmap, int x, int y){
		/*glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
		const FT_GlyphSlot g = face.glyph;
		glBegin(GL_QUADS);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_R8,
			bitmap.width, bitmap.rows,
			0, GL_RED, GL_UNSIGNED_BYTE, bitmap.buffer);

		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glEnd();*/
	}
}