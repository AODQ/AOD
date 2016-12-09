module Entity.Upgrade;
static import AOD;
import Data;
import Game_Manager;

class Upgrade : AOD.PolyEntity {

public:
  enum Type {
    new_ball,
    ball_speed,
    paddle_speed,
    larger_ball,
    size
  };
  Type type;
  this(AOD.Vector _position, AOD.Vector _velocity) {
    Set_Position(_position);
    Set_Velocity(_velocity);
    type = cast(Type)AOD.Util.R_Rand(0, cast(int)Type.size);
    Set_Sprite(Image_Data.upgrades[cast(int)type], 1);
    Set_Vertices([
      AOD.Vector(-size.x/2.0f, -size.y/2.0f),
      AOD.Vector( size.x/2.0f, -size.y/2.0f),
      AOD.Vector( size.x/2.0f,  size.y/2.0f),
      AOD.Vector(-size.x/2.0f,  size.y/2.0f),
    ]);
  }
  override void Update() {
    velocity.y += 0.125;
    velocity.y = AOD.Util.R_Min(velocity.y, 8.0f);

    if ( position.x < 0 || position.x + size.x > AOD.R_Window_Width ) {
      velocity.x *= -1;
      if ( position.x < 0 ) ++ position.x;
      else                  -- position.x;
    }

    if ( Game_Manager.paddle is null ) return;
    auto col = Collision(Game_Manager.paddle, velocity);
    if ( !col.will_collide ) return;
    // activate upgrade
    switch ( type ) {
      case Type.new_ball:     Activate_New_Ball();     break;
      case Type.ball_speed:   Activate_Ball_Speed();   break;
      case Type.paddle_speed: Activate_Paddle_Speed(); break;
      case Type.larger_ball:  Activate_Larger_Ball();  break;
      default: assert(0);
    }
    Game_Manager.Remove(this);
  }

  import std.stdio;
  static void Activate_New_Ball() {
    import Entity.Ball;
    if ( Game_Manager.paddle !is null ) {
      auto ball = new Ball(10);
      Game_Manager.Add(ball);
      Game_Manager.paddle.Add_Ball(ball);
    }
  }

  static void Activate_Ball_Speed() {
    import Entity.Ball;
    foreach ( b; Game_Manager.balls ) {
      b.Set_Ball_Speed(b.R_Default_Speed() * 2.5f, cast(int)AOD.R_MS()*30);
    }
  }

  static void Activate_Larger_Ball() {
    import Entity.Ball;
    foreach ( b; Game_Manager.balls ) {
      b.Set_Ball_Size(b.R_Default_Size() * 4.5f, cast(int)AOD.R_MS()*20);
    }
  }

  static void Activate_Paddle_Speed() {
    import Entity.Paddle;
    auto p = Game_Manager.paddle;
    if ( p !is null ) {
      p.Set_Speed(p.R_Default_Speed() * 3.5f, cast(int)AOD.R_MS()*30);
    }
  }
}
