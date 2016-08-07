module AODCore.input;
import derelict.sdl2.sdl;
import Camera = AODCore.camera;

// These represent SDL_ScanCodes. These are prefereable
// to just calling R_LMB() or w/e b/c these are bindeable
// from INI file
enum Mouse_Bind
     { Left = 300, Right = 301, Middle = 302,
       Wheelup  = 303, Wheeldown = 304,
       X1   = 305, X2    = 306 };

ubyte* keystate;

class MouseEngine {
static: private:
  uint mouse;
  int mouse_x, mouse_y;
static: public:
  void Refresh_Input() {
    keystate = cast(ubyte*)(SDL_GetKeyboardState(null));
    mouse = SDL_GetMouseState(&mouse_x, &mouse_y);
    keystate[ Mouse_Bind.Left   ] = R_LMB();
    keystate[ Mouse_Bind.Right  ] = R_RMB();
    keystate[ Mouse_Bind.Middle ] = R_MMB();
    keystate[ Mouse_Bind.X1     ] = R_MX1();
    keystate[ Mouse_Bind.X2     ] = R_MX2();
    // Let AODCore.D handle mouse wheel
  }
}

private alias MEngine = MouseEngine;

bool R_LMB() { return cast(bool)MEngine.mouse&SDL_BUTTON(SDL_BUTTON_LEFT  ); }
bool R_RMB() { return cast(bool)MEngine.mouse&SDL_BUTTON(SDL_BUTTON_RIGHT ); }
bool R_MMB() { return cast(bool)MEngine.mouse&SDL_BUTTON(SDL_BUTTON_MIDDLE); }
bool R_MX1() { return cast(bool)MEngine.mouse&SDL_BUTTON(SDL_BUTTON_X1    ); }
bool R_MX2() { return cast(bool)MEngine.mouse&SDL_BUTTON(SDL_BUTTON_X2    ); }

float R_Mouse_X(bool camoffset) {
  return MouseEngine.mouse_x + (camoffset ?
          Camera.R_Position().x - Camera.R_Size().x/2 : 0);
}
float R_Mouse_Y(bool camoffset) {
  return MouseEngine.mouse_y + (camoffset ?
          Camera.R_Position().y - Camera.R_Size().y/2 : 0);
}
