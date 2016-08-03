import AOD.AOD;
import AODUtil = AOD.Utility;

private AODUtil.Vector position;
private AODUtil.Vector size;

void Set_Position(const ref Vector pos) {
  position = pos;
}

void Set_Position(float x, float y) {
  position = new AODUtil.Vector(x, y);
}

void Set_Size(const ref Vector siz) {
  if ( siz.x <= 0 || siz.y <= 0 ) return;
  size = siz;
}

void Set_Size(float x, float y) {
  if ( x <= 0 || y <= 0 ) return;
  Camera.size = new AODUtil.Vector(x, y);
}

AODUtil.Vector R_Size() { return size; }
AODUtil.Vector R_Position() { return position; }
