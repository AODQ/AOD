module AOD.Console;

immutable(int) TYPE_NONE, /// No console
               TYPE_DEBUG_IN, /// AOD generated messages left in
               TYPE_DEBUG_OUT; /// AOD generated messaged left out

import AOD = AOD.AOD;
import AOD.Text : Text;
import AOD.Object : Object;
import Input = AOD.Input;
import CV = AOD.ClientVars;
import derelict.opengl3.gl3;
import derelict.sdl2.sdl;
import std.string;

static class ConsEng {
  int console_type = 0;
  GLuint console_image = 0;
  Text console_text;
  Text input, input_after, input_sig;
  Object cursor, background;
  int console_input_cursor,
      console_input_select_len;
  string[] to_console;
  int console_history = 9;
  ubyte console_message_count;

  void Construct() {
    input = new Text(12, 100, "");
    input_after = new Text(10, 100, "");
    input_sig   = new Text(0, 100, ">>");
    input_sig.Set_Visible(0);
    cursor = new Object;
    cursor.Set_Image_Size(AOD::Vector(1, 10));
    cursor.Set_Visible(0);
    cursor.Set_Position(13, 96);
    background = new Object;
    background.Set_Image_Size(Vector(CV.screen_width, 103));
    background.Set_Visible(0);
    background.Set_Position(CV.screen_width/2, 103/2);
    Add(input);
    Add(input_after);
    Add(input_sig);
    Add(background, 50);
    Add(cursor, 50);
  }
  void Deconstruct() {
    console_text = [];
    AOD.Remove(input);
    AOD.Remove(input_after);
    AOD.Remove(cursor);
  }

  void Refresh() {
    if ( console_type == TYPE_DEBUG_IN || console_type == TYPE_DEBUG_OUT ) {
      if ( Input.keys[ key ] ) {
        console_open ^= 1;
        if ( console_open ) {
          for ( int i = 0; i != console_text.length; ++ i ) {
            console_text[i].Set_Visible(1);
            console_text[i].Set_To_Default();
          }
          input.Set_Visible(1);
          input_after.Set_Visible(1);
          input_sig.Set_Visible(1);
          cursor.Set_Visible(1);
          background.Set_Visible(1);
          SDL_StartTextInput();
        } else {
          input.Set_Visible(0);
          input_sig.Set_Visible(0);
          input_after.Set_Visible(0);
          cursor.Set_Visible(0);
          background.Set_Visible(0);
          SDL_StopTextInput();
        }
      }
      Input.keys[ key ] = 0;
      if ( console_open )
        for ( int i = console_text.size()-1; i != -1; -- i )
          console_text[i].Set_Position(3, 1 + (console_text.length - i)*10);
    }
    // push back new texts
    foreach ( i; to_console ) {
      auto txt = new AOD::Text(-20,-20,i);
      console_text = txt ~ console_text;
    }
    to_console = [];
    // pop back old debugs
    while ( console_text.size() > console_history ) {
      AOD.Remove(console_text[console_text.size()-1]);
      -- console_text.length;
    }
  }
}

bool console_open = 0;

void Set_Open_Console_Key(SDL_Keycode k) {
  ConsEng.key = k;
}

void Set_Console_History(int history_limit) {
  ConsEng.console_history = history_limit;
}

private void Out ( string o ) {
  ConsEng.to_console ~= o;
}

void Output(string ot) {
  Out(ot);
}

void Debug_Output(string ot) {
  if ( ConsEng.console_type == ConsEng.TYPE_DEBUG_IN )
    Out(ot);
}
