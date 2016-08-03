import derelict.sdl2.sdl;

// These represent SDL_ScanCodes. These are prefereable
// to just calling R_LMB() or w/e b/c these are bindeable
// from INI file
enum Mouse_Bind
     { Left = 300, Right = 301, Middle = 302,
       Wheelup  = 303, Wheeldown = 304,
       X1   = 305, X2    = 306 };

private class MouseEngine {
  ubyte mouse;
  int mouse_x, mouse_y;
  void Refresh_Input() {
    keys = cast(ubyte*)(SDL_GetKeyboardState(null));
    mouse = SDL_GetMouseState(&mouse_x, &mouse_y);
    keys[ Mouse_Bind.Left ] = R_LMB();
    keys[ Mouse_Bind.Right ] = R_RMB();
    keys[ Mouse_Bind.Middle ] = R_MMB();
    keys[ Mouse_Bind.X1 ] = R_MX1();
    Keys[ Mouse_Bind.X2 ] = R_MX2();
    // Let AOD.D handle mouse wheel
  }
}

bool R_LMB() { return MouseEngine.mouse&SDL_BUTTON(SDL_BUTTON_LEFT  ); }
bool R_RMB() { return MouseEngine.mouse&SDL_BUTTON(SDL_BUTTON_RIGHT ); }
bool R_MMB() { return MouseEngine.mouse&SDL_BUTTON(SDL_BUTTON_MIDDLE); }
bool R_MX1() { return MouseEngine.mouse&SDL_BUTTON(SDL_BUTTON_X1    ); }
bool R_MX2() { return MouseEngine.mouse&SDL_BUTTON(SDL_BUTTON_X2    ); }

float AODInp::R_Mouse_X(bool camoffset) {
  return MouseEngine.mouse_x + (camoffset ?
          Camera.R_Position().x - Camera.R_Size().x/2 : 0);
}
float AODInp::R_Mouse_Y(bool camoffset) {
  return MouseEngine.mouse_y + (camoffset ?
          Camera.R_Position().y - Camera.R_Size().y/2 : 0);
}
