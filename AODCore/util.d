/**
  Just general utility that is useful in AOD. Was much more useful in C++, now
  in D most of these are not necessary
*/
module AODCore.util;
import AODCore.aod;
import std.string;

/** */
const(float) E         =  2.718282f,
/** */
             Log10E    =  0.4342945f,
/** */
             Log2E     =  1.442695f,
/** */
             Pi        =  3.141593f,
/** */
             Tau       =  6.283185f,
/** use float.max instead */
             Max_float =  3.402823E+38,
/** use float.min instead */
             Min_float = -3.402823E+38,
/** */
             Epsilon   =  0.000001f;

import std.random;
private Mt19937 gen;

void Seed_Random() {
  import std.algorithm.iteration : map;
  import std.range : repeat;
  uint seed = unpredictableSeed;
  import std.stdio;
  import std.conv : to;
  writeln("SEED: " ~ to!string(seed));
  gen.seed(seed);
}

/** Returns: A random float bot .. top*/
float R_Rand(float bot, float top) {
  if ( bot == top ) return top;
  return bot < top ? uniform(bot, top, gen) : uniform(top, bot, gen);
}

/** Returns: Max value between the two parameters */
T R_Max(T)(T x, T y) { return x > y ? x : y; }
/** Returns: Min value between the two parameters */
T R_Min(T)(T x, T y) { return x < y ? x : y; }

/** Returns array with indexed element removed */
T Remove(T)(T array, size_t index) in {
  assert(index >= 0 && index < array.length);
} body {
  if ( array.length-1 == index ) return array[0 .. index];
  else if ( index == 0 )
    return array[0 .. index];
  else {
    return array[0 .. index] ~
           array[index+1 .. $];
  }
}


/** Converts from degrees to radians */
float To_Rad(float x) {
  return x * (Pi/180.0);
}

/** Converts from radians to degrees*/
float To_Deg(float x) {
  return x * (180.0/Pi);
}

/**
  Calculates Bresenham's Line Algorithm
  From: http://www.roguebasin.com/index.php?title=Bresenham%27s_Line_Algorithm
*/
Vector[] Bresenham_Line(int sx, int sy, int ex, int ey) {
  import std.math;
  int dx = abs(ex - sx),
      dy = abs(ey - sy),
      ix = sx < ex ? 1 : -1,
      iy = sy < ey ? 1 : -1;
  int err = dx - dy;

  Vector[] points;
  while ( true ) {
    points ~= Vector(sx, sy);

    if ( sx == ex && sy == ey )
      break;

    int e = err * 2;
    if ( e > -dx ) {
      err -= dy;
      sx += ix;
    }
    if ( e < dx ){
      err += dx;
      sy += iy;
    }
  }
  return points;
}

/** Linearly interpolates between a and b using fraction f */
float Lerp(float a, float b, float f) {
  return (a * (1.0f - f)) + (b * f);
}

/**
  Describes a variable assignment from an INI file
*/
struct INI_Item {
  /** The left-hand side of the assignment */
  string key,
  /** The right-hand side of the assignment */
         value;
  /** */
  this(string key_, string value_) {
    key = key_; value = value_;
  }
}

/** Hashmap representing categories. Each category contains an array of INI_Item
Example:
---
  if ( data["audio"].key == "volume" )
    volume = to!int(data["audio"].value);
---
*/
alias INI_Data = INI_Item[][string];

import std.file;
import std.stdio;
/**
  Loads an entire INI file
Params:
  filename = file to load
Returns:
  A hashmap representing categories, each of which is an array of INI_Item.
*/
INI_Data Load_INI(string filename) in {
  assert(std.file.exists(filename));
}  body {
  INI_Data data;
  string current_section = "";
  File fil = File(filename, "rb");
  while ( !fil.eof() ) {
    string current_line = fil.readln().strip();
    if ( current_line    == ""  ) continue; // empty line
    if ( current_line[0] == ';' ) continue; // comment
    if ( current_line[0] == '[' && current_line[$-1] == ']' ) { // section
      current_section = current_line[1 .. $-1].strip();
      continue;
    }
    // regular item assignment
    auto split_data = current_line.split("=");
    if ( split_data.length == 2 ) {
      data [ current_section ] ~= INI_Item(split_data[0].strip(),
                                           split_data[1].strip());
    }
  }
  return data;
}



/// ----
/// ---- now this is where AOD.Util become useful, meta template stuff
/// ----
import std.traits;
import std.typetuple;
import std.typecons;
import std.meta;
import std.string : format;
import entity.tile;

template AliasSeqToStringArray(ASeq...) {
  static if ( ASeq.length == 0 )
    enum string[] AliasSeqToStringArray = [];
  else static if ( ASeq.length == 1 )
    enum string[] AliasSeqToStringArray = [ASeq[0].stringof];
  else
    enum string[] AliasSeqToStringArray = [ASeq[0].stringof] ~
                            AliasSeqToStringArray!(ASeq[1..$]);
}
