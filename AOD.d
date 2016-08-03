import derelict.opengl3.gl3;
import derelict.sdl2.sdl;
import std.string;

module AOD.AOD;

import Camera  = AOD.Camera;
import Console = AOD.Console;
import Input   = AOD.Input;
import Object  = AOD.Object;
import Realm   = AOD.Realm;
import Sounds  = AOD.Sounds;
import Text    = AOD.Text;
import AOD.Vector;
import AOD.Utility;

SDL_Window* screen = null;
GLuint[] images;

Realm* realm = null;

uint ms_dt = 0;

bool started = 0;
int start_ticks = 0;
AOD::Text* fps_display = null;
float[20] fps = { 0 };

void Initialize(int window_width, int window_height, uint fps,
                char[] window_name, char[] icon = "") {
  if ( realm == null ) {
    if ( window_name == "" )
      window_name = "Art of Dwarficorn";
    realm = new Realm(window_width, window_height, window_name, icon);
    ms_dt = fps;
  }
  Camera::Set_Position(Vector(0, 0));
  Camera::Set_Size(Vector(cast(float)window_width, cast(float)window_height));
}

void Initialize_Console(bool debug, SDL_Keycode key, string cons) {
  if ( debug )
    Console::console_type = AOD::Console::TYPE_DEBUG_IN;
  else
    Console::console_type = AOD::Console::TYPE_DEBUG_OUT;
  Debug_Output("Created new console");
  Console::key = key;
  Console::Construct();
}

void Change_MSDT(Uint32 x) {
  if ( x > 0 )
    ms_dt = x;
  else
    Debug_Output("Trying to change the MS DeltaTime to a value <= 0");
}

void Reset() {
  if ( realm != null )
    realm->Reset();
}
void End() {
  if ( realm != null )
    realm->~Realm();
  SDL_DestroyWindow(screen);
  SDL_Quit();
}

Object[int] obj_list;

import core.sync.mutex;

private auto add_obj_mutex = new Mutex;

int Add(AOD::Object o,int layer) {
  add_obj_mutex.lock();
  static uint id_counter = 0;
  if ( realm != null && o && layer >= 0 ) {
    realm.__Add(o, layer);
    o.Set_ID(id_counter++);
    obj_list[o.Ret_ID(), o);
    return o.Ret_ID();
  } else {
    if ( o == null )
      Debug_Output("Error: Adding null text to realm");
    if ( layer >= 0 )
      Debug_Output("Error: Negative layer not allowed");
    return -1;
  }
  add_obj_mutex.unlock();
}

private auto add_text_mutex = new Mutex;

void AOD::Add(AOD::Text t) {
  add_text_mutex.lock();
  if ( realm != null && t != null )
    realm.__Add(t);
  else {
    if ( t == null )
      AOD_Engine::Debug_Output("Error: Adding null text to realm");
  }
  add_text_mutex.unlock();
}

private auto rem_mutex = new Mutex;

void Remove(Object o) {
  rem_mutex.lock();
  if ( realm != null )
    realm.__Remove(o);
  rem_mutex.unlock();
}

void Remove(Text* t) {
  if ( realm != null )
    realm.__Remove(t);
}

void Set_BG_Colour(GLfloat r, GLfloat g, GLfloat b) {
  if ( realm == null ) return;
  realm.Set_BG_Colours(r, g, b);
}

void Run() {
  if ( realm == null ) return;
  float prev_dt        = 0, // DT from previous frame
        curr_dt        = 0, // DT for beginning of current frame
        elapsed_dt     = 0, // DT elapsed between previous frame and this frame
        accumulated_dt = 0; // DT needing to be processed
  started = 1;
  start_ticks = SDL_GetTicks();
  SDL_Event _event;
  _event.user.code = 2;
  _event.user.data1 = null;
  _event.user.data2 = null;
  SDL_PushEvent(&_event);

  // so I can set up keys and not have to rely that update is ran first
  SDL_PumpEvents();
  Input::Refresh_Input();
  SDL_PumpEvents();
  Input::Refresh_Input();

  while ( SDL_PollEvent(&_event) ) {
    switch ( _event.type ) {
      case SDL_QUIT:
        return;
    }
  }
  prev_dt = cast(float)SDL_GetTicks();
  while ( true ) {
    // refresh time handlers
    curr_dt = cast(float)SDL_GetTicks();
    elapsed_dt = curr_dt - prev_dt;
    accumulated_dt += elapsed_dt;

    // refresh calculations
    while ( accumulated_dt >= ms_dt ) {
      // sdl
      SDL_PumpEvents();
      Input::Refresh_Input();

      // actual update
      accumulated_dt -= ms_dt;
      realm->Update();

      string tex;
      string to_handle;
      bool alnum;
      char* chptr = null;

      /* auto input = Console::input->R_Str(), */
      /*      input_after = Console::input_after->R_Str(); */

      while ( SDL_PollEvent(&_event) ) {
        switch ( _event.type ) {
/* case SDL_MOUSEWHEEL: */
/*   if ( _event.wheel.y > 0 ) // positive away from user */
/*     Input::keys[ MOUSEBIND::MWHEELUP ] = true; */
/*   else if ( _event.wheel.y < 0 ) */
/*     Input::keys[ MOUSEBIND::MWHEELDOWN ] = true; */
/* break; */
/* case SDL_KEYDOWN: */
/*   // check if backspace or copy/paste */
/*   if ( Console::console_open ) { */
/*     switch ( _event.key.keysym.sym ) { */
/*       case SDLK_BACKSPACE: */
/*         if ( Console::input->R_Str().length() > 0 ) { */
/*           Console::input.Set_S */
/*           Console::input.R_Str().pop_back(); */
/*           Update_Console_Input_Position(); */
/*         } */
/*       break; */
/*       case SDLK_DELETE: */
/*         if ( Console::input_after->R_Str().length() > 0 ) { */
/*           Console::input_after->R_Str().erase(0, 1); */
/*           Update_Console_Input_Position(); */
/*         } */
/*       break; */
/*       case SDLK_c: // copy */
/*         if ( SDL_GetModState() & KMOD_CTRL ) { */
/*           SDL_SetClipboardText( Console::input->R_Str().c_str() ); */
/*           Update_Console_Input_Position(); */
/*         } */
/*       break; */
/*       case SDLK_v: // paste */
/*         if ( SDL_GetModState() & KMOD_CTRL ) { */
/*           chptr = SDL_GetClipboardText(); */
/*           Console::input.Set_String( chptr ); */
/*           SDL_free(chptr); */
/*           Update_Console_Input_Position(); */
/*         } */
/*       break; */
/*       case SDLK_LEFT: // navigate cursor left */
/*         tex = Console::input->R_Str(); */
/*         if ( tex.length() > 0 ) { */
/*           tex = tex[tex.length()-1]; */
/*           Console::input->R_Str().pop_back(); */
/*           Console::input_after->R_Str().insert(0, tex); */

/*           // skip word */
/*           /1* if ( SDL_GetModState() & KMOD_CTRL ) { *1/ */
/*           /1*   alnum = isalnum(tex[0]); *1/ */
/*           /1*   while ( Console::input->R_Str().length() > 0 ) { *1/ */
/*           /1*     tex = Console::input->R_Str(); *1/ */
/*           /1*     tex = tex[tex.length()-1]; *1/ */
/*           /1*     if ( (bool)isalnum(tex[0]) == alnum ) { *1/ */
/*           /1*       Console::input->R_Str().pop_back(); *1/ */
/*           /1*       Console::input_after->R_Str().insert(0, tex); *1/ */
/*           /1*     } else break; *1/ */
/*           /1*   } *1/ */
/*           /1* } *1/ */

/*           Update_Console_Input_Position(); */
/*         } */
/*       break; */
/*       case SDLK_RIGHT: // navigate cursor right */
/*         tex = Console::input_after->R_Str(); */
/*         if ( tex.length() > 0 ) { */
/*           tex = tex[0]; */
/*           Console::input_after->R_Str().erase(0, 1); */
/*           Console::input->R_Str().push_back(tex[0]); */

/*           // skip word */
/*           /1* if ( SDL_GetModState() & KMOD_CTRL ) { *1/ */
/*           /1*   alnum = isalnum(tex[0]); *1/ */
/*           /1*   while ( Console::input_after->R_Str().length() > 0 ) { *1/ */
/*           /1*     tex = Console::input_after->R_Str(); *1/ */
/*           /1*     tex = tex[0]; *1/ */
/*           /1*     if ( (bool)isalnum(tex[0]) == alnum ) { *1/ */
/*           /1*       Console::input_after->R_Str().erase(0, 1); *1/ */
/*           /1*       Console::input->R_Str().push_back(tex[0]); *1/ */
/*           /1*     } else break; *1/ */
/*           /1*   } *1/ */
/*           /1* } *1/ */

/*           Update_Console_Input_Position(); */
/*         } */
/*       break; */
/*       case SDLK_RETURN: case SDLK_RETURN2: */
/*         to_handle = Console::input->R_Str() + */
/*                     Console::input_after->R_Str(); */
/*         if ( to_handle != "" ) { */
/*           Console::input->Set_String(""); */
/*           Console::input_after->Set_String(""); */
/*           Handle_Console_Input(to_handle); */
/*           Update_Console_Input_Position(); */
/*         } */
/*       break; */
/*       case SDLK_END: */
/*         Console::input->R_Str() += Console::input_after->R_Str(); */
/*         Console::input_after->R_Str().clear(); */
/*         Update_Console_Input_Position(); */
/*       break; */
/*       case SDLK_HOME: */
/*         // since appending is faster than prepending */
/*         Console::input->R_Str() += Console::input_after->R_Str(); */
/*         Console::input_after->R_Str() = Console::input->R_Str(); */
/*         Console::input->R_Str().clear(); */
/*         Update_Console_Input_Position(); */
/*       break; */
/*     } */
/*   } */
/* break; */
/* case SDL_TEXTINPUT: */
/*   if ( AOD::Console::console_open ) { */
/*     if ( (SDL_GetModState() & KMOD_CTRL) || */
/*           _event.text.text[0] == '~' || _event.text.text[0] == '`' ) */
/*       break; */
/*     Console::input->R_Str() += _event.text.text; */
/*     Update_Console_Input_Position(); */
/*   } */
/* break; */
          case SDL_QUIT:
            return;
        }
      }
    }

    { // refresh screen
      float _FPS = 0;
      for ( int i = 0; i != 19; ++ i ) {
        fps[i+1] = fps[i];
        _FPS += fps[i+1];
      }
      fps[0] = elapsed_dt;
      _FPS += fps[0];

      if ( fps_display != null ) {
        //fps_display->Set_String(std::to_string(int(20000/_FPS)) + " FPS");
      }

      Console::Refresh();
      realm->Render(); // render the screen
    }

    { // sleep until temp dt reaches ms_dt
      float temp_dt = accumulated_dt;
      temp_dt = cast(float)(SDL_GetTicks()) - curr_dt;
      while ( temp_dt < AOD_Engine::ms_dt ) {
        SDL_PumpEvents();
        temp_dt = cast(float)(SDL_GetTicks()) - curr_dt;
      }
    }

    // set current frame timemark
    prev_dt = curr_dt;
  }
}

float R_MS()         { return cast(float)ms_dt; }
float To_MS(float x) { return (x*ms_dt)/1000;   }

void D_Output(string out) {
  /*std::ofstream fil("DEBUG.txt", std::ios::app);
  fil << out << '\n';
  fil.close();*/
  Console::to_console ~= out;
}

private auto output_lock = new Mutex();

void Output(string out) {
  output_lock.lock();
  D_Output(out);
  output_lock.unlock();
}

void Debug_Output(string out) {
  if ( Console::console_type == Console::TYPE_DEBUG_IN )
      D_Output(out);
}
