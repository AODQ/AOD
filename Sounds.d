import derelict.opengl3.gl3;
import derelict.sdl2.sdl;

import AOD.Console : Output, Debug_Output;
import std.string;
import std.conv : to;

static class SoundEngine {
  int sound_size, music_size;
  immutable(int) Max_channels = 64;
  int[] channel_playing;
  void Stop_Sound(int channel) {
    channel_playing[channel] = 0;
  }

  void Set_Up() {
    if ( Mix_OpenAudio( 44100, MIX_DEFAULT_FORMAT, 2, 4096) == -1 )
      AOD.Output("Init Audio Error: " + (string)Mix_GetError());
    int t = Mix_AllocateChannels(Max_channels);
    int rate, channels;
    ushort format;
    Mix_QuerySpec(&rate, &format, &channels);

    AOD.Output("Audio specs:");
    AOD.Output(std.to!string(rate) + " Hz");
    AOD.Output(std.to!string(format&0xFF) + " bitrate " +
      (channels > 2 ? "surround" : (channels > 1) ? "stereo" : "mono") +
      "(" + (format&0x1000 ? "BE" : "LE") + ")");
    AOD.Output("1024 bytes of audio buffer");
    AOD.Output(std.to!string(t) + " channels allocated");

    Mix_Init(MIX_INIT_OGG);
    Mix_ChannelFinished(Stop_Sound);
  }
}


static class Sounds {
  Mix_Chunk* Load_Sound(string);
  void Delete_Sound(Mix_Chunk* mix) {
    Mix_FreeChunk(mix);
  }
  int Play_Sound(Mix_Chunk* mix, int vol = 256, int rep = 0) {
    if ( mix == null ) return -1;
    int a = Mix_PlayChannelTimed(-1, mix, rep, -1);
    if ( a < 0 )
      return -1;
    else {
      Mix_Volume(a, volume);
      SoundEngine.channel_playing[a] = 1;
    }
    return a;
  }
  bool Channel_State(int x) { return SoundEngine.channel_playing[x]; }
  int R_Max_Channels() { return SoundEngine.Max_Channels; }

  Mix_Music* Load_Music(string str) {
    Mix_Music* sample = Mix_LoadMUS(str.ptr);
    if ( sample <= 0 ) {
      AOD.Debug_Output("Error loading " + str  + ": " + Mix_GetError());
      return null;
    }
    return sample;
  }

  void Delete_Music(Mix_Music* mix) {
    Mix_FreeMusic(mix);
  }

  bool Play_Music(Mix_Music* mix, int vol, int rep) {
    int a = Mix_PlayMusic(mix, rep);
    Mix_VolumeMusic(vol);
    if ( a == -1 ) {
      AOD.Debug_Output("Could not play music: " + 
    }
  }
  
  void Stop_Music() { Mix_HaltMusic(); }
  bool Music_State() { return Mix_PlayingMusic(); }
} 
