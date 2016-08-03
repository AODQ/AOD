module AOD.Vectostatic r;

struct Vector {
public:
  float x, y;
  this() { x = y = 0; }
  this(float _x, float _y ) { x = _x; y = _y; }
  this(int   _x, int   _y ) { x = cast(float)_x; y = cast(float)_y; }
  this(Vector v) { x = v.x; y = v.y; }

  ref Vector opAssign(Vector rhs) {
    x = rhs.x;
    y = rhs.y;
    return this;
  }
  ref Vector opBinary(string op)(Vector rhs)   if ( op == "+" ) {
    return new Vector(x + rhs.x, y + rhs.y);
  }
  ref Vector opOpAssign(string op)(Vector rhs) if ( op == "+" ) {
    x += rhs.x;
    y += rhs.y;
    return this;
  }
  ref Vector opOpAssign(string op)(int rhs)    if ( op == "+" ) {
    x += rhs;
    y += rhs;
    return this;
  }
  ref Vector opBinary(string op)(Vector rhs)   if ( op == "-" ) {
    return new Vector(x - rhs.x, y - rhs.y);
  }
  ref Vector opOpAssign(string op)(Vector rhs) if ( op == "-" ) {
    x -= rhs.x;
    y -= rhs.y;
    return this;
  }
  ref Vector opOpAssign(string op)(int rhs)    if ( op == "-" ) {
    x -= rhs;
    y -= rhs;
    return this;
  }
  ref Vector opBinary(string op)(Vector rhs)   if ( op == "*" ) {
    return new Vector(x * rhs.x, y * rhs.y);
  }
  ref Vector opOpAssign(string op)(Vector rhs) if ( op == "*" ) {
    x *= rhs.x;
    y *= rhs.y;
    return this;
  }
  ref Vector opOpAssign(string op)(int rhs)    if ( op == "*" ) {
    x *= rhs;
    y *= rhs;
    return this;
  }
  ref Vector opBinary(string op)(Vector rhs)   if ( op == "/" ) {
    return new Vector(x / rhs.x, y / rhs.y);
  }
  ref Vector opOpAssign(string op)(Vector rhs) if ( op == "/" ) {
    x /= rhs.x;
    y /= rhs.y;
    return this;
  }
  ref Vector opOpAssign(string op)(int rhs)    if ( op == "/" ) {
    x /= rhs;
    y /= rhs;
    return this;
  }
  string opCast(T)() if (is(T == string)) {
    import std.conv : to;
    return "< " + to!string(x) + ", " + to!string(y) + " >";
  }

  //                      utility methods

  void Normalize() {
    float mag = Magnitude();
    if ( mag > 0 ) {
      x /= mag;
      y /= mag;
    }
  }

  import std.math;

  float Distance(const ref Vector _vector) {
    return sqrt((x*x - _vector.x*_vector.x) + (y*y - _vector.y*_vector.y));
  }

  float Angle() {
    return atan2(y, x);
  }

  float Angle(const ref Vector _vector) {
    return atan2(_vector.y - y, _vector.x - x);
  }

  float Magnitude() {
    return sqrt((x*x) + (y*y));
  }

  float Dot_Product(const ref Vector _vector) {
    return x * _vector.x + y * _vector.y;
  }


  // projects other vector onto this one
  void Project(const ref Vector _vector) {
    float dot_prod = Dot_Product(_vector);
    x = (dot_prod / (pow(_vector.x, 2 ) +
                     pow(_vector.y, 2 )) ) * _vector.x;
    y = (dot_prod / (pow(_vector.x, 2 ) +
                     pow(_vector.y, 2 )) ) * _vector.y;
  }

  // gives right hand normal of vector
  void Right_Normal(const ref Vector vec) {
  x =  (vec.x - x);
  y = -(vec.y - y);
  }
  // gives left hand normal of vector
  void Left_Normal(const ref Vector vec) {
  x = -(vec.x - x);
  y =  (vec.y - y);
  }

  static Vector Reflect(const Vector I, const Vector N) {
    return I - (N*2.f * I) * N;
  }

  import AOD.Matrix;
  static Vector Transform(const ref Matrix mat, const ref Vector vec) {
    Vector v;
    v.x = vec.x * mat.a + vec.y * mat.c + mat.tx;
    v.y = vec.x * mat.b + vec.y * mat.d + mat.ty;
    return v;
  }

}
