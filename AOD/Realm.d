module AODCore.realm;

import derelict.opengl3.gl3;
import derelict.opengl3.gl;
import derelict.openal.al;
import derelict.vorbis.vorbis;
import derelict.vorbis.file;
import derelict.sdl2.sdl;
import derelict.devil.il;
import derelict.devil.ilu;
import derelict.devil.ilut;
import derelict.freetype.ft;
import AODCore.entity;
import AODCore.text;
import AODCore.console;
import AODCore.input;
import AODCore.sound;
import Camera = AODCore.camera;

private SDL_Window* screen = null;

class Realm {
  Entity[][] objects;
  Text[] text;

  Entity[] objs_to_rem;

  GLfloat bg_red, bg_blue, bg_green;

  bool started;
  uint start_ticks;

  int width, height;
  uint ms_dt;
  float[20] fps = [ 0 ];
  AODCore.text.Text fps_display;
public:

  void Change_MSDT(uint ms_dt_) in {
    assert(ms_dt_ > 0);
  } body {
    ms_dt = ms_dt_;
  }

  int R_Width ()       { return width;                        }
  int R_Height()       { return height;                       }
  float R_MS  ()       { return cast(float)ms_dt;             }
  float To_MS(float x) { return cast(float)(x*ms_dt)/1000.0f; }

  void Set_FPS_Display(AODCore.text.Text fps) {
    if ( fps_display !is null )
      Remove(fps_display);
    fps_display = fps;
    if ( fps_display !is null )
      Add(fps_display);
  }

  this(int window_width, int window_height, uint ms_dt_,
       immutable(char)* window_name, immutable(char)* icon = "") {
    width  = window_width;
    height = window_height;
    ms_dt = ms_dt_;
    Debug_Output("Initializing SDL");
    import std.conv : to; 
    import derelict.util.exception;
    import std.stdio;
    writeln("AOD@Realm.d@Initialize Initializing Art of Dwarficorn engine");
    writeln("AOD@Realm.d@Initialize Loading external libraries");

    template Load_Library(string lib, string params) {
      const char[] Load_Library =
        "try { " ~ lib ~ ".load(" ~ params ~ ");" ~
        "} catch ( DerelictException de ) {" ~
            "writeln(\"--------------------------------------------------\");"~
            "writeln(\"Failed to load: " ~ lib ~ ", \" ~ to!string(de));"     ~
        "}";
    }
    
    mixin(Load_Library!("DerelictGL3"       ,""));
    mixin(Load_Library!("DerelictGL"        ,""));
    mixin(Load_Library!("DerelictSDL2",
                        "\"SDL2.dll\",SharedLibVersion(2 ,0 ,2)"));
    mixin(Load_Library!("DerelictIL"        ,""));
    mixin(Load_Library!("DerelictILU"       ,""));
    mixin(Load_Library!("DerelictILUT"      ,""));
    mixin(Load_Library!("DerelictFT"        ,"\"freetype265.dll\""));
    mixin(Load_Library!("DerelictAL"        ,""));
    mixin(Load_Library!("DerelictVorbis"    ,"\"libvorbis-0.dll\""));
    mixin(Load_Library!("DerelictVorbisFile","\"libvorbisfile-3.dll\""));
    
    writeln("AOD@Realm.d@Initialize Initializing SDL");
    SDL_Init ( SDL_INIT_EVERYTHING );


    writeln("AOD@Realm.d@Initialize Creating SDL Window");
    screen = SDL_CreateWindow(window_name, SDL_WINDOWPOS_UNDEFINED,
                                           SDL_WINDOWPOS_UNDEFINED,
                                           window_width, window_height,
                                           SDL_WINDOW_OPENGL |
                                           SDL_WINDOW_SHOWN );
    writeln("Creating OpenGL Context");
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE,  24);
    SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE,   8);
    import std.conv : to;
    if ( screen is null ) {
      throw new Exception("Error SDL_CreateWindow: "
                          ~ to!string(SDL_GetError()));
    }

    if ( SDL_GL_CreateContext(screen) is null ) {
      throw new Exception("Error SDL_GL_CreateContext: "
                          ~ to!string(SDL_GetError()));
    }

    try {
      DerelictGL3.reload();
      DerelictGL.reload();
    } catch ( DerelictException de ) {
      writeln("\n----------------------------------------------------------\n");
      writeln("Failed to reload DerelictGL3: " ~ to!string(de));
      writeln("\n----------------------------------------------------------\n");
    }

    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    if ( icon != "" ) {
      writeln("Loading window icon");
      SDL_Surface* ico = SDL_LoadBMP(icon);
      SDL_SetWindowIcon(screen, ico);
    }

    glClearDepth(1.0f);
    glPolygonMode(GL_FRONT, GL_FILL);
    glShadeModel(GL_FLAT);
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
    glDepthFunc(GL_LEQUAL);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glMatrixMode(GL_PROJECTION);
    glEnable(GL_ALPHA);

    writeln("glLoadIdentity");
    glLoadIdentity();

    ilInit();
    iluInit();
    ilutInit();
    if ( !ilutRenderer(ILUT_OPENGL) )
      writeln("Error setting ilut Renderer to ILUT_OPENGL");
    import AODCore.vector;
    writeln("window dimensions: " ~ cast(string)Vector(window_width,
                                                       window_height));
    
    glOrtho(0, window_width, window_height, 0, 0, 1);

    glDisable(GL_DEPTH_TEST);
    glMatrixMode(GL_MODELVIEW);
    { // others
      writeln("Initializing sounds core");
      Debug_Output("Initializing Sounds Core");
      SoundEng.Set_Up();
      Debug_Output("Initializing Font Core");
      TextEng.Font.Init();
      /* objs_to_rem = []; */
      /* bg_red   = 0; */
      /* bg_blue  = 0; */
      /* bg_green = 0; */
    }
    static import AODCore.camera;
    AODCore.camera.Set_Position(Vector(0, 0));
    AODCore.camera.Set_Size(Vector(cast(float)window_width,
                                   cast(float)window_height));
    writeln("AOD@Realm.d@Initialize Finalized initializing AOD main core");
  }

  int Add(Entity o) in {
    assert(o !is null);
  } body {
    static uint id_count = 0;
    o.Set_ID(id_count ++);
    int l = o.R_Layer();
    if ( objects.length <= l ) objects.length = l+1;
    objects[l] ~= o;
    return o.Ret_ID();
  }

  void Add(Text t) in {
    assert(t !is null);
  } body {
    text ~= t;
  }

  void Remove(Entity o) in {
    assert(o !is null);
  } body {
    objs_to_rem ~= o;
  }
  void Remove(Text t) in {
    assert(t !is null);
  } body {
    foreach ( i; 0 .. text.length ) {
      if ( text[i] == t ) {
        destroy(text[i]);
        text[i] = null;
        text = text[0 .. i] ~ text[i+1 .. $];
        return;
      }
    }
  }

  void Set_BG_Colours(GLfloat r, GLfloat g, GLfloat b) {
    bg_red = r;
    bg_green = g;
    bg_blue = g;
  }


  void Run() {
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
    /* writeln("AOD@AODCore.d@Run pumping events before first update"); */
    SDL_PumpEvents();
    MouseEngine.Refresh_Input();
    SDL_PumpEvents();
    MouseEngine.Refresh_Input();

    while ( SDL_PollEvent(&_event) ) {
      switch ( _event.type ) {
        case SDL_QUIT:
          return;
        default: break;
      }
    }
    prev_dt = cast(float)SDL_GetTicks();
    /* writeln("AOD@AODCore.d@Run Now beginning main engine loop"); */
    while ( true ) {
      // refresh time handlers
      curr_dt = cast(float)SDL_GetTicks();
      elapsed_dt = curr_dt - prev_dt;
      accumulated_dt += elapsed_dt;

      // refresh calculations
      while ( accumulated_dt >= ms_dt ) {
        // sdl
        SDL_PumpEvents();
        MouseEngine.Refresh_Input();

        // actual update
        accumulated_dt -= ms_dt;
        Update();

        string tex;
        string to_handle;
        bool alnum;
        char* chptr = null;

        /* auto input = Console::input->R_Str(), */
        /*      input_after = Console::input_after->R_Str(); */

        while ( SDL_PollEvent(&_event) ) {
          switch ( _event.type ) {
            default: break;
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

        if ( fps_display !is null ) {
          import std.conv : to;
          fps_display.Set_String( to!string(cast(int)(20000/_FPS)) ~ " FPS");
        }

        Render(); // render the screen
      }

      { // sleep until temp dt reaches ms_dt
        float temp_dt = accumulated_dt;
        temp_dt = cast(float)(SDL_GetTicks()) - curr_dt;
        while ( temp_dt < ms_dt ) {
          SDL_PumpEvents();
          temp_dt = cast(float)(SDL_GetTicks()) - curr_dt;
        }
      }

      // set current frame timemark
      prev_dt = curr_dt;
    }
  }


  void Update() {
    // update objects
    foreach ( l ; objects )
    foreach ( a ; l )
      a.Update();

    // remove objects
    foreach ( rem_it; 0 .. objs_to_rem.length ) {
      int layer_it = objs_to_rem[rem_it].R_Layer();
      foreach ( obj_it; 0 .. objects[layer_it].length ) {
        if ( objects[layer_it][obj_it] is objs_to_rem[rem_it] ) {
          destroy(objects[layer_it][obj_it]);
          objects[layer_it][obj_it] = null;
          objects[layer_it] = objects[layer_it][0 .. obj_it] ~
                              objects[layer_it][obj_it+1 .. $];
          break;
        }
      }
    }
    objs_to_rem = [];
  }

  ~this() {
    // todo...
    SDL_DestroyWindow(screen);
    SDL_Quit();
  }

  void Render() {
    glClear(GL_COLOR_BUFFER_BIT| GL_DEPTH_BUFFER_BIT);
    glClearColor(bg_red,bg_green,bg_blue,0);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_TEXTURE_2D);

    float off_x = Camera.R_Origin_Offset().x,
          off_y = Camera.R_Origin_Offset().y;

    static GLubyte[6] index = [ 0,1,2, 1,2,3 ];

    // --- objects

    foreach ( az ; objects )
    foreach ( lz ; az ) {
      if ( !lz.R_Is_Visible() ) continue;
      auto position = lz.R_Position(),
           size      = lz.R_Size();
      if ( !lz.R_Is_Static_Pos() ) {
        position.x -= off_x;
        position.y -= off_y;
      }
      if ((position.x + size.x/2 < 0 ||
           position.x - size.x/2 > Camera.R_Size().x ) ||
          (position.y + size.y/2 < 0 ||
           position.y - size.y/2 > Camera.R_Size().y) )
        continue;

      glPushMatrix();
      glPushAttrib(GL_CURRENT_BIT);
        if ( lz.R_Is_Coloured() )
          glColor4f(lz.R_Red(), lz.R_Green(), lz.R_Blue(), lz.R_Alpha());
        glBindTexture(GL_TEXTURE_2D, lz.R_Sprite_Texture());
        auto origin = lz.R_Origin();
        int fx = lz.R_Flipped_X() ? - 1 :  1 ,
            fy = lz.R_Flipped_Y() ?   1 :- 1 ;
        glTranslatef(position.x + origin.x*fx,
                     position.y + origin.y*fy, 0);
        import std.conv : to;
        import std.stdio : writeln;
        glRotatef((lz.R_Rotation()*180.0)/3.14159f, 0, 0, 1);
        glTranslatef(-origin.x*fx,
                     -origin.y*fy, 0);
        glScalef (lz.R_Img_Size().x, lz.R_Img_Size().y, 1);

        import std.conv : to;
        glVertexPointer  (2, GL_FLOAT, 0, Entity.Vertices.ptr);
        glTexCoordPointer(2, GL_FLOAT, 0, lz.R_UV_Array().ptr);
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_BYTE, index.ptr);
        glLoadIdentity();
      glPopAttrib();
      glPopMatrix();
    }


    // ---- texts
    foreach ( i; 0 .. text.length ) {
      auto tz = text[i];
      if ( !tz.R_Visible() ) continue;
      if ( !tz.R_FT_Font() ) {
        Debug_Output("Font face uninitialized for " ~ tz.R_Font());
      }
    
      string t_str = tz.R_Str();
      import std.stdio : writeln;
      /* writeln("Rendering " ~ t_str ~ " @ " ~ cast(string)tz.R_Position()); */

      glPushMatrix();
        glTranslatef(tz.R_Position().x, tz.R_Position().y, 0);
        glListBase(tz.R_FT_Font().R_Character_List());
        glCallLists(t_str.length, GL_UNSIGNED_BYTE, t_str.ptr);
      glPopMatrix();
    }


    // ---- console
    static import AODCore.console;
    if ( AODCore.console.console_open ) {
      foreach ( tz; AODCore.console.ConsEng.console_text ) {
        string t_str = tz.R_Str();

        glPushMatrix();
          glTranslatef(tz.R_Position().x, tz.R_Position().y, 0);
          glListBase(tz.R_FT_Font().R_Character_List());
          glCallLists(t_str.length, GL_UNSIGNED_BYTE, t_str.ptr);
        glPopMatrix();
      }
    }

    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_TEXTURE_2D);


    SDL_GL_SwapWindow(screen);
  }
}
