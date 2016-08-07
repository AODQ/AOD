module AODCore.matrix;

import AODCore.vector;

struct Matrix {
public:
  float a, b, c, d, tx, ty;
  float rot, prev_rot;
  Vector scale;

  this(float _a, float _b, float _c,
       float _d, float _tx, float _ty) {
    a = _a; b = _b; c = _c; d = _d; tx = _tx; ty = _ty;
    rot = prev_rot = 0;
    scale = Vector( 1,1 ); 
  }

  static Matrix New() {
    return Matrix(1, 0, 0, 1, 0, 0);
  }

  void Identity() {
    a = 1;  b = 0;    c = 0;
    d = 1;  tx = 0;  ty = 0;
  }

  void Translate(const ref Vector vec) {
    tx += vec.x;
    ty += vec.y;
  }

  void Translate(float x, float y) {
    tx += x;
    ty += y;
  }

  void Set_Translation(float x, float y) {
    tx = x;
    ty = y;
  }

  void Set_Translation(const ref Vector vec) {
    tx = vec.x;
    ty = vec.y;
  }

  void Compose(const Vector pos, float RADIANS,
                     Vector scale) {
    Identity();

    Scale( scale );
    Rotate( rot );
    Set_Translation( pos );
  }

  void Rotate(float r) {
    import std.math;
    float x = cos(r),
          y = sin(r);

    float a1 = a * x - b * y;
    b = a * y + b * x;
    a = a1;

    float c1 = c * x - d * y;
    d = c * y + d * x;
    c = c1;

    float tx1 = tx * x - ty * y;
    ty = tx * y + ty * x;
    tx = tx1;
  }

  void Scale(Vector sc) {
    a *= sc.x;
    b *= sc.y;

    c *= sc.x;
    d *= sc.y;

    tx *= sc.x;
    ty *= sc.y;
  }
}
