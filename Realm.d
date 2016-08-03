import derelict.opengl3.gl3;
import derelict.sdl2.sdl;
import AOD.AOD;
import AOD.Object;
import AOD.Text;
import AOD.Console;

module AOD.Realm;

class Realm {
  AOD.Object[][] objects;
  AOD.Text[] text;

  AOD::Object[] objs_to_rem;

  GLfloat bg_red, bg_blue, bg_green;
public:
  this(int window_width, int window_height,
       immutable(char)* window_name, immutable(char)* icon = "") {
    Debug_Output("Initializing SDL");
    DerelictGL3.load();
    DerelictSDL2.load(SharedLibVersion(2, 0, 2));

    SDL_Init ( SDL_INIT_EVERYTHING );
    Engine.screen = SDL_CreateWindow(window_name, SDL_WINDOWPOS_UNDEFINED,
                                                  SDL_WINDOWPOS_UNDEFINED,
                                                  window_width, window_height,
                                                  SDL_WINDOW_OPENGL |
                                                  SDL_WINDOW_SHOWN);
		if ( SDL_GL_SetAttribute( SDL_GL_CONTEXT_MAJOR_VERSION, 2 ) == -1 )
			Output("Error CONTEXT_MAJOR: " ~ string(SDL_GetError()));
		if ( SDL_GL_SetAttribute( SDL_GL_CONTEXT_MINOR_VERSION, 1 ) == -1 )
			Output("Error CONTEXT_MINOR: " ~ string(SDL_GetError()));
		if ( SDL_GL_CreateContext( Engine.screen ) == nullptr ) {
			Output("Error window context: " ~ string(SDL_GetError()));
		}
		if ( SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1) == -1 )
			Output("Error DOUBLEBUFFER: " + string(SDL_GetError()));
		if ( SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, 8) == -1 )
			Output("Error ALPHA_SIZE: " + string(SDL_GetError()));
		//glShadeModel(GL_SMOOTH);
		glEnable(GL_TEXTURE_2D);
		glEnable(GL_BLEND);
		if ( icon != "" ) {
			SDL_Surface* ico = SDL_LoadBMP(icon);
			SDL_SetWindowIcon(Engine.screen, ico);
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
		if ( !ilutRenderer(ILUT_OPENGL) )
			AOD.Output("Error setting ilut Renderer to ILUT_OPENGL");
		ilInit();
		iluInit();
		ilutInit();
		if ( !ilutRenderer(ILUT_OPENGL) )
			AOD.Output("Error setting ilut Renderer to ILUT_OPENGL");
		glEnable(GL_ALPHA);

		glLoadIdentity();
		
		glOrtho(0, window_width, window_height, 0, 0, 1);

		//glMatrixMode(GL_MODELVIEW);
		glDisable(GL_DEPTH_TEST);
		glMatrixMode(GL_MODELVIEW);
	}

	{ // others
		Debug_Output("Initializing Sounds Core");
		SoundEngine.Set_Up();
		Debug_Output("Initializing Font Core");
    TextEngine.Font.Init();
		objs_to_rem.clear();
		bg_red	 = 0;
		bg_blue	= 0;
		bg_green = 0;;
	}

  void __Add(Object o, int layer = 0) {
    o.layer = l;
    if ( l < 0 ) {
      l = 0;
      Debug_Output("Invalid layer is < 0, setting to 0");
    }

    if ( objects.length <= l ) objects.length = l+1;
    objects[l] ~= o;
  }
  void __Add(Text t) {
    text.push_back(t);
  }

  void __Remove(Object o) {
    objs_to_rem.push_back(o);
  }
  void __Remove(Text t) 
    foreach ( i; 0 .. text.length ) {
      if ( text[i] == t ) {
        text = [0 .. i] ~ [i+1 .. $];
        return;
      }
    }
  }

  void Set_BG_Colours(GLfloat r, GLfloat g, GLfloat b) {
    bg_red = r;
    bg_green = g;
    bg_blue = g;
  }


  void Update() {
    // update objects
    foreach ( l ; objects )
    foreach ( a ; l )
      a.Update();

    // remove objects
    foreach ( rem_it; 0 .. objs_to_rem.length ) {
      int layer_it = objs_to_rem[rem_it].layer;
      foreach ( obj_it; 0 .. objects[layer_it].length ) {
        if ( objects[layer_it][obj_it] is objs_to_rem[rem_it] ) {
          objects[layer_it][obj_it] = null;
          objects[layer_it] = objects[layer_it][0 .. obj_it] ~
                              objects[layer_it][obj_it+1 .. $];
          break;
        }
      }
    }
    objs_to_rem.clear();
  }

  void Render() {
    import CV = AOD.Client_Vars;

    glClear(GL_COLOR_BUFFER_BIT| GL_DEPTH_BUFFER_BIT);
    glClearColor(bg_red,bg_green,bg_blue,0);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_TEXTURE_2D);

    float off_x = Camera.position.x - Camera.size.x/2,
          off_y = Camera.position.y - Camera.size.y/2;

    static GLubyte index[6] = { 0,1,2, 1,2,3 };

    // --- objects

    foreach ( az ; objects )
    foreach ( lz ; az ) {
      if ( !lz.R_Is_Visible() ) continue;
      auto position = lz->R_Position(),
           size		 = lz->R_Size();
      if ( !lz.R_Is_Static_Pos() ) {
        position.x -= off_x;
        position.y -= off_y;
      }
      if ((position.x + size.x/2 < 0 ||
           position.x - size.x/2 > Camera.size.x ) ||
          (position.y + size.y/2 < 0 ||
           position.y - size.y/2 > Camera.size.y) )
        continue;

      glPushMatrix();
      glPushAttrib(GL_CURRENT_BIT);
        if ( lz.R_Is_Coloured() )
          glColor4f(lz.R_Red(), lz.R_Green(), lz.R_Blue(), lz.R_Alpha());
        glBindTexture(GL_TEXTURE_2D,lz->image);
        auto& origin = lz->R_Origin();
        int fx = lz.R_Flipped_X() ? -1 : 1,
            fy = lz.R_Flipped_Y() ?	1 :-1;
        glTranslatef(position.x + origin.x*fx,
                     position.y + origin.y*fy, 0);
        glRotatef((lz.rotation*180)/std::_Pi, 0, 0, 1);
        glTranslatef(-origin.x*fx,
                     -origin.y*fy, 0);
        glScalef (lz.image_size.x, lz->image_size.y, 1);

        glVertexPointer	(2, GL_FLOAT, 0, AOD.Object.Vertices);
        glTexCoordPointer(2, GL_FLOAT, 0, lz._UV);
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_BYTE, index);
        glLoadIdentity();
      glPopAttrib();
      glPopMatrix();
    }
  }
}
