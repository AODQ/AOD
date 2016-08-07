module AOD;

import derelict.opengl3.gl3;
import derelict.opengl3.gl;
import derelict.sdl2.sdl;
import std.string;
import std.stdio;

static import AODCore.camera;
static import AODCore.clientvars;
static import AODCore.realm;
static import AODCore.text;
static import AODCore.sound;
static import AODCore.entity;
static import AODCore.vector;
static import AODCore.utility;
static import AODCore.matrix;
static import AODCore.camera;

// --------------------- realm -------------------------------------------------

private AODCore.realm.Realm realm = null;

void Initialize(uint fps, string name, int width, int height, string ico = "")
in {
  assert(realm is null);
} body {
  if ( name == "" )
    name = "Art of Dwarficorn";
  realm = new AODCore.realm.Realm(width, height, fps, name.ptr, ico.ptr);
}
void Change_MSDT(Uint32 ms_dt) in { assert(realm !is null); } body {
  realm.Change_MSDT(ms_dt);
}
void Reset() in { assert(realm  is null); } body { /* ... todo ... */ }
void End()   in { assert(realm !is null); } body {
  destroy(realm);
  realm = null;
}

int  Add(Entity o)    in {assert(realm !is null);} body { return realm.Add(o); }
void Add(Text t)      in {assert(realm !is null);} body {        realm.Add(t); } 
void Remove(Entity o) in {assert(realm !is null);} body {     realm.Remove(o); }
void Remove(Text t)   in {assert(realm !is null);} body {     realm.Remove(t); }

void Set_BG_Colour(GLfloat r, GLfloat g, GLfloat b)
in {
  assert(realm !is null);
} body {
  realm.Set_BG_Colours(r, g, b);
}

void Run() in { assert(realm !is null); } body {
  realm.Run();
}

float R_MS()         { return realm.R_MS();   }
float To_MS(float x) { return realm.To_MS(x); }

int R_Window_Width()  { return realm.R_Width();  }
int R_Window_Height() { return realm.R_Height(); }

// will add Text to realm & remove old one
void Set_FPS_Display(AODCore.text.Text fps) in { assert(realm !is null); }
body { realm.Set_FPS_Display(fps);}

// --------------------- Vector/Matrix/Utility ---------------------------------

alias Vector = AODCore.vector.Vector;
alias Matrix = AODCore.matrix.Matrix;

class Util {
public: static:
  alias R_Rand = AODCore.utility.R_Rand;
  alias R_Max  = AODCore.utility.R_Max;
  alias R_Min  = AODCore.utility.R_Min;
  alias To_Rad = AODCore.utility.To_Rad;
  alias To_Deg = AODCore.utility.To_Deg;

  alias E         = AODCore.utility.E;
  alias Log10E    = AODCore.utility.Log10E;
  alias Log2E     = AODCore.utility.Log2E;
  alias Pi        = AODCore.utility.Pi;
  alias Tau       = AODCore.utility.Tau;
  alias Max_float = AODCore.utility.Max_float;
  alias Min_float = AODCore.utility.Min_float;
  alias Epsilon   = AODCore.utility.Epsilon;
}

// --------------------- Camera ------------------------------------------------

class Camera {
public: static:
  alias Set_Position    = AODCore.camera.Set_Position;
  alias Set_Size        = AODCore.camera.Set_Size;
  alias R_Size          = AODCore.camera.R_Size;
  alias R_Position      = AODCore.camera.R_Position;
  alias R_Origin_Offset = AODCore.camera.R_Origin_Offset;
}

// --------------------- ClientVars --------------------------------------------

class ClientVars {
public: static:
  alias Keybind       = AODCore.clientvars.Keybind;
  alias screen_width  = AODCore.clientvars.screen_width;
  alias screen_height = AODCore.clientvars.screen_height;
  alias Load_Config   = AODCore.clientvars.Load_Config;
}

// --------------------- Console -----------------------------------------------

class Console {
public: static:
  alias Type                    = AODCore.console.Type;
  alias console_open            = AODCore.console.console_open;
  alias Set_Open_Console_Key    = AODCore.console.Set_Open_Console_Key;
  alias Set_Console_History     = AODCore.console.Set_Console_History;
  alias Set_Console_Output_Type = AODCore.console.Set_Console_Output_Type;
  alias Initialize              = AODCore.console.Initialize;
}
alias Output = AODCore.console.Output;

// --------------------- Entity ------------------------------------------------

alias Entity     = AODCore.entity.Entity;
alias PolyEntity = AODCore.entity.PolyEnt;
alias AABBEntity = AODCore.entity.AABBEnt;

// --------------------- Image -------------------------------------------------

alias SheetContainer = AODCore.image.SheetContainer;
alias SheetRect      = AODCore.image.SheetRect;
alias Load_Image     = AODCore.image.Load_Image;

// --------------------- Input -------------------------------------------------

class Inp {
  alias Mouse_Bind = AODCore.input.Mouse_Bind;
  alias keystate   = AODCore.input.keystate;
  alias R_LMB      = AODCore.input.R_LMB;
  alias R_RMB      = AODCore.input.R_RMB;
  alias R_MMB      = AODCore.input.R_MMB;
  alias R_MX1      = AODCore.input.R_MX1;
  alias R_MX2      = AODCore.input.R_MX2;
  alias R_Mouse_X  = AODCore.input.R_Mouse_X;
  alias R_Mouse_Y  = AODCore.input.R_Mouse_Y;
}

// --------------------- Sound -------------------------------------------------

alias Play_Sample = AODCore.sound.Sounds.Play_Sample;
class Sound {
  alias Change_Sample_Position = AODCore.sound.Sounds.Change_Sample_Position;
  alias Clean_Up               = AODCore.sound.Sounds.Clean_Up;
}

// --------------------- Text --------------------------------------------------

alias Text = AODCore.text.Text;

// ------------------- s c r a p s  --------------------------------------------
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
