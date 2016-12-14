import derelict.opengl3.gl3;
import derelict.sdl2.sdl;
import std.stdio;
static import AOD = AODCore.aod;

class Test_Object : AOD.Entity {
public:
  this() {
    super();
    Set_Size(32, 32);
    Set_Sprite(AOD.Load_Image("assets/AOD.png"));
    Set_Is_Static_Pos(true);
    Set_Visible(true);
  }
  override void Update() {
    Set_Position(AOD.Inp.R_Mouse_X(0), AOD.Inp.R_Mouse_Y(0));
    if ( AOD.Util.R_Rand(0.0f, 100.0f) > 75.0f ) {
      auto f = new Flykick();
      f.Set_Position(R_Position());
      AOD.Add(f);
    }
  }
}

class Flykick : AOD.Entity {
public:
  this() {
    super();
    static bool loaded = false;
    static AOD.SheetContainer flykick_img;
    if ( !loaded ) {
      loaded = true;
      flykick_img = AOD.Load_Image("assets/flyside.png");
      flykick_img.width  = 64;
      flykick_img.height = 64;
    }
    Set_Size(64, 64, true);
    Set_Sprite(flykick_img);
    Set_Is_Static_Pos(true);
    fx = AOD.Util.R_Rand(-15.0f, 15.0f);
    fy = AOD.Util.R_Rand(-15.0f, 15.0f);
  }

  float fx, fy;

  override void Update() {
    fx *= 0.91f;
    fy *= 0.898f;
    Add_Position(fx, fy);
    if ( fx <= 1f && fy <= 1f ) {
      AOD.Remove(this);
    }
  }
}

// This is the "standard" way to initialize the engine. My thought process is
// to immediately set up the console so we can receive errors as we initialize
// the AOD engine. Then afterwards we adjust the camera to center of screen
// and load the font & assign console key so we can start reading from the
// console. Everything else after is usually control configuration or debug
void Init () {
  writeln("app.d@Init Setting up console");
  AOD.Console.console_open = false;
  AOD.Console.Set_Console_Output_Type(AOD.Console.Type.Debug_In);
  AOD.Initialize(16, "CYBER BUTCHER", 640, 480);
  AOD.Camera.Set_Size(AOD.Vector(AOD.R_Window_Width(), AOD.R_Window_Height()));
  AOD.Camera.Set_Position(AOD.Vector(AOD.R_Window_Width()/2,
                                     AOD.R_Window_Height()/2));
  AOD.Text.Set_Default_Font("assets/DejaVuSansMono.ttf", 13);
  AOD.Console.Initialize(1, SDL_SCANCODE_GRAVE, "");
  AOD.Set_BG_Colour(.08, .08, .095);
  // --- debug ---
  AOD.Add(new Test_Object());
  AOD.Set_FPS_Display(new AOD.Text(20, 20, ""));
  AOD.Play_Sample("assets\\test-song.ogg");
}

int main () {
  Init();
  AOD.Run();
  writeln("Ending program");
  return 0;
}
