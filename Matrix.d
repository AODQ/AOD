module AOD.Matrix;

import AOD.Vector;

struct Matrix {
  public:
  float a, b, c, d, tx, ty;
  float rot, prev_rot;
  Vector scale;

  Matrix(float _a = 1, float _b = 0, float _c = 0,
         float _d = 1, float _tx = 0, float _ty = 0);
    a = _a, b = _b, c = _c, d = _d, tx = _tx, ty = _ty;
    rot = prev_rot = 0;
    scale = new Vector( 1,1 ); 
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

  void Set_Translation(const ref AOD::Vector vec) {
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
    import std.math
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
