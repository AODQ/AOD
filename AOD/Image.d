module AODCore.image;

import derelict.opengl3.gl3;
import derelict.sdl2.sdl;
import derelict.devil.il;
import derelict.devil.ilu;
//import derelict.devil.ilut;
import AODCore.console;
import AODCore.vector;

// contains information of image
struct SheetContainer {
public:
  GLuint texture;
  int width, height;
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

// A sheet container that will also contain location of obj inside a sheet,
// pixel-based coordinates where origin is {0, 0}. Useful for spritesheets,
// I'm sure there are some other utilities such as image cropping
struct SheetRect {
public:
  GLuint texture;
  int width, height;
  Vector ul, lr;
  // Creates sheet rect whose image is sheet container, and coordinates
  // are from upper-left (ul) to lower-right (lr), which are relative offsets
  // from the origin {0, 0}
  this(ref SheetContainer sc, ref Vector ul_, ref Vector lr_) {
    texture = sc.texture;
    width = sc.width;
    height = sc.height;
    ul = ul_;
    lr = lr_;
  }
}

import std.string;
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
      import std.conv : to;
      auto t = iluErrorString(ilGetError());
      Debug_Output(to!string(t));
      return SheetContainer();
    }
    glBindTexture(GL_TEXTURE_2D, 0);
    glGenTextures(1, &GL_ID);
    glBindTexture(GL_TEXTURE_2D, GL_ID);
    if ( !glIsTexture(GL_ID) ) {
      Output("Error generating GL texture");
      return SheetContainer();
    }
    // set texture clamping method
    /* glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP); */
    /* glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP); */

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
    import std.conv;
    Debug_Output("Error loading " ~ to!string(fil) ~ ": " ~
      to!string(iluErrorString(t)) ~ "(" ~ to!string(ilGetError()) ~ ")");
    return SheetContainer();
  }
  ilDeleteImages(1, &IL_ID);
  return SheetContainer(GL_ID, width, height);
}
import std.string;
SheetContainer Load_Image(string fil) {
  return Load_Image(fil.ptr);
}
