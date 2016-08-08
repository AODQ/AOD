/**
  -- still in development, check in later --
*/
module AODCore.sound;
import derelict.openal.al;
import derelict.vorbis.vorbis;
import derelict.vorbis.file;

import AODCore.console : Output, Debug_Output;
import std.string;
import std.conv : to;

class SoundEng {
static:
  ALCdevice*  al_device;
  ALCcontext* al_context;
  immutable(int) Buffer_size = 4096,
                 Buffer_amt  =    3;

  ALfloat[] listener_position    = [0.0,0.0,4.0              ] ;
  ALfloat[] listener_velocity    = [0.0,0.0,0.0              ] ;
  ALfloat[] listener_orientation = [0.0,0.0,1.0, 0.0,1.0,0.0 ] ;

  void Set_Up() {
    import derelict.util.exception;
    import std.stdio;
    al_device = alcOpenDevice(null);
    Check_AL_Errors() ;
    if ( al_device == null ) {
      throw new Exception("Failed to open ALC device");
    }
    al_context = alcCreateContext(al_device, null);
    Check_AL_Errors() ;
    alcMakeContextCurrent(al_context);
    Check_AL_Errors() ;

    writeln("Setting listener");
    alListenerfv(AL_POSITION, listener_position.ptr);
    Check_AL_Errors() ;
    alListenerfv(AL_VELOCITY, listener_velocity.ptr);
    Check_AL_Errors() ;
    alListenerfv(AL_ORIENTATION, listener_orientation.ptr);
    Check_AL_Errors() ;

    writeln("spawning thread");
    import std.concurrency;
    thread_id = spawn(&Main_Sound_Loop);

    writeln("Finished with setting up AL");
  }
  
  import std.concurrency : Tid;

  private Tid thread_id;

  Sample LoadOGG(immutable(string) file_name) {
    Sample s = new Sample();

    alGenBuffers(Buffer_amt, s.buffer_id.ptr);
    Check_AL_Errors();
    alGenSources(1, &s.source_id);
    Check_AL_Errors();
    s.file_name = file_name;

    import std.stdio;
    import core.stdc.stdio : fopen;
    FILE* f = fopen(file_name.ptr, "rb".ptr);
    if ( f == null ) {
      writeln("Error opening file for playing: " ~ file_name);
      return null;
    }
    vorbis_info* p_info;
    OggVorbis_File ogg_file;
    writeln("Loading song " ~ file_name);
    auto x = ov_open(f, &ogg_file, null, 0);
    if ( x != 0 ) {
      import std.conv : to;
      switch ( x ) {
        default:                                                         break ;
        case OV_EREAD:      writeln ("eread ");                          break ;
        case OV_ENOTVORBIS: writeln ("not vorbis");                      break ;
        case OV_EVERSION:   writeln ("mismatch version");                break ;
        case OV_EBADHEADER: writeln ("invalid vorbis bitstream header"); break ;
        case OV_EFAULT:     writeln ("Internal logic fault");            break ;
      }
      writeln("error: "~ to!string(x));
      throw new Exception("OGG file not found: " ~ file_name);
    }
    Check_AL_Errors() ;
    p_info = ov_info(&ogg_file, -1);
    if ( p_info is null ) {
      throw new Exception("Could not generate info for OGG file");
    }
    Check_AL_Errors() ;

    s.format = p_info.channels == 1 ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16;
    s.freq = p_info.rate;
    
    s.ogg_file = ogg_file;
    Check_AL_Errors() ;
    writeln("OGG Sample loaded");

    return s;
  }

  // returns true if error
  bool Check_AL_Errors() {
    import std.stdio;
    int error = alGetError();
    switch ( error ) {
      default: break;
      case AL_NO_ERROR: return false;
    }
    write("OpenAL error: ");
    switch ( error ) {
      default: assert(0);
      case AL_INVALID_NAME:
        writeln("AL_INVALID_NAME");
      break;
      case AL_INVALID_ENUM:
        writeln("AL_INVALID_ENUM");
      break;
      case AL_INVALID_VALUE:
        writeln("AL_INVALID_VALUE");
      break;
      case AL_INVALID_OPERATION:
        writeln("AL_INVALID_OPERATION");
      break;
      case AL_OUT_OF_MEMORY:
        writeln("AL_OUT_OF_MEMORY");
      break;
    }
    return true;
  }

  // returns TRUE if file has finished loading or errored
  bool Stream_Buffer( Sample s, ALuint buffer_id ) {
    // load buffer 
    byte[Buffer_size] buffer;
    int result, section = 0, size = 0;
    while ( size < Buffer_size ) {
      result = ov_read(&s.ogg_file, buffer.ptr + size, Buffer_size - size,
                       0, 2, 1, &section);

      if ( result > 0 ) size += result;
      else if ( result < 0 ) {
        import std.stdio : writeln;
        writeln("Error while attempting to buffer sample" ~ s.file_name);
        return true;
      } else {
        break;
      }
    }

    if ( size == 0 ) {
      return true;
    }

    // set to OpenAL
    alBufferData ( buffer_id, s.format, buffer.ptr, size, s.freq );
    SoundEng.Check_AL_Errors();
    return false;
  }

  class Sample {
    ALint state;
    bool loop;
    ALuint[Buffer_amt] buffer_id;
    ALuint source_id;
    OggVorbis_File ogg_file;
    ALenum format;
    ALint freq;
    string file_name;
  };

}

private enum ThreadMsg {
  PlaySample, PauseSample, StopSample,
  PlaySound, StopSound,
  ChangePosition,
  StopAllSounds
}

private void Main_Sound_Loop() {
  SoundEng.Sample current_song;
  bool playing_song;

  void Play_Sample() {
    auto s = current_song;
    playing_song = true;
    foreach ( i; 0 .. SoundEng.Buffer_amt ) // buffer 
      SoundEng.Stream_Buffer(s, s.buffer_id[i]);
    alSourceQueueBuffers(s.source_id, 3, s.buffer_id.ptr);
    SoundEng.Check_AL_Errors();
    alSourcei(s.source_id, AL_LOOPING, AL_FALSE);
    alSourcePlay(s.source_id);
    SoundEng.Check_AL_Errors();
  }

  while ( true ) {
    // check for messages
    import std.concurrency;
    import std.stdio : writeln;
    import core.time;
    receiveTimeout(dur!"msecs"(1), /* no hanging */
      (ThreadMsg msg, immutable(string)[] params) {
        switch ( msg ) {
          default: break;
          case ThreadMsg.PlaySample:
            current_song = SoundEng.LoadOGG(params[0]);
            writeln("Playing song " ~ params[0]);
            Play_Sample();
          break;
        }
      },
      (ThreadMsg msg, immutable(float)[] params) {
        switch ( msg ) {
          default: break;
          case ThreadMsg.ChangePosition:
            alSourcefv(current_song.source_id, AL_POSITION, params.ptr);
            if ( SoundEng.Check_AL_Errors() ) {
              writeln("Couldn't update song's position");
            }
          break;
        }
      }
    );


    if ( playing_song ) { // refresh song
      auto s = current_song;

      int state, processed;
      bool ended = false;

      alGetSourcei(s.source_id, AL_SOURCE_STATE, &state);
      alGetSourcei(s.source_id, AL_BUFFERS_PROCESSED, &processed);

      while ( processed -- > 0) {
        ALuint buffer;
        ALenum error;

        alSourceUnqueueBuffers(s.source_id, 1, &buffer);
        SoundEng.Check_AL_Errors();
        ended = SoundEng.Stream_Buffer(s, buffer);
        if ( ended ) break;
        alSourceQueueBuffers(s.source_id, 1, &buffer);
        SoundEng.Check_AL_Errors();
        if ( state != AL_PLAYING && state != AL_PAUSED )
          alSourcePlay(s.source_id);
      }
      // processing finished
    }

    // refresh sounds
    import core.thread;
    Thread.sleep(dur!("msecs")(10));
  }

}


class Sounds {
static:
  void Play_Sample(immutable(string) file_name) in {
    import File = std.file;
    assert(File.exists(file_name));
  } body {
    import std.stdio : writeln;
    writeln("Playing song " ~ file_name);
    import std.concurrency;
    send(SoundEng.thread_id, ThreadMsg.PlaySample,[ file_name ]);
  }

  void Change_Sample_Position(immutable(float) x, immutable(float) y,
                              immutable(float) z) {
    import std.concurrency;
    send(SoundEng.thread_id, ThreadMsg.ChangePosition, [x, y, z]);
  }

  void Clean_Up() {
    import std.concurrency;
    /* send(SoundEng.thread_id, ThreadMsg.StopSound,     []); */
    /* send(SoundEng.thread_id, ThreadMsg,StopAllSounds, []); */
  }
}
