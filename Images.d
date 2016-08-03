import derelict.opengl3.gl3;
import derelict.sdl2.sdl;
module AOD.Image;

// contains information of image
struct SheetContainer {
public:
  GLuint texture;
  int width, height;
  this() { }
  this(GLuint t, int w, int h) {
    texture = t;
    width = w;
    height = h;
  }
  this(char* filename) {
    auto z = Load_Image(filename);
    texture = z.texture;
    width = z.width;
    height = z.height;
  }
}

// A sheet container that will also contain lcoation of obj inside a sheet,
// pixel-based coordinates where origin is {0, 0}. Useful for spritesheets,
// I'm sure there are some other utilities such as image cropping
struct SheetRect : public SheetContainer {
public:
  Vector ul, lr;
  // nil constructor ( no sheet container, ul/lr will set to 0, 0
  SheetRect();
  // Creates sheet rect whose image is sheet container, and coordinates
  // are from upper-left (ul) to lower-right (lr), which are relative offsets
  // from the origin {0, 0}
  SheetRect(const SheetContainer&, AOD::Vector ul, AOD::Vector lr);
}


SheetContainer Load_Image(const char* fil) {
  ILuint IL_ID;
  GLuint GL_ID;
  int width, height;

  ilGenImages(1, &IL_ID);
  ilBindImage(IL_ID);
  if ( ilLoadImage( fil ) == IL_TRUE ) {
    ILinfo ImageInfo;
    iluGetImageInfo(&ImageInfo);
    if ( ImageInfo.Origin == IL_ORIGIN_UPPER_LEFT )
      iluFlipImage();

    if ( !ilConvertImage(IL_RGBA, IL_UNSIGNED_BYTE) ) {
      auto t = iluErrorString(ilGetError());
      AOD_Engine::Debug_Output(t);
      return 0;
    }
    glBindTexture(GL_TEXTURE_2D, 0);
    glGenTextures(1, &GL_ID);
    glBindTexture(GL_TEXTURE_2D, GL_ID);
    if ( !glIsTexture(GL_ID) ) {
      AOD::Output("Error generating GL texture");
      return SheetContainer();
    }
    // set texture clamping method
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);

    // set texture interpolation method
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
      
    width  = ilGetInteger(IL_IMAGE_WIDTH);
    height = ilGetInteger(IL_IMAGE_HEIGHT);

    // texture specs
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0,
               ilGetInteger(IL_IMAGE_FORMAT), GL_UNSIGNED_BYTE, ilGetData());
  } else {
    auto t = ilGetError();
    AOD_Engine::Debug_Output("Error loading " + std::string(fil) + ": " +
      iluErrorString(t) + "(" + std::to_string(ilGetError()) + ')');
    return 0;
  }
  ilDeleteImages(1, &IL_ID);
  return SheetContainer(GL_ID, width, height);
}
import std.string;
SheetContainer Load_Image(string fil) {
  return Load_Image(fil.ptr);
}
