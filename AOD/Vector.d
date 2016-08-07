module AODCore.vector;

struct Vector {
public:
  float x, y;
  this(float _x, float _y ) { x = _x; y = _y; }
  this(int   _x, int   _y ) { x = cast(float)_x; y = cast(float)_y; }
  this(Vector v) { x = v.x; y = v.y; }

  Vector opAssign(Vector rhs) {
    x = rhs.x;
    y = rhs.y;
    return this;
  }
  Vector opBinary(string op)(Vector rhs)   if ( op == "+" ) {
    return Vector(x + rhs.x, y + rhs.y);
  }
  Vector opBinary(string op)(float rhs)    if ( op == "+" ) {
    return Vector(x + rhs, y + rhs);
  }
  Vector opOpAssign(string op)(Vector rhs) if ( op == "+" ) {
    x += rhs.x;
    y += rhs.y;
    return this;
  }
  Vector opOpAssign(string op)(float rhs)  if ( op == "+" ) {
    x += rhs;
    y += rhs;
    return this;
  }
  Vector opBinary(string op)(Vector rhs)   if ( op == "-" ) {
    return Vector(x - rhs.x, y - rhs.y);
  }
  Vector opBinary(string op)(float rhs)    if ( op == "-" ) {
    return Vector(x - rhs, y - rhs);
  }
  Vector opOpAssign(string op)(Vector rhs) if ( op == "-" ) {
    x -= rhs.x;
    y -= rhs.y;
    return this;
  }
  Vector opOpAssign(string op)(float rhs)  if ( op == "-" ) {
    x -= rhs;
    y -= rhs;
    return this;
  }
  Vector opBinary(string op)(Vector rhs)   if ( op == "*" ) {
    return Vector(x * rhs.x, y * rhs.y);
  }
  Vector opBinary(string op)(float rhs)    if ( op == "*" ) {
    return Vector(x * rhs, y * rhs);
  }
  Vector opOpAssign(string op)(Vector rhs) if ( op == "*" ) {
    x *= rhs.x;
    y *= rhs.y;
    return this;
  }
  Vector opOpAssign(string op)(float rhs)  if ( op == "*" ) {
    x *= rhs;
    y *= rhs;
    return this;
  }
  Vector opBinary(string op)(Vector rhs)   if ( op == "/" ) {
    return Vector(x / rhs.x, y / rhs.y);
  }
  Vector opBinary(string op)(float rhs)    if ( op == "/" ) {
    return Vector(x / rhs, y / rhs);
  }
  Vector opOpAssign(string op)(Vector rhs) if ( op == "/" ) {
    x /= rhs.x;
    y /= rhs.y;
    return this;
  }
  Vector opOpAssign(string op)(float rhs)  if ( op == "/" ) {
    x /= rhs;
    y /= rhs;
    return this;
  }
  string opCast(T)() if (is(T == string)) {
    import std.conv : to;
    return "< " ~ to!string(x) ~ ", " ~ to!string(y) ~ " >";
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

  float Distance(Vector _vector) {
    return sqrt((x*x - _vector.x*_vector.x) + (y*y - _vector.y*_vector.y));
  }

  float Angle() {
    return atan2(y, x);
  }

  float Angle(Vector _vector) {
    return atan2(_vector.y - y, _vector.x - x);
  }

  float Magnitude() {
    return sqrt((x*x) + (y*y));
  }

  float Dot_Product(Vector _vector) {
    return x * _vector.x + y * _vector.y;
  }


  // projects other vector onto this one
  void Project(Vector _vector) {
    float dot_prod = Dot_Product(_vector);
    x = (dot_prod / (pow(_vector.x, 2 ) +
                     pow(_vector.y, 2 )) ) * _vector.x;
    y = (dot_prod / (pow(_vector.x, 2 ) +
                     pow(_vector.y, 2 )) ) * _vector.y;
  }

  // gives right hand normal of vector
  void Right_Normal(Vector vec) {
  x =  (vec.x - x);
  y = -(vec.y - y);
  }
  // gives left hand normal of vector
  void Left_Normal(Vector vec) {
  x = -(vec.x - x);
  y =  (vec.y - y);
  }

  static Vector Reflect(Vector I, Vector N) {
    return I - (N*2.0f * I) * N;
  }

  import AODCore.matrix;

  static Vector Transform(Matrix mat, Vector vec) {
    Vector v;
    v.x = vec.x * mat.a + vec.y * mat.c + mat.tx;
    v.y = vec.x * mat.b + vec.y * mat.d + mat.ty;
    return v;
  }

}
