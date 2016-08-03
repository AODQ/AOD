module AOD.ClientVars;
import std.string;

struct Keybind {
public:
  int key;
  string command;
}

int screen_width;
int screen_height;
alias Keybind = std::pair<int, std::string>;

void Load_Config() {
  // do later ...
}
