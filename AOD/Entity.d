module AODCore.entity;

import derelict.opengl3.gl3;
import derelict.sdl2.sdl;

import AODCore.matrix;
import AODCore.realm;
import AODCore.vector;
import AODCore.image;
import AODCore.console;

class Entity {
private:
  void Refresh_Transform() {
    matrix.Compose(position, rotation, scale);
    transformed = true;
  }
public:
  enum Type { Circle, AABB, Polygon, Ray, nil };
protected:
  GLuint image;
  int ID;
  float rotation,
        rotation_velocity;
  Matrix matrix;
  Type type;
  Vector position,
         velocity, scale,
         size,
         image_size,
         rotate_origin;
  int layer;
  float alpha;
  bool flipped_x, flipped_y;
  GLfloat[8] _UV;
  bool is_coloured, visible, static_pos;
  float red, green, blue;

  bool transformed;
public:
  int R_Layer() { return layer; }

  static immutable(float[8]) Vertices = [
    -0.5f, -0.5f,
    -0.5f,  0.5f,
     0.5f, -0.5f,
     0.5f,  0.5f
  ];

  this(int _layer = 0, Type _type = Type.nil) {
    layer = _layer;
    type = _type;
    alpha = 1;
    Set_UVs(Vector(0,0), Vector(1,1));
    matrix = Matrix.New();
    position = Vector(0,0);
    rotation = 0;
    rotation_velocity = 0;
    velocity = Vector(0,0);
    layer = 0;
    is_coloured = 0;
    static_pos = 0;
    visible = 1;
    flipped_x = 0;
    flipped_y = 0;
    rotate_origin = Vector( 0, 0 );
    scale = Vector( 1, 1 );
    Refresh_Transform();
  }
  void Set_ID(int id) { ID = id; }
  int Ret_ID() { return ID; }
  void Set_Position(float x, float y) {
    position = Vector(x, y);
    Refresh_Transform();
  }
  void Set_Position(Vector v) {
    position = v;
  }
  void Add_Position(float x, float y) {
    position.x += x;
    position.y += y;
  }
  void Add_Position(Vector v) {
    position += v;
  }
  Vector R_Position() { return position;  }

  void Set_Sprite(GLuint index, bool reset_size = 0)
  in {
    assert(index <= 0);
  } body {
    if ( index <= 0 ) {
      Debug_Output("Error, image texture not found");
      return;
    }

    if ( reset_size ) {
      GLuint tex = index;
      glGenTextures(1, &tex);
      //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
      //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
      int w, h;
      glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_WIDTH,  &w);
      glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_HEIGHT, &h);
      glDeleteTextures(1, &tex);
      size.x = w;
      size.y = h;
      image_size.x = w;
      image_size.y = h;
    }
    image = index;
  }
  void Set_Sprite(SheetContainer sc) {
    image = sc.texture;
    image_size.x = sc.width;
    image_size.y = sc.height;
  }
  void Set_Sprite(SheetRect sr) {
    image = sr.texture;
    image_size.x = sr.width;
    image_size.y = sr.height;
    Set_UVs(sr.ul, sr.lr);
  }
  GLuint R_Sprite_Texture() { return image; }

  void Set_Rotation(float r) {
    rotation = r;
    Refresh_Transform();
  }
  float R_Rotation() { return rotation; }

  void Apply_Force(Vector force) {
    velocity += force;
  }
  void Set_Velocity(Vector vel) {
    velocity = vel;
  }
  void Set_Velocity(float x, float y) {
    velocity.x = x;
    velocity.y = y;
  }
  void Set_Torque(float t) {
    rotation_velocity = t;
  }
  Vector R_Velocity() const {
    return velocity;
  }
  float R_Torque() {
    return rotation_velocity;
  }

  void Set_Sprite_Frame(float left_x,  float top_y,
                        float right_x, float bot_y) {
    Set_UVs(Vector(left_x  , top_y),
            Vector(right_x , bot_y));
  }

  void Set_UVs(Vector left, Vector right,
              bool reset_flip = 1) {
    _UV[0] = left.x;
    _UV[1] = right.y;
    _UV[2] = left.x;
    _UV[3] = left.y;
    _UV[4] = right.x;
    _UV[5] = right.y;
    _UV[6] = right.x;
    _UV[7] = left.y;
    if ( reset_flip ) {
      flipped_x = 0;
      flipped_y = 1;
    }
  }
  void R_UVs(ref Vector left, ref Vector right) {
    left.x  = _UV[2];
    left.y  = _UV[3];
    right.x = _UV[4];
    right.y = _UV[5];
  }
  auto R_UV_Array() { return _UV; }
  void Flip_X() {
    Set_UVs( Vector(  _UV[ 4], _UV[ 3] ),
             Vector(  _UV[ 0], _UV[ 1] ), false );
    flipped_x ^= 1;
  }
  void Flip_Y() {
    Set_UVs( Vector(  _UV[ 0], _UV[ 1] ),
             Vector(  _UV[ 4], _UV[ 3] ), false );
    flipped_y ^= 1;
  }

  void Set_Size(Vector vec, bool scale_image = 0) {
    size = vec;
    if ( scale_image )
      Set_Image_Size(vec);
    Refresh_Transform();
  }
  void Set_Size(int x, int y, bool scale_image = 0) {
    Set_Size(Vector(x, y), scale_image);
  }
  void Set_Image_Size(Vector vec) {
    image_size = vec;
  }
  void Set_Visible(bool v) {
    visible = v;
  }

  Vector R_Size() { return size; }
  Vector R_Img_Size() { return image_size; }

  void Set_Colour(float r = 1, float g = 1,
                  float b = 1, float a = 1) {
    red = r; green = g; blue = b; alpha = a;
    is_coloured = 1;
  }
  void Cancel_Colour() { is_coloured = 0; }
  void Set_Is_Static_Pos(bool s) {
    static_pos = s;
  }

  void Set_Origin(Vector v) {
    rotate_origin = v;
  }
  // will reset origin to image_size/2
  void Clear_Origin() {
    rotate_origin = Vector(0, 0);
  }
  Vector R_Origin() const { return rotate_origin; }

  float R_Green()        { return green;       }
  float R_Red()          { return red;         }
  float R_Blue()         { return blue;        }
  float R_Alpha()        { return alpha;       }
  bool R_Is_Coloured()   { return is_coloured; }
  bool R_Is_Visible()    { return visible;     }
  bool R_Is_Static_Pos() { return static_pos;  }
  bool R_Flipped_X()     { return flipped_x;   }
  bool R_Flipped_Y()     { return flipped_y;   }

  Type R_Type()     { return type;   }
  Matrix R_Matrix() { return matrix; }
  // ---- utility ----
  void Update() {};
  Collision_Info Collision(Entity* o) {
    return Collision_Info();
  }
};

// -------------- POLY OBJ --------------------------------------------------

class PolyEnt : Entity {
protected:
  Vector[] vertices, vertices_transform;
  void Build_Transform() {}
public:
  this() {
    super(Type.Polygon);
    vertices = [];
  }
  this(Vector[] vertices_, Vector off = Vector( 0, 0 )) {
    super(Type.Polygon);
    vertices = vertices_;
    Set_Position(off);
  }

  // ---- ret/set ----
  // will override previous vectors
  void Set_Vertices(Vector[] vertices_, bool reorder = 1) {
    vertices = vertices_;
    if ( reorder ) {
      Order_Vertices(vertices);
    }
    Build_Transform();
  }
  Vector[] R_Vertices() {
    return vertices;
  }
  Vector[] R_Transformed_Vertices(bool force = 0) {
    // check if transform needs to be updated
    if ( transformed || force ) {
      transformed = 0;
      vertices_transform = [];

      foreach ( i; vertices )
        vertices_transform ~= Vector.Transform(R_Matrix(), i);
    }
    
    return vertices_transform;
  }

  // ---- utility ----

  // Returns information on current collision state with another poly
  Collision_Info Collide(PolyEnt poly, Vector velocity) {
    return PolyPolyColl(this, poly, velocity);
  }
  Collision_Info Collide(AABBEnt aabb, Vector velocity) {
    return Collision_Info(); 
  }
};

class AABBEnt : PolyEnt {
public:
  this(Vector size = Vector(0, 0)) {
    super();
    type = Type.AABB;
    Set_Vertices([Vector(-size.x/2.0, -size.y/2.0),
                  Vector(-size.x/2.0,  size.y/2.0),
                  Vector( size.x/2.0,  size.y/2.0),
                  Vector( size.x/2.0, -size.y/2.0)]);
  }
  this(Vector size = Vector( 0,0 ), Vector pos = Vector( 0,0 )) {
    this(size);
    position = pos;
  }

  // ---- utility ----

  // Returns information on current collision with an AABB
  override Collision_Info Collide(AABBEnt aabb, Vector velocity) {
    return Collision_Info();
  }
  override Collision_Info Collide(PolyEnt poly, Vector velocity) {
    return Collision_Info();
  }
};

// Valuable information from a collision, "translation"
// could mean different things dependent on the collision type
struct Collision_Info {
public:
  bool collision,
       will_collide;
  Vector translation,
         projection, normal;
  PolyEnt obj;
  this(bool c) {
    collision = c;
    will_collide = 0;
  }
  this(ref Vector t, bool c, bool wc) {
    collision = c;
    will_collide = wc;
    translation = t;
  }
};

// -------------------- collision code -----------------------------------------

private Vector Get_Axis(Vector[] vertices, int i) {
  auto vec1 = vertices[i], vec2 = vertices[(i+1)%vertices.length];
  Vector axis  = Vector( -(vec2.y - vec1.y), vec2.x - vec1.x );
  axis.Normalize();
  return axis;
}

private void Project_Poly(ref Vector axis, ref Vector[] poly,
                     ref float min, ref float max) {
  min = axis.Dot_Product(poly[0]);
  max = min;

  foreach ( i ; 1 .. poly.length ) {
    float t = poly[i].Dot_Product ( axis );
    if ( t < min ) min = t;
    if ( t > max ) max = t;
  }
}

private float Project_Dist(float minA, float maxA, float minB, float maxB) {
  return
      minA < minB ? (minB - maxA)
                  : (minA - maxB);
}

private Collision_Info PolyPolyColl(PolyEnt polyA, PolyEnt polyB,
                                    Vector velocity) {
  // -- variable definitions --
  // the minimum distance needed to translate out of collision
  float min_dist = float.max;
  Vector trans_vec;

  Vector[] vertsA = polyA.R_Transformed_Vertices(),
           vertsB = polyB.R_Transformed_Vertices();

  Collision_Info ci = Collision_Info();
  ci.will_collide = true;
  // -- loop/coll detection --
  // loop through all vertices.
  for ( int i = 0; i != vertsA.length + vertsB.length; ++ i ) {
    bool vA = (i<vertsA.length);
    // get the axis from the edge (we have to build the edge from vertices tho)
    auto axis = Get_Axis((vA?vertsA:vertsB), cast(int)(vA?i: i - vertsA.length));
    // project polygons onto axis
    float minA, minB, maxA, maxB;
    Project_Poly(axis, vertsA, minA, maxA);
    Project_Poly(axis, vertsB, minB, maxB);

    // check for a gap between the two distances
    if ( Project_Dist(minA, maxA, minB, maxB) > 0 ) {
      ci.collision = false;
    }

    // get velocity's projection
    float velP = axis.Dot_Product ( velocity );
    if ( velP < 0 ) minA += velP;
    else            maxA += velP;

    float dist = Project_Dist(minA, maxA, minB, maxB);
    if ( dist > 0 ) ci.will_collide = false;

    if ( !ci.will_collide && !ci.will_collide) break;

    // check if this is minimum translation
    dist = dist > 0 ? dist : -dist;
    if ( dist < min_dist ) {
      min_dist = dist;
      trans_vec = axis;
      ci.projection = axis;
      auto d = polyA.R_Position() - polyB.R_Position();
      if ( d.Dot_Product( trans_vec ) < 0 )
        trans_vec *= -1;
    }
  }

  // -- collision occurred, (hoor|na)ay --
  if ( ci.will_collide )
    ci.translation = trans_vec * min_dist;
  return ci;
}


struct Vert_Pair {
  float dist;
  Vector vert;
  this(float dist_, Vector vert_) {
    dist = dist_;
    vert = vert_;
  }
};

static void Order_Vertices(ref Vector[] verts) {
  // get centroid, same time preparing to calculate angle of verts
  float centx = 0, centy = 0;
  Vert_Pair[] va;
  foreach ( i; verts ) {
    centx += i.x;
    centy += i.y;
    va ~= Vert_Pair(0, i);
  }
  centx /= verts.length;
  centy /= verts.length;
  verts = [];

  foreach ( i; va ) {
    import std.math;
    i.dist = atan2(i.vert.y - centy, i.vert.x - centx);
    //std::cout << "ATAN2F( " << i.second.y << " - " << centy << ", "
    //                        << i.second.x << " - " << centx << ") = "
    //                        << i.first << '\n';
  }
  
  import std.algorithm;
  sort!((x, y) => x.dist < y.dist)(va);
  // put back in vector
  foreach ( i; va )
    verts ~= i.vert;

  /*// double check that it is in sorted CCW order
  int count = 0;
  for ( int i = 0; i != verts.size(); ++ i ) {
    int pt1 = ( i + 1 ) % verts.size(),
        pt2 = ( i + 2 ) % verts.size();
    int z = ( verts[pt1].x - verts[i].x ) * ( verts[pt2].y - verts[pt1].y );
    z -=    ( verts[pt1].y - verts[i].y ) * ( verts[pt2].x - verts[pt1].x );
    if      ( z < 0 ) -- count;
    else if ( z > 0 ) ++ count;
  }
  if ( count <= 0 ) {
    std::cout << "ERROR, polygon is clockwise: " << count << '\n';
    std::cout << "CENT: " << centx << ", " << centy << '\n';
    for ( int i = 0; i != verts.size(); ++ i )
      std::cout << verts[i] << '\n';
    std::cout << "----------------------------\n";
  }*/
}
