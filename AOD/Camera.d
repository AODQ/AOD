module AODCore.camera;

import AODCore.vector;

private Vector position;
private Vector size;

void Set_Position(Vector pos) {
  position = pos;
}

void Set_Position(float x, float y) {
  position = Vector(x, y);
}

void Set_Size(Vector siz) {
  if ( siz.x <= 0 || siz.y <= 0 ) return;
  size = siz;
}

void Set_Size(float x, float y) {
  if ( x <= 0 || y <= 0 ) return;
  size = Vector(x, y);
}

Vector R_Size()     { return size;     }
Vector R_Position() { return position; }
Vector R_Origin_Offset() { return position - (size/2.0); }
