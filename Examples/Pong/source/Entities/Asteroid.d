module Entity.Asteroid;
static import AOD;
static import Game_Manager;
import Data;
import std.random;

class Asteroid : AOD.PolyEntity {
public:
  enum Size { nil = 0, tiny = 8, small = 16, medium = 32, large = 64 }
	this(Size sz, AOD.Vector pos, AOD.Vector vel) {
    super(Layer_Data.Asteroid);
    import std.conv : to;
    size = sz;

		Set_Velocity(vel);
		Set_Position(pos);
    import std.stdio : writeln;
    writeln("Position: " ~ cast(string)pos);
    Set_Size(sz, sz);
		switch (sz) {
      case Size.tiny:
        Set_Sprite(Image_Data.meteor_tiny[cast(uint)AOD.Util.R_Rand(0,8)]);
        break;
      case Size.small:
        Set_Sprite(Image_Data.meteor_small[cast(uint)AOD.Util.R_Rand(0,4)]);
        break;
      case Size.medium:
        Set_Sprite(Image_Data.meteor_medium[cast(uint)AOD.Util.R_Rand(0,2)]);
        break;
      case Size.large:
        Set_Sprite(Image_Data.meteor_large);
        break;
      default:
		}
    Randomize_Torque();
    Set_Size(64, 64);
    Set_Vertices(Construct_Vertices(sz));

    import std.stdio;
	}

	this(Size sz) {
		this(sz, AOD.Vector(640/2, 480/2),
        AOD.Vector(AOD.Util.R_Rand(1, 1.5) * (AOD.Util.R_Rand(0, 2) > 1?1:-1),
                   AOD.Util.R_Rand(1, 1.5) * (AOD.Util.R_Rand(0, 2) > 1?1:-1)));
	}

	~this() {
	}

  // We need this here otherwise if the game ended and all instances were
  // removed, then bad stuff happens
  void Destroy() {
    auto R_Size_Decremented(Size sz) {
      switch ( sz ) {
        default:
        case Size.tiny   : return Size.nil;
        case Size.small  : return Size.tiny;
        case Size.medium : return Size.small;
        case Size.large  : return Size.medium;
      }
    }
    auto R_Meteor_Amt(Size sz) {
      switch ( sz ) {
        default:
        case Size.tiny   : return 0;
        case Size.small  : return 8;
        case Size.medium : return 4;
        case Size.large  : return 2;
      }
    }
    int sound_index = cast(int)AOD.Util.R_Rand(0, 7);
    AOD.Play_Sound(Sound_Data.sf[sound_index],
        -(R_Position.x-AOD.R_Window_Width /2)/10,
         (R_Position.y-AOD.R_Window_Height/2)/50,
         (R_Position.y-AOD.R_Window_Height/2)/50);
		Size temp = R_Size_Decremented(size);
    import std.math;
    foreach ( e; 0 .. R_Meteor_Amt(size) ) {
			AOD.Vector vel = AOD.Vector(
          AOD.Util.R_Rand(1, 1.5) * (AOD.Util.R_Rand(0, 2) > 1?1:-1),
          AOD.Util.R_Rand(1, 1.5) * (AOD.Util.R_Rand(0, 2) > 1?1:-1));
      vel *= log(size)/2.5f;
      auto a = new Asteroid(temp, R_Position(), vel);
      Game_Manager.Add(a);
    }
    if ( AOD.Util.R_Rand(5 * cast(int)log(size), 100) > 50 ) {
      import Entity.Upgrade;
      alias Rand = AOD.Util.R_Rand;
      Game_Manager.Add(new Upgrade(position, AOD.Vector(Rand(-3.0f,  3.0f),
                                                        Rand(-8.0f, -2.0f))));
    }
  }

 void Randomize_Torque() {
   int mult;
   switch (  size ) {
      case Size.tiny:   mult = 10; break;
      case Size.small:  mult =  5; break;
      case Size.medium: mult =  2; break;
      case Size.large:  mult =  1; break;
      default: break;
   }
  Set_Torque(AOD.Util.R_Rand(-0.01f, 0.1f));
 }

  override void Update() {
    // -- collision --
    if ( position.x - R_Size().x/2.0f + velocity.x < 0 ||
         position.x + R_Size().x/2.0f + velocity.x > AOD.R_Window_Width() ) {
      velocity.x *= -1;
    }

    if ( position.y - R_Size().x/2.0f + velocity.y < 0 &&
		 position.y - R_Size().x/2.0f > 0||
         position.y + R_Size().x/2.0f + velocity.y > 360 ) {
      velocity.y *= -1;
    }
  }

  static auto Construct_Vertices(Size s) {
    return [AOD.Vector(-s/2.0f, -s/2.0f),
            AOD.Vector(-s/2.0f,  s/2.0f),
            AOD.Vector( s/2.0f,  s/2.0f),
            AOD.Vector( s/2.0f, -s/2.0f)];
  }

private:
	Size size;
}
