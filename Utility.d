module AOD.Utility;

const(float) E         =  2.718282f,
             Log10E    =  0.4342945f,
             Log2E     =  1.442695f,
             Pi        =  3.141593f,
             Tau       =  6.283185f,
             Max_float =  3.402823E+38f,
             Min_float = -3.402823E+38f,
             Epsilon   =  0.000001f;

import std.random;

Random gen;

float R_Rand(float bot, float top) {
  return uniform(bot, top, gen);
}

T R_Max(T)(T x, T y) { return x > y ? x : y; }
T R_Min(T)(T x, T y) { return x < y ? x : y; }

void Delete_Image(GLuint t) {

}

import AOD.Vector;

float To_Rad(float x) {
  return x * (Pi/180.f);
}

float To_Deg(float x) {
  return x * (180.f/Pi);
}
