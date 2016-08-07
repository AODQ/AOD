module AODCore.utility;

import derelict.opengl3.gl3;
import derelict.sdl2.sdl;

const(float) E         =  2.718282,
             Log10E    =  0.4342945,
             Log2E     =  1.442695,
             Pi        =  3.141593,
             Tau       =  6.283185,
             Max_float =  3.402823E+38,
             Min_float = -3.402823E+38,
             Epsilon   =  0.000001;

import std.random;
private Random gen;

float R_Rand(float bot, float top) {
  return uniform(bot, top, gen);
}

T R_Max(T)(T x, T y) { return x > y ? x : y; }
T R_Min(T)(T x, T y) { return x < y ? x : y; }

import AODCore.vector;

float To_Rad(float x) {
  return x * (Pi/180.0);
}

float To_Deg(float x) {
  return x * (180.0/Pi);
}
