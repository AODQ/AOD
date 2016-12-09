module Data;
static import AOD;

enum Layer_Data {
  Asteroid = 49,
  Paddle   = 50,
  Ball     = 51
}
class Menu {
public: static:
  AOD.SheetRect splashscreen;
  AOD.SheetRect background, background_submenu;
  AOD.SheetRect[] credits;
  AOD.SheetRect[AOD.Menu.Button.max+1] buttons;
  string[] text_credits;
  string[] controls;
  immutable(int) button_y      = 280,
                 button_y_it   = 50,
                 credit_y      = 255,
                 credit_y_it   = 60,
                 credit_text_x = 20,
                 credit_img_x  = 500;
  void Initialize() {
    alias SR = AOD.SheetRect;
    alias SC = AOD.SheetContainer;
    background = cast(SR)SC("assets/menu/background.png");
    background_submenu = cast(SR)SC("assets/menu/background-submenu.png");
    buttons = [
      cast(SR)SC("assets/menu/button_start.png"),
      cast(SR)SC("assets/menu/button_controls.png"),
      cast(SR)SC("assets/menu/button_credits.png"),
      cast(SR)SC("assets/menu/button_quit.png"),
      cast(SR)SC("assets/menu/button_back.png")
    ];
    text_credits = [
                    "AODQ - Engine, Code",
                    "Nadjatee1996 - Code",
                    "Smilecythe   - Pixels, Music",
                    "WEAF         - Code",
                   ];
    controls = [
      "up", "down"
    ];
  }
}

auto Construct_New_Menu() {
  static import Game_Manager;
  return new AOD.Menu(
    Data.Menu.background, Data.Menu.background_submenu,
    Data.Menu.buttons,    Data.Menu.text_credits,
    new Game_Manager.Gmanage, Data.Menu.button_y, Data.Menu.button_y_it,
    Data.Menu.credit_y, Data.Menu.credit_y_it, Data.Menu.credit_text_x,
    Data.Menu.credit_img_x
  );
}

class Image_Data {
public: static:
  AOD.SheetContainer paddle, ball;
  AOD.SheetRect    meteor_large; // 64x64
  AOD.SheetRect[2] meteor_medium; // 32x32
  AOD.SheetRect[4] meteor_small; // 16x16
  AOD.SheetRect[8] meteor_tiny; // 8x8
  AOD.SheetRect[4] upgrades;

  void Initialize() {
    Menu.Initialize();
    paddle       = AOD.SheetContainer("assets/paddle.png"   ) ;
    ball         = AOD.SheetContainer("assets/ball.png"     ) ;
    auto meteor  = AOD.SheetContainer("assets/meteor.png"   ) ;
    auto upgrade = AOD.SheetContainer("assets/upgrades.png" ) ;
    meteor_tiny = [
      AOD.SheetRect(meteor, AOD.Vector(0,  0), AOD.Vector(8,  8)),
      AOD.SheetRect(meteor, AOD.Vector(0,  8), AOD.Vector(8, 16)),
      AOD.SheetRect(meteor, AOD.Vector(0, 16), AOD.Vector(8, 24)),
      AOD.SheetRect(meteor, AOD.Vector(0, 24), AOD.Vector(8, 32)),
      AOD.SheetRect(meteor, AOD.Vector(0, 32), AOD.Vector(8, 40)),
      AOD.SheetRect(meteor, AOD.Vector(0, 40), AOD.Vector(8, 48)),
      AOD.SheetRect(meteor, AOD.Vector(0, 48), AOD.Vector(8, 56)),
      AOD.SheetRect(meteor, AOD.Vector(0, 56), AOD.Vector(8, 64))
    ];
    meteor_small = [
      AOD.SheetRect(meteor, AOD.Vector(8,  0) ,AOD.Vector(24, 16)),
      AOD.SheetRect(meteor, AOD.Vector(8, 16) ,AOD.Vector(24, 32)),
      AOD.SheetRect(meteor, AOD.Vector(8, 32) ,AOD.Vector(24, 48)),
      AOD.SheetRect(meteor, AOD.Vector(8, 48) ,AOD.Vector(24, 64))
    ];
    meteor_medium = [
      AOD.SheetRect(meteor, AOD.Vector(24,  0), AOD.Vector(56, 32)),
      AOD.SheetRect(meteor, AOD.Vector(24, 32), AOD.Vector(56, 64))
    ];
    meteor_large = AOD.SheetRect(meteor, AOD.Vector(56,   0),
                                         AOD.Vector(120, 64));
    upgrades = [
      AOD.SheetRect(upgrade, AOD.Vector( 0,  0), AOD.Vector( 32,  32)),
      AOD.SheetRect(upgrade, AOD.Vector( 0, 32), AOD.Vector( 32,  64)),
      AOD.SheetRect(upgrade, AOD.Vector( 0, 64), AOD.Vector( 32,  96)),
      AOD.SheetRect(upgrade, AOD.Vector( 0, 96), AOD.Vector( 32, 128))
    ];
  }
}

class Sound_Data {
public: static:
  uint bg_music;
  uint[] sf;

  void Initialize() {
    bg_music = AOD.Load_Sound("assets/exult.ogg");
    sf = [
      AOD.Load_Sound("assets/hit0.ogg"),
      AOD.Load_Sound("assets/hit1.ogg"),
      AOD.Load_Sound("assets/hit2.ogg"),
      AOD.Load_Sound("assets/hit3.ogg"),
      AOD.Load_Sound("assets/hit4.ogg"),
      AOD.Load_Sound("assets/hit5.ogg"),
      AOD.Load_Sound("assets/hit6.ogg")
    ];
  }
}
