module Entity.Ball;
static import AOD;
static import Game_Manager;
import Data;
import std.math;

class Ball : AOD.PolyEntity {
  float speed;
  float default_size;
  int speed_timer, size_timer;
  static immutable(float) Default_speed = 5.0f;
  void Refresh_Vertices() {
    Set_Vertices([
      AOD.Vector(-size.x / 2.0f, -size.x / 2.0f),
      AOD.Vector( size.x / 2.0f, -size.x / 2.0f),
      AOD.Vector( size.x / 2.0f,  size.x / 2.0f),
      AOD.Vector(-size.x / 2.0f,  size.x / 2.0f),
    ]);
  }
public:
  AOD.Vector direction = AOD.Vector(0.0f, 0.0f);

  void Set_Ball_Speed(float _speed, int _speed_timer) {
    speed = _speed;
    speed_timer = _speed_timer;
  }

  void Set_Ball_Size(float _size, int _size_timer) {
    Set_Size(AOD.Vector(_size, _size), true);
    size_timer = _size_timer;
    Refresh_Vertices();
  }

  this(float size) {
    super(Layer_Data.Ball);
    default_size = size;
    Set_Size(AOD.Vector(size, size));

    Set_Sprite(Image_Data.ball);

    Set_Size(AOD.Vector(size, size), true);
    speed = Default_speed;
    Refresh_Vertices();
  }

  ~this() {
  }

  float R_Default_Speed() { return Default_speed; }
  float R_Default_Size()  { return default_size;  }
  float R_Speed()         { return speed;         }

  override void Update() {
    // -- upgrade management --
    if ( speed_timer > 0 && --speed_timer == 0 ) {
      speed = Default_speed;
    }
    if ( size_timer  > 0 && --size_timer  == 0 ) {
      Set_Size(AOD.Vector(default_size, default_size), true);
      Refresh_Vertices();
    }

    // -- velocity/collision --
    direction.Normalize();

    velocity = direction * speed;

    if ( position.x - size.x / 2.0f + velocity.x < 0 ||
         position.x + size.x / 2.0f + velocity.x > AOD.R_Window_Width() ) {
      direction.x = -direction.x;
    }

    if ( position.y - size.x / 2.0f + velocity.y < 0 ) {
      direction.y = -direction.y;
      ++ position.y;
    }

    if ( position.y - size.x > AOD.R_Window_Height ) {
      if ( Game_Manager.balls.length == 1 )
        Game_Manager.Restart_Game();
      else
        Game_Manager.Remove(this);
    }

    static int coll_timer = 0;

    import std.stdio;
    if ( coll_timer == 0 ) {
      if ( Game_Manager.paddle is null ) return;
      auto col = Collision(Game_Manager.paddle, velocity);
      if ( col.will_collide && Game_Manager.paddle.R_Stored_Ball !is this ) {
        writeln("COLLIDE");
        Add_Position(col.translation);
        direction.x = (position.x - Game_Manager.paddle.R_Position.x)
                      / Game_Manager.paddle.R_Width();
        direction.y = -sqrt(1-direction.x*direction.x);
        coll_timer = 16;
      }
      foreach ( asteroid; Game_Manager.asteroids ) {
        col = Collision(asteroid, velocity);
        if ( col.will_collide ) {
          direction *= -1;
          direction.x = AOD.Util.R_Rand(-1, 1);
          direction.y = AOD.Util.R_Rand(-1, 1);
          asteroid.Destroy();
          Game_Manager.Remove(asteroid);
          coll_timer = 16;
          break;
        }
      }
    } else -- coll_timer;
  }
}
