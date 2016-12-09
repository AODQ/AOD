module Entity.Boss;
static import AOD;
import Data;

class Boss : AOD.PolyEntity {
public:
  bool key_left, key_right, key_down, key_jump, key_prim;
  bool in_air;

  this() {
    super();
    /* Set_Sprite(Image_Data.boss); */
    Set_Position(50.0f, 50.0f);
  }

  override void Update() {
    key_left = key_right = key_down = key_jump = key_prim = false;
    // check keybinds
    foreach ( k; AOD.ClientVars.keybinds ) {
      if ( AOD.Input.keystate[ k.key ] ) {
        switch ( k.command ) {
          default: break;
          case "left":  key_left  = true; break;
          case "right": key_right = true; break;
          case "down":  key_down  = true; break;
          case "jump":  key_jump  = true; break;
          case "prim":  key_prim  = true; break;
          /* case "crouch" */
        }
      }
    }

    velocity.x *= 0.899f;

    if ( key_left ) {
      Add_Velocity(AOD.Vector(-2.0f, 0.0f));
    }
    if ( key_right ) {
      Add_Velocity(AOD.Vector( 2.0f, 0.0f));
    }


    if ( in_air ) {
      velocity.y += 0.025;
    }
  }
}
